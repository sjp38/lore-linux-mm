Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx168.postini.com [74.125.245.168])
	by kanga.kvack.org (Postfix) with SMTP id A5A946B0089
	for <linux-mm@kvack.org>; Fri, 23 Aug 2013 00:24:53 -0400 (EDT)
Received: from /spool/local
	by e28smtp04.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Fri, 23 Aug 2013 09:46:49 +0530
Received: from d28relay03.in.ibm.com (d28relay03.in.ibm.com [9.184.220.60])
	by d28dlp02.in.ibm.com (Postfix) with ESMTP id 0410A3940053
	for <linux-mm@kvack.org>; Fri, 23 Aug 2013 09:54:37 +0530 (IST)
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay03.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r7N4QIM343515956
	for <linux-mm@kvack.org>; Fri, 23 Aug 2013 09:56:18 +0530
Received: from d28av05.in.ibm.com (localhost [127.0.0.1])
	by d28av05.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id r7N4OkgH030941
	for <linux-mm@kvack.org>; Fri, 23 Aug 2013 09:54:46 +0530
Date: Fri, 23 Aug 2013 12:24:44 +0800
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH 3/6] mm/hwpoison: fix num_poisoned_pages error statistics
 for thp
Message-ID: <20130823042444.GA23672@hacker.(null)>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
References: <1377164907-24801-1-git-send-email-liwanp@linux.vnet.ibm.com>
 <1377164907-24801-3-git-send-email-liwanp@linux.vnet.ibm.com>
 <1377189788-xv5ewgmb-mutt-n-horiguchi@ah.jp.nec.com>
 <5216a46f.a800310a.2351.ffffa95cSMTPIN_ADDED_BROKEN@mx.google.com>
 <1377228430-o4j77sme-mutt-n-horiguchi@ah.jp.nec.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1377228430-o4j77sme-mutt-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>, Fengguang Wu <fengguang.wu@intel.com>, Tony Luck <tony.luck@intel.com>, gong.chen@linux.intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi Naoya,
On Thu, Aug 22, 2013 at 11:27:10PM -0400, Naoya Horiguchi wrote:
>Hi Wanpeng,
>
>On Fri, Aug 23, 2013 at 07:52:40AM +0800, Wanpeng Li wrote:
>> Hi Naoya,
>> On Thu, Aug 22, 2013 at 12:43:08PM -0400, Naoya Horiguchi wrote:
>> >On Thu, Aug 22, 2013 at 05:48:24PM +0800, Wanpeng Li wrote:
>> >> There is a race between hwpoison page and unpoison page, memory_failure 
>> >> set the page hwpoison and increase num_poisoned_pages without hold page 
>> >> lock, and one page count will be accounted against thp for num_poisoned_pages.
>> >> However, unpoison can occur before memory_failure hold page lock and 
>> >> split transparent hugepage, unpoison will decrease num_poisoned_pages 
>> >> by 1 << compound_order since memory_failure has not yet split transparent 
>> >> hugepage with page lock held. That means we account one page for hwpoison
>> >> and 1 << compound_order for unpoison. This patch fix it by decrease one 
>> >> account for num_poisoned_pages against no hugetlbfs pages case.
>> >> 
>> >> Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
>> >
>> >I think that a thp never becomes hwpoisoned without splitting, so "trying
>> >to unpoison thp" never happens (I think that this implicit fact should be
>> 
>> There is a race window here for hwpoison thp: 
>
>OK, thanks for great explanation (it's worth written in description.)
>And I found my previous comment was comletely pointless, sorry :(
>

Ah, ok, I will fold them in the patch description. ;-)

>> 				A	  			 									B
>> 		memory_failue 
>> 		TestSetPageHWPoison(p);
>> 		if (PageHuge(p))
>> 			nr_pages = 1 << compound_order(hpage);
>> 		else 
>> 			nr_pages = 1;
>> 		atomic_long_add(nr_pages, &num_poisoned_pages);	
>> 																unpoison_memory
>> 																nr_pages = 1<< compound_trans_order(page;)
>> 
>> 																if(TestClearPageHWPoison(p))
>> 																	atomic_long_sub(nr_pages, &num_poisoned_pages);
>> 		lock page 
>> 		if (!PageHWPoison(p))
>> 			unlock page and return 
>> 		hwpoison_user_mappings
>> 		if (PageTransHuge(hpage))
>> 			split_huge_page(hpage);
>
>When this race happens, our expectation is that num_poisoned_pages is
>increased by 1 because finally thread A succeeds to hwpoison one normal page.
>So thread B should fail to unpoison without clearing PageHWPoison nor
>decreasing num_poisoned_pages.  My suggestion is inserting a PageTransHuge
>check before doing TestClearPageHWPoison like follows:
>
>diff --git a/mm/memory-failure.c b/mm/memory-failure.c
>index 1cb3b7d..f551b72 100644
>--- a/mm/memory-failure.c
>+++ b/mm/memory-failure.c
>@@ -1336,6 +1336,16 @@ int unpoison_memory(unsigned long pfn)
> 		return 0;
> 	}
>
>+	/*
>+	 * unpoison_memory() can encounter thp only when the thp is being
>+	 * worked by memory_failure() and the page lock is not held yet.
>+	 * In such case, we yield to memory_failure() and make unpoison fail.
>+	 */
>+	if (PageTransHuge(page)) {
>+		pr_info("MCE: Memory failure is now running on %#lx\n", pfn);
>+		return 0;
>+	}
>+

Looks reasonable to me, I will fold it in my patch. ;-)

> 	nr_pages = 1 << compound_trans_order(page);
>
> 	if (!get_page_unless_zero(page)) {
>
>
>I think that replacing atomic_long_sub() with atomic_long_dec() still
>has a meaning, so you don't have to drop that.
>

Agreed.

>> 
>> We increase one page count, however, decrease 1 << compound_trans_order.
>> The compound_trans_order you mentioned is used here for thp, that's why 
>> I don't drop it in patch 2/6.
>
>I don't think that we have to use compound_trans_order() any more, because
>with the above change we don't calculate nr_pages any more for thp.
>We can reduce the cost to lock/unlock compound_lock as described in 2/6.
>

Agreed.

>> >commented somewhere or asserted with VM_BUG_ON().)
>> 
>> I will add the VM_BUG_ON() in unpoison_memory after lock page in next
>> version.
>
>Sorry, my previous suggestion didn't make sense.
>

Agreed.

Regards,
Wanpeng Li 

>Thank you!
>Naoya Horiguchi
>
>> >And nr_pages in unpoison_memory() can be greater than 1 for hugetlbfs page.
>> >So does this patch break counting when unpoisoning free hugetlbfs pages?
>> >
>> >Thanks,
>> >Naoya Horiguchi
>> >
>> >> ---
>> >>  mm/memory-failure.c | 2 +-
>> >>  1 file changed, 1 insertion(+), 1 deletion(-)
>> >> 
>> >> diff --git a/mm/memory-failure.c b/mm/memory-failure.c
>> >> index 5092e06..6bfd51e 100644
>> >> --- a/mm/memory-failure.c
>> >> +++ b/mm/memory-failure.c
>> >> @@ -1350,7 +1350,7 @@ int unpoison_memory(unsigned long pfn)
>> >>  			return 0;
>> >>  		}
>> >>  		if (TestClearPageHWPoison(p))
>> >> -			atomic_long_sub(nr_pages, &num_poisoned_pages);
>> >> +			atomic_long_dec(&num_poisoned_pages);
>> >>  		pr_info("MCE: Software-unpoisoned free page %#lx\n", pfn);
>> >>  		return 0;
>> >>  	}
>> >> -- 
>> >> 1.8.1.2
>> >>
>> 
>> --
>> To unsubscribe, send a message with 'unsubscribe linux-mm' in
>> the body to majordomo@kvack.org.  For more info on Linux MM,
>> see: http://www.linux-mm.org/ .
>> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
