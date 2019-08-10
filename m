Return-Path: <SRS0=GuKW=WG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EFBBBC433FF
	for <linux-mm@archiver.kernel.org>; Sat, 10 Aug 2019 10:58:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 664FA217F4
	for <linux-mm@archiver.kernel.org>; Sat, 10 Aug 2019 10:58:25 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 664FA217F4
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C5A116B0005; Sat, 10 Aug 2019 06:58:24 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C09BA6B0006; Sat, 10 Aug 2019 06:58:24 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AFBF36B0007; Sat, 10 Aug 2019 06:58:24 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id 64D286B0005
	for <linux-mm@kvack.org>; Sat, 10 Aug 2019 06:58:24 -0400 (EDT)
Received: by mail-wr1-f71.google.com with SMTP id r4so48108267wrt.13
        for <linux-mm@kvack.org>; Sat, 10 Aug 2019 03:58:24 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=P21/S/fJS9eT/ynPiPDqSMhRCMMGLfT41c0H2IwHwi0=;
        b=VwF4FmvwqrOu3d5JSza+wWFxypo5BgDtMoKQILaUMecc3VaoEH2OdxOTdXxPtJl2PF
         tU+NwVY62c56Iy7Di2s6F/+whiZI6u/j5nJ1kVBCyI582D6JeJHC2HykByrN14L4wF1V
         +e4twhzfrRxY0/mnMAwfITJ/aIJKeascO2ZqzYATWC58JgQXU8fQ+oiMSZR7u5yGl3zb
         GiBv7pW6b2FWRSgNXjEePFmg41SrPvP9qZCX9j3XfHvXR3njzeE+TZiStdqxd4pgPcLQ
         N2jB0Bs5C3lZuXPeA17ZT1ZEfZ/pxjS6hDCsYG/1teltpwK57BPWbG92HlNGYJYCiQcN
         Dsrg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
X-Gm-Message-State: APjAAAVSyqOLmSBS3+Me7oxIG8gRIfCIdF8ztf35ueCP5qd7n6E9mRk1
	oAxz6H6AdMnzTLSVWf7nSZP+JUgLGf3uV2PJot8yAsyuZ3fvKcayvPAWPom+0KqsRiTybikNBZv
	qRv039pHXauyhl3rycwWj2HZtckeeS0Ru36dC5tri673WSE47JfYjo9fObZcOfoWreA==
X-Received: by 2002:a7b:c4c6:: with SMTP id g6mr8828468wmk.52.1565434703823;
        Sat, 10 Aug 2019 03:58:23 -0700 (PDT)
X-Google-Smtp-Source: APXvYqymGN9VI/nZWswM42ldzAJaiYjbEhPsWqlbbjbZJ2NyYkUzZXMn1NfxucZm1NU76QC2QN+Z
X-Received: by 2002:a7b:c4c6:: with SMTP id g6mr8828341wmk.52.1565434702516;
        Sat, 10 Aug 2019 03:58:22 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565434702; cv=none;
        d=google.com; s=arc-20160816;
        b=DhwFQ1R1Ho8tYcZqT/nXGJ9y32OaGyfoAGtZbGHQoxrTN4IHNHWR1hhWGIxRwnHkwY
         PAjAP6YBIHHlzN6LT07CvhJJS+yCOxm/N7rlOLooYxIs3dkCoL/LjQxMBLyr6+Hyhk7w
         8RBayTGdHXgEz1rXDRsv8yAasLYAYAZDqjtbASR1s6EkDUw3RiiRT8KhSOi86E+u0Ol5
         Tg+JPgO3UlTPWk/T/xtCf96kjumWNdYWkI4PeUFA01jUeZtwsN93pFzh72XN6PbpmE6l
         08V8aS3yWFW3Axf5ewta01d/wiML+3DCWCK1d0oFV2q8yvEAHcsGlRJ3BMrne0CUeAoZ
         20Bg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=P21/S/fJS9eT/ynPiPDqSMhRCMMGLfT41c0H2IwHwi0=;
        b=MRITxd0TzVY8KphiVRbzKlJ3rxu2ruY/OsOOvZevS1mGmzumGvgyY5bdtuz64OmoMN
         C++xpuWzBptrxXyZqQMvJpgp31zCz5z/EfvaY1FKq5Z7q3dWniTqERjdhxcCUxWxjAYd
         2xk55wtiJMVuiZ9fqNj6UmQiLEq+r4UuQwv7VIfE20uQjIHLIyZ6MwCjLkevQYR4EOAb
         zMdN7Pxh4qORxalKI+pwR9a+XVAzQ6c1DFEYJNzEr7Vum2wBk0wWUA9lzLODSz4EVGby
         Xt9j7ydloRq3SkqlLwVV2+lTb+MMecGvEkl5srj30I8k4M9Xe8wO/l2UAokFv3xca08W
         i6vQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: from verein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id j18si9671933wrb.415.2019.08.10.03.58.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 10 Aug 2019 03:58:22 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) client-ip=213.95.11.211;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: by verein.lst.de (Postfix, from userid 2407)
	id D73C868BFE; Sat, 10 Aug 2019 12:58:19 +0200 (CEST)
Date: Sat, 10 Aug 2019 12:58:19 +0200
From: Christoph Hellwig <hch@lst.de>
To: Bharata B Rao <bharata@linux.ibm.com>
Cc: linuxppc-dev@lists.ozlabs.org, kvm-ppc@vger.kernel.org,
	linux-mm@kvack.org, paulus@au1.ibm.com,
	aneesh.kumar@linux.vnet.ibm.com, jglisse@redhat.com,
	linuxram@us.ibm.com, sukadev@linux.vnet.ibm.com,
	cclaudio@linux.ibm.com, hch@lst.de
Subject: Re: [PATCH v6 1/7] kvmppc: Driver to manage pages of secure guest
Message-ID: <20190810105819.GA26030@lst.de>
References: <20190809084108.30343-1-bharata@linux.ibm.com> <20190809084108.30343-2-bharata@linux.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190809084108.30343-2-bharata@linux.ibm.com>
User-Agent: Mutt/1.5.17 (2007-11-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

> +#ifdef CONFIG_PPC_UV
> +extern unsigned long kvmppc_h_svm_page_in(struct kvm *kvm,
> +					  unsigned long gra,
> +					  unsigned long flags,
> +					  unsigned long page_shift);
> +extern unsigned long kvmppc_h_svm_page_out(struct kvm *kvm,
> +					  unsigned long gra,
> +					  unsigned long flags,
> +					  unsigned long page_shift);

No need for externs on function declarations.

> +struct kvmppc_devm_device {
> +	struct device dev;
> +	dev_t devt;
> +	struct dev_pagemap pagemap;
> +	unsigned long pfn_first, pfn_last;
> +	unsigned long *pfn_bitmap;
> +};

We shouldn't really need this conaining structucture given that there
is only a single global instance of it anyway.

> +struct kvmppc_devm_copy_args {
> +	unsigned long *rmap;
> +	unsigned int lpid;
> +	unsigned long gpa;
> +	unsigned long page_shift;
> +};

Do we really need this args structure?  It is just used in a single
function call where passing the arguments might be cleaner.

> +static void kvmppc_devm_put_page(struct page *page)
> +{
> +	unsigned long pfn = page_to_pfn(page);
> +	unsigned long flags;
> +	struct kvmppc_devm_page_pvt *pvt;
> +
> +	spin_lock_irqsave(&kvmppc_devm_lock, flags);
> +	pvt = (struct kvmppc_devm_page_pvt *)page->zone_device_data;

No need for the cast.

> +	page->zone_device_data = 0;

This should be NULL.

> +
> +	bitmap_clear(kvmppc_devm.pfn_bitmap,
> +		     pfn - kvmppc_devm.pfn_first, 1);
> +	*(pvt->rmap) = 0;

No need for the braces.

> +	dpage = alloc_page_vma(GFP_HIGHUSER, mig->vma, mig->start);
> +	if (!dpage)
> +		return -EINVAL;
> +	lock_page(dpage);
> +	pvt = (struct kvmppc_devm_page_pvt *)spage->zone_device_data;

No need for the cast here.

> +static void kvmppc_devm_page_free(struct page *page)
> +{
> +	kvmppc_devm_put_page(page);
> +}

This seems to be the only caller of kvmppc_devm_put_page, any reason
not to just merge the two functions?

> +static int kvmppc_devm_pages_init(void)
> +{
> +	unsigned long nr_pfns = kvmppc_devm.pfn_last -
> +				kvmppc_devm.pfn_first;
> +
> +	kvmppc_devm.pfn_bitmap = kcalloc(BITS_TO_LONGS(nr_pfns),
> +				 sizeof(unsigned long), GFP_KERNEL);
> +	if (!kvmppc_devm.pfn_bitmap)
> +		return -ENOMEM;
> +
> +	spin_lock_init(&kvmppc_devm_lock);

Just initialize the spinlock using DEFINE_SPINLOCK() at compile time.
The rest of the function is so trivial that it can be inlined into the
caller.

Also is kvmppc_devm_lock such a good name?  This mostly just protects
the allocation bitmap, so reflecting that in the name might be a good
idea.

> +int kvmppc_devm_init(void)
> +{
> +	int ret = 0;
> +	unsigned long size;
> +	struct resource *res;
> +	void *addr;
> +
> +	size = kvmppc_get_secmem_size();
> +	if (!size) {
> +		ret = -ENODEV;
> +		goto out;
> +	}
> +
> +	ret = alloc_chrdev_region(&kvmppc_devm.devt, 0, 1,
> +				"kvmppc-devm");
> +	if (ret)
> +		goto out;
> +
> +	dev_set_name(&kvmppc_devm.dev, "kvmppc_devm_device%d", 0);
> +	kvmppc_devm.dev.release = kvmppc_devm_release;
> +	device_initialize(&kvmppc_devm.dev);
> +	res = devm_request_free_mem_region(&kvmppc_devm.dev,
> +		&iomem_resource, size);
> +	if (IS_ERR(res)) {
> +		ret = PTR_ERR(res);
> +		goto out_unregister;
> +	}
> +
> +	kvmppc_devm.pagemap.type = MEMORY_DEVICE_PRIVATE;
> +	kvmppc_devm.pagemap.res = *res;
> +	kvmppc_devm.pagemap.ops = &kvmppc_devm_ops;
> +	addr = devm_memremap_pages(&kvmppc_devm.dev, &kvmppc_devm.pagemap);
> +	if (IS_ERR(addr)) {
> +		ret = PTR_ERR(addr);
> +		goto out_unregister;
> +	}

It seems a little silly to allocate a struct device just so that we can
pass it to devm_request_free_mem_region and devm_memremap_pages.  I think
we should just create non-dev_ versions of those as well.

> +
> +	kvmppc_devm.pfn_first = res->start >> PAGE_SHIFT;
> +	kvmppc_devm.pfn_last = kvmppc_devm.pfn_first +
> +			(resource_size(res) >> PAGE_SHIFT);

pfn_last is only used to calculat a size.  Also I think we could
just use kvmppc_devm.pagemap.res directly instead of copying these
values out.  the ">> PAGE_SHIFT" is cheap enough.

