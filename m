Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 610386B0003
	for <linux-mm@kvack.org>; Mon, 13 Aug 2018 19:21:55 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id u19-v6so18714525qkl.13
        for <linux-mm@kvack.org>; Mon, 13 Aug 2018 16:21:55 -0700 (PDT)
Received: from aserp2120.oracle.com (aserp2120.oracle.com. [141.146.126.78])
        by mx.google.com with ESMTPS id k9-v6si4694588qvd.123.2018.08.13.16.21.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 13 Aug 2018 16:21:54 -0700 (PDT)
Subject: Re: [PATCH] mm: migration: fix migration of huge PMD shared pages
References: <20180813034108.27269-1-mike.kravetz@oracle.com>
 <20180813105821.j4tg6iyrdxgwyr3y@kshutemo-mobl1>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <d4cf0f85-e010-36f2-3fae-f7983e4f6505@oracle.com>
Date: Mon, 13 Aug 2018 16:21:41 -0700
MIME-Version: 1.0
In-Reply-To: <20180813105821.j4tg6iyrdxgwyr3y@kshutemo-mobl1>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Davidlohr Bueso <dave@stgolabs.net>, Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>

On 08/13/2018 03:58 AM, Kirill A. Shutemov wrote:
> On Sun, Aug 12, 2018 at 08:41:08PM -0700, Mike Kravetz wrote:
>> The page migration code employs try_to_unmap() to try and unmap the
>> source page.  This is accomplished by using rmap_walk to find all
>> vmas where the page is mapped.  This search stops when page mapcount
>> is zero.  For shared PMD huge pages, the page map count is always 1
>> not matter the number of mappings.  Shared mappings are tracked via
>> the reference count of the PMD page.  Therefore, try_to_unmap stops
>> prematurely and does not completely unmap all mappings of the source
>> page.
>>
>> This problem can result is data corruption as writes to the original
>> source page can happen after contents of the page are copied to the
>> target page.  Hence, data is lost.
>>
>> This problem was originally seen as DB corruption of shared global
>> areas after a huge page was soft offlined.  DB developers noticed
>> they could reproduce the issue by (hotplug) offlining memory used
>> to back huge pages.  A simple testcase can reproduce the problem by
>> creating a shared PMD mapping (note that this must be at least
>> PUD_SIZE in size and PUD_SIZE aligned (1GB on x86)), and using
>> migrate_pages() to migrate process pages between nodes.
>>
>> To fix, have the try_to_unmap_one routine check for huge PMD sharing
>> by calling huge_pmd_unshare for hugetlbfs huge pages.  If it is a
>> shared mapping it will be 'unshared' which removes the page table
>> entry and drops reference on PMD page.  After this, flush caches and
>> TLB.
>>
>> Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
>> ---
>> I am not %100 sure on the required flushing, so suggestions would be
>> appreciated.  This also should go to stable.  It has been around for
>> a long time so still looking for an appropriate 'fixes:'.
> 
> I believe we need flushing. And huge_pmd_unshare() usage in
> __unmap_hugepage_range() looks suspicious: I don't see how we flush TLB in
> that case.

Thanks Kirill,

__unmap_hugepage_range() has two callers:
1) unmap_hugepage_range, which wraps the call with tlb_gather_mmu and
   tlb_finish_mmu on the range.  IIUC, this should cause an appropriate
   TLB flush.
2) __unmap_hugepage_range_final via unmap_single_vma.  unmap_single_vma
  has three callers:
  - unmap_vmas which assumes the caller will flush the whole range after
    return.
  - zap_page_range wraps the call with tlb_gather_mmu/tlb_finish_mmu
  - zap_page_range_single wraps the call with tlb_gather_mmu/tlb_finish_mmu

So, it appears we are covered.  But, I could be missing something.

My primary reason for asking the question was with respect to the code
added to try_to_unmap_one.  In my testing, the changes I added appeared
to be required.  Just wanted to make sure.

I need to fix a build issue and will send another version.
-- 
Mike Kravetz
