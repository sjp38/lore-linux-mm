Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 39D0E6B0006
	for <linux-mm@kvack.org>; Fri, 20 Jul 2018 03:53:03 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id g12-v6so7800340ioh.5
        for <linux-mm@kvack.org>; Fri, 20 Jul 2018 00:53:03 -0700 (PDT)
Received: from huawei.com (szxga05-in.huawei.com. [45.249.212.191])
        by mx.google.com with ESMTPS id b6-v6si874681jal.13.2018.07.20.00.53.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 20 Jul 2018 00:53:01 -0700 (PDT)
Subject: Re: [RFC] a question about reuse hwpoison page in soft_offline_page()
References: <99235479-716d-4c40-8f61-8e44c242abf8.xishi.qiuxishi@alibaba-inc.com>
 <20180706081847.GA5144@hori1.linux.bs1.fc.nec.co.jp>
From: Xie XiuQi <xiexiuqi@huawei.com>
Message-ID: <7f0ff90d-578b-2096-92c0-542a490b06a1@huawei.com>
Date: Fri, 20 Jul 2018 15:50:26 +0800
MIME-Version: 1.0
In-Reply-To: <20180706081847.GA5144@hori1.linux.bs1.fc.nec.co.jp>
Content-Type: text/plain; charset="iso-2022-jp"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, =?UTF-8?B?6KOY56iA55+zKOeogOefsyk=?= <xishi.qiuxishi@alibaba-inc.com>
Cc: linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, "zy.zhengyi" <zy.zhengyi@alibaba-inc.com>, "Zhangfei (Tyler)" <tyler.zhang@huawei.com>, lvzhipeng@huawei.com, meinanjing@huawei.com, Zhong Jiang <zhongjiang@huawei.com>

Hi Naoya, Xishi,

We have a similar problem.
@zhangfei, could you please describe your problem here.

On 2018/7/6 16:18, Naoya Horiguchi wrote:
> On Fri, Jul 06, 2018 at 11:37:41AM +0800, 裘稀石(稀石) wrote:
>> This patch add05cec
>> (mm: soft-offline: don't free target page in successful page migration) removes
>> set_migratetype_isolate() and unset_migratetype_isolate() in soft_offline_page
>> ().
>>
>> And this patch 243abd5b
>> (mm: hugetlb: prevent reuse of hwpoisoned free hugepages) changes
>> if (!is_migrate_isolate_page(page)) to if (!PageHWPoison(page)), so it could
>> prevent someone
>> reuse the free hugetlb again after set the hwpoison flag
>> in soft_offline_free_page()
>>
>> My question is that if someone reuse the free hugetlb again before 
>> soft_offline_free_page() and
>> after get_any_page(), then it uses the hopoison page, and this may trigger mce
>> kill later, right?
> 
> Hi Xishi,
> 
> Thank you for pointing out the issue. That's nice catch.
> 
> I think that the race condition itself could happen, but it doesn't lead
> to MCE kill because PageHWPoison is not visible to HW which triggers MCE.
> PageHWPoison flag is just a flag in struct page to report the memory error
> from kernel to userspace. So even if a CPU is accessing to the page whose
> struct page has PageHWPoison set, that doesn't cause a MCE unless the page
> is physically broken.
> The type of memory error that soft offline tries to handle is corrected
> one which is not a failure yet although it's starting to wear.
> So such PageHWPoison page can be reused, but that's not critical because
> the page is freed at some point afterword and error containment completes.
> 
> However, I noticed that there's a small pain in free hugetlb case.
> We call dissolve_free_huge_page() in soft_offline_free_page() which moves
> the PageHWPoison flag from the head page to the raw error page.
> If the reported race happens, dissolve_free_huge_page() just return without
> doing any dissolve work because "if (PageHuge(page) && !page_count(page))"
> block is skipped.
> The hugepage is allocated and used as usual, but the contaiment doesn't
> complete as expected in the normal page, because free_huge_pages() doesn't
> call dissolve_free_huge_page() for hwpoison hugepage. This is not critical
> because such error hugepage just reside in free hugepage list. But this
> might looks like a kind of memory leak. And even worse when hugepage pool
> is shrinked and the hwpoison hugepage is freed, the PageHWPoison flag is
> still on the head page which is unlikely to be an actual error page.
> 
> So I think we need improvement here, how about the fix like below?
> 
>   (not tested yet, sorry)
> 
>   diff --git a/mm/memory-failure.c b/mm/memory-failure.c
>   --- a/mm/memory-failure.c
>   +++ b/mm/memory-failure.c
>   @@ -1883,6 +1883,11 @@ static void soft_offline_free_page(struct page *page)
>           struct page *head = compound_head(page);
>   
>           if (!TestSetPageHWPoison(head)) {
>   +               if (page_count(head)) {
>   +                       ClearPageHWPoison(head);
>   +                       return;
>   +               }
>   +
>                   num_poisoned_pages_inc();
>                   if (PageHuge(head))
>                           dissolve_free_huge_page(page);
> 
> Thanks,
> Naoya Horiguchi
> 
> .
> 

-- 
Thanks,
Xie XiuQi
