Return-Path: <SRS0=HICI=RB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1FD0BC4360F
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 14:52:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D811221848
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 14:52:29 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D811221848
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 649548E0003; Tue, 26 Feb 2019 09:52:29 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5D17E8E0001; Tue, 26 Feb 2019 09:52:29 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 475318E0003; Tue, 26 Feb 2019 09:52:29 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id DDB648E0001
	for <linux-mm@kvack.org>; Tue, 26 Feb 2019 09:52:28 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id y26so824319edb.4
        for <linux-mm@kvack.org>; Tue, 26 Feb 2019 06:52:28 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=bD5NRUXxGBxdPoj8IUizuyNDwZkfIx2P+HlQoT4139I=;
        b=Mg0GicFuTFNxHHbKFIbPo9ru5lnIk8i9Z23nFBftDAz/RrIRWj1nH8UeaSxt6RrAyi
         0ZRVmLQnc2S+Z/77CRwQJUW5n7OhYdgTIVM4Wcadh1V9ZmEeAGwL5tpeR7ru7oDqp8R8
         8wDF8RqO5Y1LEiOS9nxbJ4QHtRAs2+VG+2DrRPiLqunmFE4f017PgR9hDNeLw+DcyVSt
         tTX6c6zEH/G26dKGxN5JI4C4OsnkYYqe6uq2g+K4ZgkMbb4dT+abnLOjK4K6B3q4cmuh
         GO6ZIkm/AyDTnwfZDQPHm0lctVcODpK7kGkWux8eq+586CYjGeBYdLaY1bkwtfSqsSzx
         ojGw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
X-Gm-Message-State: AHQUAuZMwsS53vBANbxzucRTk8/mcRWf4BJYmhHJNn8jE4BvigeePleK
	F9oS/kSl6vMQ2rGXHi01tQ4WZ8KDjAvSF9xOlBmO2pwtBFOORSrGzKhSIc3JCyQuU6ATo0Tgd3Q
	E5A4AIUPizqZu7qi8vh+MxnS7G92R+Y/qdcP1PK7qhmrc5Xs0au8n9LwN5lKc3xjdnA==
X-Received: by 2002:a50:9927:: with SMTP id k36mr19404652edb.31.1551192748470;
        Tue, 26 Feb 2019 06:52:28 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYWJKCCli78n6ThTrjoe/ixm/Omu7ALivjHoTr/fSjYKv/clGkVyfQpWrIksTZUE3r6BjLW
X-Received: by 2002:a50:9927:: with SMTP id k36mr19404594edb.31.1551192747588;
        Tue, 26 Feb 2019 06:52:27 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551192747; cv=none;
        d=google.com; s=arc-20160816;
        b=HeMXmg1H88tNrYccKS70ulKc7UGjPppJ0/QHljSWBYreO2pEWDt59Mu9FAQQ1TUxQK
         un5dRC4ZytRjoeR1dGpd4NkHSech8qZenj+LzDHvnrUruvJtQkai8A6SkwHdkRU+5S+Z
         VGdxgZUTgZjJQPsh737VTyqk60qOW/tozroVw/ZCxke/S5hq+XDJcNPD6PrRLMe5DWRz
         MHk7ijSkBRnRW0DnhXBNIOO4M6KTLdkoKKLs7rwg2EueF1TwwAg9dKWlBKOW5FStciQ4
         gfpOtWltu/rVEhAyHXiWGbsU60H266FGMW4+xeWruc1MVfR5sSNd4COFz1kd5rkUJ7tG
         rx0g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=bD5NRUXxGBxdPoj8IUizuyNDwZkfIx2P+HlQoT4139I=;
        b=xI8KZBCD2kljDdZaiDOjqpy5wRTHe11L4dxagEUqB/hO8F0WV5XtRD5m1+Z15Z8dlu
         wwaQVxZEX60b/2D0kjYwGZAaEFNTIlX9Vc/tQwPCDLQNXexS0wy+TYqWU+iN6lnqH7GC
         9G2p2ftxRiwYNOHEZ262AH6mGh0yNpmgTm7VVYS0seN48Gh3EXEXVRI0thNJteYKVaOY
         spWYQE6WXG9BOrdb2rT83JutmSFUZ06p8csKreazBBINALDnOyEbkdi68aDRwqlPemPA
         iAbpw63fsTt/Mf34tuQz5f57chMnry46kH2ikSpgjCRRVqDAiSRx//H9BXsrYaI5+n2e
         QxWw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id t3si4576425edb.327.2019.02.26.06.52.27
        for <linux-mm@kvack.org>;
        Tue, 26 Feb 2019 06:52:27 -0800 (PST)
Received-SPF: pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 20F27A78;
	Tue, 26 Feb 2019 06:52:26 -0800 (PST)
Received: from arrakis.emea.arm.com (arrakis.cambridge.arm.com [10.1.196.78])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id BAC4F3F703;
	Tue, 26 Feb 2019 06:52:23 -0800 (PST)
Date: Tue, 26 Feb 2019 14:52:21 +0000
From: Catalin Marinas <catalin.marinas@arm.com>
To: Mike Rapoport <rppt@linux.ibm.com>
Cc: Vlastimil Babka <vbabka@suse.cz>,
	Andrew Morton <akpm@linux-foundation.org>,
	Peng Fan <peng.fan@nxp.com>,
	"labbott@redhat.com" <labbott@redhat.com>,
	"mhocko@suse.com" <mhocko@suse.com>,
	"iamjoonsoo.kim@lge.com" <iamjoonsoo.kim@lge.com>,
	"rppt@linux.vnet.ibm.com" <rppt@linux.vnet.ibm.com>,
	"m.szyprowski@samsung.com" <m.szyprowski@samsung.com>,
	"rdunlap@infradead.org" <rdunlap@infradead.org>,
	"andreyknvl@google.com" <andreyknvl@google.com>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"van.freenix@gmail.com" <van.freenix@gmail.com>
Subject: Re: [PATCH] mm/cma: cma_declare_contiguous: correct err handling
Message-ID: <20190226145218.GA124603@arrakis.emea.arm.com>
References: <20190214125704.6678-1-peng.fan@nxp.com>
 <20190214123824.fe95cc2e603f75382490bfb4@linux-foundation.org>
 <b78470e8-b204-4a7e-f9cc-eff9c609f480@suse.cz>
 <20190219174610.GA32749@rapoport-lnx>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190219174610.GA32749@rapoport-lnx>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Feb 19, 2019 at 07:46:11PM +0200, Mike Rapoport wrote:
> On Tue, Feb 19, 2019 at 05:55:33PM +0100, Vlastimil Babka wrote:
> > On 2/14/19 9:38 PM, Andrew Morton wrote:
> > > On Thu, 14 Feb 2019 12:45:51 +0000 Peng Fan <peng.fan@nxp.com> wrote:
> > > 
> > >> In case cma_init_reserved_mem failed, need to free the memblock allocated
> > >> by memblock_reserve or memblock_alloc_range.
> > >>
> > >> ...
> > >>
> > >> --- a/mm/cma.c
> > >> +++ b/mm/cma.c
> > >> @@ -353,12 +353,14 @@ int __init cma_declare_contiguous(phys_addr_t base,
> > >>  
> > >>  	ret = cma_init_reserved_mem(base, size, order_per_bit, name, res_cma);
> > >>  	if (ret)
> > >> -		goto err;
> > >> +		goto free_mem;
> > >>  
> > >>  	pr_info("Reserved %ld MiB at %pa\n", (unsigned long)size / SZ_1M,
> > >>  		&base);
> > >>  	return 0;
> > >>  
> > >> +free_mem:
> > >> +	memblock_free(base, size);
> > >>  err:
> > >>  	pr_err("Failed to reserve %ld MiB\n", (unsigned long)size / SZ_1M);
> > >>  	return ret;
> > > 
> > > This doesn't look right to me.  In the `fixed==true' case we didn't
> > > actually allocate anything and in the `fixed==false' case, the
> > > allocated memory is at `addr', not at `base'.
> > 
> > I think it's ok as the fixed==true path has "memblock_reserve()", but
> > better leave this to the memblock maintainer :)
> 
> As Peng Fan noted in the other e-mail, fixed==true has memblock_reserve()
> and fixed==false resets base = addr, so this is Ok.
>  
> > There's also 'kmemleak_ignore_phys(addr)' which should probably be
> > undone (or not called at all) in the failure case. But it seems to be
> > missing from the fixed==true path?
> 
> Well, memblock and kmemleak interaction does not seem to have clear
> semantics anyway. memblock_free() calls kmemleak_free_part_phys() which
> does not seem to care about ignored objects.
> As for the fixed==true path, memblock_reserve() does not register the area
> with kmemleak, so there would be no object to free in memblock_free().
> AFAIU, kmemleak simply ignores this.

Kmemleak is supposed to work with the memblock_{alloc,free} pair and it
ignores the memblock_reserve() as a memblock_alloc() implementation
detail. It is, however, tolerant to memblock_free() being called on a
sub-range or just a different range from a previous memblock_alloc(). So
the original patch looks fine to me. FWIW:

Reviewed-by: Catalin Marinas <catalin.marinas@arm.com>

