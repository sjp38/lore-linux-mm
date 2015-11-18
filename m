Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f43.google.com (mail-wm0-f43.google.com [74.125.82.43])
	by kanga.kvack.org (Postfix) with ESMTP id 8344D82F6C
	for <linux-mm@kvack.org>; Wed, 18 Nov 2015 08:31:57 -0500 (EST)
Received: by wmdw130 with SMTP id w130so198683685wmd.0
        for <linux-mm@kvack.org>; Wed, 18 Nov 2015 05:31:57 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l75si35815276wmd.47.2015.11.18.05.31.56
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 18 Nov 2015 05:31:56 -0800 (PST)
Subject: Re: [PATCH] mm: Loosen MADV_NOHUGEPAGE to enable Qemu postcopy on
 s390
References: <1447341516-18076-1-git-send-email-jjherne@linux.vnet.ibm.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <564C7DCA.8010400@suse.cz>
Date: Wed, 18 Nov 2015 14:31:54 +0100
MIME-Version: 1.0
In-Reply-To: <1447341516-18076-1-git-send-email-jjherne@linux.vnet.ibm.com>
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Jason J. Herne" <jjherne@linux.vnet.ibm.com>, linux-s390@vger.kernel.org
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, aarcange@redhat.com, borntraeger@de.ibm.com, linux-api@vger.kernel.org, linux-man@vger.kernel.org

[CC += linux-api@vger.kernel.org]

Since this is a kernel-user-space API change, please CC linux-api@. The kernel
source file Documentation/SubmitChecklist notes that all Linux kernel patches
that change userspace interfaces should be CCed to linux-api@vger.kernel.org, so
that the various parties who are interested in API changes are informed. For
further information, see https://www.kernel.org/doc/man-pages/linux-api-ml.html

On 11/12/2015 04:18 PM, Jason J. Herne wrote:
> MADV_NOHUGEPAGE processing is too restrictive. kvm already disables
> hugepage but hugepage_madvise() takes the error path when we ask to turn
> on the MADV_NOHUGEPAGE bit and the bit is already on. This causes Qemu's
> new postcopy migration feature to fail on s390 because its first action is
> to madvise the guest address space as NOHUGEPAGE. This patch modifies the
> code so that the operation succeeds without error now.
> 
> Signed-off-by: Jason J. Herne <jjherne@linux.vnet.ibm.com>
> Reviewed-by: Andrea Arcangeli <aarcange@redhat.com>

Looks like the manpage should be fine, as it wasn't very specific wrt these
madvise flags. The only thing that potentially applies is:

"EINVAL advice is not a valid."

which itself looks like it needs fixing. Valid what, value? As in completely
unknown flags, or flags not valid for the given vma?

Anyway, I agree that it doesn't make sense to fail madvise when the given flag
is already set. On the other hand, I don't think the userspace app should fail
just because of madvise failing? It should in general be an advice that the
kernel is also strictly speaking free to ignore as it shouldn't affect
correctnes, just performance. Yeah, there are exceptions today like
MADV_DONTNEED, but that shouldn't apply to hugepages?
So I think Qemu needs fixing too. Also what happens if the kernel is build
without CONFIG_TRANSPARENT_HUGEPAGE? Then madvise also returns EINVAL, how does
Qemu handle that?

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
