Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f177.google.com (mail-pd0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id BD2A46B0032
	for <linux-mm@kvack.org>; Tue, 13 Jan 2015 22:18:41 -0500 (EST)
Received: by mail-pd0-f177.google.com with SMTP id ft15so7094364pdb.8
        for <linux-mm@kvack.org>; Tue, 13 Jan 2015 19:18:41 -0800 (PST)
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com. [209.85.192.179])
        by mx.google.com with ESMTPS id i8si29199186pdm.106.2015.01.13.19.18.39
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 13 Jan 2015 19:18:39 -0800 (PST)
Received: by mail-pd0-f179.google.com with SMTP id fp1so7078911pdb.10
        for <linux-mm@kvack.org>; Tue, 13 Jan 2015 19:18:39 -0800 (PST)
Date: Tue, 13 Jan 2015 19:18:36 -0800
From: Omar Sandoval <osandov@osandov.com>
Subject: Re: [PATCH v2 0/5] clean up and generalize swap-over-NFS
Message-ID: <20150114031836.GA21198@mew>
References: <cover.1419044605.git.osandov@osandov.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <cover.1419044605.git.osandov@osandov.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, Trond Myklebust <trond.myklebust@primarydata.com>, Christoph Hellwig <hch@infradead.org>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org

On Fri, Dec 19, 2014 at 07:18:24PM -0800, Omar Sandoval wrote:
> Hi,
> 
> This patch series (based on ecb5ec0 in Linus' tree) contains all of the
> non-BTRFS work that I've done to implement swapfiles on BTRFS. The BTRFS
> portion is still undergoing development and is now outweighed by the
> non-BTRFS changes, so I want to get these in separately.
> 
> Version 2 changes the generic swapfile interface to use ->read_iter and
> ->write_iter instead of using ->direct_IO directly in response to
> discussion on the previous submission. It also adds the iov_iter_is_bvec
> helper to factor out some common checks.
> 
> Version 1 can be found here: https://lkml.org/lkml/2014/12/15/7
> 
> Omar Sandoval (5):
>   iov_iter: add ITER_BVEC helpers
>   direct-io: don't dirty ITER_BVEC pages on read
>   nfs: don't dirty ITER_BVEC pages read through direct I/O
>   swapfile: use ->read_iter and ->write_iter
>   vfs: update swap_{,de}activate documentation
> 
>  Documentation/filesystems/Locking |  7 ++++---
>  Documentation/filesystems/vfs.txt |  7 ++++---
>  fs/direct-io.c                    |  8 ++++---
>  fs/nfs/direct.c                   |  5 ++++-
>  fs/splice.c                       |  7 ++-----
>  include/linux/uio.h               |  7 +++++++
>  mm/iov_iter.c                     | 12 +++++++++++
>  mm/page_io.c                      | 44 +++++++++++++++++++++++++--------------
>  mm/swapfile.c                     | 11 +++++++++-
>  9 files changed, 76 insertions(+), 32 deletions(-)
> 
> -- 
> 2.2.1
> 

Hi, everyone,

Thanks for all of the feedback on the last few iterations of this
series. If it's alright, I'd like to revive the conversation around
these patches.

There are a couple of issues which we were discussing before the
holidays:

One concern that Al mentioned was ->read_iter and ->write_iter falling
back to the buffered I/O case. Like Christoph mentioned, this can be
prevented by doing the proper checks on the filesystem side (usually
just making sure that all blocks of a swapfile are allocated, but on
BTRFS, for example, we also have to check for compressed extents).

The other concern which Al brought up was that ->read_iter is passed a
locked page in the iter_bvec and could end up trying to lock it. I'm not
too sure under what conditions that would happen -- could someone give
an example? My intuition is that there's no path which will lead us to
deadlock on a page in the swapcache, but I don't have anything solid to
back that up.

Thanks!
-- 
Omar

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
