Return-Path: <SRS0=2U+7=VU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BC3F0C76186
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 18:05:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7A9222239E
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 18:05:15 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="YQ/N0Xsa"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7A9222239E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 257338E0009; Tue, 23 Jul 2019 14:05:15 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 22F6F8E0002; Tue, 23 Jul 2019 14:05:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 11EB98E0009; Tue, 23 Jul 2019 14:05:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id CEC948E0002
	for <linux-mm@kvack.org>; Tue, 23 Jul 2019 14:05:14 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id e20so26710393pfd.3
        for <linux-mm@kvack.org>; Tue, 23 Jul 2019 11:05:14 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:message-id:subject:from:to:cc
         :date:in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=2WcZWDsEeaAbXJODUUrweD+LLkNIEwu0OXxXPorIgBc=;
        b=EC+Ee3TX5DyoNkher2+dSMgpMInM8I4Q5cL8X8fT4VSWjK/WIUHbaQ/0IAPsfCitlG
         BsZEJiJHO3hXdDlOrf4Zy4HSh0k4Ih6bdPhkc6zyhXqPM+10ctvJi087GlyQJWo37Qaf
         UJ/d9+Z+yQucQVJvwqr/0EZtbc1NvdMgWYOU1LZ2n1obuYOiDgBf39Tt4qDm1rB8FYeX
         lthjv9aMttI+ApP417/LusW7Uv1R9q2M1GxbAktqoHMhv9XnpPJhzdz5fEGOzyqTtcz7
         rZKUPmfNfkZT3ZDEfyL86VLV0U0tBxPYhttUvgZoJQOUtmEbCLYWBsEuIsev1lAIqxO5
         tqjA==
X-Gm-Message-State: APjAAAUCSpI4zWM92+OwhgfbpVvUX1OC6yID56YiTeEqB8QCYChCRMTA
	oxqOgjIm/siI2baHD2kVqMd67WQolTn4obFAYGADXQROIQ1Gf63cshKbE4g79WXW3Lm9MCHzfoq
	akGmzkGXNCVMaeON3YtkWMv0D1SKzAsf073GluZ+UphFLvQ67M7VFEWd68VVH5vssWQ==
X-Received: by 2002:a17:90b:8d8:: with SMTP id ds24mr7877219pjb.135.1563905114470;
        Tue, 23 Jul 2019 11:05:14 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyUo242ASvhi55oyl3S7cDwJMf06JpAX6ovAT/BiNsxua+OHI+mfIMWO2OhmuYtHY7nguZf
X-Received: by 2002:a17:90b:8d8:: with SMTP id ds24mr7877173pjb.135.1563905113805;
        Tue, 23 Jul 2019 11:05:13 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563905113; cv=none;
        d=google.com; s=arc-20160816;
        b=K7TvCcXFvugpeVoONceeCb/PRtdcYNkhxdq5zTOvL9iPBfbCBNJCPiHlND/arDY3LW
         NMoCEr4k1iFv8aR76eJ3ui6jGrvYNxMb1aF7HvR6HGOwRpm8unwdH7Pk9ziGsYDIKwCP
         g9SM+veG9z4FaqUuUp2GTY+u4O0Nbu0foSRpv6Q6TbileN1+gl6ZE2kCsfscbHr0Rf1Y
         ZsWMPIvAr+mYCrORoehz7sURKb8gdw+lNQePaOOcR0qesT/D7FfYL+atxUmBwcdJLe5H
         ILdgCdrax+RfO4mG01nqRfKx7AU+s4grfcn50n3/EK0F0ZIe7xFIBqc0slRhkR0Ig8/u
         7LKQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:date:cc:to:from:subject:message-id:dkim-signature;
        bh=2WcZWDsEeaAbXJODUUrweD+LLkNIEwu0OXxXPorIgBc=;
        b=j1JmehbcrV9b01M602EF8AQdoJve/Ha9R1wbuMUyj5GfbuHrJeqZ3dJ+5cAc3uGgA5
         Do8OENRe8MLRQLw5GLH5BqcGLILZfhEtR1r/OTGkN/143SxeY1BpPp/wl1/5XSqPDSGX
         9VxjhE+qy04R01wuwgS44MDRsAf/GDCvaizIE3i1hMKaaC5BN788vU5HTpqBlGftelIM
         Tlix99i2BYvO5L25Mt40H8LdVIdlkKk2yyN6Ceci97KCs5HGpcrWiaApZ7xVF6BBa6wj
         Yq0dNj1OT+Yqv11bea8P0Mo1F3rM/AWc/tsyoL3m8BbwV9/LQYVwt3p8WQNFwnkgZyoo
         dsgQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b="YQ/N0Xsa";
       spf=pass (google.com: domain of jlayton@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=jlayton@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id d22si11264900plr.120.2019.07.23.11.05.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Jul 2019 11:05:13 -0700 (PDT)
Received-SPF: pass (google.com: domain of jlayton@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b="YQ/N0Xsa";
       spf=pass (google.com: domain of jlayton@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=jlayton@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from tleilax.poochiereds.net (cpe-71-70-156-158.nc.res.rr.com [71.70.156.158])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 8D21821926;
	Tue, 23 Jul 2019 18:05:12 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1563905113;
	bh=rAlMUYDiLSqWc5h78CMWYXPZl9tMbGMy0McuERVfjeM=;
	h=Subject:From:To:Cc:Date:In-Reply-To:References:From;
	b=YQ/N0Xsar7YCkc6u4JNaNtp4JIHg+jQXNIQIJCS7xOhoo207XnXIzqsVtVuxY7wLF
	 9E2skJ1Vz2dpuFqSqtBoD0CQdgr5fKlGVFBsGVQ4rvgUs8aCpXTxC1LuCQDMvzmbEl
	 QNhSlpOtHcSJAQlqy6VWJcmic4GO09KGFW22MRcY=
Message-ID: <f43c131d9b635994aafed15cb72308b32d2eef67.camel@kernel.org>
Subject: Re: [PATCH] mm: check for sleepable context in kvfree
From: Jeff Layton <jlayton@kernel.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org,  viro@zeniv.linux.org.uk,
 lhenriques@suse.com, cmaiolino@redhat.com, Christoph Hellwig <hch@lst.de>
Date: Tue, 23 Jul 2019 14:05:11 -0400
In-Reply-To: <20190723175543.GL363@bombadil.infradead.org>
References: <20190723131212.445-1-jlayton@kernel.org>
	 <3622a5fe9f13ddfd15b262dbeda700a26c395c2a.camel@kernel.org>
	 <20190723175543.GL363@bombadil.infradead.org>
Content-Type: text/plain; charset="UTF-8"
User-Agent: Evolution 3.32.4 (3.32.4-1.fc30) 
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 2019-07-23 at 10:55 -0700, Matthew Wilcox wrote:
> On Tue, Jul 23, 2019 at 01:52:36PM -0400, Jeff Layton wrote:
> > On Tue, 2019-07-23 at 09:12 -0400, Jeff Layton wrote:
> > > A lot of callers of kvfree only go down the vfree path under very rare
> > > circumstances, and so may never end up hitting the might_sleep_if in it.
> > > Ensure that when kvfree is called, that it is operating in a context
> > > where it is allowed to sleep.
> > > 
> > > Cc: Alexander Viro <viro@zeniv.linux.org.uk>
> > > Cc: Luis Henriques <lhenriques@suse.com>
> > > Signed-off-by: Jeff Layton <jlayton@kernel.org>
> > > ---
> > >  mm/util.c | 2 ++
> > >  1 file changed, 2 insertions(+)
> > > 
> > 
> > FWIW, I started looking at this after Luis sent me some ceph patches
> > that fixed a few of these problems. I have not done extensive testing
> > with this patch, so maybe consider this an RFC for now.
> > 
> > HCH points out that xfs uses kvfree as a generic "free this no matter
> > what it is" sort of wrapper and expects the callers to work out whether
> > they might be freeing a vmalloc'ed address. If that sort of usage turns
> > out to be prevalent, then we may need another approach to clean this up.
> 
> I think it's a bit of a landmine, to be honest.  How about we have kvfree()
> call vfree_atomic() instead?

Not a bad idea, though it means more overhead for the vfree case.

Since we're spitballing here...could we have kvfree figure out whether
it's running in a context where it would need to queue it instead and
only do it in that case?

We currently have to figure that out for the might_sleep_if anyway. We
could just have it DTRT instead of printk'ing and dumping the stack in
that case.
-- 
Jeff Layton <jlayton@kernel.org>

