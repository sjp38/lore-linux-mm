Received: from sd0208e0.au.ibm.com (d23rh904.au.ibm.com [202.81.18.202])
	by ausmtp04.au.ibm.com (8.13.8/8.13.8) with ESMTP id l2R7Zahv009666
	for <linux-mm@kvack.org>; Tue, 27 Mar 2007 17:35:36 +1000
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.250.242])
	by sd0208e0.au.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l2R7LIki100662
	for <linux-mm@kvack.org>; Tue, 27 Mar 2007 17:21:26 +1000
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l2R7HUfT028116
	for <linux-mm@kvack.org>; Tue, 27 Mar 2007 17:17:45 +1000
Message-ID: <4608C4F6.4020407@linux.vnet.ibm.com>
Date: Tue, 27 Mar 2007 12:47:10 +0530
From: Vaidyanathan Srinivasan <svaidy@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH 3/3][RFC] Containers: Pagecache controller reclaim
References: <45ED251C.2010400@linux.vnet.ibm.com> <45ED266E.7040107@linux.vnet.ibm.com> <6d6a94c50703262044q22e94538i5e79a32a82f7c926@mail.gmail.com>
In-Reply-To: <6d6a94c50703262044q22e94538i5e79a32a82f7c926@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Aubrey Li <aubreylee@gmail.com>
Cc: Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, ckrm-tech@lists.sourceforge.net, Balbir Singh <balbir@in.ibm.com>, Srivatsa Vaddagiri <vatsa@in.ibm.com>, devel@openvz.org, xemul@sw.ru, Paul Menage <menage@google.com>, Christoph Lameter <clameter@sgi.com>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>


Aubrey Li wrote:
> On 3/6/07, Vaidyanathan Srinivasan <svaidy@linux.vnet.ibm.com> wrote:
>> The reclaim code is similar to RSS memory controller.  Scan control is
>> slightly different since we are targeting different type of pages.
>>
>> Additionally no mapped pages are touched when scanning for pagecache pages.
>>
>> RSS memory controller and pagecache controller share common code in reclaim
>> and hence pagecache controller patches are dependent on RSS memory controller
>> patch even though the features are independently configurable at compile time.
>>
>> --- linux-2.6.20.orig/mm/vmscan.c
>> +++ linux-2.6.20/mm/vmscan.c
>> @@ -43,6 +43,7 @@
>>
>>  #include <linux/swapops.h>
>>  #include <linux/memcontrol.h>
>> +#include <linux/pagecache_acct.h>
>>
>>  #include "internal.h"
>>
>> @@ -70,6 +71,8 @@ struct scan_control {
>>
>>         struct container *container;    /* Used by containers for reclaiming */
>>                                         /* pages when the limit is exceeded  */
>> +       int reclaim_pagecache_only;     /* Set when called from
>> +                                          pagecache controller */
>>  };
>>
>>  /*
>> @@ -474,6 +477,15 @@ static unsigned long shrink_page_list(st
>>                         goto keep;
>>
>>                 VM_BUG_ON(PageActive(page));
>> +               /* Take it easy if we are doing only pagecache pages */
>> +               if (sc->reclaim_pagecache_only) {
>> +                       /* Check if this is a pagecache page they are not mapped */
>> +                       if (page_mapped(page))
>> +                               goto keep_locked;
>> +                       /* Check if this container has exceeded pagecache limit */
>> +                       if (!pagecache_acct_page_overlimit(page))
>> +                               goto keep_locked;
>> +               }
>>
>>                 sc->nr_scanned++;
>>
>> @@ -522,7 +534,8 @@ static unsigned long shrink_page_list(st
>>                 }
>>
>>                 if (PageDirty(page)) {
>> -                       if (referenced)
>> +                       /* Reclaim even referenced pagecache pages if over limit */
>> +                       if (!pagecache_acct_page_overlimit(page) && referenced)
>>                                 goto keep_locked;
>>                         if (!may_enter_fs)
>>                                 goto keep_locked;
>> @@ -869,6 +882,13 @@ force_reclaim_mapped:
>>                 cond_resched();
>>                 page = lru_to_page(&l_hold);
>>                 list_del(&page->lru);
>> +               /* While reclaiming pagecache make it easy */
>> +               if (sc->reclaim_pagecache_only) {
>> +                       if (page_mapped(page) || !pagecache_acct_page_overlimit(page)) {
>> +                               list_add(&page->lru, &l_active);
>> +                               continue;
>> +                       }
>> +               }
> 
> Please correct me if I'm wrong.
> Here, if page type is mapped or not overlimit, why add it back to active list?
> Did  shrink_page_list() is called by shrink_inactive_list()?

Correct, shrink_page_list() is called from shrink_inactive_list() but
the above code is patched in shrink_active_list().  The
'force_reclaim_mapped' label is from function shrink_active_list() and
not in shrink_page_list() as it may seem in the patch file.

While removing pages from active_list, we want to select only
pagecache pages and leave the remaining in the active_list.
page_mapped() pages are _not_ of interest to pagecache controller
(they will be taken care by rss controller) and hence we put it back.
 Also if the pagecache controller is below limit, no need to reclaim
so we put back all pages and come out.

--Vaidy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
