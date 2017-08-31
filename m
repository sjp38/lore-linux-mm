Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id A033C6B0292
	for <linux-mm@kvack.org>; Thu, 31 Aug 2017 06:02:03 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id m85so5683727wma.8
        for <linux-mm@kvack.org>; Thu, 31 Aug 2017 03:02:03 -0700 (PDT)
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id 193si4775280wmp.6.2017.08.31.03.02.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 31 Aug 2017 03:02:02 -0700 (PDT)
Date: Thu, 31 Aug 2017 12:02:01 +0200
From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH 1/2] vfs: add flags parameter to ->mmap() in 'struct
	file_operations'
Message-ID: <20170831100201.GC21443@lst.de>
References: <150413449482.5923.1348069619036923853.stgit@dwillia2-desk3.amr.corp.intel.com> <150413450036.5923.13851061508172314879.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <150413450036.5923.13851061508172314879.stgit@dwillia2-desk3.amr.corp.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: linux-mm@kvack.org, jack@suse.cz, linux-nvdimm@lists.01.org, David Airlie <airlied@linux.ie>, linux-api@vger.kernel.org, Takashi Iwai <tiwai@suse.com>, dri-devel@lists.freedesktop.org, Julia Lawall <julia.lawall@lip6.fr>, luto@kernel.org, Daniel Vetter <daniel.vetter@intel.com>, akpm@linux-foundation.org, torvalds@linux-foundation.org, hch@lst.de

> -static int ecryptfs_mmap(struct file *file, struct vm_area_struct *vma)
> +static int ecryptfs_mmap(struct file *file, struct vm_area_struct *vma,
> +			 unsigned long map_flags)
>  {
>  	struct file *lower_file = ecryptfs_file_to_lower(file);
>  	/*
> @@ -179,7 +180,7 @@ static int ecryptfs_mmap(struct file *file, struct vm_area_struct *vma)
>  	 */
>  	if (!lower_file->f_op->mmap)
>  		return -ENODEV;
> -	return generic_file_mmap(file, vma);
> +	return generic_file_mmap(file, vma, 0);

Shouldn't ecryptfs pass on the flags?  Same for coda_file_mmap and
shm_mmap.

> -static inline int call_mmap(struct file *file, struct vm_area_struct *vma)
> +static inline int call_mmap(struct file *file, struct vm_area_struct *vma,
> +			    unsigned long flags)
>  {
> -	return file->f_op->mmap(file, vma);
> +	return file->f_op->mmap(file, vma, flags);
>  }

It would be great to kill this pointless wrapper while we're at it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
