Return-Path: <SRS0=cZWw=UO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.0 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 49DE2C31E50
	for <linux-mm@archiver.kernel.org>; Sat, 15 Jun 2019 13:59:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EB55321473
	for <linux-mm@archiver.kernel.org>; Sat, 15 Jun 2019 13:59:11 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="SghgOUqO"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EB55321473
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7E3EF6B0006; Sat, 15 Jun 2019 09:59:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 794DA8E0002; Sat, 15 Jun 2019 09:59:11 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 65D638E0001; Sat, 15 Jun 2019 09:59:11 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 2E5C06B0006
	for <linux-mm@kvack.org>; Sat, 15 Jun 2019 09:59:11 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id 21so4010592pgl.5
        for <linux-mm@kvack.org>; Sat, 15 Jun 2019 06:59:11 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=uw+8Gsob+xo/SGAw3aMo5AOaLhno7qEOpvZ++8fuMSg=;
        b=J8nKPdRZBpC0vnRnmp19PzV9XLpA/CNMKwwsWsy72WpRDI1JSFTUEE76qFvbdBuaCo
         wm/Gdq1eMJEXj6VNsIwuZIoHGPWilZYbywFBFBTCbBlgRm7mhQUFOe5lIR+VZqNUpfTz
         5qJyon7vsVfAkKM4Koj9nbROd2sSDY62ZczOM6tVM3tk1XxWMI/4JtOzw+Yzk1WiaHLc
         WoNSt1jVWMqV3xvM87RBvifBjbMf+u64DcefccuEstS4hxwEU5AUfdYcYIlcbygl/wqO
         po/8B9UmK5QtNAY4llxXCvCrLW5kx1AHit2F4PkSvEEt2QdIJ1JE2iLMQfBeP9cJ3r1A
         bXEA==
X-Gm-Message-State: APjAAAX1HvgtEupqTZq/bXmub62szNj6juk+Z26vC633TyKQOhR0ONVW
	152t0mofzgivGSO0B0Q51zmvdN5xsdeqriQjJk7X73MyVtph97Il5/M+4l6p5w+TPAidojm6BOn
	+VYtYnA6yYcSdTrbS7heJHQWucNPLWsQ6PGCyc/qhrr3HDsH8xiap01K8yz+X0jAuVA==
X-Received: by 2002:a17:90a:8a15:: with SMTP id w21mr16544788pjn.134.1560607150804;
        Sat, 15 Jun 2019 06:59:10 -0700 (PDT)
X-Google-Smtp-Source: APXvYqycLl2YEhUSquTMzgUn2/ok4lclLh9ANfZ11aF9zxZlOe7sRZy1ixFoY/m6qhbP+8f1pRaz
X-Received: by 2002:a17:90a:8a15:: with SMTP id w21mr16544752pjn.134.1560607150110;
        Sat, 15 Jun 2019 06:59:10 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560607150; cv=none;
        d=google.com; s=arc-20160816;
        b=X3F5Cu0YdEcoJlf+lw9RH8aZqsocTS+sPnCimsSYxDnTe+WbFzWcvtcWtSBhowto/4
         oAz7Lkjf1qpr3+vrcrRNoKN3Ioizq4RpSGAwrhfAltAegBdhZP4w2f36meOXCjeDaRnA
         +4WMwGHYR+HQPjqrgafsV5R5ES608CNiQoxO8wBp59Qgu2pwUB4Y6G/76/NoKnLhrBw5
         2lQfYJuId66pbdtbsfmmFfhiOPaEPIdih027AwHnj6bwFFPsQHO+SVgLKRZfReKp9QcF
         /w11XEyusyx+LtyFjmrAgh1NElIgInhecrvHgHXFLYUsZpn7fDTfBacT2PcqEQDKzCx5
         ze9g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=uw+8Gsob+xo/SGAw3aMo5AOaLhno7qEOpvZ++8fuMSg=;
        b=V5bHFilvBX0cMaBJ+1bH5R856P0YiCRURpSXTxv/LZBvjlK/lRJF7xReLPoEFUNBWF
         5pYE1097zH9ZvjLtAA8LVW0k91MDJ/uzUuhMzw6K2eUSnR10v3XHif/4Iq94EcB9msW3
         zGJyI1INAtv2urerotAXwN/7sdy0qEo5PSBs2semliU7n8yNMfVz2MPqSpSLwZipIN9Z
         HtejS8AC0jHj+tra4wttigtATA2s8iWz3EeygdP/qH+wpFHtKjnjOlymg0oNFcI5/AVx
         bA3TFLpyIOo+lXm8IRGz3x0uZpUndywl9j8D/6Wk8ivFp7C+bBPQbPpibszPh3gPZ6m1
         bMPQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=SghgOUqO;
       spf=pass (google.com: best guess record for domain of batv+78a6abdb7ec5759febfc+5774+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+78a6abdb7ec5759febfc+5774+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id r23si5682130pgk.126.2019.06.15.06.59.09
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Sat, 15 Jun 2019 06:59:09 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+78a6abdb7ec5759febfc+5774+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=SghgOUqO;
       spf=pass (google.com: best guess record for domain of batv+78a6abdb7ec5759febfc+5774+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+78a6abdb7ec5759febfc+5774+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=uw+8Gsob+xo/SGAw3aMo5AOaLhno7qEOpvZ++8fuMSg=; b=SghgOUqONoSRbIHgI8mPRhVMT
	twgH3naz+biFngZQOZd3Gfiqe8dVH42nugcD5e0Tep/6FkDlqVGXX8DlYOQhyRRP6O7klcnieXo6i
	jjlWR3luZbcxwFtG0w3KW2LSIGImE5ebS3p7jjD9mPgIU2cJ/x+/iiSAFR3Fg82dE+1fzRwqKEH/h
	Qdaga43CwL64GRoC9uL+zhZeMgz+tE9LTXAFyT71viusNdb66qP93qtAQnYFYqKjCTVSTAa2XiEkP
	ZZPRbeKA7C1RqLqGOWq8mHy5rS6D0nKeKB/hd12WNrXe6DiUV4EaD/0y/ZC6hyyT0vzri7JJQ6WkG
	r0yItbY3w==;
Received: from hch by bombadil.infradead.org with local (Exim 4.92 #3 (Red Hat Linux))
	id 1hc9D0-00057j-88; Sat, 15 Jun 2019 13:59:06 +0000
Date: Sat, 15 Jun 2019 06:59:06 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Jason Gunthorpe <jgg@ziepe.ca>
Cc: Jerome Glisse <jglisse@redhat.com>,
	Ralph Campbell <rcampbell@nvidia.com>,
	John Hubbard <jhubbard@nvidia.com>, Felix.Kuehling@amd.com,
	linux-rdma@vger.kernel.org, linux-mm@kvack.org,
	Andrea Arcangeli <aarcange@redhat.com>,
	dri-devel@lists.freedesktop.org, amd-gfx@lists.freedesktop.org,
	Ben Skeggs <bskeggs@redhat.com>, Jason Gunthorpe <jgg@mellanox.com>,
	Ira Weiny <ira.weiny@intel.com>, Philip Yang <Philip.Yang@amd.com>
Subject: Re: [PATCH v3 hmm 02/12] mm/hmm: Use hmm_mirror not mm as an
 argument for hmm_range_register
Message-ID: <20190615135906.GB17724@infradead.org>
References: <20190614004450.20252-1-jgg@ziepe.ca>
 <20190614004450.20252-3-jgg@ziepe.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190614004450.20252-3-jgg@ziepe.ca>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jun 13, 2019 at 09:44:40PM -0300, Jason Gunthorpe wrote:
> From: Jason Gunthorpe <jgg@mellanox.com>
> 
> Ralph observes that hmm_range_register() can only be called by a driver
> while a mirror is registered. Make this clear in the API by passing in the
> mirror structure as a parameter.
> 
> This also simplifies understanding the lifetime model for struct hmm, as
> the hmm pointer must be valid as part of a registered mirror so all we
> need in hmm_register_range() is a simple kref_get.

Looks good, at least an an intermediate step:

Reviewed-by: Christoph Hellwig <hch@lst.de>

> index f6956d78e3cb25..22a97ada108b4e 100644
> --- a/mm/hmm.c
> +++ b/mm/hmm.c
> @@ -914,13 +914,13 @@ static void hmm_pfns_clear(struct hmm_range *range,
>   * Track updates to the CPU page table see include/linux/hmm.h
>   */
>  int hmm_range_register(struct hmm_range *range,
> -		       struct mm_struct *mm,
> +		       struct hmm_mirror *mirror,
>  		       unsigned long start,
>  		       unsigned long end,
>  		       unsigned page_shift)
>  {
>  	unsigned long mask = ((1UL << page_shift) - 1UL);
> -	struct hmm *hmm;
> +	struct hmm *hmm = mirror->hmm;
>  
>  	range->valid = false;
>  	range->hmm = NULL;
> @@ -934,20 +934,15 @@ int hmm_range_register(struct hmm_range *range,
>  	range->start = start;
>  	range->end = end;

But while you're at it:  the calling conventions of hmm_range_register
are still rather odd, as the staet, end and page_shift arguments are
only used to fill out fields in the range structure passed in.  Might
be worth cleaning up as well if we change the calling convention.

