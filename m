Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 158876B7FA5
	for <linux-mm@kvack.org>; Fri,  7 Sep 2018 14:04:32 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id a23-v6so7795949pfo.23
        for <linux-mm@kvack.org>; Fri, 07 Sep 2018 11:04:32 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 8-v6sor1669977pgw.42.2018.09.07.11.04.30
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 07 Sep 2018 11:04:30 -0700 (PDT)
Date: Fri, 7 Sep 2018 11:04:28 -0700
From: Omar Sandoval <osandov@osandov.com>
Subject: Re: [PATCH v6 6/6] Btrfs: support swap files
Message-ID: <20180907180428.GA29245@vader>
References: <cover.1536305017.git.osandov@fb.com>
 <77442bbbad9ebc37f3b72a47ca983a3a805e0718.1536305017.git.osandov@fb.com>
 <401845b3-f7b9-7dfb-dc9b-42350daff44e@suse.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <401845b3-f7b9-7dfb-dc9b-42350daff44e@suse.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nikolay Borisov <nborisov@suse.com>
Cc: linux-btrfs@vger.kernel.org, kernel-team@fb.com, linux-mm@kvack.org

On Fri, Sep 07, 2018 at 11:39:25AM +0300, Nikolay Borisov wrote:
> 
> 
> On  7.09.2018 10:39, Omar Sandoval wrote:
> > From: Omar Sandoval <osandov@fb.com>
> > 
> > Implement the swap file a_ops on Btrfs. Activation needs to make sure
> > that the file can be used as a swap file, which currently means it must
> > be fully allocated as nocow with no compression on one device. It must
> > also do the proper tracking so that ioctls will not interfere with the
> > swap file. Deactivation clears this tracking.
> > 
> > Signed-off-by: Omar Sandoval <osandov@fb.com>
> > ---
> >  fs/btrfs/inode.c | 316 +++++++++++++++++++++++++++++++++++++++++++++++
> >  1 file changed, 316 insertions(+)
> > 
> > diff --git a/fs/btrfs/inode.c b/fs/btrfs/inode.c
> > index 9357a19d2bff..55aba2d7074c 100644
> > --- a/fs/btrfs/inode.c
> > +++ b/fs/btrfs/inode.c
> > @@ -27,6 +27,7 @@
> >  #include <linux/uio.h>
> >  #include <linux/magic.h>
> >  #include <linux/iversion.h>
> > +#include <linux/swap.h>
> >  #include <asm/unaligned.h>
> >  #include "ctree.h"
> >  #include "disk-io.h"
> > @@ -10437,6 +10438,319 @@ void btrfs_set_range_writeback(struct extent_io_tree *tree, u64 start, u64 end)
> >  	}
> >  }
> >  
> > +/*
> > + * Add an entry indicating a block group or device which is pinned by a
> > + * swapfile. Returns 0 on success, 1 if there is already an entry for it, or a
> > + * negative errno on failure.
> > + */
> > +static int btrfs_add_swapfile_pin(struct inode *inode, void *ptr,
> > +				  bool is_block_group)
> > +{
> > +	struct btrfs_fs_info *fs_info = BTRFS_I(inode)->root->fs_info;
> > +	struct btrfs_swapfile_pin *sp, *entry;
> > +	struct rb_node **p;
> > +	struct rb_node *parent = NULL;
> > +
> > +	sp = kmalloc(sizeof(*sp), GFP_NOFS);
> > +	if (!sp)
> > +		return -ENOMEM;
> > +	sp->ptr = ptr;
> > +	sp->inode = inode;
> > +	sp->is_block_group = is_block_group;
> > +
> > +	spin_lock(&fs_info->swapfile_pins_lock);
> > +	p = &fs_info->swapfile_pins.rb_node;
> > +	while (*p) {
> > +		parent = *p;
> > +		entry = rb_entry(parent, struct btrfs_swapfile_pin, node);
> > +		if (sp->ptr < entry->ptr ||
> > +		    (sp->ptr == entry->ptr && sp->inode < entry->inode)) {
> > +			p = &(*p)->rb_left;
> > +		} else if (sp->ptr > entry->ptr ||
> > +			   (sp->ptr == entry->ptr && sp->inode > entry->inode)) {
> > +			p = &(*p)->rb_right;
> > +		} else {
> > +			spin_unlock(&fs_info->swapfile_pins_lock);
> > +			kfree(sp);
> > +			return 1;
> > +		}
> 
> 
> I have to admit this is creative use of pointers but I dislike it:
> 
> 1. You are not really doing an interval tree of any sorts so rb seems a
> bit of an overkill. How many block groups/devices do you expect to have
> in the rb tree i.e how many swap files per file system so that the logn
> search behavior really matter? Why not a simple linked list and just an
> equality comparison of pointers?

We know there's at least one block group per gigabyte of swap, but there
can be many more if the file is fragmented. We could probably get away
with a linked list in most cases, but the number of entries is only
bounded by the size of the filesystem * number of swapfiles. With a
linked list, checking n block groups for balance becomes O(n^2) instead
of O(n * log n), so I'd rather be on the safe side here. The rbtree
manipulation isn't that much more complicated than using a linked list,
after all.

> 2. The code self-admits that using pointers for lt/gr comparison is a
> hack since in case pointers match you fall back to checking the inode
> pointer

It's not a fallback. A block group or device can contain more than one
swapfile, so it's really a separate entry.

> 3. There is a discrepancy between the keys used for adding (ptr + inode)
> and deletion (just inode)

Well, yeah, we add an entry that says block group/device X is pinned by
inode Y, and we delete all of the entries pinned by inode Y.

> At the very  least this hack needs to be at least mentioned in the
> changelog.

I'll add these comments:

diff --git a/fs/btrfs/ctree.h b/fs/btrfs/ctree.h
index e37ce40db380..1c258ee4be24 100644
--- a/fs/btrfs/ctree.h
+++ b/fs/btrfs/ctree.h
@@ -719,6 +719,11 @@ struct btrfs_delayed_root;
 /*
  * Block group or device which contains an active swapfile. Used for preventing
  * unsafe operations while a swapfile is active.
+ *
+ * These are sorted on (ptr, inode) (note that a block group or device can
+ * contain more than one swapfile). We compare the pointer values because we
+ * don't actually care what the object is, we just need a quick check whether
+ * the object exists in the rbtree.
  */
 struct btrfs_swapfile_pin {
 	struct rb_node node;
diff --git a/fs/btrfs/inode.c b/fs/btrfs/inode.c
index 55aba2d7074c..e103e81c6533 100644
--- a/fs/btrfs/inode.c
+++ b/fs/btrfs/inode.c
@@ -10481,6 +10481,7 @@ static int btrfs_add_swapfile_pin(struct inode *inode, void *ptr,
 	return 0;
 }
 
+/* Free all of the entries pinned by this swapfile. */
 static void btrfs_free_swapfile_pins(struct inode *inode)
 {
 	struct btrfs_fs_info *fs_info = BTRFS_I(inode)->root->fs_info;
diff --git a/fs/btrfs/volumes.c b/fs/btrfs/volumes.c
index 514932c47bcd..062ad86358ad 100644
--- a/fs/btrfs/volumes.c
+++ b/fs/btrfs/volumes.c
@@ -7545,6 +7545,10 @@ int btrfs_verify_dev_extents(struct btrfs_fs_info *fs_info)
 	return ret;
 }
 
+/*
+ * Check whether the given block group or device is pinned by any inode being
+ * used as a swapfile.
+ */
 bool btrfs_pinned_by_swapfile(struct btrfs_fs_info *fs_info, void *ptr)
 {
 	struct btrfs_swapfile_pin *sp;
