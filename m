Return-Path: <SRS0=kGB6=SG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E7503C4360F
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 07:22:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9789920855
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 07:22:41 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="tMrbVWBf"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9789920855
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2721C6B0006; Thu,  4 Apr 2019 03:22:41 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1FC266B000D; Thu,  4 Apr 2019 03:22:41 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0755B6B000E; Thu,  4 Apr 2019 03:22:41 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id BDAE56B0006
	for <linux-mm@kvack.org>; Thu,  4 Apr 2019 03:22:40 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id u2so1006624pgi.10
        for <linux-mm@kvack.org>; Thu, 04 Apr 2019 00:22:40 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=NuCj5JtYrNzGsmbwn0QA8u7nztnxy+OdMzQXQhCdVuU=;
        b=RwvM6QdDE5E+650En5XPdw+vpxaKvtHUvERsqDK+ESlkchIhAmEH5tbIR3bwBk7y77
         XNtj92Zs8QFoTjO7MctXH97yXB7UFSuDMPdZcl3mNAiZMZYslnZqcmWmkroRCtfb7YSY
         yvFH3jFCdyKP4xsAJai7Fpjy9tve4bhyZiz2Lwk+exP4nHGztpLc8oqHn4jB2iHDFoP+
         Rn1wrDbjh1D/FmVuC+6yhEBiY1Uv9hbpLhnLnWWBAyNJAgs6q23kIs6zGQ5uECAfp5Te
         X48qUf5Mx20iu2eUfPxI1znlbLSe+QxE/ad5+2AZC1FDJTmPa2vYM/gJiKJnPIbH7abA
         Al1g==
X-Gm-Message-State: APjAAAWpyAmFuMLN0iLOJqCOlclklftOl/obNuPKdo5xDz+UJz3GkWKJ
	fRVCW9LRFtePYWkLE8fO7n7JPWGESn/mD6sXeEKhhDytw5S5i2BxWOBoKV2TShnAEm3rmNEB8+L
	cieAQp/RL+6cA8AUSY0rbD/gwMD/2+VLHsWYeCMbvdZVnRZQ6nr5JWR+TX2lZ1caWSQ==
X-Received: by 2002:a62:f20e:: with SMTP id m14mr4284818pfh.228.1554362560244;
        Thu, 04 Apr 2019 00:22:40 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw0h5ykv9V+HDXUAjSChZdKanMRa+AtJQ/pC0l4kfVBtFy1B+D7Cj7/LDqeBvNvrHfOIdlv
X-Received: by 2002:a62:f20e:: with SMTP id m14mr4284776pfh.228.1554362559493;
        Thu, 04 Apr 2019 00:22:39 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554362559; cv=none;
        d=google.com; s=arc-20160816;
        b=UGJY6ZKpwBgacyoFDF+P1awLIBalKqKFjGZD9Mp7fd6ToOPwNVCxwnV4q3OlGNj3Jr
         TGKx3dbJN/BecfXn3tG/KPaCFS/O78zt0OXpfHfYxtv1LORNOO76w2a/EjiMMrWGg6Gn
         jQRyCCu+hWuzVF5mJGq2ZxH+5Hg6Dj3uD7vko0AdjcUwelnpGksXCuHNArB38uTtJ6dr
         9A6WaI0WPqf8nVnrsIa5HFOoPixZgje3UC28noAyhBAMkpqW+C0MoYl+OEkTp+aXfgjx
         kva3gSAe21OicvBHjvSe6dpKwThvZXMQvoo4KwCoKbYhUgZvjBUI9dMJYwT8hQNlcbrW
         Mv2g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=NuCj5JtYrNzGsmbwn0QA8u7nztnxy+OdMzQXQhCdVuU=;
        b=B6BlXf5P/mj1pKdKVJyoSM1kwveoQhmV+PlCopRghKom2bq/9kSgMDzOERk2YtWA2P
         s50qdyI4Ext2ZSE4GJD3irfNF7zxQlDFB5OA3z3eAXT7g8Mjfa84ngCIer1QvYgQ+5kj
         ImFQ8ifIK0EX16oB1XqTAiepV0zyb/Ee/oHuk9Y46StstU682GqDVlTSkLntQodxG2Ti
         nuIxu+Hbl7PBxM14u453xAMAdl8uNWtQmX9+T0O0rrXJZqJ/IeFKK4Wq7uYLY3+HI4yv
         RWYAEbMRq8rW82tWFUx+lrpfLfaR9RqIT0g0wfwFLnRYNqY8ZJr3rkjfh+iCALvJEyRB
         h9AA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=tMrbVWBf;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=peterz@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id 11si16174256plb.330.2019.04.04.00.22.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 04 Apr 2019 00:22:39 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=tMrbVWBf;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=peterz@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=NuCj5JtYrNzGsmbwn0QA8u7nztnxy+OdMzQXQhCdVuU=; b=tMrbVWBfYpeidpZ56M3JSwTkO
	/tC1iVhz71qN+2Z90sXFcosCDlVOb/HXqhsSMoH7W6B0Cxz2jvOaAsOKXk9ZTk7uyk5fbjSDlyZru
	Tv7GeCWcfPZPffvTKBYhijdY6QEtxlfyTfHEQn9wn+P88PUjsSfdJ5om03oKzERQsEmJibJuX4dlL
	GAwQ5GEdzGsWnncJD8gMXwZzIgxHVfO/HlFKilUdvcAkgcvMwAYHntzN9f5C2rTmYFiCeQVexm4jD
	r2gb22wZsqa0CU6taCvMi5fXXJUnKo/D8FCBCZt22XR92L61gPHPDAfG812UpgDkJNQ8B0k30zR9R
	dYdfHENOw==;
Received: from j217100.upc-j.chello.nl ([24.132.217.100] helo=hirez.programming.kicks-ass.net)
	by bombadil.infradead.org with esmtpsa (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hBwh8-0007U0-QV; Thu, 04 Apr 2019 07:21:55 +0000
Received: by hirez.programming.kicks-ass.net (Postfix, from userid 1000)
	id EE10A2022A093; Thu,  4 Apr 2019 09:21:52 +0200 (CEST)
Date: Thu, 4 Apr 2019 09:21:52 +0200
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
Message-ID: <20190404072152.GN4038@hirez.programming.kicks-ass.net>
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

On Wed, Apr 03, 2019 at 11:34:04AM -0600, Khalid Aziz wrote:
> diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
> index 2c471a2c43fa..d17d33f36a01 100644
> --- a/include/linux/mm_types.h
> +++ b/include/linux/mm_types.h
> @@ -204,6 +204,14 @@ struct page {
>  #ifdef LAST_CPUPID_NOT_IN_PAGE_FLAGS
>  	int _last_cpupid;
>  #endif
> +
> +#ifdef CONFIG_XPFO
> +	/* Counts the number of times this page has been kmapped. */
> +	atomic_t xpfo_mapcount;
> +
> +	/* Serialize kmap/kunmap of this page */
> +	spinlock_t xpfo_lock;

NAK, see ALLOC_SPLIT_PTLOCKS

spinlock_t can be _huge_ (CONFIG_PROVE_LOCKING=y), also are you _really_
sure you want spinlock_t and not raw_spinlock_t ? For
CONFIG_PREEMPT_FULL spinlock_t turns into a rtmutex.

> +#endif

Growing the page-frame by 8 bytes (in the good case) is really sad,
that's a _lot_ of memory.

>  } _struct_page_alignment;

