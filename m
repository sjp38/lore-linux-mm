Return-Path: <SRS0=HICI=RB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 45E0FC43381
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 14:04:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D868E217F5
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 14:04:47 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="UtqpNt4A"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D868E217F5
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3DE6A8E0003; Tue, 26 Feb 2019 09:04:47 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3B51F8E0001; Tue, 26 Feb 2019 09:04:47 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2CC378E0003; Tue, 26 Feb 2019 09:04:47 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id E0D748E0001
	for <linux-mm@kvack.org>; Tue, 26 Feb 2019 09:04:46 -0500 (EST)
Received: by mail-pf1-f200.google.com with SMTP id o67so10524342pfa.20
        for <linux-mm@kvack.org>; Tue, 26 Feb 2019 06:04:46 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=FTKp8mQxcps8RZ7UOhvwpjyGKEofEGAsn6bznwSBBmM=;
        b=QDF9n/BUkEfssaNAXBjVAtkBFJJpdhGnhVuJueX/1vsut8MV1D533hFgKpRgt6VnOb
         cCElTy31MSyJeKarpccBTo4NfBiwC0VEEdaPoKwySXdHGPueiS8UOB6VOYw/BNoTOuE/
         zuW3F6jLif0uo4hu8MMS6kfdtkwPQb++J8QGqOnwrb3xHKE4JdWo7xyjsUK4EolRvguB
         A9dqnhVDh/4z7zI27IEWIm0fWWRMZQcv+3vMOG/dcsVCr6eiiVbyZgmyvTg/yK0vGBjF
         1Lq0s/gs2MmIRrdMAl+rwfoOqyEog16g6imo7kwf9oloJRsIY7Ky2SsoxRhTM2Ivde56
         boOA==
X-Gm-Message-State: AHQUAuYfnJGNjkmOYhyxu5cCP3T+mqFYoraipDUBG28KuejAKZJscF3r
	gSdrHkRzOKLeXRs6IrJ1H61aXVJwpODQfT5097bNh90jtWfaarDHxbzC3x1AH+jhpWfqXSqv5e2
	rooNcqexjOjkninfrNB3w/GPoSEHMonvhqN/quh7Mf0GnoQJTkZNqTvFJSmywIdo6Gw==
X-Received: by 2002:a17:902:7688:: with SMTP id m8mr24896946pll.248.1551189886520;
        Tue, 26 Feb 2019 06:04:46 -0800 (PST)
X-Google-Smtp-Source: AHgI3Ia5mSVZEygzlZxAd2KamA3/pAlAtigyXjncaxlQoXJkNM0nmkalP9E8voZTgBePwXXHjgAS
X-Received: by 2002:a17:902:7688:: with SMTP id m8mr24896829pll.248.1551189885167;
        Tue, 26 Feb 2019 06:04:45 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551189885; cv=none;
        d=google.com; s=arc-20160816;
        b=dO4nsnhWcNs1VU+SFBaW6SyGfkEli1I1eUw12RaJM4cQaHtuBnRyVAVnXH9XGCy2Sn
         L6A4uJ5S/KZ1jwTgXHnBV6m8Y5Eq7gPVWjqHYrmaVvlIXxStTQ+XPCpC2f3H8iIW8ZFN
         giVAwaQBOxDs/yBTx4NUMz8VnGNcKGKKXJ5OiHl1DPy3hmte24f2ax380JPZfZbb3aEP
         JAjPTLcG9jHS3QybNzYH2p7N4ZbhPb/sHkpg1OCqCtxWrajtw4szWLDvA39ZkA4eBz+l
         tkoamJWumqmLjvm0ifGWK7+CpTiRErRUbQ6UDug6QrCb0StnHvrxiFDapLmXxfzttPRc
         J1vg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=FTKp8mQxcps8RZ7UOhvwpjyGKEofEGAsn6bznwSBBmM=;
        b=PrEWf5n1su/JbeNLgXtgOt70L+QZA56DDwi+hHvMoJ7ZkEKJsHs6NPXsJ2tOWhyFXv
         9zLzaYWD6X5xQssCKG9zHMpwlbLxY4lwIfdS2MEkEePij8pYd+zswK/bYCjWhdYctsfo
         wERuw5+oL9S+tZOATf+IEvCeSswN7JYVCjPVC2wx+8aPWDzrPP4kiGxuF4tCcuh+qFhz
         SAOnGfqT4Q59dD3hNUwLTbHmDFT++FEwlRdrDeRn82Ptye1t0QqDv/B6vUw6e4Nf2J2q
         mnmmDjKpYWmtPFA8k8tiC4YVjt7O4EvZw2Gv/X++DfiE+dHVvIq8YN+64I1hIt6m7IUA
         P5bg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=UtqpNt4A;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 198.137.202.133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [198.137.202.133])
        by mx.google.com with ESMTPS id 14si9032956ple.405.2019.02.26.06.04.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 26 Feb 2019 06:04:45 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 198.137.202.133 as permitted sender) client-ip=198.137.202.133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=UtqpNt4A;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 198.137.202.133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=FTKp8mQxcps8RZ7UOhvwpjyGKEofEGAsn6bznwSBBmM=; b=UtqpNt4AvDE3O8Z6UPaYE5K5u
	kqvFQeo/6Krb28+aAtR0hCftwfnappsTJkN6EFrZZ2F89QcWqvNX9wWYTQF/RnYa9WJkUE1z5md7o
	cEZHoMOBZB/hUD21jDomuvEMXmLuCmRwmxsaWxO38TuxTreN6tGa/ry7ta6YbScEo7ZXroKpOiOKu
	53xQTaN3Q2mNsK6P0qzNXurrfU/PhENlHCVDy5ASAkDdG+27egMwCSbEqqEFqx4BnlWhxFHyxaUTp
	5E08MepKwzTkI5VbacrPTlnn27nWxB6IXBnQ4sJBgec7m/bhLezhoRxE/nxvEwpQLH5hbAG35/6SQ
	CGyfvPthg==;
Received: from willy by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1gydLc-0003S3-Hw; Tue, 26 Feb 2019 14:04:40 +0000
Date: Tue, 26 Feb 2019 06:04:40 -0800
From: Matthew Wilcox <willy@infradead.org>
To: Ming Lei <ming.lei@redhat.com>
Cc: Ming Lei <tom.leiming@gmail.com>, Vlastimil Babka <vbabka@suse.cz>,
	Dave Chinner <david@fromorbit.com>,
	"Darrick J . Wong" <darrick.wong@oracle.com>,
	"open list:XFS FILESYSTEM" <linux-xfs@vger.kernel.org>,
	Jens Axboe <axboe@kernel.dk>,
	Vitaly Kuznetsov <vkuznets@redhat.com>,
	Dave Chinner <dchinner@redhat.com>, Christoph Hellwig <hch@lst.de>,
	Alexander Duyck <alexander.h.duyck@linux.intel.com>,
	Aaron Lu <aaron.lu@intel.com>, Christopher Lameter <cl@linux.com>,
	Linux FS Devel <linux-fsdevel@vger.kernel.org>,
	linux-mm <linux-mm@kvack.org>,
	linux-block <linux-block@vger.kernel.org>,
	Pekka Enberg <penberg@kernel.org>,
	David Rientjes <rientjes@google.com>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH] xfs: allocate sector sized IO buffer via page_frag_alloc
Message-ID: <20190226140440.GF11592@bombadil.infradead.org>
References: <20190226030214.GI23020@dastard>
 <20190226032737.GA11592@bombadil.infradead.org>
 <20190226045826.GJ23020@dastard>
 <20190226093302.GA24879@ming.t460p>
 <a641feb8-ceb2-2dac-27aa-7b1df10f5ae5@suse.cz>
 <CACVXFVMX=WpTRBbDTSibfXkTZxckk3ootetbE+rkJtHhsZkRAw@mail.gmail.com>
 <20190226121209.GC11592@bombadil.infradead.org>
 <20190226123545.GA6163@ming.t460p>
 <20190226130230.GD11592@bombadil.infradead.org>
 <20190226134247.GA30942@ming.t460p>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190226134247.GA30942@ming.t460p>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Feb 26, 2019 at 09:42:48PM +0800, Ming Lei wrote:
> On Tue, Feb 26, 2019 at 05:02:30AM -0800, Matthew Wilcox wrote:
> > Wait, we're imposing a ridiculous amount of complexity on XFS for no
> > reason at all?  We should just change this to 512-byte alignment.  Tying
> > it to the blocksize of the device never made any sense.
> 
> OK, that is fine since we can fallback to buffered IO for loop in case of
> unaligned dio.
> 
> Then something like the following patch should work for all fs, could
> anyone comment on this approach?

That's not even close to what I meant.

diff --git a/fs/direct-io.c b/fs/direct-io.c
index ec2fb6fe6d37..dee1fc47a7fc 100644
--- a/fs/direct-io.c
+++ b/fs/direct-io.c
@@ -1185,18 +1185,20 @@ do_blockdev_direct_IO(struct kiocb *iocb, struct inode *inode,
 	struct dio_submit sdio = { 0, };
 	struct buffer_head map_bh = { 0, };
 	struct blk_plug plug;
-	unsigned long align = offset | iov_iter_alignment(iter);
 
 	/*
 	 * Avoid references to bdev if not absolutely needed to give
 	 * the early prefetch in the caller enough time.
 	 */
 
-	if (align & blocksize_mask) {
+	if (iov_iter_alignment(iter) & 511)
+		goto out;
+
+	if (offset & blocksize_mask) {
 		if (bdev)
 			blkbits = blksize_bits(bdev_logical_block_size(bdev));
 		blocksize_mask = (1 << blkbits) - 1;
-		if (align & blocksize_mask)
+		if (offset & blocksize_mask)
 			goto out;
 	}
 

