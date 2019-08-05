Return-Path: <SRS0=3S0K=WB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A58C8C0650F
	for <linux-mm@archiver.kernel.org>; Mon,  5 Aug 2019 22:06:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5D91A2147A
	for <linux-mm@archiver.kernel.org>; Mon,  5 Aug 2019 22:06:16 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5D91A2147A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 05ABE6B000A; Mon,  5 Aug 2019 18:06:16 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 032AB6B000C; Mon,  5 Aug 2019 18:06:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E3B806B000D; Mon,  5 Aug 2019 18:06:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id B00D76B000A
	for <linux-mm@kvack.org>; Mon,  5 Aug 2019 18:06:15 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id g126so7036871pgc.22
        for <linux-mm@kvack.org>; Mon, 05 Aug 2019 15:06:15 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=pDaTeb9IaOKhAKJKqRRPSklvjeNnK+0piCiT4cVDf6M=;
        b=B1CZ0mV6WDXfjuTkX69bicpNxPSMRBfSvIKCdr5T/qnCGU+/t+8drvpOp7kAontcH5
         STJc2sYa1KdaitYYlNt4+ee+2+D0wsoqrthaig7cJZ/U7HGit8Wu6ZSIDIhiFFhwKHSz
         Qo4Qi32tXfE5JVrhcRXTwkm+UMd+O+4yZoFrpBvctytZkAdipVgkAVsFe5XZrj+Fyf8s
         +z7MHX73f/z5ATAEkk8zkpiKackwq5gsevp5v8CDsnPygedFMtsZUzmR8JLNzKUz6LW/
         oi4GITHYXgpM/Y7nSuxzdt440nDiHybC/4hxMFnst8MetU+b63LhCrXRpUVpXOHUtBTQ
         b9hw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.65 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAUo+IiXrE7sp4+PqI6QJnbcjo/ywp2/RazsaPoDN182REBXLHIG
	XE+jXwLkKr0X2SEabKpoAyiWRrJWAEFHLY+3rXm6Kg4V5Jjg4YOKE5dmic35yxnFS4wwTLuG7Nd
	rsnLWXGn5KEvmCIpD1vA2B/eTVvNWonNdclMca2NhBXEM+1TJ2pWZXflGRGJBuYYHDg==
X-Received: by 2002:a65:6846:: with SMTP id q6mr93912pgt.150.1565042775236;
        Mon, 05 Aug 2019 15:06:15 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwaXo0uwjF+6gLNkaWzmPXwwxaPRhP6xJ8fcBvaM6VfaRNEjgLWTLErx3/XQMTh7UGqUqB5
X-Received: by 2002:a65:6846:: with SMTP id q6mr93868pgt.150.1565042774563;
        Mon, 05 Aug 2019 15:06:14 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565042774; cv=none;
        d=google.com; s=arc-20160816;
        b=lsx3+kMYfQqy2avfo0zHJWPebSG4NET/ACsD3zyXT4clu+x9a1Jlhfwp+epBtWbLai
         DK+/GTNj0lpXk49+CRHD3Dg4+r9/E9Qds94xT/L7GiLm9PQBK3RONweLTiuucl6TIt2Z
         OGOo/K4TjMSHgDOlxAhlDWvl07Ejvle20Gya58dApFHyag4NI3ldP/KKh89duyFreO7h
         oGRqByUJ+iH1EaMDjmH4nCh2lXoP/Gzq3J9fi6+pLcLZSBkref29Pxd6Hbj5N198HTaG
         k99ockU0GYXxy+5mVqa9LtPzOf8s/SS8+9NRi6ULNt5b9PIlLvXvnsJlCEtK1hbAKLYk
         JPGw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=pDaTeb9IaOKhAKJKqRRPSklvjeNnK+0piCiT4cVDf6M=;
        b=Q2m+FsIPQD28eDFU88W5g7Zvx2+2Hna9aZzilHUKQac+1tNy56Wc5LRVH6WtGeSJlK
         a0vdJox9RPbh+cxll5cBpJOAakjFzJggkAtw1Ct+8gbYFc6AdHkoBHW7k3r+AwyI0pvs
         76lLW3NSFtvpAQ9nNYaeLg0PYM5ljgogW52Q+C1xvPSVO/MAxOYt4WtZv9TtBom7u9cI
         8h6ZbigXkTBSR3dZxre2Vp/4Yfma1yesXE6d9jmPQijfCCwlcuwWmZcYLJF10t5Duwaf
         JVeNJVh2gZxsob//JFvSwY+hccroujnWO2s3LBuDhSMg6M/NQsIdADmsP998v0/bkCST
         y7DA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.65 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id 65si46507871pfg.241.2019.08.05.15.06.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Aug 2019 15:06:14 -0700 (PDT)
Received-SPF: pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.65 as permitted sender) client-ip=134.134.136.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.65 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNKNOWN
X-Amp-Original-Verdict: FILE UNKNOWN
X-Amp-File-Uploaded: False
Received: from orsmga005.jf.intel.com ([10.7.209.41])
  by orsmga103.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 05 Aug 2019 15:05:49 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.64,350,1559545200"; 
   d="scan'208";a="349235770"
Received: from iweiny-desk2.sc.intel.com ([10.3.52.157])
  by orsmga005.jf.intel.com with ESMTP; 05 Aug 2019 15:05:48 -0700
Date: Mon, 5 Aug 2019 15:05:48 -0700
From: Ira Weiny <ira.weiny@intel.com>
To: john.hubbard@gmail.com
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Christoph Hellwig <hch@infradead.org>, Jan Kara <jack@suse.cz>,
	Jason Gunthorpe <jgg@ziepe.ca>, Jerome Glisse <jglisse@redhat.com>,
	LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org,
	linux-fsdevel@vger.kernel.org, John Hubbard <jhubbard@nvidia.com>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	Jens Axboe <axboe@kernel.dk>, linux-block@vger.kernel.org
Subject: Re: [PATCH] fs/io_uring.c: convert put_page() to put_user_page*()
Message-ID: <20190805220547.GB23416@iweiny-DESK2.sc.intel.com>
References: <20190805023206.8831-1-jhubbard@nvidia.com>
 <20190805220441.GA23416@iweiny-DESK2.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190805220441.GA23416@iweiny-DESK2.sc.intel.com>
User-Agent: Mutt/1.11.1 (2018-12-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Aug 05, 2019 at 03:04:42PM -0700, 'Ira Weiny' wrote:
> On Sun, Aug 04, 2019 at 07:32:06PM -0700, john.hubbard@gmail.com wrote:
> > From: John Hubbard <jhubbard@nvidia.com>
> > 
> > For pages that were retained via get_user_pages*(), release those pages
> > via the new put_user_page*() routines, instead of via put_page() or
> > release_pages().
> > 
> > This is part a tree-wide conversion, as described in commit fc1d8e7cca2d
> > ("mm: introduce put_user_page*(), placeholder versions").
> > 
> > Cc: Alexander Viro <viro@zeniv.linux.org.uk>
> > Cc: Jens Axboe <axboe@kernel.dk>
> > Cc: linux-fsdevel@vger.kernel.org
> > Cc: linux-block@vger.kernel.org
> > Signed-off-by: John Hubbard <jhubbard@nvidia.com>
> 
> Signed-off-by: Ira Weiny <ira.weiny@intel.com>

<sigh>

I meant to say I wrote the same patch ...  For this one...

Reviewed-by: Ira Weiny <ira.weiny@intel.com>

> 
> > ---
> >  fs/io_uring.c | 8 +++-----
> >  1 file changed, 3 insertions(+), 5 deletions(-)
> > 
> > diff --git a/fs/io_uring.c b/fs/io_uring.c
> > index d542f1cf4428..8a1de5ab9c6d 100644
> > --- a/fs/io_uring.c
> > +++ b/fs/io_uring.c
> > @@ -2815,7 +2815,7 @@ static int io_sqe_buffer_unregister(struct io_ring_ctx *ctx)
> >  		struct io_mapped_ubuf *imu = &ctx->user_bufs[i];
> >  
> >  		for (j = 0; j < imu->nr_bvecs; j++)
> > -			put_page(imu->bvec[j].bv_page);
> > +			put_user_page(imu->bvec[j].bv_page);
> >  
> >  		if (ctx->account_mem)
> >  			io_unaccount_mem(ctx->user, imu->nr_bvecs);
> > @@ -2959,10 +2959,8 @@ static int io_sqe_buffer_register(struct io_ring_ctx *ctx, void __user *arg,
> >  			 * if we did partial map, or found file backed vmas,
> >  			 * release any pages we did get
> >  			 */
> > -			if (pret > 0) {
> > -				for (j = 0; j < pret; j++)
> > -					put_page(pages[j]);
> > -			}
> > +			if (pret > 0)
> > +				put_user_pages(pages, pret);
> >  			if (ctx->account_mem)
> >  				io_unaccount_mem(ctx->user, nr_pages);
> >  			kvfree(imu->bvec);
> > -- 
> > 2.22.0
> > 

