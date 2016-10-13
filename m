Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id 451176B0038
	for <linux-mm@kvack.org>; Thu, 13 Oct 2016 02:19:57 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id n3so41663954lfn.5
        for <linux-mm@kvack.org>; Wed, 12 Oct 2016 23:19:57 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id wa6si15587775wjc.12.2016.10.12.23.19.55
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 12 Oct 2016 23:19:55 -0700 (PDT)
Subject: Re: [PATCH] mm, compaction: allow compaction for GFP_NOFS requests
References: <20161012114721.31853-1-mhocko@kernel.org>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <224e7340-411c-f0ea-a9b5-0191517fbf7d@suse.cz>
Date: Thu, 13 Oct 2016 08:19:53 +0200
MIME-Version: 1.0
In-Reply-To: <20161012114721.31853-1-mhocko@kernel.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Joonsoo Kim <js1304@gmail.com>, Dave Chinner <david@fromorbit.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On 10/12/2016 01:47 PM, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
>
> compaction has been disabled for GFP_NOFS and GFP_NOIO requests since
> the direct compaction was introduced by 56de7263fcf3 ("mm: compaction:
> direct compact when a high-order allocation fails"). The main reason
> is that the migration of page cache pages might recurse back to fs/io
> layer and we could potentially deadlock. This is overly conservative
> because all the anonymous memory is migrateable in the GFP_NOFS context
> just fine.  This might be a large portion of the memory in many/most
> workkloads.
>
> Remove the GFP_NOFS restriction and make sure that we skip all fs pages
> (those with a mapping) while isolating pages to be migrated. We cannot
> consider clean fs pages because they might need a metadata update so
> only isolate pages without any mapping for nofs requests.
>
> The effect of this patch will be probably very limited in many/most
> workloads because higher order GFP_NOFS requests are quite rare,
> although different configurations might lead to very different results.
> David Chinner has mentioned a heavy metadata workload with 64kB block
> which to quote him:
> "
> Unfortunately, there was an era of cargo cult configuration tweaks
> in the Ceph community that has resulted in a large number of
> production machines with XFS filesystems configured this way. And a
> lot of them store large numbers of small files and run under
> significant sustained memory pressure.
>
> I slowly working towards getting rid of these high order allocations
> and replacing them with the equivalent number of single page
> allocations, but I haven't got that (complex) change working yet.
> "
>
> We can do the following to simulate that workload:
> $ mkfs.xfs -f -n size=64k <dev>
> $ mount <dev> /mnt/scratch
> $ time ./fs_mark  -D  10000  -S0  -n  100000  -s  0  -L  32 \
>         -d  /mnt/scratch/0  -d  /mnt/scratch/1 \
>         -d  /mnt/scratch/2  -d  /mnt/scratch/3 \
>         -d  /mnt/scratch/4  -d  /mnt/scratch/5 \
>         -d  /mnt/scratch/6  -d  /mnt/scratch/7 \
>         -d  /mnt/scratch/8  -d  /mnt/scratch/9 \
>         -d  /mnt/scratch/10  -d  /mnt/scratch/11 \
>         -d  /mnt/scratch/12  -d  /mnt/scratch/13 \
>         -d  /mnt/scratch/14  -d  /mnt/scratch/15
>
> and indeed is hammers the system with many high order GFP_NOFS requests as
> per a simle tracepoint during the load:
> $ echo '!(gfp_flags & 0x80) && (gfp_flags &0x400000)' > $TRACE_MNT/events/kmem/mm_page_alloc/filter
> I am getting
> 5287609 order=0
>      37 order=1
> 1594905 order=2
> 3048439 order=3
> 6699207 order=4
>   66645 order=5
>
> My testing was done in a kvm guest so performance numbers should be
> taken with a grain of salt but there seems to be a difference when the
> patch is applied:
>
> * Original kernel
> FSUse%        Count         Size    Files/sec     App Overhead
>      1      1600000            0       4300.1         20745838
>      3      3200000            0       4239.9         23849857
>      5      4800000            0       4243.4         25939543
>      6      6400000            0       4248.4         19514050
>      8      8000000            0       4262.1         20796169
>      9      9600000            0       4257.6         21288675
>     11     11200000            0       4259.7         19375120
>     13     12800000            0       4220.7         22734141
>     14     14400000            0       4238.5         31936458
>     16     16000000            0       4231.5         23409901
>     18     17600000            0       4045.3         23577700
>     19     19200000            0       2783.4         58299526
>     21     20800000            0       2678.2         40616302
>     23     22400000            0       2693.5         83973996
>
> and xfs complaining about memory allocation not making progress
> [ 2304.372647] XFS: fs_mark(3289) possible memory allocation deadlock size 65624 in kmem_alloc (mode:0x2408240)
> [ 2304.443323] XFS: fs_mark(3285) possible memory allocation deadlock size 65728 in kmem_alloc (mode:0x2408240)
> [ 4796.772477] XFS: fs_mark(3424) possible memory allocation deadlock size 46936 in kmem_alloc (mode:0x2408240)
> [ 4796.775329] XFS: fs_mark(3423) possible memory allocation deadlock size 51416 in kmem_alloc (mode:0x2408240)
> [ 4797.388808] XFS: fs_mark(3424) possible memory allocation deadlock size 65728 in kmem_alloc (mode:0x2408240)
>
> * Patched kernel
> FSUse%        Count         Size    Files/sec     App Overhead
>      1      1600000            0       4289.1         19243934
>      3      3200000            0       4241.6         32828865
>      5      4800000            0       4248.7         32884693
>      6      6400000            0       4314.4         19608921
>      8      8000000            0       4269.9         24953292
>      9      9600000            0       4270.7         33235572
>     11     11200000            0       4346.4         40817101
>     13     12800000            0       4285.3         29972397
>     14     14400000            0       4297.2         20539765
>     16     16000000            0       4219.6         18596767
>     18     17600000            0       4273.8         49611187
>     19     19200000            0       4300.4         27944451
>     21     20800000            0       4270.6         22324585
>     22     22400000            0       4317.6         22650382
>     24     24000000            0       4065.2         22297964
>
> So the dropdown at Count 19200000 didn't happen and there was only a
> single warning about allocation not making progress
> [ 3063.815003] XFS: fs_mark(3272) possible memory allocation deadlock size 65624 in kmem_alloc (mode:0x2408240)
>
> This suggests that the patch has helped even though there is not all
> that much of anonymous memory as the workload mostly generates fs
> metadata. I assume the success rate would be higher with more anonymous
> memory which should be the case in many workloads.
>
> Changes since RFC
> - testing results from the test case suggested by David
> - fix kcompactd and proc triggered compaction by giving them GFP_KERNEL
>   gfp_mask as per Vlastimil
>
> Signed-off-by: Michal Hocko <mhocko@suse.com>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

Small nitpick below.

> @@ -1696,14 +1703,16 @@ enum compact_result try_to_compact_pages(gfp_t gfp_mask, unsigned int order,
>  		unsigned int alloc_flags, const struct alloc_context *ac,
>  		enum compact_priority prio)
>  {
> -	int may_enter_fs = gfp_mask & __GFP_FS;
>  	int may_perform_io = gfp_mask & __GFP_IO;
>  	struct zoneref *z;
>  	struct zone *zone;
>  	enum compact_result rc = COMPACT_SKIPPED;
>
> -	/* Check if the GFP flags allow compaction */
> -	if (!may_enter_fs || !may_perform_io)
> +	/*
> +	 * Check if the GFP flags allow compaction - GFP_NOIO is really
> +	 * tricky context because the migration might require IO and

"and" ?

> +	 */
> +	if (!may_perform_io)
>  		return COMPACT_SKIPPED;
>
>  	trace_mm_compaction_try_to_compact_pages(order, gfp_mask, prio);
> @@ -1770,6 +1779,7 @@ static void compact_node(int nid)
>  		.mode = MIGRATE_SYNC,
>  		.ignore_skip_hint = true,
>  		.whole_zone = true,
> +		.gfp_mask = GFP_KERNEL,
>  	};
>
>
> @@ -1895,6 +1905,7 @@ static void kcompactd_do_work(pg_data_t *pgdat)
>  		.classzone_idx = pgdat->kcompactd_classzone_idx,
>  		.mode = MIGRATE_SYNC_LIGHT,
>  		.ignore_skip_hint = true,
> +		.gfp_mask = GFP_KERNEL,
>
>  	};
>  	trace_mm_compaction_kcompactd_wake(pgdat->node_id, cc.order,
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
