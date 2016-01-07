Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f43.google.com (mail-wm0-f43.google.com [74.125.82.43])
	by kanga.kvack.org (Postfix) with ESMTP id 5F62D828DE
	for <linux-mm@kvack.org>; Thu,  7 Jan 2016 14:26:35 -0500 (EST)
Received: by mail-wm0-f43.google.com with SMTP id l65so109762110wmf.1
        for <linux-mm@kvack.org>; Thu, 07 Jan 2016 11:26:35 -0800 (PST)
Received: from libero.it (smtp-17.italiaonline.it. [212.48.25.145])
        by mx.google.com with ESMTP id ko8si159359750wjb.26.2016.01.07.11.26.34
        for <linux-mm@kvack.org>;
        Thu, 07 Jan 2016 11:26:34 -0800 (PST)
Message-ID: <1452194792.7839.20.camel@libero.it>
Subject: Re: Unrecoverable Out Of Memory kernel error
From: Guido Trentalancia <g.trentalancia@libero.it>
Date: Thu, 07 Jan 2016 20:26:32 +0100
In-Reply-To: <20160105155400.GC15594@dhcp22.suse.cz>
References: <1451408582.2783.20.camel@libero.it>
	 <20160105155400.GC15594@dhcp22.suse.cz>
Content-Type: text/plain; charset="ISO-8859-1"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org

Hello Michal.

I believe it's a serious problem, as an unprivileged user-space
application can basically render the system completely unusable, so
that it must be hard-rebooted.

I'll try to answer your points below...

On mar, 2016-01-05 at 16:54 +0100, Michal Hocko wrote:
> On Tue 29-12-15 18:03:02, Guido Trentalancia wrote:
> > Hello.
> > 
> > I am getting an unrecoverable Out Of Memory error on kernel 4.3.1,
> > while compiling Firefox 43.0.3. The system becomes unresponsive,
> > the
> > hard-disk is continuously busy and a hard-reboot must be forced.
> > 
> > Here is the report from the kernel:
> [...]
> > Dec 29 12:28:25 vortex kernel: Mem-Info:
> > Dec 29 12:28:25 vortex kernel: active_anon:716916
> > inactive_anon:199483 isolated_anon:0
> > Dec 29 12:28:25 vortex kernel: active_file:3108 inactive_file:3160
> > isolated_file:32
> > Dec 29 12:28:25 vortex kernel: unevictable:4316 dirty:3173
> > writeback:55 unstable:0
> > Dec 29 12:28:25 vortex kernel: slab_reclaimable:16548
> > slab_unreclaimable:9058
> > Dec 29 12:28:25 vortex kernel: mapped:4037 shmem:13351
> > pagetables:6846 bounce:0
> > Dec 29 12:28:25 vortex kernel: free:7058 free_pcp:295 free_cma:0
> [...]
> > Dec 29 12:28:25 vortex kernel: Free swap  = 0kB
> > Dec 29 12:28:25 vortex kernel: Total swap = 16380kB
> 
> Your swap space is full and basically all the memory is eaten by the
> anonymous memory which cannot be reclaimed.
> [...]
> > Dec 29 12:28:25 vortex kernel: Killed process 10197 (cc1plus)
> > total-vm:969632kB, anon-rss:809184kB, file-rss:9308kB
> 
> This task is consuming a lot of memory so killing it should help to
> release the memory pressure. It would be interesting to see whether
> the
> task has died or not. 

I am not able to login into any console and therefore I cannot check
whether the gcc task died or not.

> Are there any follow up messages in the log?

The first message have been posted entirely. Such message is then
repeated several times (for the "cc1plus" task and once for the "as"
assembler). The other messages are similar and therefore have not been
posted...

It only appears to happen with parallel builds ("make -j4") and not
with normal builds ("make" or "make -j1"), but that's another issue, I
mean a user-space application should not be able to render the system
unusable by sucking all of its memory...

Is the hard-disk working continuosly because the kernel is trying to
swap endlessly and cannot reclaim back memory ?!?

> Maybe the target task is stuck behind some lock which is blocked
> because
> of a memory allocation. We have seen deadlocks like that in the past.
> The current linux-next has some measures to reduce the probability of
> such a deadlock so you might give it a try. Especially if this is
> reproducible.

It's probably possible to reproduce it on my system by launching a
parallel build "make -j4" of the firefox 43.0.3.

Gcc is version 5.3.0, glibc is version 2.22. If the same versions of
gcc, glibc and firefox are installed on another system, it might or
might not be possible to reproduce it, I have not checked...

Guido

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
