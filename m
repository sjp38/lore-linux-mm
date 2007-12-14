Message-ID: <4761CE88.9070406@rtr.ca>
Date: Thu, 13 Dec 2007 19:30:00 -0500
From: Mark Lord <liml@rtr.ca>
MIME-Version: 1.0
Subject: Re: QUEUE_FLAG_CLUSTER: not working in 2.6.24 ?
References: <20071213185326.GQ26334@parisc-linux.org>	<4761821F.3050602@rtr.ca>	<20071213192633.GD10104@kernel.dk>	<4761883A.7050908@rtr.ca>	<476188C4.9030802@rtr.ca>	<20071213193937.GG10104@kernel.dk>	<47618B0B.8020203@rtr.ca>	<20071213195350.GH10104@kernel.dk>	<20071213200219.GI10104@kernel.dk>	<476190BE.9010405@rtr.ca>	<20071213200958.GK10104@kernel.dk>	<20071213140207.111f94e2.akpm@linux-foundation.org>	<1197584106.3154.55.camel@localhost.localdomain> <20071213142935.47ff19d9.akpm@linux-foundation.org> <4761B32A.3070201@rtr.ca> <4761BCB4.1060601@rtr.ca> <4761C8E4.2010900@rtr.ca>
In-Reply-To: <4761C8E4.2010900@rtr.ca>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: James Bottomley <James.Bottomley@HansenPartnership.com>, jens.axboe@oracle.com, lkml@rtr.ca, matthew@wil.cx, linux-ide@vger.kernel.org, linux-kernel@vger.kernel.org, linux-scsi@vger.kernel.org, linux-mm@kvack.org, mel@csn.ul.ie
List-ID: <linux-mm.kvack.org>

Mark Lord wrote:
> Mark Lord wrote:
>> Mark Lord wrote:
>>> Andrew Morton wrote:
>>>> On Thu, 13 Dec 2007 17:15:06 -0500
>>>> James Bottomley <James.Bottomley@HansenPartnership.com> wrote:
>>>>
>>>>> On Thu, 2007-12-13 at 14:02 -0800, Andrew Morton wrote:
>>>>>> On Thu, 13 Dec 2007 21:09:59 +0100
>>>>>> Jens Axboe <jens.axboe@oracle.com> wrote:
>>>>>>
>>>>>>> OK, it's a vm issue,
>>>>>> cc linux-mm and probable culprit.
>>>>>>
>>>>>>>  I have tens of thousand "backward" pages after a
>>>>>>> boot - IOW, bvec->bv_page is the page before bvprv->bv_page, not
>>>>>>> reverse. So it looks like that bug got reintroduced.
>>>>>> Bill Irwin fixed this a couple of years back: changed the page 
>>>>>> allocator so
>>>>>> that it mostly hands out pages in ascending physical-address order.
>>>>>>
>>>>>> I guess we broke that, quite possibly in Mel's page allocator rework.
>>>>>>
>>>>>> It would help if you could provide us with a simple recipe for
>>>>>> demonstrating this problem, please.
>>>>> The simple way seems to be to malloc a large area, touch every page 
>>>>> and
>>>>> then look at the physical pages assigned ... they now mostly seem 
>>>>> to be
>>>>> descending in physical address.
>>>>>
>>>>
>>>> OIC.  -mm's /proc/pid/pagemap can be used to get the pfn's...
>>> ..
>>>
>>> I'm actually running the treadmill right now (have been for many 
>>> hours, actually,
>>> to bisect it to a specific commit.
>>>
>>> Thought I was almost done, and then noticed that git-bisect doesn't keep
>>> the Makefile VERSION lines the same, so I was actually running the wrong
>>> kernel after the first few times.. duh.
>>>
>>> Wrote a script to fix it now.
>> ..
>>
>> Well, that was a waste of three hours.
> ..
> 
> Ahh.. it seems to be sensitive to one/both of these:
> 
> CONFIG_HIGHMEM64G=y with 4GB RAM:  not so bad, frequently does 20KB - 
> 48KB segments.
> CONFIG_HIGHMEM4G=y  with 2GB RAM:  very severe, rarely does more than 
> 8KB segments.
> CONFIG_HIGHMEM4G=y  with 3GB RAM:  very severe, rarely does more than 
> 8KB segments.
> 
> So if you want to reproduce this on a large memory machine, use 
> "mem=2GB" for starters.
..

Here's the commit that causes the regression:

535131e6925b4a95f321148ad7293f496e0e58d7 Choose pages from the per-cpu list based on migration type


From: Mel Gorman <mel@csn.ul.ie>
Date: Tue, 16 Oct 2007 08:25:49 +0000 (-0700)
Subject: Choose pages from the per-cpu list based on migration type
X-Git-Tag: v2.6.24-rc1~1141
X-Git-Url: http://git.kernel.org/?p=linux%2Fkernel%2Fgit%2Ftorvalds%2Flinux-2.6.git;a=commitdiff_plain;h=535131e6925b4a95f321148ad7293f496e0e58d7;hp=b2a0ac8875a0a3b9f0739b60526f8c5977d2200f

Choose pages from the per-cpu list based on migration type

The freelists for each migrate type can slowly become polluted due to the
per-cpu list.  Consider what happens when the following happens

1. A 2^(MAX_ORDER-1) list is reserved for __GFP_MOVABLE pages
2. An order-0 page is allocated from the newly reserved block
3. The page is freed and placed on the per-cpu list
4. alloc_page() is called with GFP_KERNEL as the gfp_mask
5. The per-cpu list is used to satisfy the allocation

This results in a kernel page is in the middle of a migratable region. This
patch prevents this leak occuring by storing the MIGRATE_ type of the page in
page->private. On allocate, a page will only be returned of the desired type,
else more pages will be allocated. This may temporarily allow a per-cpu list
to go over the pcp->high limit but it'll be corrected on the next free. Care
is taken to preserve the hotness of pages recently freed.

The additional code is not measurably slower for the workloads we've tested.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
---

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index d54ecf4..e3e726b 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -760,7 +760,8 @@ static int rmqueue_bulk(struct zone *zone, unsigned int order,
 		struct page *page = __rmqueue(zone, order, migratetype);
 		if (unlikely(page == NULL))
 			break;
-		list_add_tail(&page->lru, list);
+		list_add(&page->lru, list);
+		set_page_private(page, migratetype);
 	}
 	spin_unlock(&zone->lock);
 	return i;
@@ -887,6 +888,7 @@ static void fastcall free_hot_cold_page(struct page *page, int cold)
 	local_irq_save(flags);
 	__count_vm_event(PGFREE);
 	list_add(&page->lru, &pcp->list);
+	set_page_private(page, get_pageblock_migratetype(page));
 	pcp->count++;
 	if (pcp->count >= pcp->high) {
 		free_pages_bulk(zone, pcp->batch, &pcp->list, 0);
@@ -951,9 +953,27 @@ again:
 			if (unlikely(!pcp->count))
 				goto failed;
 		}
-		page = list_entry(pcp->list.next, struct page, lru);
-		list_del(&page->lru);
-		pcp->count--;
+		/* Find a page of the appropriate migrate type */
+		list_for_each_entry(page, &pcp->list, lru) {
+			if (page_private(page) == migratetype) {
+				list_del(&page->lru);
+				pcp->count--;
+				break;
+			}
+		}
+
+		/*
+		 * Check if a page of the appropriate migrate type
+		 * was found. If not, allocate more to the pcp list
+		 */
+		if (&page->lru == &pcp->list) {
+			pcp->count += rmqueue_bulk(zone, 0,
+					pcp->batch, &pcp->list, migratetype);
+			page = list_entry(pcp->list.next, struct page, lru);
+			VM_BUG_ON(page_private(page) != migratetype);
+			list_del(&page->lru);
+			pcp->count--;
+		}
 	} else {
 		spin_lock_irqsave(&zone->lock, flags);
 		page = __rmqueue(zone, order, migratetype);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
