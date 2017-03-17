Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id CDAE96B0038
	for <linux-mm@kvack.org>; Fri, 17 Mar 2017 09:54:44 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id h188so3896149wma.4
        for <linux-mm@kvack.org>; Fri, 17 Mar 2017 06:54:44 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g29si3322638wmi.145.2017.03.17.06.54.43
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 17 Mar 2017 06:54:43 -0700 (PDT)
Date: Fri, 17 Mar 2017 14:54:40 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: DOM Worker: page allocation stalls (4.9.13)
Message-ID: <20170317135440.GJ26298@dhcp22.suse.cz>
References: <20170316100409.GR802@shells.gnugeneration.com>
 <20170317084652.GD26298@dhcp22.suse.cz>
 <08ae9fca-9388-1f8a-f8ae-14ada0bdbb92@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <08ae9fca-9388-1f8a-f8ae-14ada0bdbb92@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: "Philip J. Freeman" <elektron@halo.nu>, linux-mm@kvack.org

On Fri 17-03-17 22:24:40, Tetsuo Handa wrote:
> On 2017/03/17 17:46, Michal Hocko wrote:
> > On Thu 16-03-17 03:04:09, Philip J. Freeman wrote:
> >> My laptop became almost totally un responsive today. I was able to
> >> switch VTs but not log in and had to power cycle to regain control. I
> >> don't understand what this means. Any ideas?
> >>
> >> Mar 14 14:31:20 x61s-44a5 kernel: [168382.032039] DOM Worker: page allocation stalls for 10646ms, order:0, mode:0x24280ca(GFP_HIGHUSER_MOVABLE|__GFP_ZERO)
> > [...]
> >> Mar 14 14:31:22 x61s-44a5 kernel: [168382.032181] Mem-Info:
> >> Mar 14 14:31:22 x61s-44a5 kernel: [168382.032192] active_anon:308454 inactive_anon:154809 isolated_anon:224
> >> Mar 14 14:31:22 x61s-44a5 kernel: [168382.032192]  active_file:869 inactive_file:978 isolated_file:0
> >> Mar 14 14:31:22 x61s-44a5 kernel: [168382.032192]  unevictable:0 dirty:0 writeback:0 unstable:0
> >> Mar 14 14:31:22 x61s-44a5 kernel: [168382.032192]  slab_reclaimable:6099 slab_unreclaimable:8555
> >> Mar 14 14:31:22 x61s-44a5 kernel: [168382.032192]  mapped:1999 shmem:156254 pagetables:2929 bounce:0
> >> Mar 14 14:31:22 x61s-44a5 kernel: [168382.032192]  free:13192 free_pcp:0 free_cma:0
> > 
> > OK, so the allocation couldn't make a forward progress for more than
> > 10s. You do not seem to have many file pages on the LRU lists left
> > and so you only have anonymous memory as reclaimable. Slab doesn't
> > have many pages either. Everything together makes it 1886MB out of 2GB.
> > ~50MB is free so this means ~70MB is in unaccounted memory (50MB is
> > reserved) which looks reasonably and I wouldn't suspect any kernel
> > memory leak
> 
> I don't suspect any kernel memory leak here.
> 
> > And again the anonymous memory pressure grows. So I would suspect some
> > userspace application went off the hook and started consuming a lot of
> > anonymous memory which gets you to a trashing stage when basically
> > nothing can move on much without swap out. The page cache is at its
> > minimum and I suspect that most binaries would have to be read from disk
> > and you reached the point of trashing. I am afraid we are not really
> > great at handling these situations from the kernel well. Killing the
> > memory hog would be probably the most sane thing to do.
> > 
> 
> I don't know what "DOM Worker" process is. But guessing from that there is
> "firefox-esr" process, "DOM Worker" is a process related to HTML5 Web Workers API.
> Since web browser processes can heavily consume memory depending on the content
> loaded (or memory leak of plugins), it is possible that you are overstressing
> the system.
> 
> "DMA32 free:" is below "DMA32 min:" which I think means that the OOM killer
> would have been triggerred immediately if there is no swap.
> 
> I guess there were other processes which stalled less than 10 seconds. Maybe
> processes stalling at doing swap I/O exist, but we can't know them because
> warn_alloc() threshold is not configurable and __GFP_NOWARN allocations are
> not reported by warn_alloc(). Too bad.
> 
> If you can rebuild your kernel, calling dump_tasks() in mm/oom_kill.c when
> you hit warn_alloc() warnings might help.

I do not really see how this would help much. If anything watching for
/proc/vmstat counters would tell us much more.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
