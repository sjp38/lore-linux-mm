Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 37D398E0001
	for <linux-mm@kvack.org>; Sun, 20 Jan 2019 16:07:45 -0500 (EST)
Received: by mail-pg1-f197.google.com with SMTP id a2so12679986pgt.11
        for <linux-mm@kvack.org>; Sun, 20 Jan 2019 13:07:45 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id d40si1944470pla.427.2019.01.20.13.07.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 20 Jan 2019 13:07:43 -0800 (PST)
Received: from pps.filterd (m0098393.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x0KKwrJL040874
	for <linux-mm@kvack.org>; Sun, 20 Jan 2019 16:07:43 -0500
Received: from e06smtp07.uk.ibm.com (e06smtp07.uk.ibm.com [195.75.94.103])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2q4j49fdkt-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Sun, 20 Jan 2019 16:07:43 -0500
Received: from localhost
	by e06smtp07.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Sun, 20 Jan 2019 21:07:40 -0000
Date: Sun, 20 Jan 2019 23:07:32 +0200
From: Mike Rapoport <rppt@linux.ibm.com>
Subject: Re: [PATCH 4/4] userfaultfd: change the direction for UFFDIO_REMAP
 to out
References: <cover.1547251023.git.blake.caldwell@colorado.edu>
 <ab1b6be85254e111935104cf4a2293ab2fa4a8d6.1547251023.git.blake.caldwell@colorado.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <ab1b6be85254e111935104cf4a2293ab2fa4a8d6.1547251023.git.blake.caldwell@colorado.edu>
Message-Id: <20190120210731.GC28141@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Blake Caldwell <blake.caldwell@colorado.edu>
Cc: rppt@linux.vnet.ibm.com, xemul@virtuozzo.com, akpm@linux-foundation.org, mike.kravetz@oracle.com, kirill.shutemov@linux.intel.com, linux-mm@kvack.org, aarcange@redhat.com

Hi,

On Sat, Jan 12, 2019 at 12:36:29AM +0000, Blake Caldwell wrote:
> Moving a page out of a userfaultfd registered region and into a userland
> anonymous vma is needed by the use case of uncooperatively limiting the
> resident size of the userfaultfd region. Reverse the direction of the
> original userfaultfd_remap() to the out direction. Now after memory has
> been removed, subsequent accesses will generate uffdio page fault events.

It took me a while but better late then never :)

Why did you keep this as a separate patch? If the primary use case for
UFFDIO_REMAP to move pages out of userfaultfd region, why not make it so
from the beginning?

> Signed-off-by: Blake Caldwell <blake.caldwell@colorado.edu>
> ---
>  Documentation/admin-guide/mm/userfaultfd.rst | 10 ++++++++++
>  fs/userfaultfd.c                             |  6 +++---
>  2 files changed, 13 insertions(+), 3 deletions(-)
> 
> diff --git a/Documentation/admin-guide/mm/userfaultfd.rst b/Documentation/admin-guide/mm/userfaultfd.rst
> index 5048cf6..714af49 100644
> --- a/Documentation/admin-guide/mm/userfaultfd.rst
> +++ b/Documentation/admin-guide/mm/userfaultfd.rst
> @@ -108,6 +108,16 @@ UFFDIO_COPY. They're atomic as in guaranteeing that nothing can see an
>  half copied page since it'll keep userfaulting until the copy has
>  finished.
> 
> +To move pages out of a userfault registered region and into a user vma
> +the UFFDIO_REMAP ioctl can be used. This is only possible for the
> +"OUT" direction. For the "IN" direction, UFFDIO_COPY is preferred
> +since UFFDIO_REMAP requires a TLB flush on the source range at a
> +greater penalty than copying the page. With
> +UFFDIO_REGISTER_MODE_MISSING set, subsequent accesses to the same
> +region will generate a page fault event. This allows non-cooperative
> +removal of memory in a userfaultfd registered vma, effectively
> +limiting the amount of resident memory in such a region.
> +
>  QEMU/KVM
>  ========
> 
> diff --git a/fs/userfaultfd.c b/fs/userfaultfd.c
> index cf68cdb..8099da2 100644
> --- a/fs/userfaultfd.c
> +++ b/fs/userfaultfd.c
> @@ -1808,10 +1808,10 @@ static int userfaultfd_remap(struct userfaultfd_ctx *ctx,
>  			   sizeof(uffdio_remap)-sizeof(__s64)))
>  		goto out;
> 
> -	ret = validate_range(ctx->mm, uffdio_remap.dst, uffdio_remap.len);
> +	ret = validate_range(current->mm, uffdio_remap.dst, uffdio_remap.len);
>  	if (ret)
>  		goto out;
> -	ret = validate_range(current->mm, uffdio_remap.src, uffdio_remap.len);
> +	ret = validate_range(ctx->mm, uffdio_remap.src, uffdio_remap.len);
>  	if (ret)
>  		goto out;
>  	ret = -EINVAL;
> @@ -1819,7 +1819,7 @@ static int userfaultfd_remap(struct userfaultfd_ctx *ctx,
>  				  UFFDIO_REMAP_MODE_DONTWAKE))
>  		goto out;
> 
> -	ret = remap_pages(ctx->mm, current->mm,
> +	ret = remap_pages(current->mm, ctx->mm,
>  			  uffdio_remap.dst, uffdio_remap.src,
>  			  uffdio_remap.len, uffdio_remap.mode);
>  	if (unlikely(put_user(ret, &user_uffdio_remap->remap)))
> -- 
> 1.8.3.1
> 

-- 
Sincerely yours,
Mike.
