Return-Path: <SRS0=DRoR=SM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 14F95C10F11
	for <linux-mm@archiver.kernel.org>; Wed, 10 Apr 2019 06:59:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BABBA217D6
	for <linux-mm@archiver.kernel.org>; Wed, 10 Apr 2019 06:59:18 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="kKWEuING"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BABBA217D6
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3257C6B0006; Wed, 10 Apr 2019 02:59:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2D3496B0008; Wed, 10 Apr 2019 02:59:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 19C4E6B000A; Wed, 10 Apr 2019 02:59:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id D899A6B0006
	for <linux-mm@kvack.org>; Wed, 10 Apr 2019 02:59:17 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id l13so1263686pgp.3
        for <linux-mm@kvack.org>; Tue, 09 Apr 2019 23:59:17 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=Pa9yXGXWbJBeYpUWKfQ3OcoqrYebqvpcXb3jKozmpHo=;
        b=YI5d5AYP96ySv+A/bBVUga9HAisjwG0Xlsmm2UarWuppqYOJjoPc3SgBfwNvLpBfnR
         04qapR6lPcHF/jBYHoWjJwHab6AWQF7Do5p93TU0ZyIjf/d12mRi4MUFnG7O6knePbQe
         orQ2TPBFoR5TIAVEnvXgfGeBdjz7e2ZkjQFWR6VLUuMcLw8sOWzK22+4s/DRPgWyaNyg
         QPQL3rfXxAqhrXTBAMpBAG3UjEoFehydwaND8EwZ6DkXUCtsKi6uUXVsLCUYmodqzZQL
         iO4j2rFti3/36RyqbpcyLNYnAyxTZmRztsrwlZOPCpg4YtiTexSr9mzgxt5DIPT7zdqs
         h34g==
X-Gm-Message-State: APjAAAUtMUGyg726jtpVGtkAO8spzS4SDGey7YKP2XrgeT8FDEpL2q64
	xq0L5HB0WTZj0ZtryJL85v/Ayyytp9PL3jd92jq2VDr8vH7EwIUccJOviVe3ofvSQ8ToPSE5rXV
	h07UjLVFxtNZBD7ZZGA+P5B3YHzTdajBB0/aMG9488QRBpLqL7UDQ1N2rV9LAgS2IKw==
X-Received: by 2002:a63:6844:: with SMTP id d65mr39885739pgc.393.1554879557450;
        Tue, 09 Apr 2019 23:59:17 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzbh8AENmedp/0CXN+xPRKrmNXzan8aAIHwfzOj4/wXpsRMDMA8Sjz4FJ7uSp69/cdVmqd6
X-Received: by 2002:a63:6844:: with SMTP id d65mr39885688pgc.393.1554879556722;
        Tue, 09 Apr 2019 23:59:16 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554879556; cv=none;
        d=google.com; s=arc-20160816;
        b=Jo2tFaM0G8dhxRmgYsxF3qTpMFvIze56l3x8GzaMO/QYvuTH5rxHo36/N/Fhhna0zv
         kbutGSi1hZyWKUUw4VoK2hqfSRCp8vXJYq3pIwCFnbrUF0suIAu4lr5Q6sLiMhJ6p+V+
         GEXwGpJUGCfZ/HDFKE4jJ3FN2fiYim8ogXDy6f0ltOAIsc02lze9O7Sv556mO74oKkZa
         GwVMP4uTlVeHhn3XJ33w+0qIQ4pDq0Kn+xQJRxo7A5jTDPqL+sgpdsW4xLeO/FgymB+a
         3Gb9Cl6yvTHQ3+D87Q8F504wYZzcLjE3NpyNk4lzzdgBJfCf2tejxXDFI+KmxLOCIrpy
         Hbxw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=Pa9yXGXWbJBeYpUWKfQ3OcoqrYebqvpcXb3jKozmpHo=;
        b=VVWhOOzsuxW7p+aJdmBP37z8uojAkYmkznr0idUGlxz1Mb1qRp/+cKANfK7yDyC8EE
         5IQdDx8nC6KetqkkWoF6bgkZidH6WGwCiOM9XsyemJbYR80UdJJbPU+7biMwYQF3IEff
         O9TX37Pld1Fwh4N16VWHaotllC31QnzsrxR2bc24oIdxE0zzUIbXFPlf5h5ac8ly1PPx
         iXYWP647on98zL7hLiSy0MPp975ju1qL45IStVf0Rx20Ag6BRe5oGC+83xk4kEfkdic3
         Q+LHiz+2j9IWIi21owDlX1GizzibXbJw/H+fMLAfx36TrYqqG78+jVNWzNcCUNjuQMQC
         3bTA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=kKWEuING;
       spf=pass (google.com: best guess record for domain of batv+a16ff09a3038f8df3613+5708+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+a16ff09a3038f8df3613+5708+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id 130si30597955pgc.256.2019.04.09.23.59.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 09 Apr 2019 23:59:16 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+a16ff09a3038f8df3613+5708+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=kKWEuING;
       spf=pass (google.com: best guess record for domain of batv+a16ff09a3038f8df3613+5708+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+a16ff09a3038f8df3613+5708+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=Pa9yXGXWbJBeYpUWKfQ3OcoqrYebqvpcXb3jKozmpHo=; b=kKWEuING3f2F4y1Crs43dW3di
	7Bgxl9UZq1ZWxGCBndfeH4As6FMxSHsqaBeXbGy1nKaBH4fcs4OGwRybfuk4thgRdacux+1NeL1wd
	fZ6MJ5QYy6PgmfZlZ1HuxBa2ZUuT4ynZ1HRd05tlU6w3HRdXC5FyER53UnJmZ3eODIvvVSDtMzA1o
	y0AmGJwp57NBJKxbBbCHJh4/wf99JEbw+dEwYWXttkE5YROQ6NdHe5mr0dWl2/XApRnu9i+o1aNrt
	ekUQ+YuDTPg9b5SNQIt5cFJD4lyNzNCzk4BP4gjihHO/QIWHLOmKmkyDFDaFRJut/1iiO9BJAP5q3
	475Whn/4g==;
Received: from hch by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hE7CO-0003NH-8Q; Wed, 10 Apr 2019 06:59:08 +0000
Date: Tue, 9 Apr 2019 23:59:08 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Alexandre Ghiti <alex@ghiti.fr>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Albert Ou <aou@eecs.berkeley.edu>,
	Kees Cook <keescook@chromium.org>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Palmer Dabbelt <palmer@sifive.com>,
	Will Deacon <will.deacon@arm.com>,
	Russell King <linux@armlinux.org.uk>,
	Ralf Baechle <ralf@linux-mips.org>, linux-kernel@vger.kernel.org,
	Christoph Hellwig <hch@infradead.org>, linux-mm@kvack.org,
	Paul Burton <paul.burton@mips.com>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	James Hogan <jhogan@kernel.org>, linux-fsdevel@vger.kernel.org,
	linux-riscv@lists.infradead.org, linux-mips@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org,
	Luis Chamberlain <mcgrof@kernel.org>
Subject: Re: [PATCH v2 2/5] arm64, mm: Move generic mmap layout functions to
 mm
Message-ID: <20190410065908.GC2942@infradead.org>
References: <20190404055128.24330-1-alex@ghiti.fr>
 <20190404055128.24330-3-alex@ghiti.fr>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190404055128.24330-3-alex@ghiti.fr>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Apr 04, 2019 at 01:51:25AM -0400, Alexandre Ghiti wrote:
> - fix the case where stack randomization should not be taken into
>   account.

Hmm.  This sounds a bit vague.  It might be better if something
considered a fix is split out to a separate patch with a good
description.

> +config ARCH_WANT_DEFAULT_TOPDOWN_MMAP_LAYOUT
> +	bool
> +	help
> +	  This allows to use a set of generic functions to determine mmap base
> +	  address by giving priority to top-down scheme only if the process
> +	  is not in legacy mode (compat task, unlimited stack size or
> +	  sysctl_legacy_va_layout).

Given that this is an option that is just selected by other Kconfig
options the help text won't ever be shown.  I'd just move it into a
comment bove the definition.

> +#ifdef CONFIG_MMU
> +#ifdef CONFIG_ARCH_WANT_DEFAULT_TOPDOWN_MMAP_LAYOUT

I don't think we need the #ifdef CONFIG_MMU here,
CONFIG_ARCH_WANT_DEFAULT_TOPDOWN_MMAP_LAYOUT should only be selected
if the MMU is enabled to start with.

> +#ifdef CONFIG_ARCH_HAS_ELF_RANDOMIZE
> +unsigned long arch_mmap_rnd(void)

Now that a bunch of architectures use a version in common code
the arch_ prefix is a bit mislead.  Probably not worth changing
here, but some time in the future it could use a new name.

