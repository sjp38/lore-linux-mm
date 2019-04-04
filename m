Return-Path: <SRS0=kGB6=SG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 59121C4360F
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 07:44:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 09A0520882
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 07:44:27 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="ynh5aum/"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 09A0520882
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 87DA56B0005; Thu,  4 Apr 2019 03:44:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 82BF16B0007; Thu,  4 Apr 2019 03:44:27 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6F4126B0008; Thu,  4 Apr 2019 03:44:27 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f198.google.com (mail-it1-f198.google.com [209.85.166.198])
	by kanga.kvack.org (Postfix) with ESMTP id 517D86B0005
	for <linux-mm@kvack.org>; Thu,  4 Apr 2019 03:44:27 -0400 (EDT)
Received: by mail-it1-f198.google.com with SMTP id 79so1441618itz.3
        for <linux-mm@kvack.org>; Thu, 04 Apr 2019 00:44:27 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=fkXTvxTntduKxZ8WdZYgqJ5i7S/Be5vMJb4Djj6/dOA=;
        b=mo1UDQuTpbBUz4oHibikNx8+itfnWUleZxJ7UdP3FfTvg8UjEK1xRo5QbCjJxWO2nx
         C8eikh4c+MGzDhNQggtK8SuPF7oo/NARLS28nEx87nwd2yfIAvzCKX8oahWoRqpTNDow
         Z0iWBh0Wt/5r1/pW2oI/RgFMGpzlT27D/VS9TyVn4NPBMk9xre5wySN9zWj1WYAXWG6r
         GLYyA6PMivY+akniq4eE6o/qjKNbvvJ00Y6mtfaGwJZM7ynp9NoGGUrrUiiPNe1xhqNc
         f8pMUjX3n+B3Y9TLa1Pz/iw0bqVwyVhvmDcX5h5NAywtMQRebP3Jv1oVY5Jak2Z2c+RP
         RiKg==
X-Gm-Message-State: APjAAAWOZ1sTiZI/i1Dwnp4aLGWyqE7313hBKmbIiniqNeXjNhMr5LMj
	CQPBlptp/H9yXLCVFiiL0qg6phfYRY4GKmi2sHDJ32iIczaw/4934EufU1lne4uY1Ja7mUpDgfP
	nKcIkX3sDz2xmqy9Xa5vfxHNipALXERAp6DVWMJ0JINvfbqjY//t0suCDS7gIcCO54Q==
X-Received: by 2002:a02:4482:: with SMTP id o124mr3691612jaa.121.1554363866988;
        Thu, 04 Apr 2019 00:44:26 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzNKJecr+7oOKQmHZl2ulzqAozqGvQyTRo2HOkl5BXtFLIkdSKwuGKQCJSqJqfIemIVcak8
X-Received: by 2002:a02:4482:: with SMTP id o124mr3691575jaa.121.1554363866107;
        Thu, 04 Apr 2019 00:44:26 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554363866; cv=none;
        d=google.com; s=arc-20160816;
        b=abUXhIH/puibNvn8G/AOIFzA8ixc4bAhPC3kQCgM5VoYL03MBS0iqMJxYOEpI4M62m
         mp6rlhNN100bQejEQFbxaQeVmW1E0pWhQKVhsKJUg+19BW2tnko3yWaZTWgddlJi13pU
         Ox85sPneWuUt2GbuFPosw5+TSo1zLGun5l6VD9Yk82nHkSsd3dWiYowMwVuzx3xG8DyA
         EBaWYpF1G5kbqoJ3/HdSurxUhTS0KOc1NRr0P5bAKOQ1LwU2uhfhPHuOwHcaNyZUIeFt
         wyjELT5AZGqz8IgYSfSk6UJP4zNZxC3R5n59dIcUPcY+h7raBs3IK/BDG8O+IIa8PB+u
         czbw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=fkXTvxTntduKxZ8WdZYgqJ5i7S/Be5vMJb4Djj6/dOA=;
        b=kucjBx2NzyWm5hUUq3p1DEE1ylQaSev/I1/h5jO5coNGj6pI3KqXZXsKZi5RAn3pmT
         IEAWpuG0gxi1/sTZuVjJBCjEh82B91kDHxwV/1ohqkMHBjKmFtYfa3RFIxPS/aUj8gzO
         T1VC210w6BuJVSk+UoKfPfK5cOBkuzyKClAcH8yrOhyHRfh1jVTlJeRWU04UzdfIhwVq
         hKuRnMr/Q/5WO6JH5DbvdEzAb7jd551xjORirM70T6I018rCjKq20q5fJOdFtJRndhez
         SlFijKH82t9RBlrTPIkGcoGsl/Fmxo0c5xAhksMWayObX/fHkyFnJ+uN8IcVU1a6x0Pq
         jnmQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b="ynh5aum/";
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=peterz@infradead.org
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id s24si9502307jan.48.2019.04.04.00.44.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 04 Apr 2019 00:44:26 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) client-ip=2001:8b0:10b:1231::1;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b="ynh5aum/";
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=peterz@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=merlin.20170209; h=In-Reply-To:Content-Type:MIME-Version:
	References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=fkXTvxTntduKxZ8WdZYgqJ5i7S/Be5vMJb4Djj6/dOA=; b=ynh5aum/IvMQq1evMErbxjEL3
	r8v6ZH3fod/irBtsbj3f9emyFWE1wyKW7TU+erYeHS1PoweM0OgoI/j3hBNfosLBeiNBLkqDzMgsI
	B++X5lgr8rT3cxqkJJwQCSrDLo715zCfCZO7Wydw7KzPt8T10AFX/jCF8b2TydsO27ajiiIrU8851
	N4IwuCuhliz5iINuDvRH2x/iDI6t3e8wRv31PnHIK2x15UPJ9DdF47V9AnsMEBERRNS6RHmDbkVAV
	TOh+4Sqby7RqzcXTaw7AmvP8l5uNfswFTBHJy8QWTTuMEqLiC8SiQv2gNdubMpRGLpKG/kZpm9OY2
	tXwrxLlHQ==;
Received: from j217100.upc-j.chello.nl ([24.132.217.100] helo=hirez.programming.kicks-ass.net)
	by merlin.infradead.org with esmtpsa (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hBx1x-0000sG-63; Thu, 04 Apr 2019 07:43:26 +0000
Received: by hirez.programming.kicks-ass.net (Postfix, from userid 1000)
	id E06AF2038C247; Thu,  4 Apr 2019 09:43:23 +0200 (CEST)
Date: Thu, 4 Apr 2019 09:43:23 +0200
From: Peter Zijlstra <peterz@infradead.org>
To: Khalid Aziz <khalid.aziz@oracle.com>
Cc: juergh@gmail.com, tycho@tycho.ws, jsteckli@amazon.de,
	ak@linux.intel.com, liran.alon@oracle.com, keescook@google.com,
	konrad.wilk@oracle.com,
	Juerg Haefliger <juerg.haefliger@canonical.com>,
	deepa.srinivasan@oracle.com, chris.hyser@oracle.com,
	tyhicks@canonical.com, dwmw@amazon.co.uk, andrew.cooper3@citrix.com,
	jcm@redhat.com, boris.ostrovsky@oracle.com,
	kanth.ghatraju@oracle.com, joao.m.martins@oracle.com,
	jmattson@google.com, pradeep.vincent@oracle.com,
	john.haxby@oracle.com, tglx@linutronix.de,
	kirill.shutemov@linux.intel.com, hch@lst.de,
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
Subject: Re: [RFC PATCH v9 03/13] mm: Add support for eXclusive Page Frame
 Ownership (XPFO)
Message-ID: <20190404074323.GO4038@hirez.programming.kicks-ass.net>
References: <cover.1554248001.git.khalid.aziz@oracle.com>
 <f1ac3700970365fb979533294774af0b0dd84b3b.1554248002.git.khalid.aziz@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <f1ac3700970365fb979533294774af0b0dd84b3b.1554248002.git.khalid.aziz@oracle.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


You must be so glad I no longer use kmap_atomic from NMI context :-)

On Wed, Apr 03, 2019 at 11:34:04AM -0600, Khalid Aziz wrote:
> +static inline void xpfo_kmap(void *kaddr, struct page *page)
> +{
> +	unsigned long flags;
> +
> +	if (!static_branch_unlikely(&xpfo_inited))
> +		return;
> +
> +	if (!PageXpfoUser(page))
> +		return;
> +
> +	/*
> +	 * The page was previously allocated to user space, so
> +	 * map it back into the kernel if needed. No TLB flush required.
> +	 */
> +	spin_lock_irqsave(&page->xpfo_lock, flags);
> +
> +	if ((atomic_inc_return(&page->xpfo_mapcount) == 1) &&
> +		TestClearPageXpfoUnmapped(page))
> +		set_kpte(kaddr, page, PAGE_KERNEL);
> +
> +	spin_unlock_irqrestore(&page->xpfo_lock, flags);

That's a really sad sequence, not wrong, but sad. _3_ atomic operations,
2 on likely the same cacheline. And mostly all pointless.

This patch makes xpfo_mapcount an atomic, but then all modifications are
under the spinlock, what gives?

Anyway, a possibly saner sequence might be:

	if (atomic_inc_not_zero(&page->xpfo_mapcount))
		return;

	spin_lock_irqsave(&page->xpfo_lock, flag);
	if ((atomic_inc_return(&page->xpfo_mapcount) == 1) &&
	    TestClearPageXpfoUnmapped(page))
		set_kpte(kaddr, page, PAGE_KERNEL);
	spin_unlock_irqrestore(&page->xpfo_lock, flags);

> +}
> +
> +static inline void xpfo_kunmap(void *kaddr, struct page *page)
> +{
> +	unsigned long flags;
> +
> +	if (!static_branch_unlikely(&xpfo_inited))
> +		return;
> +
> +	if (!PageXpfoUser(page))
> +		return;
> +
> +	/*
> +	 * The page is to be allocated back to user space, so unmap it from
> +	 * the kernel, flush the TLB and tag it as a user page.
> +	 */
> +	spin_lock_irqsave(&page->xpfo_lock, flags);
> +
> +	if (atomic_dec_return(&page->xpfo_mapcount) == 0) {
> +#ifdef CONFIG_XPFO_DEBUG
> +		WARN_ON(PageXpfoUnmapped(page));
> +#endif
> +		SetPageXpfoUnmapped(page);
> +		set_kpte(kaddr, page, __pgprot(0));
> +		xpfo_flush_kernel_tlb(page, 0);

You didn't speak about the TLB invalidation anywhere. But basically this
is one that x86 cannot do.

> +	}
> +
> +	spin_unlock_irqrestore(&page->xpfo_lock, flags);

Idem:

	if (atomic_add_unless(&page->xpfo_mapcount, -1, 1))
		return;

	....


> +}

Also I'm failing to see the point of PG_xpfo_unmapped, afaict it
is identical to !atomic_read(&page->xpfo_mapcount).

