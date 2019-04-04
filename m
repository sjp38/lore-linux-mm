Return-Path: <SRS0=kGB6=SG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EB63AC4360F
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 07:56:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9DDF720674
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 07:56:56 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="eFm8AusD"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9DDF720674
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 31CA86B0005; Thu,  4 Apr 2019 03:56:56 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2A4406B0006; Thu,  4 Apr 2019 03:56:56 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 120F56B0007; Thu,  4 Apr 2019 03:56:56 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id C8B326B0005
	for <linux-mm@kvack.org>; Thu,  4 Apr 2019 03:56:55 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id n63so1222830pfb.14
        for <linux-mm@kvack.org>; Thu, 04 Apr 2019 00:56:55 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=sNr0UCNtybW5G7vqlzh4XQP02LQ1aNT5Ns3ahyoQ+Yk=;
        b=o8jE1yd9NUqligx+MSOkZCFDSG0J9nNANErv7j2ZIH/WHHNzuA4xIy4VnSObemCOVX
         otK+Th++2EhlbFgcijjWgTy4C4NL7bTvy/CTYLg5M4jH4RJ81qfUwABDmgMR2KjUq7nC
         l9MXPVF8aeRj9mpbevxS4FJ++BtcDQMvz5idcThpPLxCyRjBGtqjGWRmjryElLCyhvYz
         N8BjF9/N9T1z9D8YdJ4z8w5U+dT6ZIMYndVWWRQKY0kvMhNTlR9xlInoROAnw2FYnrnf
         w2YwlvkK3upCUk3GRmNtZAxdvd2mzF7WMniKAC3dZCJoEtTGDYNiAUqAFwuTpNpyr6EW
         AyPA==
X-Gm-Message-State: APjAAAUQ/5aUKkJqXaYQWPU55YPyugs9LO6BrHIheh6k56HOcA0L8Jnd
	4bzdZjApHFJhGiHcNer1hRCLAahaEWYQesog3IJfW0bwzLNBBbp86njrjkEr7sCJO5GIMmi2LFT
	3QBQQbE1hgE8LSjotnkK83UpiHb12wcAFaHUy4IO5wMaSg7ztvJk5yG88wyTIy2qsBw==
X-Received: by 2002:a63:1659:: with SMTP id 25mr4224605pgw.275.1554364615394;
        Thu, 04 Apr 2019 00:56:55 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzI2FVcbKn5fVZtDCPeKc/Fr7XpyzuhX5E8157qFSCLS8lkISFljubkHWNvaLLkzCqANAlC
X-Received: by 2002:a63:1659:: with SMTP id 25mr4224487pgw.275.1554364613079;
        Thu, 04 Apr 2019 00:56:53 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554364613; cv=none;
        d=google.com; s=arc-20160816;
        b=bhZbsZNh7PZkgFHymIqn3XEHvxI6ZlQjbR6JwE8m0vau8R50K84ZPeddzkEBcCHGBR
         Eb6+/05AeoXARZlLbXAJ3K9o7z18JJ00RQFRRgHwi0Ek5cVz9F9ZjbuyHTBiLoevUWLS
         vykEK4K5QG/XBjxqb/glbBNgerPy7Sz4qD/hncKwjYR8vKZSKUBsoHt2j/xBqEMSXOs4
         cbx6xttz2LMGlrf6csl1Jpw7U1z2Z+ggHIBK+eADpKtwWm1x0Z6rh/sYijAKmPeilbcj
         ee8+Amr7JazcX/RrEQQhLWkjd1LxZRnbArTsEDmyzuitXu45gRbnCCqBbqPwJZiFODA/
         Jujw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=sNr0UCNtybW5G7vqlzh4XQP02LQ1aNT5Ns3ahyoQ+Yk=;
        b=cf8OF8qM+CV4/5uTo/V26WB4e7D7932Wm6lJ0f5ufYom3/LoSCdQHL0R21n9TDl0Ia
         QiJ9eSwZ1lha6CcZ7+rrIJlxWGmEQ/C9ZEs6EZrgN9FD2iPDUf/ibTfL/uc6oovKtjF1
         gvzue6umF7XQ0BFmCwsuOymA9Y9aOUUCAOKUzSbarQyT27MoCy23boLv/zN78HMkodwK
         qyGGL3wT5R38aOPlb+giL0ycnrUtVd0WWUsC+AvDCHIFa79vMAbcJMMr9lD2o13mo5G0
         4FUyGXKQMOGBukP9vsIMPdRCQ9rKp6m08z/Hh/ruFGS5R2xCXeYj//YrpNdmA5Wl/9sH
         r/bA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=eFm8AusD;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=peterz@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id e3si11126696pfn.164.2019.04.04.00.56.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 04 Apr 2019 00:56:53 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=eFm8AusD;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=peterz@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=sNr0UCNtybW5G7vqlzh4XQP02LQ1aNT5Ns3ahyoQ+Yk=; b=eFm8AusDBgX3GWUX8LDuMd3Rk
	C3a398T3Ughz/tFXlkt3oUAvixILp0rtPpjU6H7/OMdaw9nae7WjWhxxgCcrSGksjwZvnL47TlwHp
	XVRXuUVsdH0J6qDly4I1BeYn1aMWTKq56mguQBwdkR9VGP2RfAvajE3krzJOWdmDMymMVno6hSQys
	7726882pVsttLds/EhwcothsC1Qeet4x+hZQq6LhZ0/d757ruB9JQXCCTGLjCt1TgF0XPzGuJfuL9
	1tJK8p3Ci3KfsgbFotzcj+2fV0XGFJENE+8bX6swcorJIn/4P/IawMq/hvV3OCZi0S1tCOMIN8/ZX
	SAOKNV6Tw==;
Received: from j217100.upc-j.chello.nl ([24.132.217.100] helo=hirez.programming.kicks-ass.net)
	by bombadil.infradead.org with esmtpsa (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hBxEv-0006RG-TV; Thu, 04 Apr 2019 07:56:50 +0000
Received: by hirez.programming.kicks-ass.net (Postfix, from userid 1000)
	id 63BAA2038C247; Thu,  4 Apr 2019 09:56:48 +0200 (CEST)
Date: Thu, 4 Apr 2019 09:56:48 +0200
From: Peter Zijlstra <peterz@infradead.org>
To: Khalid Aziz <khalid.aziz@oracle.com>
Cc: juergh@gmail.com, tycho@tycho.ws, jsteckli@amazon.de,
	ak@linux.intel.com, liran.alon@oracle.com, keescook@google.com,
	konrad.wilk@oracle.com, deepa.srinivasan@oracle.com,
	chris.hyser@oracle.com, tyhicks@canonical.com, dwmw@amazon.co.uk,
	andrew.cooper3@citrix.com, jcm@redhat.com,
	boris.ostrovsky@oracle.com, kanth.ghatraju@oracle.com,
	joao.m.martins@oracle.com, jmattson@google.com,
	pradeep.vincent@oracle.com, john.haxby@oracle.com,
	tglx@linutronix.de, kirill.shutemov@linux.intel.com, hch@lst.de,
	steven.sistare@oracle.com, labbott@redhat.com, luto@kernel.org,
	dave.hansen@intel.com, aaron.lu@intel.com,
	akpm@linux-foundation.org, alexander.h.duyck@linux.intel.com,
	amir73il@gmail.com, andreyknvl@google.com,
	aneesh.kumar@linux.ibm.com, anthony.yznaga@oracle.com,
	ard.biesheuvel@linaro.org, arnd@arndb.de, arunks@codeaurora.org,
	ben@decadent.org.uk, bigeasy@linutronix.de, bp@alien8.de,
	brgl@bgdev.pl, catalin.marinas@arm.com, corbet@lwn.net,
	cpandya@codeaurora.org, daniel.vetter@ffwll.ch,
	dan.j.williams@intel.com, gregkh@linuxfoundation.org, guro@fb.com,
	hannes@cmpxchg.org, hpa@zytor.com, iamjoonsoo.kim@lge.com,
	james.morse@arm.com, jannh@google.com, jgross@suse.com,
	jkosina@suse.cz, jmorris@namei.org, joe@perches.com,
	jrdr.linux@gmail.com, jroedel@suse.de, keith.busch@intel.com,
	khlebnikov@yandex-team.ru, logang@deltatee.com,
	marco.antonio.780@gmail.com, mark.rutland@arm.com,
	mgorman@techsingularity.net, mhocko@suse.com, mhocko@suse.cz,
	mike.kravetz@oracle.com, mingo@redhat.com, mst@redhat.com,
	m.szyprowski@samsung.com, npiggin@gmail.com, osalvador@suse.de,
	paulmck@linux.vnet.ibm.com, pavel.tatashin@microsoft.com,
	rdunlap@infradead.org, richard.weiyang@gmail.com, riel@surriel.com,
	rientjes@google.com, robin.murphy@arm.com, rostedt@goodmis.org,
	rppt@linux.vnet.ibm.com, sai.praneeth.prakhya@intel.com,
	serge@hallyn.com, steve.capper@arm.com, thymovanbeers@gmail.com,
	vbabka@suse.cz, will.deacon@arm.com, willy@infradead.org,
	yang.shi@linux.alibaba.com, yaojun8558363@gmail.com,
	ying.huang@intel.com, zhangshaokun@hisilicon.com,
	iommu@lists.linux-foundation.org, x86@kernel.org,
	linux-arm-kernel@lists.infradead.org, linux-doc@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	linux-security-module@vger.kernel.org,
	Khalid Aziz <khalid@gonehiking.org>,
	kernel-hardening@lists.openwall.com,
	"Vasileios P . Kemerlis" <vpk@cs.columbia.edu>,
	Juerg Haefliger <juerg.haefliger@canonical.com>,
	David Woodhouse <dwmw2@infradead.org>
Subject: Re: [RFC PATCH v9 11/13] xpfo, mm: optimize spinlock usage in
 xpfo_kunmap
Message-ID: <20190404075648.GQ4038@hirez.programming.kicks-ass.net>
References: <cover.1554248001.git.khalid.aziz@oracle.com>
 <5bab13e12d4215112ad2180106cc6bb9b513754a.1554248002.git.khalid.aziz@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5bab13e12d4215112ad2180106cc6bb9b513754a.1554248002.git.khalid.aziz@oracle.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Apr 03, 2019 at 11:34:12AM -0600, Khalid Aziz wrote:
> From: Julian Stecklina <jsteckli@amazon.de>
> 
> Only the xpfo_kunmap call that needs to actually unmap the page
> needs to be serialized. We need to be careful to handle the case,
> where after the atomic decrement of the mapcount, a xpfo_kmap
> increased the mapcount again. In this case, we can safely skip
> modifying the page table.
> 
> Model-checked with up to 4 concurrent callers with Spin.
> 
> Signed-off-by: Julian Stecklina <jsteckli@amazon.de>
> Signed-off-by: Khalid Aziz <khalid.aziz@oracle.com>
> Cc: Khalid Aziz <khalid@gonehiking.org>
> Cc: x86@kernel.org
> Cc: kernel-hardening@lists.openwall.com
> Cc: Vasileios P. Kemerlis <vpk@cs.columbia.edu>
> Cc: Juerg Haefliger <juerg.haefliger@canonical.com>
> Cc: Tycho Andersen <tycho@tycho.ws>
> Cc: Marco Benatto <marco.antonio.780@gmail.com>
> Cc: David Woodhouse <dwmw2@infradead.org>
> ---
>  include/linux/xpfo.h | 24 +++++++++++++++---------
>  1 file changed, 15 insertions(+), 9 deletions(-)
> 
> diff --git a/include/linux/xpfo.h b/include/linux/xpfo.h
> index 2318c7eb5fb7..37e7f52fa6ce 100644
> --- a/include/linux/xpfo.h
> +++ b/include/linux/xpfo.h
> @@ -61,6 +61,7 @@ static inline void xpfo_kmap(void *kaddr, struct page *page)
>  static inline void xpfo_kunmap(void *kaddr, struct page *page)
>  {
>  	unsigned long flags;
> +	bool flush_tlb = false;
>  
>  	if (!static_branch_unlikely(&xpfo_inited))
>  		return;
> @@ -72,18 +73,23 @@ static inline void xpfo_kunmap(void *kaddr, struct page *page)
>  	 * The page is to be allocated back to user space, so unmap it from
>  	 * the kernel, flush the TLB and tag it as a user page.
>  	 */
> -	spin_lock_irqsave(&page->xpfo_lock, flags);
> -
>  	if (atomic_dec_return(&page->xpfo_mapcount) == 0) {
> -#ifdef CONFIG_XPFO_DEBUG
> -		WARN_ON(PageXpfoUnmapped(page));
> -#endif
> -		SetPageXpfoUnmapped(page);
> -		set_kpte(kaddr, page, __pgprot(0));
> -		xpfo_flush_kernel_tlb(page, 0);
> +		spin_lock_irqsave(&page->xpfo_lock, flags);
> +
> +		/*
> +		 * In the case, where we raced with kmap after the
> +		 * atomic_dec_return, we must not nuke the mapping.
> +		 */
> +		if (atomic_read(&page->xpfo_mapcount) == 0) {
> +			SetPageXpfoUnmapped(page);
> +			set_kpte(kaddr, page, __pgprot(0));
> +			flush_tlb = true;
> +		}
> +		spin_unlock_irqrestore(&page->xpfo_lock, flags);
>  	}
>  
> -	spin_unlock_irqrestore(&page->xpfo_lock, flags);
> +	if (flush_tlb)
> +		xpfo_flush_kernel_tlb(page, 0);
>  }

This doesn't help with the TLB invalidation issue, AFAICT this is still
completely buggered. kunmap_atomic() can be called from IRQ context.

