Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id BED1A6B025F
	for <linux-mm@kvack.org>; Tue, 29 Aug 2017 10:38:22 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id o63so10463492qkb.4
        for <linux-mm@kvack.org>; Tue, 29 Aug 2017 07:38:22 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id w23sor1838859qkb.13.2017.08.29.07.38.21
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 29 Aug 2017 07:38:21 -0700 (PDT)
Date: Tue, 29 Aug 2017 07:38:18 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH] mm: Use WQ_HIGHPRI for mm_percpu_wq.
Message-ID: <20170829143817.GK491396@devbig577.frc2.facebook.com>
References: <20170828121055.GI17097@dhcp22.suse.cz>
 <20170828170611.GV491396@devbig577.frc2.facebook.com>
 <201708290715.FEI21383.HSFOQtJOMVOFFL@I-love.SAKURA.ne.jp>
 <20170828230256.GF491396@devbig577.frc2.facebook.com>
 <20170828230924.GG491396@devbig577.frc2.facebook.com>
 <201708292014.JHH35412.FMVFHOQOJtSLOF@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201708292014.JHH35412.FMVFHOQOJtSLOF@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: mhocko@kernel.org, akpm@linux-foundation.org, linux-mm@kvack.org, mgorman@suse.de, vbabka@suse.cz

Hello, Tetsuo.

On Tue, Aug 29, 2017 at 08:14:49PM +0900, Tetsuo Handa wrote:
> [  897.503107] workqueue mm_percpu_wq: flags=0x18
> [  897.503291]   pwq 5: cpus=2 node=0 flags=0x0 nice=-20 active=1/256
> [  897.503301]     pending: vmstat_update{58752}

This is weird.  Assuming 1000HZ, the work item has been pending for
about a minute but there's no active worker 

> [  897.505127] pool 0: cpus=0 node=0 flags=0x0 nice=0 hung=40s workers=2 manager: 135
> [  897.505160] pool 2: cpus=1 node=0 flags=0x0 nice=0 hung=0s workers=3 idle: 3311 2132
> [  897.505179] pool 4: cpus=2 node=0 flags=0x0 nice=0 hung=59s workers=2 manager: 444
> [  897.505200] pool 10: cpus=5 node=0 flags=0x0 nice=0 hung=43s workers=3 idle: 41 257
> [  897.505478] pool 256: cpus=0-127 flags=0x4 nice=0 hung=0s workers=3 idle: 3305 378

but there's no active worker on the pool and the rescuer hasn't been
kicked off.

> #include <stdio.h>
> #include <stdlib.h>
> #include <unistd.h>
> #include <sys/types.h>
> #include <sys/stat.h>
> #include <fcntl.h>
> 
> int main(int argc, char *argv[])
> {
> 	static char buffer[4096] = { };
> 	char *buf = NULL;
> 	unsigned long size;
> 	unsigned long i;
> 	for (i = 0; i < 1024; i++) {
> 		if (fork() == 0) {
> 			int fd = open("/proc/self/oom_score_adj", O_WRONLY);
> 			write(fd, "1000", 4);
> 			close(fd);
> 			snprintf(buffer, sizeof(buffer), "/tmp/file.%u", getpid());
> 			fd = open(buffer, O_WRONLY | O_CREAT | O_APPEND, 0600);
> 			sleep(1);
> 			while (write(fd, buffer, sizeof(buffer)) == sizeof(buffer));
> 			_exit(0);
> 		}
> 	}
> 	for (size = 1048576; size < 512UL * (1 << 30); size <<= 1) {
> 		char *cp = realloc(buf, size);
> 		if (!cp) {
> 			size >>= 1;
> 			break;
> 		}
> 		buf = cp;
> 	}
> 	sleep(2);
> 	/* Will cause OOM due to overcommit */
> 	for (i = 0; i < size; i += 4096)
> 		buf[i] = 0;
> 	return 0;
> }

I'll try to repro and find out what's going on.

Thanks!

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
