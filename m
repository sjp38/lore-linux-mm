Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f177.google.com (mail-we0-f177.google.com [74.125.82.177])
	by kanga.kvack.org (Postfix) with ESMTP id D16F86B0038
	for <linux-mm@kvack.org>; Sun,  1 Feb 2015 01:31:28 -0500 (EST)
Received: by mail-we0-f177.google.com with SMTP id l61so33638064wev.8
        for <linux-mm@kvack.org>; Sat, 31 Jan 2015 22:31:28 -0800 (PST)
Received: from ZenIV.linux.org.uk (zeniv.linux.org.uk. [2002:c35c:fd02::1])
        by mx.google.com with ESMTPS id bc4si18893170wib.96.2015.01.31.22.31.26
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sat, 31 Jan 2015 22:31:27 -0800 (PST)
Date: Sun, 1 Feb 2015 06:31:16 +0000
From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: backing_dev_info cleanups & lifetime rule fixes V2
Message-ID: <20150201063116.GP29656@ZenIV.linux.org.uk>
References: <1421228561-16857-1-git-send-email-hch@lst.de>
 <54BEC3C2.7080906@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <54BEC3C2.7080906@fb.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jens Axboe <axboe@fb.com>
Cc: Christoph Hellwig <hch@lst.de>, David Howells <dhowells@redhat.com>, Tejun Heo <tj@kernel.org>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-mtd@lists.infradead.org, linux-nfs@vger.kernel.org, ceph-devel@vger.kernel.org

On Tue, Jan 20, 2015 at 02:08:18PM -0700, Jens Axboe wrote:
> On 01/14/2015 02:42 AM, Christoph Hellwig wrote:
> >The first 8 patches are unchanged from the series posted a week ago and
> >cleans up how we use the backing_dev_info structure in preparation for
> >fixing the life time rules for it.  The most important change is to
> >split the unrelated nommu mmap flags from it, but it also remove a
> >backing_dev_info pointer from the address_space (and thus the inode)
> >and cleans up various other minor bits.
> >
> >The remaining patches sort out the issues around bdi_unlink and now
> >let the bdi life until it's embedding structure is freed, which must
> >be equal or longer than the superblock using the bdi for writeback,
> >and thus gets rid of the whole mess around reassining inodes to new
> >bdis.
> >
> >Changes since V1:
> >  - various minor documentation updates based on Feedback from Tejun
> 
> I applied this to for-3.20/bdi, only making the change (noticed by
> Jan) to kill the extra WARN_ON() in patch #11.

And at that point we finally can make sb_lock and super_blocks static in
fs/super.c.  Do you want that in your tree, or would you rather have it
done via vfs.git during the merge window after your tree goes in?  It's
as trivial as this:

Make super_blocks and sb_lock static

The only user outside of fs/super.c is gone now

Signed-off-by: Al Viro <viro@zeniv.linux.org.uk>
---
diff --git a/fs/super.c b/fs/super.c
index eae088f..91badbb 100644
--- a/fs/super.c
+++ b/fs/super.c
@@ -36,8 +36,8 @@
 #include "internal.h"
 
 
-LIST_HEAD(super_blocks);
-DEFINE_SPINLOCK(sb_lock);
+static LIST_HEAD(super_blocks);
+static DEFINE_SPINLOCK(sb_lock);
 
 static char *sb_writers_name[SB_FREEZE_LEVELS] = {
 	"sb_writers",
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 1f3c439..efc384e 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -1184,8 +1184,6 @@ struct mm_struct;
 #define UMOUNT_NOFOLLOW	0x00000008	/* Don't follow symlink on umount */
 #define UMOUNT_UNUSED	0x80000000	/* Flag guaranteed to be unused */
 
-extern struct list_head super_blocks;
-extern spinlock_t sb_lock;
 
 /* Possible states of 'frozen' field */
 enum {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
