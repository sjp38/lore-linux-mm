Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id 6323A6B0038
	for <linux-mm@kvack.org>; Thu,  8 Sep 2016 14:10:42 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id vp2so116064066pab.3
        for <linux-mm@kvack.org>; Thu, 08 Sep 2016 11:10:42 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id sm1si31225312pab.168.2016.09.08.11.10.41
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 08 Sep 2016 11:10:41 -0700 (PDT)
From: "Huang\, Ying" <ying.huang@intel.com>
Subject: Re: [PATCH -v3 07/10] mm, THP, swap: Support to add/delete THP to/from swap cache
References: <1473266769-2155-1-git-send-email-ying.huang@intel.com>
	<1473266769-2155-8-git-send-email-ying.huang@intel.com>
	<57D128A9.3030306@linux.vnet.ibm.com>
Date: Thu, 08 Sep 2016 11:10:38 -0700
In-Reply-To: <57D128A9.3030306@linux.vnet.ibm.com> (Anshuman Khandual's
	message of "Thu, 8 Sep 2016 14:30:25 +0530")
Message-ID: <8760q65kkh.fsf@yhuang-mobile.sh.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: "Huang, Ying" <ying.huang@intel.com>, Andrew Morton <akpm@linux-foundation.org>, tim.c.chen@intel.com, dave.hansen@intel.com, andi.kleen@intel.com, aaron.lu@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Shaohua Li <shli@kernel.org>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>

Hi, Anshuman,

Thanks for comments!

Anshuman Khandual <khandual@linux.vnet.ibm.com> writes:

> On 09/07/2016 10:16 PM, Huang, Ying wrote:
>> From: Huang Ying <ying.huang@intel.com>
>> 
>> With this patch, a THP (Transparent Huge Page) can be added/deleted
>> to/from the swap cache as a set of sub-pages (512 on x86_64).
>> 
>> This will be used for the THP (Transparent Huge Page) swap support.
>> Where one THP may be added/delted to/from the swap cache.  This will
>> batch the swap cache operations to reduce the lock acquire/release times
>> for the THP swap too.
>> 
>> Cc: Hugh Dickins <hughd@google.com>
>> Cc: Shaohua Li <shli@kernel.org>
>> Cc: Minchan Kim <minchan@kernel.org>
>> Cc: Rik van Riel <riel@redhat.com>
>> Cc: Andrea Arcangeli <aarcange@redhat.com>
>> Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
>> Signed-off-by: "Huang, Ying" <ying.huang@intel.com>
>> ---
>>  include/linux/page-flags.h |  2 +-
>>  mm/swap_state.c            | 57 +++++++++++++++++++++++++++++++---------------
>>  2 files changed, 40 insertions(+), 19 deletions(-)
>> 
>> diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
>> index 74e4dda..f5bcbea 100644
>> --- a/include/linux/page-flags.h
>> +++ b/include/linux/page-flags.h
>> @@ -314,7 +314,7 @@ PAGEFLAG_FALSE(HighMem)
>>  #endif
>>  
>>  #ifdef CONFIG_SWAP
>> -PAGEFLAG(SwapCache, swapcache, PF_NO_COMPOUND)
>> +PAGEFLAG(SwapCache, swapcache, PF_NO_TAIL)
>
> What is the reason for this change ? The commit message does not seem
> to explain.

Before this change, SetPageSwapCache() cannot be called for THP, after
the change, SetPageSwapCache() could be called for the head page of the
THP, but not the tail pages.  Because we will never do that before this
patch series.

Best Regards,
Huang, Ying

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
