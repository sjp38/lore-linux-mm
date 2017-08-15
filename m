Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 5A41C6B02F3
	for <linux-mm@kvack.org>; Tue, 15 Aug 2017 08:27:05 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id y96so1068853wrc.10
        for <linux-mm@kvack.org>; Tue, 15 Aug 2017 05:27:05 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m185si1230215wmg.140.2017.08.15.05.27.04
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 15 Aug 2017 05:27:04 -0700 (PDT)
Date: Tue, 15 Aug 2017 14:27:01 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH v4 2/3] mm: introduce MAP_VALIDATE a mechanism for adding
 new mmap flags
Message-ID: <20170815122701.GF27505@quack2.suse.cz>
References: <150277752553.23945.13932394738552748440.stgit@dwillia2-desk3.amr.corp.intel.com>
 <150277753660.23945.11500026891611444016.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <150277753660.23945.11500026891611444016.stgit@dwillia2-desk3.amr.corp.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: darrick.wong@oracle.com, Jan Kara <jack@suse.cz>, Arnd Bergmann <arnd@arndb.de>, linux-nvdimm@lists.01.org, linux-api@vger.kernel.org, linux-kernel@vger.kernel.org, linux-xfs@vger.kernel.org, linux-mm@kvack.org, luto@kernel.org, linux-fsdevel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@lst.de>

On Mon 14-08-17 23:12:16, Dan Williams wrote:
> The mmap syscall suffers from the ABI anti-pattern of not validating
> unknown flags. However, proposals like MAP_SYNC and MAP_DIRECT need a
> mechanism to define new behavior that is known to fail on older kernels
> without the feature. Use the fact that specifying MAP_SHARED and
> MAP_PRIVATE at the same time is invalid as a cute hack to allow a new
> set of validated flags to be introduced.
> 
> This also introduces the ->fmmap() file operation that is ->mmap() plus
> flags. Each ->fmmap() implementation must fail requests when a locally
> unsupported flag is specified.
...
> diff --git a/include/linux/fs.h b/include/linux/fs.h
> index 1104e5df39ef..bbe755d0caee 100644
> --- a/include/linux/fs.h
> +++ b/include/linux/fs.h
> @@ -1674,6 +1674,7 @@ struct file_operations {
>  	long (*unlocked_ioctl) (struct file *, unsigned int, unsigned long);
>  	long (*compat_ioctl) (struct file *, unsigned int, unsigned long);
>  	int (*mmap) (struct file *, struct vm_area_struct *);
> +	int (*fmmap) (struct file *, struct vm_area_struct *, unsigned long);
>  	int (*open) (struct inode *, struct file *);
>  	int (*flush) (struct file *, fl_owner_t id);
>  	int (*release) (struct inode *, struct file *);
> @@ -1748,6 +1749,12 @@ static inline int call_mmap(struct file *file, struct vm_area_struct *vma)
>  	return file->f_op->mmap(file, vma);
>  }
>  
> +static inline int call_fmmap(struct file *file, struct vm_area_struct *vma,
> +		unsigned long flags)
> +{
> +	return file->f_op->fmmap(file, vma, flags);
> +}
> +

Hum, I dislike a new file op for this when the only problem with ->mmap is
that it misses 'flags' argument. I understand there are lots of ->mmap
implementations out there and modifying prototype of them all is painful
but is it so bad? Coccinelle patch for this should be rather easy...

Also for MAP_SYNC I want the flag to be copied in VMA anyway so for that I
don't need additional flags argument anyway. And I wonder how you want to
make things work without VMA flag in case of MAP_DIRECT as well - VMAs can
be split, partially unmapped etc. and so without VMA flag you are going to
have hard time to detect whether there's any mapping left which blocks
block mapping changes.

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
