Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f180.google.com (mail-yk0-f180.google.com [209.85.160.180])
	by kanga.kvack.org (Postfix) with ESMTP id 992DC6B0074
	for <linux-mm@kvack.org>; Mon, 12 Jan 2015 18:10:00 -0500 (EST)
Received: by mail-yk0-f180.google.com with SMTP id 9so10550989ykp.11
        for <linux-mm@kvack.org>; Mon, 12 Jan 2015 15:10:00 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id e23si9866067yhb.116.2015.01.12.15.09.59
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 12 Jan 2015 15:09:59 -0800 (PST)
Date: Mon, 12 Jan 2015 15:09:58 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v12 09/20] dax,ext2: Replace xip_truncate_page with
 dax_truncate_page
Message-Id: <20150112150958.2e6bd85dc3e25b953d28c6cb@linux-foundation.org>
In-Reply-To: <1414185652-28663-10-git-send-email-matthew.r.wilcox@intel.com>
References: <1414185652-28663-1-git-send-email-matthew.r.wilcox@intel.com>
	<1414185652-28663-10-git-send-email-matthew.r.wilcox@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <matthew.r.wilcox@intel.com>
Cc: linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, willy@linux.intel.com

On Fri, 24 Oct 2014 17:20:41 -0400 Matthew Wilcox <matthew.r.wilcox@intel.com> wrote:

> It takes a get_block parameter just like nobh_truncate_page() and
> block_truncate_page()
> 
> --- a/fs/dax.c
> +++ b/fs/dax.c
> @@ -458,3 +458,47 @@ int dax_fault(struct vm_area_struct *vma, struct vm_fault *vmf,
>  	return result;
>  }
>  EXPORT_SYMBOL_GPL(dax_fault);
> +
> +/**
> + * dax_truncate_page - handle a partial page being truncated in a DAX file
> + * @inode: The file being truncated
> + * @from: The file offset that is being truncated to
> + * @get_block: The filesystem method used to translate file offsets to blocks
> + *
> + * Similar to block_truncate_page(), this function can be called by a
> + * filesystem when it is truncating an DAX file to handle the partial page.
> + *
> + * We work in terms of PAGE_CACHE_SIZE here for commonality with
> + * block_truncate_page(), but we could go down to PAGE_SIZE if the filesystem
> + * took care of disposing of the unnecessary blocks.

But PAGE_SIZE==PAGE_CACHE_SIZE.  Unclear what you're saying here.

> + Even if the filesystem
> + * block size is smaller than PAGE_SIZE, we have to zero the rest of the page
> + * since the file might be mmaped.
> + */
> 
> ...
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
