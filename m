Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id E448D6B2BA0
	for <linux-mm@kvack.org>; Thu, 22 Nov 2018 07:06:41 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id o21so1060365edq.4
        for <linux-mm@kvack.org>; Thu, 22 Nov 2018 04:06:41 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 94si1191379edq.95.2018.11.22.04.06.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Nov 2018 04:06:40 -0800 (PST)
Date: Thu, 22 Nov 2018 13:06:38 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH v2] mm: don't break integrity writeback on ->writepage()
 error
Message-ID: <20181122120638.GM9840@quack2.suse.cz>
References: <20181116134304.32440-1-bfoster@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181116134304.32440-1-bfoster@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Brian Foster <bfoster@redhat.com>
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-xfs@vger.kernel.org, linux-ext4@vger.kernel.org

On Fri 16-11-18 08:43:04, Brian Foster wrote:
> The write_cache_pages() function is used in both background and
> integrity writeback scenarios by various filesystems. Background
> writeback is mostly concerned with cleaning a certain number of
> dirty pages based on various mm heuristics. It may not write the
> full set of dirty pages or wait for I/O to complete. Integrity
> writeback is responsible for persisting a set of dirty pages before
> the writeback job completes. For example, an fsync() call must
> perform integrity writeback to ensure data is on disk before the
> call returns.
> 
> write_cache_pages() unconditionally breaks out of its processing
> loop in the event of a ->writepage() error. This is fine for
> background writeback, which had no strict requirements and will
> eventually come around again. This can cause problems for integrity
> writeback on filesystems that might need to clean up state
> associated with failed page writeouts. For example, XFS performs
> internal delayed allocation accounting before returning a
> ->writepage() error, where applicable. If the current writeback
> happens to be associated with an unmount and write_cache_pages()
> completes the writeback prematurely due to error, the filesystem is
> unmounted in an inconsistent state if dirty+delalloc pages still
> exist.
> 
> To handle this problem, update write_cache_pages() to always process
> the full set of pages for integrity writeback regardless of
> ->writepage() errors. Save the first encountered error and return it
> to the caller once complete. This facilitates XFS (or any other fs
> that expects integrity writeback to process the entire set of dirty
> pages) to clean up its internal state completely in the event of
> persistent mapping errors. Background writeback continues to exit on
> the first error encountered.
> 
> Signed-off-by: Brian Foster <bfoster@redhat.com>

OK, makes sense and the patch looks good to me. You can add:

Reviewed-by: Jan Kara <jack@suse.cz>

								Honza

> ---
> 
> Here's a v2 with minor enhancenents based on Andrew Morton's feedback. I
> combined the additional comments with the existing one to avoid having
> too many multi-indent/multi-line comments in this area.
> 
> Brian
> 
> v2:
> - Dropped unnecessary ->for_sync check.
> - Added comment and updated commit log description.
> v1: https://marc.info/?l=linux-fsdevel&m=154143578027082&w=2
> 
>  mm/page-writeback.c | 35 +++++++++++++++++++++--------------
>  1 file changed, 21 insertions(+), 14 deletions(-)
> 
> diff --git a/mm/page-writeback.c b/mm/page-writeback.c
> index 3f690bae6b78..59b4b56d3762 100644
> --- a/mm/page-writeback.c
> +++ b/mm/page-writeback.c
> @@ -2154,6 +2154,7 @@ int write_cache_pages(struct address_space *mapping,
>  {
>  	int ret = 0;
>  	int done = 0;
> +	int error;
>  	struct pagevec pvec;
>  	int nr_pages;
>  	pgoff_t uninitialized_var(writeback_index);
> @@ -2227,25 +2228,31 @@ int write_cache_pages(struct address_space *mapping,
>  				goto continue_unlock;
>  
>  			trace_wbc_writepage(wbc, inode_to_bdi(mapping->host));
> -			ret = (*writepage)(page, wbc, data);
> -			if (unlikely(ret)) {
> -				if (ret == AOP_WRITEPAGE_ACTIVATE) {
> +			error = (*writepage)(page, wbc, data);
> +			if (unlikely(error)) {
> +				/*
> +				 * Handle errors according to the type of
> +				 * writeback. There's no need to continue to for
> +				 * background writeback. Just push done_index
> +				 * past this page so media errors won't choke
> +				 * writeout for the entire file. For integrity
> +				 * writeback, we must process the entire dirty
> +				 * set regardless of errors because the fs may
> +				 * still have state to clear for each page. In
> +				 * that case we continue processing and return
> +				 * the first error.
> +				 */
> +				if (error == AOP_WRITEPAGE_ACTIVATE) {
>  					unlock_page(page);
> -					ret = 0;
> -				} else {
> -					/*
> -					 * done_index is set past this page,
> -					 * so media errors will not choke
> -					 * background writeout for the entire
> -					 * file. This has consequences for
> -					 * range_cyclic semantics (ie. it may
> -					 * not be suitable for data integrity
> -					 * writeout).
> -					 */
> +					error = 0;
> +				} else if (wbc->sync_mode != WB_SYNC_ALL) {
> +					ret = error;
>  					done_index = page->index + 1;
>  					done = 1;
>  					break;
>  				}
> +				if (!ret)
> +					ret = error;
>  			}
>  
>  			/*
> -- 
> 2.17.2
> 
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR
