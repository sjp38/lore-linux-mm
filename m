Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb1-f198.google.com (mail-yb1-f198.google.com [209.85.219.198])
	by kanga.kvack.org (Postfix) with ESMTP id D0FB78E0038
	for <linux-mm@kvack.org>; Tue,  8 Jan 2019 21:53:05 -0500 (EST)
Received: by mail-yb1-f198.google.com with SMTP id y16so2976998ybk.2
        for <linux-mm@kvack.org>; Tue, 08 Jan 2019 18:53:05 -0800 (PST)
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id 204si43234428ywi.272.2019.01.08.18.53.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Jan 2019 18:53:04 -0800 (PST)
Subject: Re: [PATCH 1/1] mm/hugetlb.c: teach follow_hugetlb_page() to handle
 FOLL_NOWAIT
References: <20190109020203.26669-1-aarcange@redhat.com>
 <20190109020203.26669-2-aarcange@redhat.com>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <c15462f3-f901-a624-8174-400d331c45bc@oracle.com>
Date: Tue, 8 Jan 2019 18:53:00 -0800
MIME-Version: 1.0
In-Reply-To: <20190109020203.26669-2-aarcange@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mike Rapoport <rppt@linux.vnet.ibm.com>, Peter Xu <peterx@redhat.com>, "Dr. David Alan Gilbert" <dgilbert@redhat.com>

On 1/8/19 6:02 PM, Andrea Arcangeli wrote:
> hugetlb needs the same fix as faultin_nopage (which was applied in
> 96312e61282ae3f6537a562625706498cbc75594) or KVM hangs because it
> thinks the mmap_sem was already released by hugetlb_fault() if it
> returned VM_FAULT_RETRY, but it wasn't in the FOLL_NOWAIT case.
> 
> Fixes: ce53053ce378 ("kvm: switch get_user_page_nowait() to get_user_pages_unlocked()")
> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
> Tested-by: "Dr. David Alan Gilbert" <dgilbert@redhat.com>
> Reported-by: "Dr. David Alan Gilbert" <dgilbert@redhat.com>

Thanks for fixing this.

Reviewed-by: Mike Kravetz <mike.kravetz@oracle.com>
-- 
Mike Kravetz

> ---
>  mm/hugetlb.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index e37efd5d8318..b3622d7888c8 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -4301,7 +4301,8 @@ long follow_hugetlb_page(struct mm_struct *mm, struct vm_area_struct *vma,
>  				break;
>  			}
>  			if (ret & VM_FAULT_RETRY) {
> -				if (nonblocking)
> +				if (nonblocking &&
> +				    !(fault_flags & FAULT_FLAG_RETRY_NOWAIT))
>  					*nonblocking = 0;
>  				*nr_pages = 0;
>  				/*
> 
