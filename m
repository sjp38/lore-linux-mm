Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx162.postini.com [74.125.245.162])
	by kanga.kvack.org (Postfix) with SMTP id 457816B0039
	for <linux-mm@kvack.org>; Mon, 26 Aug 2013 20:21:12 -0400 (EDT)
Received: from /spool/local
	by e23smtp03.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Tue, 27 Aug 2013 10:09:58 +1000
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [9.190.235.21])
	by d23dlp03.au.ibm.com (Postfix) with ESMTP id 33EF33578052
	for <linux-mm@kvack.org>; Tue, 27 Aug 2013 10:21:07 +1000 (EST)
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r7R0KujO44040282
	for <linux-mm@kvack.org>; Tue, 27 Aug 2013 10:20:56 +1000
Received: from d23av01.au.ibm.com (localhost [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id r7R0L6o3001182
	for <linux-mm@kvack.org>; Tue, 27 Aug 2013 10:21:07 +1000
Date: Tue, 27 Aug 2013 08:21:05 +0800
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH v4 8/10] mm/hwpoison: fix memory failure still hold
 reference count after unpoison empty zero page
Message-ID: <20130827002105.GA20736@hacker.(null)>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
References: <1377506774-5377-1-git-send-email-liwanp@linux.vnet.ibm.com>
 <1377506774-5377-8-git-send-email-liwanp@linux.vnet.ibm.com>
 <1377531937-15nx3q8e-mutt-n-horiguchi@ah.jp.nec.com>
 <20130826232604.GA12498@hacker.(null)>
 <1377562349-97tgdeoj-mutt-n-horiguchi@ah.jp.nec.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1377562349-97tgdeoj-mutt-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>, Fengguang Wu <fengguang.wu@intel.com>, Tony Luck <tony.luck@intel.com>, gong.chen@linux.intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi Naoya,
On Mon, Aug 26, 2013 at 08:12:29PM -0400, Naoya Horiguchi wrote:
>Hi Wanpeng,
>
>On Tue, Aug 27, 2013 at 07:26:04AM +0800, Wanpeng Li wrote:
>> Hi Naoya,
>> On Mon, Aug 26, 2013 at 11:45:37AM -0400, Naoya Horiguchi wrote:
>> >On Mon, Aug 26, 2013 at 04:46:12PM +0800, Wanpeng Li wrote:
>> >> madvise hwpoison inject will poison the read-only empty zero page if there is 
>> >> no write access before poison. Empty zero page reference count will be increased 
>> >> for hwpoison, subsequent poison zero page will return directly since page has
>> >> already been set PG_hwpoison, however, page reference count is still increased 
>> >> by get_user_pages_fast. The unpoison process will unpoison the empty zero page 
>> >> and decrease the reference count successfully for the fist time, however, 
>> >> subsequent unpoison empty zero page will return directly since page has already 
>> >> been unpoisoned and without decrease the page reference count of empty zero page.
>> >> This patch fix it by decrease page reference count for empty zero page which has 
>> >> already been unpoisoned and page count > 1.
>> >
>> >I guess that fixing on the madvise side looks reasonable to me, because this
>> >refcount mismatch happens only when we poison with madvise(). The root cause
>> >is that we can get refcount multiple times on a page, even if memory_failure()
>> >or soft_offline_page() can do its work only once.
>> >
>> 
>> I think this just happen in read-only before poison case against empty
>> zero page. 
>
>OK. I agree.
>
>> Hi Andrew,
>> 
>> I see you have already merged the patch, which method you prefer? 
>>
>> >How about making madvise_hwpoison() put a page and return immediately
>> >(without calling memory_failure() or soft_offline_page()) when the page
>> >is already hwpoisoned? 
>> >I hope it also helps us avoid meaningless printk flood.
>> >
>> 
>> Btw, Naoya, how about patch 10/10, any input are welcome! ;-)
>
>No objection if you (and Andrew) decide to go with current approach.

Andrew prefer your method, I will resend the patch w/ your suggested-by. ;-)

>But I think that if we shift to fix this problem in madvise(),
>we don't need 10/10 any more. So it looks simpler to me.

I don't think it's same issue. There is just one page in my test case.
#define PAGES_TO_TEST 1
If I miss something?

Regards,
Wanpeng Li 

>
>Thanks,
>Naoya Horiguchi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
