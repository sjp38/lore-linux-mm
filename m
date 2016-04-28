Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id B3ABA6B007E
	for <linux-mm@kvack.org>; Wed, 27 Apr 2016 21:38:55 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id 203so115952643pfy.2
        for <linux-mm@kvack.org>; Wed, 27 Apr 2016 18:38:55 -0700 (PDT)
Received: from mail-pf0-x22d.google.com (mail-pf0-x22d.google.com. [2607:f8b0:400e:c00::22d])
        by mx.google.com with ESMTPS id ya3si12804294pab.2.2016.04.27.18.38.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Apr 2016 18:38:54 -0700 (PDT)
Received: by mail-pf0-x22d.google.com with SMTP id n1so30379965pfn.2
        for <linux-mm@kvack.org>; Wed, 27 Apr 2016 18:38:54 -0700 (PDT)
Date: Thu, 28 Apr 2016 10:40:28 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH] mm/zswap: use workqueue to destroy pool
Message-ID: <20160428014028.GA594@swordfish>
References: <1461619210-10057-1-git-send-email-ddstreet@ieee.org>
 <1461704891-15272-1-git-send-email-ddstreet@ieee.org>
 <20160427005853.GD4782@swordfish>
 <CALZtONArGwmaWNcHJODmY1uXm306NiqeZtRekfCFgZsMz_cngw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALZtONArGwmaWNcHJODmY1uXm306NiqeZtRekfCFgZsMz_cngw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Streetman <ddstreet@ieee.org>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Yu Zhao <yuzhao@google.com>, Andrew Morton <akpm@linux-foundation.org>, Seth Jennings <sjenning@redhat.com>, Minchan Kim <minchan@kernel.org>, Nitin Gupta <ngupta@vflare.org>, Linux-MM <linux-mm@kvack.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, linux-kernel <linux-kernel@vger.kernel.org>, Dan Streetman <dan.streetman@canonical.com>

Hello Dan,

On (04/27/16 13:19), Dan Streetman wrote:
[..]
> > so in general the patch look good to me.
> >
> > it's either I didn't have enough coffee yet (which is true) or
> > _IN THEORY_ it creates a tiny race condition; which is hard (and
> > unlikely) to hit, but still. and the problem being is
> > CONFIG_ZSMALLOC_STAT.
> 
> Aha, thanks, I hadn't tested with that param enabled.  However, the
> patch doesn't create the race condition, that existed already.

well, agree. it's not like zsmalloc race condition, but the way zsmalloc
is managed (deferred destruction either via rcu or scheduled work).

> It fails because the new zswap pool creates a new zpool using
> zsmalloc, but it can't create the zsmalloc pool because there is
> already one named 'zswap' so the stat dir can't be created.
> 
> So...either zswap needs to provide a unique 'name' to each of its
> zpools, or zsmalloc needs to modify its provided pool name in some way
> (add a unique suffix maybe).  Or both.
> 
> It seems like zsmalloc should do the checking/modification - or, at
> the very least, it should have consistent behavior regardless of the
> CONFIG_ZSMALLOC_STAT setting.

yes, zram guarantees that there won't be any name collisions. and the
way it's working for zram, zram<ID> corresponds to zsmalloc<ID>.


the bigger issue here (and I was thinking at some point of fixing it,
but then I grepped to see how many API users are in there, and I gave
up) is that it seems we have no way to check if the dir exists in debugfs.

we call this function

struct dentry *debugfs_create_dir(const char *name, struct dentry *parent)
{
	struct dentry *dentry = start_creating(name, parent);
	struct inode *inode;

	if (IS_ERR(dentry))
		return NULL;

	inode = debugfs_get_inode(dentry->d_sb);
	if (unlikely(!inode))
		return failed_creating(dentry);

	inode->i_mode = S_IFDIR | S_IRWXU | S_IRUGO | S_IXUGO;
	inode->i_op = &simple_dir_inode_operations;
	inode->i_fop = &simple_dir_operations;

	/* directory inodes start off with i_nlink == 2 (for "." entry) */
	inc_nlink(inode);
	d_instantiate(dentry, inode);
	inc_nlink(d_inode(dentry->d_parent));
	fsnotify_mkdir(d_inode(dentry->d_parent), dentry);
	return end_creating(dentry);
}

and debugfs _does know_ that the directory ERR_PTR(-EEXIST), that's what
start_creating()->lookup_one_len() return

static struct dentry *start_creating(const char *name, struct dentry *parent)
{
	struct dentry *dentry;
	int error;

	pr_debug("debugfs: creating file '%s'\n",name);

	if (IS_ERR(parent))
		return parent;

	error = simple_pin_fs(&debug_fs_type, &debugfs_mount,
			      &debugfs_mount_count);
	if (error)
		return ERR_PTR(error);

	/* If the parent is not specified, we create it in the root.
	 * We need the root dentry to do this, which is in the super
	 * block. A pointer to that is in the struct vfsmount that we
	 * have around.
	 */
	if (!parent)
		parent = debugfs_mount->mnt_root;

	inode_lock(d_inode(parent));
	dentry = lookup_one_len(name, parent, strlen(name));
	if (!IS_ERR(dentry) && d_really_is_positive(dentry)) {
		dput(dentry);
		dentry = ERR_PTR(-EEXIST);
	}

	if (IS_ERR(dentry)) {
		inode_unlock(d_inode(parent));
		simple_release_fs(&debugfs_mount, &debugfs_mount_count);
	}

	return dentry;
}

but debugfs_create_dir() instead of propagating this error, it swallows it
and simply return NULL, so we can't tell the difference between -EEXIST, OOM,
or anything else. so doing this check in zsmalloc() is not so easy.

/* well, I may be wrong here */

> However, it's easy to change zswap to provide a unique name for each
> zpool creation, and zsmalloc's primary user (zram) guarantees to
> provide a unique name for each pool created. So updating zswap is
> probably best.

if you can do it in zswap, then please do.

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
