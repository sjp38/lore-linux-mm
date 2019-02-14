Return-Path: <SRS0=uhAD=QV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C4EF4C43381
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 07:47:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8BDF9222A4
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 07:47:50 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8BDF9222A4
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 25C088E0002; Thu, 14 Feb 2019 02:47:50 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 20C688E0001; Thu, 14 Feb 2019 02:47:50 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0FC538E0002; Thu, 14 Feb 2019 02:47:50 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id AB60C8E0001
	for <linux-mm@kvack.org>; Thu, 14 Feb 2019 02:47:49 -0500 (EST)
Received: by mail-wr1-f69.google.com with SMTP id m7so1900484wrn.15
        for <linux-mm@kvack.org>; Wed, 13 Feb 2019 23:47:49 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=MGN17bp0RQuYnKSNxfOT6ZJhm+M2guEfTeFqbReYHXs=;
        b=tfrdNwvosvxepH1T+eqROomosM9aVJGwmN5WBrpNPpvKIkBOiaq62EEvnxGY70wmTN
         BbhsEvTNwYOkwHvyjoVIWS4p69/CnuuPeBr3wEXy3JbVP392EgPOJq4i2D7PgdYMdB63
         H4P90ImXEdpAMLZvcRA7OsU/PjyrfzT4WF021GyZzli2A3biC575wIbqGersm4OA9oyp
         /gvUAMGQw4ega1GZZ1ZGevRZGC58VsfTymwSt/uRRTTIkf3rXEUTeMf7+wvCrCj9bMIx
         c4Bbf9WleFEAucNoHMJVEMRAJwYogXbxTYp7gZ3XUFhStRAELrixJAvUTbozBM18eiEj
         tDxw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
X-Gm-Message-State: AHQUAuYw8+qLNBA/h4Q21dt2f0F7WVQxB4f4+rBzr8UMGyS5o1cOGfiY
	2GwDPM/+Khbo0egQoK6uYsVMOWofPEne18CL5iH5cEm+9N68SpgZqAdBYS+r8fmK2YMRBcb3G6a
	H5F1urWX5t8fEsB6GsheOIq4xYefuLsK7RioHp/QK2n4NUVcdq4BJy+CKRGAQi3bF1g==
X-Received: by 2002:a7b:c777:: with SMTP id x23mr1604172wmk.71.1550130469255;
        Wed, 13 Feb 2019 23:47:49 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbWgUd0pmdFZLx7s+MI/WNmsuJaqmVynxUgAHoLIGTso/+EXUVykESIhqRxN4ntCBdcc/8x
X-Received: by 2002:a7b:c777:: with SMTP id x23mr1604137wmk.71.1550130468456;
        Wed, 13 Feb 2019 23:47:48 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550130468; cv=none;
        d=google.com; s=arc-20160816;
        b=t3j1uvOEwZwGXQiAsyxFJvDQcS2kw9HpOAvqVpv0RvqC3p4xlPjZhbOBehntK0mB8x
         Ass9SU3kW62NfdalOocbEZlacn1SgebTAInrgGs403lumf63eTD2aZfUVGYlfOwPSpiF
         wIsHQiw2jGdiCf7HCoWEPC/YLb9tnvoRoeOQ7SPLdW4LajZMj1GbJCTxNW8KfFdVDUAq
         ucvk2raUzTydowHw5WTJfnq40j55V5sNe5A/UDKDTLoVSU58E+CmaaCbU+2o3y4mjPqO
         2xFl6ewEbVe7TP+uBTv7uUPQLx76SD6PFQLuJoMwCnex5UHXGYlGsgqVcVbL3YiRoaxS
         XNnA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=MGN17bp0RQuYnKSNxfOT6ZJhm+M2guEfTeFqbReYHXs=;
        b=rw87T2PQ+e0i5jZBMgYlcppOtBO5R0F3hQut1u4wjc68uVVVGlly1WblBSAi52/U48
         zUj7IvpbBNWJHdxtT1bAaoSrTvB6VrQMB0PSZ7vCodjZan/l45ReqRA4gfYkuDItb3kE
         ULq7VKRNhUSxdlVXdemlIPD0kio2w61w51bUcrESkZKUYJhTpJ2vOyjxSALegltj96lv
         oeRpPO8mm4zzGn+nL87wGSl7utGpn2K3O75xyKAkGFHlvT5BINx5C36VIgd2+uHThX85
         gC5NX3v4MJ/KBPHAi7zeR9+3xIbHijd+ARuPSiU3k6fVBWXxLovzM/bI9xINn1fhXRC7
         +mdA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id u3si1036008wrr.2.2019.02.13.23.47.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Feb 2019 23:47:48 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) client-ip=213.95.11.211;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: by newverein.lst.de (Postfix, from userid 2407)
	id 94CA068CEB; Thu, 14 Feb 2019 08:47:47 +0100 (CET)
Date: Thu, 14 Feb 2019 08:47:47 +0100
From: Christoph Hellwig <hch@lst.de>
To: Khalid Aziz <khalid.aziz@oracle.com>
Cc: juergh@gmail.com, tycho@tycho.ws, jsteckli@amazon.de,
	ak@linux.intel.com, torvalds@linux-foundation.org,
	liran.alon@oracle.com, keescook@google.com,
	akpm@linux-foundation.org, mhocko@suse.com, catalin.marinas@arm.com,
	will.deacon@arm.com, jmorris@namei.org, konrad.wilk@oracle.com,
	Juerg Haefliger <juerg.haefliger@canonical.com>,
	deepa.srinivasan@oracle.com, chris.hyser@oracle.com,
	tyhicks@canonical.com, dwmw@amazon.co.uk, andrew.cooper3@citrix.com,
	jcm@redhat.com, boris.ostrovsky@oracle.com,
	kanth.ghatraju@oracle.com, oao.m.martins@oracle.com,
	jmattson@google.com, pradeep.vincent@oracle.com,
	john.haxby@oracle.com, tglx@linutronix.de,
	kirill.shutemov@linux.intel.com, hch@lst.de,
	steven.sistare@oracle.com, labbott@redhat.com, luto@kernel.org,
	dave.hansen@intel.com, peterz@infradead.org,
	kernel-hardening@lists.openwall.com, linux-mm@kvack.org,
	x86@kernel.org, linux-arm-kernel@lists.infradead.org,
	linux-kernel@vger.kernel.org, Tycho Andersen <tycho@docker.com>
Subject: Re: [RFC PATCH v8 04/14] swiotlb: Map the buffer if it was
 unmapped by XPFO
Message-ID: <20190214074747.GA10666@lst.de>
References: <cover.1550088114.git.khalid.aziz@oracle.com> <b595ffb3231dfef3c6b6c896a8e1cba0e838978c.1550088114.git.khalid.aziz@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <b595ffb3231dfef3c6b6c896a8e1cba0e838978c.1550088114.git.khalid.aziz@oracle.com>
User-Agent: Mutt/1.5.17 (2007-11-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Feb 13, 2019 at 05:01:27PM -0700, Khalid Aziz wrote:
> +++ b/kernel/dma/swiotlb.c
> @@ -396,8 +396,9 @@ static void swiotlb_bounce(phys_addr_t orig_addr, phys_addr_t tlb_addr,
>  {
>  	unsigned long pfn = PFN_DOWN(orig_addr);
>  	unsigned char *vaddr = phys_to_virt(tlb_addr);
> +	struct page *page = pfn_to_page(pfn);
>  
> -	if (PageHighMem(pfn_to_page(pfn))) {
> +	if (PageHighMem(page) || xpfo_page_is_unmapped(page)) {

I think this just wants a page_unmapped or similar helper instead of
needing the xpfo_page_is_unmapped check.  We actually have quite
a few similar construct in the arch dma mapping code for architectures
that require cache flushing.

> +bool xpfo_page_is_unmapped(struct page *page)
> +{
> +	struct xpfo *xpfo;
> +
> +	if (!static_branch_unlikely(&xpfo_inited))
> +		return false;
> +
> +	xpfo = lookup_xpfo(page);
> +	if (unlikely(!xpfo) && !xpfo->inited)
> +		return false;
> +
> +	return test_bit(XPFO_PAGE_UNMAPPED, &xpfo->flags);
> +}
> +EXPORT_SYMBOL(xpfo_page_is_unmapped);

And at least for swiotlb there is no need to export this helper,
as it is always built in.

