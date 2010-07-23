Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 1835E6B02A8
	for <linux-mm@kvack.org>; Fri, 23 Jul 2010 14:06:39 -0400 (EDT)
Received: by pvc30 with SMTP id 30so4382760pvc.14
        for <linux-mm@kvack.org>; Fri, 23 Jul 2010 11:06:34 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20100723152552.GE8127@basil.fritz.box>
References: <1279610324.17101.9.camel@sli10-desk.sh.intel.com>
	<20100723234938.88EB.A69D9226@jp.fujitsu.com>
	<20100723152552.GE8127@basil.fritz.box>
Date: Sat, 24 Jul 2010 03:06:33 +0900
Message-ID: <AANLkTin3EbBe_x2JpdaOyz7KsBb7ztW++1=w_4RrPyK3@mail.gmail.com>
Subject: Re: [RFC]mm: batch activate_page() to reduce lock contention
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: Shaohua Li <shaohua.li@intel.com>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, "Wu, Fengguang" <fengguang.wu@intel.com>
List-ID: <linux-mm.kvack.org>

>> > For example, in a 4 socket 64 CPU system, create a sparse file and 64 processes,
>> > processes shared map to the file. Each process read access the whole file and
>> > then exit. The process exit will do unmap_vmas() and cause a lot of
>> > activate_page() call. In such workload, we saw about 58% total time reduction
>> > with below patch.
>>
>> I'm not sure this. Why process exiting on your workload call unmap_vmas?
>
> Trick question?
>
> Getting rid of a mm on process exit requires unmapping the vmas.

Oops, I misparsed unmap_vmas() and unuse_vma(). thanks fix me.

Ho Hum, zap_pte_range() call mark_page_accessed(). it was introduced slightly
recent (below).

----------------------------------------------------------------------------------
commit bf3f3bc5e734706730c12a323f9b2068052aa1f0
Author: Nick Piggin <npiggin@suse.de>
Date:   Tue Jan 6 14:38:55 2009 -0800

    mm: don't mark_page_accessed in fault path
----------------------------------------------------------------------------------


So, I guess we can apply following small optimization.
the intention is, if the exiting process is last mapped one,
we don't need to refrect its pte_young() because it is good
sign that the page is never touched.

Of cource, this is offtopic. On Shaouhua's testcase, 64 processes
shared map to the file.

-------------------------------------------------------------------------------
diff --git a/mm/memory.c b/mm/memory.c
index 833952d..ebdfcb1 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -951,7 +951,8 @@ static unsigned long zap_pte_range(struct mmu_gather *tlb,
                                if (pte_dirty(ptent))
                                        set_page_dirty(page);
                                if (pte_young(ptent) &&
-                                   likely(!VM_SequentialReadHint(vma)))
+                                   (page_mapcount(page) != 1) &&
+                                   !VM_SequentialReadHint(vma))
                                        mark_page_accessed(page);
                                rss[MM_FILEPAGES]--;
-------------------------------------------------------------------------------

One more offtopic:
we need to move ClearPageReferenced() from mark_page_accessed()
to __activate_page() honorly. unuse_vma() case also need to clear
page-referenced bit. I think.


Anyway, I agree original patch concept is fine. Thanks a lot of productive
information!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
