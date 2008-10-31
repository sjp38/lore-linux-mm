Date: Thu, 30 Oct 2008 17:48:14 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: mmotm 2008-10-30-02-23 uploaded (mm/ + fs/)
Message-Id: <20081030174814.cf900476.akpm@linux-foundation.org>
In-Reply-To: <20081030172700.35383b15.randy.dunlap@oracle.com>
References: <200810300924.m9U9OPqK030938@imap1.linux-foundation.org>
	<20081030172700.35383b15.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Randy Dunlap <randy.dunlap@oracle.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Dmitri Monakhov <dmonakhov@openvz.org>, Takashi Sato <t-sato@yk.jp.nec.com>
List-ID: <linux-mm.kvack.org>

On Thu, 30 Oct 2008 17:27:00 -0700
Randy Dunlap <randy.dunlap@oracle.com> wrote:

> On Thu, 30 Oct 2008 02:24:25 -0700 akpm@linux-foundation.org wrote:
> 
> > The mm-of-the-moment snapshot 2008-10-30-02-23 has been uploaded to
> > 
> >    http://userweb.kernel.org/~akpm/mmotm/
> > 
> > It contains the following patches against 2.6.28-rc2:
> 
> 
> mm/filemap.c: In function '__generic_file_aio_write_nolock':
> mm/filemap.c:2347: error: 'DIO_LOCKING' undeclared (first use in this function)
> mm/filemap.c: In function 'generic_file_aio_write_nolock':
> mm/filemap.c:2421: error: 'DIO_OWN_LOCKING' undeclared (first use in this function)
> mm/filemap.c: In function 'generic_file_aio_write':
> mm/filemap.c:2446: error: 'DIO_LOCKING' undeclared (first use in this function)

fs-truncate-blocks-outside-i_size-after-generic_file_direct_write-error.patch,
CONFIG_BLOCK=n.

That patch is a bit messy, carrying direct-io internals over into core
pagecache functions.  Dmitry, can we have another look at how to do
that?  Perhaps do the truncation back in direct-io.c?

> 
> fs/ioctl.c: In function 'ioctl_fsfreeze':
> fs/ioctl.c:460: error: implicit declaration of function 'freeze_bdev'
> fs/ioctl.c:460: warning: assignment makes pointer from integer without a cast
> fs/ioctl.c: In function 'ioctl_fsthaw':
> fs/ioctl.c:478: error: implicit declaration of function 'thaw_bdev'
> 

filesystem-freeze-implement-generic-freeze-feature.patch,
CONFIG_BLOCK=n.  Dunno, perhaps provide do-nothing stubs for
freeze_bdev() and thaw_bdev(), I guess.

--- a/include/linux/buffer_head.h~filesystem-freeze-implement-generic-freeze-feature-fix
+++ a/include/linux/buffer_head.h
@@ -345,6 +345,15 @@ static inline int remove_inode_buffers(s
 static inline int sync_mapping_buffers(struct address_space *mapping) { return 0; }
 static inline void invalidate_bdev(struct block_device *bdev) {}
 
+static inline struct super_block *freeze_bdev(struct block_device *sb)
+{
+	return NULL;
+}
+
+static inline int thaw_bdev(struct block_device *bdev, struct super_block *sb)
+{
+	return 0;
+}
 
 #endif /* CONFIG_BLOCK */
 #endif /* _LINUX_BUFFER_HEAD_H */
_


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
