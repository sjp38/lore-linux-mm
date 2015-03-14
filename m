Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f173.google.com (mail-ob0-f173.google.com [209.85.214.173])
	by kanga.kvack.org (Postfix) with ESMTP id 2D0FE6B00CA
	for <linux-mm@kvack.org>; Sat, 14 Mar 2015 09:53:06 -0400 (EDT)
Received: by obdfc2 with SMTP id fc2so8145788obd.3
        for <linux-mm@kvack.org>; Sat, 14 Mar 2015 06:53:05 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id pa9si2564105obb.61.2015.03.14.06.53.04
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sat, 14 Mar 2015 06:53:04 -0700 (PDT)
Subject: Re: How to handle TIF_MEMDIE stalls?
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20150210151934.GA11212@phnom.home.cmpxchg.org>
	<201502111123.ICD65197.FMLOHSQJFVOtFO@I-love.SAKURA.ne.jp>
	<201502112237.CDD87547.tJOFFVHLOOQSMF@I-love.SAKURA.ne.jp>
	<20150211185015.GA2792@redhat.com>
	<20150211185945.GA3578@redhat.com>
In-Reply-To: <20150211185945.GA3578@redhat.com>
Message-Id: <201503142203.EJB52611.FOOtHFSFVJQMOL@I-love.SAKURA.ne.jp>
Date: Sat, 14 Mar 2015 22:03:59 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: oleg@redhat.com
Cc: mhocko@suse.cz, hannes@cmpxchg.org, david@fromorbit.com, dchinner@redhat.com, linux-mm@kvack.org, rientjes@google.com, akpm@linux-foundation.org, mgorman@suse.de, torvalds@linux-foundation.org

Oleg Nesterov wrote:
> On 02/11, Oleg Nesterov wrote:
> >
> > On 02/11, Tetsuo Handa wrote:
> > >
> > > (Asking Oleg this time.)
> >
> > Well, sorry, I ignored the previous discussion, not sure I understand you
> > correctly.
> >
> > > > Though, more serious behavior with this reproducer is (B) where the system
> > > > stalls forever without kernel messages being saved to /var/log/messages .
> > > > out_of_memory() does not select victims until the coredump to pipe can make
> > > > progress whereas the coredump to pipe can't make progress until memory
> > > > allocation succeeds or fails.
> > >
> > > This behavior is related to commit d003f371b2701635 ("oom: don't assume
> > > that a coredumping thread will exit soon"). That commit tried to take
> > > SIGNAL_GROUP_COREDUMP into account, but actually it is failing to do so.
> >
> > Heh. Please see the changelog. This "fix" is obviously very limited, it does
> > not even try to solve all problems (even with coredump in particular).
> >
> > Note also that SIGNAL_GROUP_COREDUMP is not even set if the process (not a
> > sub-thread) shares the memory with the coredumping task. It would be better
> > to check mm->core_state != NULL instead, but this needs the locking. Plus
> > that process likely sleeps in D state in exit_mm(), so this can't help.
> >
> > And that is why we set SIGNAL_GROUP_COREDUMP in zap_threads(), not in
> > zap_process(). We probably want to make that "wait for coredump_finish()"
> > sleep in exit_mm() killable, but this is not simple.
> 
> on a cecond thought, perhaps it makes sense to set SIGNAL_GROUP_COREDUMP
> anyway, even if a CLONE_VM process participating in coredump is not killable.
> I'll recheck tomorrow.

Ping?

> 
> > Sorry for noise if the above is not relevant.
> >
> > Oleg.
> 
> 

I tried https://lkml.org/lkml/2015/3/11/707 with retry_allocation_attempts == 1
(with http://marc.info/?l=linux-mm&m=141671829611143&w=2 for debug printk() ).

Although 0x2015a (which is !__GFP_FS) allocation likely fails within a few
jiffies under TIF_MEMDIE condition, TIF_MEMDIE condition itself cannot be solved
until SIGNAL_GROUP_COREDUMP patch is proposed.

----------
XFS: possible memory allocation deadlock in xfs_buf_allocate_memory (mode:0x250)
XFS: possible memory allocation deadlock in xfs_buf_allocate_memory (mode:0x250)
warn_alloc_failed: 212565 callbacks suppressed
crond: page allocation failure: order:0, mode:0x2015a
rngd: page allocation failure: order:0, mode:0x2015a
CPU: 3 PID: 1667 Comm: rngd Not tainted 4.0.0-rc3+ #37
Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/31/2013
 0000000000000000 00000000ce4cec53 0000000000000000 ffffffff815f30c4
 000000000002015a ffffffff8111063e ffff88007fffdb00 0000000000000000
 0000000000000040 ffff88007c223db0 0000000000000000 00000000ce4cec53
Call Trace:
 [<ffffffff815f30c4>] ? dump_stack+0x40/0x50
 [<ffffffff8111063e>] ? warn_alloc_failed+0xee/0x150
 [<ffffffff81113b03>] ? __alloc_pages_nodemask+0x623/0xa10
 [<ffffffff81150c57>] ? alloc_pages_current+0x87/0x100
 [<ffffffff8110d30d>] ? filemap_fault+0x1bd/0x400
 [<ffffffff812e3dbc>] ? radix_tree_next_chunk+0x5c/0x240
 [<ffffffff8112f85b>] ? __do_fault+0x4b/0xe0
 [<ffffffff81134465>] ? handle_mm_fault+0xc85/0x1640
 [<ffffffff81051c9a>] ? __do_page_fault+0x16a/0x430
 [<ffffffff81051f90>] ? do_page_fault+0x30/0x70
 [<ffffffff815fb03f>] ? error_exit+0x1f/0x60
 [<ffffffff815fae18>] ? page_fault+0x28/0x30
----------

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
