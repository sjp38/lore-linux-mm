Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 6CECA6B2387
	for <linux-mm@kvack.org>; Tue, 20 Nov 2018 22:20:56 -0500 (EST)
Received: by mail-pl1-f199.google.com with SMTP id a9so5401518pla.2
        for <linux-mm@kvack.org>; Tue, 20 Nov 2018 19:20:56 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h17sor1081312pfa.67.2018.11.20.19.20.55
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 20 Nov 2018 19:20:55 -0800 (PST)
Subject: Re: [PATCH V10 09/19] block: introduce bio_bvecs()
References: <20181115085306.9910-1-ming.lei@redhat.com>
 <20181115085306.9910-10-ming.lei@redhat.com> <20181116134541.GH3165@lst.de>
 <002fe56b-25e4-573e-c09b-bb12c3e8d25a@grimberg.me>
 <20181120161651.GB2629@lst.de>
 <53526aae-fb9b-ee38-0a01-e5899e2d4e4d@grimberg.me>
 <20181121005902.GA31748@ming.t460p>
From: Sagi Grimberg <sagi@grimberg.me>
Message-ID: <2d9bee7a-f010-dcf4-1184-094101058584@grimberg.me>
Date: Tue, 20 Nov 2018 19:20:45 -0800
MIME-Version: 1.0
In-Reply-To: <20181121005902.GA31748@ming.t460p>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ming Lei <ming.lei@redhat.com>
Cc: Christoph Hellwig <hch@lst.de>, Jens Axboe <axboe@kernel.dk>, linux-block@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Dave Chinner <dchinner@redhat.com>, Kent Overstreet <kent.overstreet@gmail.com>, Mike Snitzer <snitzer@redhat.com>, dm-devel@redhat.com, Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, Shaohua Li <shli@kernel.org>, linux-raid@vger.kernel.org, linux-erofs@lists.ozlabs.org, David Sterba <dsterba@suse.com>, linux-btrfs@vger.kernel.org, "Darrick J . Wong" <darrick.wong@oracle.com>, linux-xfs@vger.kernel.org, Gao Xiang <gaoxiang25@huawei.com>, Theodore Ts'o <tytso@mit.edu>, linux-ext4@vger.kernel.org, Coly Li <colyli@suse.de>, linux-bcache@vger.kernel.org, Boaz Harrosh <ooo@electrozaur.com>, Bob Peterson <rpeterso@redhat.com>, cluster-devel@redhat.com


> Not sure I understand the 'blocking' problem in this case.
> 
> We can build a bvec table from this req, and send them all
> in send(),

I would like to avoid growing bvec tables and keep everything
preallocated. Plus, a bvec_iter operates on a bvec which means
we'll need a table there as well... Not liking it so far...

> can this way avoid your blocking issue? You may see this
> example in branch 'rq->bio != rq->biotail' of lo_rw_aio().

This is exactly an example of not ignoring the bios...

> If this way is what you need, I think you are right, even we may
> introduce the following helpers:
> 
> 	rq_for_each_bvec()
> 	rq_bvecs()

I'm not sure how this helps me either. Unless we can set a bvec_iter to
span bvecs or have an abstract bio crossing when we re-initialize the
bvec_iter I don't see how I can ignore bios completely...

> So looks nvme-tcp host driver might be the 2nd driver which benefits
> from multi-page bvec directly.
> 
> The multi-page bvec V11 has passed my tests and addressed almost
> all the comments during review on V10. I removed bio_vecs() in V11,
> but it won't be big deal, we can introduce them anytime when there
> is the requirement.

multipage-bvecs and nvme-tcp are going to conflict, so it would be good
to coordinate on this. I think that nvme-tcp host needs some adjustments
as setting a bvec_iter. I'm under the impression that the change is 
rather small and self-contained, but I'm not sure I have the full
picture here.
