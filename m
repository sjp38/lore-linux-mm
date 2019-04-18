Return-Path: <SRS0=2ZuM=SU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 59051C10F0E
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 16:52:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1109D21479
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 16:52:23 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1109D21479
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A3B8B6B0007; Thu, 18 Apr 2019 12:52:23 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9EA676B0008; Thu, 18 Apr 2019 12:52:23 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8B1826B000A; Thu, 18 Apr 2019 12:52:23 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 552746B0007
	for <linux-mm@kvack.org>; Thu, 18 Apr 2019 12:52:23 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id h69so1721631pfd.21
        for <linux-mm@kvack.org>; Thu, 18 Apr 2019 09:52:23 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=9GpBzBJeWI514pchDnbYy8pCqa767wMZeQJ3zMAhRKw=;
        b=lsay1SiE/v3oTTC6P5nlfORohm8oxCgV+vQ3pJHf90xPyAe7hxUrGuLrJorvc3Zi+O
         P2pwZwsAhdNIp7+zD8qtA6MuGxql2fMSJ0JhXs+S7VvI06wIDLy0lVXAz4mDOBnk0lp7
         Ht3IQZ31X/rEULhq1EkhtVMOsddffOFiZCvpLdqyUCniuabBBzAATWOm2GLLSqA4XEak
         QANrGi/D77bjcCMfL0NjdW8wmiqZZ741JXml5ehGximH1CGq+yBhSNYqFFINy9f5JTMl
         ijh/0emH4DyIu+X7YVN2qPNUruQdeRuJoiJB2gWyBis91LAcdz1HfzbCyR5KHNAEt5xy
         w0JA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dave.hansen@intel.com designates 192.55.52.151 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAVjMFZRYvHRhGes1ohFasGP9eds2H0OW83CcGEbl6AnCBEyG36D
	dGabh8pKtjJpGDZxEend6v0FFgLLdEeW8Mt4/lyFIa3/N4gYwZn/kUEBHB8dEfDuMCdG4NWlVSe
	bj6KLk/IoKFRBZlE6aRF/11bb+hGAd/IkMUcWivoFBlay4eOo5QWU2GPye+0PSX2zyA==
X-Received: by 2002:a63:b64:: with SMTP id a36mr90633947pgl.58.1555606342823;
        Thu, 18 Apr 2019 09:52:22 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwyMajrbHUkuCGc/u/BRVRf2RttTI3/uVxNtyDWv1c5ejYyhBc9/vNglepaJ3oQ5tJAVU08
X-Received: by 2002:a63:b64:: with SMTP id a36mr90633904pgl.58.1555606342093;
        Thu, 18 Apr 2019 09:52:22 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555606342; cv=none;
        d=google.com; s=arc-20160816;
        b=qZKP6sUWU4RKHf4EpRg571e9cc6Gi8BQsqgNrvWxOCjbI1JV4+THSLUSiDoYV6Z1pX
         FsVX1X9TOgGMVJPquEXFRkdZu9cTfbjP7h+z1by7Q/F2EPqgwGHsyTtkQg/MZiuBxzjI
         shPRldj3SlNlN/U3t/EFjSWM27qg98E4cW7UJ5X36Y98RGteXLNpap5taFwk0S/D1IOW
         ceyTZMfRcj+ZXHHMMFUy5A7AyX9SYSroWBbx2xIp32w+czBx8ZNe2KfftHnL0g1Hq98k
         R7NXlEynUqaORS9tHGxcQA1neOPuTNUiUwhgjFsIrbJoQae0hPFdY9Tz7L0IWObcnC+6
         NZTg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:autocrypt:openpgp:from:references:cc:to
         :subject;
        bh=9GpBzBJeWI514pchDnbYy8pCqa767wMZeQJ3zMAhRKw=;
        b=WcYL9lFXm2g1/bp7k8FiXjoZ6gUkP1nWY/bY3sQg2BRdffXEjbOnU2KROpFtS0VWdn
         /3QBuHwX5jFW9juhPrY9FAYDgzlkBk2NPF5jwHNjs3zB7fC74a6+zJOyglZSH8Tfm+8d
         M0lQlI7AkX3rIZ+zPmpBlTr5Vzcb9m5t/JpNfOZPQ2STTntidGKyxFDAa+mnEbCh1vaD
         nUbiGEmvVEuGqgr3vu26ia1GMVolXjWXGkG5fDHD46XBlJYM3lCtR97zgprmqwjJYZhe
         bCEYDZwsw61YumrD/WIIsLADc18JLqt5Db1EDtiqPkIiTYQn5v66Fq0LwdFXhO01Q/KJ
         pV9A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dave.hansen@intel.com designates 192.55.52.151 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga17.intel.com (mga17.intel.com. [192.55.52.151])
        by mx.google.com with ESMTPS id h17si2741163pfj.38.2019.04.18.09.52.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Apr 2019 09:52:22 -0700 (PDT)
Received-SPF: pass (google.com: domain of dave.hansen@intel.com designates 192.55.52.151 as permitted sender) client-ip=192.55.52.151;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dave.hansen@intel.com designates 192.55.52.151 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga004.jf.intel.com ([10.7.209.38])
  by fmsmga107.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 18 Apr 2019 09:52:21 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.60,366,1549958400"; 
   d="scan'208";a="292660378"
Received: from ray.jf.intel.com (HELO [10.7.201.126]) ([10.7.201.126])
  by orsmga004.jf.intel.com with ESMTP; 18 Apr 2019 09:52:21 -0700
Subject: Re: [PATCH 2/3] gfp: mm: introduce __GFP_NOINIT
To: Alexander Potapenko <glider@google.com>, akpm@linux-foundation.org,
 cl@linux.com, dvyukov@google.com, keescook@chromium.org, labbott@redhat.com
Cc: linux-mm@kvack.org, linux-security-module@vger.kernel.org,
 kernel-hardening@lists.openwall.com
References: <20190418154208.131118-1-glider@google.com>
 <20190418154208.131118-3-glider@google.com>
From: Dave Hansen <dave.hansen@intel.com>
Openpgp: preference=signencrypt
Autocrypt: addr=dave.hansen@intel.com; keydata=
 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
Message-ID: <7bf6bd62-c8e0-df3d-8e98-70063f2d175a@intel.com>
Date: Thu, 18 Apr 2019 09:52:21 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <20190418154208.131118-3-glider@google.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 4/18/19 8:42 AM, Alexander Potapenko wrote:
> __GFP_NOINIT basically defeats the hardening against information leaks
> provided by the init_allocations feature, so one should use it with
> caution.

Even more than that, shouldn't we try to use it only in places where
there is a demonstrated benefit, like performance data?

> diff --git a/kernel/kexec_core.c b/kernel/kexec_core.c
> index be84f5f95c97..f9d1f1236cd0 100644
> --- a/kernel/kexec_core.c
> +++ b/kernel/kexec_core.c
> @@ -302,7 +302,7 @@ static struct page *kimage_alloc_pages(gfp_t gfp_mask, unsigned int order)
>  {
>  	struct page *pages;
>  
> -	pages = alloc_pages(gfp_mask & ~__GFP_ZERO, order);
> +	pages = alloc_pages((gfp_mask & ~__GFP_ZERO) | __GFP_NOINIT, order);
>  	if (pages) {
>  		unsigned int count, i;

While this is probably not super security-sensitive, it's also not
performance sensitive.

> diff --git a/mm/slab.c b/mm/slab.c
> index dcc5b73cf767..762cb0e7bcc1 100644
> --- a/mm/slab.c
> +++ b/mm/slab.c
> @@ -1393,7 +1393,7 @@ static struct page *kmem_getpages(struct kmem_cache *cachep, gfp_t flags,
>  	struct page *page;
>  	int nr_pages;
>  
> -	flags |= cachep->allocflags;
> +	flags |= (cachep->allocflags | __GFP_NOINIT);
>  
>  	page = __alloc_pages_node(nodeid, flags, cachep->gfporder);
>  	if (!page) {
> diff --git a/mm/slob.c b/mm/slob.c
> index 18981a71e962..867d2d68a693 100644
> --- a/mm/slob.c
> +++ b/mm/slob.c
> @@ -192,6 +192,7 @@ static void *slob_new_pages(gfp_t gfp, int order, int node)
>  {
>  	void *page;
>  
> +	gfp |= __GFP_NOINIT;
>  #ifdef CONFIG_NUMA
>  	if (node != NUMA_NO_NODE)
>  		page = __alloc_pages_node(node, gfp, order
> diff --git a/mm/slub.c b/mm/slub.c
> index e4efb6575510..a79b4cb768a2 100644
> --- a/mm/slub.c
> +++ b/mm/slub.c
> @@ -1493,6 +1493,7 @@ static inline struct page *alloc_slab_page(struct kmem_cache *s,
>  	struct page *page;
>  	unsigned int order = oo_order(oo);
>  
> +	flags |= __GFP_NOINIT;
>  	if (node == NUMA_NO_NODE)
>  		page = alloc_pages(flags, order);
>  	else
> 

These sl*b ones seem like a bad idea.  We already have rules that sl*b
allocations must be initialized by callers, and we have reasonably
frequent bugs where the rules are broken.

Setting __GFP_NOINIT might be reasonable to do, though, for slabs that
have a constructor.  We have much higher confidence that *those* are
going to get initialized properly.

