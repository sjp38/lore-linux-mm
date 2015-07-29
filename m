Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f170.google.com (mail-pd0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id 2281F6B0256
	for <linux-mm@kvack.org>; Wed, 29 Jul 2015 09:20:36 -0400 (EDT)
Received: by pdrg1 with SMTP id g1so5989266pdr.2
        for <linux-mm@kvack.org>; Wed, 29 Jul 2015 06:20:35 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id u4si61728764pdh.9.2015.07.29.06.20.34
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 29 Jul 2015 06:20:35 -0700 (PDT)
Subject: Re: [RFC -v2] panic_on_oom_timeout
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20150617121104.GD25056@dhcp22.suse.cz>
	<201506172131.EFE12444.JMLFOSVOHFOtFQ@I-love.SAKURA.ne.jp>
	<20150617125127.GF25056@dhcp22.suse.cz>
	<20150617132427.GG25056@dhcp22.suse.cz>
	<20150729115543.GG15801@dhcp22.suse.cz>
In-Reply-To: <20150729115543.GG15801@dhcp22.suse.cz>
Message-Id: <201507292220.DBB48488.OHLOJMVtOFFSFQ@I-love.SAKURA.ne.jp>
Date: Wed, 29 Jul 2015 22:20:03 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: linux-mm@kvack.org, rientjes@google.com, hannes@cmpxchg.org, tj@kernel.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org

Michal Hocko wrote:
> On Wed 17-06-15 15:24:27, Michal Hocko wrote:
> > On Wed 17-06-15 14:51:27, Michal Hocko wrote:
> > [...]
> > > The important thing is to decide what is the reasonable way forward. We
> > > have two two implementations of panic based timeout. So we should decide
> > 
> > And the most obvious question, of course.
> > - Should we add a panic timeout at all?
> > 
> > > - Should be the timeout bound to panic_on_oom?
> > > - Should we care about constrained OOM contexts?
> > > - If yes should they use the same timeout?
> > > - If yes should each memcg be able to define its own timeout?
> >        ^ no
> >  
> > > My thinking is that it should be bound to panic_on_oom=1 only until we
> > > hear from somebody actually asking for a constrained oom and even then
> > > do not allow for too large configuration space (e.g. no per-memcg
> > > timeout) or have separate mempolicy vs. memcg timeouts.
> > > 
> > > Let's start simple and make things more complicated later!
> 
> Any more ideas/thoughts on this?

No ideas/thoughts from my side.



By the way, the "set TIF_MEMDIE upon calling out_of_memory() when TIF_MEMDIE
was not set by previous out_of_memory() because oom_kill_process() chose a
different thread" logic

    if (current->mm &&
        (fatal_signal_pending(current) || task_will_free_mem(current))) {
            mark_oom_victim(current);
            goto out;
    }

sounds broken for me, for GFP_NOFS allocations do not call
out_of_memory() from the beginning.

Say, Process1 has two threads called Thread1 and Thread2. Thread1 was blocked
at unkillable lock and Thread2 was doing GFP_NOFS allocation from syscall
context (e.g. codes under security/ directory) when TIF_MEMDIE was set on
Thread1.

While failing GFP_NOFS allocation for ext4 filesystem's operations damages
the filesystem, failing GFP_NOFS allocation from syscall context will not
damage the filesystem. Therefore, Thread2 should be able to fail GFP_NOFS
allocations than wait for TIF_MEMDIE forever (which will never be set
because the logic above does not apply to GFP_NOFS allocation).

I didn't imagine kmalloc_killable() when I wrote "(3) Replace kmalloc()
with kmalloc_nofail() and kmalloc_noretry()." at
http://marc.info/?l=linux-mm&m=142408937117294 . But I came to feel that
introducing GFP_KILLABLE (retry unless fatal_signal_pending()) which is
between GFP_NORETRY (don't retry) and GFP_NOFAIL (retry forever) might help
reducing the possibility of stalling multi-threaded OOM victim process.



Other than that, my ideas/thoughts are staying at
http://marc.info/?l=linux-mm&m=143239200805478 .

Please continue CC'ing me because I'm not subscribed to linux-mm ML.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
