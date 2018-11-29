Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id F25A56B4FFA
	for <linux-mm@kvack.org>; Wed, 28 Nov 2018 20:30:29 -0500 (EST)
Received: by mail-qt1-f200.google.com with SMTP id z6so286048qtj.21
        for <linux-mm@kvack.org>; Wed, 28 Nov 2018 17:30:29 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id v67si259960qkd.63.2018.11.28.17.30.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 28 Nov 2018 17:30:28 -0800 (PST)
Date: Thu, 29 Nov 2018 09:30:00 +0800
From: Ming Lei <ming.lei@redhat.com>
Subject: Re: [PATCH V12 00/20] block: support multi-page bvec
Message-ID: <20181129012959.GC23249@ming.t460p>
References: <20181126021720.19471-1-ming.lei@redhat.com>
 <7096bc4e-0617-29d0-a90d-ae7caf09a16d@kernel.dk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <7096bc4e-0617-29d0-a90d-ae7caf09a16d@kernel.dk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jens Axboe <axboe@kernel.dk>, Mike Snitzer <snitzer@redhat.com>, "Ewan D. Milne" <emilne@redhat.com>
Cc: linux-block@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Theodore Ts'o <tytso@mit.edu>, Omar Sandoval <osandov@fb.com>, Sagi Grimberg <sagi@grimberg.me>, Dave Chinner <dchinner@redhat.com>, Kent Overstreet <kent.overstreet@gmail.com>, dm-devel@redhat.com, Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, Shaohua Li <shli@kernel.org>, linux-raid@vger.kernel.org, David Sterba <dsterba@suse.com>, linux-btrfs@vger.kernel.org, "Darrick J . Wong" <darrick.wong@oracle.com>, linux-xfs@vger.kernel.org, Gao Xiang <gaoxiang25@huawei.com>, Christoph Hellwig <hch@lst.de>, linux-ext4@vger.kernel.org, Coly Li <colyli@suse.de>, linux-bcache@vger.kernel.org, Boaz Harrosh <ooo@electrozaur.com>, Bob Peterson <rpeterso@redhat.com>, cluster-devel@redhat.com

On Wed, Nov 28, 2018 at 06:44:00AM -0700, Jens Axboe wrote:
> On 11/25/18 7:17 PM, Ming Lei wrote:
> > Hi,
> > 
> > This patchset brings multi-page bvec into block layer:
> > 
> > 1) what is multi-page bvec?
> > 
> > Multipage bvecs means that one 'struct bio_bvec' can hold multiple pages
> > which are physically contiguous instead of one single page used in linux
> > kernel for long time.
> > 
> > 2) why is multi-page bvec introduced?
> > 
> > Kent proposed the idea[1] first. 
> > 
> > As system's RAM becomes much bigger than before, and huge page, transparent
> > huge page and memory compaction are widely used, it is a bit easy now
> > to see physically contiguous pages from fs in I/O. On the other hand, from
> > block layer's view, it isn't necessary to store intermediate pages into bvec,
> > and it is enough to just store the physicallly contiguous 'segment' in each
> > io vector.
> > 
> > Also huge pages are being brought to filesystem and swap [2][6], we can
> > do IO on a hugepage each time[3], which requires that one bio can transfer
> > at least one huge page one time. Turns out it isn't flexiable to change
> > BIO_MAX_PAGES simply[3][5]. Multipage bvec can fit in this case very well.
> > As we saw, if CONFIG_THP_SWAP is enabled, BIO_MAX_PAGES can be configured
> > as much bigger, such as 512, which requires at least two 4K pages for holding
> > the bvec table.
> 
> I'm pretty happy with this patchset at this point, looks like it just
> needs a respin to address the last comments. My only concern is whether

I will address the last comment from Omar on patch of '[PATCH V12 01/20] btrfs:
remove various bio_offset arguments', we may use the approach in V11 simply.

> it's a good idea to target this for 4.21, or if we should wait until
> 4.22. 4.21 has a fairly substantial amount of changes in terms of block
> already, it's not the best timing for something of this magnitude too.

Yeah, I understand.

> 
> I'm going back and forth on those one a bit. Any concerns with
> pushing this to 4.22?

My only one concern is about the warning of "blk_cloned_rq_check_limits:
over max segments limit" on dm multipath, and seems Ewan and Mike is waiting
for this fix.

thanks,
Ming
