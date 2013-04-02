Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx141.postini.com [74.125.245.141])
	by kanga.kvack.org (Postfix) with SMTP id 027BE6B0027
	for <linux-mm@kvack.org>; Tue,  2 Apr 2013 12:26:25 -0400 (EDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
In-Reply-To: <1363283435-7666-21-git-send-email-kirill.shutemov@linux.intel.com>
References: <1363283435-7666-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1363283435-7666-21-git-send-email-kirill.shutemov@linux.intel.com>
Subject: RE: [PATCHv2, RFC 20/30] ramfs: enable transparent huge page cache
Content-Transfer-Encoding: 7bit
Message-Id: <20130402162813.0B4CBE0085@blue.fi.intel.com>
Date: Tue,  2 Apr 2013 19:28:12 +0300 (EEST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Hillf Danton <dhillf@gmail.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Kirill A. Shutemov wrote:
> From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
> 
> ramfs is the most simple fs from page cache point of view. Let's start
> transparent huge page cache enabling here.
> 
> For now we allocate only non-movable huge page. It's not yet clear if
> movable page is safe here and what need to be done to make it safe.
> 
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> ---
>  fs/ramfs/inode.c |    6 +++++-
>  1 file changed, 5 insertions(+), 1 deletion(-)
> 
> diff --git a/fs/ramfs/inode.c b/fs/ramfs/inode.c
> index c24f1e1..da30b4f 100644
> --- a/fs/ramfs/inode.c
> +++ b/fs/ramfs/inode.c
> @@ -61,7 +61,11 @@ struct inode *ramfs_get_inode(struct super_block *sb,
>  		inode_init_owner(inode, dir, mode);
>  		inode->i_mapping->a_ops = &ramfs_aops;
>  		inode->i_mapping->backing_dev_info = &ramfs_backing_dev_info;
> -		mapping_set_gfp_mask(inode->i_mapping, GFP_HIGHUSER);
> +		/*
> +		 * TODO: what should be done to make movable safe?
> +		 */
> +		mapping_set_gfp_mask(inode->i_mapping,
> +				GFP_TRANSHUGE & ~__GFP_MOVABLE);

Hugh, I've found old thread with the reason why we have GFP_HIGHUSER here, not
GFP_HIGHUSER_MOVABLE:

http://lkml.org/lkml/2006/11/27/156

It seems the origin reason is not longer valid, correct?

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
