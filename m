Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com [209.85.212.172])
	by kanga.kvack.org (Postfix) with ESMTP id B3F906B0031
	for <linux-mm@kvack.org>; Wed,  9 Apr 2014 13:56:48 -0400 (EDT)
Received: by mail-wi0-f172.google.com with SMTP id hi2so9353982wib.17
        for <linux-mm@kvack.org>; Wed, 09 Apr 2014 10:56:46 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id f10si1522504wix.43.2014.04.09.10.56.44
        for <linux-mm@kvack.org>;
        Wed, 09 Apr 2014 10:56:45 -0700 (PDT)
Date: Wed, 9 Apr 2014 13:56:14 -0400
From: Luiz Capitulino <lcapitulino@redhat.com>
Subject: Re: [PATCH 5/5] hugetlb: add support for gigantic page allocation
 at runtime
Message-ID: <20140409135614.0fb55016@redhat.com>
In-Reply-To: <53449759.6040207@jp.fujitsu.com>
References: <1396983740-26047-1-git-send-email-lcapitulino@redhat.com>
	<1396983740-26047-6-git-send-email-lcapitulino@redhat.com>
	<53449759.6040207@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, mtosatti@redhat.com, aarcange@redhat.com, mgorman@suse.de, akpm@linux-foundation.org, andi@firstfloor.org, davidlohr@hp.com, rientjes@google.com, yinghai@kernel.org, riel@redhat.com, n-horiguchi@ah.jp.nec.com

On Wed, 9 Apr 2014 09:42:01 +0900
Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com> wrote:

> (2014/04/09 4:02), Luiz Capitulino wrote:
> > HugeTLB is limited to allocating hugepages whose size are less than
> > MAX_ORDER order. This is so because HugeTLB allocates hugepages via
> > the buddy allocator. Gigantic pages (that is, pages whose size is
> > greater than MAX_ORDER order) have to be allocated at boottime.
> > 
> > However, boottime allocation has at least two serious problems. First,
> > it doesn't support NUMA and second, gigantic pages allocated at
> > boottime can't be freed.
> > 
> > This commit solves both issues by adding support for allocating gigantic
> > pages during runtime. It works just like regular sized hugepages,
> > meaning that the interface in sysfs is the same, it supports NUMA,
> > and gigantic pages can be freed.
> > 
> > For example, on x86_64 gigantic pages are 1GB big. To allocate two 1G
> > gigantic pages on node 1, one can do:
> > 
> >   # echo 2 > \
> >     /sys/devices/system/node/node1/hugepages/hugepages-1048576kB/nr_hugepages
> > 
> > And to free them all:
> > 
> >   # echo 0 > \
> >     /sys/devices/system/node/node1/hugepages/hugepages-1048576kB/nr_hugepages
> > 
> > The one problem with gigantic page allocation at runtime is that it
> > can't be serviced by the buddy allocator. To overcome that problem, this
> > commit scans all zones from a node looking for a large enough contiguous
> > region. When one is found, it's allocated by using CMA, that is, we call
> > alloc_contig_range() to do the actual allocation. For example, on x86_64
> > we scan all zones looking for a 1GB contiguous region. When one is found,
> > it's allocated by alloc_contig_range().
> > 
> > One expected issue with that approach is that such gigantic contiguous
> > regions tend to vanish as runtime goes by. The best way to avoid this for
> > now is to make gigantic page allocations very early during system boot, say
> > from a init script. Other possible optimization include using compaction,
> > which is supported by CMA but is not explicitly used by this commit.
> > 
> > It's also important to note the following:
> > 
> >   1. Gigantic pages allocated at boottime by the hugepages= command-line
> >      option can be freed at runtime just fine
> > 
> >   2. This commit adds support for gigantic pages only to x86_64. The
> >      reason is that I don't have access to nor experience with other archs.
> >      The code is arch indepedent though, so it should be simple to add
> >      support to different archs
> > 
> >   3. I didn't add support for hugepage overcommit, that is allocating
> >      a gigantic page on demand when
> >     /proc/sys/vm/nr_overcommit_hugepages > 0. The reason is that I don't
> >     think it's reasonable to do the hard and long work required for
> >     allocating a gigantic page at fault time. But it should be simple
> >     to add this if wanted
> > 
> > Signed-off-by: Luiz Capitulino <lcapitulino@redhat.com>
> > ---
> >   mm/hugetlb.c | 158 ++++++++++++++++++++++++++++++++++++++++++++++++++++++-----
> >   1 file changed, 147 insertions(+), 11 deletions(-)
> > 
> > diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> > index 9dded98..2258045 100644
> > --- a/mm/hugetlb.c
> > +++ b/mm/hugetlb.c
> > @@ -679,11 +679,141 @@ static int hstate_next_node_to_free(struct hstate *h, nodemask_t *nodes_allowed)
> >   		((node = hstate_next_node_to_free(hs, mask)) || 1);	\
> >   		nr_nodes--)
> >   
> > +#if defined(CONFIG_CMA) && defined(CONFIG_X86_64)
> > +static void destroy_compound_gigantic_page(struct page *page,
> > +					unsigned long order)
> > +{
> > +	int i;
> > +	int nr_pages = 1 << order;
> > +	struct page *p = page + 1;
> > +
> > +	for (i = 1; i < nr_pages; i++, p = mem_map_next(p, page, i)) {
> > +		__ClearPageTail(p);
> > +		set_page_refcounted(p);
> > +		p->first_page = NULL;
> > +	}
> > +
> > +	set_compound_order(page, 0);
> > +	__ClearPageHead(page);
> > +}
> > +
> > +static void free_gigantic_page(struct page *page, unsigned order)
> > +{
> > +	free_contig_range(page_to_pfn(page), 1 << order);
> > +}
> > +
> > +static int __alloc_gigantic_page(unsigned long start_pfn, unsigned long count)
> > +{
> > +	unsigned long end_pfn = start_pfn + count;
> > +	return alloc_contig_range(start_pfn, end_pfn, MIGRATE_MOVABLE);
> > +}
> > +
> > +static bool pfn_range_valid_gigantic(unsigned long start_pfn,
> > +				unsigned long nr_pages)
> > +{
> > +	unsigned long i, end_pfn = start_pfn + nr_pages;
> > +	struct page *page;
> > +
> > +	for (i = start_pfn; i < end_pfn; i++) {
> > +		if (!pfn_valid(i))
> > +			return false;
> > +
> > +		page = pfn_to_page(i);
> > +
> > +		if (PageReserved(page))
> > +			return false;
> > +
> > +		if (page_count(page) > 0)
> > +			return false;
> > +
> > +		if (PageHuge(page))
> > +			return false;
> > +	}
> > +
> > +	return true;
> > +}
> > +
> > +static struct page *alloc_gigantic_page(int nid, unsigned order)
> > +{
> > +	unsigned long nr_pages = 1 << order;
> > +	unsigned long ret, pfn, flags;
> > +	struct zone *z;
> > +
> > +	z = NODE_DATA(nid)->node_zones;
> > +	for (; z - NODE_DATA(nid)->node_zones < MAX_NR_ZONES; z++) {
> > +		spin_lock_irqsave(&z->lock, flags);
> > +
> > +		pfn = ALIGN(z->zone_start_pfn, nr_pages);
> > +		for (; pfn < zone_end_pfn(z); pfn += nr_pages) {
> 
> > +			if (pfn_range_valid_gigantic(pfn, nr_pages)) {
> 
> How about it. It can reduce the indentation level.
> 			if (!pfn_range_valid_gigantic(...))
> 				continue;
> 
> And I think following check is necessary:
> 			if (pfn + nr_pages >= zone_end_pfn(z))
> 				break;

You're right that we have to check if the whole range is within the zone,
but the check above is off-by-one. What about the following:

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 01c0068..b01cdeb 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -734,6 +734,13 @@ static bool pfn_range_valid_gigantic(unsigned long start_pfn,
 	return true;
 }
 
+static bool zone_spans_last_pfn(const struct zone *zone,
+			unsigned long start_pfn, unsigned long nr_pages)
+{
+	unsigned long last_pfn = start_pfn + nr_pages - 1;
+	return zone_spans_pfn(zone, last_pfn);
+}
+
 static struct page *alloc_gigantic_page(int nid, unsigned order)
 {
 	unsigned long nr_pages = 1 << order;
@@ -745,7 +752,7 @@ static struct page *alloc_gigantic_page(int nid, unsigned order)
 		spin_lock_irqsave(&z->lock, flags);
 
 		pfn = ALIGN(z->zone_start_pfn, nr_pages);
-		for (; pfn < zone_end_pfn(z); pfn += nr_pages) {
+		while (zone_spans_last_pfn(z, pfn, nr_pages)) {
 			if (pfn_range_valid_gigantic(pfn, nr_pages)) {
 				/*
 				 * We release the zone lock here because
@@ -760,6 +767,7 @@ static struct page *alloc_gigantic_page(int nid, unsigned order)
 					return pfn_to_page(pfn);
 				spin_lock_irqsave(&z->lock, flags);
 			}
+			pfn += nr_pages;
 		}
 
 		spin_unlock_irqrestore(&z->lock, flags);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
