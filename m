Return-Path: <SRS0=RE7g=PQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5F61EC43612
	for <linux-mm@archiver.kernel.org>; Tue,  8 Jan 2019 22:17:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 245AF2064C
	for <linux-mm@archiver.kernel.org>; Tue,  8 Jan 2019 22:17:59 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 245AF2064C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A7B7B8E009D; Tue,  8 Jan 2019 17:17:58 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9DACB8E0038; Tue,  8 Jan 2019 17:17:58 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8533E8E009D; Tue,  8 Jan 2019 17:17:58 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 3DE1C8E0038
	for <linux-mm@kvack.org>; Tue,  8 Jan 2019 17:17:58 -0500 (EST)
Received: by mail-pl1-f197.google.com with SMTP id g12so2931496pll.22
        for <linux-mm@kvack.org>; Tue, 08 Jan 2019 14:17:58 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :subject:from:to:cc:date:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=nya6k/ExNhm2UnmmzGNAjz6VZm9G6zYsXPnUenZrDso=;
        b=OhzcEY+fhkU6Vjlwqbt4UgFD5ou5vvMl53yBj9za46j4q3CvpSTTpvFVqdYK1lEwBv
         lym336VV86CxQZc8+MXtKCq5+GWzEJCG8INJUXfjTX0yd3Js5l3lTmU02j4/62NJu7O8
         B7ilddCWNk3e5vAQm//zt08BgpnVKntV7ws7RvBBty02qLIw+erMYf7vHkd6NqXVpbox
         deQvFMmO56vdSw47So25/L+pHbcFl39XCfsqBzZweTE1Ia+9DW0YSTbYL2uGOpHR8zVd
         MmgCgduRDXr2I/eeCdc5KskQuUaJJ/Q5au+/bMoo439iwHK4+Rnbpn1kV7QPkSAG6iZT
         cFsw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of alexander.h.duyck@linux.intel.com designates 192.55.52.88 as permitted sender) smtp.mailfrom=alexander.h.duyck@linux.intel.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AJcUukecTxTUAq7h5c9Z/njUIJs32nzpiqc/8BhSJB16SMfufLUUUHD4
	3TJQzbag/yzQK6YQZeecxyewuhXFGoIUGrMuc/CcsF2orvBtLG5QFc51QWSKbDSe2W3DHY/c6DE
	d5/eYoCu3UXoDFjv2Yi4g1mFE+OJAtKgQGLr3zsQ5NrcS0pbUwfJJpLsMpRA5wfGwzw==
X-Received: by 2002:a62:7042:: with SMTP id l63mr3630844pfc.89.1546985877907;
        Tue, 08 Jan 2019 14:17:57 -0800 (PST)
X-Google-Smtp-Source: ALg8bN4m2jqRihm8ZVI6unwpGE1yMqqWq6pF6K1Nzw+8bBF5lgTHmWw5tC3rXKmKw7yxx2D4dnbl
X-Received: by 2002:a62:7042:: with SMTP id l63mr3630793pfc.89.1546985876986;
        Tue, 08 Jan 2019 14:17:56 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1546985876; cv=none;
        d=google.com; s=arc-20160816;
        b=pyjtnziwmgFlnMu6VrEyyclQhRCMkhGRs9ucwG/RA2ue6pUHVweGCzfwXjyMs41ASl
         HtzKEMzR/qfrpgxLY77gJT4Rrm2gNBOaUEqveLYPafcL3/c12XHzJ8PiaEQ7lpFKShTY
         8fe6V6me+NiZ7R0P0lOWF7D1WfKnqBsT2+CHSZ/F4SDk3NgvZHHrngn/Ur7ihOHCd6Sk
         2zAyfW/wgzx71zsQ6HNmJquXH14Xqud9CMXYcGy/6LKJxAhOeWG/mETiIbQhLPI3iAVz
         KCi/+xsVFodH6RM/BsHfCCkvyU4Agy7culU4Oxv7E9LlOhfc7Gsh8N7IzoeHzdPcH9C2
         Y3UA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to:date
         :cc:to:from:subject:message-id;
        bh=nya6k/ExNhm2UnmmzGNAjz6VZm9G6zYsXPnUenZrDso=;
        b=jkqK5qloszT2zI4ljFWc7hRUdmYSMNBnTnPbZ0/CAUFKClGuFtXGJh1q/QCExvPEiD
         /c0T9zKRNFMptftS/2ngXUpGN+HPmolAze5KLcBp3UyGwk8lzK/dfCNZ+D7XC7ObRqlC
         0ddO13/QEczs0tdtPV5bS/usGQaHBVfl7qCS6tw4iqfR48xOO9kd0UKOeWCnpB27qyjD
         uEGh9EgzDl+NJAcPTAHROA8sCuPUVve+lPdyvCuWieIYrqEbpf3tPtlFEBNWugN0Wh1C
         m2KPdzk5lydRr70kzllSbnx80IrnwgFASbzav+nexr209QaMoTbSX4otaJl8JNM7Htlg
         d5Kg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of alexander.h.duyck@linux.intel.com designates 192.55.52.88 as permitted sender) smtp.mailfrom=alexander.h.duyck@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id h17si12326482pgd.538.2019.01.08.14.17.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Jan 2019 14:17:56 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of alexander.h.duyck@linux.intel.com designates 192.55.52.88 as permitted sender) client-ip=192.55.52.88;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of alexander.h.duyck@linux.intel.com designates 192.55.52.88 as permitted sender) smtp.mailfrom=alexander.h.duyck@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga003.jf.intel.com ([10.7.209.27])
  by fmsmga101.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 08 Jan 2019 14:17:56 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.56,455,1539673200"; 
   d="scan'208";a="116556304"
Received: from ahduyck-desk1.jf.intel.com ([10.7.198.76])
  by orsmga003.jf.intel.com with ESMTP; 08 Jan 2019 14:17:56 -0800
Message-ID: <7c81c8bc741819e87e9a2a39a8b1b6d2f8d3423a.camel@linux.intel.com>
Subject: Re: [PATCH v7] mm/page_alloc.c: memory_hotplug: free pages as
 higher order
From: Alexander Duyck <alexander.h.duyck@linux.intel.com>
To: Arun KS <arunks@codeaurora.org>, arunks.linux@gmail.com, 
 akpm@linux-foundation.org, mhocko@kernel.org, vbabka@suse.cz,
 osalvador@suse.de,  linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: getarunks@gmail.com
Date: Tue, 08 Jan 2019 14:17:56 -0800
In-Reply-To: <1546578076-31716-1-git-send-email-arunks@codeaurora.org>
References: <1546578076-31716-1-git-send-email-arunks@codeaurora.org>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.28.5 (3.28.5-2.fc28) 
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190108221756.QJNbi4E-0mt8vSRoqyBytgAv9aZwZLtc5qlmU-RhKGs@z>

On Fri, 2019-01-04 at 10:31 +0530, Arun KS wrote:
> When freeing pages are done with higher order, time spent on coalescing
> pages by buddy allocator can be reduced.  With section size of 256MB, hot
> add latency of a single section shows improvement from 50-60 ms to less
> than 1 ms, hence improving the hot add latency by 60 times.  Modify
> external providers of online callback to align with the change.
> 
> Signed-off-by: Arun KS <arunks@codeaurora.org>
> Acked-by: Michal Hocko <mhocko@suse.com>
> Reviewed-by: Oscar Salvador <osalvador@suse.de>

Sorry, ended up encountering a couple more things that have me a bit
confused.

[...]

> diff --git a/drivers/hv/hv_balloon.c b/drivers/hv/hv_balloon.c
> index 5301fef..211f3fe 100644
> --- a/drivers/hv/hv_balloon.c
> +++ b/drivers/hv/hv_balloon.c
> @@ -771,7 +771,7 @@ static void hv_mem_hot_add(unsigned long start, unsigned long size,
>  	}
>  }
>  
> -static void hv_online_page(struct page *pg)
> +static int hv_online_page(struct page *pg, unsigned int order)
>  {
>  	struct hv_hotadd_state *has;
>  	unsigned long flags;
> @@ -783,10 +783,12 @@ static void hv_online_page(struct page *pg)
>  		if ((pfn < has->start_pfn) || (pfn >= has->end_pfn))
>  			continue;
>  
> -		hv_page_online_one(has, pg);
> +		hv_bring_pgs_online(has, pfn, (1UL << order));
>  		break;
>  	}
>  	spin_unlock_irqrestore(&dm_device.ha_lock, flags);
> +
> +	return 0;
>  }
>  
>  static int pfn_covered(unsigned long start_pfn, unsigned long pfn_cnt)

So the question I have is why was a return value added to these
functions? They were previously void types and now they are int. What
is the return value expected other than 0?

> diff --git a/drivers/xen/balloon.c b/drivers/xen/balloon.c
> index ceb5048..95f888f 100644
> --- a/drivers/xen/balloon.c
> +++ b/drivers/xen/balloon.c
> @@ -345,8 +345,8 @@ static enum bp_state reserve_additional_memory(void)
>  
>  	/*
>  	 * add_memory_resource() will call online_pages() which in its turn
> -	 * will call xen_online_page() callback causing deadlock if we don't
> -	 * release balloon_mutex here. Unlocking here is safe because the
> +	 * will call xen_bring_pgs_online() callback causing deadlock if we
> +	 * don't release balloon_mutex here. Unlocking here is safe because the
>  	 * callers drop the mutex before trying again.
>  	 */
>  	mutex_unlock(&balloon_mutex);
> @@ -369,15 +369,22 @@ static enum bp_state reserve_additional_memory(void)
>  	return BP_ECANCELED;
>  }
>  
> -static void xen_online_page(struct page *page)
> +static int xen_bring_pgs_online(struct page *pg, unsigned int order)

Why did we rename this function? I see it was added as a new function
in v3, however in v4 we ended up replacing it completely. So why not
just keep the same name and make it easier for us to identify that the
is the Xen version of the XXX_online_pages callback?

[...]

> +static int online_pages_blocks(unsigned long start, unsigned long nr_pages)
> +{
> +	unsigned long end = start + nr_pages;
> +	int order, ret, onlined_pages = 0;
> +
> +	while (start < end) {
> +		order = min(MAX_ORDER - 1,
> +			get_order(PFN_PHYS(end) - PFN_PHYS(start)));
> +
> +		ret = (*online_page_callback)(pfn_to_page(start), order);
> +		if (!ret)
> +			onlined_pages += (1UL << order);
> +		else if (ret > 0)
> +			onlined_pages += ret;
> +

So if the ret > 0 it is supposed to represent how many pages were
onlined within a given block? What if the ret was negative? Really I am
not a fan of adding a return value to the online functions unless we
specifically document what the expected return values are supposed to
be. If we don't have any return values other than 0 there isn't much
point in having one anyway.

