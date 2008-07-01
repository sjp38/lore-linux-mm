Date: Tue, 1 Jul 2008 09:09:11 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [problem] raid performance loss with 2.6.26-rc8 on 32-bit x86 (bisected)
Message-ID: <20080701080910.GA10865@csn.ul.ie>
References: <1214877439.7885.40.camel@dwillia2-linux.ch.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1214877439.7885.40.camel@dwillia2-linux.ch.intel.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, NeilBrown <neilb@suse.de>, babydr@baby-dragons.com, cl@linux-foundation.org, lee.schermerhorn@hp.com, apw@shadowen.org
List-ID: <linux-mm.kvack.org>

(Christoph's address corrected and Andys added to cc)

On (30/06/08 18:57), Dan Williams didst pronounce:
> Hello,
> 
> Prompted by a report from a user I have bisected a performance loss
> apparently introduced by commit 54a6eb5c (mm: use two zonelist that are
> filtered by GFP mask).  The test is simple sequential writes to a 4 disk
> raid5 array.  Performance should be about 20% greater than 2.6.25 due to
> commit 8b3e6cdc (md: introduce get_priority_stripe() to improve raid456
> write performance).  The sample data below shows sporadic performance
> starting at 54a6eb5c.  The '+' indicates where I hand applied 8b3e6cdc.
> 
> revision   2.6.25.8-fc8 2.6.25.9+ dac1d27b+ 18ea7e71+ 54a6eb5c+ 2.6.26-rc1 2.6.26-rc8
>            138          168       169       167       177       149        144
>            140          168       172       170       109       138        142
>            142          165       169       164       119       138        129
>            144          168       169       171       120       139        135
>            142          165       174       166       165       122        154
> MB/s (avg) 141          167       171       168       138       137        141
> % change   0%           18%       21%       19%       -2%       -3%        0%
> result     base         good      good      good      [bad]     bad        bad
> 

That is not good at all as this patch is not a straight-forward revert but
the second time it's come under suspicion.

> Notable observations:
> 1/ This problem does not reproduce when ARCH=x86_64, i.e. 2.6.26-rc8 and
> 54a6eb5c show consistent performance at 170MB/s.

I'm very curious as to why this doesn't affect x86_64. HIGHMEM is one
possibility if GFP_KERNEL is a major factor and it has to scan over the
unusable zone a lot. However, another remote possibility is that many function
calls are more expensive on x86 than on x86_64 (this is a wild guess based
on the registers available). Spectulative patch is below.

If 8b3e6cdc is reverted from 2.6.26-rc8, what do the figures look like?
i.e. is the zonelist filtering looking like a performance regression or is
it just somehow negating the benefits of the raid patch?

> 2/ Single drive performance appears to be unaffected
> 3/ A quick test shows that raid0 performance is also sporadic:
>    2147483648 bytes (2.1 GB) copied, 7.72408 s, 278 MB/s
>    2147483648 bytes (2.1 GB) copied, 7.78478 s, 276 MB/s
>    2147483648 bytes (2.1 GB) copied, 11.0323 s, 195 MB/s
>    2147483648 bytes (2.1 GB) copied, 8.41244 s, 255 MB/s
>    2147483648 bytes (2.1 GB) copied, 30.7649 s, 69.8 MB/s
> 

Are these synced writes? i.e. is it possible the performance at the end
is dropped because memory becomes full of dirty pages at that point?

> System/Test configuration:
> (2) Intel(R) Xeon(R) CPU 5150
> mem=1024M
> CONFIG_HIGHMEM4G=y (full config attached)
> mdadm --create /dev/md0 /dev/sd[b-e] -n 4 -l 5 --assume-clean
> for i in `seq 1 5`; do dd if=/dev/zero of=/dev/md0 bs=1024k count=2048; done
> 
> Neil suggested CONFIG_NOHIGHMEM=y, I will give that a shot tomorrow.
> Other suggestions / experiments?
> 

There was a deporkify patch which replaced inline function with normal
functions. I worried at the time that all the function calls in an
iterator may cause a performnace problem but I couldn't measure it so
assumed the reduction in text size was a plus. This is a partial
reporkify patch that should reduce the number of function calls that
take place at the cost of larger text. Can you try it out applied
against 2.6.26-rc8 please?

diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.26-rc8-clean/include/linux/mmzone.h linux-2.6.26-rc8-repork/include/linux/mmzone.h
--- linux-2.6.26-rc8-clean/include/linux/mmzone.h	2008-06-24 18:58:20.000000000 -0700
+++ linux-2.6.26-rc8-repork/include/linux/mmzone.h	2008-07-01 00:49:17.000000000 -0700
@@ -742,6 +742,15 @@ static inline int zonelist_node_idx(stru
 #endif /* CONFIG_NUMA */
 }
 
+static inline int zref_in_nodemask(struct zoneref *zref, nodemask_t *nodes)
+{
+#ifdef CONFIG_NUMA
+	return node_isset(zonelist_node_idx(zref), *nodes);
+#else
+	return 1;
+#endif /* CONFIG_NUMA */
+}
+
 /**
  * next_zones_zonelist - Returns the next zone at or below highest_zoneidx within the allowed nodemask using a cursor within a zonelist as a starting point
  * @z - The cursor used as a starting point for the search
@@ -754,10 +763,26 @@ static inline int zonelist_node_idx(stru
  * search. The zoneref returned is a cursor that is used as the next starting
  * point for future calls to next_zones_zonelist().
  */
-struct zoneref *next_zones_zonelist(struct zoneref *z,
+static inline struct zoneref *next_zones_zonelist(struct zoneref *z,
 					enum zone_type highest_zoneidx,
 					nodemask_t *nodes,
-					struct zone **zone);
+					struct zone **zone)
+{
+	/*
+	 * Find the next suitable zone to use for the allocation.
+	 * Only filter based on nodemask if it's set
+	 */
+	if (likely(nodes == NULL))
+		while (zonelist_zone_idx(z) > highest_zoneidx)
+			z++;
+	else
+		while (zonelist_zone_idx(z) > highest_zoneidx ||
+				(z->zone && !zref_in_nodemask(z, nodes)))
+			z++;
+
+	*zone = zonelist_zone(z++);
+	return z;
+}
 
 /**
  * first_zones_zonelist - Returns the first zone at or below highest_zoneidx within the allowed nodemask in a zonelist
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.26-rc8-clean/mm/mmzone.c linux-2.6.26-rc8-repork/mm/mmzone.c
--- linux-2.6.26-rc8-clean/mm/mmzone.c	2008-06-24 18:58:20.000000000 -0700
+++ linux-2.6.26-rc8-repork/mm/mmzone.c	2008-07-01 00:48:19.000000000 -0700
@@ -42,33 +42,3 @@ struct zone *next_zone(struct zone *zone
 	return zone;
 }
 
-static inline int zref_in_nodemask(struct zoneref *zref, nodemask_t *nodes)
-{
-#ifdef CONFIG_NUMA
-	return node_isset(zonelist_node_idx(zref), *nodes);
-#else
-	return 1;
-#endif /* CONFIG_NUMA */
-}
-
-/* Returns the next zone at or below highest_zoneidx in a zonelist */
-struct zoneref *next_zones_zonelist(struct zoneref *z,
-					enum zone_type highest_zoneidx,
-					nodemask_t *nodes,
-					struct zone **zone)
-{
-	/*
-	 * Find the next suitable zone to use for the allocation.
-	 * Only filter based on nodemask if it's set
-	 */
-	if (likely(nodes == NULL))
-		while (zonelist_zone_idx(z) > highest_zoneidx)
-			z++;
-	else
-		while (zonelist_zone_idx(z) > highest_zoneidx ||
-				(z->zone && !zref_in_nodemask(z, nodes)))
-			z++;
-
-	*zone = zonelist_zone(z++);
-	return z;
-}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
