Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id AF6676B0292
	for <linux-mm@kvack.org>; Thu, 27 Jul 2017 04:43:44 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id g71so12803126wmg.13
        for <linux-mm@kvack.org>; Thu, 27 Jul 2017 01:43:44 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id s78si7478423wma.251.2017.07.27.01.43.43
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 27 Jul 2017 01:43:43 -0700 (PDT)
Date: Thu, 27 Jul 2017 10:43:41 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH v2 1/4] mm: consolidate dax / non-dax checks for writeback
Message-ID: <20170727084341.GB21100@quack2.suse.cz>
References: <20170726175538.13885-1-jlayton@kernel.org>
 <20170726175538.13885-2-jlayton@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170726175538.13885-2-jlayton@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jeff Layton <jlayton@kernel.org>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, Jan Kara <jack@suse.cz>, "J . Bruce Fields" <bfields@fieldses.org>, Andrew Morton <akpm@linux-foundation.org>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Matthew Wilcox <willy@infradead.org>, Bob Peterson <rpeterso@redhat.com>, Steven Whitehouse <swhiteho@redhat.com>, cluster-devel@redhat.com

On Wed 26-07-17 13:55:35, Jeff Layton wrote:
> From: Jeff Layton <jlayton@redhat.com>
> 
> We have this complex conditional copied to several places. Turn it into
> a helper function.
> 
> Signed-off-by: Jeff Layton <jlayton@redhat.com>

Looks good. You can add:

Reviewed-by: Jan Kara <jack@suse.cz>

								Honza

> ---
>  mm/filemap.c | 15 +++++++++------
>  1 file changed, 9 insertions(+), 6 deletions(-)
> 
> diff --git a/mm/filemap.c b/mm/filemap.c
> index e1cca770688f..72e46e6f0d9a 100644
> --- a/mm/filemap.c
> +++ b/mm/filemap.c
> @@ -522,12 +522,17 @@ int filemap_fdatawait(struct address_space *mapping)
>  }
>  EXPORT_SYMBOL(filemap_fdatawait);
>  
> +static bool mapping_needs_writeback(struct address_space *mapping)
> +{
> +	return (!dax_mapping(mapping) && mapping->nrpages) ||
> +	    (dax_mapping(mapping) && mapping->nrexceptional);
> +}
> +
>  int filemap_write_and_wait(struct address_space *mapping)
>  {
>  	int err = 0;
>  
> -	if ((!dax_mapping(mapping) && mapping->nrpages) ||
> -	    (dax_mapping(mapping) && mapping->nrexceptional)) {
> +	if (mapping_needs_writeback(mapping)) {
>  		err = filemap_fdatawrite(mapping);
>  		/*
>  		 * Even if the above returned error, the pages may be
> @@ -566,8 +571,7 @@ int filemap_write_and_wait_range(struct address_space *mapping,
>  {
>  	int err = 0;
>  
> -	if ((!dax_mapping(mapping) && mapping->nrpages) ||
> -	    (dax_mapping(mapping) && mapping->nrexceptional)) {
> +	if (mapping_needs_writeback(mapping)) {
>  		err = __filemap_fdatawrite_range(mapping, lstart, lend,
>  						 WB_SYNC_ALL);
>  		/* See comment of filemap_write_and_wait() */
> @@ -656,8 +660,7 @@ int file_write_and_wait_range(struct file *file, loff_t lstart, loff_t lend)
>  	int err = 0, err2;
>  	struct address_space *mapping = file->f_mapping;
>  
> -	if ((!dax_mapping(mapping) && mapping->nrpages) ||
> -	    (dax_mapping(mapping) && mapping->nrexceptional)) {
> +	if (mapping_needs_writeback(mapping)) {
>  		err = __filemap_fdatawrite_range(mapping, lstart, lend,
>  						 WB_SYNC_ALL);
>  		/* See comment of filemap_write_and_wait() */
> -- 
> 2.13.3
> 
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
