Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 152816B0036
	for <linux-mm@kvack.org>; Tue, 15 Oct 2013 07:09:13 -0400 (EDT)
Received: by mail-pa0-f44.google.com with SMTP id lf10so8845244pab.31
        for <linux-mm@kvack.org>; Tue, 15 Oct 2013 04:09:12 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
In-Reply-To: <20131015001826.GL3432@hippobay.mtv.corp.google.com>
References: <20131015001826.GL3432@hippobay.mtv.corp.google.com>
Subject: RE: [PATCH 11/12] mm, thp, tmpfs: enable thp page cache in tmpfs
Content-Transfer-Encoding: 7bit
Message-Id: <20131015110905.085B1E0090@blue.fi.intel.com>
Date: Tue, 15 Oct 2013 14:09:04 +0300 (EEST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ning Qu <quning@gmail.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>, Al Viro <viro@zeniv.linux.org.uk>Hugh Dickins <hughd@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <willy@linux.intel.com>, Hillf Danton <dhillf@gmail.com>, Dave Hansen <dave@sr71.net>, Alexander Shishkin <alexander.shishkin@linux.intel.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, Ning Qu <quning@google.com>

Ning Qu wrote:
> Signed-off-by: Ning Qu <quning@gmail.com>
> ---
>  mm/Kconfig | 4 ++--
>  mm/shmem.c | 5 +++++
>  2 files changed, 7 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/Kconfig b/mm/Kconfig
> index 562f12f..4d2f90f 100644
> --- a/mm/Kconfig
> +++ b/mm/Kconfig
> @@ -428,8 +428,8 @@ config TRANSPARENT_HUGEPAGE_PAGECACHE
>  	help
>  	  Enabling the option adds support hugepages for file-backed
>  	  mappings. It requires transparent hugepage support from
> -	  filesystem side. For now, the only filesystem which supports
> -	  hugepages is ramfs.
> +	  filesystem side. For now, the filesystems which support
> +	  hugepages are: ramfs and tmpfs.
>  
>  config CROSS_MEMORY_ATTACH
>  	bool "Cross Memory Support"
> diff --git a/mm/shmem.c b/mm/shmem.c
> index 75c0ac6..50a3335 100644
> --- a/mm/shmem.c
> +++ b/mm/shmem.c
> @@ -1672,6 +1672,11 @@ static struct inode *shmem_get_inode(struct super_block *sb, const struct inode
>  			break;
>  		case S_IFREG:
>  			inode->i_mapping->a_ops = &shmem_aops;
> +			/*
> +			 * TODO: make tmpfs pages movable
> +			 */
> +			mapping_set_gfp_mask(inode->i_mapping,
> +					     GFP_TRANSHUGE & ~__GFP_MOVABLE);

Unlike ramfs, tmpfs pages are movable before transparent page cache
patchset.
Making tmpfs pages non-movable looks like a big regression to me. It need
to be fixed before proposing it upstream.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
