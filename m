Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 88FFC6B0279
	for <linux-mm@kvack.org>; Wed, 24 May 2017 07:53:21 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id r203so37838833wmb.2
        for <linux-mm@kvack.org>; Wed, 24 May 2017 04:53:21 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 31si18272015edq.171.2017.05.24.04.53.20
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 24 May 2017 04:53:20 -0700 (PDT)
Subject: Re: [Question] Mlocked count will not be decreased
References: <a61701d8-3dce-51a2-5eaf-14de84425640@huawei.com>
 <85591559-2a99-f46b-7a5a-bc7affb53285@huawei.com>
 <93f1b063-6288-d109-117d-d3c1cf152a8e@suse.cz> <5925709F.1030105@huawei.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <d354b321-0d11-4308-0b0e-aacef5a5e34b@suse.cz>
Date: Wed, 24 May 2017 13:52:44 +0200
MIME-Version: 1.0
In-Reply-To: <5925709F.1030105@huawei.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>
Cc: Yisheng Xie <xieyisheng1@huawei.com>, Kefeng Wang <wangkefeng.wang@huawei.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, zhongjiang <zhongjiang@huawei.com>

On 05/24/2017 01:38 PM, Xishi Qiu wrote:
>>
>> Race condition with what? Who else would isolate our pages?
>>
> 
> Hi Vlastimil,
> 
> I find the root cause, if the page was not cached on the current cpu,
> lru_add_drain() will not push it to LRU. So we should handle fail
> case in mlock_vma_page().

Yeah that would explain it.

> follow_page_pte()
> 		...
> 		if (page->mapping && trylock_page(page)) {
> 			lru_add_drain();  /* push cached pages to LRU */
> 			/*
> 			 * Because we lock page here, and migration is
> 			 * blocked by the pte's page reference, and we
> 			 * know the page is still mapped, we don't even
> 			 * need to check for file-cache page truncation.
> 			 */
> 			mlock_vma_page(page);
> 			unlock_page(page);
> 		}
> 		...
> 
> I think we should add yisheng's patch, also we should add the following change.
> I think it is better than use lru_add_drain_all().

I agree about yisheng's fix (but v2 didn't address my comments). I don't
think we should add the hunk below, as that deviates from the rest of
the design.

Thanks,
Vlastimil

> diff --git a/mm/mlock.c b/mm/mlock.c
> index 3d3ee6c..ca2aeb9 100644
> --- a/mm/mlock.c
> +++ b/mm/mlock.c
> @@ -88,6 +88,11 @@ void mlock_vma_page(struct page *page)
>  		count_vm_event(UNEVICTABLE_PGMLOCKED);
>  		if (!isolate_lru_page(page))
>  			putback_lru_page(page);
> +		else {
> +			ClearPageMlocked(page);
> +			mod_zone_page_state(page_zone(page), NR_MLOCK,
> +					-hpage_nr_pages(page));
> +		}
>  	}
>  }
> 
> Thanks,
> Xishi Qiu
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
