Return-Path: <SRS0=VMr4=QW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DAAF5C4360F
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 17:34:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 70650222BE
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 17:34:26 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 70650222BE
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0AFA28E0005; Fri, 15 Feb 2019 12:34:26 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 061328E0001; Fri, 15 Feb 2019 12:34:26 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E1CDA8E0005; Fri, 15 Feb 2019 12:34:25 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 9928F8E0001
	for <linux-mm@kvack.org>; Fri, 15 Feb 2019 12:34:25 -0500 (EST)
Received: by mail-pl1-f197.google.com with SMTP id 38so4901695pld.6
        for <linux-mm@kvack.org>; Fri, 15 Feb 2019 09:34:25 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to
         :references:from:openpgp:autocrypt:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=k0KYmEVYb9yqepM+o/0h383e8SyRMTVWb12ii8b/R9U=;
        b=J/fLnqBbJHFH3PdhMMNSfHVuZfIvOCPgynVUYcc568vQaOB4mt5IBQQ6gUjW8DQliH
         CqYbnpi+BmxWPS2J8l/gWb6uxDNPy/8KgdjRcCmtNIH3Ghgllrvuy9ZzgeRGnXDMxpv3
         D6girRUUdctEraJtpTrEqV88OwHyOXlqJRYUj8WIC8VJAuzZ11nmQ+V6kngLyJm/Esly
         7JVbA0DTfdw5Svsv6x7acjSOucPkXzGBmFCW8vx8rt7zmlUobyM/UMvhww3PQU47hPbU
         Gs1rFKhrD+wpVi4xd1I6KwMYLNpWNus9oSSFfNjFC645hyC2g2Ildwaee0A08rGo6FCa
         h9Mw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dave.hansen@intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AHQUAuZTy/OgYtkyZ96EwZFarWq0q4rJhCrrwf/ujGZ8pA60XnggkmLQ
	WDm7BOyv2hifoWeFViv1cBN0JfDCLwaFBRywxzFVrQLA9qnZ6AOfUeXHtuhBbjESSEuwh+QEjLY
	5IAIYtPlwM9N+ZNhpKTvWJ8jnTzjWUrQiqTeWGDdbATyVL0BgC6uV7HfZ9Hh5/s83qg==
X-Received: by 2002:a65:490e:: with SMTP id p14mr6420977pgs.373.1550252065262;
        Fri, 15 Feb 2019 09:34:25 -0800 (PST)
X-Google-Smtp-Source: AHgI3Ia71RS8WE05EqjT0CoiyoPPLeDy1yAHktuDndzRf4TZ97o9pHWOLxJm7gdEVsxYkti9ZWiw
X-Received: by 2002:a65:490e:: with SMTP id p14mr6420909pgs.373.1550252064328;
        Fri, 15 Feb 2019 09:34:24 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550252064; cv=none;
        d=google.com; s=arc-20160816;
        b=myAoxDbi53LIJhEmgjKncRyUEEt6NcCWa0K/k6pmuk9w2Y6rMrgSCLCMhFZklLCEaq
         y3bJsBPJAv1m/v1mnv8xA/XMNjLrHPQaaZm585na6oK+MoaHqOmKvRAacUnna3cL/AUw
         r3Sb0M/FaoFeT+vc0Vn1FUPpjE9I33ZseV5T7RPYHrvTOG0COycnz+nODtXnAk+N7Jo3
         Fbg7ZtxWhmbQIrf30TqKcJnACqZ/ltEoF/rXIh9w3A+r7dzx880yMy/VUG3vU+iO64n2
         tb0ye+A4tTOQFmyhggab+I1mVoEdS/sNQ7sVE1FP9wlsTqkpgoqwkaC1iPIehZmNBHky
         uHjw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:autocrypt:openpgp:from:references:to
         :subject;
        bh=k0KYmEVYb9yqepM+o/0h383e8SyRMTVWb12ii8b/R9U=;
        b=JHDCb88WhQPuHcHcgyv6Lq8JBg9dVs28LI3Au/le//6UCC4LxXLkb8s3zCuNgjPu58
         emAbpKEdtsmQdfHQCy0et+e9K4NPvgV67Zfh13okx3vwf76oVfjsgyuLjzmuJmtnLHNP
         nmXP7vqKlqHc/ZmUl5j4cGjBjB/dZV1uvrtJUZPWLm9L6g1bWpmcmgePxeINpIoSqIRu
         ieOpMpEdLIlGOaq09H/TEzgDC8ld85DgEgxZwBi6yC59Nnsgf2w6d+f0UPPVwq7j9eoF
         aZ1KPdAfFaX79YvF951MFoy5OINiMzHcOtbRZprSjRAV10eJaWO5lcynIV5yxdVAcwLj
         YrpA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dave.hansen@intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id n9si5785401pge.470.2019.02.15.09.34.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Feb 2019 09:34:24 -0800 (PST)
Received-SPF: pass (google.com: domain of dave.hansen@intel.com designates 134.134.136.100 as permitted sender) client-ip=134.134.136.100;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dave.hansen@intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga001.jf.intel.com ([10.7.209.18])
  by orsmga105.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 15 Feb 2019 09:34:23 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.58,373,1544515200"; 
   d="scan'208";a="138950984"
Received: from ray.jf.intel.com (HELO [10.7.201.17]) ([10.7.201.17])
  by orsmga001.jf.intel.com with ESMTP; 15 Feb 2019 09:34:23 -0800
Subject: Re: [PATCH v3] hugetlb: allow to free gigantic pages regardless of
 the configuration
To: Alexandre Ghiti <alex@ghiti.fr>, Vlastimil Babka <vbabka@suse.cz>,
 Catalin Marinas <catalin.marinas@arm.com>, Will Deacon
 <will.deacon@arm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>,
 Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>,
 Martin Schwidefsky <schwidefsky@de.ibm.com>,
 Heiko Carstens <heiko.carstens@de.ibm.com>,
 Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>,
 Borislav Petkov <bp@alien8.de>, "H . Peter Anvin" <hpa@zytor.com>,
 x86@kernel.org, Dave Hansen <dave.hansen@linux.intel.com>,
 Andy Lutomirski <luto@kernel.org>, Peter Zijlstra <peterz@infradead.org>,
 Alexander Viro <viro@zeniv.linux.org.uk>,
 Mike Kravetz <mike.kravetz@oracle.com>,
 linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
 linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org,
 linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
References: <20190214193100.3529-1-alex@ghiti.fr>
From: Dave Hansen <dave.hansen@intel.com>
Openpgp: preference=signencrypt
Autocrypt: addr=dave.hansen@intel.com; keydata=
 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
Message-ID: <c6d9be5f-3b3a-c95b-0045-9f98ea52a5c4@intel.com>
Date: Fri, 15 Feb 2019 09:34:24 -0800
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <20190214193100.3529-1-alex@ghiti.fr>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

> -#if (defined(CONFIG_MEMORY_ISOLATION) && defined(CONFIG_COMPACTION)) || defined(CONFIG_CMA)
> +#ifdef CONFIG_CONTIG_ALLOC
>  /* The below functions must be run on a range from a single zone. */
>  extern int alloc_contig_range(unsigned long start, unsigned long end,
>  			      unsigned migratetype, gfp_t gfp_mask);
> -extern void free_contig_range(unsigned long pfn, unsigned nr_pages);
>  #endif
> +extern void free_contig_range(unsigned long pfn, unsigned int nr_pages);

There's a lot of stuff going on in this patch.  Adding/removing config
options.  Please get rid of these superfluous changes or at least break
them out.

>  #ifdef CONFIG_CMA
>  /* CMA stuff */
> diff --git a/mm/Kconfig b/mm/Kconfig
> index 25c71eb8a7db..138a8df9b813 100644
> --- a/mm/Kconfig
> +++ b/mm/Kconfig
> @@ -252,12 +252,17 @@ config MIGRATION
>  	  pages as migration can relocate pages to satisfy a huge page
>  	  allocation instead of reclaiming.
>  
> +
>  config ARCH_ENABLE_HUGEPAGE_MIGRATION
>  	bool

Like this. :)

>  config ARCH_ENABLE_THP_MIGRATION
>  	bool
>  
> +config CONTIG_ALLOC
> +	def_bool y
> +	depends on (MEMORY_ISOLATION && COMPACTION) || CMA
> +
>  config PHYS_ADDR_T_64BIT
>  	def_bool 64BIT

Please think carefully though the Kconfig dependencies.  'select' is
*not* the same as 'depends on'.

This replaces a bunch of arch-specific "select ARCH_HAS_GIGANTIC_PAGE"
with a 'depends on'.  I *think* that ends up being OK, but it absolutely
needs to be addressed in the changelog about why *you* think it is OK
and why it doesn't change the functionality of any of the patched
architetures.

> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index afef61656c1e..e686c92212e9 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -1035,7 +1035,6 @@ static int hstate_next_node_to_free(struct hstate *h, nodemask_t *nodes_allowed)
>  		((node = hstate_next_node_to_free(hs, mask)) || 1);	\
>  		nr_nodes--)
>  
> -#ifdef CONFIG_ARCH_HAS_GIGANTIC_PAGE
>  static void destroy_compound_gigantic_page(struct page *page,
>  					unsigned int order)
>  {

Whats the result of this #ifdef removal?  A universally larger kernel
even for architectures that do not support runtime gigantic page
alloc/free?  That doesn't seem like a good thing.

> @@ -1058,6 +1057,12 @@ static void free_gigantic_page(struct page *page, unsigned int order)
>  	free_contig_range(page_to_pfn(page), 1 << order);
>  }
>  
> +static inline bool gigantic_page_runtime_allocation_supported(void)
> +{
> +	return IS_ENABLED(CONFIG_CONTIG_ALLOC);
> +}

Why bother having this function?  Why don't the callers just check the
config option directly?

> +#ifdef CONFIG_CONTIG_ALLOC
>  static int __alloc_gigantic_page(unsigned long start_pfn,
>  				unsigned long nr_pages, gfp_t gfp_mask)
>  {
> @@ -1143,22 +1148,15 @@ static struct page *alloc_gigantic_page(struct hstate *h, gfp_t gfp_mask,
>  static void prep_new_huge_page(struct hstate *h, struct page *page, int nid);
>  static void prep_compound_gigantic_page(struct page *page, unsigned int order);
>  
> -#else /* !CONFIG_ARCH_HAS_GIGANTIC_PAGE */
> -static inline bool gigantic_page_supported(void) { return false; }
> +#else /* !CONFIG_CONTIG_ALLOC */
>  static struct page *alloc_gigantic_page(struct hstate *h, gfp_t gfp_mask,
>  		int nid, nodemask_t *nodemask) { return NULL; }
> -static inline void free_gigantic_page(struct page *page, unsigned int order) { }
> -static inline void destroy_compound_gigantic_page(struct page *page,
> -						unsigned int order) { }
>  #endif
>  
>  static void update_and_free_page(struct hstate *h, struct page *page)
>  {
>  	int i;
>  
> -	if (hstate_is_gigantic(h) && !gigantic_page_supported())
> -		return;

I don't get the point of removing this check.  Logically, this reads as
checking if the architecture supports gigantic hstates and has nothing
to do with allocation.

>  	h->nr_huge_pages--;
>  	h->nr_huge_pages_node[page_to_nid(page)]--;
>  	for (i = 0; i < pages_per_huge_page(h); i++) {
> @@ -2276,13 +2274,20 @@ static int adjust_pool_surplus(struct hstate *h, nodemask_t *nodes_allowed,
>  }
>  
>  #define persistent_huge_pages(h) (h->nr_huge_pages - h->surplus_huge_pages)
> -static unsigned long set_max_huge_pages(struct hstate *h, unsigned long count,
> +static int set_max_huge_pages(struct hstate *h, unsigned long count,
>  						nodemask_t *nodes_allowed)
>  {
>  	unsigned long min_count, ret;
>  
> -	if (hstate_is_gigantic(h) && !gigantic_page_supported())
> -		return h->max_huge_pages;
> +	if (hstate_is_gigantic(h) &&
> +		!gigantic_page_runtime_allocation_supported()) {

The indentation here is wrong and reduces readability.  Needs to be like
this:

	if (hstate_is_gigantic(h) &&
	    !gigantic_page_runtime_allocation_supported()) {

> +		spin_lock(&hugetlb_lock);
> +		if (count > persistent_huge_pages(h)) {
> +			spin_unlock(&hugetlb_lock);
> +			return -EINVAL;
> +		}
> +		goto decrease_pool;
> +	}

Needs comments.

	/* Gigantic pages can be freed but not allocated */

or something.

