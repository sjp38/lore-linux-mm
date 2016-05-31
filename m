Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f69.google.com (mail-vk0-f69.google.com [209.85.213.69])
	by kanga.kvack.org (Postfix) with ESMTP id F30126B025E
	for <linux-mm@kvack.org>; Tue, 31 May 2016 02:51:04 -0400 (EDT)
Received: by mail-vk0-f69.google.com with SMTP id w185so238134420vkf.3
        for <linux-mm@kvack.org>; Mon, 30 May 2016 23:51:04 -0700 (PDT)
Received: from e38.co.us.ibm.com (e38.co.us.ibm.com. [32.97.110.159])
        by mx.google.com with ESMTPS id a75si30069148qhb.113.2016.05.30.23.51.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Mon, 30 May 2016 23:51:04 -0700 (PDT)
Received: from localhost
	by e38.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Tue, 31 May 2016 00:51:03 -0600
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [RFC PATCH 2/4] mm: Change the interface for __tlb_remove_page
In-Reply-To: <002b01d1baef$e6246530$b26d2f90$@alibaba-inc.com>
References: <001701d1ba44$b9c0d560$2d428020$@alibaba-inc.com> <001901d1ba4a$514eccc0$f3ec6640$@alibaba-inc.com> <87mvn71rwc.fsf@skywalker.in.ibm.com> <002b01d1baef$e6246530$b26d2f90$@alibaba-inc.com>
Date: Tue, 31 May 2016 12:20:49 +0530
Message-ID: <87h9de201i.fsf@skywalker.in.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <hillf.zj@alibaba-inc.com>
Cc: 'linux-kernel' <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

Hillf Danton <hillf.zj@alibaba-inc.com> writes:

>> >> @@ -1202,7 +1205,12 @@ again:
>> >>  	if (force_flush) {
>> >>  		force_flush = 0;
>> >>  		tlb_flush_mmu_free(tlb);
>> >> -
>> >> +		if (pending_page) {
>> >> +			/* remove the page with new size */
>> >> +			__tlb_adjust_range(tlb, tlb->addr);
>> >
>> > Would you please specify why tlb->addr is used here?
>> >
>> 
>> That is needed because tlb_flush_mmu_tlbonly() does a __tlb_reset_range().
>> 
> If ->addr is updated in resetting, then it is a noop here to deliver tlb->addr to
> __tlb_adjust_range().
> On the other hand, if ->addr is not updated in resetting, then it is also a noop here.
>
> Do you want to update ->addr here?
>

I don't get that question. We wanted to track the alst adjusted addr in
tlb->addr because when we do a tlb_flush_mmu_tlbonly() we does a
__tlb_reset_range(), which clears tlb->start and tlb->end. Now we need
to update the range again with the last adjusted addr before we can call
__tlb_remove_page(). Look for VM_BUG_ON(!tlb->end); in
__tlb_remove_page().

-aneesh


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
