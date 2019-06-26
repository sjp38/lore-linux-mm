Return-Path: <SRS0=C/CR=UZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.0 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A104BC48BD9
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 17:51:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 68886216FD
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 17:51:34 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="ObuCZMnJ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 68886216FD
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0A1DC6B0005; Wed, 26 Jun 2019 13:51:34 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 02C4A8E0003; Wed, 26 Jun 2019 13:51:33 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DE7478E0002; Wed, 26 Jun 2019 13:51:33 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id A81F26B0005
	for <linux-mm@kvack.org>; Wed, 26 Jun 2019 13:51:33 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id c18so2016516pgk.2
        for <linux-mm@kvack.org>; Wed, 26 Jun 2019 10:51:33 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=/vs8Egy5g6Si0QhAWTdGb3iiX4UWuX/9RaMs8MRYrk0=;
        b=IEFHMqskj0GdeUJpQiQZewGkZ1GGdWA0OW5wnwXwRnmISIjXK3sHXQYq45aRjMeGVO
         SkTiBI6oTHl2tt4g4tSBzIe6MNI20pQUeRhJFlq/wZ3/DAMN57UH3bmyPBoF/Omb6L6v
         FUoA9x5OysUbZS6L1FOhlGqe8C9nWvkHr5ZS/lKp48CQbzL5vnWHnVhlxzEgK53AZb5g
         6iPkqLhTuLHSe3A13fU27uLEeT9dMzpMkWlI0LgBisNKKsk54CRhPAPOTtrD1KBKoXjo
         D/aeR4Zb7VP4b3CCfAiwESwALPdb78vbYkU6hEZorepFosOH2Auk63RKYiQI88XOoMl8
         LmUg==
X-Gm-Message-State: APjAAAVmq9ADq5m9121l75r9rUNs6W9ORHG54RXSSj9McVnQu/h1V9Dw
	BjYHBW7TNTJiw1XL62DQu/WjcMj8+X/Mk+w6iLshzYXlByWukxufgNvXnG24zWOgXLM6Xv1OQjl
	Wq8e7F8KhX++dlkVClisSPwbOnemsy/t4Id8TyjD/S9Jn4Xgt0pb29Bp/2MCAyPSe1g==
X-Received: by 2002:a17:90a:9a8d:: with SMTP id e13mr318306pjp.77.1561571493294;
        Wed, 26 Jun 2019 10:51:33 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzVVYZesTF7baRLzi0YbYxosSE2zat8ficMNHjE0lcfpAXsgfFThFHnXSPbv2Vhy8KZt2//
X-Received: by 2002:a17:90a:9a8d:: with SMTP id e13mr318254pjp.77.1561571492718;
        Wed, 26 Jun 2019 10:51:32 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561571492; cv=none;
        d=google.com; s=arc-20160816;
        b=ec0Mq+63Z0JYKHsa58xpShXKZo4L8ww5Y0e7nrfuZQxXkXUgx4ZawNgwEOpQWAvOsc
         fybxQPh3apJJbNvqMRTmuzSsn01Iq8s+s6Eggqfg1ypepEUzw5DWD2h5Mfq6UePMe0dq
         aEouo3Aw89b81sUn6Q7NW+UgeLk99MmpccqfwXcAhNFlSRktg3kS90rW7/zhSeXM2GW+
         EmzZqAx2XLnrmxdKxpe4CBN6hu19uPhIdPkrWxBIBYYr2mbr9TTlxr8GklK32MBCcRO9
         ZEIkdZqDFAJVNSONfETkNFr7SlhISOUJ+BV50k1idai1W+8eKkH13YBvS3ZcerKc8yYd
         sbkw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=/vs8Egy5g6Si0QhAWTdGb3iiX4UWuX/9RaMs8MRYrk0=;
        b=M1IikyIjhnPna6hZqW/zDbhwQthrIx/LF5sbr/I/zDa37ND1St+jZ2FN9R50Ke1dQY
         I/S/mRf1vsI+zjkzxhGJWxcNxadySlHiF1M6ripPebUnXfG3F0pGs3azzjimp50TOGq2
         Z9nUCMmi7hVea393j4TYFplUmz0yZ8pDqpuKE7aq/I8fJWEqn1hDPRGWWEdBhHvl0xEG
         MlW0PQji8dXIf+4UzschF+WVI/IvVWlbWkaau5gzt0slSHfsUz26NeK1/MerpEYChZlt
         WT2L9MaEbGBc4jAgt1Yl6DHExgrAgdBgvtyISvG/YpDL5yw2W9t9/F8N0hqVF+ZPrA4t
         pG1A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=ObuCZMnJ;
       spf=pass (google.com: best guess record for domain of batv+ab1f803c58217d155be4+5785+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+ab1f803c58217d155be4+5785+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id l70si1237720pge.446.2019.06.26.10.51.32
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Wed, 26 Jun 2019 10:51:32 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+ab1f803c58217d155be4+5785+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=ObuCZMnJ;
       spf=pass (google.com: best guess record for domain of batv+ab1f803c58217d155be4+5785+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+ab1f803c58217d155be4+5785+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=/vs8Egy5g6Si0QhAWTdGb3iiX4UWuX/9RaMs8MRYrk0=; b=ObuCZMnJZL8XNKfEkGcnHvqPQ
	0snBZEHMJeZIlgKormOrFx9XKNZKn33QySiOBBapISItR0gi6ysSoc9ZVrAvT5JH0ueHZqZMyuA+y
	izLVmercQAhaMcp4j3x985xKi65IjQaHbwJJMqkkU7xHeSx/4nYn3SbcYtle1VLXXJCgG+2cKeyhv
	YSqVHhTYdnvfShOwnTEnhzxv9QE0MO/ANXi1ljUb8edvZeH4nyR99EXN+gpeUJcDAg/hhxRxKWQhg
	tGB7O37l3u0XPhaTtCwYKe1W3Z2e3ktVUq+DPh5eltEiqNFJ1ofEPqZPq1qHKtMXUva310T8yKBvq
	edAHdacLA==;
Received: from hch by bombadil.infradead.org with local (Exim 4.92 #3 (Red Hat Linux))
	id 1hgC4x-0004yn-Oh; Wed, 26 Jun 2019 17:51:31 +0000
Date: Wed, 26 Jun 2019 10:51:31 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Pankaj Suryawanshi <pankajssuryawanshi@gmail.com>
Cc: linux-mm@kvack.org, Michal Hocko <mhocko@kernel.org>,
	linux-kernel@vger.kernel.org, Vlastimil Babka <vbabka@suse.cz>,
	iommu@lists.linux-foundation.org
Subject: Re: DMA-API attr - DMA_ATTR_NO_KERNEL_MAPPING
Message-ID: <20190626175131.GA17250@infradead.org>
References: <CACDBo564RoWpi8y2pOxoddnn0s3f3sA-fmNxpiXuxebV5TFBJA@mail.gmail.com>
 <CACDBo55GfomD4yAJ1qaOvdm8EQaD-28=etsRHb39goh+5VAeqw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CACDBo55GfomD4yAJ1qaOvdm8EQaD-28=etsRHb39goh+5VAeqw@mail.gmail.com>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jun 26, 2019 at 10:12:45PM +0530, Pankaj Suryawanshi wrote:
> [CC: linux kernel and Vlastimil Babka]

The right list is the list for the DMA mapping subsystem, which is
iommu@lists.linux-foundation.org.  I've also added that.

> > I am writing driver in which I used DMA_ATTR_NO_KERNEL_MAPPING attribute
> > for cma allocation using dma_alloc_attr(), as per kernel docs
> > https://www.kernel.org/doc/Documentation/DMA-attributes.txt  buffers
> > allocated with this attribute can be only passed to user space by calling
> > dma_mmap_attrs().
> >
> > how can I mapped in kernel space (after dma_alloc_attr with
> > DMA_ATTR_NO_KERNEL_MAPPING ) ?

You can't.  And that is the whole point of that API.

