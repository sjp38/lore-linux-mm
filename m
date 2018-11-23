Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 5B05C6B30D3
	for <linux-mm@kvack.org>; Fri, 23 Nov 2018 05:51:05 -0500 (EST)
Received: by mail-qt1-f198.google.com with SMTP id d35so8490759qtd.20
        for <linux-mm@kvack.org>; Fri, 23 Nov 2018 02:51:05 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id o89si9235183qko.41.2018.11.23.02.51.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 23 Nov 2018 02:51:04 -0800 (PST)
Date: Fri, 23 Nov 2018 18:50:26 +0800
From: Ming Lei <ming.lei@redhat.com>
Subject: Re: [PATCH V11 15/19] block: enable multipage bvecs
Message-ID: <20181123105024.GA13902@ming.t460p>
References: <20181121032327.8434-1-ming.lei@redhat.com>
 <20181121032327.8434-16-ming.lei@redhat.com>
 <20181121145502.GA3241@lst.de>
 <20181121154812.GD19111@ming.t460p>
 <20181121161206.GD4977@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181121161206.GD4977@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: Jens Axboe <axboe@kernel.dk>, linux-block@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Theodore Ts'o <tytso@mit.edu>, Omar Sandoval <osandov@fb.com>, Sagi Grimberg <sagi@grimberg.me>, Dave Chinner <dchinner@redhat.com>, Kent Overstreet <kent.overstreet@gmail.com>, Mike Snitzer <snitzer@redhat.com>, dm-devel@redhat.com, Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, Shaohua Li <shli@kernel.org>, linux-raid@vger.kernel.org, David Sterba <dsterba@suse.com>, linux-btrfs@vger.kernel.org, "Darrick J . Wong" <darrick.wong@oracle.com>, linux-xfs@vger.kernel.org, Gao Xiang <gaoxiang25@huawei.com>, linux-ext4@vger.kernel.org, Coly Li <colyli@suse.de>, linux-bcache@vger.kernel.org, Boaz Harrosh <ooo@electrozaur.com>, Bob Peterson <rpeterso@redhat.com>, cluster-devel@redhat.com

On Wed, Nov 21, 2018 at 05:12:06PM +0100, Christoph Hellwig wrote:
> On Wed, Nov 21, 2018 at 11:48:13PM +0800, Ming Lei wrote:
> > I guess the correct check should be:
> > 
> > 		end_addr = vec_addr + bv->bv_offset + bv->bv_len;
> > 		if (same_page &&
> > 		    (end_addr & PAGE_MASK) != (page_addr & PAGE_MASK))
> > 			return false;
> 
> Indeed.

The above is still not totally correct, and it should have been:

 		end_addr = vec_addr + bv->bv_offset + bv->bv_len - 1;
 		if (same_page && (end_addr & PAGE_MASK) != page_addr)
 			return false;

Also bv->bv_len should be guaranteed as being bigger than zero.

It also shows that it is quite easy to figure out the last page as
wrong, :-(


Thanks,
Ming
