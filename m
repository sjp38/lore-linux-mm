Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f52.google.com (mail-oi0-f52.google.com [209.85.218.52])
	by kanga.kvack.org (Postfix) with ESMTP id 9C74D6B0038
	for <linux-mm@kvack.org>; Fri,  7 Aug 2015 05:28:13 -0400 (EDT)
Received: by oiev193 with SMTP id v193so22604810oie.3
        for <linux-mm@kvack.org>; Fri, 07 Aug 2015 02:28:13 -0700 (PDT)
Received: from BLU004-OMC1S29.hotmail.com (blu004-omc1s29.hotmail.com. [65.55.116.40])
        by mx.google.com with ESMTPS id 194si6874626oif.69.2015.08.07.02.28.12
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 07 Aug 2015 02:28:12 -0700 (PDT)
Message-ID: <BLU436-SMTP77121C8FEC4887D613BDF180730@phx.gbl>
Subject: Re: [PATCH] mm/hwpoison: fix page refcount of unkown non LRU page
References: <BLU436-SMTP128848C012F916D3DFC86B80740@phx.gbl>
 <20150807074612.GA8014@hori1.linux.bs1.fc.nec.co.jp>
From: Wanpeng Li <wanpeng.li@hotmail.com>
Date: Fri, 7 Aug 2015 17:28:00 +0800
MIME-Version: 1.0
In-Reply-To: <20150807074612.GA8014@hori1.linux.bs1.fc.nec.co.jp>
Content-Type: text/plain; charset="iso-2022-jp"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>, Tony Luck <tony.luck@intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>



On 8/7/15 3:46 PM, Naoya Horiguchi wrote:
> On Thu, Aug 06, 2015 at 04:09:37PM +0800, Wanpeng Li wrote:
>> After try to drain pages from pagevec/pageset, we try to get reference
>> count of the page again, however, the reference count of the page is 
>> not reduced if the page is still not on LRU list. This patch fix it by 
>> adding the put_page() to drop the page reference which is from 
>> __get_any_page().
>>
>> Signed-off-by: Wanpeng Li <wanpeng.li@hotmail.com> 
> This fix is correct. Thanks you for catching this, Wanpeng!
>
> Acked-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

Thanks, :)

>
> BTW, I think this patch is worth sending to stable tree. It seems that
> the latest change around this code is given by the following commit:
>
>   commit af8fae7c08862bb85c5cf445bf9b36314b82111f
>   Author: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
>   Date:   Fri Feb 22 16:34:03 2013 -0800
>   
>       mm/memory-failure.c: clean up soft_offline_page()
>
> . I think that this bug existed before this commit, but this patch is
> cleanly applicable only after this patch, so I think tagging
> "Cc: stable@vger.kernel.org # 3.9+" is good.

I will add this in v2.

Regards,
Wanpeng Li

>
> Thanks,
> Naoya Horiguchi
>
>> ---
>>  mm/memory-failure.c |    2 ++
>>  1 files changed, 2 insertions(+), 0 deletions(-)
>>
>> diff --git a/mm/memory-failure.c b/mm/memory-failure.c
>> index c53543d..23163d0 100644
>> --- a/mm/memory-failure.c
>> +++ b/mm/memory-failure.c
>> @@ -1535,6 +1535,8 @@ static int get_any_page(struct page *page, unsigned long pfn, int flags)
>>  		 */
>>  		ret = __get_any_page(page, pfn, 0);
>>  		if (!PageLRU(page)) {
>> +			/* Drop page reference which is from __get_any_page() */
>> +			put_page(page);
>>  			pr_info("soft_offline: %#lx: unknown non LRU page type %lx\n",
>>  				pfn, page->flags);
>>  			return -EIO;
>> -- 
>> 1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
