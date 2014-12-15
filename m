Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id B3F5E6B0070
	for <linux-mm@kvack.org>; Mon, 15 Dec 2014 11:56:21 -0500 (EST)
Received: by mail-pa0-f41.google.com with SMTP id rd3so12210346pab.28
        for <linux-mm@kvack.org>; Mon, 15 Dec 2014 08:56:21 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id lq5si14839285pab.45.2014.12.15.08.56.19
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Dec 2014 08:56:20 -0800 (PST)
Date: Mon, 15 Dec 2014 08:56:15 -0800
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 2/8] swap: lock i_mutex for swap_writepage direct_IO
Message-ID: <20141215165615.GA19041@infradead.org>
References: <cover.1418618044.git.osandov@osandov.com>
 <a59510f4552a5d3557958cdb0ce1b23b3abfc75b.1418618044.git.osandov@osandov.com>
 <20141215162705.GA23887@quack.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20141215162705.GA23887@quack.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Omar Sandoval <osandov@osandov.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, Trond Myklebust <trond.myklebust@primarydata.com>, Christoph Hellwig <hch@infradead.org>, David Sterba <dsterba@suse.cz>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org

On Mon, Dec 15, 2014 at 05:27:05PM +0100, Jan Kara wrote:
> On Sun 14-12-14 21:26:56, Omar Sandoval wrote:
> > The generic write code locks i_mutex for a direct_IO. Swap-over-NFS
> > doesn't grab the mutex because nfs_direct_IO doesn't expect i_mutex to
> > be held, but most direct_IO implementations do.
>   I think you are speaking about direct IO writes only, aren't you? For DIO
> reads we don't hold i_mutex AFAICS. And also for DIO writes we don't
> necessarily hold i_mutex - see for example XFS which doesn't take i_mutex
> for direct IO writes. It uses it's internal rwlock for this (see
> xfs_file_dio_aio_write()). So I think this is just wrong.

The problem is that the use of ->direct_IO by the swap code is a gross
layering violation.  ->direct_IO is a callback for the filesystem, and
the swap code need to call ->read_iter instead of ->readpage and
->write_tier instead of ->direct_IO, and leave the locking to the
filesystem.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
