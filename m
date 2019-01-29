Return-Path: <SRS0=Ydgi=QF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-13.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4DD3AC4151A
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 04:46:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DD219217F5
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 04:46:11 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="AhB3TneB"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DD219217F5
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3B5448E0002; Mon, 28 Jan 2019 23:46:11 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3649E8E0001; Mon, 28 Jan 2019 23:46:11 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 27AE38E0002; Mon, 28 Jan 2019 23:46:11 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id DAC018E0001
	for <linux-mm@kvack.org>; Mon, 28 Jan 2019 23:46:10 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id q64so15824144pfa.18
        for <linux-mm@kvack.org>; Mon, 28 Jan 2019 20:46:10 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=eVdQI+bKFnHxHsyrWVjxAl5UcBq6aUXQPMqjgJnSXMU=;
        b=kZWJMYW2L+G+/GAekXiB88i0R42FFDxLmM4wX/mZRfPJGz3mamx27ibu2+BRMFsf0K
         dCifXTY6xhAlbNoA7ew1YpP3bLjpPKezfeBjosZimZ69onZUaxPBYuzmYbxwaNcNsmOj
         fOMyxFmazQA7pFsZ9GpXsyIhopofAfF2k05zET3yfVuWZEk5bRv41fsWjBB9QCpDWwDw
         OPlCc6PpxRbX/+OpqYbiiL3qVUIYzni53ufteo60WIihXj8tK3tT6Jylbo8FPreL2XSD
         z/eW+vfjpxDEM8cgchb9/0wIAyh9MLAfFQxVx839anXGbZjXKnPJaQ+XkvcZdwY0s51d
         VSnw==
X-Gm-Message-State: AJcUukeTYhBpoUUIk1Z1/6bN0r2cjNtEUnsrFGrrJ2KUp7L/zGvUryM+
	zSEloNi74yQ1226pJPlTQZr+xmWPP78BepRtoRYnkpXqGqYymV2gZiAqoAb4agzhKaXKix8SD1E
	dlRqqkevVa9EWTLUWj4aUvT6bPtK2dyXfO+sIEjWHRLcfvvUMNUsMCcqxyLLo78mct0OYOKtwcg
	sC4Id3iaijtZT+CSMJTP9xSquHc4ctpHsO52YYb9eUATio7XZ5OfDoIqjU0WCLPPv9NEM35oNeJ
	Hc0lGSNb0xtiQWopOHfc6wu9Ad52RyKnF4SVoVMmbmXAAZ7rKRXGPOiE8plnSeSujd43uwkE1eo
	Z0yLLlprSkOXQuGAc+6c2vKMfjwkf99da92OmVggv9jKqDeiVCCqzRjIZ334tBBAsZXH2K9dbHx
	S
X-Received: by 2002:a63:ff16:: with SMTP id k22mr22515823pgi.244.1548737170481;
        Mon, 28 Jan 2019 20:46:10 -0800 (PST)
X-Received: by 2002:a63:ff16:: with SMTP id k22mr22515795pgi.244.1548737169667;
        Mon, 28 Jan 2019 20:46:09 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548737169; cv=none;
        d=google.com; s=arc-20160816;
        b=Mfcgx6djUqlbsSwdBKQGGY7Oz7SrdZSjQk43ujt/+Tyvp4fWlo0xPt+5qv5WqjbasV
         LO6slL0xlI1fGDaWLbjFxZ4rd+xXoP8tJE/kCLsLVMtxH5Cineb2IklpAQbHt2lM6/E3
         psbD+KgHeIo+2mxBia212cBEj5DOggC4OBjZLavD8Rp84mL+P4MRCchfREcnntd+iFlB
         faSUI/M74XKxviRoiLxg2ZtqoDJ2IWvd4yaCbdQHLIB2gGPF3/2JATDlRWEo7Yq8vR47
         2XgiV6VEU7wMLkIWN7/TGgT4w/aZDAJ8AXCjEPNgOUZIPSwSnUrWzGXsm25jURp1rDUY
         p6UQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=eVdQI+bKFnHxHsyrWVjxAl5UcBq6aUXQPMqjgJnSXMU=;
        b=o3aE7gALjjHt43p3op+AIpIMlEaykOI6Mbj6aUns3y6CANWCezEg5TK/cZ7ILLXfxn
         20wAL53NoyXiYnWo6f6pjSrz+2vhJs+GajAtcfbTmgEuzVn6KNnLUKTuhk9Fv9ZjD05I
         bow3NaQ55G9sed28vqSPAHBhH9oe93NdgmBz4QJIRUHarqW9e3L1Uri2vHR1j4+SBwHF
         I5P9l39Kq1lPMZIAFFOAH0yhufAOBgQp8W1P2htMjHNj4pFcoBeO2v4oGe1/0OUoAr9E
         PjRaIgCB7CdZeih9kt7WjcUVQa+8hn0Bt7Bca+nWYdIto7QMDi1O+/bXBhrXEe/rzGSa
         Qk3A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=AhB3TneB;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i98sor4254548plb.48.2019.01.28.20.46.09
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 28 Jan 2019 20:46:09 -0800 (PST)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=AhB3TneB;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=eVdQI+bKFnHxHsyrWVjxAl5UcBq6aUXQPMqjgJnSXMU=;
        b=AhB3TneBFy5a0D3ECmn3nW0DFD00d64H7KXVKa2rW5c8hyVHul1zsyPBj53m+pAEn6
         a3VzM3KcH8t2Btm5Qz/EHVh0SVk4D/dz+4lBGsMUPMlsQY7JrJpIoUhRX3JvrLBTtrUF
         hu+ABju5baJzTV6C6u2plaAYJbka1voJWQK4d1xS/t+oGAV5rgNy1Wtb9AmimQz9rDcn
         NK9GIET8z8CNIMWhVivUtsc+vbDm3xHvUKYhE4pCMl18Fbj0RGgcb2b6wstWaTY5SErZ
         eiwjt4GAeq78cF/eTYNjn5r5B/vr9moiRWvzJT1X3iffiFSmAiFT86VT01lQvrj8sZQe
         VY+Q==
X-Google-Smtp-Source: ALg8bN7+HaiY1XsTWvzakNPi7ADMWJt74gu5PpijmJ/RQm9hMIALtHjokkF1/++wIReWRCu9PvwyWQ==
X-Received: by 2002:a17:902:7c05:: with SMTP id x5mr24101332pll.273.1548737169100;
        Mon, 28 Jan 2019 20:46:09 -0800 (PST)
Received: from ziepe.ca (S010614cc2056d97f.ed.shawcable.net. [174.3.196.123])
        by smtp.gmail.com with ESMTPSA id h128sm66270847pgc.15.2019.01.28.20.46.08
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 28 Jan 2019 20:46:08 -0800 (PST)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1goLHj-00040F-Du; Mon, 28 Jan 2019 21:46:07 -0700
Date: Mon, 28 Jan 2019 21:46:07 -0700
From: Jason Gunthorpe <jgg@ziepe.ca>
To: Davidlohr Bueso <dave@stgolabs.net>
Cc: akpm@linux-foundation.org, dledford@redhat.com, jack@suse.de,
	ira.weiny@intel.com, linux-rdma@vger.kernel.org, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, dennis.dalessandro@intel.com,
	mike.marciniszyn@intel.com, Davidlohr Bueso <dbueso@suse.de>
Subject: Re: [PATCH 3/6] drivers/IB,qib: do not use mmap_sem
Message-ID: <20190129044607.GL25106@ziepe.ca>
References: <20190121174220.10583-1-dave@stgolabs.net>
 <20190121174220.10583-4-dave@stgolabs.net>
 <20190128233140.GA12530@ziepe.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190128233140.GA12530@ziepe.ca>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jan 28, 2019 at 04:31:40PM -0700, Jason Gunthorpe wrote:
> On Mon, Jan 21, 2019 at 09:42:17AM -0800, Davidlohr Bueso wrote:
> > The driver uses mmap_sem for both pinned_vm accounting and
> > get_user_pages(). By using gup_fast() and letting the mm handle
> > the lock if needed, we can no longer rely on the semaphore and
> > simplify the whole thing as the pinning is decoupled from the lock.
> > 
> > This also fixes a bug that __qib_get_user_pages was not taking into
> > account the current value of pinned_vm.
> > 
> > Cc: dennis.dalessandro@intel.com
> > Cc: mike.marciniszyn@intel.com
> > Reviewed-by: Ira Weiny <ira.weiny@intel.com>
> > Signed-off-by: Davidlohr Bueso <dbueso@suse.de>
> >  drivers/infiniband/hw/qib/qib_user_pages.c | 67 ++++++++++--------------------
> >  1 file changed, 22 insertions(+), 45 deletions(-)
> 
> I need you to respin this patch/series against the latest rdma tree:
> 
> git://git.kernel.org/pub/scm/linux/kernel/git/rdma/rdma.git
> 
> branch for-next
> 
> > diff --git a/drivers/infiniband/hw/qib/qib_user_pages.c b/drivers/infiniband/hw/qib/qib_user_pages.c
> > -static int __qib_get_user_pages(unsigned long start_page, size_t num_pages,
> > -				struct page **p)
> > -{
> > -	unsigned long lock_limit;
> > -	size_t got;
> > -	int ret;
> > -
> > -	lock_limit = rlimit(RLIMIT_MEMLOCK) >> PAGE_SHIFT;
> > -
> > -	if (num_pages > lock_limit && !capable(CAP_IPC_LOCK)) {
> > -		ret = -ENOMEM;
> > -		goto bail;
> > -	}
> > -
> > -	for (got = 0; got < num_pages; got += ret) {
> > -		ret = get_user_pages(start_page + got * PAGE_SIZE,
> > -				     num_pages - got,
> > -				     FOLL_WRITE | FOLL_FORCE,
> > -				     p + got, NULL);
> 
> As this has been rightly changed to get_user_pages_longterm, and I
> think the right answer to solve the conflict is to discard some of
> this patch?

.. and I'm looking at some of the other conversions here.. *most
likely* any caller that is manipulating rlimit for get_user_pages
should really be calling get_user_pages_longterm, so they should not
be converted to use _fast?

Jason

