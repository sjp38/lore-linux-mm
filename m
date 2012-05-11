Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx101.postini.com [74.125.245.101])
	by kanga.kvack.org (Postfix) with SMTP id 35E8A6B004D
	for <linux-mm@kvack.org>; Fri, 11 May 2012 00:37:13 -0400 (EDT)
Message-ID: <4FAC9786.9060200@kernel.org>
Date: Fri, 11 May 2012 13:37:26 +0900
From: Minchan Kim <minchan@kernel.org>
MIME-Version: 1.0
Subject: Allow migration of mlocked page?
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, tglx@linutronix.de, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>
Cc: Theodore Ts'o <tytso@mit.edu>

Let's open new thread.

On 05/11/2012 11:51 AM, KOSAKI Motohiro wrote:
> (5/10/12 8:50 PM), Minchan Kim wrote:
>> Hi KOSAKI,
>>
>> On 05/11/2012 02:53 AM, KOSAKI Motohiro wrote:
>>
>>>>>> let's assume that one application want to allocate user space memory
>>>>>> region using malloc() and then write something on the region. as you
>>>>>> may know, user space buffer doen't have real physical pages once
>>>>>> malloc() call so if user tries to access the region then page fault
>>>>>> handler would be triggered
>>>>>
>>>>>
>>>>> Understood.
>>>>>
>>>>>> and then in turn next process like swap in to fill physical frame
>>>>>> number
>>>>> into entry of the page faulted.
>>>>>
>>>>>
>>>>> Sorry, I can't understand your point due to my poor English.
>>>>> Could you rewrite it easiliy? :)
>>>>>
>>>>
>>>> Simply saying, handle_mm_fault would be called to update pte after
>>>> finding
>>>> vma and checking access right. and as you know, there are many cases to
>>>> process page fault such as COW or demand paging.
>>>
>>> Hmm. If I understand correctly, you guys misunderstand mlock. it doesn't
>>> page pinning
>>> nor prevent pfn change. It only guarantee to don't make swap out. e.g.
>>
>>
>> Symantic point of view, you're right but the implementation makes sure
>> page pinning.
>>
>>> memory campaction
>>> feature may automatically change page physical address.
>>
>>
>> I tried it last year but decided drop by realtime issue.
>> https://lkml.org/lkml/2011/8/29/295
>>
>> so I think mlock is a kind of page pinning. If elsewhere I don't
>> realized is doing, that place should be fixed.
>> Or my above patch should go ahead.
> 
> Thanks pointing out. I didn't realized your patch didn't merged. I think
> it should go ahead. think autonuma case,
> if mlock disable autonuma migration, that's bug.  I don't think we can

Bug is rather exaggerated. It's a just more overhead.

> promise mlock don't change physical page.
> I wonder if any realtime guys page migration is free lunch. they should
> disable both auto migration and compaction.

I think disable migration is overkill. We can do better than it.
Quote from discussion last year from me.

"
We can solve a bit that by another approach if it's really problem
with RT processes. The another approach is to separate mlocked pages
with allocation time like below pseudo patch which just show the
concept)

ex)
diff --git a/include/linux/highmem.h b/include/linux/highmem.h
index 3a93f73..8ae2e60 100644
--- a/include/linux/highmem.h
+++ b/include/linux/highmem.h
@@ -175,7 +175,8 @@ static inline struct page *
 alloc_zeroed_user_highpage_movable(struct vm_area_struct *vma,
                                        unsigned long vaddr)
 {
-       return __alloc_zeroed_user_highpage(__GFP_MOVABLE, vma, vaddr);
+       gfp_t gfp_flag = vma->vm_flags & VM_LCOKED ? 0 : __GFP_MOVABLE;
+       return __alloc_zeroed_user_highpage(gfp_flag, vma, vaddr);
 }

But it's a solution about newly allocated page on mlocked vma.
Old pages in the VMA is still a problem.
We can solve it at mlock system call through migrating the pages to
UNMOVABLE block.
"
It would be a solution to enhance compaction/CMA and we can make that compaction doesn't migrate
UNMOVABLE_PAGE_GROUP which make full by unevictable pages so mlocked page is still pinning page.
But get_user_pages in drivers still a problem. Or we can migrate unevictable pages, too so that
compaction/CMA would be good much but we lost pinning concept(It would break man page of mlocked
about real-time application stuff). Hmm.

> 
> And, think if application explictly use migrate_pages(2) or admins uses
> cpusets. driver code can't assume such scenario
> doesn't occur, yes?

Yes. it seems to migrate mlocked page now. Hmm,
Johannes, Mel.
Why should we be unfair on only compaction?

I hope hear opinion from rt guys, too.
Thanks.

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
