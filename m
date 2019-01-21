Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 287088E0001
	for <linux-mm@kvack.org>; Mon, 21 Jan 2019 04:43:25 -0500 (EST)
Received: by mail-pl1-f197.google.com with SMTP id j8so12884478plb.1
        for <linux-mm@kvack.org>; Mon, 21 Jan 2019 01:43:25 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o7sor17320642pfi.46.2019.01.21.01.43.24
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 21 Jan 2019 01:43:24 -0800 (PST)
Subject: Re: [PATCH V14 00/18] block: support multi-page bvec
References: <20190121081805.32727-1-ming.lei@redhat.com>
From: Sagi Grimberg <sagi@grimberg.me>
Message-ID: <61dfaa1e-e7bf-75f1-410b-ed32f97d0782@grimberg.me>
Date: Mon, 21 Jan 2019 01:43:21 -0800
MIME-Version: 1.0
In-Reply-To: <20190121081805.32727-1-ming.lei@redhat.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ming Lei <ming.lei@redhat.com>, Jens Axboe <axboe@kernel.dk>
Cc: linux-block@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Theodore Ts'o <tytso@mit.edu>, Omar Sandoval <osandov@fb.com>, Dave Chinner <dchinner@redhat.com>, Kent Overstreet <kent.overstreet@gmail.com>, Mike Snitzer <snitzer@redhat.com>, dm-devel@redhat.com, Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, linux-raid@vger.kernel.org, David Sterba <dsterba@suse.com>, linux-btrfs@vger.kernel.org, "Darrick J . Wong" <darrick.wong@oracle.com>, linux-xfs@vger.kernel.org, Gao Xiang <gaoxiang25@huawei.com>, Christoph Hellwig <hch@lst.de>, linux-ext4@vger.kernel.org, Coly Li <colyli@suse.de>, linux-bcache@vger.kernel.org, Boaz Harrosh <ooo@electrozaur.com>, Bob Peterson <rpeterso@redhat.com>, cluster-devel@redhat.com


> V14:
> 	- drop patch(patch 4 in V13) for renaming bvec helpers, as suggested by Jens
> 	- use mp_bvec_* as multi-page bvec helper name
> 	- fix one build issue, which is caused by missing one converion of
> 	bio_for_each_segment_all in fs/gfs2
> 	- fix one 32bit ARCH specific issue caused by segment boundary mask
> 	overflow

Hey Ming,

So is nvme-tcp also affected here? The only point where I see nvme-tcp
can be affected is when initializing a bvec iter using bio_segments() as
everywhere else we use iters which should transparently work..

I see that loop was converted, does it mean that nvme-tcp needs to
call something like?
--
	bio_for_each_mp_bvec(bv, bio, iter)
		nr_bvecs++;
--
