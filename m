Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id C5DB26B0032
	for <linux-mm@kvack.org>; Tue, 16 Dec 2014 03:56:30 -0500 (EST)
Received: by mail-pa0-f43.google.com with SMTP id kx10so13754579pab.30
        for <linux-mm@kvack.org>; Tue, 16 Dec 2014 00:56:30 -0800 (PST)
Received: from mail-pd0-f181.google.com (mail-pd0-f181.google.com. [209.85.192.181])
        by mx.google.com with ESMTPS id is3si17329032pbc.229.2014.12.16.00.56.28
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 16 Dec 2014 00:56:29 -0800 (PST)
Received: by mail-pd0-f181.google.com with SMTP id v10so13540334pde.40
        for <linux-mm@kvack.org>; Tue, 16 Dec 2014 00:56:28 -0800 (PST)
Date: Tue, 16 Dec 2014 00:56:24 -0800
From: Omar Sandoval <osandov@osandov.com>
Subject: Re: [PATCH 2/8] swap: lock i_mutex for swap_writepage direct_IO
Message-ID: <20141216085624.GA25256@mew>
References: <cover.1418618044.git.osandov@osandov.com>
 <a59510f4552a5d3557958cdb0ce1b23b3abfc75b.1418618044.git.osandov@osandov.com>
 <20141215162705.GA23887@quack.suse.cz>
 <20141215165615.GA19041@infradead.org>
 <20141215221100.GA4637@mew>
 <20141216083543.GA32425@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20141216083543.GA32425@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Jan Kara <jack@suse.cz>, Alexander Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, Trond Myklebust <trond.myklebust@primarydata.com>, David Sterba <dsterba@suse.cz>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue, Dec 16, 2014 at 12:35:43AM -0800, Christoph Hellwig wrote:
> On Mon, Dec 15, 2014 at 02:11:00PM -0800, Omar Sandoval wrote:
> > Ok, I got the swap code working with ->read_iter/->write_iter without
> > too much trouble. I wanted to double check before I submit if there's
> > any gotchas involved with adding the O_DIRECT flag to a file pointer
> > after it has been opened -- swapon opens the swapfile before we know if
> > we're using the SWP_FILE infrastructure, and we need to add O_DIRECT so
> > ->{read,write}_iter use direct I/O, but we can't add O_DIRECT to the
> > original open without excluding filesystems that support the old bmap
> > path but not direct I/O.
> 
> In general just adding O_DIRECT is a problem.  However given that the
> swap file is locked against any other access while in use it seems ok
> in this particular case.  Just make sure to clear it on swapoff, and
> write a detailed comment explaining the situation.

I'll admit that I'm a bit confused. I want to do this:

diff --git a/mm/swapfile.c b/mm/swapfile.c
index 8798b2e..5145c09 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -1728,6 +1728,9 @@ static int setup_swap_extents(struct swap_info_struct *sis, sector_t *span)
        }
 
        if (mapping->a_ops->swap_activate) {
+               if (!mapping->a_ops->direct_IO)
+                       return -EINVAL;
+               swap_file->f_flags |= O_DIRECT;
                ret = mapping->a_ops->swap_activate(sis, swap_file, span);
                if (!ret) {
                        sis->flags |= SWP_FILE;

This seems to be more or less equivalent to doing a fcntl(F_SETFL) to
add the O_DIRECT flag to swap_file (which is a struct file *). Swapoff
calls filp_close on swap_file, so I don't see why it's necessary to
clear the flag.

-- 
Omar

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
