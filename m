Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 3F2F06B0007
	for <linux-mm@kvack.org>; Wed, 27 Jun 2018 22:01:53 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id w22-v6so774578edr.14
        for <linux-mm@kvack.org>; Wed, 27 Jun 2018 19:01:53 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l56-v6si249372edd.239.2018.06.27.19.01.51
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 27 Jun 2018 19:01:51 -0700 (PDT)
Subject: Re: [PATCH V7 20/24] bcache: avoid to use bio_for_each_segment_all()
 in bch_bio_alloc_pages()
References: <20180627124548.3456-1-ming.lei@redhat.com>
 <20180627124548.3456-21-ming.lei@redhat.com>
 <e1499d87-62b8-40a8-75a5-d9d1d81ce9c5@suse.de>
 <20180628012816.GH7583@ming.t460p>
From: Coly Li <colyli@suse.de>
Message-ID: <92ae1547-39b1-472c-efbe-c0a6430fc3f6@suse.de>
Date: Thu, 28 Jun 2018 10:01:39 +0800
MIME-Version: 1.0
In-Reply-To: <20180628012816.GH7583@ming.t460p>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ming Lei <ming.lei@redhat.com>
Cc: Jens Axboe <axboe@fb.com>, Christoph Hellwig <hch@infradead.org>, Kent Overstreet <kent.overstreet@gmail.com>, David Sterba <dsterba@suse.cz>, Huang Ying <ying.huang@intel.com>, Mike Snitzer <snitzer@redhat.com>, linux-kernel@vger.kernel.org, linux-block@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Theodore Ts'o <tytso@mit.edu>, "Darrick J . Wong" <darrick.wong@oracle.com>, Filipe Manana <fdmanana@gmail.com>, Randy Dunlap <rdunlap@infradead.org>, linux-bcache@vger.kernel.org

On 2018/6/28 9:28 AM, Ming Lei wrote:
> On Wed, Jun 27, 2018 at 11:55:33PM +0800, Coly Li wrote:
>> On 2018/6/27 8:45 PM, Ming Lei wrote:
>>> bch_bio_alloc_pages() is always called on one new bio, so it is safe
>>> to access the bvec table directly. Given it is the only kind of this
>>> case, open code the bvec table access since bio_for_each_segment_all()
>>> will be changed to support for iterating over multipage bvec.
>>>
>>> Cc: Coly Li <colyli@suse.de>
>>> Cc: linux-bcache@vger.kernel.org
>>> Signed-off-by: Ming Lei <ming.lei@redhat.com>
>>> ---
>>>  drivers/md/bcache/util.c | 2 +-
>>>  1 file changed, 1 insertion(+), 1 deletion(-)
>>>
>>> diff --git a/drivers/md/bcache/util.c b/drivers/md/bcache/util.c
>>> index fc479b026d6d..9f2a6fd5dfc9 100644
>>> --- a/drivers/md/bcache/util.c
>>> +++ b/drivers/md/bcache/util.c
>>> @@ -268,7 +268,7 @@ int bch_bio_alloc_pages(struct bio *bio, gfp_t gfp_mask)
>>>  	int i;
>>>  	struct bio_vec *bv;
>>>
>>
>> Hi Ming,
>>
>>> -	bio_for_each_segment_all(bv, bio, i) {
>>> +	for (i = 0, bv = bio->bi_io_vec; i < bio->bi_vcnt; bv++) {
>>
>>
>> Is it possible to treat this as a special condition of
>> bio_for_each_segement_all() ? I mean only iterate one time in
>> bvec_for_each_segment(). I hope the above change is not our last choice
>> before I reply an Acked-by :-)
> 
> Now the bvec from bio_for_each_segement_all() can't be changed any more
> since the referenced 'bvec' is generated in-flight given we store
> real multipage bvec.
> 
> BTW, this way is actually suggested by Christoph for saving one new
> helper of bio_for_each_bvec_all() as done in V6, and per previous discussion,
> seems both Kent and Christoph agrees to convert bcache into bio_add_page()
> finally.
> 
> So I guess this open code style should be fine.

Hi Ming,

I see, thanks for the hint.

Acked-by: Coly Li <colyli@suse.de>

Coly Li
