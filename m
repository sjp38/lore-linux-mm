Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f169.google.com (mail-ig0-f169.google.com [209.85.213.169])
	by kanga.kvack.org (Postfix) with ESMTP id E21D06B0038
	for <linux-mm@kvack.org>; Tue,  6 Oct 2015 10:52:07 -0400 (EDT)
Received: by igbkq10 with SMTP id kq10so86343263igb.0
        for <linux-mm@kvack.org>; Tue, 06 Oct 2015 07:52:07 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id p19si13504043igs.80.2015.10.06.07.52.05
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=RC4-SHA bits=128/128);
        Tue, 06 Oct 2015 07:52:06 -0700 (PDT)
Subject: Re: Can't we use timeout based OOM warning/killing?
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20150925093556.GF16497@dhcp22.suse.cz>
	<201509260114.ADI35946.OtHOVFOMJQFLFS@I-love.SAKURA.ne.jp>
	<201509290118.BCJ43256.tSFFFMOLHVOJOQ@I-love.SAKURA.ne.jp>
	<20151002123639.GA13914@dhcp22.suse.cz>
	<201510031502.BJD59536.HFJMtQOOLFFVSO@I-love.SAKURA.ne.jp>
In-Reply-To: <201510031502.BJD59536.HFJMtQOOLFFVSO@I-love.SAKURA.ne.jp>
Message-Id: <201510062351.JHJ57310.VFQLFHFOJtSMOO@I-love.SAKURA.ne.jp>
Date: Tue, 6 Oct 2015 23:51:49 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: rientjes@google.com, oleg@redhat.com, torvalds@linux-foundation.org, kwalker@redhat.com, cl@linux.com, akpm@linux-foundation.org, hannes@cmpxchg.org, vdavydov@parallels.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, skozina@redhat.com

Tetsuo Handa wrote:
> Sorry. This was my misunderstanding. But I still think that we need to be
> prepared for cases where zapping OOM victim's mm approach fails.
> ( http://lkml.kernel.org/r/201509242050.EHE95837.FVFOOtMQHLJOFS@I-love.SAKURA.ne.jp )

I tested whether it is easy/difficult to make zapping OOM victim's mm
approach fail. The result seems that not difficult to make it fail.

---------- Reproducer start ----------
#define _GNU_SOURCE
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <sched.h>
#include <sys/mman.h>

static int reader(void *unused)
{
	char c;
	int fd = open("/proc/self/cmdline", O_RDONLY);
	while (pread(fd, &c, 1, 0) == 1);
	return 0;
}

static int writer(void *unused)
{
	const int fd = open("/proc/self/exe", O_RDONLY);
	static void *ptr[10000];
	int i;
	sleep(2);
	while (1) {
		for (i = 0; i < 10000; i++)
			ptr[i] = mmap(NULL, 4096, PROT_READ, MAP_PRIVATE, fd,
				      0);
		for (i = 0; i < 10000; i++)
			munmap(ptr[i], 4096);
	}
	return 0;
}

int main(int argc, char *argv[])
{
	int zero_fd = open("/dev/zero", O_RDONLY);
	char *buf = NULL;
	unsigned long size = 0;
	int i;
	for (size = 1048576; size < 512UL * (1 << 30); size <<= 1) {
		char *cp = realloc(buf, size);
		if (!cp) {
			size >>= 1;
			break;
		}
		buf = cp;
	}
	for (i = 0; i < 100; i++) {
		clone(reader, malloc(1024) + 1024, CLONE_THREAD | CLONE_SIGHAND | CLONE_VM,
		      NULL);
	}
	clone(writer, malloc(1024) + 1024, CLONE_THREAD | CLONE_SIGHAND | CLONE_VM, NULL);
	read(zero_fd, buf, size); /* Will cause OOM due to overcommit */
	return * (char *) NULL; /* Kill all threads. */
}
---------- Reproducer end ----------

(I wrote this program for trying to mimic a trouble that a customer's system
 hung up with a lot of ps processes blocked at reading /proc/pid/ entries
 due to unkillable down_read(&mm->mmap_sem) in __access_remote_vm(). Though
 I couldn't identify what function was holding the mmap_sem for writing...)

Uptime > 429 of http://I-love.SAKURA.ne.jp/tmp/serial-20151006.txt.xz showed
a OOM livelock that

  (1) thread group leader is blocked at down_read(&mm->mmap_sem) in exit_mm()
      called from do_exit().

  (2) writer thread is blocked at down_write(&mm->mmap_sem) in vm_mmap_pgoff()
      called from SyS_mmap_pgoff() called from SyS_mmap().

  (3) many reader threads are blocking the writer thread because of
      down_read(&mm->mmap_sem) called from proc_pid_cmdline_read().

  (4) while the thread group leader is blocked at down_read(&mm->mmap_sem),
      some of the reader threads are trying to allocate memory via page fault.

So, zapping the first OOM victim's mm might fail by chance.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
