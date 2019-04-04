Return-Path: <SRS0=kGB6=SG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E16C1C10F0E
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 08:19:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 965272075E
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 08:19:17 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="pzmy567a"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 965272075E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 493986B0005; Thu,  4 Apr 2019 04:19:17 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 440366B0006; Thu,  4 Apr 2019 04:19:17 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 30A556B0007; Thu,  4 Apr 2019 04:19:17 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id EC5176B0005
	for <linux-mm@kvack.org>; Thu,  4 Apr 2019 04:19:16 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id y2so1256845pfl.16
        for <linux-mm@kvack.org>; Thu, 04 Apr 2019 01:19:16 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=LNyXvdI8JxEsiGwfHNcov9VDzHahXWYQ7iPiyxvAPh0=;
        b=MR0RxnbQZawB46vyqvxWRg9w1S6U0k3mO6JI9fX8lR2bzBsEfnr6276Feyp/UebKCj
         6Z7R7ecs6puSZV6PP28SsfMDC/3/0S4XOHRLcWAVtTKEgDX+xX+eixs4Du9e8p85OtEN
         PbfAtrJv5XNle0j/0oOT9i1Qqnagguh5SX6ZPLqbcyNdrbVEOqHYZ6f5RtRYmJKPlHiw
         GrYQr/N43Y/ueFBeJHJ3DJFUsYOuQyiRH3Hi4ofLen1Cc+GfXY6+WzrhigQO9DxqBTqC
         +iPgE8OXIrYwZXCKU3Vv6NWe4Y1h6nvV5+ZGJgo2c/XkmeWkh6QrlxJxQyGzAQx59x1k
         Z5Cg==
X-Gm-Message-State: APjAAAU8FV3sxHshW7JNqF1/e01JJbL+RU6/bMAoyJarNpAEiB64IL2o
	qsBXKF2ZeY1SIfN7h7D+YTOUrUSIfyS7jqMC93433dB198w52uTyhYSXaCKZqiVtciCIvgMAcfL
	s7vvXCQy4Qfp4qz0QN6DGoOYgNGATMjTSUD0hidQntY6zWEBIZceV0t33asaAlVkOAw==
X-Received: by 2002:a17:902:2702:: with SMTP id c2mr4715018plb.239.1554365956557;
        Thu, 04 Apr 2019 01:19:16 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyNYW1uCBOqOdOOB7A1y8PPRuVJp0Ezoh3Q1HwNPf3glRSAtAkXjGnW4wcp1agSXo2T3HN2
X-Received: by 2002:a17:902:2702:: with SMTP id c2mr4714952plb.239.1554365955674;
        Thu, 04 Apr 2019 01:19:15 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554365955; cv=none;
        d=google.com; s=arc-20160816;
        b=t5jXbPDELLj00M3PzMtEq684QQYUmG+MRzJV8MzVnAi5CtdE/N6WbwkxhtvefibIYc
         VXj51El0zdk5BxCkPpUyL5nWD1VtDMzvPDaoPjG6PAXq5XMLf8tUBC19mQaG5ZCg8Y5f
         DQOIyPcEAHZXbqwleT84Xsc4k2d+cX/7Gx1uw73sLh5ktETQmBU4gIorpwqBusDrWXY3
         ARx/6gjyq2SpuaEdraJGqhR840oV24enCi6+s8nnETPgoux0N+kSdMRaSi/3vdHMNCyr
         UVTWBYKBoLCy2ASZ+AjBdLk7Ps8z3ElOKgzsQ5QKQpyK2dk5LNAujVWdpjBjLd5iQXxb
         3xKw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=LNyXvdI8JxEsiGwfHNcov9VDzHahXWYQ7iPiyxvAPh0=;
        b=Kj0rCiNNvuKMzH2fSrBWwXx9TERviwWm9gPoUS4hcVuhf3gvtbQHw/Bz4mCUJAYa55
         7/D9XL98zq+M2VsCW6GUGIku1THpPA09uIe4dTUXZSdxTNJw3LqKFPn3M8ycjEjULm4/
         4WCdGY5W0loC5io7lN605d2+BB5nJrhxH0GBxMsh5zaHocsh8cNBwAt8TmUJcYj2yzc3
         yGTbS+35cO2m+EbMFwzc83oQmMDeHB1/1dgeq/opf2amjfthw6j7nCDNFmEFMFglaXQS
         8sVxGR8j+7SNd8g1WewMJrINckqx9oKxdw1tLWH8S/EvhZ8hL23dAE5+Az/3vFXr5W6F
         +zMw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=pzmy567a;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=peterz@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id n11si15767175pgu.562.2019.04.04.01.19.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 04 Apr 2019 01:19:15 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=pzmy567a;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=peterz@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=LNyXvdI8JxEsiGwfHNcov9VDzHahXWYQ7iPiyxvAPh0=; b=pzmy567azB5TJxYdB1PGuD4gk
	2kQM6BmfmutCrm82ZU4JGILi5VVvhQGVLVgec/E00xobnybHyuaUteaM1Txi72LKH24mMlWOaqXIU
	ArlNuHF9sn8e9+19BXDNbiFC8IDnejzPOFgCIgPV7dMtkl/Sp9sBCyuI2malJ1qc79LIvc0AkEkS7
	xiXc/Mq6+PbVfXxmRh+gPm0i0KXG0WD/r4ya/zTy92OfCzGurMQLa0mWZF3DscX1HBW7FspucFcNg
	/4EFRVtptrtI9tTiUY63Hw1SEpXVmJO3P6ukPOKKpoSvjGH22kmp0AMbbUAWwWOTUxPBihDo4+A4Y
	Z8rh0raUQ==;
Received: from j217100.upc-j.chello.nl ([24.132.217.100] helo=hirez.programming.kicks-ass.net)
	by bombadil.infradead.org with esmtpsa (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hBxaD-00089y-4n; Thu, 04 Apr 2019 08:18:49 +0000
Received: by hirez.programming.kicks-ass.net (Postfix, from userid 1000)
	id 997212022A093; Thu,  4 Apr 2019 10:18:47 +0200 (CEST)
Date: Thu, 4 Apr 2019 10:18:47 +0200
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
	Khalid Aziz <khalid@gonehiking.org>
Subject: Re: [RFC PATCH v9 12/13] xpfo, mm: Defer TLB flushes for non-current
 CPUs (x86 only)
Message-ID: <20190404081847.GR4038@hirez.programming.kicks-ass.net>
References: <cover.1554248001.git.khalid.aziz@oracle.com>
 <4495dda4bfc4a06b3312cc4063915b306ecfaecb.1554248002.git.khalid.aziz@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4495dda4bfc4a06b3312cc4063915b306ecfaecb.1554248002.git.khalid.aziz@oracle.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Apr 03, 2019 at 11:34:13AM -0600, Khalid Aziz wrote:
> diff --git a/arch/x86/mm/tlb.c b/arch/x86/mm/tlb.c
> index 999d6d8f0bef..cc806a01a0eb 100644
> --- a/arch/x86/mm/tlb.c
> +++ b/arch/x86/mm/tlb.c
> @@ -37,6 +37,20 @@
>   */
>  #define LAST_USER_MM_IBPB	0x1UL
>  
> +/*
> + * A TLB flush may be needed to flush stale TLB entries
> + * for pages that have been mapped into userspace and unmapped
> + * from kernel space. This TLB flush needs to be propagated to
> + * all CPUs. Asynchronous flush requests to all CPUs can cause
> + * significant performance imapct. Queue a pending flush for
> + * a CPU instead. Multiple of these requests can then be handled
> + * by a CPU at a less disruptive time, like context switch, in
> + * one go and reduce performance impact significantly. Following
> + * data structure is used to keep track of CPUs with pending full
> + * TLB flush forced by xpfo.
> + */
> +static cpumask_t pending_xpfo_flush;
> +
>  /*
>   * We get here when we do something requiring a TLB invalidation
>   * but could not go invalidate all of the contexts.  We do the
> @@ -321,6 +335,16 @@ void switch_mm_irqs_off(struct mm_struct *prev, struct mm_struct *next,
>  		__flush_tlb_all();
>  	}
>  #endif
> +
> +	/*
> +	 * If there is a pending TLB flush for this CPU due to XPFO
> +	 * flush, do it now.
> +	 */
> +	if (cpumask_test_and_clear_cpu(cpu, &pending_xpfo_flush)) {
> +		count_vm_tlb_event(NR_TLB_REMOTE_FLUSH_RECEIVED);
> +		__flush_tlb_all();
> +	}

That really should be:

	if (cpumask_test_cpu(cpu, &pending_xpfo_flush)) {
		cpumask_clear_cpu(cpu, &pending_xpfo_flush);
		count_vm_tlb_event(NR_TLB_REMOTE_FLUSH_RECEIVED);
		__flush_tlb_all();
	}

test_and_clear is an unconditional RmW and can cause cacheline
contention between adjecent CPUs even if none of the bits are set.

> +
>  	this_cpu_write(cpu_tlbstate.is_lazy, false);
>  
>  	/*
> @@ -803,6 +827,34 @@ void flush_tlb_kernel_range(unsigned long start, unsigned long end)
>  	}
>  }
>  
> +void xpfo_flush_tlb_kernel_range(unsigned long start, unsigned long end)
> +{
> +	struct cpumask tmp_mask;
> +
> +	/*
> +	 * Balance as user space task's flush, a bit conservative.
> +	 * Do a local flush immediately and post a pending flush on all
> +	 * other CPUs. Local flush can be a range flush or full flush
> +	 * depending upon the number of entries to be flushed. Remote
> +	 * flushes will be done by individual processors at the time of
> +	 * context switch and this allows multiple flush requests from
> +	 * other CPUs to be batched together.
> +	 */
> +	if (end == TLB_FLUSH_ALL ||
> +	    (end - start) > tlb_single_page_flush_ceiling << PAGE_SHIFT) {
> +		do_flush_tlb_all(NULL);
> +	} else {
> +		struct flush_tlb_info info;
> +
> +		info.start = start;
> +		info.end = end;
> +		do_kernel_range_flush(&info);
> +	}
> +	cpumask_setall(&tmp_mask);
> +	__cpumask_clear_cpu(smp_processor_id(), &tmp_mask);
> +	cpumask_or(&pending_xpfo_flush, &pending_xpfo_flush, &tmp_mask);
> +}
> +
>  void arch_tlbbatch_flush(struct arch_tlbflush_unmap_batch *batch)
>  {
>  	struct flush_tlb_info info = {
> diff --git a/arch/x86/mm/xpfo.c b/arch/x86/mm/xpfo.c
> index b42513347865..638eee5b1f09 100644
> --- a/arch/x86/mm/xpfo.c
> +++ b/arch/x86/mm/xpfo.c
> @@ -118,7 +118,7 @@ inline void xpfo_flush_kernel_tlb(struct page *page, int order)
>  		return;
>  	}
>  
> -	flush_tlb_kernel_range(kaddr, kaddr + (1 << order) * size);
> +	xpfo_flush_tlb_kernel_range(kaddr, kaddr + (1 << order) * size);
>  }
>  EXPORT_SYMBOL_GPL(xpfo_flush_kernel_tlb);

So this patch is the one that makes it 'work', but I'm with Andy on
hating it something fierce.

Up until this point x86_64 is completely buggered in this series, after
this it sorta works but *urgh* what crap.

All in all your changelog is complete and utter garbage, this is _NOT_ a
performance issue. It is a very much a correctness issue.

Also; I distinctly dislike the inconsistent TLB states this generates.
It makes it very hard to argue for its correctness..

