Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 7FE866B027A
	for <linux-mm@kvack.org>; Fri, 28 Oct 2016 04:30:48 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id e6so16643655pfk.2
        for <linux-mm@kvack.org>; Fri, 28 Oct 2016 01:30:48 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id fv1si275130pad.7.2016.10.28.01.30.47
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 28 Oct 2016 01:30:47 -0700 (PDT)
From: "Huang\, Ying" <ying.huang@intel.com>
Subject: Re: [PATCH -v4 RESEND 6/9] mm, THP, swap: Support to add/delete THP to/from swap cache
References: <20161028055608.1736-1-ying.huang@intel.com>
	<20161028055608.1736-7-ying.huang@intel.com>
	<050a01d230f2$826f0b20$874d2160$@alibaba-inc.com>
Date: Fri, 28 Oct 2016 16:30:43 +0800
In-Reply-To: <050a01d230f2$826f0b20$874d2160$@alibaba-inc.com> (Hillf Danton's
	message of "Fri, 28 Oct 2016 16:08:46 +0800")
Message-ID: <87lgx87u4s.fsf@yhuang-dev.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <hillf.zj@alibaba-inc.com>
Cc: "'Huang, Ying'" <ying.huang@intel.com>, 'Andrew Morton' <akpm@linux-foundation.org>, tim.c.chen@intel.com, dave.hansen@intel.com, andi.kleen@intel.com, aaron.lu@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, 'Hugh Dickins' <hughd@google.com>, 'Shaohua Li' <shli@kernel.org>, 'Minchan Kim' <minchan@kernel.org>, 'Rik van Riel' <riel@redhat.com>, 'Andrea Arcangeli' <aarcange@redhat.com>, "'Kirill A . Shutemov'" <kirill.shutemov@linux.intel.com>

Hi, Hillf,

Hillf Danton <hillf.zj@alibaba-inc.com> writes:

> On Friday, October 28, 2016 1:56 PM Huang, Ying wrote:
>> 
>> @@ -109,9 +118,16 @@ int __add_to_swap_cache(struct page *page, swp_entry_t entry)
>>  		 * So add_to_swap_cache() doesn't returns -EEXIST.
>>  		 */
>>  		VM_BUG_ON(error == -EEXIST);
>> -		set_page_private(page, 0UL);
>>  		ClearPageSwapCache(page);
>> -		put_page(page);
>> +		set_page_private(cur_page, 0UL);
>> +		while (i--) {
>> +			cur_page--;
>> +			cur_entry.val--;
>> +			set_page_private(cur_page, 0UL);
>> +			radix_tree_delete(&address_space->page_tree,
>> +					  swp_offset(cur_entry));
>> +		}
>
> Pull pages out of radix tree with tree lock held?

OOPS, I should hold the tree lock for the error path too.  Will update
it in the next version.  Thanks for pointing out this!

Best Regards,
Huang, Ying


>> +		page_ref_sub(page, nr);
>>  	}
>> 
>>  	return error;
>> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
