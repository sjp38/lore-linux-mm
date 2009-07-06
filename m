Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 687126B005A
	for <linux-mm@kvack.org>; Mon,  6 Jul 2009 13:22:15 -0400 (EDT)
In-reply-to: <20090706165438.GQ2714@wotan.suse.de> (message from Nick Piggin
	on Mon, 6 Jul 2009 18:54:38 +0200)
Subject: Re: [rfc][patch 1/3] fs: new truncate sequence
References: <20090706165438.GQ2714@wotan.suse.de>
Message-Id: <E1MNsU3-0002Lx-8T@pomaz-ex.szeredi.hu>
From: Miklos Szeredi <miklos@szeredi.hu>
Date: Mon, 06 Jul 2009 20:00:07 +0200
Sender: owner-linux-mm@kvack.org
To: npiggin@suse.de
Cc: linux-fsdevel@vger.kernel.org, hch@infradead.org, jack@suse.cz, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> Index: linux-2.6/mm/truncate.c
> ===================================================================
> --- linux-2.6.orig/mm/truncate.c
> +++ linux-2.6/mm/truncate.c
> @@ -465,3 +465,79 @@ int invalidate_inode_pages2(struct addre
>  	return invalidate_inode_pages2_range(mapping, 0, -1);
>  }
>  EXPORT_SYMBOL_GPL(invalidate_inode_pages2);
> +
> +/**
> + * truncate_pagecache - unmap mappings "freed" by truncate() syscall
> + * @inode: inode
> + * @old: old file offset
> + * @new: new file offset
> + *
> + * inode's new i_size must already be written before truncate_pagecache
> + * is called.
> + */
> +void truncate_pagecache(struct inode * inode, loff_t old, loff_t new)
> +{
> +	VM_BUG_ON(inode->i_size != new);

This is not true for fuse (and NFS?) as i_size isn't protected by
i_mutex during attribute revalidation, and so it can change during the
truncate.

Thanks,
Miklos

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
