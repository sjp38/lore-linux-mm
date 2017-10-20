Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 7FEFB6B0038
	for <linux-mm@kvack.org>; Fri, 20 Oct 2017 08:39:21 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id u27so10071008pfg.12
        for <linux-mm@kvack.org>; Fri, 20 Oct 2017 05:39:21 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id m63si579184pld.191.2017.10.20.05.39.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 20 Oct 2017 05:39:20 -0700 (PDT)
Message-ID: <1508503151.5572.27.camel@kernel.org>
Subject: Re: [PATCH v3 11/13] fs: use smp_load_acquire in
 break_{layout,lease}
From: Jeffrey Layton <jlayton@kernel.org>
Date: Fri, 20 Oct 2017 08:39:11 -0400
In-Reply-To: <150846719726.24336.3564801642993121646.stgit@dwillia2-desk3.amr.corp.intel.com>
References: 
	<150846713528.24336.4459262264611579791.stgit@dwillia2-desk3.amr.corp.intel.com>
	 <150846719726.24336.3564801642993121646.stgit@dwillia2-desk3.amr.corp.intel.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>, akpm@linux-foundation.org
Cc: linux-xfs@vger.kernel.org, linux-nvdimm@lists.01.org, linux-kernel@vger.kernel.org, hch@lst.de, "J. Bruce Fields" <bfields@fieldses.org>, linux-mm@kvack.org, Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, Ross Zwisler <ross.zwisler@linux.intel.com>

On Thu, 2017-10-19 at 19:39 -0700, Dan Williams wrote:
> Commit 128a37852234 "fs: fix data races on inode->i_flctx" converted
> checks of inode->i_flctx to use smp_load_acquire(), but it did not
> convert break_layout(). smp_load_acquire() includes a READ_ONCE(). There
> should be no functional difference since __break_lease repeats the
> sequence, but this is a clean up to unify all ->i_flctx lookups on a
> common pattern.
> 
> Cc: Christoph Hellwig <hch@lst.de>
> Cc: Alexander Viro <viro@zeniv.linux.org.uk>
> Cc: Ross Zwisler <ross.zwisler@linux.intel.com>
> Cc: Jeff Layton <jlayton@poochiereds.net>
> Cc: "J. Bruce Fields" <bfields@fieldses.org>
> Signed-off-by: Dan Williams <dan.j.williams@intel.com>
> ---
>  include/linux/fs.h |   10 ++++++----
>  1 file changed, 6 insertions(+), 4 deletions(-)
> 
> diff --git a/include/linux/fs.h b/include/linux/fs.h
> index 13dab191a23e..eace2c5396a7 100644
> --- a/include/linux/fs.h
> +++ b/include/linux/fs.h
> @@ -2281,8 +2281,9 @@ static inline int break_lease(struct inode *inode, unsigned int mode)
>  	 * could end up racing with tasks trying to set a new lease on this
>  	 * file.
>  	 */
> -	smp_mb();
> -	if (inode->i_flctx && !list_empty_careful(&inode->i_flctx->flc_lease))
> +	struct file_lock_context *ctx = smp_load_acquire(&inode->i_flctx);
> +
> +	if (ctx && !list_empty_careful(&ctx->flc_lease))
>  		return __break_lease(inode, mode, FL_LEASE);
>  	return 0;
>  }
> @@ -2325,8 +2326,9 @@ static inline int break_deleg_wait(struct inode **delegated_inode)
>  
>  static inline int break_layout(struct inode *inode, bool wait)
>  {
> -	smp_mb();
> -	if (inode->i_flctx && !list_empty_careful(&inode->i_flctx->flc_lease))
> +	struct file_lock_context *ctx = smp_load_acquire(&inode->i_flctx);
> +
> +	if (ctx && !list_empty_careful(&ctx->flc_lease))
>  		return __break_lease(inode,
>  				wait ? O_WRONLY : O_WRONLY | O_NONBLOCK,
>  				FL_LAYOUT);
> 

Nice catch. This can go in independently of the rest of the patches in
the series, I think. I'll assume Andrew is picking this up since he's in
the "To:", but let me know if you need me to get it.

Reviewed-by: Jeff Layton <jlayton@kernel.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
