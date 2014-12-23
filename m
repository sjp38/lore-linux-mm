Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id A63A76B0032
	for <linux-mm@kvack.org>; Tue, 23 Dec 2014 04:37:20 -0500 (EST)
Received: by mail-pa0-f44.google.com with SMTP id et14so7587733pad.31
        for <linux-mm@kvack.org>; Tue, 23 Dec 2014 01:37:20 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id q5si28487848pdm.153.2014.12.23.01.37.16
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Dec 2014 01:37:17 -0800 (PST)
Date: Tue, 23 Dec 2014 01:37:10 -0800
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 2/8] swap: lock i_mutex for swap_writepage direct_IO
Message-ID: <20141223093710.GA29096@infradead.org>
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
Cc: Jan Kara <jack@suse.cz>, Omar Sandoval <osandov@osandov.com>, Andrew Morton <akpm@linux-foundation.org>, Trond Myklebust <trond.myklebust@primarydata.com>, David Sterba <dsterba@suse.cz>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org

On Sat, Dec 20, 2014 at 06:51:33AM +0000, Al Viro wrote:
> > The problem is that the use of ->direct_IO by the swap code is a gross
> > layering violation.  ->direct_IO is a callback for the filesystem, and
> > the swap code need to call ->read_iter instead of ->readpage and
> > ->write_tier instead of ->direct_IO, and leave the locking to the
> > filesystem.
> 
> The thing is, ->read_iter() and ->write_iter() might decide to fall back to 
> buffered IO path.  XFS is unusual in that respect - there O_DIRECT ends up
> with short write in such case.  Other filesystems, OTOH...

We'll just need a ->swap_activate method that makes sure we really do
direct I/O.  For all filesystems currently suporting swap just checking
that all blocks are allocated (as the ->bmap path already does) should
be enough.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
