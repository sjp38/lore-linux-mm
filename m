Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 367696B0390
	for <linux-mm@kvack.org>; Thu, 13 Apr 2017 00:17:16 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id b10so27251734pgn.8
        for <linux-mm@kvack.org>; Wed, 12 Apr 2017 21:17:16 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id a67si22537999pfb.345.2017.04.12.21.17.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Apr 2017 21:17:15 -0700 (PDT)
Received: from pps.filterd (m0098399.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v3D4Fum3016529
	for <linux-mm@kvack.org>; Thu, 13 Apr 2017 00:17:14 -0400
Received: from e28smtp01.in.ibm.com (e28smtp01.in.ibm.com [125.16.236.1])
	by mx0a-001b2d01.pphosted.com with ESMTP id 29ssdktnsp-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 13 Apr 2017 00:17:14 -0400
Received: from localhost
	by e28smtp01.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Thu, 13 Apr 2017 09:47:11 +0530
Received: from d28av03.in.ibm.com (d28av03.in.ibm.com [9.184.220.65])
	by d28relay10.in.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v3D4FkbV14090452
	for <linux-mm@kvack.org>; Thu, 13 Apr 2017 09:45:46 +0530
Received: from d28av03.in.ibm.com (localhost [127.0.0.1])
	by d28av03.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v3D4H50G018568
	for <linux-mm@kvack.org>; Thu, 13 Apr 2017 09:47:07 +0530
Subject: Re: [PATCH] mm: add VM_STATIC flag to vmalloc and prevent from
 removing the areas
References: <1491973350-26816-1-git-send-email-hoeun.ryu@gmail.com>
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Date: Thu, 13 Apr 2017 09:47:03 +0530
MIME-Version: 1.0
In-Reply-To: <1491973350-26816-1-git-send-email-hoeun.ryu@gmail.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Message-Id: <c900f2f4-8b0c-cc0e-afb7-a03cd1458e4c@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hoeun Ryu <hoeun.ryu@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Andreas Dilger <adilger@dilger.ca>, Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@suse.com>, Chris Wilson <chris@chris-wilson.co.uk>, Ingo Molnar <mingo@kernel.org>, zijun_hu <zijun_hu@htc.com>, Matthew Wilcox <mawilcox@microsoft.com>, Thomas Garnier <thgarnie@google.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 04/12/2017 10:31 AM, Hoeun Ryu wrote:
> vm_area_add_early/vm_area_register_early() are used to reserve vmalloc area
> during boot process and those virtually mapped areas are never unmapped.
> So `OR` VM_STATIC flag to the areas in vmalloc_init() when importing
> existing vmlist entries and prevent those areas from being removed from the
> rbtree by accident.

I am wondering whether protection against accidental deletion
of any vmap area should be done in remove_vm_area() function
or the callers should take care of it. But I guess either way
it works.

> 
> Signed-off-by: Hoeun Ryu <hoeun.ryu@gmail.com>
> ---
>  include/linux/vmalloc.h | 1 +
>  mm/vmalloc.c            | 9 ++++++---
>  2 files changed, 7 insertions(+), 3 deletions(-)
> 
> diff --git a/include/linux/vmalloc.h b/include/linux/vmalloc.h
> index 46991ad..3df53fc 100644
> --- a/include/linux/vmalloc.h
> +++ b/include/linux/vmalloc.h
> @@ -19,6 +19,7 @@ struct notifier_block;		/* in notifier.h */
>  #define VM_UNINITIALIZED	0x00000020	/* vm_struct is not fully initialized */
>  #define VM_NO_GUARD		0x00000040      /* don't add guard page */
>  #define VM_KASAN		0x00000080      /* has allocated kasan shadow memory */
> +#define VM_STATIC		0x00000200

You might want to add some description in the comment saying
its a sticky VM area which will never go away or something.

>  /* bits [20..32] reserved for arch specific ioremap internals */
>  
>  /*
> diff --git a/mm/vmalloc.c b/mm/vmalloc.c
> index 8ef8ea1..fb5049a 100644
> --- a/mm/vmalloc.c
> +++ b/mm/vmalloc.c
> @@ -1262,7 +1262,7 @@ void __init vmalloc_init(void)
>  	/* Import existing vmlist entries. */
>  	for (tmp = vmlist; tmp; tmp = tmp->next) {
>  		va = kzalloc(sizeof(struct vmap_area), GFP_NOWAIT);
> -		va->flags = VM_VM_AREA;
> +		va->flags = VM_VM_AREA | VM_STATIC;
>  		va->va_start = (unsigned long)tmp->addr;
>  		va->va_end = va->va_start + tmp->size;
>  		va->vm = tmp;
> @@ -1480,7 +1480,7 @@ struct vm_struct *remove_vm_area(const void *addr)
>  	might_sleep();
>  
>  	va = find_vmap_area((unsigned long)addr);
> -	if (va && va->flags & VM_VM_AREA) {
> +	if (va && va->flags & VM_VM_AREA && likely(!(va->flags & VM_STATIC))) {


You might want to move the VM_STATIC check before the VM_VM_AREA
check so in cases where the former is set we can save one more
conditional check.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
