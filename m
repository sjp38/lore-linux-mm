Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id E73AE6B0341
	for <linux-mm@kvack.org>; Fri, 23 Dec 2016 09:47:44 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id w13so41532219wmw.0
        for <linux-mm@kvack.org>; Fri, 23 Dec 2016 06:47:44 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id s3si35922425wjr.258.2016.12.23.06.47.43
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 23 Dec 2016 06:47:43 -0800 (PST)
Date: Fri, 23 Dec 2016 15:47:39 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: [RFC PATCH] mm, memcg: fix (Re: OOM: Better, but still there on)
Message-ID: <20161223144738.GB23117@dhcp22.suse.cz>
References: <20161217210646.GA11358@boerne.fritz.box>
 <20161219134534.GC5164@dhcp22.suse.cz>
 <20161220020829.GA5449@boerne.fritz.box>
 <20161221073658.GC16502@dhcp22.suse.cz>
 <20161222101028.GA11105@ppc-nas.fritz.box>
 <20161222191719.GA19898@dhcp22.suse.cz>
 <20161222214611.GA3015@boerne.fritz.box>
 <20161223105157.GB23109@dhcp22.suse.cz>
 <20161223121851.GA27413@ppc-nas.fritz.box>
 <20161223125728.GE23109@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161223125728.GE23109@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nils Holland <nholland@tisys.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Chris Mason <clm@fb.com>, David Sterba <dsterba@suse.cz>, linux-btrfs@vger.kernel.org

[Add Mel, Johannes and Vladimir - the email thread started here
http://lkml.kernel.org/r/20161215225702.GA27944@boerne.fritz.box
The long story short, the zone->node reclaim change has broken active
list aging for lowmem requests when memory cgroups are enabled. More
details below.

On Fri 23-12-16 13:57:28, Michal Hocko wrote:
> On Fri 23-12-16 13:18:51, Nils Holland wrote:
> > On Fri, Dec 23, 2016 at 11:51:57AM +0100, Michal Hocko wrote:
> > > TL;DR
> > > drop the last patch, check whether memory cgroup is enabled and retest
> > > with cgroup_disable=memory to see whether this is memcg related and if
> > > it is _not_ then try to test with the patch below
> > 
> > Right, it seems we might be looking in the right direction! So I
> > removed the previous patch from my kernel and verified if memory
> > cgroup was enabled, and indeed, it was. So I booted with
> > cgroup_disable=memory and ran my ordinary test again ... and in fact,
> > no ooms!
> 
> OK, thanks for confirmation. I could have figured that earlier. The
> pagecache differences in such a short time should have raised the red
> flag and point towards memcgs...
> 
> [...]
> > > I would appreciate to stick with your setup to not pull new unknows into
> > > the picture.
> > 
> > No problem! It's just likely that I won't be able to test during the
> > following days until Dec 27th, but after that I should be back to
> > normal and thus be able to run further tests in a timely fashion. :-)
> 
> no problem at all. I will try to cook up a patch in the mean time.

So here is my attempt. Only compile tested so be careful, it might eat
your kittens or do more harm. I would appreciate other guys to have a
look to see whether this is sane. There are probably other places which
would need some tweaks. I think that get_scan_count needs some tweaks
as well because we should only consider eligible zones when counting the
number of pages to scan. This would be for a separate patch which I will
send later. I just want to fix this one first.

Nils, even though this is still highly experimental, could you give it a
try please?
---
