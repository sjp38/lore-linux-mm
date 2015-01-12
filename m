Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f181.google.com (mail-pd0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id C1E126B0032
	for <linux-mm@kvack.org>; Mon, 12 Jan 2015 03:01:25 -0500 (EST)
Received: by mail-pd0-f181.google.com with SMTP id v10so29106897pde.12
        for <linux-mm@kvack.org>; Mon, 12 Jan 2015 00:01:25 -0800 (PST)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id va1si22220596pbc.211.2015.01.12.00.01.23
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 12 Jan 2015 00:01:24 -0800 (PST)
Date: Mon, 12 Jan 2015 11:01:14 +0300
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: Re: [PATCH cgroup/for-3.19-fixes] cgroup: implement
 cgroup_subsys->unbind() callback
Message-ID: <20150112080114.GE2110@esperanza>
References: <54B01335.4060901@arm.com>
 <20150110085525.GD2110@esperanza>
 <20150110214316.GF25319@htj.dyndns.org>
 <20150111205543.GA5480@phnom.home.cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20150111205543.GA5480@phnom.home.cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Tejun Heo <tj@kernel.org>, "Suzuki K. Poulose" <Suzuki.Poulose@arm.com>, linux-mm@kvack.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Will Deacon <Will.Deacon@arm.com>

On Sun, Jan 11, 2015 at 03:55:43PM -0500, Johannes Weiner wrote:
> On Sat, Jan 10, 2015 at 04:43:16PM -0500, Tejun Heo wrote:
> > > May be, we should kill the ref counter to the memory controller root in
> > > cgroup_kill_sb only if there is no children at all, neither online nor
> > > offline.
> > 
> > Ah, thanks for the analysis, but I really wanna avoid making hierarchy
> > destruction conditions opaque to userland.  This is userland visible
> > behavior.  It shouldn't be determined by kernel internals invisible
> > outside.  This patch adds ss->unbind() which memcg can hook into to
> > kick off draining of residual refs.  If this would work, I'll add this
> > patch to cgroup/for-3.19-fixes, possibly with stable cc'd.
> 
> How about this ->unbind() for memcg?
> 
> From d527ba1dbfdb58e1f7c7c4ee12b32ef2e5461990 Mon Sep 17 00:00:00 2001
> From: Johannes Weiner <hannes@cmpxchg.org>
> Date: Sun, 11 Jan 2015 10:29:05 -0500
> Subject: [patch] mm: memcontrol: zap outstanding cache/swap references during
>  unbind
> 
> Cgroup core assumes that any outstanding css references after
> offlining are temporary in nature, and e.g. mount waits for them to
> disappear and release the root cgroup.  But leftover page cache and
> swapout records in an offlined memcg are only dropped when the pages
> get reclaimed under pressure or the swapped out pages get faulted in
> from other cgroups, and so those cgroup operations can hang forever.
> 
> Implement the ->unbind() callback to actively get rid of outstanding
> references when cgroup core wants them gone.  Swap out records are
> deleted, such that the swap-in path will charge those pages to the
> faulting task.  Page cache pages are moved to the root memory cgroup.

... and kmem pages are ignored. I reckon we could reparent them (I
submitted the patch set some time ago), but that's going to be tricky
and will complicate regular kmem charge/uncharge paths, as well as
list_lru_add/del. I don't think we can put up with it, provided we only
want reparenting on unmount, do we not?

Come to think of it, I wonder how many users actually want to mount
different controllers subset after unmount. Because we could allow
mounting the same subset perfectly well, even if it includes memcg. BTW,
AFAIU in the unified hierarchy we won't have this problem at all,
because by definition it mounts all controllers IIRC, so do we need to
bother fixing this in such a complicated manner at all for the setup
that's going to be deprecated anyway?

Thanks,
Vladimir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
