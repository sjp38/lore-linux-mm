Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ea0-f172.google.com (mail-ea0-f172.google.com [209.85.215.172])
	by kanga.kvack.org (Postfix) with ESMTP id 0B74D6B0074
	for <linux-mm@kvack.org>; Fri, 13 Dec 2013 04:08:12 -0500 (EST)
Received: by mail-ea0-f172.google.com with SMTP id q10so612867ead.17
        for <linux-mm@kvack.org>; Fri, 13 Dec 2013 01:08:12 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 5si1180094eei.18.2013.12.13.01.08.11
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 13 Dec 2013 01:08:12 -0800 (PST)
Message-ID: <52AACE79.20804@suse.cz>
Date: Fri, 13 Dec 2013 10:08:09 +0100
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: kernel BUG in munlock_vma_pages_range
References: <52A3D0C3.1080504@oracle.com> <52A58E8A.3050401@suse.cz> <52A5F83F.4000207@oracle.com> <52A5F9EE.4010605@suse.cz> <52A6275F.4040007@oracle.com> <52A8EE38.2060004@suse.cz> <52A92A8D.20603@oracle.com> <52A943BC.2090001@oracle.com> <52A9AEF2.2030600@suse.cz> <52AA2510.8080908@oracle.com> <52AACA0B.6080602@oracle.com>
In-Reply-To: <52AACA0B.6080602@oracle.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bob Liu <bob.liu@oracle.com>, Sasha Levin <sasha.levin@oracle.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, joern@logfs.org, mgorman@suse.de, Michel Lespinasse <walken@google.com>, riel@redhat.com, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On 12/13/2013 09:49 AM, Bob Liu wrote:
> On 12/13/2013 05:05 AM, Sasha Levin wrote:
>> On 12/12/2013 07:41 AM, Vlastimil Babka wrote:
>>> On 12/12/2013 06:03 AM, Bob Liu wrote:
>>>>
>>>> On 12/12/2013 11:16 AM, Sasha Levin wrote:
>>>>> On 12/11/2013 05:59 PM, Vlastimil Babka wrote:
>>>>>> On 12/09/2013 09:26 PM, Sasha Levin wrote:
>>>>>>> On 12/09/2013 12:12 PM, Vlastimil Babka wrote:
>>>>>>>> On 12/09/2013 06:05 PM, Sasha Levin wrote:
>>>>>>>>> On 12/09/2013 04:34 AM, Vlastimil Babka wrote:
>>>>>>>>>> Hello, I will look at it, thanks.
>>>>>>>>>> Do you have specific reproduction instructions?
>>>>>>>>>
>>>>>>>>> Not really, the fuzzer hit it once and I've been unable to trigger
>>>>>>>>> it again. Looking at
>>>>>>>>> the piece of code involved it might have had something to do with
>>>>>>>>> hugetlbfs, so I'll crank
>>>>>>>>> up testing on that part.
>>>>>>>>
>>>>>>>> Thanks. Do you have trinity log and the .config file? I'm currently
>>>>>>>> unable to even boot linux-next
>>>>>>>> with my config/setup due to a GPF.
>>>>>>>> Looking at code I wouldn't expect that it could encounter a tail
>>>>>>>> page, without first encountering a
>>>>>>>> head page and skipping the whole huge page. At least in THP case, as
>>>>>>>> TLB pages should be split when
>>>>>>>> a vma is split. As for hugetlbfs, it should be skipped for
>>>>>>>> mlock/munlock operations completely. One
>>>>>>>> of these assumptions is probably failing here...
>>>>>>>
>>>>>>> If it helps, I've added a dump_page() in case we hit a tail page
>>>>>>> there and got:
>>>>>>>
>>>>>>> [  980.172299] page:ffffea003e5e8040 count:0 mapcount:1
>>>>>>> mapping:          (null) index:0
>>>>>>> x0
>>>>>>> [  980.173412] page flags: 0x2fffff80008000(tail)
>>>>>>>
>>>>>>> I can also add anything else in there to get other debug output if
>>>>>>> you think of something else useful.
>>>>>>
>>>>>> Please try the following. Thanks in advance.
>>>>>
>>>>> [  428.499889] page:ffffea003e5c0040 count:0 mapcount:4
>>>>> mapping:          (null) index:0x0
>>>>> [  428.499889] page flags: 0x2fffff80008000(tail)
>>>>> [  428.499889] start=140117131923456 pfn=16347137
>>>>> orig_start=140117130543104 page_increm
>>>>> =1 vm_start=140117130543104 vm_end=140117134688256 vm_flags=135266419
>>>>> [  428.499889] first_page pfn=16347136
>>>>> [  428.499889] page:ffffea003e5c0000 count:204 mapcount:44
>>>>> mapping:ffff880fb5c466c1 inde
>>>>> x:0x7f6f8fe00
>>>>> [  428.499889] page flags:
>>>>> 0x2fffff80084068(uptodate|lru|active|head|swapbacked)
>>>>
>>>>    From this print, it looks like the page is still a huge page.
>>>> One situation I guess is a huge page which isn't PageMlocked and passed
>>>> to munlock_vma_page(). I'm not sure whether this will happen.
>>>
>>> Yes that's quite likely the case. It's not illegal to happen I would say.
>>>
>>>> Please take a try this patch.
>>>
>>> I've made a simpler version that does away with the ugly page_mask
>>> thing completely.
>>> Please try that as well. Thanks.
>>>
>>> Also when working on this I think I found another potential but much
>>> rare problem
>>> when munlock_vma_page races with a THP split. That would however
>>> manifest such that
>>> part of the former tail pages would stay PageMlocked. But that still
>>> needs more thought.
>>> The bug at hand should however be fixed by this patch.
>>
>> Yup, this patch seems to fix the issue previously reported.
>>
>> However, I'll piggyback another thing that popped up now that the vm
>> could run for a while which
>> also seems to be caused by the original patch. It looks like a pretty
>> straightforward deadlock, but

Sigh, put one down, patch it around... :)

> Looks like put_page() in __munlock_pagevec() need to get the
> zone->lru_lock which is already held when entering __munlock_pagevec().

I've come to the same conclusion, however:

> How about fix like this?

That unfortunately removes most of the purpose of this function which was to avoid repeated locking. 

Please try this patch.

-------8<-------
From: Vlastimil Babka <vbabka@suse.cz>
Date: Fri, 13 Dec 2013 10:03:25 +0100
Subject: [PATCH] Deadlock in __munlock_pagevec candidate fix

---
 mm/mlock.c | 16 ++++++++++++----
 1 file changed, 12 insertions(+), 4 deletions(-)

diff --git a/mm/mlock.c b/mm/mlock.c
index a34dfdc..c97273e 100644
--- a/mm/mlock.c
+++ b/mm/mlock.c
@@ -281,10 +281,12 @@ static void __munlock_pagevec(struct pagevec *pvec, struct zone *zone)
 {
 	int i;
 	int nr = pagevec_count(pvec);
-	int delta_munlocked = -nr;
+	int delta_munlocked;
 	struct pagevec pvec_putback;
 	int pgrescued = 0;
 
+	pagevec_init(&pvec_putback, 0);
+
 	/* Phase 1: page isolation */
 	spin_lock_irq(&zone->lru_lock);
 	for (i = 0; i < nr; i++) {
@@ -313,16 +315,22 @@ skip_munlock:
 			/*
 			 * We won't be munlocking this page in the next phase
 			 * but we still need to release the follow_page_mask()
-			 * pin.
+			 * pin. We cannot do it under lru_lock however. If it's
+			 * the last pin, __page_cache_release would deadlock.
 			 */
+			pagevec_add(&pvec_putback, pvec->pages[i]);
 			pvec->pages[i] = NULL;
-			put_page(page);
-			delta_munlocked++;
 		}
 	}
+	delta_munlocked = -nr + pagevec_count(&pvec_putback);
 	__mod_zone_page_state(zone, NR_MLOCK, delta_munlocked);
 	spin_unlock_irq(&zone->lru_lock);
 
+	/* Now we can release pins of pages that we are not munlocking */
+	for (i = 0; i < pagevec_count(&pvec_putback); i++) {
+		put_page(pvec_putback.pages[i]);
+	}
+
 	/* Phase 2: page munlock */
 	pagevec_init(&pvec_putback, 0);
 	for (i = 0; i < nr; i++) {
-- 
1.8.4


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
