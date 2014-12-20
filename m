Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f176.google.com (mail-wi0-f176.google.com [209.85.212.176])
	by kanga.kvack.org (Postfix) with ESMTP id B2DE26B0032
	for <linux-mm@kvack.org>; Sat, 20 Dec 2014 01:51:43 -0500 (EST)
Received: by mail-wi0-f176.google.com with SMTP id ex7so3812749wid.15
        for <linux-mm@kvack.org>; Fri, 19 Dec 2014 22:51:43 -0800 (PST)
Received: from ZenIV.linux.org.uk (zeniv.linux.org.uk. [2002:c35c:fd02::1])
        by mx.google.com with ESMTPS id hg10si21132078wjb.144.2014.12.19.22.51.42
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 19 Dec 2014 22:51:42 -0800 (PST)
Date: Sat, 20 Dec 2014 06:51:33 +0000
From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [PATCH 2/8] swap: lock i_mutex for swap_writepage direct_IO
Message-ID: <20141220065133.GC22149@ZenIV.linux.org.uk>
References: <cover.1418618044.git.osandov@osandov.com>
 <a59510f4552a5d3557958cdb0ce1b23b3abfc75b.1418618044.git.osandov@osandov.com>
 <20141215162705.GA23887@quack.suse.cz>
 <20141215165615.GA19041@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20141215165615.GA19041@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Jan Kara <jack@suse.cz>, Omar Sandoval <osandov@osandov.com>, Andrew Morton <akpm@linux-foundation.org>, Trond Myklebust <trond.myklebust@primarydata.com>, David Sterba <dsterba@suse.cz>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org

On Mon, Dec 15, 2014 at 08:56:15AM -0800, Christoph Hellwig wrote:
> On Mon, Dec 15, 2014 at 05:27:05PM +0100, Jan Kara wrote:
> > On Sun 14-12-14 21:26:56, Omar Sandoval wrote:
> > > The generic write code locks i_mutex for a direct_IO. Swap-over-NFS
> > > doesn't grab the mutex because nfs_direct_IO doesn't expect i_mutex to
> > > be held, but most direct_IO implementations do.
> >   I think you are speaking about direct IO writes only, aren't you? For DIO
> > reads we don't hold i_mutex AFAICS. And also for DIO writes we don't
> > necessarily hold i_mutex - see for example XFS which doesn't take i_mutex
> > for direct IO writes. It uses it's internal rwlock for this (see
> > xfs_file_dio_aio_write()). So I think this is just wrong.
> 
> The problem is that the use of ->direct_IO by the swap code is a gross
> layering violation.  ->direct_IO is a callback for the filesystem, and
> the swap code need to call ->read_iter instead of ->readpage and
> ->write_tier instead of ->direct_IO, and leave the locking to the
> filesystem.

The thing is, ->read_iter() and ->write_iter() might decide to fall back to 
buffered IO path.  XFS is unusual in that respect - there O_DIRECT ends up
with short write in such case.  Other filesystems, OTOH...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
