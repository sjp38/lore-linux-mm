Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f176.google.com (mail-qc0-f176.google.com [209.85.216.176])
	by kanga.kvack.org (Postfix) with ESMTP id 69F316B00E7
	for <linux-mm@kvack.org>; Wed,  2 Apr 2014 15:18:06 -0400 (EDT)
Received: by mail-qc0-f176.google.com with SMTP id m20so726341qcx.7
        for <linux-mm@kvack.org>; Wed, 02 Apr 2014 12:18:06 -0700 (PDT)
Date: Wed, 2 Apr 2014 12:17:58 -0700
From: Zach Brown <zab@redhat.com>
Subject: Re: [PATCH 1/6] fs/bio-integrity: remove duplicate code
Message-ID: <20140402191758.GI2394@lenny.home.zabbo.net>
References: <20140324162231.10848.4863.stgit@birch.djwong.org>
 <20140324162238.10848.96492.stgit@birch.djwong.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140324162238.10848.96492.stgit@birch.djwong.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Darrick J. Wong" <darrick.wong@oracle.com>
Cc: axboe@kernel.dk, martin.petersen@oracle.com, JBottomley@parallels.com, jmoyer@redhat.com, bcrl@kvack.org, viro@zeniv.linux.org.uk, linux-fsdevel@vger.kernel.org, linux-aio@kvack.org, Gu Zheng <guz.fnst@cn.fujitsu.com>, linux-scsi@vger.kernel.org, linux-mm@kvack.org

> +static int bio_integrity_generate_verify(struct bio *bio, int operate)
>  {

> +	if (operate)
> +		sector = bio->bi_iter.bi_sector;
> +	else
> +		sector = bio->bi_integrity->bip_iter.bi_sector;

> +		if (operate) {
> +			bi->generate_fn(&bix);
> +		} else {
> +			ret = bi->verify_fn(&bix);
> +			if (ret) {
> +				kunmap_atomic(kaddr);
> +				return ret;
> +			}
> +		}

I was glad to see this replaced with explicit sector and func arguments
in later refactoring in the 6/ patch.

But I don't think the function poiner casts in that 6/ patch are wise
(Or even safe all the time, given crazy function pointer trampolines?
Is that still a thing?).  I'd have made a single walk_fn type that
returns and have the non-returning iterators just return 0.

- z

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
