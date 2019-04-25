Return-Path: <SRS0=RcsE=S3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7FEFAC43218
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 20:38:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 636D920717
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 20:38:57 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="Ba/RHj2P"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 636D920717
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CFDC36B0003; Thu, 25 Apr 2019 16:38:56 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CAD8F6B0005; Thu, 25 Apr 2019 16:38:56 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B754E6B0006; Thu, 25 Apr 2019 16:38:56 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 786FC6B0003
	for <linux-mm@kvack.org>; Thu, 25 Apr 2019 16:38:56 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id h14so450627pgn.23
        for <linux-mm@kvack.org>; Thu, 25 Apr 2019 13:38:56 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=Getn4cTZ4pFTdmhspLn2WdzsbNKww/5YNBDIeCXTUdc=;
        b=k5Pn56v3EAD1MzcKds21pReekp9m1t8eHHasaYBVt2hPGjQyINXY/PeysGAr45OD24
         DykNIbPcPiEpDP7WerIqmXYKbgXe32DuQcgHJ1TYCpf+Nn9T9ucUF7KOp8VlEQdEB0nc
         MyKKi5ELjJkAntULJ1tlNMY2FYWa/nMlXna/SdtljZWs+mq71mIcszdftc2YqKohBZWo
         ckLfFP8uYWD8zlJ7Wti9NCE70FQZrkYFRIenqzS0Cnp/VPPl/Wh3v7tD1n03Opo3jrz9
         mBGbr+uh0NVarOllthuP3HNweWWiCevWCUi+SqSQ3MlbN1swN9IY1pwPsGQ7nYoiW84T
         Q54Q==
X-Gm-Message-State: APjAAAVQLzG/pFng9iKlSnIummirP3fxmWopfxSUD3oLKTQTKhtCKOgK
	87QCXZQ+SAskvPim8VJ03/9bfoJlazjfXmpVCZbhAf3dIpZkPtQQfMVCpwA+GewZ6+uxLnaUwle
	HmETTrjmERGZPMMJvGFA9kjHv1+sLgVPox54pqEsJ87aqH5Y8ROjKlvWZg8tDM8ZL1w==
X-Received: by 2002:a63:ff26:: with SMTP id k38mr39485758pgi.123.1556224736090;
        Thu, 25 Apr 2019 13:38:56 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwn+t8V1xozpF3DeDT1ZcrFgyBE81K/k7UD+XmYSstDxehNjIod/OOR9oIrz6QNzapthDjA
X-Received: by 2002:a63:ff26:: with SMTP id k38mr39485699pgi.123.1556224735256;
        Thu, 25 Apr 2019 13:38:55 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556224735; cv=none;
        d=google.com; s=arc-20160816;
        b=OytbZ62LcaHys0S2nEpU/GL4BHvmgTaAMbr+asHrpfXwdvHn2l8E5p5A3mqWKOmbcZ
         REVj3/rUlsf6AeRPvu2MAg3yYTtglUWYiEzbe0xQK/dRQSlnifidhYahi/ynO06RbDUs
         H5HQT8DSIpI7FhagzgNsLXh9iohP8Y182xnWcHimXOT4qRd/HYact6zKu5C8/hJX1Z6F
         D37Ewq9uCNMM7UdMRJ0120VqZuwGF3HCmB3liBMC+ZUgAtN8/yIuuRJNsPaxPzOcGyrt
         bt53O9ji6p4nvKX1g/ec4i9WMiHdxPecnEiLymscyZDS9mVOyamHlDxaoSbT9BpNDr9e
         uTpQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=Getn4cTZ4pFTdmhspLn2WdzsbNKww/5YNBDIeCXTUdc=;
        b=SL6QnZUWfOq8LWSi2i4qwrTW1fz/xOL3bDsFEm+VDrze0+PiAZGGnjF+Z2pvEhsLUv
         ybebsOQnBjSwN8kFzqDv/Gbp7amsT5goZIjB0UsZEkcWaxHtsCDeI+TiFJjZrGUQHoJ8
         7xbvtFoaI6euR3c94jwQ9ay/KBM5b76D1meBRrO4DT0FLXTilyKb2egzoPctV8+1j7z5
         M/HONMHydvo3j1vCcUXjgKggfFJLDkmV83dw1SPJl5z1YMi9yXGAguAuhh8zrSvk8vQx
         jpY44iBtULGYiHLg6/0domQhyRkm1nQ1Lzt4uMJIgeEJEgtgRu3PvO4b9/nQn0PkjdJi
         z4Ng==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b="Ba/RHj2P";
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=peterz@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id d23si22033968pgh.448.2019.04.25.13.38.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 25 Apr 2019 13:38:55 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b="Ba/RHj2P";
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=peterz@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=Getn4cTZ4pFTdmhspLn2WdzsbNKww/5YNBDIeCXTUdc=; b=Ba/RHj2PKqwoRzj/7lCLAnOuc
	JR5I1Rltif9/m0BwLlHtq/xarEqQQzk7NYCfDBIFvwfaeW73JGyno4/3sXKiM/OeGLP12PzYHWyD7
	mXYxKYSYIxOUsW/jb8kq4c0NOrkpvblGi+CQpZtEBwhz5eX1pNNs45/xq+6NdRpYyuAatYAgkHKaP
	16qrHHWC5VV8gXJ+KWpbt/jLiTI22b4SYcU6cE192rn8HQRcxLlRJH9dcswMmfsSE3mGgF+VAHCq9
	i8s4L9KvR6Oox3+8S6kfvlGEEzzNDD49oVHCCT97bAmfxpN02nxLIgmOQdqDO0rgM8CpsRocAJ7M0
	/sPr8h5vQ==;
Received: from j217100.upc-j.chello.nl ([24.132.217.100] helo=hirez.programming.kicks-ass.net)
	by bombadil.infradead.org with esmtpsa (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hJl8p-0006Vb-2T; Thu, 25 Apr 2019 20:38:49 +0000
Received: by hirez.programming.kicks-ass.net (Postfix, from userid 1000)
	id 3B5C9200D2F43; Thu, 25 Apr 2019 22:38:45 +0200 (CEST)
Date: Thu, 25 Apr 2019 22:38:45 +0200
From: Peter Zijlstra <peterz@infradead.org>
To: Rick Edgecombe <rick.p.edgecombe@intel.com>
Cc: Borislav Petkov <bp@alien8.de>, Andy Lutomirski <luto@kernel.org>,
	Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org,
	x86@kernel.org, hpa@zytor.com, Thomas Gleixner <tglx@linutronix.de>,
	Nadav Amit <nadav.amit@gmail.com>,
	Dave Hansen <dave.hansen@linux.intel.com>, linux_dti@icloud.com,
	linux-integrity@vger.kernel.org,
	linux-security-module@vger.kernel.org, akpm@linux-foundation.org,
	kernel-hardening@lists.openwall.com, linux-mm@kvack.org,
	will.deacon@arm.com, ard.biesheuvel@linaro.org,
	kristen@linux.intel.com, deneen.t.dock@intel.com
Subject: Re: [PATCH v4 16/23] vmalloc: Add flag for free of special
 permsissions
Message-ID: <20190425203845.GA12232@hirez.programming.kicks-ass.net>
References: <20190422185805.1169-1-rick.p.edgecombe@intel.com>
 <20190422185805.1169-17-rick.p.edgecombe@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190422185805.1169-17-rick.p.edgecombe@intel.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Apr 22, 2019 at 11:57:58AM -0700, Rick Edgecombe wrote:
> Add a new flag VM_FLUSH_RESET_PERMS, for enabling vfree operations to
> immediately clear executable TLB entries before freeing pages, and handle
> resetting permissions on the directmap. This flag is useful for any kind
> of memory with elevated permissions, or where there can be related
> permissions changes on the directmap. Today this is RO+X and RO memory.
> 
> Although this enables directly vfreeing non-writeable memory now,
> non-writable memory cannot be freed in an interrupt because the allocation
> itself is used as a node on deferred free list. So when RO memory needs to
> be freed in an interrupt the code doing the vfree needs to have its own
> work queue, as was the case before the deferred vfree list was added to
> vmalloc.
> 
> For architectures with set_direct_map_ implementations this whole operation
> can be done with one TLB flush when centralized like this. For others with
> directmap permissions, currently only arm64, a backup method using
> set_memory functions is used to reset the directmap. When arm64 adds
> set_direct_map_ functions, this backup can be removed.
> 
> When the TLB is flushed to both remove TLB entries for the vmalloc range
> mapping and the direct map permissions, the lazy purge operation could be
> done to try to save a TLB flush later. However today vm_unmap_aliases
> could flush a TLB range that does not include the directmap. So a helper
> is added with extra parameters that can allow both the vmalloc address and
> the direct mapping to be flushed during this operation. The behavior of the
> normal vm_unmap_aliases function is unchanged.

> +static inline void set_vm_flush_reset_perms(void *addr)
> +{
> +	struct vm_struct *vm = find_vm_area(addr);
> +
> +	if (vm)
> +		vm->flags |= VM_FLUSH_RESET_PERMS;
> +}

So, previously in the series we added NX to module_alloc() and fixed up
all the usage site. And now we're going through those very same sites to
add set_vm_flush_reset_perms().

Why isn't module_alloc() calling the above function and avoid sprinkling
it all over the place again?

