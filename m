Return-Path: <SRS0=KVn2=RQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_NEOMUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 76A82C10F03
	for <linux-mm@archiver.kernel.org>; Wed, 13 Mar 2019 07:52:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 393D12171F
	for <linux-mm@archiver.kernel.org>; Wed, 13 Mar 2019 07:52:20 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 393D12171F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C72188E0003; Wed, 13 Mar 2019 03:52:19 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BFA618E0002; Wed, 13 Mar 2019 03:52:19 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A9B238E0003; Wed, 13 Mar 2019 03:52:19 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 678618E0002
	for <linux-mm@kvack.org>; Wed, 13 Mar 2019 03:52:19 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id m25so525630edd.6
        for <linux-mm@kvack.org>; Wed, 13 Mar 2019 00:52:19 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=KFcarliCiA0glMe5rqP+hgAx0Yaz2aiCSLJQP4bA8v0=;
        b=TzLrkWqh/1Uhu8fmT3owhOaREoMCezCWvDgGc2sAA0bQwo4LXgDzy4tXzqCnlhhNod
         E4aMco9/s9YIUPalJ4xlhNHz/6WOhQSahYWtgWiGbXTK8mA0D44GocTB8MSp5aGiMmCR
         vuHXPbQGja4D6xBT+et8wezFJ/Co2wnSp4WT2n6oxraMJyfzOVUzYJSnglynLSScBc7l
         pl9mpGJvlv+itPyMNsp23cKM+YHgei/mndmafdMNWRMn+56m0vICIpbcmEOVNQ06XMFu
         UI8snxWI7g+fyoPynfr1qXlno6W5ZReCn+fgy5SkqrUjaQlKlime4LtxEqKhy7uxgPxi
         WNfQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.221.2 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Gm-Message-State: APjAAAUsDUOGZZmC1Vks2yPR4rrNmlCATgqsu4dGn+CpTbKtS//Ur1Fj
	LbKMkSgjo5n+pkT3+V+mbfczreNI7oNc3OmiDQBU7AkR22oO6dCXLWN7PhRAkzLSl+5ntVtT//a
	JKziXX+zXQL+/ALm683XumnIod/OFufiGzUTNEvjKMVIFkDB5yVOytb4JR9tde5pYQQ==
X-Received: by 2002:a17:906:4f15:: with SMTP id t21mr28582512eju.179.1552463538947;
        Wed, 13 Mar 2019 00:52:18 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxfRA/lvDgsKeIuEgQz28uMrW77CYcXq6EI1+Gq7T6Z/YI4aNF6NYCOycEcNZ9D5xXOnkhd
X-Received: by 2002:a17:906:4f15:: with SMTP id t21mr28582468eju.179.1552463537883;
        Wed, 13 Mar 2019 00:52:17 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552463537; cv=none;
        d=google.com; s=arc-20160816;
        b=U051xuwf8wQNM1Ruv1e38xGqg+X7zS/Nx4u0qMsc1GWH99QSEpuGY85XpDLdbc6RTT
         +SqC/s0U5p9HAXcRjOkATLdDuWEpfUGeIAxfXeS1awRU7abIij9eKFUE8THOEe3OaCeD
         iTA5t1aRGufTZt9cdu7FRIcv30Ldx/9QmpiBZ/0YVPKZoFtPXSZ7/Xz0/KswNP7P6NO7
         stzWV1eOvoAQMdFoSjzvEtzQYAcFHYQNfOHadJswD2Al3rbFSbSoYnoYNaO3n9XBLAal
         RwquWvTqV8G+yH3xrnq7Q2QtnqVnLQfudvM3rGAyIgpWNDOeGCEUSg5RbBmpDb8rdcbM
         k+GA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=KFcarliCiA0glMe5rqP+hgAx0Yaz2aiCSLJQP4bA8v0=;
        b=zPAGvk76SRrDX0zTa0k5m2dbIpSX7wyT+4+oeZ4o1dRXrKLIwujCAIeaF21rdBAt9J
         7JtYxUSuhqjHdk+rT4tGocNfLYjnfL1Ai9Eb0LxdRshv06b/QokSJr4NAzFmuu9BRCDM
         fKjmiIHt+/qbzYApBKE1QHAPBDjOC1myZVZpf/mFz6avpQGzx1DPnlya5YihyzTZqKot
         nLl52z4EpTlrqYn9L666rH+WkEiPs6UL23IhT7S1isxFIKVVF4NO/uZ3/SlsUEhEOjto
         QH7p6P2O6NWeS9y4L9Q0kg9WbBTOhge1IzymwY7gk/163wJ0L2di5bopdgDyENT6F7Ue
         69gQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.221.2 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: from suse.de (nat.nue.novell.com. [195.135.221.2])
        by mx.google.com with ESMTP id r43si287564eda.124.2019.03.13.00.52.17
        for <linux-mm@kvack.org>;
        Wed, 13 Mar 2019 00:52:17 -0700 (PDT)
Received-SPF: pass (google.com: domain of osalvador@suse.de designates 195.135.221.2 as permitted sender) client-ip=195.135.221.2;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.221.2 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: by suse.de (Postfix, from userid 1000)
	id AB5F84552; Wed, 13 Mar 2019 08:52:16 +0100 (CET)
Date: Wed, 13 Mar 2019 08:52:16 +0100
From: Oscar Salvador <osalvador@suse.de>
To: Qian Cai <cai@lca.pw>
Cc: akpm@linux-foundation.org, mhocko@kernel.org, vbabka@suse.cz,
	linux-mm@kvack.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH] mm/hotplug: fix offline undo_isolate_page_range()
Message-ID: <20190313075212.wc3pbwixx3ppwxua@d104.suse.de>
References: <20190313014216.36782-1-cai@lca.pw>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190313014216.36782-1-cai@lca.pw>
User-Agent: NeoMutt/20170421 (1.8.2)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.005248, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Mar 12, 2019 at 09:42:16PM -0400, Qian Cai wrote:
> +
> +	/*
> +	 * Onlining will reset pagetype flags and makes migrate type
> +	 * MOVABLE, so just need to decrease the number of isolated
> +	 * pageblocks zone counter here.
> +	 */
> +	for (pfn = start_pfn; pfn < end_pfn; pfn += pageblock_nr_pages) {
> +		int i;
> +
> +		for (i = 0; i < pageblock_nr_pages; i++)
> +			if (pfn_valid_within(pfn + i)) {
> +				zone->nr_isolate_pageblock--;
> +				break;
> +			}
> +	}
> +

I do not really like this.

I first thought about saving the value before entering start_isolate_page_range,
but that could race with alloc_contig_range for instance.
So, why not make start_isolate_page_range to return the actual number of isolated
pageblocks?
Sure, that would mean to change a bit how we threat its return code, but
I think that it is pretty simple.
In that way, we would only have to substract the value start_isolate_page_range
gave us at the end of __offline__pages() to set nr_isolate_pageblock back to
its original value.

-- 
Oscar Salvador
SUSE L3

