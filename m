Return-Path: <SRS0=7ZCb=UD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 318A6C282CE
	for <linux-mm@archiver.kernel.org>; Tue,  4 Jun 2019 07:08:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A622F245C9
	for <linux-mm@archiver.kernel.org>; Tue,  4 Jun 2019 07:08:11 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="PhE+NmWc"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A622F245C9
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 28DF66B000A; Tue,  4 Jun 2019 03:08:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 23F1F6B000D; Tue,  4 Jun 2019 03:08:11 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1063A6B0266; Tue,  4 Jun 2019 03:08:11 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id CC7486B000A
	for <linux-mm@kvack.org>; Tue,  4 Jun 2019 03:08:10 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id g11so13388437plt.23
        for <linux-mm@kvack.org>; Tue, 04 Jun 2019 00:08:10 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=m/punIg9+myPZqcO5Fex4TzU8Z+bUAZ/ApxJa070rqw=;
        b=sIY7RtRLM3EX+AKkuojS0bIA0h7oOJKB8HZLZ8fUFjX/Hq8zZ8lf02RCqLkKxay40R
         Fu8J3Zgw4AFYqCEeFwnQesNBvtlvujKY0HzLEhg2YoGyoJ6tBI0BmelEpAVxuyc8OP7p
         jooATt8FhMmenEZN1HpdgQKgqFzD1WW9rCcotRaXCIIbBVc8RhRdFUzBsrOmNPiBljem
         nvP+kfMWwAtBRqljHbL2AQNMS89bMXIhVbaL/tQdvmVMT64lqh9oTOYlyHEEgwEcezw7
         Ay/qvKaJV1pBxs1ITtkmf11E3jX6AJkuJfzc+dZRmtqxqTRy7IrajHhPPzr6W476eCM0
         E/+w==
X-Gm-Message-State: APjAAAXQWLeN+TaYVpBTjytQ2pSoWqx29NDrxNXvt2q4frMC4wma4do1
	YPFSgtc6pFEysiFEwuN3NrEqucQm6DTatR6l9pjqoEe7sTP8zUBehioGTGPb9kYDvFNFhwBWLGm
	REmv0FUcdjonzBLMD0ugtmx/47oUlUg4pOETnIWQUsrk404quBqHTYiJ4eIWCILd5ig==
X-Received: by 2002:a17:902:b402:: with SMTP id x2mr35266956plr.128.1559632090481;
        Tue, 04 Jun 2019 00:08:10 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx3EHIXCh0CPO+I08ggGWBRORFoRvq2WaxHJxeCjQW37U02+5mUPEos45hwnspQFdLgmA0f
X-Received: by 2002:a17:902:b402:: with SMTP id x2mr35266900plr.128.1559632089720;
        Tue, 04 Jun 2019 00:08:09 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559632089; cv=none;
        d=google.com; s=arc-20160816;
        b=Ss9No8kuVJdpr9EvWi9ECGrFw4+HVtpA2ScyW0Od1u+JhKkjs3NyUJAnOQzSvghN/l
         Gjwv40sSXEyzlFKil+HpiJjCIj77QqVvqJljmYRpfFXa9v7UVUd1c+7UI57dgMsSW7EQ
         a0btCOYYb97AarVbIG1jamUpg8w7boJzVeVn8IKnx6rXl6aoJghYZcD7AbgTsGNwVMl4
         SVHshS59JdvNmek51C8pPeHpFUcni5ppV0By9wvMq5cyqd7pQupzjcUK68qlrAQtXzSL
         d2qwz01QfoOJ9vvrW68bqxhvvZRs5gPf5YPoBCqb/GRLHdlvzUOlv/OVFdL8xnk6HLoc
         wNyA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=m/punIg9+myPZqcO5Fex4TzU8Z+bUAZ/ApxJa070rqw=;
        b=bmnyDXi/Cca6Y2fZrgP+hTBURYFW7IWo3pD5+vOD2F0WSi5UA7vjfZvucCuLYxRtJp
         2JQ4j2I2xqvUW1cRUL+v1e4I7ScP37L3KwnrU2JRz/Tu/PC7K34zrwcf+k3Rl5rsrn6J
         aaqnZWOC2qHwx8LL/nrGkicD6l8CT2MzxzFv/ApFa7I8SEA1LdAipJN/UyizFh+sQkSN
         1tQ+LhN5SzB3+Ci691pTZ4zDR6OEPvDEXZ8OyfpyV9kTMr5RqRTgu6RO47YfB3VR6jgq
         +zIIdP/Vh92DJfuTjlSqGFVv5rUuLuIqSVfrHXkbW4PN1oMerBTvgi7OxJXmJYtRhuGi
         F7Tg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=PhE+NmWc;
       spf=pass (google.com: best guess record for domain of batv+8160fb773a6c716236a8+5763+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+8160fb773a6c716236a8+5763+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id y1si19945833pjr.109.2019.06.04.00.08.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 04 Jun 2019 00:08:09 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+8160fb773a6c716236a8+5763+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=PhE+NmWc;
       spf=pass (google.com: best guess record for domain of batv+8160fb773a6c716236a8+5763+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+8160fb773a6c716236a8+5763+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=m/punIg9+myPZqcO5Fex4TzU8Z+bUAZ/ApxJa070rqw=; b=PhE+NmWcH3ODsjbf5DgAK0rDR
	wNbT88AC4wWX+ZvyP5MM1KqyooYM0+mAkuIdGtabHS44vr1bAfF+mOtJyPthTKg+/syEbcFJyBQ+D
	vdlie6qPJkRzG+Nif1tIPr8FKNxoIgKFarWD5+HgSCI8eL9EpEd1969URTGDodzK0Vg9YxN6Dg7QU
	I1kZVZJSe2kjVSjBZt5VvJQJa8z6/2JIw+0EauSETmT3ODTqSj1eOnowCy7paNrTgZbjGe15oASWA
	pDcGtfUIgJqflfZtG65779lHUaUM7n3J7aSzRx1j3fTyF7KFC5P99GbYE/BvDYP7gnYfAk+D0GuSR
	juu0GR9+w==;
Received: from hch by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hY3YG-0000zz-I4; Tue, 04 Jun 2019 07:08:08 +0000
Date: Tue, 4 Jun 2019 00:08:08 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Ira Weiny <ira.weiny@intel.com>
Cc: Christoph Hellwig <hch@infradead.org>,
	Pingfan Liu <kernelfans@gmail.com>, linux-mm@kvack.org,
	Andrew Morton <akpm@linux-foundation.org>,
	Mike Rapoport <rppt@linux.ibm.com>,
	Dan Williams <dan.j.williams@intel.com>,
	Matthew Wilcox <willy@infradead.org>,
	John Hubbard <jhubbard@nvidia.com>,
	"Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>,
	Keith Busch <keith.busch@intel.com>, linux-kernel@vger.kernel.org
Subject: Re: [PATCHv2 1/2] mm/gup: fix omission of check on FOLL_LONGTERM in
 get_user_pages_fast()
Message-ID: <20190604070808.GA28858@infradead.org>
References: <1559543653-13185-1-git-send-email-kernelfans@gmail.com>
 <20190603164206.GB29719@infradead.org>
 <20190603235610.GB29018@iweiny-DESK2.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190603235610.GB29018@iweiny-DESK2.sc.intel.com>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jun 03, 2019 at 04:56:10PM -0700, Ira Weiny wrote:
> On Mon, Jun 03, 2019 at 09:42:06AM -0700, Christoph Hellwig wrote:
> > > +#if defined(CONFIG_CMA)
> > 
> > You can just use #ifdef here.
> > 
> > > +static inline int reject_cma_pages(int nr_pinned, unsigned int gup_flags,
> > > +	struct page **pages)
> > 
> > Please use two instead of one tab to indent the continuing line of
> > a function declaration.
> > 
> > > +{
> > > +	if (unlikely(gup_flags & FOLL_LONGTERM)) {
> > 
> > IMHO it would be a little nicer if we could move this into the caller.
> 
> FWIW we already had this discussion and thought it better to put this here.
> 
> https://lkml.org/lkml/2019/5/30/1565

I don't see any discussion like this.  FYI, this is what I mean,
code might be easier than words:


diff --git a/mm/gup.c b/mm/gup.c
index ddde097cf9e4..62d770b18e2c 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -2197,6 +2197,27 @@ static int __gup_longterm_unlocked(unsigned long start, int nr_pages,
 	return ret;
 }
 
+#ifdef CONFIG_CMA
+static int reject_cma_pages(struct page **pages, int nr_pinned)
+{
+	int i = 0;
+
+	for (i = 0; i < nr_pinned; i++)
+		if (is_migrate_cma_page(pages[i])) {
+			put_user_pages(pages + i, nr_pinned - i);
+			return i;
+		}
+	}
+
+	return nr_pinned;
+}
+#else
+static inline int reject_cma_pages(struct page **pages, int nr_pinned)
+{
+	return nr_pinned;
+}
+#endif /* CONFIG_CMA */
+
 /**
  * get_user_pages_fast() - pin user pages in memory
  * @start:	starting user address
@@ -2237,6 +2258,9 @@ int get_user_pages_fast(unsigned long start, int nr_pages,
 		ret = nr;
 	}
 
+	if (nr && unlikely(gup_flags & FOLL_LONGTERM))
+		nr = reject_cma_pages(pages, nr);
+
 	if (nr < nr_pages) {
 		/* Try to get the remaining pages with get_user_pages */
 		start += nr << PAGE_SHIFT;

