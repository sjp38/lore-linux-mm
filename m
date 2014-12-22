Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 4FC756B006E
	for <linux-mm@kvack.org>; Mon, 22 Dec 2014 02:26:44 -0500 (EST)
Received: by mail-pa0-f46.google.com with SMTP id lf10so5404485pab.33
        for <linux-mm@kvack.org>; Sun, 21 Dec 2014 23:26:43 -0800 (PST)
Received: from mail-pd0-f173.google.com (mail-pd0-f173.google.com. [209.85.192.173])
        by mx.google.com with ESMTPS id rv7si23968994pbc.125.2014.12.21.23.26.42
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sun, 21 Dec 2014 23:26:42 -0800 (PST)
Received: by mail-pd0-f173.google.com with SMTP id ft15so5325043pdb.32
        for <linux-mm@kvack.org>; Sun, 21 Dec 2014 23:26:42 -0800 (PST)
Date: Sun, 21 Dec 2014 23:26:38 -0800
From: Omar Sandoval <osandov@osandov.com>
Subject: Re: [PATCH 2/8] swap: lock i_mutex for swap_writepage direct_IO
Message-ID: <20141222072638.GB24722@mew>
References: <cover.1418618044.git.osandov@osandov.com>
 <a59510f4552a5d3557958cdb0ce1b23b3abfc75b.1418618044.git.osandov@osandov.com>
 <20141215162705.GA23887@quack.suse.cz>
 <20141215165615.GA19041@infradead.org>
 <20141220065133.GC22149@ZenIV.linux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20141220065133.GC22149@ZenIV.linux.org.uk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Al Viro <viro@ZenIV.linux.org.uk>
Cc: Christoph Hellwig <hch@infradead.org>, Jan Kara <jack@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Trond Myklebust <trond.myklebust@primarydata.com>, David Sterba <dsterba@suse.cz>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org

On Sat, Dec 20, 2014 at 06:51:33AM +0000, Al Viro wrote:
> On Mon, Dec 15, 2014 at 08:56:15AM -0800, Christoph Hellwig wrote:
> > On Mon, Dec 15, 2014 at 05:27:05PM +0100, Jan Kara wrote:
> > > On Sun 14-12-14 21:26:56, Omar Sandoval wrote:
> > > > The generic write code locks i_mutex for a direct_IO. Swap-over-NFS
> > > > doesn't grab the mutex because nfs_direct_IO doesn't expect i_mutex to
> > > > be held, but most direct_IO implementations do.
> > >   I think you are speaking about direct IO writes only, aren't you? For DIO
> > > reads we don't hold i_mutex AFAICS. And also for DIO writes we don't
> > > necessarily hold i_mutex - see for example XFS which doesn't take i_mutex
> > > for direct IO writes. It uses it's internal rwlock for this (see
> > > xfs_file_dio_aio_write()). So I think this is just wrong.
> > 
> > The problem is that the use of ->direct_IO by the swap code is a gross
> > layering violation.  ->direct_IO is a callback for the filesystem, and
> > the swap code need to call ->read_iter instead of ->readpage and
> > ->write_tier instead of ->direct_IO, and leave the locking to the
> > filesystem.
> 
> The thing is, ->read_iter() and ->write_iter() might decide to fall back to 
> buffered IO path.  XFS is unusual in that respect - there O_DIRECT ends up
> with short write in such case.  Other filesystems, OTOH...

Alright, now what? Using ->direct_IO directly is pretty much a no go
because of the different locking conventions as was pointed out. Maybe
some "no, really, just direct I/O" iocb flag?

-- 
Omar

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
