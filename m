Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 151EC6B0007
	for <linux-mm@kvack.org>; Fri,  1 Jun 2018 10:12:48 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id n17-v6so886956wmh.4
        for <linux-mm@kvack.org>; Fri, 01 Jun 2018 07:12:48 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l9-v6si1045684edc.112.2018.06.01.07.12.43
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 01 Jun 2018 07:12:44 -0700 (PDT)
Date: Fri, 1 Jun 2018 16:09:54 +0200
From: David Sterba <dsterba@suse.cz>
Subject: Re: [RESEND PATCH V5 00/33] block: support multipage bvec
Message-ID: <20180601140954.GY3539@suse.cz>
Reply-To: dsterba@suse.cz
References: <20180525034621.31147-1-ming.lei@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180525034621.31147-1-ming.lei@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ming Lei <ming.lei@redhat.com>
Cc: Jens Axboe <axboe@fb.com>, Christoph Hellwig <hch@infradead.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Kent Overstreet <kent.overstreet@gmail.com>, Huang Ying <ying.huang@intel.com>, linux-kernel@vger.kernel.org, linux-block@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Theodore Ts'o <tytso@mit.edu>, "Darrick J . Wong" <darrick.wong@oracle.com>, Coly Li <colyli@suse.de>, Filipe Manana <fdmanana@gmail.com>

On Fri, May 25, 2018 at 11:45:48AM +0800, Ming Lei wrote:
>  fs/btrfs/check-integrity.c          |   6 +-
>  fs/btrfs/compression.c              |   8 +-
>  fs/btrfs/disk-io.c                  |   3 +-
>  fs/btrfs/extent_io.c                |  14 ++-
>  fs/btrfs/file-item.c                |   4 +-
>  fs/btrfs/inode.c                    |  12 ++-
>  fs/btrfs/raid56.c                   |   5 +-

For the btrfs bits,
Acked-by: David Sterba <dsterba@suse.com>

but that's from the bio API user perspective only, I'll leave the design
and implementation questions to others.

I've let the patchset through fstests, no problems. One thing that caught
my eye was use of the 'struct bvec_iter_all' in random functions. As
this structure is a compound of 2 others and is 40 bytes in size, I was
curious how this increased stack consumption.

Measured with -fstack-usage before and after patch 22/33 "btrfs: conver to
bio_for_each_page_all2"

-disk-io.c:btree_csum_one_bio                             48 static
+disk-io.c:btree_csum_one_bio                             80 static
-extent_io.c:end_bio_extent_buffer_writepage              56 static
+extent_io.c:end_bio_extent_buffer_writepage              80 static
-extent_io.c:end_bio_extent_readpage                      176 dynamic,bounded
+extent_io.c:end_bio_extent_readpage                      240 dynamic,bounded
-extent_io.c:end_bio_extent_writepage                     56 static
+extent_io.c:end_bio_extent_writepage                     120 static
-inode.c:btrfs_retry_endio                                96 dynamic,bounded
+inode.c:btrfs_retry_endio                                144 dynamic,bounded
-inode.c:btrfs_retry_endio_nocsum                         72 dynamic,bounded
+inode.c:btrfs_retry_endio_nocsum                         104 dynamic,bounded
-raid56.c:set_bio_pages_uptodate                          8 static
+raid56.c:set_bio_pages_uptodate                          40 static

It's not that bad, but still quite a lot just to iterate a list of bios. I
think it's worth mentioning as it affects several other filesystems and
should be possibly optimized in the future.
