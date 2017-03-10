Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id E2D166B0404
	for <linux-mm@kvack.org>; Thu,  9 Mar 2017 19:09:40 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id q126so137909187pga.0
        for <linux-mm@kvack.org>; Thu, 09 Mar 2017 16:09:40 -0800 (PST)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id a62si1179106pgc.371.2017.03.09.16.09.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 09 Mar 2017 16:09:40 -0800 (PST)
Date: Thu, 9 Mar 2017 17:09:39 -0700
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: Re: [PATCH v2 3/9] mm: clear any AS_* errors when returning error on
 any fsync or close
Message-ID: <20170310000939.GC30285@linux.intel.com>
References: <20170308162934.21989-1-jlayton@redhat.com>
 <20170308162934.21989-4-jlayton@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170308162934.21989-4-jlayton@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jeff Layton <jlayton@redhat.com>
Cc: viro@zeniv.linux.org.uk, akpm@linux-foundation.org, konishi.ryusuke@lab.ntt.co.jp, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-nilfs@vger.kernel.org, ross.zwisler@linux.intel.com, jack@suse.cz, neilb@suse.com, openosd@gmail.com, adilger@dilger.ca, James.Bottomley@HansenPartnership.com

On Wed, Mar 08, 2017 at 11:29:28AM -0500, Jeff Layton wrote:
> Currently we don't clear the address space error when there is a -EIO
> error on fsynci, due to writeback initiation failure. If writes fail
	   fsync

> with -EIO and the mapping is flagged with an AS_EIO or AS_ENOSPC error,
> then we can end up returning errors on two fsync calls, even when a
> write between them succeeded (or there was no write).
> 
> Ensure that we also clear out any mapping errors when initiating
> writeback fails with -EIO in filemap_write_and_wait and
> filemap_write_and_wait_range.
> 
> Suggested-by: Jan Kara <jack@suse.cz>
> Signed-off-by: Jeff Layton <jlayton@redhat.com>
> ---
>  mm/filemap.c | 20 ++++++++++++++++++--
>  1 file changed, 18 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/filemap.c b/mm/filemap.c
> index 1694623a6289..fc123b9833e1 100644
> --- a/mm/filemap.c
> +++ b/mm/filemap.c
> @@ -488,7 +488,7 @@ EXPORT_SYMBOL(filemap_fdatawait);
>  
>  int filemap_write_and_wait(struct address_space *mapping)
>  {
> -	int err = 0;
> +	int err;
>  
>  	if ((!dax_mapping(mapping) && mapping->nrpages) ||
>  	    (dax_mapping(mapping) && mapping->nrexceptional)) {
> @@ -499,10 +499,18 @@ int filemap_write_and_wait(struct address_space *mapping)
>  		 * But the -EIO is special case, it may indicate the worst
>  		 * thing (e.g. bug) happened, so we avoid waiting for it.
>  		 */
> -		if (err != -EIO) {
> +		if (likely(err != -EIO)) {

The above two cleanup changes were made only to filemap_write_and_wait(), but
should also probably be done to filemap_write_and_wait_range() to keep them as
consistent as possible?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
