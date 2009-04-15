Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 33B345F0001
	for <linux-mm@kvack.org>; Wed, 15 Apr 2009 18:06:33 -0400 (EDT)
Date: Wed, 15 Apr 2009 14:59:10 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] hugetlbfs: return negative error code for bad mount
 option
Message-Id: <20090415145910.22910363.akpm@linux-foundation.org>
In-Reply-To: <20090413035623.GA4156@localhost.localdomain>
References: <20090413035623.GA4156@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Akinobu Mita <akinobu.mita@gmail.com>
Cc: linux-kernel@vger.kernel.org, wli@holomorphy.com, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, stable@kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, 13 Apr 2009 12:56:23 +0900
Akinobu Mita <akinobu.mita@gmail.com> wrote:

> This fixes the following BUG:
> 
> # mount -o size=MM -t hugetlbfs none /huge
> hugetlbfs: Bad value 'MM' for mount option 'size=MM'
> ------------[ cut here ]------------
> kernel BUG at fs/super.c:996!

I can't tell where this BUG (or WARN?) is happening unless I know
exactly which kernel version was tested.

I assume that it is BUG_ON(!mnt->mnt_sb); in vfs_kern_mount()?

> Also, remove unused #include <linux/quotaops.h>
> 
> Cc: William Irwin <wli@holomorphy.com>
> Cc: stable@kernel.org
> Signed-off-by: Akinobu Mita <akinobu.mita@gmail.com>
> ---
> 
> diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
> index 23a3c76..153d968 100644
> --- a/fs/hugetlbfs/inode.c
> +++ b/fs/hugetlbfs/inode.c
> @@ -26,7 +26,6 @@
>  #include <linux/pagevec.h>
>  #include <linux/parser.h>
>  #include <linux/mman.h>
> -#include <linux/quotaops.h>
>  #include <linux/slab.h>
>  #include <linux/dnotify.h>
>  #include <linux/statfs.h>
> @@ -842,7 +841,7 @@ hugetlbfs_parse_options(char *options, struct hugetlbfs_config *pconfig)
>  bad_val:
>   	printk(KERN_ERR "hugetlbfs: Bad value '%s' for mount option '%s'\n",
>  	       args[0].from, p);
> - 	return 1;
> + 	return -EINVAL;
>  }
>  
>  static int

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
