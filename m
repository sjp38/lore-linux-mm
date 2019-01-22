Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 2F9588E0001
	for <linux-mm@kvack.org>; Mon, 21 Jan 2019 21:02:10 -0500 (EST)
Received: by mail-qt1-f197.google.com with SMTP id m37so22791755qte.10
        for <linux-mm@kvack.org>; Mon, 21 Jan 2019 18:02:10 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id x24si418779qtp.214.2019.01.21.18.02.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 21 Jan 2019 18:02:09 -0800 (PST)
Date: Tue, 22 Jan 2019 10:01:30 +0800
From: Ming Lei <ming.lei@redhat.com>
Subject: Re: [PATCH V14 00/18] block: support multi-page bvec
Message-ID: <20190122020128.GB2490@ming.t460p>
References: <20190121081805.32727-1-ming.lei@redhat.com>
 <61dfaa1e-e7bf-75f1-410b-ed32f97d0782@grimberg.me>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <61dfaa1e-e7bf-75f1-410b-ed32f97d0782@grimberg.me>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sagi Grimberg <sagi@grimberg.me>
Cc: Jens Axboe <axboe@kernel.dk>, linux-block@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Theodore Ts'o <tytso@mit.edu>, Omar Sandoval <osandov@fb.com>, Dave Chinner <dchinner@redhat.com>, Kent Overstreet <kent.overstreet@gmail.com>, Mike Snitzer <snitzer@redhat.com>, dm-devel@redhat.com, Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, linux-raid@vger.kernel.org, David Sterba <dsterba@suse.com>, linux-btrfs@vger.kernel.org, "Darrick J . Wong" <darrick.wong@oracle.com>, linux-xfs@vger.kernel.org, Gao Xiang <gaoxiang25@huawei.com>, Christoph Hellwig <hch@lst.de>, linux-ext4@vger.kernel.org, Coly Li <colyli@suse.de>, linux-bcache@vger.kernel.org, Boaz Harrosh <ooo@electrozaur.com>, Bob Peterson <rpeterso@redhat.com>, cluster-devel@redhat.com

On Mon, Jan 21, 2019 at 01:43:21AM -0800, Sagi Grimberg wrote:
> 
> > V14:
> > 	- drop patch(patch 4 in V13) for renaming bvec helpers, as suggested by Jens
> > 	- use mp_bvec_* as multi-page bvec helper name
> > 	- fix one build issue, which is caused by missing one converion of
> > 	bio_for_each_segment_all in fs/gfs2
> > 	- fix one 32bit ARCH specific issue caused by segment boundary mask
> > 	overflow
> 
> Hey Ming,
> 
> So is nvme-tcp also affected here? The only point where I see nvme-tcp
> can be affected is when initializing a bvec iter using bio_segments() as
> everywhere else we use iters which should transparently work..
> 
> I see that loop was converted, does it mean that nvme-tcp needs to
> call something like?
> --
> 	bio_for_each_mp_bvec(bv, bio, iter)
> 		nr_bvecs++;

bio_for_each_segment()/bio_segments() still works, just not as efficient
as bio_for_each_mp_bvec() given each multi-page bvec(very similar with scatterlist)
is returned in each loop.

I don't look at nvme-tcp code yet. But if nvme-tcp supports this way,
it can benefit from bio_for_each_mp_bvec().

Thanks,
Ming
