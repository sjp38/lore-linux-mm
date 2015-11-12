Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f51.google.com (mail-wm0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id DC58A6B0257
	for <linux-mm@kvack.org>; Thu, 12 Nov 2015 11:45:26 -0500 (EST)
Received: by wmvv187 with SMTP id v187so42436697wmv.1
        for <linux-mm@kvack.org>; Thu, 12 Nov 2015 08:45:26 -0800 (PST)
Received: from e06smtp13.uk.ibm.com (e06smtp13.uk.ibm.com. [195.75.94.109])
        by mx.google.com with ESMTPS id la10si3112455wjb.83.2015.11.12.08.45.25
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=AES128-SHA bits=128/128);
        Thu, 12 Nov 2015 08:45:25 -0800 (PST)
Received: from localhost
	by e06smtp13.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <borntraeger@de.ibm.com>;
	Thu, 12 Nov 2015 16:45:25 -0000
Received: from b06cxnps3075.portsmouth.uk.ibm.com (d06relay10.portsmouth.uk.ibm.com [9.149.109.195])
	by d06dlp02.portsmouth.uk.ibm.com (Postfix) with ESMTP id 2CB442190056
	for <linux-mm@kvack.org>; Thu, 12 Nov 2015 16:45:17 +0000 (GMT)
Received: from d06av03.portsmouth.uk.ibm.com (d06av03.portsmouth.uk.ibm.com [9.149.37.213])
	by b06cxnps3075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id tACGjLxJ48103582
	for <linux-mm@kvack.org>; Thu, 12 Nov 2015 16:45:21 GMT
Received: from d06av03.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av03.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id tACGjLOL018807
	for <linux-mm@kvack.org>; Thu, 12 Nov 2015 09:45:21 -0700
Subject: Re: [PATCH] mm: Loosen MADV_NOHUGEPAGE to enable Qemu postcopy on
 s390
References: <1447341516-18076-1-git-send-email-jjherne@linux.vnet.ibm.com>
From: Christian Borntraeger <borntraeger@de.ibm.com>
Message-ID: <5644C220.30303@de.ibm.com>
Date: Thu, 12 Nov 2015 17:45:20 +0100
MIME-Version: 1.0
In-Reply-To: <1447341516-18076-1-git-send-email-jjherne@linux.vnet.ibm.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Jason J. Herne" <jjherne@linux.vnet.ibm.com>, linux-s390@vger.kernel.org
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, aarcange@redhat.com

On 11/12/2015 04:18 PM, Jason J. Herne wrote:
> MADV_NOHUGEPAGE processing is too restrictive. kvm already disables
> hugepage but hugepage_madvise() takes the error path when we ask to turn
> on the MADV_NOHUGEPAGE bit and the bit is already on. This causes Qemu's
> new postcopy migration feature to fail on s390 because its first action is
> to madvise the guest address space as NOHUGEPAGE. This patch modifies the
> code so that the operation succeeds without error now.

maybe add

"For consistency reasons do the same for MADV_HUGEPAGE."

> 
> Signed-off-by: Jason J. Herne <jjherne@linux.vnet.ibm.com>
> Reviewed-by: Andrea Arcangeli <aarcange@redhat.com>

Acked-by: Christian Borntraeger <borntraeger@de.ibm.com>

Andrew, can you queue this patch?


> ---
>  mm/huge_memory.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> index c29ddeb..62fe06b 100644
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -2009,7 +2009,7 @@ int hugepage_madvise(struct vm_area_struct *vma,
>  		/*
>  		 * Be somewhat over-protective like KSM for now!
>  		 */
> -		if (*vm_flags & (VM_HUGEPAGE | VM_NO_THP))
> +		if (*vm_flags & VM_NO_THP)
>  			return -EINVAL;
>  		*vm_flags &= ~VM_NOHUGEPAGE;
>  		*vm_flags |= VM_HUGEPAGE;
> @@ -2025,7 +2025,7 @@ int hugepage_madvise(struct vm_area_struct *vma,
>  		/*
>  		 * Be somewhat over-protective like KSM for now!
>  		 */
> -		if (*vm_flags & (VM_NOHUGEPAGE | VM_NO_THP))
> +		if (*vm_flags & VM_NO_THP)
>  			return -EINVAL;
>  		*vm_flags &= ~VM_HUGEPAGE;
>  		*vm_flags |= VM_NOHUGEPAGE;
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
