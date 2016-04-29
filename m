Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 2F61A6B007E
	for <linux-mm@kvack.org>; Fri, 29 Apr 2016 15:08:07 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id e190so250607408pfe.3
        for <linux-mm@kvack.org>; Fri, 29 Apr 2016 12:08:07 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id j9si19421368paf.186.2016.04.29.12.08.06
        for <linux-mm@kvack.org>;
        Fri, 29 Apr 2016 12:08:06 -0700 (PDT)
Date: Fri, 29 Apr 2016 13:08:05 -0600
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: Re: [PATCH 11/18] dax: Fix condition for filling of PMD holes
Message-ID: <20160429190805.GF5888@linux.intel.com>
References: <1461015341-20153-1-git-send-email-jack@suse.cz>
 <1461015341-20153-12-git-send-email-jack@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1461015341-20153-12-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, linux-mm@kvack.org, Ross Zwisler <ross.zwisler@linux.intel.com>, Dan Williams <dan.j.williams@intel.com>, linux-nvdimm@lists.01.org, Matthew Wilcox <willy@linux.intel.com>

On Mon, Apr 18, 2016 at 11:35:34PM +0200, Jan Kara wrote:
> Currently dax_pmd_fault() decides to fill a PMD-sized hole only if
> returned buffer has BH_Uptodate set. However that doesn't get set for
> any mapping buffer so that branch is actually a dead code. The
> BH_Uptodate check doesn't make any sense so just remove it.

I'm not sure about this one.  In my testing (which was a while ago) I was
also never able to exercise this code path and create huge zero pages.   My
concern is that by removing the buffer_uptodate() check, we will all of a
sudden start running through a code path that was previously unreachable.

AFAICT the buffer_uptodate() was part of the original PMD commit.  Did we ever
get buffers with BH_Uptodate set?  Has this code ever been run?  Does it work?

I suppose this concern is mitigated by the fact that later in this series you 
disable the PMD path entirely, but maybe we should just leave it as is and
turn it off, then clean it up if/when we reenable it when we add multi-order
radix tree locking for PMDs?

> Signed-off-by: Jan Kara <jack@suse.cz>
> ---
>  fs/dax.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/fs/dax.c b/fs/dax.c
> index 237581441bc1..42bf65b4e752 100644
> --- a/fs/dax.c
> +++ b/fs/dax.c
> @@ -878,7 +878,7 @@ int __dax_pmd_fault(struct vm_area_struct *vma, unsigned long address,
>  		goto fallback;
>  	}
>  
> -	if (!write && !buffer_mapped(&bh) && buffer_uptodate(&bh)) {
> +	if (!write && !buffer_mapped(&bh)) {
>  		spinlock_t *ptl;
>  		pmd_t entry;
>  		struct page *zero_page = get_huge_zero_page();
> -- 
> 2.6.6
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
