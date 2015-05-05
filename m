Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f42.google.com (mail-wg0-f42.google.com [74.125.82.42])
	by kanga.kvack.org (Postfix) with ESMTP id 6ABEC6B0038
	for <linux-mm@kvack.org>; Tue,  5 May 2015 06:45:21 -0400 (EDT)
Received: by wgso17 with SMTP id o17so178253118wgs.1
        for <linux-mm@kvack.org>; Tue, 05 May 2015 03:45:21 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w13si27351036wjq.111.2015.05.05.03.45.19
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 05 May 2015 03:45:19 -0700 (PDT)
Date: Tue, 5 May 2015 11:45:14 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 0/13] Parallel struct page initialisation v4
Message-ID: <20150505104514.GC2462@suse.de>
References: <1430231830-7702-1-git-send-email-mgorman@suse.de>
 <554030D1.8080509@hp.com>
 <5543F802.9090504@hp.com>
 <554415B1.2050702@hp.com>
 <20150504143046.9404c572486caf71bdef0676@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20150504143046.9404c572486caf71bdef0676@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Waiman Long <waiman.long@hp.com>, Nathan Zimmer <nzimmer@sgi.com>, Dave Hansen <dave.hansen@intel.com>, Scott Norton <scott.norton@hp.com>, Daniel J Blueman <daniel@numascale.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Mon, May 04, 2015 at 02:30:46PM -0700, Andrew Morton wrote:
> > Before the patch, the boot time from elilo prompt to ssh login was 694s. 
> > After the patch, the boot up time was 346s, a saving of 348s (about 50%).
> 
> Having to guesstimate the amount of memory which is needed for a
> successful boot will be painful.  Any number we choose will be wrong
> 99% of the time.
> 
> If the kswapd threads have started, all we need to do is to wait: take
> a little nap in the allocator's page==NULL slowpath.
> 
> I'm not seeing any reason why we can't start kswapd much earlier -
> right at the start of do_basic_setup()?

It doesn't even have to be kswapd, it just should be a thread pinned to
a done. The difficulty is that dealing with the system hashes means the
initialisation has to happen before vfs_caches_init_early() when there is
no scheduler. Those allocations could be delayed further but then there is
the possibility that the allocations would not be contiguous and they'd
have to rely on CMA to make the attempt. That potentially alters the
performance of the large system hashes at run time.

We can scale the amount initialised with memory sizes relatively easy.
This boots on the same 1TB machine I was testing before but that is
hardly a surprise.

---8<---
mm: meminit: Take into account that large system caches scale linearly with memory

Waiman Long reported a 24TB machine triggered an OOM as parallel memory
initialisation deferred too much memory for initialisation. The likely
consumer of this memory was large system hashes that scale with memory
size. This patch initialises at least 2G per node but scales the amount
initialised for larger systems.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 mm/page_alloc.c | 15 +++++++++++++--
 1 file changed, 13 insertions(+), 2 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 598f78d6544c..f7cc6c9fb909 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -266,15 +266,16 @@ static inline bool early_page_nid_uninitialised(unsigned long pfn, int nid)
  */
 static inline bool update_defer_init(pg_data_t *pgdat,
 				unsigned long pfn, unsigned long zone_end,
+				unsigned long max_initialise,
 				unsigned long *nr_initialised)
 {
 	/* Always populate low zones for address-contrained allocations */
 	if (zone_end < pgdat_end_pfn(pgdat))
 		return true;
 
-	/* Initialise at least 2G of the highest zone */
+	/* Initialise at least the requested amount in the highest zone */
 	(*nr_initialised)++;
-	if (*nr_initialised > (2UL << (30 - PAGE_SHIFT)) &&
+	if ((*nr_initialised > max_initialise) &&
 	    (pfn & (PAGES_PER_SECTION - 1)) == 0) {
 		pgdat->first_deferred_pfn = pfn;
 		return false;
@@ -299,6 +300,7 @@ static inline bool early_page_nid_uninitialised(unsigned long pfn, int nid)
 
 static inline bool update_defer_init(pg_data_t *pgdat,
 				unsigned long pfn, unsigned long zone_end,
+				unsigned long max_initialise,
 				unsigned long *nr_initialised)
 {
 	return true;
@@ -4457,11 +4459,19 @@ void __meminit memmap_init_zone(unsigned long size, int nid, unsigned long zone,
 	unsigned long end_pfn = start_pfn + size;
 	unsigned long pfn;
 	struct zone *z;
+	unsigned long max_initialise;
 	unsigned long nr_initialised = 0;
 
 	if (highest_memmap_pfn < end_pfn - 1)
 		highest_memmap_pfn = end_pfn - 1;
 
+	/*
+	 * Initialise at least 2G of a node but also take into account that
+	 * two large system hashes that can take up an 8th of memory.
+	 */
+	max_initialise = min(2UL << (30 - PAGE_SHIFT),
+			(pgdat->node_spanned_pages >> 3));
+
 	z = &pgdat->node_zones[zone];
 	for (pfn = start_pfn; pfn < end_pfn; pfn++) {
 		/*
@@ -4475,6 +4485,7 @@ void __meminit memmap_init_zone(unsigned long size, int nid, unsigned long zone,
 			if (!early_pfn_in_nid(pfn, nid))
 				continue;
 			if (!update_defer_init(pgdat, pfn, end_pfn,
+						max_initialise,
 						&nr_initialised))
 				break;
 		}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
