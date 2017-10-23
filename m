Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 9594B6B0033
	for <linux-mm@kvack.org>; Mon, 23 Oct 2017 14:20:24 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id j58so15592505qtj.7
        for <linux-mm@kvack.org>; Mon, 23 Oct 2017 11:20:24 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id p81si64552qkl.397.2017.10.23.11.20.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 Oct 2017 11:20:23 -0700 (PDT)
Subject: Re: [PATCH 1/1] mm:hugetlbfs: Fix hwpoison reserve accounting
References: <20171019230007.17043-1-mike.kravetz@oracle.com>
 <20171019230007.17043-2-mike.kravetz@oracle.com>
 <20171020023019.GA9318@hori1.linux.bs1.fc.nec.co.jp>
 <5016e528-8ea9-7597-3420-086ae57f3d9d@oracle.com>
 <20171023073258.GA5115@hori1.linux.bs1.fc.nec.co.jp>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <26945734-ac7e-f71e-dbfa-0b0f0fdaff32@oracle.com>
Date: Mon, 23 Oct 2017 11:20:02 -0700
MIME-Version: 1.0
In-Reply-To: <20171023073258.GA5115@hori1.linux.bs1.fc.nec.co.jp>
Content-Type: text/plain; charset=iso-2022-jp
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@kernel.org>, Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, "stable@vger.kernel.org" <stable@vger.kernel.org>

On 10/23/2017 12:32 AM, Naoya Horiguchi wrote:
> On Fri, Oct 20, 2017 at 10:49:46AM -0700, Mike Kravetz wrote:
>> On 10/19/2017 07:30 PM, Naoya Horiguchi wrote:
>>> On Thu, Oct 19, 2017 at 04:00:07PM -0700, Mike Kravetz wrote:
>>>
>>> Thank you for addressing this. The patch itself looks good to me, but
>>> the reported issue (negative reserve count) doesn't reproduce in my trial
>>> with v4.14-rc5, so could you share the exact procedure for this issue?
>>
>> Sure, but first one question on your test scenario below.
>>
>>>
>>> When error handler runs over a huge page, the reserve count is incremented
>>> so I'm not sure why the reserve count goes negative.
>>
>> I'm not sure I follow.  What specific code is incrementing the reserve
>> count?
> 
> The call path is like below:
> 
>   hugetlbfs_error_remove_page
>     hugetlb_fix_reserve_counts
>       hugepage_subpool_get_pages(spool, 1)
>         hugetlb_acct_memory(h, 1);
>           gather_surplus_pages
>             h->resv_huge_pages += delta;
> 

Ah OK.  This is a result of call to hugetlb_fix_reserve_counts which
I believe is incorrect in most instances, and is unlikely to happen 
with my patch.

>>
>> Remove the file (rm /var/opt/oracle/hugepool/foo)
>> -------------------------------------------------
>> HugePages_Total:       1
>> HugePages_Free:        0
>> HugePages_Rsvd:    18446744073709551615
>> HugePages_Surp:        0
>> Hugepagesize:       2048 kB
>>
>> I am still confused about how your test maintains a reserve count after
>> poisoning.  It may be a good idea for you to test my patch with your
>> test scenario as I can not recreate here.
> 
> Interestingly, I found that this reproduces if all hugetlb pages are
> reserved when poisoning.
> Your testing meets the condition, and mine doesn't.
> 
> In gather_surplus_pages() we determine whether we extend hugetlb pool
> with surplus pages like below:
> 
>     needed = (h->resv_huge_pages + delta) - h->free_huge_pages;
>     if (needed <= 0) {
>             h->resv_huge_pages += delta;
>             return 0;
>     }
>     ...
> 
> needed is 1 if h->resv_huge_pages == h->free_huge_pages, and then
> the reserve count gets inconsistent.
> I confirmed that your patch fixes the issue, so I'm OK with it.

Thanks.  That now makes sense to me.

hugetlb_fix_reserve_counts (which results in gather_surplus_pages being
called), is only designed to be called in the extremely rare cases when
we have free'ed a huge page but are unable to free the reservation entry.

Just curious, when the hugetlb_fix_reserve_counts call was added to
hugetlbfs_error_remove_page, was the intention to preserve the original
reservation?  I remember thinking hard about that for the hole punch
case and came to the conclusion that it was easier and less error prone
to remove the reservation as well.  That will also happen in the error
case with the patch I provided.

-- 
Mike Kravetz

> 
> Acked-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> 
> Thanks,
> Naoya Horiguchi
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
