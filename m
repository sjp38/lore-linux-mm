Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id ED5E96B244F
	for <linux-mm@kvack.org>; Wed, 21 Nov 2018 00:35:12 -0500 (EST)
Received: by mail-pl1-f197.google.com with SMTP id o10-v6so5993328plk.16
        for <linux-mm@kvack.org>; Tue, 20 Nov 2018 21:35:12 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 4-v6sor55065303plh.23.2018.11.20.21.35.11
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 20 Nov 2018 21:35:11 -0800 (PST)
Subject: Re: [PATCH V10 09/19] block: introduce bio_bvecs()
References: <20181115085306.9910-10-ming.lei@redhat.com>
 <20181116134541.GH3165@lst.de>
 <002fe56b-25e4-573e-c09b-bb12c3e8d25a@grimberg.me>
 <20181120161651.GB2629@lst.de>
 <53526aae-fb9b-ee38-0a01-e5899e2d4e4d@grimberg.me>
 <20181121005902.GA31748@ming.t460p>
 <2d9bee7a-f010-dcf4-1184-094101058584@grimberg.me>
 <20181121034415.GA8408@ming.t460p>
 <2a47d336-c19b-6bf4-c247-d7382871eeea@grimberg.me>
 <7378bf49-5a7e-5622-d4d1-808ba37ce656@grimberg.me>
 <20181121050359.GA31915@ming.t460p>
From: Sagi Grimberg <sagi@grimberg.me>
Message-ID: <fc268b0e-61b5-aacc-67be-cb7b266c6d8f@grimberg.me>
Date: Tue, 20 Nov 2018 21:35:07 -0800
MIME-Version: 1.0
In-Reply-To: <20181121050359.GA31915@ming.t460p>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ming Lei <ming.lei@redhat.com>
Cc: Christoph Hellwig <hch@lst.de>, Jens Axboe <axboe@kernel.dk>, linux-block@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Dave Chinner <dchinner@redhat.com>, Kent Overstreet <kent.overstreet@gmail.com>, Mike Snitzer <snitzer@redhat.com>, dm-devel@redhat.com, Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, Shaohua Li <shli@kernel.org>, linux-raid@vger.kernel.org, linux-erofs@lists.ozlabs.org, David Sterba <dsterba@suse.com>, linux-btrfs@vger.kernel.org, "Darrick J . Wong" <darrick.wong@oracle.com>, linux-xfs@vger.kernel.org, Gao Xiang <gaoxiang25@huawei.com>, Theodore Ts'o <tytso@mit.edu>, linux-ext4@vger.kernel.org, Coly Li <colyli@suse.de>, linux-bcache@vger.kernel.org, Boaz Harrosh <ooo@electrozaur.com>, Bob Peterson <rpeterso@redhat.com>, cluster-devel@redhat.com


>> Wait, I see that the bvec is still a single array per bio. When you said
>> a table I thought you meant a 2-dimentional array...
> 
> I mean a new 1-d table A has to be created for multiple bios in one rq,
> and build it in the following way
> 
>             rq_for_each_bvec(tmp, rq, rq_iter)
>                      *A = tmp;
> 
> Then you can pass A to iov_iter_bvec() & send().
> 
> Given it is over TCP, I guess it should be doable for you to preallocate one
> 256-bvec table in one page for each request, then sets the max segment size as
> (unsigned int)-1, and max segment number as 256, the preallocated table
> should work anytime.

256 bvec table is really a lot to preallocate, especially when its not
needed, I can easily initialize the bvec_iter on the bio bvec. If this
involves preallocation of the worst-case than I don't consider this to
be an improvement.
