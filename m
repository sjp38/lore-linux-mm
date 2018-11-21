Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 956786B23F7
	for <linux-mm@kvack.org>; Tue, 20 Nov 2018 23:25:51 -0500 (EST)
Received: by mail-pl1-f200.google.com with SMTP id d23so5615536plj.22
        for <linux-mm@kvack.org>; Tue, 20 Nov 2018 20:25:51 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y40-v6sor53534264pla.26.2018.11.20.20.25.49
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 20 Nov 2018 20:25:50 -0800 (PST)
Subject: Re: [PATCH V10 09/19] block: introduce bio_bvecs()
References: <20181115085306.9910-1-ming.lei@redhat.com>
 <20181115085306.9910-10-ming.lei@redhat.com> <20181116134541.GH3165@lst.de>
 <002fe56b-25e4-573e-c09b-bb12c3e8d25a@grimberg.me>
 <20181120161651.GB2629@lst.de>
 <53526aae-fb9b-ee38-0a01-e5899e2d4e4d@grimberg.me>
 <20181121005902.GA31748@ming.t460p>
 <2d9bee7a-f010-dcf4-1184-094101058584@grimberg.me>
 <20181121034415.GA8408@ming.t460p>
From: Sagi Grimberg <sagi@grimberg.me>
Message-ID: <2a47d336-c19b-6bf4-c247-d7382871eeea@grimberg.me>
Date: Tue, 20 Nov 2018 20:25:46 -0800
MIME-Version: 1.0
In-Reply-To: <20181121034415.GA8408@ming.t460p>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ming Lei <ming.lei@redhat.com>
Cc: Christoph Hellwig <hch@lst.de>, Jens Axboe <axboe@kernel.dk>, linux-block@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Dave Chinner <dchinner@redhat.com>, Kent Overstreet <kent.overstreet@gmail.com>, Mike Snitzer <snitzer@redhat.com>, dm-devel@redhat.com, Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, Shaohua Li <shli@kernel.org>, linux-raid@vger.kernel.org, linux-erofs@lists.ozlabs.org, David Sterba <dsterba@suse.com>, linux-btrfs@vger.kernel.org, "Darrick J . Wong" <darrick.wong@oracle.com>, linux-xfs@vger.kernel.org, Gao Xiang <gaoxiang25@huawei.com>, Theodore Ts'o <tytso@mit.edu>, linux-ext4@vger.kernel.org, Coly Li <colyli@suse.de>, linux-bcache@vger.kernel.org, Boaz Harrosh <ooo@electrozaur.com>, Bob Peterson <rpeterso@redhat.com>, cluster-devel@redhat.com


>> I would like to avoid growing bvec tables and keep everything
>> preallocated. Plus, a bvec_iter operates on a bvec which means
>> we'll need a table there as well... Not liking it so far...
> 
> In case of bios in one request, we can't know how many bvecs there
> are except for calling rq_bvecs(), so it may not be suitable to
> preallocate the table. If you have to send the IO request in one send(),
> runtime allocation may be inevitable.

I don't want to do that, I want to work on a single bvec at a time like
the current implementation does.

> If you don't require to send the IO request in one send(), you may send
> one bio in one time, and just uses the bio's bvec table directly,
> such as the single bio case in lo_rw_aio().

we'd need some indication that we need to reinit my iter with the
new bvec, today we do:

static inline void nvme_tcp_advance_req(struct nvme_tcp_request *req,
                 int len)
{
         req->snd.data_sent += len;
         req->pdu_sent += len;
         iov_iter_advance(&req->snd.iter, len);
         if (!iov_iter_count(&req->snd.iter) &&
             req->snd.data_sent < req->data_len) {
                 req->snd.curr_bio = req->snd.curr_bio->bi_next;
                 nvme_tcp_init_send_iter(req);
         }
}

and initialize the send iter. I imagine that now I will need to
switch to the next bvec and only if I'm on the last I need to
use the next bio...

Do you offer an API for that?


>>> can this way avoid your blocking issue? You may see this
>>> example in branch 'rq->bio != rq->biotail' of lo_rw_aio().
>>
>> This is exactly an example of not ignoring the bios...
> 
> Yeah, that is the most common example, given merge is enabled
> in most of cases. If the driver or device doesn't care merge,
> you can disable it and always get single bio request, then the
> bio's bvec table can be reused for send().

Does bvec_iter span bvecs with your patches? I didn't see that change?

>> I'm not sure how this helps me either. Unless we can set a bvec_iter to
>> span bvecs or have an abstract bio crossing when we re-initialize the
>> bvec_iter I don't see how I can ignore bios completely...
> 
> rq_for_each_bvec() will iterate over all bvecs from all bios, so you
> needn't to see any bio in this req.

But I don't need this iteration, I need a transparent API like;
bvec2 = rq_bvec_next(rq, bvec)

This way I can simply always reinit my iter without thinking about how
the request/bios/bvecs are constructed...

> rq_bvecs() will return how many bvecs there are in this request(cover
> all bios in this req)

Still not very useful given that I don't want to use a table...

>>> So looks nvme-tcp host driver might be the 2nd driver which benefits
>>> from multi-page bvec directly.
>>>
>>> The multi-page bvec V11 has passed my tests and addressed almost
>>> all the comments during review on V10. I removed bio_vecs() in V11,
>>> but it won't be big deal, we can introduce them anytime when there
>>> is the requirement.
>>
>> multipage-bvecs and nvme-tcp are going to conflict, so it would be good
>> to coordinate on this. I think that nvme-tcp host needs some adjustments
>> as setting a bvec_iter. I'm under the impression that the change is rather
>> small and self-contained, but I'm not sure I have the full
>> picture here.
> 
> I guess I may not get your exact requirement on block io iterator from nvme-tcp
> too, :-(

They are pretty much listed above. Today nvme-tcp sets an iterator with:

vec = __bvec_iter_bvec(bio->bi_io_vec, bio->bi_iter);
nsegs = bio_segments(bio);
size = bio->bi_iter.bi_size;
offset = bio->bi_iter.bi_bvec_done;
iov_iter_bvec(&req->snd.iter, WRITE, vec, nsegs, size);

and when done, iterate to the next bio and do the same.

With multipage bvec it would be great if we can simply have
something like rq_bvec_next() that would pretty much satisfy
the requirements from the nvme-tcp side...
