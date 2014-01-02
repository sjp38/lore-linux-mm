Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f169.google.com (mail-pd0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id 12C806B0031
	for <linux-mm@kvack.org>; Thu,  2 Jan 2014 18:55:37 -0500 (EST)
Received: by mail-pd0-f169.google.com with SMTP id v10so14671690pde.14
        for <linux-mm@kvack.org>; Thu, 02 Jan 2014 15:55:37 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id sw1si43836896pab.344.2014.01.02.15.55.36
        for <linux-mm@kvack.org>;
        Thu, 02 Jan 2014 15:55:36 -0800 (PST)
Date: Thu, 2 Jan 2014 15:55:34 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 2/3] Add shrink_pagecache_parent
Message-Id: <20140102155534.9b0cd498209d835d0c93837e@linux-foundation.org>
In-Reply-To: <249cbd3edaa84dd58a0626780fb546ddf7c1dc11.1388409687.git.liwang@ubuntukylin.com>
References: <cover.1388409686.git.liwang@ubuntukylin.com>
	<249cbd3edaa84dd58a0626780fb546ddf7c1dc11.1388409687.git.liwang@ubuntukylin.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Li Wang <liwang@ubuntukylin.com>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Cong Wang <xiyou.wangcong@gmail.com>, Zefan Li <lizefan@huawei.com>, Matthew Wilcox <matthew@wil.cx>, Yunchuan Wen <yunchuanwen@ubuntukylin.com>, Dave Chinner <david@fromorbit.com>

On Mon, 30 Dec 2013 21:45:17 +0800 Li Wang <liwang@ubuntukylin.com> wrote:

> Analogous to shrink_dcache_parent except that it collects inodes.
> It is not very appropriate to be put in dcache.c, but d_walk can only
> be invoked from here.

Please cc Dave Chinner on future revisions.  He be da man.

The overall intent of the patchset seems reasonable and I agree that it
can't be efficiently done from userspace with the current kernel API. 
We *could* do it from userspace by providing facilities for userspace to
query the VFS caches: "is this pathname in the dentry cache" and "is
this inode in the inode cache".

> --- a/fs/dcache.c
> +++ b/fs/dcache.c
> @@ -1318,6 +1318,42 @@ void shrink_dcache_parent(struct dentry *parent)
>  }
>  EXPORT_SYMBOL(shrink_dcache_parent);
>  
> +static enum d_walk_ret gather_inode(void *data, struct dentry *dentry)
> +{
> +	struct list_head *list = data;
> +	struct inode *inode = dentry->d_inode;
> +
> +	if ((inode == NULL) || ((!inode_owner_or_capable(inode)) &&
> +				(!capable(CAP_SYS_ADMIN))))
> +		goto out;
> +	spin_lock(&inode->i_lock);
> +	if ((inode->i_state & (I_FREEING|I_WILL_FREE|I_NEW)) ||

It's unclear what rationale lies behind this particular group of tests.

> +		(inode->i_mapping->nrpages == 0) ||
> +		(!list_empty(&inode->i_lru))) {

arg, the "Inode locking rules" at the top of fs/inode.c needs a
refresh, I suspect.  It is too vague.

Formally, inode->i_lru is protected by
i_sb->s_inode_lru->node[nid].lock, not by ->i_lock.  I guess you can
just do a list_lru_add() and that will atomically add the inode to your
local list_lru if ->i_lru wasn't being used for anything else.

I *think* that your use of i_lock works OK, because code which fiddles
with i_lru and s_inode_lru also takes i_lock.  However we need to
decide which is the preferred and official lock.  ie: what is the
design here??

However...  most inodes will be on an LRU list, won't they?  Doesn't
this reuse of i_lru mean that many inodes will fail to be processed? 
If so, we might need to add a new list_head to the inode, which will be
problematic.


Aside: inode_lru_isolate() fiddles directly with inode->i_lru without
taking i_sb->s_inode_lru->node[nid].lock.  Why doesn't this make a
concurrent s_inode_lru walker go oops??  Should we be using
list_lru_del() in there?  (which should have been called
list_lru_del_init(), sigh).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
