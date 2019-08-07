Return-Path: <SRS0=t1E5=WD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.1 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CF493C19759
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 06:40:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8AFD6214C6
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 06:40:08 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="dLjgyEgY"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8AFD6214C6
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3F25E6B0007; Wed,  7 Aug 2019 02:40:08 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3A13E6B0008; Wed,  7 Aug 2019 02:40:08 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 26AA26B000A; Wed,  7 Aug 2019 02:40:08 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id DF2BD6B0007
	for <linux-mm@kvack.org>; Wed,  7 Aug 2019 02:40:07 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id a5so50133783pla.3
        for <linux-mm@kvack.org>; Tue, 06 Aug 2019 23:40:07 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=7uoByRa+Al/xx5bip7rUm8otbKddClrdMOGAdUETRbE=;
        b=VWLm9An7Pl6r6BM7oJ8Mz961eajBcTk+J4Th5N+hlEfCm2n1hU+8ohzxwjZ2lQGSnF
         K0Eu6s3jO/wTBBqrIci9SlknVA0WQ0F1Tpcwt1F+Myg6zPZ1Fo3AXS8WYM+ii2RJafXY
         LCd7Zmt0qJdPjs/3OIdjowGyU0+RP4QhxZxrpLKSgjLbGdkuBRbL4TBPjBmVnlyrSPuM
         TQ4jDX4VEWT67f4IoIzX0byWC4Cnx/fik2vwWxeY/Cj0fSXV2CFMjH260Mi0UsehEq8T
         WXi+o3Zsp8I+mzHng5zabewmhME2bWIHjJ1NpOEbbAKvntdGZkZa7i+zG7bPv2gDGwLJ
         3JJQ==
X-Gm-Message-State: APjAAAXXPYBOSIAv+efMFuKMsjHk5fphMSnKqe2xWUZ1L22adlDP6SZE
	5pbbtXGzh1nFInEO6QO+Xm8gpCRKkTVYZuHJE+QLkTT1tAS3+L0YoSosLI+msSkXc/3XQo1PbII
	AyrCgr7kiHJUzyIntHOLSI9UrF0pjf2lmTcFnCsyPvLhLLrMdIAcBysHwTKsx5E+mLw==
X-Received: by 2002:a17:90a:d14a:: with SMTP id t10mr6956954pjw.85.1565160007595;
        Tue, 06 Aug 2019 23:40:07 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzlmT/yAAf7qRF9/Lr3LD8OP3WuV2fTriiRH2kQB+HBjVaukn1EVRzU80sBfXCxttQu6BTM
X-Received: by 2002:a17:90a:d14a:: with SMTP id t10mr6956925pjw.85.1565160007019;
        Tue, 06 Aug 2019 23:40:07 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565160007; cv=none;
        d=google.com; s=arc-20160816;
        b=fqPIAjIskfWoKlkTd9T1CzD/hxjsZZVQm5OpbfguHRNeHdwpwf6ctn0F7S8XQWd22v
         xXYywqBosmqxhtg26N8Rvgafkh09nQlNiBaR+2oWQvFWuXDMtJT+SXdBthrWNZFiLSLP
         6ElrDAEGZYkJQlnSJ2tRKizbEU8Z8d4LE2TmZ3ghy28c4MlP8OwwitnNLRGmS5OrRFL/
         4den7wsSVosFcAsmCLN+5JTKyYqnuMc5rM5lfuEru1sgBZ/QaJcBmRYNvZFaNul0HqfN
         w1C2MhSxus4ZP4j+2/mIn95YLA1B+A7h2httEd2ieRQHM7zM8k5BG7O+J4V6Y5c861qp
         3kiw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=7uoByRa+Al/xx5bip7rUm8otbKddClrdMOGAdUETRbE=;
        b=unkoDSnU3W4pjs2gpYXLkfASonH9gsabbP0+BXDAZHH31w6vJE2pfbbQAMqgsKubwz
         Z2tWBNbM0wGBj/12fLBygNMve84PiXks6HdMOLBQ1kZ72Vmnv9OtTBHo1qlcer1kFdD9
         1MWDaX+BfgjNeptixSngJTrj6iqSey/1IPpHVJe7HL0/48CB7fa1/cp0lQ8K8B7Ori36
         8WisTuY3JqU094TRxgCqS3CJGzPWqKYEqVm/QF5B4NG3yP/wz9vlTi9SIeSqmqyvsIh5
         6MihaXO4II5CCt9IBErXOuxrCmi2ZbQ+QEOcVAIJBdNnmlkVVu9dBZ9Le1k3oxvgO5+2
         5RHg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=dLjgyEgY;
       spf=pass (google.com: best guess record for domain of batv+ecabc3e5d1f7686a0adb+5827+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+ecabc3e5d1f7686a0adb+5827+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id x9si37679216plv.182.2019.08.06.23.40.06
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 06 Aug 2019 23:40:07 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+ecabc3e5d1f7686a0adb+5827+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=dLjgyEgY;
       spf=pass (google.com: best guess record for domain of batv+ecabc3e5d1f7686a0adb+5827+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+ecabc3e5d1f7686a0adb+5827+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=7uoByRa+Al/xx5bip7rUm8otbKddClrdMOGAdUETRbE=; b=dLjgyEgYjD1Os5q21xXo4cPVG
	9DH2AgUTdtbRF+g2nPIvPt5xl1Kb4pJ9PgP55ZxyrfEJopI8Y6zDiY54klLdOvkh50jjPzNLjN2g3
	YJMwWzn4POHUA71za7cjK1UnTdmYk1umo1Q09nkIrCUrPUZmCC7kliZRklsJpjnPvb1jHKRK8B0LY
	3exvnq5asy/EFK1Fz/4Pa7KlySZu1MpQqfwFN3NHTROnZmA5wy3d66hMcRR0PhsSe730aQcDCEiNP
	Dz+EPfLNHWPuIyFAKQ++QPOeCkLMVt2t+i+At2EeInDwGgyJYOL+Ta8BJGxsLgFDTCd5axhBG1yp8
	ZV8RsxtYw==;
Received: from hch by bombadil.infradead.org with local (Exim 4.92 #3 (Red Hat Linux))
	id 1hvFc8-0007MG-7S; Wed, 07 Aug 2019 06:40:00 +0000
Date: Tue, 6 Aug 2019 23:40:00 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	Christoph Hellwig <hch@infradead.org>,
	Thomas =?iso-8859-1?Q?Hellstr=F6m_=28VMware=29?= <thomas@shipmail.org>,
	Dave Airlie <airlied@gmail.com>,
	Thomas Hellstrom <thellstrom@vmware.com>,
	Daniel Vetter <daniel.vetter@ffwll.ch>,
	LKML <linux-kernel@vger.kernel.org>,
	dri-devel <dri-devel@lists.freedesktop.org>,
	Jerome Glisse <jglisse@redhat.com>,
	Jason Gunthorpe <jgg@mellanox.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Steven Price <steven.price@arm.com>, Linux-MM <linux-mm@kvack.org>
Subject: Re: drm pull for v5.3-rc1
Message-ID: <20190807064000.GC6002@infradead.org>
References: <CAPM=9tzJQ+26n_Df1eBPG1A=tXf4xNuVEjbG3aZj-aqYQ9nnAg@mail.gmail.com>
 <CAPM=9twvwhm318btWy_WkQxOcpRCzjpok52R8zPQxQrnQ8QzwQ@mail.gmail.com>
 <CAHk-=wjC3VX5hSeGRA1SCLjT+hewPbbG4vSJPFK7iy26z4QAyw@mail.gmail.com>
 <CAHk-=wiD6a189CXj-ugRzCxA9r1+siSCA0eP_eoZ_bk_bLTRMw@mail.gmail.com>
 <48890b55-afc5-ced8-5913-5a755ce6c1ab@shipmail.org>
 <CAHk-=whwcMLwcQZTmWgCnSn=LHpQG+EBbWevJEj5YTKMiE_-oQ@mail.gmail.com>
 <CAHk-=wghASUU7QmoibQK7XS09na7rDRrjSrWPwkGz=qLnGp_Xw@mail.gmail.com>
 <20190806073831.GA26668@infradead.org>
 <CAHk-=wi7L0MDG7DY39Hx6v8jUMSq3ZCE3QTnKKirba_8KAFNyw@mail.gmail.com>
 <20190806190937.GD30179@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190806190937.GD30179@bombadil.infradead.org>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Aug 06, 2019 at 12:09:38PM -0700, Matthew Wilcox wrote:
> Has anyone looked at turning the interface inside-out?  ie something like:
> 
> 	struct mm_walk_state state = { .mm = mm, .start = start, .end = end, };
> 
> 	for_each_page_range(&state, page) {
> 		... do something with page ...
> 	}
> 
> with appropriate macrology along the lines of:
> 
> #define for_each_page_range(state, page)				\
> 	while ((page = page_range_walk_next(state)))
> 
> Then you don't need to package anything up into structs that are shared
> between the caller and the iterated function.

I'm not an all that huge fan of super magic macro loops.  But in this
case I don't see how it could even work, as we get special callbacks
for huge pages and holes, and people are trying to add a few more ops
as well.

