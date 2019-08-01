Return-Path: <SRS0=cJsh=V5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.1 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3FC97C19759
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 17:45:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id ED5E32173E
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 17:45:03 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="jt4hKtVO"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org ED5E32173E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 74F998E0006; Thu,  1 Aug 2019 13:45:03 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6FF698E0001; Thu,  1 Aug 2019 13:45:03 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5C6BE8E0006; Thu,  1 Aug 2019 13:45:03 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 1BAC68E0001
	for <linux-mm@kvack.org>; Thu,  1 Aug 2019 13:45:03 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id 6so46228313pfz.10
        for <linux-mm@kvack.org>; Thu, 01 Aug 2019 10:45:03 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=tMgjBYsrubSb9pgotqA8mXtCx85t7Qpa3qg3Loua/zQ=;
        b=umqT1AV9SzbkmvtSLPSlCuFO/klrTydSXprK1KOBubPxzmtwdqsah61k7CpadHb4+P
         /Bxz7iBHEkcc8HemRFADcCPaEixb7UvcDiwZ3w1rHFMA9OIf1U+gny0dhT9VD8XviffN
         TVqrXvwYOwZoeLxgeoIvo21Zz5bPvZcYxbmAUfdUFOfyUQAhRk/B9vAtI2D9V+6YW5Dz
         Ynsp2Ozj0m/ZfXQC4FFgMLn0OHiJV56BggCU1i74hz6nRh7NQgWhHLUEyJQqvLzjUS2B
         4hLyDfV8jT2HsGgFyuEC9sLC1ANnRkSJB41F5s9bbUsZBrBtSw96gGkCyT7FFId3H9i6
         Z0iQ==
X-Gm-Message-State: APjAAAVaQQQJNo53XxGIErWLctUSCNhkNzgPiz3XhWewybnJRJ5m+/kL
	iN9fGtw5U5yPLTdC+yW7tXGcgKK+5D3LIP7kv6cyqxdnGkAcHobuAcsni01Nm3Z6lzCbMZcUyuV
	FD+90ntcZJ/BxDVaM8HhDgxO+yHQkd0xwUchicQ9wRwMUZuOy7zSLQB1yAkV3L1ju1A==
X-Received: by 2002:a62:e403:: with SMTP id r3mr52531029pfh.37.1564681502661;
        Thu, 01 Aug 2019 10:45:02 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwqaEetI/q+llLGfrkM+3lssJN1aELEmOJyOXHVhEb/TT9nyqL93A931VquaCrEaj1kAJ7i
X-Received: by 2002:a62:e403:: with SMTP id r3mr52530966pfh.37.1564681501845;
        Thu, 01 Aug 2019 10:45:01 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564681501; cv=none;
        d=google.com; s=arc-20160816;
        b=NbwJgorn2OYg6sXJs7YehVLoTPjhdHBU/iOINKKk4XmRksqwt8PETyFKKhocXYx+jS
         cypUF6WSX8oN1OKrUPNpG48tC77n2nq0V1V02G+kGD2FGlo/vAClWBSlnB5H123GAuin
         k1MD1MuHSU2dp/DXLsQVTYIFiBI2VIsupT1Jm+d8w4Qoyie+76DKvjXgRkD9Pv/kh8Gt
         dw3qe8V0XzSZmZqMFdp1mqKBhA3QzqePLdW7VyYI56XPmUh0Co+dYYT2/h/0H7HG7OG0
         uTa4a8BMXCFh1yTa+Alq3jBu0/9gNbxwc7SlNHQPDVyF8VAYdrMRDbXkScF1bMBZ4Jel
         uK2w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=tMgjBYsrubSb9pgotqA8mXtCx85t7Qpa3qg3Loua/zQ=;
        b=ZUYQJzMw1NQV2Z1TzboKHJ2jfPyzfRFV9hbzuIj4SdL/71rHU3rKBDzP2a4yJLDkDP
         FTzmXxkzYlak4uHvpRXixba4WIs2rbVFLlAcduc8q92oALtZP5nYyveYt6G0R5S8VRJ7
         Du/sVNEQIjvgOb054iIOU2iQ+6ViYbx+fDRPFQqLCSSyBQAjgQulvJ5pO9JWVZmTJfri
         +8cqBn2c6tonmAVVag59ng3Tc6BmRIB27qvwadzUvr9sNSVOQtgvXJ8C9syg0JFB/HqM
         wewVs5BPuU1eT+6VSenTYSNoZePuphYiL+q5ehEHEEsXQkuKI71+oXannaT/NwGlRebt
         kSGw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=jt4hKtVO;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id h15si34243423plk.74.2019.08.01.10.45.01
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Thu, 01 Aug 2019 10:45:01 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=jt4hKtVO;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=tMgjBYsrubSb9pgotqA8mXtCx85t7Qpa3qg3Loua/zQ=; b=jt4hKtVOP0JruDnFEiVIbs+R4
	5Jr/p4/PDSk4xZQOJOmNoL5pmHs9yrvrN7admwjQqoOTEkO9GxfqdWGhid7xBBqLvmHVwONWt5LTF
	T+KWHP8aKH6aPKQ+DjlcDihPn6agAZQfktblmSjb4cvENxHNRIaDvqj2JRbADO6WhLOM34thWRQAJ
	xxl8y/8U3IaAvdOjWAtlQ+FC7khQvj1UjaN8MY08Xzb3YojKgOEb3gfPVGROyM3tPOPbA0XDNy7Lt
	qXSoPKF4ih9PVP4zcqLaYDCgD7NnbrSn9D5gNfpeRUDk89WlYQzgrrdeNF5/tSERP892V3Lyo7Hsp
	Me8zIzZew==;
Received: from willy by bombadil.infradead.org with local (Exim 4.92 #3 (Red Hat Linux))
	id 1htF8O-0004C9-4L; Thu, 01 Aug 2019 17:45:00 +0000
Date: Thu, 1 Aug 2019 10:45:00 -0700
From: Matthew Wilcox <willy@infradead.org>
To: Christoph Hellwig <hch@lst.de>
Cc: Dave Chinner <david@fromorbit.com>, linux-fsdevel@vger.kernel.org,
	linux-xfs@vger.kernel.org, linux-mm@kvack.org
Subject: Re: [PATCH 1/2] iomap: Support large pages
Message-ID: <20190801174500.GL4700@bombadil.infradead.org>
References: <20190731171734.21601-1-willy@infradead.org>
 <20190731171734.21601-2-willy@infradead.org>
 <20190731230315.GJ7777@dread.disaster.area>
 <20190801035955.GI4700@bombadil.infradead.org>
 <20190801162147.GB25871@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190801162147.GB25871@lst.de>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Aug 01, 2019 at 06:21:47PM +0200, Christoph Hellwig wrote:
> On Wed, Jul 31, 2019 at 08:59:55PM -0700, Matthew Wilcox wrote:
> > -       nbits = BITS_TO_LONGS(page_size(page) / SECTOR_SIZE);
> > -       iop = kmalloc(struct_size(iop, uptodate, nbits),
> > -                       GFP_NOFS | __GFP_NOFAIL);
> > -       atomic_set(&iop->read_count, 0);
> > -       atomic_set(&iop->write_count, 0);
> > -       bitmap_zero(iop->uptodate, nbits);
> > +       n = BITS_TO_LONGS(page_size(page) >> inode->i_blkbits);
> > +       iop = kmalloc(struct_size(iop, uptodate, n),
> > +                       GFP_NOFS | __GFP_NOFAIL | __GFP_ZERO);
> 
> I am really worried about potential very large GFP_NOFS | __GFP_NOFAIL
> allocations here.

I don't think it gets _very_ large here.  Assuming a 4kB block size
filesystem, that's 512 bits (64 bytes, plus 16 bytes for the two counters)
for a 2MB page.  For machines with an 8MB PMD page, it's 272 bytes.
Not a very nice fraction of a page size, so probably rounded up to a 512
byte allocation, but well under the one page that the MM is supposed to
guarantee being able to allocate.

> And thinking about this a bit more while walking
> at the beach I wonder if a better option is to just allocate one
> iomap per tail page if needed rather than blowing the head page one
> up.  We'd still always use the read_count and write_count in the
> head page, but the bitmaps in the tail pages, which should be pretty
> easily doable.

We wouldn't need to allocate an iomap per tail page, even.  We could
just use one bit of tail-page->private per block.  That'd work except
for 512-byte block size on machines with a 64kB page.  I doubt many
people expect that combination to work well.

One of my longer-term ambitions is to do away with tail pages under
certain situations; eg partition the memory between allocatable-as-4kB
pages and allocatable-as-2MB pages.  We'd need a different solution for
that, but it's a bit of a pipe dream right now anyway.

> Note that we'll also need to do another optimization first that I
> skipped in the initial iomap writeback path work:  We only really need
> an iomap if the blocksize is smaller than the page and there actually
> is an extent boundary inside that page.  If a (small or huge) page is
> backed by a single extent we can skip the whole iomap thing.  That is at
> least for now, because I have a series adding optional t10 protection
> information tuples (8 bytes per 512 bytes of data) to the end of
> the iomap, which would grow it quite a bit for the PI case, and would
> make also allocating the updatodate bit dynamically uglies (but not
> impossible).
> 
> Note that we'll also need to remove the line that limits the iomap
> allocation size in iomap_begin to 1024 times the page size to a better
> chance at contiguous allocations for huge page faults and generally
> avoid pointless roundtrips to the allocator.  It might or might be
> time to revisit that limit in general, not just for huge pages.

I think that's beyond my current understanding of the iomap code ;-)

