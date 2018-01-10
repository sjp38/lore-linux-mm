Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f198.google.com (mail-ot0-f198.google.com [74.125.82.198])
	by kanga.kvack.org (Postfix) with ESMTP id 0EE0B6B0038
	for <linux-mm@kvack.org>; Tue,  9 Jan 2018 21:41:17 -0500 (EST)
Received: by mail-ot0-f198.google.com with SMTP id t27so8486432otf.10
        for <linux-mm@kvack.org>; Tue, 09 Jan 2018 18:41:17 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 9si4097101oic.271.2018.01.09.18.41.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 Jan 2018 18:41:15 -0800 (PST)
Date: Wed, 10 Jan 2018 10:40:53 +0800
From: Ming Lei <ming.lei@redhat.com>
Subject: Re: [PATCH V4 13/45] block: blk-merge: try to make front segments in
 full size
Message-ID: <20180110024046.GA18922@ming.t460p>
References: <20171218122247.3488-1-ming.lei@redhat.com>
 <20171218122247.3488-14-ming.lei@redhat.com>
 <c3227c8f-c782-7685-c3eb-af558a082399@gmail.com>
 <20180109023432.GB31067@ming.t460p>
 <e816e626-b8b0-c14e-ba08-cafe76dcf233@gmail.com>
 <20180109143339.GC4356@ming.t460p>
 <be7f7e1b-88c8-54f5-37c3-672f8426c6ca@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <be7f7e1b-88c8-54f5-37c3-672f8426c6ca@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Osipenko <digetx@gmail.com>
Cc: Jens Axboe <axboe@fb.com>, Christoph Hellwig <hch@infradead.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Kent Overstreet <kent.overstreet@gmail.com>, Huang Ying <ying.huang@intel.com>, linux-kernel@vger.kernel.org, linux-block@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Theodore Ts'o <tytso@mit.edu>, "Darrick J . Wong" <darrick.wong@oracle.com>, Coly Li <colyli@suse.de>, Filipe Manana <fdmanana@gmail.com>, Ulf Hansson <ulf.hansson@linaro.org>, linux-mmc@vger.kernel.org

On Tue, Jan 09, 2018 at 08:02:53PM +0300, Dmitry Osipenko wrote:
> On 09.01.2018 17:33, Ming Lei wrote:
> > On Tue, Jan 09, 2018 at 04:18:39PM +0300, Dmitry Osipenko wrote:
> >> On 09.01.2018 05:34, Ming Lei wrote:
> >>> On Tue, Jan 09, 2018 at 12:09:27AM +0300, Dmitry Osipenko wrote:
> >>>> On 18.12.2017 15:22, Ming Lei wrote:
> >>>>> When merging one bvec into segment, if the bvec is too big
> >>>>> to merge, current policy is to move the whole bvec into another
> >>>>> new segment.
> >>>>>
> >>>>> This patchset changes the policy into trying to maximize size of
> >>>>> front segments, that means in above situation, part of bvec
> >>>>> is merged into current segment, and the remainder is put
> >>>>> into next segment.
> >>>>>
> >>>>> This patch prepares for support multipage bvec because
> >>>>> it can be quite common to see this case and we should try
> >>>>> to make front segments in full size.
> >>>>>
> >>>>> Signed-off-by: Ming Lei <ming.lei@redhat.com>
> >>>>> ---
> >>>>>  block/blk-merge.c | 54 +++++++++++++++++++++++++++++++++++++++++++++++++-----
> >>>>>  1 file changed, 49 insertions(+), 5 deletions(-)
> >>>>>
> >>>>> diff --git a/block/blk-merge.c b/block/blk-merge.c
> >>>>> index a476337a8ff4..42ceb89bc566 100644
> >>>>> --- a/block/blk-merge.c
> >>>>> +++ b/block/blk-merge.c
> >>>>> @@ -109,6 +109,7 @@ static struct bio *blk_bio_segment_split(struct request_queue *q,
> >>>>>  	bool do_split = true;
> >>>>>  	struct bio *new = NULL;
> >>>>>  	const unsigned max_sectors = get_max_io_size(q, bio);
> >>>>> +	unsigned advance = 0;
> >>>>>  
> >>>>>  	bio_for_each_segment(bv, bio, iter) {
> >>>>>  		/*
> >>>>> @@ -134,12 +135,32 @@ static struct bio *blk_bio_segment_split(struct request_queue *q,
> >>>>>  		}
> >>>>>  
> >>>>>  		if (bvprvp && blk_queue_cluster(q)) {
> >>>>> -			if (seg_size + bv.bv_len > queue_max_segment_size(q))
> >>>>> -				goto new_segment;
> >>>>>  			if (!BIOVEC_PHYS_MERGEABLE(bvprvp, &bv))
> >>>>>  				goto new_segment;
> >>>>>  			if (!BIOVEC_SEG_BOUNDARY(q, bvprvp, &bv))
> >>>>>  				goto new_segment;
> >>>>> +			if (seg_size + bv.bv_len > queue_max_segment_size(q)) {
> >>>>> +				/*
> >>>>> +				 * On assumption is that initial value of
> >>>>> +				 * @seg_size(equals to bv.bv_len) won't be
> >>>>> +				 * bigger than max segment size, but will
> >>>>> +				 * becomes false after multipage bvec comes.
> >>>>> +				 */
> >>>>> +				advance = queue_max_segment_size(q) - seg_size;
> >>>>> +
> >>>>> +				if (advance > 0) {
> >>>>> +					seg_size += advance;
> >>>>> +					sectors += advance >> 9;
> >>>>> +					bv.bv_len -= advance;
> >>>>> +					bv.bv_offset += advance;
> >>>>> +				}
> >>>>> +
> >>>>> +				/*
> >>>>> +				 * Still need to put remainder of current
> >>>>> +				 * bvec into a new segment.
> >>>>> +				 */
> >>>>> +				goto new_segment;
> >>>>> +			}
> >>>>>  
> >>>>>  			seg_size += bv.bv_len;
> >>>>>  			bvprv = bv;
> >>>>> @@ -161,6 +182,12 @@ static struct bio *blk_bio_segment_split(struct request_queue *q,
> >>>>>  		seg_size = bv.bv_len;
> >>>>>  		sectors += bv.bv_len >> 9;
> >>>>>  
> >>>>> +		/* restore the bvec for iterator */
> >>>>> +		if (advance) {
> >>>>> +			bv.bv_len += advance;
> >>>>> +			bv.bv_offset -= advance;
> >>>>> +			advance = 0;
> >>>>> +		}
> >>>>>  	}
> >>>>>  
> >>>>>  	do_split = false;
> >>>>> @@ -361,16 +388,29 @@ __blk_segment_map_sg(struct request_queue *q, struct bio_vec *bvec,
> >>>>>  {
> >>>>>  
> >>>>>  	int nbytes = bvec->bv_len;
> >>>>> +	unsigned advance = 0;
> >>>>>  
> >>>>>  	if (*sg && *cluster) {
> >>>>> -		if ((*sg)->length + nbytes > queue_max_segment_size(q))
> >>>>> -			goto new_segment;
> >>>>> -
> >>>>>  		if (!BIOVEC_PHYS_MERGEABLE(bvprv, bvec))
> >>>>>  			goto new_segment;
> >>>>>  		if (!BIOVEC_SEG_BOUNDARY(q, bvprv, bvec))
> >>>>>  			goto new_segment;
> >>>>>  
> >>>>> +		/*
> >>>>> +		 * try best to merge part of the bvec into previous
> >>>>> +		 * segment and follow same policy with
> >>>>> +		 * blk_bio_segment_split()
> >>>>> +		 */
> >>>>> +		if ((*sg)->length + nbytes > queue_max_segment_size(q)) {
> >>>>> +			advance = queue_max_segment_size(q) - (*sg)->length;
> >>>>> +			if (advance) {
> >>>>> +				(*sg)->length += advance;
> >>>>> +				bvec->bv_offset += advance;
> >>>>> +				bvec->bv_len -= advance;
> >>>>> +			}
> >>>>> +			goto new_segment;
> >>>>> +		}
> >>>>> +
> >>>>>  		(*sg)->length += nbytes;
> >>>>>  	} else {
> >>>>>  new_segment:
> >>>>> @@ -393,6 +433,10 @@ __blk_segment_map_sg(struct request_queue *q, struct bio_vec *bvec,
> >>>>>  
> >>>>>  		sg_set_page(*sg, bvec->bv_page, nbytes, bvec->bv_offset);
> >>>>>  		(*nsegs)++;
> >>>>> +
> >>>>> +		/* for making iterator happy */
> >>>>> +		bvec->bv_offset -= advance;
> >>>>> +		bvec->bv_len += advance;
> >>>>>  	}
> >>>>>  	*bvprv = *bvec;
> >>>>>  }
> >>>>>
> >>>>
> >>>> Hello,
> >>>>
> >>>> This patch breaks MMC on next-20180108, in particular MMC doesn't work anymore
> >>>> with this patch on NVIDIA Tegra20:
> >>>>
> >>>> <3>[   36.622253] print_req_error: I/O error, dev mmcblk1, sector 512
> >>>> <3>[   36.671233] print_req_error: I/O error, dev mmcblk2, sector 128
> >>>> <3>[   36.711308] print_req_error: I/O error, dev mmcblk1, sector 31325304
> >>>> <3>[   36.749232] print_req_error: I/O error, dev mmcblk2, sector 512
> >>>> <3>[   36.761235] print_req_error: I/O error, dev mmcblk1, sector 31325816
> >>>> <3>[   36.832039] print_req_error: I/O error, dev mmcblk2, sector 31259768
> >>>> <3>[   99.793248] print_req_error: I/O error, dev mmcblk1, sector 31323136
> >>>> <3>[   99.982043] print_req_error: I/O error, dev mmcblk1, sector 929792
> >>>> <3>[   99.986301] print_req_error: I/O error, dev mmcblk1, sector 930816
> >>>> <3>[  100.293624] print_req_error: I/O error, dev mmcblk1, sector 932864
> >>>> <3>[  100.466839] print_req_error: I/O error, dev mmcblk1, sector 947200
> >>>> <3>[  100.642955] print_req_error: I/O error, dev mmcblk1, sector 949248
> >>>> <3>[  100.818838] print_req_error: I/O error, dev mmcblk1, sector 230400
> >>>>
> >>>> Any attempt of mounting MMC block dev ends with a kernel crash. Reverting this
> >>>> patch fixes the issue.
> >>>
> >>> Hi Dmitry,
> >>>
> >>> Thanks for your report!
> >>>
> >>> Could you share us what the segment limits are on your MMC?
> >>>
> >>> 	cat /sys/block/mmcN/queue/max_segment_size
> >>> 	cat /sys/block/mmcN/queue/max_segments
> >>>
> >>> Please test the following patch to see if your issue can be fixed?
> >>>
> >>> ---
> >>> diff --git a/block/blk-merge.c b/block/blk-merge.c
> >>> index 446f63e076aa..cfab36c26608 100644
> >>> --- a/block/blk-merge.c
> >>> +++ b/block/blk-merge.c
> >>> @@ -431,12 +431,14 @@ __blk_segment_map_sg(struct request_queue *q, struct bio_vec *bvec,
> >>>  
> >>>  		sg_set_page(*sg, bvec->bv_page, nbytes, bvec->bv_offset);
> >>>  		(*nsegs)++;
> >>> +	}
> >>>  
> >>> +	*bvprv = *bvec;
> >>> +	if (advance) {
> >>>  		/* for making iterator happy */
> >>>  		bvec->bv_offset -= advance;
> >>>  		bvec->bv_len += advance;
> >>>  	}
> >>> -	*bvprv = *bvec;
> >>>  }
> >>>  
> >>>  static inline int __blk_bvec_map_sg(struct request_queue *q, struct bio_vec bv,
> >>
> >> Hi Ming,
> >>
> >> I've tried your patch and unfortunately it doesn't help with the issue.
> >>
> >> Here are the segment limits:
> >>
> >> # cat /sys/block/mmc*/queue/max_segment_size
> >> 65535
> > 
> > Hi Dmitry,
> > 
> > The 'max_segment_size' of 65535 should be the reason, could you test the
> > following patch?
> > 
> > ---
> > diff --git a/block/blk-merge.c b/block/blk-merge.c
> > index 446f63e076aa..38a66e3e678e 100644
> > --- a/block/blk-merge.c
> > +++ b/block/blk-merge.c
> > @@ -12,6 +12,8 @@
> >  
> >  #include "blk.h"
> >  
> > +#define sector_align(x)   ALIGN_DOWN(x, 512)
> > +
> >  static struct bio *blk_bio_discard_split(struct request_queue *q,
> >  					 struct bio *bio,
> >  					 struct bio_set *bs,
> > @@ -109,7 +111,7 @@ static struct bio *blk_bio_segment_split(struct request_queue *q,
> >  	bool do_split = true;
> >  	struct bio *new = NULL;
> >  	const unsigned max_sectors = get_max_io_size(q, bio);
> > -	unsigned advance = 0;
> > +	int advance = 0;
> >  
> >  	bio_for_each_segment(bv, bio, iter) {
> >  		/*
> > @@ -144,8 +146,9 @@ static struct bio *blk_bio_segment_split(struct request_queue *q,
> >  				 * bigger than max segment size, but this
> >  				 * becomes false after multipage bvecs.
> >  				 */
> > -				advance = queue_max_segment_size(q) - seg_size;
> > -
> > +				advance = sector_align(
> > +						queue_max_segment_size(q) -
> > +						seg_size);
> >  				if (advance > 0) {
> >  					seg_size += advance;
> >  					sectors += advance >> 9;
> > @@ -386,7 +389,7 @@ __blk_segment_map_sg(struct request_queue *q, struct bio_vec *bvec,
> >  {
> >  
> >  	int nbytes = bvec->bv_len;
> > -	unsigned advance = 0;
> > +	int advance = 0;
> >  
> >  	if (*sg && *cluster) {
> >  		if (!BIOVEC_PHYS_MERGEABLE(bvprv, bvec))
> > @@ -400,8 +403,9 @@ __blk_segment_map_sg(struct request_queue *q, struct bio_vec *bvec,
> >  		 * blk_bio_segment_split()
> >  		 */
> >  		if ((*sg)->length + nbytes > queue_max_segment_size(q)) {
> > -			advance = queue_max_segment_size(q) - (*sg)->length;
> > -			if (advance) {
> > +			advance = sector_align(queue_max_segment_size(q) -
> > +					(*sg)->length);
> > +			if (advance > 0) {
> >  				(*sg)->length += advance;
> >  				bvec->bv_offset += advance;
> >  				bvec->bv_len -= advance;
> > @@ -431,12 +435,14 @@ __blk_segment_map_sg(struct request_queue *q, struct bio_vec *bvec,
> >  
> >  		sg_set_page(*sg, bvec->bv_page, nbytes, bvec->bv_offset);
> >  		(*nsegs)++;
> > +	}
> >  
> > +	*bvprv = *bvec;
> > +	if (advance > 0) {
> >  		/* for making iterator happy */
> >  		bvec->bv_offset -= advance;
> >  		bvec->bv_len += advance;
> >  	}
> > -	*bvprv = *bvec;
> >  }
> >  
> >  static inline int __blk_bvec_map_sg(struct request_queue *q, struct bio_vec bv,
> 
> This patch doesn't help either.

OK, I will send a revert later.

Thinking of the patch further, we don't need this kind of logic for
multipage bvec at all since almost all bvecs won't be contiguous if
bio_add_page() is used after multipage bvec is enabled.

Thanks,
Ming

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
