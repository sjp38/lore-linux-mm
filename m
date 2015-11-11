Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f174.google.com (mail-io0-f174.google.com [209.85.223.174])
	by kanga.kvack.org (Postfix) with ESMTP id 673B56B0253
	for <linux-mm@kvack.org>; Wed, 11 Nov 2015 12:30:49 -0500 (EST)
Received: by iody8 with SMTP id y8so40854016iod.1
        for <linux-mm@kvack.org>; Wed, 11 Nov 2015 09:30:49 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id s85si12504073ios.153.2015.11.11.09.30.48
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 Nov 2015 09:30:48 -0800 (PST)
Date: Wed, 11 Nov 2015 18:30:44 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH] mm: Loosen MADV_NOHUGEPAGE to enable Qemu postcopy on
 s390
Message-ID: <20151111173044.GF4573@redhat.com>
References: <1447256116-16461-1-git-send-email-jjherne@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1447256116-16461-1-git-send-email-jjherne@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Jason J. Herne" <jjherne@linux.vnet.ibm.com>
Cc: linux-s390@vger.kernel.org, linux-mm@kvack.org, borntraeger@de.ibm.com

Hi Jason,

On Wed, Nov 11, 2015 at 10:35:16AM -0500, Jason J. Herne wrote:
> MADV_NOHUGEPAGE processing is too restrictive. kvm already disables
> hugepage but hugepage_madvise() takes the error path when we ask to turn
> on the MADV_NOHUGEPAGE bit and the bit is already on. This causes Qemu's

I wonder why KVM disables transparent hugepages on s390. It sounds
weird to disable transparent hugepages with KVM. In fact on x86 we
call MADV_HUGEPAGE to be sure transparent hugepages are enabled on the
guest physical memory, even if the transparent_hugepage/enabled ==
madvise.

> new postcopy migration feature to fail on s390 because its first action is
> to madvise the guest address space as NOHUGEPAGE. This patch modifies the
> code so that the operation succeeds without error now.

The other way is to change qemu to keep track it already called
MADV_NOHUGEPAGE and not to call it again. I don't have a strong
opinion on this, I think it's ok to return 0 but it's a visible change
to userland, I can't imagine it to break anything though. It sounds
very unlikely that an app could error out if it notices the kernel
doesn't error out on the second call of MADV_NOHUGEPAGE.

Glad to hear KVM postcopy live migration is already running on s390 too.

Thanks,
Andrea

> 
> Signed-off-by: Jason J. Herne <jjherne@linux.vnet.ibm.com>
> ---
>  mm/huge_memory.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> index c29ddeb..a8b5347 100644
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -2025,7 +2025,7 @@ int hugepage_madvise(struct vm_area_struct *vma,
>  		/*
>  		 * Be somewhat over-protective like KSM for now!
>  		 */
> -		if (*vm_flags & (VM_NOHUGEPAGE | VM_NO_THP))
> +		if (*vm_flags & VM_NO_THP)
>  			return -EINVAL;
>  		*vm_flags &= ~VM_HUGEPAGE;
>  		*vm_flags |= VM_NOHUGEPAGE;
> -- 
> 1.9.1
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
