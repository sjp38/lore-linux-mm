Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id F12AE6B025E
	for <linux-mm@kvack.org>; Wed, 23 Nov 2016 01:39:01 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id 17so5451649pfy.2
        for <linux-mm@kvack.org>; Tue, 22 Nov 2016 22:39:01 -0800 (PST)
Received: from out4433.biz.mail.alibaba.com (out4433.biz.mail.alibaba.com. [47.88.44.33])
        by mx.google.com with ESMTP id f1si3766079plb.119.2016.11.22.22.38.59
        for <linux-mm@kvack.org>;
        Tue, 22 Nov 2016 22:39:01 -0800 (PST)
Reply-To: "Hillf Danton" <hillf.zj@alibaba-inc.com>
From: "Hillf Danton" <hillf.zj@alibaba-inc.com>
References: <1478115245-32090-16-git-send-email-aarcange@redhat.com> <074501d235bb$3766dbd0$a6349370$@alibaba-inc.com> <c9c59023-35ee-1012-1da7-13c3aa89ba61@oracle.com> <31d06dc7-ea2d-4ca3-821a-f14ea69de3e9@oracle.com> <20161104193626.GU4611@redhat.com> <1805f956-1777-471c-1401-46c984189c88@oracle.com> <20161116182809.GC26185@redhat.com> <8ee2c6db-7ee4-285f-4c68-75fd6e799c0d@oracle.com> <20161117154031.GA10229@redhat.com> <718434af-d279-445d-e210-201bf02f434f@oracle.com> <20161118000527.GB10229@redhat.com> <c9350efa-ca79-c514-0305-22c90fdbb0df@oracle.com> <1b60f0b3-835f-92d6-33e2-e7aaab3209cc@oracle.com>
In-Reply-To: <1b60f0b3-835f-92d6-33e2-e7aaab3209cc@oracle.com>
Subject: Re: [PATCH 15/33] userfaultfd: hugetlbfs: add __mcopy_atomic_hugetlb for huge page UFFDIO_COPY
Date: Wed, 23 Nov 2016 14:38:37 +0800
Message-ID: <019d01d24554$38e7f220$aab7d660$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Mike Kravetz' <mike.kravetz@oracle.com>, 'Andrea Arcangeli' <aarcange@redhat.com>
Cc: 'Andrew Morton' <akpm@linux-foundation.org>, linux-mm@kvack.org, "'Dr. David Alan Gilbert'" <dgilbert@redhat.com>, 'Shaohua Li' <shli@fb.com>, 'Pavel Emelyanov' <xemul@parallels.com>, 'Mike Rapoport' <rppt@linux.vnet.ibm.com>

On Tuesday, November 22, 2016 9:17 AM Mike Kravetz wrote:
> I am not sure if you are convinced ClearPagePrivate is an acceptable
> solution to this issue.  If you do, here is the simple patch to add
> it and an appropriate comment.
> 
Hi Mike and Andrea

Sorry for my jumping in.

In commit 07443a85ad
("mm, hugetlb: return a reserved page to a reserved pool if failed")
newly allocated huge page gets cleared for a successful COW.

I'm wondering if we can handle our error path along that way?

Obvious I could miss the points you are concerning.

thanks
Hillf
> 
> If __mcopy_atomic_hugetlb exits with an error, put_page will be called
> if a huge page was allocated and needs to be freed.  If a reservation
> was associated with the huge page, the PagePrivate flag will be set.
> Clear PagePrivate before calling put_page/free_huge_page so that the
> global reservation count is not incremented.
> 
> Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
> ---
>  mm/userfaultfd.c | 17 ++++++++++++++++-
>  1 file changed, 16 insertions(+), 1 deletion(-)
> 
> diff --git a/mm/userfaultfd.c b/mm/userfaultfd.c
> index b565481..d56ba83 100644
> --- a/mm/userfaultfd.c
> +++ b/mm/userfaultfd.c
> @@ -303,8 +303,23 @@ static __always_inline ssize_t __mcopy_atomic_hugetlb(struct mm_struct *dst_mm,
>  out_unlock:
>  	up_read(&dst_mm->mmap_sem);
>  out:
> -	if (page)
> +	if (page) {
> +		/*
> +		 * We encountered an error and are about to free a newly
> +		 * allocated huge page.  It is possible that there was a
> +		 * reservation associated with the page that has been
> +		 * consumed.  See the routine restore_reserve_on_error
> +		 * for details.  Unfortunately, we can not call
> +		 * restore_reserve_on_error now as it would require holding
> +		 * mmap_sem.  Clear the PagePrivate flag so that the global
> +		 * reserve count will not be incremented in free_huge_page.
> +		 * The reservation map will still indicate the reservation
> +		 * was consumed and possibly prevent later page allocation.
> +		 * This is better than leaking a global reservation.
> +		 */
> +		ClearPagePrivate(page);
>  		put_page(page);
> +	}
>  	BUG_ON(copied < 0);
>  	BUG_ON(err > 0);
>  	BUG_ON(!copied && !err);
> --
> 2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
