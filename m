Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id BBDCD280260
	for <linux-mm@kvack.org>; Fri,  4 Nov 2016 03:39:44 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id u15so96453706oie.6
        for <linux-mm@kvack.org>; Fri, 04 Nov 2016 00:39:44 -0700 (PDT)
Received: from out4435.biz.mail.alibaba.com (out4435.biz.mail.alibaba.com. [47.88.44.35])
        by mx.google.com with ESMTP id x40si1976104ita.72.2016.11.04.00.39.42
        for <linux-mm@kvack.org>;
        Fri, 04 Nov 2016 00:39:44 -0700 (PDT)
Reply-To: "Hillf Danton" <hillf.zj@alibaba-inc.com>
From: "Hillf Danton" <hillf.zj@alibaba-inc.com>
References: <1478115245-32090-1-git-send-email-aarcange@redhat.com> <1478115245-32090-21-git-send-email-aarcange@redhat.com>
In-Reply-To: <1478115245-32090-21-git-send-email-aarcange@redhat.com>
Subject: Re: [PATCH 20/33] userfaultfd: introduce vma_can_userfault
Date: Fri, 04 Nov 2016 15:39:21 +0800
Message-ID: <07b501d2366e$8ee8ce50$acba6af0$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Andrea Arcangeli' <aarcange@redhat.com>, 'Andrew Morton' <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, 'Mike Kravetz' <mike.kravetz@oracle.com>, "'Dr. David Alan Gilbert'" <dgilbert@redhat.com>, 'Shaohua Li' <shli@fb.com>, 'Pavel Emelyanov' <xemul@parallels.com>, 'Mike Rapoport' <rppt@linux.vnet.ibm.com>

> 
> From: Mike Rapoport <rppt@linux.vnet.ibm.com>
> 
> Check whether a VMA can be used with userfault in more compact way
> 
> Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
> ---
Acked-by: Hillf Danton <hillf.zj@alibaba-inc.com> 

>  fs/userfaultfd.c | 13 +++++++++----
>  1 file changed, 9 insertions(+), 4 deletions(-)
> 
> diff --git a/fs/userfaultfd.c b/fs/userfaultfd.c
> index 9552734..387fe77 100644
> --- a/fs/userfaultfd.c
> +++ b/fs/userfaultfd.c
> @@ -1060,6 +1060,11 @@ static __always_inline int validate_range(struct mm_struct *mm,
>  	return 0;
>  }
> 
> +static inline bool vma_can_userfault(struct vm_area_struct *vma)
> +{
> +	return vma_is_anonymous(vma) || is_vm_hugetlb_page(vma);
> +}
> +
>  static int userfaultfd_register(struct userfaultfd_ctx *ctx,
>  				unsigned long arg)
>  {
> @@ -1149,7 +1154,7 @@ static int userfaultfd_register(struct userfaultfd_ctx *ctx,
> 
>  		/* check not compatible vmas */
>  		ret = -EINVAL;
> -		if (!vma_is_anonymous(cur) && !is_vm_hugetlb_page(cur))
> +		if (!vma_can_userfault(cur))
>  			goto out_unlock;
>  		/*
>  		 * If this vma contains ending address, and huge pages
> @@ -1193,7 +1198,7 @@ static int userfaultfd_register(struct userfaultfd_ctx *ctx,
>  	do {
>  		cond_resched();
> 
> -		BUG_ON(!vma_is_anonymous(vma) && !is_vm_hugetlb_page(vma));
> +		BUG_ON(!vma_can_userfault(vma));
>  		BUG_ON(vma->vm_userfaultfd_ctx.ctx &&
>  		       vma->vm_userfaultfd_ctx.ctx != ctx);
> 
> @@ -1331,7 +1336,7 @@ static int userfaultfd_unregister(struct userfaultfd_ctx *ctx,
>  		 * provides for more strict behavior to notice
>  		 * unregistration errors.
>  		 */
> -		if (!vma_is_anonymous(cur) && !is_vm_hugetlb_page(cur))
> +		if (!vma_can_userfault(cur))
>  			goto out_unlock;
> 
>  		found = true;
> @@ -1345,7 +1350,7 @@ static int userfaultfd_unregister(struct userfaultfd_ctx *ctx,
>  	do {
>  		cond_resched();
> 
> -		BUG_ON(!vma_is_anonymous(vma) && !is_vm_hugetlb_page(vma));
> +		BUG_ON(!vma_can_userfault(vma));
> 
>  		/*
>  		 * Nothing to do: this vma is already registered into this
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
