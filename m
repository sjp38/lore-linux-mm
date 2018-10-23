Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5BD6B6B0010
	for <linux-mm@kvack.org>; Tue, 23 Oct 2018 12:55:57 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id p12-v6so1266502pfn.0
        for <linux-mm@kvack.org>; Tue, 23 Oct 2018 09:55:57 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t3-v6si1851862pfl.218.2018.10.23.09.55.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Oct 2018 09:55:56 -0700 (PDT)
Date: Tue, 23 Oct 2018 18:55:51 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: memcg versus clone(CLONE_VM without CLONE_THREAD)
Message-ID: <20181023165551.GU18839@dhcp22.suse.cz>
References: <4a36ab60-ab2b-eb54-f5a8-33f969f00e73@i-love.sakura.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4a36ab60-ab2b-eb54-f5a8-33f969f00e73@i-love.sakura.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: linux-mm <linux-mm@kvack.org>

On Tue 23-10-18 22:05:12, Tetsuo Handa wrote:
> I noticed that memcg OOM event does not trigger as expected when a thread
> group ID assigned by clone(CLONE_VM without CLONE_THREAD) is specified.
> A bit of surprise because what the "tasks" file says is not what the
> limitation is applied to...

Well, the issue is that the memcg is tracked by mm_struct while cgroups
organize by task_structs. So we have a concept of mm owner which
determines the memcg a task belongs to. In your case the owner is the
main process and that one doesn't run in the limited cgroup.

This is btw. a source of pain - e.g. have a look at
mm_update_next_owner.

> 
> ----------
> #define _GNU_SOURCE
> #include <stdio.h>
> #include <stdlib.h>
> #include <string.h>
> #include <sys/types.h>
> #include <sys/stat.h>
> #include <fcntl.h>
> #include <sched.h>
> #include <unistd.h>
> 
> static int memory_eater(void *unused) {
> 	FILE *fp;
> 	const unsigned long size = 1048576 * 200;
> 	char *buf = malloc(size);
> 	mkdir("/sys/fs/cgroup/memory/test1", 0755);
> 	fp = fopen("/sys/fs/cgroup/memory/test1/memory.limit_in_bytes", "w");
> 	fprintf(fp, "%lu\n", size / 2);
> 	fclose(fp);
> 	fp = fopen("/sys/fs/cgroup/memory/test1/tasks", "w");
> 	fprintf(fp, "%u\n", getpid());
> 	fclose(fp);
> 	fp = fopen("/dev/zero", "r");
> 	fread(buf, 1, size, fp);
> 	fclose(fp);
> 	return 0;
> }
> 
> int main(int argc, char *argv[])
> {
> 	if (clone(memory_eater, malloc(8192) + 8192,
> 		  /*CLONE_SIGHAND | CLONE_THREAD | */CLONE_VM, NULL) == -1)
> 		return 1;
> 	while (1)
> 		pause();
> 	return 0;
> }
> ----------

-- 
Michal Hocko
SUSE Labs
