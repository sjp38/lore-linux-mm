Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id D29276B0290
	for <linux-mm@kvack.org>; Sun, 30 Oct 2016 21:27:03 -0400 (EDT)
Received: by mail-pa0-f69.google.com with SMTP id fl2so86668488pad.7
        for <linux-mm@kvack.org>; Sun, 30 Oct 2016 18:27:03 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id e17si22225863pgh.24.2016.10.30.18.27.02
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 30 Oct 2016 18:27:03 -0700 (PDT)
From: "Huang\, Ying" <ying.huang@intel.com>
Subject: Re: [PATCH -v4 RESEND 8/9] mm, THP, swap: Support to split THP in swap cache
References: <20161028055608.1736-1-ying.huang@intel.com>
	<20161028055608.1736-9-ying.huang@intel.com>
	<052901d23104$a6473380$f2d59a80$@alibaba-inc.com>
Date: Mon, 31 Oct 2016 09:26:59 +0800
In-Reply-To: <052901d23104$a6473380$f2d59a80$@alibaba-inc.com> (Hillf Danton's
	message of "Fri, 28 Oct 2016 18:18:34 +0800")
Message-ID: <871syx71gc.fsf@yhuang-dev.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <hillf.zj@alibaba-inc.com>
Cc: "'Huang, Ying'" <ying.huang@intel.com>, 'Andrew Morton' <akpm@linux-foundation.org>, tim.c.chen@intel.com, dave.hansen@intel.com, andi.kleen@intel.com, aaron.lu@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, 'Andrea Arcangeli' <aarcange@redhat.com>, "'Kirill A . Shutemov'" <kirill.shutemov@linux.intel.com>, 'Ebru Akagunduz' <ebru.akagunduz@gmail.com>

Hillf Danton <hillf.zj@alibaba-inc.com> writes:

> On Friday, October 28, 2016 1:56 PM Huang, Ying wrote: 
>> @@ -2016,10 +2021,12 @@ int page_trans_huge_mapcount(struct page *page, int *total_mapcount)
>>  /* Racy check whether the huge page can be split */
>>  bool can_split_huge_page(struct page *page)
>>  {
>> -	int extra_pins = 0;
>> +	int extra_pins;
>> 
>>  	/* Additional pins from radix tree */
>> -	if (!PageAnon(page))
>> +	if (PageAnon(page))
>> +		extra_pins = PageSwapCache(page) ? HPAGE_PMD_NR : 0;
>> +	else
>>  		extra_pins = HPAGE_PMD_NR;
>
> extra_pins is computed in this newly added helper.
>
>>  	return total_mapcount(page) == page_count(page) - extra_pins - 1;
>>  }
>> @@ -2072,7 +2079,7 @@ int split_huge_page_to_list(struct page *page, struct list_head *list)
>>  			ret = -EBUSY;
>>  			goto out;
>>  		}
>> -		extra_pins = 0;
>> +		extra_pins = PageSwapCache(head) ? HPAGE_PMD_NR : 0;
>
> It is also computed at the call site, so can we fold them into one?

Sounds reasonable.  I will add another argument to can_split_huge_page()
to return extra_pins, so we can avoid duplicated code and calculation.

Best Regards,
Huang, Ying

>>  		mapping = NULL;
>>  		anon_vma_lock_write(anon_vma);
>>  	} else {
>> --
>> 2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
