Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 5783D6B026E
	for <linux-mm@kvack.org>; Thu, 22 Sep 2016 03:18:09 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id i193so185481760oib.3
        for <linux-mm@kvack.org>; Thu, 22 Sep 2016 00:18:09 -0700 (PDT)
Received: from out4434.biz.mail.alibaba.com (out4434.biz.mail.alibaba.com. [47.88.44.34])
        by mx.google.com with ESMTP id v5si521592ith.37.2016.09.22.00.18.07
        for <linux-mm@kvack.org>;
        Thu, 22 Sep 2016 00:18:08 -0700 (PDT)
Reply-To: "Hillf Danton" <hillf.zj@alibaba-inc.com>
From: "Hillf Danton" <hillf.zj@alibaba-inc.com>
References: <1474492522-2261-1-git-send-email-aarcange@redhat.com> <1474492522-2261-2-git-send-email-aarcange@redhat.com>
In-Reply-To: <1474492522-2261-2-git-send-email-aarcange@redhat.com>
Subject: Re: [PATCH 1/4] mm: vm_page_prot: update with WRITE_ONCE/READ_ONCE
Date: Thu, 22 Sep 2016 15:17:52 +0800
Message-ID: <002e01d214a1$6f39e100$4dada300$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Andrea Arcangeli' <aarcange@redhat.com>, 'Andrew Morton' <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, 'Rik van Riel' <riel@redhat.com>, 'Hugh Dickins' <hughd@google.com>, 'Mel Gorman' <mgorman@techsingularity.net>

Hey Andrea
> 
> @@ -111,13 +111,16 @@ static pgprot_t vm_pgprot_modify(pgprot_t oldprot, unsigned long vm_flags)
>  void vma_set_page_prot(struct vm_area_struct *vma)
>  {
>  	unsigned long vm_flags = vma->vm_flags;
> +	pgprot_t vm_page_prot;
> 
> -	vma->vm_page_prot = vm_pgprot_modify(vma->vm_page_prot, vm_flags);
> +	vm_page_prot = vm_pgprot_modify(vma->vm_page_prot, vm_flags);
>  	if (vma_wants_writenotify(vma)) {

Since vma->vm_page_prot is currently used in vma_wants_writenotify(), is 
it possible that semantic change is introduced here with local variable? 

thanks
Hillf
>  		vm_flags &= ~VM_SHARED;
> -		vma->vm_page_prot = vm_pgprot_modify(vma->vm_page_prot,
> -						     vm_flags);
> +		vm_page_prot = vm_pgprot_modify(vma->vm_page_prot,
> +						vm_flags);
>  	}
> +	/* remove_protection_ptes reads vma->vm_page_prot without mmap_sem */
> +	WRITE_ONCE(vma->vm_page_prot, vm_page_prot);
>  }
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
