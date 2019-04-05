Return-Path: <SRS0=BJvi=SH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D8AF2C4360F
	for <linux-mm@archiver.kernel.org>; Fri,  5 Apr 2019 13:51:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8848C21738
	for <linux-mm@archiver.kernel.org>; Fri,  5 Apr 2019 13:51:59 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="Ioetmh/J"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8848C21738
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 137986B026E; Fri,  5 Apr 2019 09:51:59 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 10DD16B026F; Fri,  5 Apr 2019 09:51:59 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 024366B0270; Fri,  5 Apr 2019 09:51:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id C08DF6B026E
	for <linux-mm@kvack.org>; Fri,  5 Apr 2019 09:51:58 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id f7so4073718pgi.20
        for <linux-mm@kvack.org>; Fri, 05 Apr 2019 06:51:58 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=XY0rcBM7DfXdXLaiCQSB/Ch3HeGmn+6SsthdCa9yhTI=;
        b=LDrlDV/itegCb8Tpwzc3rnohtSZstZUv8kCpaEKxtYb5i47E6LsicjZ7hkax/uRuI4
         m3bVP6PYaqcJN5MGa9Xpa+pFXFh4lCePepePS4Etp8IkJBH1QP71CKw6SKnHiJCG35/x
         Exc2QPLKSwDGkWtA+Zf23XlzlsFOWa98mAp64A7V4Dhdx+VqUxiuFMy8mDp19lgenb+l
         SnSi+hnZ/UOkwafqRG9NkiWCo0+xGIIXjqpVXXUztOnEZRTvbItp1VfxD6NgWufzA44d
         vZddpt6uuo/8u9U2d0MJOXgxvMHsvF/UhLjnunEvWtc+Qs+u9RNhD09ZAQzR7yjdtSIQ
         3zMw==
X-Gm-Message-State: APjAAAWFt58jA3AvLkRq1QqXt+QhaYYDojwTFw8zGO0Uzaw1SWodihWm
	qvLU5ah2jIwBOAYAm9nBxidmRAkMZG/StgvqimIgDyLkMRIgOObToclOEjGITtOVx3Xi89wkRBj
	zx867V4tTWfbmasHL3hKzYtKdEwdRRrCoNGDQDAeeh2Y0HC+4Lx+1jzb2kt3O8eYsxA==
X-Received: by 2002:a17:902:8349:: with SMTP id z9mr12580363pln.144.1554472318171;
        Fri, 05 Apr 2019 06:51:58 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzC+mxPwJ7jTgclBK8jYLb64wTEgQu3WeBvmq17nby85+I8Y4VL2toT7d3pDg0EJfK46e58
X-Received: by 2002:a17:902:8349:: with SMTP id z9mr12580303pln.144.1554472317418;
        Fri, 05 Apr 2019 06:51:57 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554472317; cv=none;
        d=google.com; s=arc-20160816;
        b=lUKEkHWgcOi7pQqIJSHWQxsjRDxabEPTz4Rb/L+v+5kYT8KTUPGJd4tslu0fyJIfIq
         ftccrmmkgvoE/asxtqfH/9PDbeun4SF8R5qOhxylYzWBJcyU3i8clxHwjLhtdklfomu2
         AT2O7TSsJhpx7MiLZDGHaJVEwDRcLTLhvB6sU6DxToxy7R9OL+i2d3k4kDSVcQpxCUmu
         g4Tnl/ELjx7eNG207mT2ey60uslZWaoJgvOlxqHbwn/vVIe+7ZNP6A2SWFFquZrJAsps
         xfv2rFPwQmoEkRVlATpRGXijvxSSVHuK1vW2cgaz7NQh/ImEjrG7Q4x4yEmdInlXOpnE
         6ahA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date:dkim-signature;
        bh=XY0rcBM7DfXdXLaiCQSB/Ch3HeGmn+6SsthdCa9yhTI=;
        b=YctDN9b74ydd2uCWIormJ61cWwmeoh1SyQoG3r0A3q+xripQhmkbn1QHzNHt+YUiRl
         uqr549rS482xw628Mkrwh8tHIhHYVCkpBCM8BmFdUs0P1Bd2Ou317h2HQGavuUVkmd2A
         g+UR0nQocp7iPAWRsTcKDluG2JMGnohX91anCoAFGeIHW/TcFWN8eUCr4Ur52+70zhNX
         TIV+i9ejksSRAQyK18BQdfuT97QezkYMuAJXQ9yBh9eCyK+2CsMNtgPbad61ndfd25nZ
         wCBWHt9Wsv3tnwushWYzPQhAugsnO9F0cMGcP/SDWuVQGN+nZQ8aMszng+8+O+BscWzR
         nWtw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b="Ioetmh/J";
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id k15si18659454pll.142.2019.04.05.06.51.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 05 Apr 2019 06:51:57 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b="Ioetmh/J";
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Transfer-Encoding
	:Content-Type:MIME-Version:References:Message-ID:Subject:Cc:To:From:Date:
	Sender:Reply-To:Content-ID:Content-Description:Resent-Date:Resent-From:
	Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=XY0rcBM7DfXdXLaiCQSB/Ch3HeGmn+6SsthdCa9yhTI=; b=Ioetmh/JDU5xbCm+5YaXCT/PRr
	V9ivB2UTttkyia4RNl7sbmh6dEyNSnHlzthmLFkJ92EDG4CmpSL61jj+vUALVTbCZosk2tuUWFN+D
	RjH6jR+tSkIXUwx4Tsqby4p59AcMYlBUEHtd5gPLiK6JJqDtc2Z6QT2aTDJM73GqS7qgA6SbIOxjc
	PvXMxmKrCD7kTlbfgr2f8xgo+q0b+b0H4H81/9PEwB1vBxD3o6zbV95Hj+PHnWmvglgSk54GWLmhH
	AHIqNo6jBh2+E67wTqJ0PPx+qGKLM73fUpee3olaScZfygfB20g7WMjcA22mJwtNzqS28hpich8FT
	VEICNCjA==;
Received: from willy by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hCPG7-0005T0-JA; Fri, 05 Apr 2019 13:51:55 +0000
Date: Fri, 5 Apr 2019 06:51:55 -0700
From: Matthew Wilcox <willy@infradead.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>,
	Andrew Morton <akpm@linux-foundation.org>
Cc: Qian Cai <cai@lca.pw>, Huang Ying <ying.huang@intel.com>,
	linux-mm@kvack.org
Subject: Re: page cache: Store only head pages in i_pages
Message-ID: <20190405135155.GO22763@bombadil.infradead.org>
References: <1553894734.26196.30.camel@lca.pw>
 <20190330030431.GX10344@bombadil.infradead.org>
 <20190330141052.GZ10344@bombadil.infradead.org>
 <20190331032326.GA10344@bombadil.infradead.org>
 <20190401091858.s7clitbvf46nomjm@kshutemo-mobl1>
 <20190401092716.mxw32y4sl66ywc2o@kshutemo-mobl1>
 <1554383410.26196.39.camel@lca.pw>
 <20190404134553.vuvhgmghlkiw2hgl@kshutemo-mobl1>
 <1554413282.26196.40.camel@lca.pw>
 <20190405133742.goqgpxvbc4jsasz5@kshutemo-mobl1>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190405133742.goqgpxvbc4jsasz5@kshutemo-mobl1>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Apr 05, 2019 at 04:37:42PM +0300, Kirill A. Shutemov wrote:
> On Thu, Apr 04, 2019 at 05:28:02PM -0400, Qian Cai wrote:
> > On Thu, 2019-04-04 at 16:45 +0300, Kirill A. Shutemov wrote:
> > > What about this:
> > > 
> > > diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
> > > index f939e004c5d1..2e8438a1216a 100644
> > > --- a/include/linux/pagemap.h
> > > +++ b/include/linux/pagemap.h
> > > @@ -335,12 +335,15 @@ static inline struct page *grab_cache_page_nowait(struct
> > > address_space *mapping,
> > >  
> > >  static inline struct page *find_subpage(struct page *page, pgoff_t offset)
> > >  {
> > > -	unsigned long index = page_index(page);
> > > +	unsigned long mask;
> > > +
> > > +	if (PageHuge(page))
> > > +		return page;
> > >  
> > >  	VM_BUG_ON_PAGE(PageTail(page), page);
> > > -	VM_BUG_ON_PAGE(index > offset, page);
> > > -	VM_BUG_ON_PAGE(index + (1 << compound_order(page)) <= offset, page);
> > > -	return page - index + offset;
> > > +
> > > +	mask = (1UL << compound_order(page)) - 1;
> > > +	return page + (offset & mask);
> > >  }
> > >  
> > >  struct page *find_get_entry(struct address_space *mapping, pgoff_t offset);
> > 
> > It works fine.
> 
> Nice.
> 
> Matthew, does it look fine to you?

Yes, this looks good to me.  I think we'll have opportunities to improve
it later (eg when unifying THP and hugetlbfs uses of the page cache).
But for now, Andrew can you add this version as -fix-fix?

