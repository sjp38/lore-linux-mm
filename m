Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id E80B46B0038
	for <linux-mm@kvack.org>; Tue, 24 Oct 2017 16:06:41 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id 4so7401542wrt.8
        for <linux-mm@kvack.org>; Tue, 24 Oct 2017 13:06:41 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a22si748424wra.459.2017.10.24.13.06.40
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 24 Oct 2017 13:06:40 -0700 (PDT)
Date: Tue, 24 Oct 2017 22:06:39 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: swapper/0: page allocation failure: order:0,
 mode:0x1204010(GFP_NOWAIT|__GFP_COMP|__GFP_RECLAIMABLE|__GFP_NOTRACK),
 nodemask=(null)
Message-ID: <20171024200639.2pyxkw2cucwxrtlb@dhcp22.suse.cz>
References: <CABXGCsPEkwzKUU9OPRDOMue7TpWa4axTWg0FbXZAq+JZmoubGw@mail.gmail.com>
 <20171019035641.GB23773@intel.com>
 <CABXGCsPL0pUHo_M-KxB3mabfdGMSHPC0uchLBBt0JCzF2BYBww@mail.gmail.com>
 <20171020064305.GA13688@intel.com>
 <20171020091239.cfwapdkx5g7afyp7@dhcp22.suse.cz>
 <CABXGCsMZ0hFFJyPU2cu+JDLHZ+5eO5i=8FOv71biwpY5neyofA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CABXGCsMZ0hFFJyPU2cu+JDLHZ+5eO5i=8FOv71biwpY5neyofA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?utf-8?B?0JzQuNGF0LDQuNC7INCT0LDQstGA0LjQu9C+0LI=?= <mikhail.v.gavrilov@gmail.com>
Cc: "Du, Changbin" <changbin.du@intel.com>, linux-mm@kvack.org

On Wed 25-10-17 00:30:18, D?D,N?D?D,D>> D?D?D2N?D,D>>D 3/4 D2 wrote:
> On 20 October 2017 at 14:12, Michal Hocko <mhocko@kernel.org> wrote:
> > On Fri 20-10-17 14:43:06, Du, Changbin wrote:
> >> On Thu, Oct 19, 2017 at 11:52:49PM +0500, D?D,N?D?D,D>> D?D?D2N?D,D>>D 3/4 D2 wrote:
> >> > On 19 October 2017 at 08:56, Du, Changbin <changbin.du@intel.com> wrote:
> >> > > On Thu, Oct 19, 2017 at 01:16:48AM +0500, D?D,N?D?D,D>> D?D?D2N?D,D>>D 3/4 D2 wrote:
> >> > > I am curious about this, how can slub try to alloc compound page but the order
> >> > > is 0? This is wrong.
> >> >
> >> > Nobody seems to know how this could happen. Can any logs shed light on this?
> >> >
> >> After checking the code, kernel can handle such case. So please ignore my last
> >> comment.
> >>
> >> The warning is reporting OOM, first you need confirm if you have enough free
> >> memory? If that is true, then it is not a programmer error.
> >
> > The kernel is not OOM. It just failed to allocate for GFP_NOWAIT which
> > means that no memory reclaim could be used to free up potentially unused
> > page cache. This means that kswapd is not able to free up memory in the
> > pace it is allocated. Such an allocation failure shouldn't be critical
> > and the caller should have means to fall back to a regular allocation or
> > retry later. You can play with min_free_kbytes and increase it to kick
> > the background reclaim sooner.
> 
> Michal, thanks for clarification.
> It means if any application allocate for GFP_NOWAIT and we not having
> enough free memory (RAM) we will got this warning.
> For example:
> $ free -ht
>               total        used        free      shared  buff/cache   available
> Mem:            30G         27G        277M        1,6G        2,8G        593M
> Swap:           59G         21G         38G
> Total:          89G         48G         38G
> I see that computer have total free 38G, but only 277M available free RAM.
> So if we try allocate now more than 277M we get this warning again, right?

Well, not really. As soon as we hit a so called low watermark the
background reclaim (kswapd) kicks in and that will try to free up some
of the reclaimable memory. Allocations are still allowed to go on. It is
only when we hit min watermark when the allocation has to perform the
memory reclaim in the allocation context (so called direct reclaim).
GFP_NOWAIT request cannot sleep and as such they cannot perform the
direct reclaim and have to fail. So this thing usually happens when the
allocation pace is larger than the background reclaim can free up in the
background.
 
> I try reproduce it with kernel 4.13.8, but get another warning:
> 
> [ 3551.169126] chrome: page allocation stalls for 11542ms, order:0,
> mode:0x14280ca(GFP_HIGHUSER_MOVABLE|__GFP_ZERO), nodemask=(null)

this is a sleeping allocation which means that it is allowed to perform
the direct reclaim and that took a lot of time here. This is really
unusual and worth debugging some more.

[...]
> [ 3551.169590] Mem-Info:
> [ 3551.169595] active_anon:6904352 inactive_anon:520427 isolated_anon:0
>                 active_file:55480 inactive_file:38890 isolated_file:0
>                 unevictable:1836 dirty:556 writeback:0 unstable:0
>                 slab_reclaimable:67559 slab_unreclaimable:95967
>                 mapped:353547 shmem:480723 pagetables:89161 bounce:0
>                 free:49404 free_pcp:1474 free_cma:0

This tells us that there is quite some page cache (file LRUs) to reclaim
so I am wondering what could have caused such a delay. In order to debug
this some more we would need an additional debugging information. I
usually enable vmscan tracepoints to watch for events during the
reclaim.

[...]
> it's same problem?

so no, this looks like a separate issue.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
