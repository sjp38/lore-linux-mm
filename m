Return-Path: <SRS0=9Pd6=UE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 179AFC282DE
	for <linux-mm@archiver.kernel.org>; Wed,  5 Jun 2019 10:02:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D8FC0206B8
	for <linux-mm@archiver.kernel.org>; Wed,  5 Jun 2019 10:02:28 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D8FC0206B8
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6D4406B000E; Wed,  5 Jun 2019 06:02:28 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 684946B0010; Wed,  5 Jun 2019 06:02:28 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 54B6D6B0266; Wed,  5 Jun 2019 06:02:28 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 344C06B000E
	for <linux-mm@kvack.org>; Wed,  5 Jun 2019 06:02:28 -0400 (EDT)
Received: by mail-qk1-f200.google.com with SMTP id l185so6083068qkd.14
        for <linux-mm@kvack.org>; Wed, 05 Jun 2019 03:02:28 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=D7S6+lYBQy9QVF6C+5yrZZENacqLJTvOXQbJ52CRC/U=;
        b=Qou7ZP+BaoSMK7rNk8kn77f62jyWV97bCYgPut397nzGAPIFQbCPxRbCExyzcu5kqR
         zpQ8Z16tMgXmAAqQcQhIizbBF1UlTTGtmT6VKBy9ysRVtMOsBF/mCRyBhNM9lBoiZczy
         3nh6QZFgYsVsvVIPmQDxJcMWkjOTqnt+ZWRohO1nRdR5+ukKlbGMz6jKBvCTQtNa98Xo
         B81mVLoLf88Si762InIgBE3ZUCRcr37nCW3YOtoKKp4URiXz42nOOKnypm67ZIN6y9ye
         9zTiNJKVG85IcHlxTgfQhAAaFDpFaF5FYQgIKtsjvYXJOyyL2n9hrqeldk25QjJ93dB7
         HBhw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of oleg@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=oleg@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAX5PjYKqIzg8SCdbe5uW1UTptLZ6lcIX23iYwMRquL3mMYaux2j
	oXa6M423wO/DI7Om8yYYSvVGChaTBUz+Pn2KZhySDA6BqoF0cORMT131Tdd+wXi0I+ewZCcgHc8
	zkWZwsby5pGp9ke1kudVdrBQ4FCeduvP+zzMPvj7DFxE3AZPkGE0V5k9/A4co48GMCw==
X-Received: by 2002:a0c:bd9a:: with SMTP id n26mr601544qvg.25.1559728947973;
        Wed, 05 Jun 2019 03:02:27 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxm5p9NDrxUjpoIBi/s9NP4HRRsEOXSm7x8LuKRNEtpzyV5eZevVtqkYpb/3046NJb+Ub29
X-Received: by 2002:a0c:bd9a:: with SMTP id n26mr601474qvg.25.1559728947222;
        Wed, 05 Jun 2019 03:02:27 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559728947; cv=none;
        d=google.com; s=arc-20160816;
        b=gpV8tPN9Ppz0WJovJ9WWURnpcVfjbLYiA4W3IuyNTb9+XTihDsDzeybsd2PQOO4txU
         INItHIUYk8Kn4DXT7+3lO8R9dj5KTPFyNBCPyJm35qAR2FEUGQ1n2MxVy14cfItEDmht
         FJKhqAl9yUC6R2fz54ceUfuZ9HTbIFCNxt0zMw9KBJBqlWXjSz2AdV43PoOkaUxKQQ+h
         NlfaL7So6eIRqoXSS2DdklPces76p/cSi+Xoh+69vTwfRi5QtUnPgNUyC2NqZU2iBl+V
         TP4ibNnONZqw6ggcBS/hb/m/FuOn9N1R+/9VF0ldN1Hc4ZEbIb9LXTe1pvfiMKC3pfMo
         F8uQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=D7S6+lYBQy9QVF6C+5yrZZENacqLJTvOXQbJ52CRC/U=;
        b=t8zM6ngR7MrcpFO124DKlaFhNmg0Ht6k2R7yVfFs45//Gy5RQ231Z9aSeOSykLYzJe
         NEPpl82pyvx1VxUfffHz8kTHEVpklpP6I11+x/QDhG4v4zSIaWHiqSrYxzyq5b5o4fO/
         8UI+yZ75c52GdGkx3A/WJ/xEzeCt58YG0Wc2ZTsNs4eePkMP9p2ZSUmemLaijpIGhPxc
         cTGuaO74mz2VXF3n5yfuhWzJ0cOekSg2IZr24mL3rJWWyHoF7G4Iy6Z8aqJNb82r5hbe
         cxgu5gSa1z80mAwDExRrKhn24SqCUv151LjVnA7WmmmQtiYoj9o8XdImC9klv1g5Fw36
         tjZg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of oleg@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=oleg@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id z20si6162898qvg.220.2019.06.05.03.02.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Jun 2019 03:02:27 -0700 (PDT)
Received-SPF: pass (google.com: domain of oleg@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of oleg@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=oleg@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx06.intmail.prod.int.phx2.redhat.com [10.5.11.16])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 50645307D90D;
	Wed,  5 Jun 2019 10:02:12 +0000 (UTC)
Received: from dhcp-27-174.brq.redhat.com (unknown [10.43.17.159])
	by smtp.corp.redhat.com (Postfix) with SMTP id 6E49A5C225;
	Wed,  5 Jun 2019 10:02:09 +0000 (UTC)
Received: by dhcp-27-174.brq.redhat.com (nbSMTP-1.00) for uid 1000
	oleg@redhat.com; Wed,  5 Jun 2019 12:02:11 +0200 (CEST)
Date: Wed, 5 Jun 2019 12:02:07 +0200
From: Oleg Nesterov <oleg@redhat.com>
To: Song Liu <songliubraving@fb.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, peterz@infradead.org,
	rostedt@goodmis.org, mhiramat@kernel.org,
	kirill.shutemov@linux.intel.com, kernel-team@fb.com,
	william.kucharski@oracle.com
Subject: Re: [PATCH uprobe, thp v2 2/5] uprobe: use original page when all
 uprobes are removed
Message-ID: <20190605100207.GD32406@redhat.com>
References: <20190604165138.1520916-1-songliubraving@fb.com>
 <20190604165138.1520916-3-songliubraving@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190604165138.1520916-3-songliubraving@fb.com>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.16
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.48]); Wed, 05 Jun 2019 10:02:16 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 06/04, Song Liu wrote:
>
> Currently, uprobe swaps the target page with a anonymous page in both
> install_breakpoint() and remove_breakpoint(). When all uprobes on a page
> are removed, the given mm is still using an anonymous page (not the
> original page).

Agreed, it would be nice to avoid this,

> @@ -461,9 +471,10 @@ int uprobe_write_opcode(struct arch_uprobe *auprobe, struct mm_struct *mm,
>  			unsigned long vaddr, uprobe_opcode_t opcode)
>  {
>  	struct uprobe *uprobe;
> -	struct page *old_page, *new_page;
> +	struct page *old_page, *new_page, *orig_page = NULL;
>  	struct vm_area_struct *vma;
>  	int ret, is_register, ref_ctr_updated = 0;
> +	pgoff_t index;
>  
>  	is_register = is_swbp_insn(&opcode);
>  	uprobe = container_of(auprobe, struct uprobe, arch);
> @@ -501,6 +512,19 @@ int uprobe_write_opcode(struct arch_uprobe *auprobe, struct mm_struct *mm,
>  	copy_highpage(new_page, old_page);
>  	copy_to_page(new_page, vaddr, &opcode, UPROBE_SWBP_INSN_SIZE);
>  
> +	index = vaddr_to_offset(vma, vaddr & PAGE_MASK) >> PAGE_SHIFT;
> +	orig_page = find_get_page(vma->vm_file->f_inode->i_mapping, index);

I think you should take is_register into account, if it is true we are going
to install the breakpoint so we can avoid find_get_page/pages_identical.

> +	if (orig_page) {
> +		if (pages_identical(new_page, orig_page)) {
> +			/* if new_page matches orig_page, use orig_page */
> +			put_page(new_page);
> +			new_page = orig_page;

Hmm. can't we simply unmap the page in this case?

Oleg.

