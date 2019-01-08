Return-Path: <SRS0=RE7g=PQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E8455C43612
	for <linux-mm@archiver.kernel.org>; Tue,  8 Jan 2019 18:40:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B46AB206B6
	for <linux-mm@archiver.kernel.org>; Tue,  8 Jan 2019 18:40:21 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B46AB206B6
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 43DE28E008B; Tue,  8 Jan 2019 13:40:21 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3C6988E0038; Tue,  8 Jan 2019 13:40:21 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 26A2C8E008B; Tue,  8 Jan 2019 13:40:21 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id D615A8E0038
	for <linux-mm@kvack.org>; Tue,  8 Jan 2019 13:40:20 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id b8so3339678pfe.10
        for <linux-mm@kvack.org>; Tue, 08 Jan 2019 10:40:20 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :subject:from:to:cc:date:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=P0jC4RE0YQqxTaHtWGJJArBJ9hZ0heUQ0oMl2IH3Qog=;
        b=mewoKYP/lt/3a9+MnjtZaH3vgn2OvBZW++Bkv1DeScTxaiHehkHY0gBsmJjvIu/+pz
         +ur2Fg4e8C4BQUL1ai4Q0WaU/8lLxUYOjNDN3taxqgGcWH3Un1JscHh3Zx5vJA+coz2r
         71VxgklHuZcF2Z2r9U1h69HSvM4t2HAi5Xw+CFeoNxiFysH+yS8ltiLVbUf2pMdZEcoy
         5Hl/OZGXj13z/nK4MPaAJjd/VcWo7KZX+Kc1w81fEnvTdQYnz97IKbuLVncK6omIJRJf
         ye+2EyPAMPQzQXoA+VAdyZ5/dWRx6rK0dF0OfEkOLyOaMQWHxdukJSVKmNySx617cjlS
         sWqA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of alexander.h.duyck@linux.intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=alexander.h.duyck@linux.intel.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AJcUuke1EvMqTPGj3wXyc7/iTMCPFLxcwAiz4GuOUPnmyCmSTPvh8ykH
	/ytHVwsZQDVOZ6TcIQ54gAKNIVapyMgd4PJA3MiA99as9ciffrYy1pDYSvAD2xucg3MYHhIlLEs
	D2ywln2YHunzd8lgG/zuSpfLljg0YX9gTAmGXQGyFhtlPfE09JzP6HCeyrRXekymaPw==
X-Received: by 2002:a17:902:654a:: with SMTP id d10mr2821540pln.324.1546972820527;
        Tue, 08 Jan 2019 10:40:20 -0800 (PST)
X-Google-Smtp-Source: ALg8bN5Svit/cWFXHIJIwx716Cd8f+OeGGu1WBZkY4kzNKH1JpyM6wCgwkf3az+p+X0niuYmwdNr
X-Received: by 2002:a17:902:654a:: with SMTP id d10mr2821502pln.324.1546972819583;
        Tue, 08 Jan 2019 10:40:19 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1546972819; cv=none;
        d=google.com; s=arc-20160816;
        b=nkZu8W8aADJZKzIJtHZsBy+3lemeWUr97K1CYISf2leDU/Qi5bP+O8odQu/gN5Wtd4
         qrnTGEO+R1x4gtViYSEm4VjI+Ng3PeVJ/EOC6BuevtALPdLBFONm5efIKflDOeXzTDC+
         mbEgeJBumA/TIYP2ri/yqN3uDmgtvX0Uawdlhcf+8mDEeUYrUKUZTr3SS8+MoVN6DZSa
         yi/Sk9ct4SBCVG6/9ltnyjHWw4nF7rXVQaoO0WX+dJaMNQg6NqXVsl9Fn7CyZ0u5daJy
         Vhq2Y4R8EyrYLGVrZqMI9tHeByOMccnrtakZUvj0fqxjrupm5wqoW31en6MDoibqcUXL
         N4Fg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to:date
         :cc:to:from:subject:message-id;
        bh=P0jC4RE0YQqxTaHtWGJJArBJ9hZ0heUQ0oMl2IH3Qog=;
        b=lrJ+ZOyyUwkqQj9TGJltnmhLojU57rcJ8ikLR0oR1bfOb0gWBFL30jNEuHU+oVeBB1
         mY5yuQgtat2tfkoGwHl5CjaJkDuOyNozaA4lmGo0WyagLYFXQtqmLtOp1+6NK1TTIe6n
         beK+SZpGSKYlf8bMdtG02O3q+lwDWcJhenbgAU+vs4qFhoet20o+yVx8OMf4a39st47/
         /PZTmWN+o8ZPwkWLivohixH05I5N/ozqTqbJMh6nuJc13CswYedBzzxZICkGfvScNAZo
         4YgYLCc6/MKXmaxdMemFhkiILK82UWWr8D+k7hp8iNfu0BFdVJkZFHvcrM4g7hnO+5fe
         biNQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of alexander.h.duyck@linux.intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=alexander.h.duyck@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id e13si9225907pfi.271.2019.01.08.10.40.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Jan 2019 10:40:19 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of alexander.h.duyck@linux.intel.com designates 134.134.136.20 as permitted sender) client-ip=134.134.136.20;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of alexander.h.duyck@linux.intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=alexander.h.duyck@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga004.jf.intel.com ([10.7.209.38])
  by orsmga101.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 08 Jan 2019 10:40:19 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.56,455,1539673200"; 
   d="scan'208";a="265497410"
Received: from ahduyck-desk1.jf.intel.com ([10.7.198.76])
  by orsmga004.jf.intel.com with ESMTP; 08 Jan 2019 10:40:18 -0800
Message-ID: <37498672d5b2345b1435477e78251282af42742b.camel@linux.intel.com>
Subject: Re: [PATCH v7] mm/page_alloc.c: memory_hotplug: free pages as
 higher order
From: Alexander Duyck <alexander.h.duyck@linux.intel.com>
To: Arun KS <arunks@codeaurora.org>, arunks.linux@gmail.com, 
 akpm@linux-foundation.org, mhocko@kernel.org, vbabka@suse.cz,
 osalvador@suse.de,  linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: getarunks@gmail.com
Date: Tue, 08 Jan 2019 10:40:18 -0800
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
Message-ID: <20190108184018.F6DZSoz7jteH0PjgdSHnksTmeB-cMDbiT_k9si-KMS0@z>

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

After running into my initial issue I actually had a few more questions
about this patch.

> [...]
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
> +		start += (1UL << order);
> +	}
> +	return onlined_pages;
>  }
>  

Should the limit for this really be MAX_ORDER - 1 or should it be
pageblock_order? In some cases this will be the same value, but I seem
to recall that for x86 MAX_ORDER can be several times larger than
pageblock_order.

>  static int online_pages_range(unsigned long start_pfn, unsigned long nr_pages,
>  			void *arg)
>  {
> -	unsigned long i;
>  	unsigned long onlined_pages = *(unsigned long *)arg;
> -	struct page *page;
>  
>  	if (PageReserved(pfn_to_page(start_pfn)))

I'm not sure we even really need this check. Getting back to the
discussion I have been having with Michal in regards to the need for
the DAX pages to not have the reserved bit cleared I was originally
wondering if we could replace this check with a call to
online_section_nr since the section shouldn't be online until we set
the bit below in online_mem_sections.

However after doing some further digging it looks like this could
probably be dropped entirely since we only call this function from
online_pages and that function is only called by memory_block_action if
pages_correctly_probed returns true. However pages_correctly_probed
should return false if any of the sections contained in the page range
is already online.

> -		for (i = 0; i < nr_pages; i++) {
> -			page = pfn_to_page(start_pfn + i);
> -			(*online_page_callback)(page);
> -			onlined_pages++;
> -		}
> +		onlined_pages = online_pages_blocks(start_pfn, nr_pages);
>  
>  	online_mem_sections(start_pfn, start_pfn + nr_pages);
>  

