Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id CA5826B0395
	for <linux-mm@kvack.org>; Wed, 21 Dec 2016 06:16:58 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id w13so30155562wmw.0
        for <linux-mm@kvack.org>; Wed, 21 Dec 2016 03:16:58 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k8si27110098wjv.25.2016.12.21.03.16.57
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 21 Dec 2016 03:16:57 -0800 (PST)
Date: Wed, 21 Dec 2016 12:16:53 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: OOM: Better, but still there on
Message-ID: <20161221111653.GF31118@dhcp22.suse.cz>
References: <862a1ada-17f1-9cff-c89b-46c47432e89f@I-love.SAKURA.ne.jp>
 <20161217210646.GA11358@boerne.fritz.box>
 <20161219134534.GC5164@dhcp22.suse.cz>
 <20161220020829.GA5449@boerne.fritz.box>
 <20161221073658.GC16502@dhcp22.suse.cz>
 <201612212000.EJJ21327.SFHOLQOtVFMOFJ@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201612212000.EJJ21327.SFHOLQOtVFMOFJ@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: nholland@tisys.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, clm@fb.com, dsterba@suse.cz, linux-btrfs@vger.kernel.org

On Wed 21-12-16 20:00:38, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > TL;DR
> > there is another version of the debugging patch. Just revert the
> > previous one and apply this one instead. It's still not clear what
> > is going on but I suspect either some misaccounting or unexpeted
> > pages on the LRU lists. I have added one more tracepoint, so please
> > enable also mm_vmscan_inactive_list_is_low.
> > 
> > Hopefully the additional data will tell us more.
> > 
> > On Tue 20-12-16 03:08:29, Nils Holland wrote:
[...]
> > > http://ftp.tisys.org/pub/misc/teela_2016-12-20.log.xz
> > 
> > This is the stall report:
> > [ 1661.485568] btrfs-transacti: page alloction stalls for 611058ms, order:0, mode:0x2420048(GFP_NOFS|__GFP_HARDWALL|__GFP_MOVABLE)
> > [ 1661.485859] CPU: 1 PID: 1950 Comm: btrfs-transacti Not tainted 4.9.0-gentoo #4
> > 
> > pid 1950 is trying to allocate for a _long_ time. Considering that this
> > is the only stall report, this means that reclaim took really long so we
> > didn't get to the page allocator for that long. It sounds really crazy!
> 
> warn_alloc() reports only if !__GFP_NOWARN.

yes and the above allocation clear is !__GFP_NOWARN allocation which is
reported after 611s! If there are no prior/lost warn_alloc() then it
implies we have spent _that_ much time in the reclaim. Considering the
tracing data we cannot really rule that out. All the reclaimers would
fight over the lru_lock and considering we are scanning the whole LRU
this will take some time.

[...]

> By the way, Michal, I'm feeling strange because it seems to me that your
> analysis does not refer to the implications of "x86_32 kernel". Maybe
> you already referred x86_32 by "they are from the highmem zone" though.

yes Highmem as well all those scanning anomalies is the 32b kernel
specific thing. I believe I have already mentioned that the 32b kernel
suffers from some inherent issues but I would like to understand what is
going on here before blaming the 32b.

One thing to note here, when we are talking about 32b kernel, things
have changed in 4.8 when we moved from the zone based to node based
reclaim (see b2e18757f2c9 ("mm, vmscan: begin reclaiming pages on a
per-node basis") and associated patches). It is possible that the
reporter is hitting some pathological path which needs fixing but it
might be also related to something else. So I am rather not trying to
blame 32b yet...

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
