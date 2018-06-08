Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 993E76B0006
	for <linux-mm@kvack.org>; Fri,  8 Jun 2018 08:50:51 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id n33-v6so11833597qte.23
        for <linux-mm@kvack.org>; Fri, 08 Jun 2018 05:50:51 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id q2-v6si2982323qta.3.2018.06.08.05.50.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 08 Jun 2018 05:50:50 -0700 (PDT)
Date: Fri, 8 Jun 2018 20:50:29 +0800
From: Ming Lei <ming.lei@redhat.com>
Subject: Re: [RESEND PATCH V5 00/33] block: support multipage bvec
Message-ID: <20180608125023.GA9444@ming.t460p>
References: <20180525034621.31147-1-ming.lei@redhat.com>
 <20180601140954.GY3539@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180601140954.GY3539@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: dsterba@suse.cz, Jens Axboe <axboe@fb.com>, Christoph Hellwig <hch@infradead.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Kent Overstreet <kent.overstreet@gmail.com>, Huang Ying <ying.huang@intel.com>, linux-kernel@vger.kernel.org, linux-block@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Theodore Ts'o <tytso@mit.edu>, "Darrick J . Wong" <darrick.wong@oracle.com>, Coly Li <colyli@suse.de>, Filipe Manana <fdmanana@gmail.com>

On Fri, Jun 01, 2018 at 04:09:54PM +0200, David Sterba wrote:
> On Fri, May 25, 2018 at 11:45:48AM +0800, Ming Lei wrote:
> >  fs/btrfs/check-integrity.c          |   6 +-
> >  fs/btrfs/compression.c              |   8 +-
> >  fs/btrfs/disk-io.c                  |   3 +-
> >  fs/btrfs/extent_io.c                |  14 ++-
> >  fs/btrfs/file-item.c                |   4 +-
> >  fs/btrfs/inode.c                    |  12 ++-
> >  fs/btrfs/raid56.c                   |   5 +-
> 
> For the btrfs bits,
> Acked-by: David Sterba <dsterba@suse.com>
> 
> but that's from the bio API user perspective only, I'll leave the design
> and implementation questions to others.
> 
> I've let the patchset through fstests, no problems. One thing that caught

Thanks for your test!

> my eye was use of the 'struct bvec_iter_all' in random functions. As
> this structure is a compound of 2 others and is 40 bytes in size, I was
> curious how this increased stack consumption.
> 
> Measured with -fstack-usage before and after patch 22/33 "btrfs: conver to
> bio_for_each_page_all2"
> 
> -disk-io.c:btree_csum_one_bio                             48 static
> +disk-io.c:btree_csum_one_bio                             80 static
> -extent_io.c:end_bio_extent_buffer_writepage              56 static
> +extent_io.c:end_bio_extent_buffer_writepage              80 static
> -extent_io.c:end_bio_extent_readpage                      176 dynamic,bounded
> +extent_io.c:end_bio_extent_readpage                      240 dynamic,bounded
> -extent_io.c:end_bio_extent_writepage                     56 static
> +extent_io.c:end_bio_extent_writepage                     120 static
> -inode.c:btrfs_retry_endio                                96 dynamic,bounded
> +inode.c:btrfs_retry_endio                                144 dynamic,bounded
> -inode.c:btrfs_retry_endio_nocsum                         72 dynamic,bounded
> +inode.c:btrfs_retry_endio_nocsum                         104 dynamic,bounded
> -raid56.c:set_bio_pages_uptodate                          8 static
> +raid56.c:set_bio_pages_uptodate                          40 static
> 
> It's not that bad, but still quite a lot just to iterate a list of bios. I
> think it's worth mentioning as it affects several other filesystems and
> should be possibly optimized in the future.

OK.

We could decrease the affect by using a lightweight iterator for
bio_for_each_page_all2(), will do it in V6.


Thanks,
Ming
