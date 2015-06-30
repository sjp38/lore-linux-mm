Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com [209.85.212.178])
	by kanga.kvack.org (Postfix) with ESMTP id 47DBD6B0032
	for <linux-mm@kvack.org>; Tue, 30 Jun 2015 07:54:04 -0400 (EDT)
Received: by wiwl6 with SMTP id l6so129384109wiw.0
        for <linux-mm@kvack.org>; Tue, 30 Jun 2015 04:54:03 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ce9si18991821wib.4.2015.06.30.04.54.01
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 30 Jun 2015 04:54:02 -0700 (PDT)
Date: Tue, 30 Jun 2015 12:53:53 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [RFC v2 PATCH 0/8] mm: mirrored memory support for page buddy
 allocations
Message-ID: <20150630115353.GB6812@suse.de>
References: <558E084A.60900@huawei.com>
 <20150630094149.GA6812@suse.de>
 <20150630104654.GA24932@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20150630104654.GA24932@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: Xishi Qiu <qiuxishi@huawei.com>, Andrew Morton <akpm@linux-foundation.org>, "H. Peter Anvin" <hpa@zytor.com>, "Luck, Tony" <tony.luck@intel.com>, Hanjun Guo <guohanjun@huawei.com>, Xiexiuqi <xiexiuqi@huawei.com>, leon@leon.nu, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Dave Hansen <dave.hansen@intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Vlastimil Babka <vbabka@suse.cz>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Tue, Jun 30, 2015 at 12:46:54PM +0200, Ingo Molnar wrote:
> 
> * Mel Gorman <mgorman@suse.de> wrote:
> 
> > [...]
> > 
> > Basically, overall I feel this series is the wrong approach but not knowing who 
> > the users are making is much harder to judge. I strongly suspect that if 
> > mirrored memory is to be properly used then it needs to be available before the 
> > page allocator is even active. Once active, there needs to be controlled access 
> > for allocation requests that are really critical to mirror and not just all 
> > kernel allocations. None of that would use a MIGRATE_TYPE approach. It would be 
> > alterations to the bootmem allocator and access to an explicit reserve that is 
> > not accounted for as "free memory" and accessed via an explicit GFP flag.
> 
> So I think the main goal is to avoid kernel crashes when a #MC memory fault 
> arrives on a piece of memory that is owned by the kernel.
> 

Sounds logical. In that case, bootmem awareness would be crucial.
Enabling support in just the page allocator is too late.

> In that sense 'protecting' all kernel allocations is natural: we don't know how to 
> recover from faults that affect kernel memory.
> 

It potentially uses all mirrored memory on memory that does not need that
sort of guarantee. For example, if there was a MC on memory backing the
inode cache then potentially that is recoverable as long as the inodes
were not dirty. That's a minor detail as the kernel could later protect
only MIGRATE_UNMOVABLE requests instead of all kernel allocations if fatal
MC in kernel space could be distinguished from non-fatal checks.

Bootmem awareness is much more important either way. If that was addressed
then potentially a MIGRATE_UNMOVABLE_MIRROR type could be created that
is only used for MIGRATE_UNMOVABLE allocations and never for user-space.
That misses MIGRATE_RECLAIMABLE so if that is required then we need
something else that both preserves fragmentation avoidance and avoid
introducing loads of new migratetypes.

Reclaim-related issues could be partially avoided by forbidding use from
userspace and accounting for the size of MIGRATE_UNMOVABLE_MIRROR during
watermark checks.

> We do know how to recover from faults that affect user-space memory alone.
> 
> So if a mechanism is in place that prioritizes 3 groups of allocators:
> 
>   - non-recoverable memory (kernel allocations mostly)
> 

So bootmem at the very least followed by MIGRATE_UNMOVABLE requests whether
they are accounted for by zones of MIGRATE_TYPES.

>   - high priority user memory (critical apps that must never fail)
> 

This one is problematic with a MIGRATE_TYPE-based approach such as the one in
this series. If a high priority requires memory and MIGRATE_MIRROR is full
then some of it must be reclaimed. With a MIGRATE_TYPE approach, the kernel
may reclaim a lot of unnecessary memory trying to free some MIGRATE_MIRROR
memory with no guarantee of success. It'll look like unnecessary thrashing
from userspace but difficult to diagnose as reclaim stats are per-zone based.
Dealing with this needs either a zone-based approach or a lot of surgery
to reclaim (similar to what the node-based LRU series does actually when
it skips pages when the caller requires lowmem pages).

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
