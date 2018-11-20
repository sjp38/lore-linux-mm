Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi1-f198.google.com (mail-oi1-f198.google.com [209.85.167.198])
	by kanga.kvack.org (Postfix) with ESMTP id 9AE186B21BD
	for <linux-mm@kvack.org>; Tue, 20 Nov 2018 15:11:41 -0500 (EST)
Received: by mail-oi1-f198.google.com with SMTP id m64-v6so1434674oia.1
        for <linux-mm@kvack.org>; Tue, 20 Nov 2018 12:11:41 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t64sor11669987oih.125.2018.11.20.12.11.40
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 20 Nov 2018 12:11:40 -0800 (PST)
Subject: Re: [PATCH V10 09/19] block: introduce bio_bvecs()
References: <20181115085306.9910-1-ming.lei@redhat.com>
 <20181115085306.9910-10-ming.lei@redhat.com> <20181116134541.GH3165@lst.de>
 <002fe56b-25e4-573e-c09b-bb12c3e8d25a@grimberg.me>
 <20181120161651.GB2629@lst.de>
From: Sagi Grimberg <sagi@grimberg.me>
Message-ID: <53526aae-fb9b-ee38-0a01-e5899e2d4e4d@grimberg.me>
Date: Tue, 20 Nov 2018 12:11:35 -0800
MIME-Version: 1.0
In-Reply-To: <20181120161651.GB2629@lst.de>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: Ming Lei <ming.lei@redhat.com>, Jens Axboe <axboe@kernel.dk>, linux-block@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Dave Chinner <dchinner@redhat.com>, Kent Overstreet <kent.overstreet@gmail.com>, Mike Snitzer <snitzer@redhat.com>, dm-devel@redhat.com, Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, Shaohua Li <shli@kernel.org>, linux-raid@vger.kernel.org, linux-erofs@lists.ozlabs.org, David Sterba <dsterba@suse.com>, linux-btrfs@vger.kernel.org, "Darrick J . Wong" <darrick.wong@oracle.com>, linux-xfs@vger.kernel.org, Gao Xiang <gaoxiang25@huawei.com>, Theodore Ts'o <tytso@mit.edu>, linux-ext4@vger.kernel.org, Coly Li <colyli@suse.de>, linux-bcache@vger.kernel.org, Boaz Harrosh <ooo@electrozaur.com>, Bob Peterson <rpeterso@redhat.com>, cluster-devel@redhat.com


>>> The only user in your final tree seems to be the loop driver, and
>>> even that one only uses the helper for read/write bios.
>>>
>>> I think something like this would be much simpler in the end:
>>
>> The recently submitted nvme-tcp host driver should also be a user
>> of this. Does it make sense to keep it as a helper then?
> 
> I did take a brief look at the code, and I really don't understand
> why the heck it even deals with bios to start with.  Like all the
> other nvme transports it is a blk-mq driver and should iterate
> over segments in a request and more or less ignore bios.  Something
> is horribly wrong in the design.

Can you explain a little more? I'm more than happy to change that but
I'm not completely clear how...

Before we begin a data transfer, we need to set our own iterator that
will advance with the progression of the data transfer. We also need to
keep in mind that all the data transfer (both send and recv) are
completely non blocking (and zero-copy when we send).

That means that every data movement needs to be able to suspend
and resume asynchronously. i.e. we cannot use the following pattern:
rq_for_each_segment(bvec, rq, rq_iter) {
	iov_iter_bvec(&iov_iter, WRITE, &bvec, 1, bvec.bv_len);
	send(sock, iov_iter);
}

Given that a request can hold more than a single bio, I'm not clear on
how we can achieve that without iterating over the bios in the request
ourselves.

Any useful insight?
