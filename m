Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 9838B6B025E
	for <linux-mm@kvack.org>; Tue, 21 Nov 2017 18:11:18 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id 107so8803011wra.7
        for <linux-mm@kvack.org>; Tue, 21 Nov 2017 15:11:18 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id k7si11693340wrg.112.2017.11.21.15.11.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 Nov 2017 15:11:17 -0800 (PST)
Date: Tue, 21 Nov 2017 15:11:14 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v2 1/4] mm: introduce get_user_pages_longterm
Message-Id: <20171121151114.de95a3eb730ce602e52e891d@linux-foundation.org>
In-Reply-To: <151068939435.7446.13560129395419350737.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <151068938905.7446.12333914805308312313.stgit@dwillia2-desk3.amr.corp.intel.com>
	<151068939435.7446.13560129395419350737.stgit@dwillia2-desk3.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Christoph Hellwig <hch@lst.de>, stable@vger.kernel.org, linux-nvdimm@lists.01.org

On Tue, 14 Nov 2017 11:56:34 -0800 Dan Williams <dan.j.williams@intel.com> wrote:

> Until there is a solution to the dma-to-dax vs truncate problem it is
> not safe to allow long standing memory registrations against
> filesytem-dax vmas. Device-dax vmas do not have this problem and are
> explicitly allowed.
> 
> This is temporary until a "memory registration with layout-lease"
> mechanism can be implemented for the affected sub-systems (RDMA and
> V4L2).
> 
> --- a/mm/gup.c
> +++ b/mm/gup.c
> @@ -1095,6 +1095,70 @@ long get_user_pages(unsigned long start, unsigned long nr_pages,
>  }
>  EXPORT_SYMBOL(get_user_pages);
>  
> +#ifdef CONFIG_FS_DAX
> +/*
> + * This is the same as get_user_pages() in that it assumes we are
> + * operating on the current task's mm, but it goes further to validate
> + * that the vmas associated with the address range are suitable for
> + * longterm elevated page reference counts. For example, filesystem-dax
> + * mappings are subject to the lifetime enforced by the filesystem and
> + * we need guarantees that longterm users like RDMA and V4L2 only
> + * establish mappings that have a kernel enforced revocation mechanism.
> + *
> + * "longterm" == userspace controlled elevated page count lifetime.
> + * Contrast this to iov_iter_get_pages() usages which are transient.
> + */
> +long get_user_pages_longterm(unsigned long start, unsigned long nr_pages,
> +		unsigned int gup_flags, struct page **pages,
> +		struct vm_area_struct **vmas_arg)
> +{
> +	struct vm_area_struct **vmas = vmas_arg;
> +	struct vm_area_struct *vma_prev = NULL;
> +	long rc, i;
> +
> +	if (!pages)
> +		return -EINVAL;
> +
> +	if (!vmas) {
> +		vmas = kzalloc(sizeof(struct vm_area_struct *) * nr_pages,
> +				GFP_KERNEL);
> +		if (!vmas)
> +			return -ENOMEM;
> +	}
>
> ...
>

I'll do this:

--- a/mm/gup.c~mm-introduce-get_user_pages_longterm-fix
+++ a/mm/gup.c
@@ -1120,8 +1120,8 @@ long get_user_pages_longterm(unsigned lo
 		return -EINVAL;
 
 	if (!vmas) {
-		vmas = kzalloc(sizeof(struct vm_area_struct *) * nr_pages,
-				GFP_KERNEL);
+		vmas = kcalloc(nr_pages, sizeof(struct vm_area_struct *),
+			       GFP_KERNEL);
 		if (!vmas)
 			return -ENOMEM;
 	}
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
