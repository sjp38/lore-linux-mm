Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com [209.85.212.177])
	by kanga.kvack.org (Postfix) with ESMTP id 900346B0036
	for <linux-mm@kvack.org>; Wed, 23 Jul 2014 07:22:06 -0400 (EDT)
Received: by mail-wi0-f177.google.com with SMTP id ho1so1991313wib.16
        for <linux-mm@kvack.org>; Wed, 23 Jul 2014 04:22:03 -0700 (PDT)
Received: from jenni1.inet.fi (mta-out1.inet.fi. [62.71.2.202])
        by mx.google.com with ESMTP id vq2si4224693wjc.89.2014.07.23.04.22.01
        for <linux-mm@kvack.org>;
        Wed, 23 Jul 2014 04:22:02 -0700 (PDT)
Date: Wed, 23 Jul 2014 14:21:56 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH v8 01/22] Fix XIP fault vs truncate race
Message-ID: <20140723112156.GA10317@node.dhcp.inet.fi>
References: <cover.1406058387.git.matthew.r.wilcox@intel.com>
 <78c38d32aa62db1bb86315cf3e287b24be900c5e.1406058387.git.matthew.r.wilcox@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <78c38d32aa62db1bb86315cf3e287b24be900c5e.1406058387.git.matthew.r.wilcox@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <matthew.r.wilcox@intel.com>
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, willy@linux.intel.com

On Tue, Jul 22, 2014 at 03:47:49PM -0400, Matthew Wilcox wrote:
> Pagecache faults recheck i_size after taking the page lock to ensure that
> the fault didn't race against a truncate.  We don't have a page to lock
> in the XIP case, so use the i_mmap_mutex instead.  It is locked in the
> truncate path in unmap_mapping_range() after updating i_size.  So while
> we hold it in the fault path, we are guaranteed that either i_size has
> already been updated in the truncate path, or that the truncate will
> subsequently call zap_page_range_single() and so remove the mapping we
> have just inserted.
> 
> There is a window of time in which i_size has been reduced and the
> thread has a mapping to a page which will be removed from the file,
> but this is harmless as the page will not be allocated to a different
> purpose before the thread's access to it is revoked.
> 
> Signed-off-by: Matthew Wilcox <matthew.r.wilcox@intel.com>
> Reviewed-by: Jan Kara <jack@suse.cz>
> ---
>  mm/filemap_xip.c | 24 ++++++++++++++++++++++--
>  1 file changed, 22 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/filemap_xip.c b/mm/filemap_xip.c
> index d8d9fe3..c8d23e9 100644
> --- a/mm/filemap_xip.c
> +++ b/mm/filemap_xip.c
> @@ -260,8 +260,17 @@ again:
>  		__xip_unmap(mapping, vmf->pgoff);
>  
>  found:
> +		/* We must recheck i_size under i_mmap_mutex */
> +		mutex_lock(&mapping->i_mmap_mutex);
> +		size = (i_size_read(inode) + PAGE_CACHE_SIZE - 1) >>
> +							PAGE_CACHE_SHIFT;

round_up() ?

Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
