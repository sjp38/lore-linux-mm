Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id B40A58E0038
	for <linux-mm@kvack.org>; Wed,  9 Jan 2019 00:05:13 -0500 (EST)
Received: by mail-qt1-f199.google.com with SMTP id n39so5506773qtn.18
        for <linux-mm@kvack.org>; Tue, 08 Jan 2019 21:05:13 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id e5si6157414qkd.22.2019.01.08.21.05.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Jan 2019 21:05:13 -0800 (PST)
Date: Wed, 9 Jan 2019 13:05:05 +0800
From: Peter Xu <peterx@redhat.com>
Subject: Re: [PATCH 1/1] mm/hugetlb.c: teach follow_hugetlb_page() to handle
 FOLL_NOWAIT
Message-ID: <20190109050505.GC12837@xz-x1>
References: <20190109020203.26669-1-aarcange@redhat.com>
 <20190109020203.26669-2-aarcange@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20190109020203.26669-2-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mike Rapoport <rppt@linux.vnet.ibm.com>, Mike Kravetz <mike.kravetz@oracle.com>, "Dr. David Alan Gilbert" <dgilbert@redhat.com>

On Tue, Jan 08, 2019 at 09:02:03PM -0500, Andrea Arcangeli wrote:
> hugetlb needs the same fix as faultin_nopage (which was applied in
> 96312e61282ae3f6537a562625706498cbc75594) or KVM hangs because it
> thinks the mmap_sem was already released by hugetlb_fault() if it
> returned VM_FAULT_RETRY, but it wasn't in the FOLL_NOWAIT case.
> 
> Fixes: ce53053ce378 ("kvm: switch get_user_page_nowait() to get_user_pages_unlocked()")
> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
> Tested-by: "Dr. David Alan Gilbert" <dgilbert@redhat.com>
> Reported-by: "Dr. David Alan Gilbert" <dgilbert@redhat.com>

FWIW:

Reviewed-by: Peter Xu <peterx@redhat.com>

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

Regards,

-- 
Peter Xu
