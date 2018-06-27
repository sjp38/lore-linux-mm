Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5BF306B000A
	for <linux-mm@kvack.org>; Wed, 27 Jun 2018 19:27:31 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id n10-v6so3405886qtp.11
        for <linux-mm@kvack.org>; Wed, 27 Jun 2018 16:27:31 -0700 (PDT)
Received: from aserp2120.oracle.com (aserp2120.oracle.com. [141.146.126.78])
        by mx.google.com with ESMTPS id g6-v6si2447414qth.312.2018.06.27.16.27.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Jun 2018 16:27:30 -0700 (PDT)
Subject: Re: [PATCH] mm: hugetlb: yield when prepping struct pages
References: <20180627214447.260804-1-cannonmatthews@google.com>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <89c34814-ee1a-6339-1daf-fff02ce947e5@oracle.com>
Date: Wed, 27 Jun 2018 16:27:24 -0700
MIME-Version: 1.0
In-Reply-To: <20180627214447.260804-1-cannonmatthews@google.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cannon Matthews <cannonmatthews@google.com>, Andrew Morton <akpm@linux-foundation.org>, Nadia Yvette Chambers <nyc@holomorphy.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, andreslc@google.com, pfeiner@google.com, gthelen@google.com

On 06/27/2018 02:44 PM, Cannon Matthews wrote:
> When booting with very large numbers of gigantic (i.e. 1G) pages, the
> operations in the loop of gather_bootmem_prealloc, and specifically
> prep_compound_gigantic_page, takes a very long time, and can cause a
> softlockup if enough pages are requested at boot.
> 
> For example booting with 3844 1G pages requires prepping

Wow!  I wish I had a system with that much memory to test. :)

> (set_compound_head, init the count) over 1 billion 4K tail pages, which
> takes considerable time. This should also apply to reserving the same
> amount of memory as 2M pages, as the same number of struct pages
> are affected in either case.

Actually, this change would not apply to 2M (on x86) pages.  The hugetlbfs
initialization code is a bit confusing, but alloc_bootmem_huge_page and
gather_bootmem_prealloc are only exercised in the case where huge page
order >= MAX_ORDER.

Allocation and initialization of 2M pages happens after the normal memory
allocators are setup via the routine hugetlb_hstate_alloc_pages.  And,
there is already a cond_resched in that loop today.

Note that 'else if' in the for loop of hugetlb_hstate_alloc_pages.  This
allows the same routine to be called for early gigantic page allocations
using the bootmem allocator, and later normal (2M) allocations using the
normal memory allocators.  To me, this is a source of confusion and is
something I plan to clean up in the future.

> Add a cond_resched() to the outer loop in gather_bootmem_prealloc() to
> prevent this lockup.
> 
> Tested: Booted with softlockup_panic=1 hugepagesz=1G hugepages=3844 and
> no softlockup is reported, and the hugepages are reported as
> successfully setup.
> 
> Signed-off-by: Cannon Matthews <cannonmatthews@google.com>

My only suggestion would be to remove the mention of 2M pages in the
commit message.  Thanks for adding this.

Reviewed-by: Mike Kravetz <mike.kravetz@oracle.com>
-- 
Mike Kravetz

> ---
>  mm/hugetlb.c | 1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index a963f2034dfc..d38273c32d3b 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -2169,6 +2169,7 @@ static void __init gather_bootmem_prealloc(void)
>  		 */
>  		if (hstate_is_gigantic(h))
>  			adjust_managed_page_count(page, 1 << h->order);
> +		cond_resched();
>  	}
>  }
>  
> 
