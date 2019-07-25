Return-Path: <SRS0=Q21e=VW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.0 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6ACC0C7618B
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 11:44:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2BBD2229F9
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 11:44:12 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="FY1NJT9V"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2BBD2229F9
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C91FB8E006A; Thu, 25 Jul 2019 07:44:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C42998E0059; Thu, 25 Jul 2019 07:44:11 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B33058E006A; Thu, 25 Jul 2019 07:44:11 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 7F61C8E0059
	for <linux-mm@kvack.org>; Thu, 25 Jul 2019 07:44:11 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id y9so26161048plp.12
        for <linux-mm@kvack.org>; Thu, 25 Jul 2019 04:44:11 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=i19VkmUA/JjV1baDqjaCUFBUl3HEhx06QA8y1Sjqx2Y=;
        b=hqsV2rBtoZTdB3coWFjXhToLVTrQYgtFpSoaP3rT7dqqhuqqvXkmUVZbn/oA5ucSOI
         NSPR7i3Fk03fR7MRNQV8sXDhAOeb7Ip6qhWMVgL9RUcbctw1hAGH461FmSbse5oDjqvg
         53hi8650nIgr5T8dKniBFJgmZDssasT1McoAJM1PIgNtWUQkwztn+RInLRbyZY+KhYFN
         EQm6XyWgP5a3V6fgfwHUu4xD+Tcq56/V+oBkCf2qmRe3vUFhf6udoXDobfacROjKvdaC
         +6FhsbmTgx6b455Vxm6FJ937DfqCEEbk8WpC6H7/t73nGFOVae+m3D+hDIH1WKkCiAc7
         DJOg==
X-Gm-Message-State: APjAAAV+Af/YG5yyPxr8lqLaVkEHvP0uNj+uao23OO5q4SxXtff2AsXI
	TDVgmI8mmC/dHejcRMiItKGpdk8N/oKXbKu0VsiFixevrTL2qO/vXhlp5GFtVIjHeULrer0In5m
	XbwKld6w6b9tuZGEGYRUKBecR1GPdxPREpMt1KssQlvHVJqdZm3tnxUPCX0L/FRvphQ==
X-Received: by 2002:a63:2006:: with SMTP id g6mr84575125pgg.287.1564055051114;
        Thu, 25 Jul 2019 04:44:11 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxA0k2cL3aUByfWAi+At+pXRjVb5KqVHRYhl1+ZKQ4nDma9q4bT+eAIHqqC/NmRAI7duTqP
X-Received: by 2002:a63:2006:: with SMTP id g6mr84575082pgg.287.1564055050439;
        Thu, 25 Jul 2019 04:44:10 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564055050; cv=none;
        d=google.com; s=arc-20160816;
        b=OmIqIibTNSoVv6KvD/eapkeD2+YNacI0AmseDZsl0eB5VPYTUFlzPWdvDjgoV1U9OS
         VyPx0oKf5iZYh/Sal3gFNiMpbufSA8HfZortOK3SZhoFwmGxBawLcJN1JB/uV4dPChnR
         g0dpp4SP9zpq5W79MNFq4jplIo7G/4cp47uXZpQnHE8CV1ZmrzVDWCUsgipd5WPKsBrX
         No4/DXPjbTlGrkt7KxgxVAwuUQCHIgW82GFGF+BNBsOjkz9HNEaIRwXY5FYBIsIpP6wv
         FQMKcCSDsL1oDqnuzeIgXTDQ6dxHnfCb4BsD1uEY9LwXpuExNSpz/zNHshnDP0IeSD00
         U8VQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=i19VkmUA/JjV1baDqjaCUFBUl3HEhx06QA8y1Sjqx2Y=;
        b=y7yXQKwnIlY4fXB9QFvSNlCz76vhQj+YPWHoLQOORK4EtkaV6MrJy6K/c5JF7hL6Te
         b7l9MvhIUncffMVg2R2iSIYmcodDPowrzzCW122A5p0TigfPRsY4ZfXv/TmkkeOrA12i
         7NFFUetOKcS1cCHUd+T02SanZ7NK1QWJn4pR1T0Ni9RVAhqunNIoybDJNNSJGbud+ISO
         b3tVlYNOp4MTYxoTj1AwdH0OqZ9Yr6oHBE86HojWMR+Ghpg4sNnNLZk35H/0CoC6fdXV
         V415DyHqJ2sJq/G4PUrs9NbCjdOXDxcAPlCaNyZ3Q2norfkmUhN/foV8hQLB++HybhPm
         5U7Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=FY1NJT9V;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id q42si16606405pjc.103.2019.07.25.04.44.10
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Thu, 25 Jul 2019 04:44:10 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=FY1NJT9V;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=i19VkmUA/JjV1baDqjaCUFBUl3HEhx06QA8y1Sjqx2Y=; b=FY1NJT9VDEPZNIxz3Cx6zp8eE
	AkhT6C4nMXH4+xI8bgTRfVlXBfYv/c4iwNpHN7E14TH/fPjMP23dDVpoW5UoQPGUloknxIVUUiKf/
	5fAhay9ppAQSPw3QccU0LY31rX1wQtRKb3rscJqLglpgxytDWRZBWANdnLWRFwdLLt5Jwe778enkK
	UB5erxDzKrkcWYDPYUpcOZxRq5z90AuZZk4n7oaw7YuwZyvaX+SXFbpbrf1ORsKcJORe0F1sXNt1q
	OWuhktmc6pQaocLPV9QXGyClV2YzweTCDwCV+dV/bN/4ENX6+kOaEK37+gLGnLUzTjCIJ/IwcDaco
	lUlZavJuQ==;
Received: from willy by bombadil.infradead.org with local (Exim 4.92 #3 (Red Hat Linux))
	id 1hqcAK-0000R5-94; Thu, 25 Jul 2019 11:44:08 +0000
Date: Thu, 25 Jul 2019 04:44:08 -0700
From: Matthew Wilcox <willy@infradead.org>
To: "Huang, Ying" <ying.huang@intel.com>
Cc: Mikhail Gavrilov <mikhail.v.gavrilov@gmail.com>,
	huang ying <huang.ying.caritas@gmail.com>,
	Linux List Kernel Mailing <linux-kernel@vger.kernel.org>,
	linux-mm@kvack.org
Subject: Re: kernel BUG at mm/swap_state.c:170!
Message-ID: <20190725114408.GV363@bombadil.infradead.org>
References: <CABXGCsN9mYmBD-4GaaeW_NrDu+FDXLzr_6x+XNxfmFV6QkYCDg@mail.gmail.com>
 <CAC=cRTMz5S636Wfqdn3UGbzwzJ+v_M46_juSfoouRLS1H62orQ@mail.gmail.com>
 <CABXGCsOo-4CJicvTQm4jF4iDSqM8ic+0+HEEqP+632KfCntU+w@mail.gmail.com>
 <878ssqbj56.fsf@yhuang-dev.intel.com>
 <CABXGCsOhimxC17j=jApoty-o1roRhKYoe+oiqDZ3c1s2r3QxFw@mail.gmail.com>
 <87zhl59w2t.fsf@yhuang-dev.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87zhl59w2t.fsf@yhuang-dev.intel.com>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jul 23, 2019 at 01:08:42PM +0800, Huang, Ying wrote:
> @@ -2489,6 +2491,14 @@ static void __split_huge_page(struct page *page, struct list_head *list,
>  	/* complete memcg works before add pages to LRU */
>  	mem_cgroup_split_huge_fixup(head);
>  
> +	if (PageAnon(head) && PageSwapCache(head)) {
> +		swp_entry_t entry = { .val = page_private(head) };
> +
> +		offset = swp_offset(entry);
> +		swap_cache = swap_address_space(entry);
> +		xa_lock(&swap_cache->i_pages);
> +	}
> +
>  	for (i = HPAGE_PMD_NR - 1; i >= 1; i--) {
>  		__split_huge_page_tail(head, i, lruvec, list);
>  		/* Some pages can be beyond i_size: drop them from page cache */
> @@ -2501,6 +2511,9 @@ static void __split_huge_page(struct page *page, struct list_head *list,
>  		} else if (!PageAnon(page)) {
>  			__xa_store(&head->mapping->i_pages, head[i].index,
>  					head + i, 0);
> +		} else if (swap_cache) {
> +			__xa_store(&swap_cache->i_pages, offset + i,
> +				   head + i, 0);

I tried something along these lines (though I think I messed up the offset
calculation which is why it wasn't working for me).  My other concern
was with the case where SWAPFILE_CLUSTER was less than HPAGE_PMD_NR.
Don't we need to drop the lock and look up a new swap_cache if offset >=
SWAPFILE_CLUSTER?

