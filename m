Return-Path: <SRS0=4n/l=R3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 64EBCC43381
	for <linux-mm@archiver.kernel.org>; Sun, 24 Mar 2019 03:04:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 13C2120685
	for <linux-mm@archiver.kernel.org>; Sun, 24 Mar 2019 03:04:26 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="CZqeXVHb"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 13C2120685
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A31D06B0003; Sat, 23 Mar 2019 23:04:26 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9E0156B0006; Sat, 23 Mar 2019 23:04:26 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 881156B0007; Sat, 23 Mar 2019 23:04:26 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 4D3416B0003
	for <linux-mm@kvack.org>; Sat, 23 Mar 2019 23:04:26 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id e12so1803330pgh.2
        for <linux-mm@kvack.org>; Sat, 23 Mar 2019 20:04:26 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=/nYri7AMMzG77zUKbzytXtxVcD1Sc5lF10BzHgnCiBA=;
        b=H9aorpGpIlYzCBUCUNqqGbPffKxpHsfQ+i9P2WvBia6273ibI/gXGbj6PHxC7RkJ7d
         u38b0mBpEz5XjK7jtjF3rNrdhniGGO/sSqj29ZO/+ZvGCYWklrbJ79JdPK/E7WoaI+/3
         UR/oOFkYk761/HqclHzQoEkYQ3BJEEqCpHP9tweWAth23uNgvBvAlM8AdJH8sY3vWwuZ
         3JgRVjw6oX5KItZLc3nfERk8zH0JMGZakQiVTnw98au/oXTiv2XXztb3+6Gzh6trkZ+B
         tXXghJzWYwCnjrrSzxeIDxbDHnejGPZmVEZjgKJiK8n3lQb+DmCzge31ZE/PzimGW2zF
         sJLg==
X-Gm-Message-State: APjAAAXa3mLAwZ48fez8l9SJZ4WpNImKYxXcz94D5NLalwOgmpLCMA2W
	Qk83esz3QlMJDiLjyvBYgUPr/Uq/iyoJxoPlgYn0tz41uV7YsbgiaaLQ/WqqlvraasDxv+RdsQN
	y6AwGs3vqE6WR3dS9Ntw6UyH4eqTp1gk80/hFD+9eIV44uD3YfiZQbJwpNpKX6myYyQ==
X-Received: by 2002:a17:902:7592:: with SMTP id j18mr17632255pll.300.1553396665932;
        Sat, 23 Mar 2019 20:04:25 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz1hTWdOG79ASyWI9WzOwe+TAi1lJdzV4Bm2tCGHE8MCZj0f+SUHv8LdD89zAxoeVIw7zD2
X-Received: by 2002:a17:902:7592:: with SMTP id j18mr17632212pll.300.1553396665205;
        Sat, 23 Mar 2019 20:04:25 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553396665; cv=none;
        d=google.com; s=arc-20160816;
        b=z2+iaIdOE/CmygV16UoMjvWaUoY/DF+j+hQHxku4i7EUcWooI5D8uIe+tKTxu9KuCh
         ejHPfEkZko8oPeU7tuqFfkGRNjsZRsqOiCDlhTlft9/wtjSGjXvSofZBEcP0pdnPWwj4
         GgHI0XQJKKEZuqXvMz3KoognrwOT1WFd8chK+qBTu55E2MCD1tRSetPGreS8Q+zaJyR1
         nVfWvB8CNrIwuSuDOULCfQ8XZKF57ljlDrLmrNC0KR8hc60AWGed/+W/pbdTmytUwD9D
         jHTrxcH8jTVbl1/ll88J12vN33DK6V/toEJE/q/eOD6W8+by/dxT02+7WQeRo0wzKZVc
         HUIg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=/nYri7AMMzG77zUKbzytXtxVcD1Sc5lF10BzHgnCiBA=;
        b=ghgApsRiE2B6fXWH4HYnEf858ZfQaop3wqSzNhJpv+yR/MZzgwC1pDGL9JznTLUfUs
         9YobWyEZa4PzamqNx4otoU/EfHozjp8PTLKHvsOJv7qo3S9im8yB/XEQod5mvcwy87zg
         cx2Riw240JfHOyOIZS6qoHPDVG3AbJXoEBKRY1EvqRDeUzNf8DUDVYlZJo1aROf5Mt3E
         IxG6mmwa6f6jP26XWTxHAHwQNMovOAAFRSw2vuB1iUNd19za4YfH/U9c97FU/7K3ylEy
         +QkGBb1ssXctMGMiUTX/aCFVxJWVP7aGZGYV78h829EAFSAwoW8aNveeqOK4I60Y5tk3
         MBAQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=CZqeXVHb;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id b4si10812007pls.231.2019.03.23.20.04.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sat, 23 Mar 2019 20:04:24 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=CZqeXVHb;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=/nYri7AMMzG77zUKbzytXtxVcD1Sc5lF10BzHgnCiBA=; b=CZqeXVHbWVM9dEMMM9fDJgtwW
	rpusNSvg5mFzxHjKf2Xak5fqM6BoDg5xTQ2wINfoonzVyjvR8SSG0IC9QWDP7UfO0Fbn/x81loVn9
	xVebavCLhnZ8qVJlKCilSdtHSyH1RH1ZhohIH6KWYJKyzUEAoMhhZsy5+Q4PCH424Y+bOO5LKt2Ez
	+O6yH1megjiNulmYOMv0C2RNjDZQ9kMpKmgAwJN5EoAIE8xLEeRZbhIYxkQ8nyAfy2Moc9RXGUZvU
	GY9fu/TFkRIfG+nQWb2VrSr9/zphKMDSQajjd8wdh1MS5hG2GgLuVTrttCI6gqpSUeJEzDCz+BNg+
	uUAZQf1YA==;
Received: from willy by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1h7tQs-0002rM-Rn; Sun, 24 Mar 2019 03:04:22 +0000
Date: Sat, 23 Mar 2019 20:04:22 -0700
From: Matthew Wilcox <willy@infradead.org>
To: Qian Cai <cai@lca.pw>
Cc: Huang Ying <ying.huang@intel.com>, linux-mm@kvack.org
Subject: Re: page cache: Store only head pages in i_pages
Message-ID: <20190324030422.GE10344@bombadil.infradead.org>
References: <1553285568.26196.24.camel@lca.pw>
 <20190323033852.GC10344@bombadil.infradead.org>
 <f26c4cce-5f71-5235-8980-86d8fcd69ce6@lca.pw>
 <20190324020614.GD10344@bombadil.infradead.org>
 <897cfdda-7686-3794-571a-ecb8b9f6101f@lca.pw>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <897cfdda-7686-3794-571a-ecb8b9f6101f@lca.pw>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, Mar 23, 2019 at 10:52:49PM -0400, Qian Cai wrote:
> On 3/23/19 10:06 PM, Matthew Wilcox wrote:
> > Thanks for testing.  Kirill suggests this would be a better fix:
> > 
> > diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
> > index 41858a3744b4..9718393ae45b 100644
> > --- a/include/linux/pagemap.h
> > +++ b/include/linux/pagemap.h
> > @@ -334,10 +334,12 @@ static inline struct page *grab_cache_page_nowait(struct address_space *mapping,
> >  
> >  static inline struct page *find_subpage(struct page *page, pgoff_t offset)
> >  {
> > +	unsigned long index = page_index(page);
> > +
> >  	VM_BUG_ON_PAGE(PageTail(page), page);
> > -	VM_BUG_ON_PAGE(page->index > offset, page);
> > -	VM_BUG_ON_PAGE(page->index + compound_nr(page) <= offset, page);
> > -	return page - page->index + offset;
> > +	VM_BUG_ON_PAGE(index > offset, page);
> > +	VM_BUG_ON_PAGE(index + compound_nr(page) <= offset, page);
> > +	return page - index + offset;
> >  }
> >  
> >  struct page *find_get_entry(struct address_space *mapping, pgoff_t offset);
> 
> This is not even compiled.
> 
> If "s/compound_nr/compound_order/", it failed to boot here,

Oh, sorry.  I have another patch in that tree.

-       VM_BUG_ON_PAGE(page->index + (1 << compound_order(page)) <= offset,
-                       page);
+       VM_BUG_ON_PAGE(page->index + compound_nr(page) <= offset, page);

The patch for you should have looked like this:

@@ -335,11 +335,12 @@ static inline struct page *grab_cache_page_nowait(struct address_space *mapping,
 
 static inline struct page *find_subpage(struct page *page, pgoff_t offset)
 {
+       unsigned long index = page_index(page);
+
        VM_BUG_ON_PAGE(PageTail(page), page);
-       VM_BUG_ON_PAGE(page->index > offset, page);
-       VM_BUG_ON_PAGE(page->index + (1 << compound_order(page)) <= offset,
-                       page);
-       return page - page->index + offset;
+       VM_BUG_ON_PAGE(index > offset, page);
+       VM_BUG_ON_PAGE(index + (1 << compound_order(page)) <= offset, page);
+       return page - index + offset;
 }


> [   56.915812] page dumped because: VM_BUG_ON_PAGE(index + compound_order(page)
> <= offset)

Yeah, you were missing the '1 <<' part.

