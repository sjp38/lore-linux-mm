Return-Path: <SRS0=SemS=S7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 379C2C46460
	for <linux-mm@archiver.kernel.org>; Mon, 29 Apr 2019 20:10:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DBA9121655
	for <linux-mm@archiver.kernel.org>; Mon, 29 Apr 2019 20:10:10 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="Bjpos/jn"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DBA9121655
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6925A6B0003; Mon, 29 Apr 2019 16:10:10 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6422F6B0005; Mon, 29 Apr 2019 16:10:10 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 530826B0007; Mon, 29 Apr 2019 16:10:10 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1D68B6B0003
	for <linux-mm@kvack.org>; Mon, 29 Apr 2019 16:10:10 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id f64so7857142pfb.11
        for <linux-mm@kvack.org>; Mon, 29 Apr 2019 13:10:10 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=8bbZyLRBS7B6cXqeb9isQNcVt7Ubs7Me5nvL1c8Ic38=;
        b=IT+H9ZuEykTKBA8nWsO8PDISbXvy8pG18sG3v8JnFFKSeL9If8U/pN8xx+VUDZ2zg9
         CpspjPeGkm5V40m58uCw293oa56iUxJc/aKKf60ZF0bUsSTkVhZ9RzhKLekGQF+wGbMG
         qOJsGVP2D2kEkwo7Viet28jQ7/FETEDt70Wtz0svwZqH82dn4yrr0jNWuV/VFE55/k0L
         dmnvlUnDTi2SyAkZZZAFb3TM3t/OYnWojqKfAN8ysHD0XUEdha8lb6pMQ2xXJz8KWv3L
         K0LFUWY86MfXQgkq+fcbHQeLyMLlwqGnzb7U90xO9g23ah5Z2FpRn/YicUbxHRhF3CNJ
         RakQ==
X-Gm-Message-State: APjAAAU9XclGvFPLHjoHwp2FI44FJtjUQgb993a18is5k1Yla9E2tSeg
	ug2VjTLd/BB2bq5/BI0/BneFeCLKSVzdkAoCIG8eIxIpVMmEfAZleqhhZ19+3qpApyvcXtcqg3D
	I2M+ujH4CM5RILZu/rpqHsp87ZLd187yKJNC7enmWxNXW4P6Y5B3XEp0wJsy74Ynz1w==
X-Received: by 2002:a65:4341:: with SMTP id k1mr60051679pgq.88.1556568609724;
        Mon, 29 Apr 2019 13:10:09 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxujYIudW4McLDxDsZ1TVZJ1gfdZf1KpEu4Et7CDe5Vhs+f0k4uDdrA2PJ1ZxUcABH49W2S
X-Received: by 2002:a65:4341:: with SMTP id k1mr60051546pgq.88.1556568608594;
        Mon, 29 Apr 2019 13:10:08 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556568608; cv=none;
        d=google.com; s=arc-20160816;
        b=wEO03EZu99/SjM4c3xg7bv6SOB9DMEaQyVP9jR0WeQUgv3p9eXFoZ6OLy3qfOyVm8M
         heum0+W8xSX3IHwFKKIK9AhKMgy9pbHbXQLlsBpGoYICgdRDveMZQCbVi4cYT8kbvuGx
         IPA039SV+KvDLIUjl4Pu9F2NPzGoU/os0mmGloI17PtDQKFWzfR9DkDMXCe5ENCSGpz7
         1xApUysUfr9Las8twtt0mJLN2qGMmCWJFv5zvJctK/BPOVNzA7FTaR9jTcx9sCwzFVgj
         XTjY4wJj1/EbGSScaT8buxqmdmMDiq8DWAdmT+ObRQC0lgT3GTOM8kMMMMSbQjzsEqQZ
         UQ+Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=8bbZyLRBS7B6cXqeb9isQNcVt7Ubs7Me5nvL1c8Ic38=;
        b=HKFCeFwEWo0ybcN1B+OfvskBqItOqxoAr4ir7imjM7HVJEZTtqRUFHRhRZsRUPmGPf
         Y5SZzdSbKHPjLSdbfxhvRuWVpad1I4x4s/jz8XHLcOacUH5q/I0TozJCpHNeNELtn4F2
         IzipK76KlpvJsmoOB5Y2OHm8aNUedNWf/u7DNj6Ks5mnT9818E9rO5Izs2WPZtLW5uCP
         d00WmJSHpUCttfuvpp2e8pf9nCtdoga/EkSXjMFk9uFKYgQPBqkesjDsJVk5R5RJT/ks
         yMdIlTG4JELhrmu5hPUDqDe9VSz8BwtUxJeLcqApQCeRTzLMdREVRnWfdU2EvoQa8xTg
         6t5A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b="Bjpos/jn";
       spf=pass (google.com: best guess record for domain of batv+3f5cf76c63215fb3955b+5727+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+3f5cf76c63215fb3955b+5727+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id x6si19469967pln.74.2019.04.29.13.10.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 29 Apr 2019 13:10:06 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+3f5cf76c63215fb3955b+5727+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b="Bjpos/jn";
       spf=pass (google.com: best guess record for domain of batv+3f5cf76c63215fb3955b+5727+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+3f5cf76c63215fb3955b+5727+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=8bbZyLRBS7B6cXqeb9isQNcVt7Ubs7Me5nvL1c8Ic38=; b=Bjpos/jnVGsgKNA3/A6QH5Fqv
	3jAKzcTPg0LS0aG86fuHqbtUIILUir1hz6rBxB7r7d76Spl89Z8Gcv+dWrFTZI8otdOJIsCuWdGla
	IsGgipLBTNfUaQmfJpybjgj5KZPwYQMNLsrgt41VqbtxdI1uyxgXqxQP/r9t7HTkpv2YTFFQFtjFj
	c2/0WcjJjGr9y26IbUvGg3xsoMGxctAbpUyTmBJ8sWn5pt9/i7RgwGrSJulwzheWOBCwI233+GC5V
	1ZhCLQYcffZvx8ZmGnTglQNAETu+5+3vvAuU+/8uDKGmOPm7ZReqSqA9LrrZIJhi2Lo2GoGhgj1Ek
	g78xqD4+w==;
Received: from hch by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hLCb7-0007U6-Fw; Mon, 29 Apr 2019 20:09:57 +0000
Date: Mon, 29 Apr 2019 13:09:57 -0700
From: Christoph Hellwig <hch@infradead.org>
To: "Luck, Tony" <tony.luck@intel.com>
Cc: Christoph Hellwig <hch@infradead.org>, Meelis Roos <mroos@linux.ee>,
	Christopher Lameter <cl@linux.com>,
	Mel Gorman <mgorman@techsingularity.net>,
	Andrew Morton <akpm@linux-foundation.org>,
	Mikulas Patocka <mpatocka@redhat.com>,
	James Bottomley <James.Bottomley@hansenpartnership.com>,
	"linux-parisc@vger.kernel.org" <linux-parisc@vger.kernel.org>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	Vlastimil Babka <vbabka@suse.cz>,
	LKML <linux-kernel@vger.kernel.org>,
	"linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>,
	"Yu, Fenghua" <fenghua.yu@intel.com>,
	"linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>
Subject: Re: DISCONTIGMEM is deprecated
Message-ID: <20190429200957.GB27158@infradead.org>
References: <20190419094335.GJ18914@techsingularity.net>
 <20190419140521.GI7751@bombadil.infradead.org>
 <0100016a461809ed-be5bd8fc-9925-424d-9624-4a325a7a8860-000000@email.amazonses.com>
 <25cabb7c-9602-2e09-2fe0-cad3e54595fa@linux.ee>
 <20190428081353.GB30901@infradead.org>
 <3908561D78D1C84285E8C5FCA982C28F7E9140BA@ORSMSX104.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <3908561D78D1C84285E8C5FCA982C28F7E9140BA@ORSMSX104.amr.corp.intel.com>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Apr 29, 2019 at 04:58:09PM +0000, Luck, Tony wrote:
> > ia64 has a such a huge number of memory model choices.  Maybe we
> > need to cut it down to a small set that actually work.
> 
> SGI systems had extremely discontiguous memory (they used some high
> order physical address bits in the tens/hundreds of terabyte range for the
> node number ... so there would be a few GBytes of actual memory then
> a huge gap before the next node had a few more Gbytes).
> 
> I don't know of anyone still booting upstream on an SN2, so if we start doing
> serious hack and slash the chances are high that SN2 will be broken (if it isn't
> already).

When I wrote this, I thought of

!NUMA:  flat mem
NUMA:	sparsemem
SN2:	discontig

based on Meelis report.  But now that you mention it, I bet SN2 has
already died slow death from bitrot.  It is so different in places, and
it doesn't seem like anyone care - if people want room sized SGI
machines the Origin is much more sexy (hello Thomas!) :)

So maybe it it time to mark SN2 broken and see if anyone screams?

Without SN2 the whole machvec mess could basically go away - the
only real difference between the remaining machvecs is which iommu
if any we set up.

