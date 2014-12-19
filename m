Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 165B96B0038
	for <linux-mm@kvack.org>; Fri, 19 Dec 2014 01:24:12 -0500 (EST)
Received: by mail-pa0-f54.google.com with SMTP id fb1so546425pad.41
        for <linux-mm@kvack.org>; Thu, 18 Dec 2014 22:24:11 -0800 (PST)
Received: from mail-pd0-f176.google.com (mail-pd0-f176.google.com. [209.85.192.176])
        by mx.google.com with ESMTPS id ty10si13136382pbc.66.2014.12.18.22.24.09
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 18 Dec 2014 22:24:10 -0800 (PST)
Received: by mail-pd0-f176.google.com with SMTP id r10so551623pdi.35
        for <linux-mm@kvack.org>; Thu, 18 Dec 2014 22:24:09 -0800 (PST)
Date: Thu, 18 Dec 2014 22:24:05 -0800
From: Omar Sandoval <osandov@osandov.com>
Subject: Re: [PATCH 2/8] swap: lock i_mutex for swap_writepage direct_IO
Message-ID: <20141219062405.GA11486@mew>
References: <20141215165615.GA19041@infradead.org>
 <20141215221100.GA4637@mew>
 <20141216083543.GA32425@infradead.org>
 <20141216085624.GA25256@mew>
 <20141217080610.GA20335@infradead.org>
 <20141217082020.GH22149@ZenIV.linux.org.uk>
 <20141217082437.GA9301@infradead.org>
 <20141217145832.GA3497@mew>
 <20141217185256.GA5657@infradead.org>
 <20141217220313.GK22149@ZenIV.linux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20141217220313.GK22149@ZenIV.linux.org.uk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Al Viro <viro@ZenIV.linux.org.uk>
Cc: Christoph Hellwig <hch@infradead.org>, Jan Kara <jack@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Trond Myklebust <trond.myklebust@primarydata.com>, David Sterba <dsterba@suse.cz>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed, Dec 17, 2014 at 10:03:13PM +0000, Al Viro wrote:
> On Wed, Dec 17, 2014 at 10:52:56AM -0800, Christoph Hellwig wrote:
> > On Wed, Dec 17, 2014 at 06:58:32AM -0800, Omar Sandoval wrote:
> > > See my previous message. If we use O_DIRECT on the original open, then
> > > filesystems that implement bmap but not direct_IO will no longer work.
> > > These are the ones that I found in my tree:
> > 
> > In the long run I don't think they are worth keeping.  But to keep you
> > out of that discussion you can just try an open without O_DIRECT if the
> > open with the flag failed.
> 
> Umm...  That's one possibility, of course (and if swapon(2) is on someone's
> hotpath, I really would like to see what the hell they are doing - it has
> to be interesting in a sick way).

If this is the approach you'd prefer, I'll go ahead and do that for v2.
I personally think it looks pretty kludgey, but I'm fine either way:

diff --git a/mm/swapfile.c b/mm/swapfile.c
index 63f55cc..c1b3073 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -2379,7 +2379,16 @@ SYSCALL_DEFINE2(swapon, const char __user *, specialfile, int, swap_flags)
                name = NULL;
                goto bad_swap;
        }
-       swap_file = file_open_name(name, O_RDWR|O_LARGEFILE, 0);
+       swap_file = file_open_name(name, O_RDWR | O_LARGEFILE | O_DIRECT, 0);
+       if (IS_ERR(swap_file) && PTR_ERR(swap_file) == -EINVAL)
+               swap_file = file_open_name(name, O_RDWR | O_LARGEFILE, 0);
        if (IS_ERR(swap_file)) {
                error = PTR_ERR(swap_file);
                swap_file = NULL;

> BTW, speaking of read/write vs. swap - what's the story with e.g. AFS
> write() checking IS_SWAPFILE() and failing with -EBUSY?  Note that
> 	* it's done before acquiring i_mutex, so it isn't race-free
> 	* it's dubious from the POSIX POV - EBUSY isn't in the error
> list for write(2).
> 	* other filesystems generally don't have anything of that sort.
> NFS does, but local ones do not...
> Besides, do we even allow swapfiles on AFS?

AFS doesn't implement ->bmap or ->swap_activate, so that code is dead,
probably cargo-culted from the NFS code. It seems pretty pointless, not
only because it's inconsistent with the local filesystems like you
mentioned, but also because it's trivial to bypass with O_DIRECT on NFS:

ssize_t nfs_file_write(struct kiocb *iocb, struct iov_iter *from)
{
	struct file *file = iocb->ki_filp;
	struct inode *inode = file_inode(file);
	unsigned long written = 0;
	ssize_t result;
	size_t count = iov_iter_count(from);
	loff_t pos = iocb->ki_pos;

	result = nfs_key_timeout_notify(file, inode);
	if (result)
		return result;

	if (file->f_flags & O_DIRECT)
		return nfs_file_direct_write(iocb, from, pos);

	dprintk("NFS: write(%pD2, %zu@%Ld)\n",
		file, count, (long long) pos);

	result = -EBUSY;
	if (IS_SWAPFILE(inode))
		goto out_swapfile;

I think it's safe to scrap that code. However, this also led me to find that
NFS doesn't prevent truncates on an active swapfile. I'm submitting a patch for
that now.

-- 
Omar

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
