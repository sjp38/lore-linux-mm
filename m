Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx135.postini.com [74.125.245.135])
	by kanga.kvack.org (Postfix) with SMTP id DCFAE6B0033
	for <linux-mm@kvack.org>; Mon, 26 Aug 2013 19:40:18 -0400 (EDT)
Received: from /spool/local
	by e23smtp04.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Tue, 27 Aug 2013 09:23:03 +1000
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [9.190.235.21])
	by d23dlp01.au.ibm.com (Postfix) with ESMTP id 68F362CE8052
	for <linux-mm@kvack.org>; Tue, 27 Aug 2013 09:40:11 +1000 (EST)
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r7QNdxZo41156654
	for <linux-mm@kvack.org>; Tue, 27 Aug 2013 09:40:00 +1000
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r7QNe9vs013125
	for <linux-mm@kvack.org>; Tue, 27 Aug 2013 09:40:10 +1000
Date: Tue, 27 Aug 2013 07:40:07 +0800
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH v4 8/10] mm/hwpoison: fix memory failure still hold
 reference count after unpoison empty zero page
Message-ID: <20130826234007.GA15608@hacker.(null)>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
References: <1377506774-5377-1-git-send-email-liwanp@linux.vnet.ibm.com>
 <1377506774-5377-8-git-send-email-liwanp@linux.vnet.ibm.com>
 <1377531937-15nx3q8e-mutt-n-horiguchi@ah.jp.nec.com>
 <521be416.a5e8420a.6786.09d1SMTPIN_ADDED_BROKEN@mx.google.com>
 <20130826163150.72bb773c.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130826163150.72bb773c.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Andi Kleen <andi@firstfloor.org>, Fengguang Wu <fengguang.wu@intel.com>, Tony Luck <tony.luck@intel.com>, gong.chen@linux.intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi Andrew,
On Mon, Aug 26, 2013 at 04:31:50PM -0700, Andrew Morton wrote:
>On Tue, 27 Aug 2013 07:26:04 +0800 Wanpeng Li <liwanp@linux.vnet.ibm.com> wrote:
>
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
>> 
>> Hi Andrew,
>> 
>> I see you have already merged the patch, which method you prefer? 
>> 
>
>Addressing it within the madvise code does sound more appropriate.  The
>change which
>mm-hwpoison-fix-memory-failure-still-holding-reference-count-after-unpoisoning-empty-zero-page.patch
>makes is pretty darn strange-looking at at least needs a comment
>telling people what it's doing, and why.

Thanks for your great point out. ;-)
I will address it within the madvise code and resend patch 8/10 ~ patch 10/10.

Regards,
Wanpeng Li 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
