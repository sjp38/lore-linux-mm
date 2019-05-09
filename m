Return-Path: <SRS0=5q+O=TJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.2 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_MUTT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9100FC04AB1
	for <linux-mm@archiver.kernel.org>; Thu,  9 May 2019 17:42:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5A1A220675
	for <linux-mm@archiver.kernel.org>; Thu,  9 May 2019 17:42:26 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="A+r+1MhW"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5A1A220675
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EDBBB6B0003; Thu,  9 May 2019 13:42:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E66516B0006; Thu,  9 May 2019 13:42:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CDFA96B0007; Thu,  9 May 2019 13:42:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 9556F6B0003
	for <linux-mm@kvack.org>; Thu,  9 May 2019 13:42:25 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id o8so2120679pgq.5
        for <linux-mm@kvack.org>; Thu, 09 May 2019 10:42:25 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=SWxiY7wLMkvGzgYZ4dhJCkizwo7IZKg5eY+l4keAF+w=;
        b=bX3aIi8rrQoVevAEYsqhj2YS9c0crDC0PAJ3P1bV3zdtBp0aONNHDJGx5SL3BfVEKo
         IzR1tCrkfPDU4GOdLEiTzZ7lAGlny5TxTqoj88sgpqEyhC3I4KHOLMGDfZ9UTVc1bl2O
         stLuCUMII+9MsN3IKK6SOszkrwFbh15qvih6NZVsXa5m3DqphyfIHeKaD9UF9tmafF7U
         OYfuCjkqIkMydt7TjaU2XMy9V2AcIRs7ilCrmAU2W6Ng6k8KtDMqbc+Duw6XI3ROB8Uk
         SLrngL7uWOTzNIaLtRP2pqvCSmkuPH1CDxyelf/VA7D4D0g65mn3gqIwa329Y4IPy0pG
         tMvw==
X-Gm-Message-State: APjAAAW2CCskF5D6GzEjH+MgPlig6lUmJnBHOhAPKiyb0GWUmd8ZlwkV
	G8/jsMErHdvUkIwY1oMqeNr939q0FqiX18Z+uDNLNl/Sbrso2TGiaEIrgFucHFrCkyXU8Ge4z7H
	vhv/eYCGPHoDQSwyHjSZRdZZL4MEVTmphZnDQIRnb3h83UVXRwxYBl7M31LHEQ4JhGA==
X-Received: by 2002:a63:d949:: with SMTP id e9mr7184025pgj.437.1557423745133;
        Thu, 09 May 2019 10:42:25 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzEDVFIGQvpb5XVS2CXmdaHNugntmyjIaThcJgbtNfx0yMTK32Vdv5+735I8d3cNk78VK1I
X-Received: by 2002:a63:d949:: with SMTP id e9mr7183952pgj.437.1557423744431;
        Thu, 09 May 2019 10:42:24 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557423744; cv=none;
        d=google.com; s=arc-20160816;
        b=Bn7mCliXTMC4z3Ryfoxf459jIfumG0+Iq9qGWq6VDRQ6AndsSuCsE4HCKcshDzWG5Z
         nVGJMRlkDrDOq5h2SX4IkRyY7y3D+A1mhqzBwlRq56Jnod6rZ0TFC3/P+5NzUBhD7PpS
         QuHvTtlS2G8K3hHW9IPp3ivTWlj9UjL+QRdS8I2GV6H69/onjm4V0CatzeBjK5I28B86
         loQZ41G8Dvicmx+KcEfZnlNhDdZ8b8OJj/6E0ZtImBCDG+HuDOO05u89lTSW6fT6twP3
         TJGfdY4Zsbt5Rz4aJJFXu6ajwgf0YGli6Jjar/ipo2WBcUVeNQQHFinbNep5r3v8j1Ph
         PgEQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=SWxiY7wLMkvGzgYZ4dhJCkizwo7IZKg5eY+l4keAF+w=;
        b=Mvr5Wum0gwJTdav3HE+tF+hjy81rTamLquwTq5HjYjs3RbZ0vqDCxhKxhjhlxfOfWy
         n5g7S49NAr1w11EsER+gVksrxWpJ04ejLrvvKaA5T9MdZyCA6Sa9lgwL7j1J+VRH81I3
         AllvoFidbI0TjkjVSfBQ1qJtRjdgcUH+uJan5+qbd5/RF2WKJgQ5yhUFOB2oMlxE3P0J
         gsPqUcq02zSsZJ+oIs/t+gKemBUvlZfkLefzAz3+3wHeHEARB91ECMbALU33KHZj5G7k
         lz0T0O0kusnYUk/+D7MUH/OfJb2dxE6hPxSE/nxsFaxtlr3HtXSewlF++bhCBuYMkl3x
         nQSQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=A+r+1MhW;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id r39si3825981pld.10.2019.05.09.10.42.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 09 May 2019 10:42:24 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=A+r+1MhW;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=SWxiY7wLMkvGzgYZ4dhJCkizwo7IZKg5eY+l4keAF+w=; b=A+r+1MhWu/dkRNuFIgEnO64VI
	MbuTp1uF2SGZIS/b/4+Q9/wkGy8Nb8jCTAu4AqSvvfmbvfCLsn7yuBflpfI4fnGbLfbg2g0iiVcmN
	zowWbM+NicYMfTiL4lRHtDyOS/Bc5WsOiWTpXdx0l0jkNtyMI6YMzLLCguRIs1HglMamuA61hDuI5
	aEjceSgZhHv3m8sQeYir/8gDn0glrdEQtRSvP+DeboAUNaXnkJzr1qjIPkcnsdI5PQEVv6fxLJuP2
	8il84ihcOElvpUkBREhm6AqLzH295tN0gomSEbRmxJ8UB6xOGLHnY+napd6YJwhAz/mJU8DmwaJSJ
	5en8emtJg==;
Received: from willy by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hOn3k-0006iG-S4; Thu, 09 May 2019 17:42:20 +0000
Date: Thu, 9 May 2019 10:42:20 -0700
From: Matthew Wilcox <willy@infradead.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: akpm@linux-foundation.org, stable@vger.kernel.org,
	Piotr Balcer <piotr.balcer@intel.com>, Yan Ma <yan.ma@intel.com>,
	"Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>,
	Chandan Rajendra <chandan@linux.ibm.com>, Jan Kara <jack@suse.cz>,
	Souptick Joarder <jrdr.linux@gmail.com>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org
Subject: Re: [PATCH] mm/huge_memory: Fix vmf_insert_pfn_{pmd, pud}() crash,
 handle unaligned addresses
Message-ID: <20190509174220.GA6235@bombadil.infradead.org>
References: <155741946350.372037.11148198430068238140.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <155741946350.372037.11148198430068238140.stgit@dwillia2-desk3.amr.corp.intel.com>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, May 09, 2019 at 09:31:41AM -0700, Dan Williams wrote:
> diff --git a/drivers/dax/device.c b/drivers/dax/device.c
> index e428468ab661..996d68ff992a 100644
> --- a/drivers/dax/device.c
> +++ b/drivers/dax/device.c
> @@ -184,8 +184,7 @@ static vm_fault_t __dev_dax_pmd_fault(struct dev_dax *dev_dax,
> +	return vmf_insert_pfn_pmd(vmf, *pfn, vmf->flags & FAULT_FLAG_WRITE);

I think we can ditch the third parameter too.  Going through the callers ...

> @@ -235,8 +234,7 @@ static vm_fault_t __dev_dax_pud_fault(struct dev_dax *dev_dax,
> +	return vmf_insert_pfn_pud(vmf, *pfn, vmf->flags & FAULT_FLAG_WRITE);

> @@ -1575,8 +1575,7 @@ static vm_fault_t dax_iomap_pmd_fault(struct vm_fault *vmf, pfn_t *pfnp,
> +		result = vmf_insert_pfn_pmd(vmf, pfn, write);

This 'write' parameter came earlier from:

        bool write = vmf->flags & FAULT_FLAG_WRITE;

and it is not modified subsequently.

> @@ -1686,8 +1685,7 @@ dax_insert_pfn_mkwrite(struct vm_fault *vmf, pfn_t pfn, unsigned int order)
> +		ret = vmf_insert_pfn_pmd(vmf, pfn, FAULT_FLAG_WRITE);

If FAULT_FLAG_WRITE is not set in a mkwrite handler, I don't know
what's gone wrong with the world.

Even without these changes,

Reviewed-by: Matthew Wilcox <willy@infradead.org>

