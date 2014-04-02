Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id 072406B010F
	for <linux-mm@kvack.org>; Wed,  2 Apr 2014 16:36:04 -0400 (EDT)
Received: by mail-pa0-f52.google.com with SMTP id rd3so718376pab.25
        for <linux-mm@kvack.org>; Wed, 02 Apr 2014 13:36:04 -0700 (PDT)
Date: Wed, 2 Apr 2014 13:35:51 -0700
From: "Darrick J. Wong" <darrick.wong@oracle.com>
Subject: Re: [PATCH 1/6] fs/bio-integrity: remove duplicate code
Message-ID: <20140402203551.GA10230@birch.djwong.org>
References: <20140324162231.10848.4863.stgit@birch.djwong.org>
 <20140324162238.10848.96492.stgit@birch.djwong.org>
 <20140402191758.GI2394@lenny.home.zabbo.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140402191758.GI2394@lenny.home.zabbo.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zach Brown <zab@redhat.com>
Cc: axboe@kernel.dk, martin.petersen@oracle.com, JBottomley@parallels.com, jmoyer@redhat.com, bcrl@kvack.org, viro@zeniv.linux.org.uk, linux-fsdevel@vger.kernel.org, linux-aio@kvack.org, Gu Zheng <guz.fnst@cn.fujitsu.com>, linux-scsi@vger.kernel.org, linux-mm@kvack.org

On Wed, Apr 02, 2014 at 12:17:58PM -0700, Zach Brown wrote:
> > +static int bio_integrity_generate_verify(struct bio *bio, int operate)
> >  {
> 
> > +	if (operate)
> > +		sector = bio->bi_iter.bi_sector;
> > +	else
> > +		sector = bio->bi_integrity->bip_iter.bi_sector;
> 
> > +		if (operate) {
> > +			bi->generate_fn(&bix);
> > +		} else {
> > +			ret = bi->verify_fn(&bix);
> > +			if (ret) {
> > +				kunmap_atomic(kaddr);
> > +				return ret;
> > +			}
> > +		}
> 
> I was glad to see this replaced with explicit sector and func arguments
> in later refactoring in the 6/ patch.
> 
> But I don't think the function poiner casts in that 6/ patch are wise
> (Or even safe all the time, given crazy function pointer trampolines?
> Is that still a thing?).  I'd have made a single walk_fn type that
> returns and have the non-returning iterators just return 0.

Noted.  I cleaned all that crap out just yesterday, so now there's only one
walk function and some context data that gets passed to the iterator function.
Much less horrifying.

(I really only included this patch so that I'd have less rebasing work when
3.15-rc1 comes out.)

--D
> 
> - z
> --
> To unsubscribe from this list: send the line "unsubscribe linux-fsdevel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
