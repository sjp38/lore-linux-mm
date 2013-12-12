Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f45.google.com (mail-ee0-f45.google.com [74.125.83.45])
	by kanga.kvack.org (Postfix) with ESMTP id CF0E66B0036
	for <linux-mm@kvack.org>; Thu, 12 Dec 2013 07:41:26 -0500 (EST)
Received: by mail-ee0-f45.google.com with SMTP id d49so198832eek.18
        for <linux-mm@kvack.org>; Thu, 12 Dec 2013 04:41:26 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTP id m44si23496220eeo.100.2013.12.12.04.41.25
        for <linux-mm@kvack.org>;
        Thu, 12 Dec 2013 04:41:26 -0800 (PST)
Message-ID: <52A9AEF2.2030600@suse.cz>
Date: Thu, 12 Dec 2013 13:41:22 +0100
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: kernel BUG in munlock_vma_pages_range
References: <52A3D0C3.1080504@oracle.com> <52A58E8A.3050401@suse.cz> <52A5F83F.4000207@oracle.com> <52A5F9EE.4010605@suse.cz> <52A6275F.4040007@oracle.com> <52A8EE38.2060004@suse.cz> <52A92A8D.20603@oracle.com> <52A943BC.2090001@oracle.com>
In-Reply-To: <52A943BC.2090001@oracle.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bob Liu <bob.liu@oracle.com>, Sasha Levin <sasha.levin@oracle.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, joern@logfs.org, mgorman@suse.de, Michel Lespinasse <walken@google.com>, riel@redhat.com, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On 12/12/2013 06:03 AM, Bob Liu wrote:
> 
> On 12/12/2013 11:16 AM, Sasha Levin wrote:
>> On 12/11/2013 05:59 PM, Vlastimil Babka wrote:
>>> On 12/09/2013 09:26 PM, Sasha Levin wrote:
>>>> On 12/09/2013 12:12 PM, Vlastimil Babka wrote:
>>>>> On 12/09/2013 06:05 PM, Sasha Levin wrote:
>>>>>> On 12/09/2013 04:34 AM, Vlastimil Babka wrote:
>>>>>>> Hello, I will look at it, thanks.
>>>>>>> Do you have specific reproduction instructions?
>>>>>>
>>>>>> Not really, the fuzzer hit it once and I've been unable to trigger
>>>>>> it again. Looking at
>>>>>> the piece of code involved it might have had something to do with
>>>>>> hugetlbfs, so I'll crank
>>>>>> up testing on that part.
>>>>>
>>>>> Thanks. Do you have trinity log and the .config file? I'm currently
>>>>> unable to even boot linux-next
>>>>> with my config/setup due to a GPF.
>>>>> Looking at code I wouldn't expect that it could encounter a tail
>>>>> page, without first encountering a
>>>>> head page and skipping the whole huge page. At least in THP case, as
>>>>> TLB pages should be split when
>>>>> a vma is split. As for hugetlbfs, it should be skipped for
>>>>> mlock/munlock operations completely. One
>>>>> of these assumptions is probably failing here...
>>>>
>>>> If it helps, I've added a dump_page() in case we hit a tail page
>>>> there and got:
>>>>
>>>> [  980.172299] page:ffffea003e5e8040 count:0 mapcount:1
>>>> mapping:          (null) index:0
>>>> x0
>>>> [  980.173412] page flags: 0x2fffff80008000(tail)
>>>>
>>>> I can also add anything else in there to get other debug output if
>>>> you think of something else useful.
>>>
>>> Please try the following. Thanks in advance.
>>
>> [  428.499889] page:ffffea003e5c0040 count:0 mapcount:4
>> mapping:          (null) index:0x0
>> [  428.499889] page flags: 0x2fffff80008000(tail)
>> [  428.499889] start=140117131923456 pfn=16347137
>> orig_start=140117130543104 page_increm
>> =1 vm_start=140117130543104 vm_end=140117134688256 vm_flags=135266419
>> [  428.499889] first_page pfn=16347136
>> [  428.499889] page:ffffea003e5c0000 count:204 mapcount:44
>> mapping:ffff880fb5c466c1 inde
>> x:0x7f6f8fe00
>> [  428.499889] page flags:
>> 0x2fffff80084068(uptodate|lru|active|head|swapbacked)
> 
>  From this print, it looks like the page is still a huge page.
> One situation I guess is a huge page which isn't PageMlocked and passed
> to munlock_vma_page(). I'm not sure whether this will happen.

Yes that's quite likely the case. It's not illegal to happen I would say.

> Please take a try this patch.

I've made a simpler version that does away with the ugly page_mask thing completely.
Please try that as well. Thanks.

Also when working on this I think I found another potential but much rare problem
when munlock_vma_page races with a THP split. That would however manifest such that
part of the former tail pages would stay PageMlocked. But that still needs more thought.
The bug at hand should however be fixed by this patch.

--------8<----------
From: Vlastimil Babka <vbabka@suse.cz>
Date: Thu, 12 Dec 2013 13:06:39 +0100
Subject: [PATCH] munlock_vma_pages_range() candidate fix

---
 mm/internal.h |  2 +-
 mm/mlock.c    | 22 ++++++++--------------
 2 files changed, 9 insertions(+), 15 deletions(-)

diff --git a/mm/internal.h b/mm/internal.h
index 684f7aa..ffacdec 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -192,7 +192,7 @@ static inline int mlocked_vma_newpage(struct vm_area_struct *vma,
  * must be called with vma's mmap_sem held for read or write, and page locked.
  */
 extern void mlock_vma_page(struct page *page);
-extern unsigned int munlock_vma_page(struct page *page);
+extern void munlock_vma_page(struct page *page);
 
 /*
  * Clear the page's PageMlocked().  This can be useful in a situation where
diff --git a/mm/mlock.c b/mm/mlock.c
index d480cd6..a34dfdc 100644
--- a/mm/mlock.c
+++ b/mm/mlock.c
@@ -146,23 +146,18 @@ static void __munlock_isolation_failed(struct page *page)
  * can't isolate the page, we leave it for putback_lru_page() and vmscan
  * [page_referenced()/try_to_unmap()] to deal with.
  */
-unsigned int munlock_vma_page(struct page *page)
+void munlock_vma_page(struct page *page)
 {
-	unsigned int page_mask = 0;
-
 	BUG_ON(!PageLocked(page));
 
 	if (TestClearPageMlocked(page)) {
 		unsigned int nr_pages = hpage_nr_pages(page);
 		mod_zone_page_state(page_zone(page), NR_MLOCK, -nr_pages);
-		page_mask = nr_pages - 1;
 		if (!isolate_lru_page(page))
 			__munlock_isolated_page(page);
 		else
 			__munlock_isolation_failed(page);
 	}
-
-	return page_mask;
 }
 
 /**
@@ -440,7 +435,7 @@ void munlock_vma_pages_range(struct vm_area_struct *vma,
 
 	while (start < end) {
 		struct page *page = NULL;
-		unsigned int page_mask, page_increm;
+		unsigned int page_increm = 1;
 		struct pagevec pvec;
 		struct zone *zone;
 		int zoneid;
@@ -453,21 +448,21 @@ void munlock_vma_pages_range(struct vm_area_struct *vma,
 		 * suits munlock very well (and if somehow an abnormal page
 		 * has sneaked into the range, we won't oops here: great).
 		 */
-		page = follow_page_mask(vma, start, FOLL_GET | FOLL_DUMP,
-				&page_mask);
+		page = follow_page(vma, start, FOLL_GET | FOLL_DUMP);
 
 		if (page && !IS_ERR(page)) {
 			if (PageTransHuge(page)) {
 				lock_page(page);
+				munlock_vma_page(page);
 				/*
 				 * Any THP page found by follow_page_mask() may
 				 * have gotten split before reaching
-				 * munlock_vma_page(), so we need to recompute
-				 * the page_mask here.
+				 * munlock_vma_page(), so we need to recheck
+				 * how many pages to skip.
 				 */
-				page_mask = munlock_vma_page(page);
+				page_increm = hpage_nr_pages(page);
 				unlock_page(page);
-				put_page(page); /* follow_page_mask() */
+				put_page(page); /* follow_page() */
 			} else {
 				/*
 				 * Non-huge pages are handled in batches via
@@ -490,7 +485,6 @@ void munlock_vma_pages_range(struct vm_area_struct *vma,
 				goto next;
 			}
 		}
-		page_increm = 1 + (~(start >> PAGE_SHIFT) & page_mask);
 		start += page_increm * PAGE_SIZE;
 next:
 		cond_resched();
-- 
1.8.4


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
