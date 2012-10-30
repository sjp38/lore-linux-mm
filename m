Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx147.postini.com [74.125.245.147])
	by kanga.kvack.org (Postfix) with SMTP id 8A3316B0069
	for <linux-mm@kvack.org>; Tue, 30 Oct 2012 09:56:48 -0400 (EDT)
Date: Tue, 30 Oct 2012 13:56:40 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: spinning in isolate_migratepages_range on busy nfs server
Message-ID: <20121030135640.GD3888@suse.de>
References: <20121025164722.GE6846@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20121025164722.GE6846@fieldses.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, bmarson@redhat.com

On Thu, Oct 25, 2012 at 12:47:22PM -0400, J. Bruce Fields wrote:
> We're seeing an nfs server on a 3.6-ish kernel lock up after running
> specfs for a while.
> 
> Looking at the logs, there are some hung task warnings showing nfsd
> threads stuck on directory i_mutexes trying to do lookups.
> 
> A sysrq-t dump showed there were also lots of threads holding those
> i_mutexes while trying to allocate xfs inodes:
> 
>  	nfsd            R running task        0  6517      2 0x00000080
>  	 ffff880f925074c0 0000000000000046 ffff880fe4718000 ffff880f92507fd8
>  	 ffff880f92507fd8 ffff880f92507fd8 ffff880fd7920000 ffff880fe4718000
>  	 0000000000000000 ffff880f92506000 ffff88102ffd96c0 ffff88102ffd9b40
>  	Call Trace:
>  	[<ffffffff81091aaa>] __cond_resched+0x2a/0x40
>  	[<ffffffff815d3750>] _cond_resched+0x30/0x40
>  	[<ffffffff81150e92>] isolate_migratepages_range+0xb2/0x550
> <SNIP>
>
> And perf --call-graph also shows we're spending all our time in the same
> place, spinning on a lock (zone->lru_lock, I assume):
> 
>  -  92.65%           nfsd  [kernel.kallsyms]  [k] _raw_spin_lock_irqsave
>     - _raw_spin_lock_irqsave
>        - 99.86% isolate_migratepages_range
> 
> Just grepping through logs, I ran across 2a1402aa04 "mm: compaction:
> acquire the zone->lru_lock as late as possible", in v3.7-rc1, which
> looks relevant:
> 
> 	Richard Davies and Shaohua Li have both reported lock contention
> 	problems in compaction on the zone and LRU locks as well as
> 	significant amounts of time being spent in compaction.  This
> 	series aims to reduce lock contention and scanning rates to
> 	reduce that CPU usage.  Richard reported at
> 	https://lkml.org/lkml/2012/9/21/91 that this series made a big
> 	different to a problem he reported in August:
> 			        
> 		http://marc.info/?l=kvm&m=134511507015614&w=2
> 
> So we're trying that.  Is there anything else we should try?
> 

Sorry for the long delay in getting back, I was travelling. All the
related commits would ideally be tested. They are

e64c5237cf6ff474cb2f3f832f48f2b441dd9979 mm: compaction: abort compaction loop if lock is contended or run too long
3cc668f4e30fbd97b3c0574d8cac7a83903c9bc7 mm: compaction: move fatal signal check out of compact_checklock_irqsave
661c4cb9b829110cb68c18ea05a56be39f75a4d2 mm: compaction: Update try_to_compact_pages()kerneldoc comment
2a1402aa044b55c2d30ab0ed9405693ef06fb07c mm: compaction: acquire the zone->lru_lock as late as possible
f40d1e42bb988d2a26e8e111ea4c4c7bac819b7e mm: compaction: acquire the zone->lock as late as possible
753341a4b85ff337487b9959c71c529f522004f4 revert "mm: have order > 0 compaction start off where it left"
bb13ffeb9f6bfeb301443994dfbf29f91117dfb3 mm: compaction: cache if a pageblock was scanned and no pages were isolated
c89511ab2f8fe2b47585e60da8af7fd213ec877e mm: compaction: Restart compaction from near where it left off
62997027ca5b3d4618198ed8b1aba40b61b1137b mm: compaction: clear PG_migrate_skip based on compaction and reclaim activity
0db63d7e25f96e2c6da925c002badf6f144ddf30 mm: compaction: correct the nr_strict va isolated check for CMA

Thanks very much.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
