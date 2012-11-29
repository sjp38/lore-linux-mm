Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx202.postini.com [74.125.245.202])
	by kanga.kvack.org (Postfix) with SMTP id CE7E16B0088
	for <linux-mm@kvack.org>; Wed, 28 Nov 2012 20:29:42 -0500 (EST)
Received: by mail-ia0-f169.google.com with SMTP id r4so12865995iaj.14
        for <linux-mm@kvack.org>; Wed, 28 Nov 2012 17:29:42 -0800 (PST)
Date: Thu, 29 Nov 2012 09:29:33 +0800
From: Jaegeuk Hanse <jaegeuk.hanse@gmail.com>
Subject: Re: [PATCH] tmpfs: support SEEK_DATA and SEEK_HOLE (reprise)
Message-ID: <20121129012933.GA9112@kernel>
Reply-To: Jaegeuk Hanse <jaegeuk.hanse@gmail.com>
References: <alpine.LNX.2.00.1211281706390.1516@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LNX.2.00.1211281706390.1516@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Theodore Ts'o <tytso@mit.edu>, Zheng Liu <wenqing.lz@taobao.com>, Jeff liu <jeff.liu@oracle.com>, Jim Meyering <jim@meyering.net>, Paul Eggert <eggert@cs.ucla.edu>, Christoph Hellwig <hch@infradead.org>, Josef Bacik <josef@redhat.com>, Andi Kleen <andi@firstfloor.org>, Andreas Dilger <adilger@dilger.ca>, Dave Chinner <david@fromorbit.com>, Marco Stornelli <marco.stornelli@gmail.com>, Chris Mason <chris.mason@fusionio.com>, Sunil Mushran <sunil.mushran@oracle.com>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

On Wed, Nov 28, 2012 at 05:22:03PM -0800, Hugh Dickins wrote:
>Revert 3.5's f21f8062201f ("tmpfs: revert SEEK_DATA and SEEK_HOLE")
>to reinstate 4fb5ef089b28 ("tmpfs: support SEEK_DATA and SEEK_HOLE"),
>with the intervening additional arg to generic_file_llseek_size().
>
>In 3.8, ext4 is expected to join btrfs, ocfs2 and xfs with proper
>SEEK_DATA and SEEK_HOLE support; and a good case has now been made
>for it on tmpfs, so let's join the party.
>

Hi Hugh,

IIUC, several months ago you revert the patch. You said, 

"I don't know who actually uses SEEK_DATA or SEEK_HOLE, and whether it
would be of any use to them on tmpfs.  This code adds 92 lines and 752
bytes on x86_64 - is that bloat or worthwhile?"

But this time in which scenario will use it?

Regards,
Jaegeuk

>It's quite easy for tmpfs to scan the radix_tree to support llseek's new
>SEEK_DATA and SEEK_HOLE options: so add them while the minutiae are still
>on my mind (in particular, the !PageUptodate-ness of pages fallocated but
>still unwritten).
>
>[akpm@linux-foundation.org: fix warning with CONFIG_TMPFS=n]
>Signed-off-by: Hugh Dickins <hughd@google.com>
>---
>
> mm/shmem.c |   92 ++++++++++++++++++++++++++++++++++++++++++++++++++-
> 1 file changed, 91 insertions(+), 1 deletion(-)
>
>--- 3.7-rc7/mm/shmem.c	2012-11-16 19:26:56.388459961 -0800
>+++ linux/mm/shmem.c	2012-11-28 15:53:38.788477201 -0800
>@@ -1709,6 +1709,96 @@ static ssize_t shmem_file_splice_read(st
> 	return error;
> }
> 
>+/*
>+ * llseek SEEK_DATA or SEEK_HOLE through the radix_tree.
>+ */
>+static pgoff_t shmem_seek_hole_data(struct address_space *mapping,
>+				    pgoff_t index, pgoff_t end, int origin)
>+{
>+	struct page *page;
>+	struct pagevec pvec;
>+	pgoff_t indices[PAGEVEC_SIZE];
>+	bool done = false;
>+	int i;
>+
>+	pagevec_init(&pvec, 0);
>+	pvec.nr = 1;		/* start small: we may be there already */
>+	while (!done) {
>+		pvec.nr = shmem_find_get_pages_and_swap(mapping, index,
>+					pvec.nr, pvec.pages, indices);
>+		if (!pvec.nr) {
>+			if (origin == SEEK_DATA)
>+				index = end;
>+			break;
>+		}
>+		for (i = 0; i < pvec.nr; i++, index++) {
>+			if (index < indices[i]) {
>+				if (origin == SEEK_HOLE) {
>+					done = true;
>+					break;
>+				}
>+				index = indices[i];
>+			}
>+			page = pvec.pages[i];
>+			if (page && !radix_tree_exceptional_entry(page)) {
>+				if (!PageUptodate(page))
>+					page = NULL;
>+			}
>+			if (index >= end ||
>+			    (page && origin == SEEK_DATA) ||
>+			    (!page && origin == SEEK_HOLE)) {
>+				done = true;
>+				break;
>+			}
>+		}
>+		shmem_deswap_pagevec(&pvec);
>+		pagevec_release(&pvec);
>+		pvec.nr = PAGEVEC_SIZE;
>+		cond_resched();
>+	}
>+	return index;
>+}
>+
>+static loff_t shmem_file_llseek(struct file *file, loff_t offset, int origin)
>+{
>+	struct address_space *mapping = file->f_mapping;
>+	struct inode *inode = mapping->host;
>+	pgoff_t start, end;
>+	loff_t new_offset;
>+
>+	if (origin != SEEK_DATA && origin != SEEK_HOLE)
>+		return generic_file_llseek_size(file, offset, origin,
>+					MAX_LFS_FILESIZE, i_size_read(inode));
>+	mutex_lock(&inode->i_mutex);
>+	/* We're holding i_mutex so we can access i_size directly */
>+
>+	if (offset < 0)
>+		offset = -EINVAL;
>+	else if (offset >= inode->i_size)
>+		offset = -ENXIO;
>+	else {
>+		start = offset >> PAGE_CACHE_SHIFT;
>+		end = (inode->i_size + PAGE_CACHE_SIZE - 1) >> PAGE_CACHE_SHIFT;
>+		new_offset = shmem_seek_hole_data(mapping, start, end, origin);
>+		new_offset <<= PAGE_CACHE_SHIFT;
>+		if (new_offset > offset) {
>+			if (new_offset < inode->i_size)
>+				offset = new_offset;
>+			else if (origin == SEEK_DATA)
>+				offset = -ENXIO;
>+			else
>+				offset = inode->i_size;
>+		}
>+	}
>+
>+	if (offset >= 0 && offset != file->f_pos) {
>+		file->f_pos = offset;
>+		file->f_version = 0;
>+	}
>+	mutex_unlock(&inode->i_mutex);
>+	return offset;
>+}
>+
> static long shmem_fallocate(struct file *file, int mode, loff_t offset,
> 							 loff_t len)
> {
>@@ -2580,7 +2670,7 @@ static const struct address_space_operat
> static const struct file_operations shmem_file_operations = {
> 	.mmap		= shmem_mmap,
> #ifdef CONFIG_TMPFS
>-	.llseek		= generic_file_llseek,
>+	.llseek		= shmem_file_llseek,
> 	.read		= do_sync_read,
> 	.write		= do_sync_write,
> 	.aio_read	= shmem_file_aio_read,
>
>--
>To unsubscribe, send a message with 'unsubscribe linux-mm' in
>the body to majordomo@kvack.org.  For more info on Linux MM,
>see: http://www.linux-mm.org/ .
>Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
