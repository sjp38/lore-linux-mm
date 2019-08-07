Return-Path: <SRS0=t1E5=WD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.1 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 427EAC32751
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 14:56:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EE88321E6C
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 14:56:09 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="AC2sFIrC"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EE88321E6C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8475D6B0003; Wed,  7 Aug 2019 10:56:09 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7D1166B0006; Wed,  7 Aug 2019 10:56:09 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6715B6B0007; Wed,  7 Aug 2019 10:56:09 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 2B3906B0003
	for <linux-mm@kvack.org>; Wed,  7 Aug 2019 10:56:09 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id 71so52405238pld.1
        for <linux-mm@kvack.org>; Wed, 07 Aug 2019 07:56:09 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=WHDkGIkGDhi7s/aX5RIG2h076WJQgiwTmFKZsiix88I=;
        b=jGzjBOu8Ne780tLL8+Z4zYM/od6c8rwQfqsr9Qt8F4NgeAn5k/XqcZFy+bVtwISHL8
         sEFi7eMWSZ3RP1AVPjGVdwg1vq3/jb3F15IaPwEUHv1ckncuX5hQNC8GgIrE7CuoXRrm
         DPC1+2z4qgTHjF6qMjAyjXv78x8FGzk+X6iBvixyQzc2sHCsudXgEM3Z+rHwMGrfr/Ec
         By52Ss4wEtfHNBVl0IESuu8Mxjjiyoi6q4MR4MB7t0kUOFkmZlfB7YWoPVy6c83OB7T4
         tgMRHIGDfylb28Dz4CKjAkwEZB0PqqcnLDxbefDt6b4fWZLQX7DDLrH8RXVYVy3gktJs
         +o3A==
X-Gm-Message-State: APjAAAWeWi0wS4bPU6Va1Q2OLtawc7QPrVdOPtUd+o+7e3ukkvk+g/Kd
	GZFdjaebbYAv1Qc27Sxi3iUoCoHapGS9gLAEsEGPKutGfOpIIDRvY1OmeRYJ/ga9JfSwuGuMeyo
	0hv3BJJHLSj1x+RYipjpQAO8xE2uqWFc7ccjY2OeqUogN2osz3nRcgjj4JNMRfQe3uw==
X-Received: by 2002:a17:902:2b8a:: with SMTP id l10mr8502306plb.283.1565189768687;
        Wed, 07 Aug 2019 07:56:08 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzhbn3JI3Dq9wL6ccYYTWhLzCAbvX7JqyEUsSzWFNin0R/rJcAaXmDnA8CkN+C/BzaFbhlV
X-Received: by 2002:a17:902:2b8a:: with SMTP id l10mr8502266plb.283.1565189767883;
        Wed, 07 Aug 2019 07:56:07 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565189767; cv=none;
        d=google.com; s=arc-20160816;
        b=s9OXscl+32MKXZ6wz930dGqAVsw+iOCxxZpzLUN/Ka8zfXSB3amgjzxTEzgK2du+J9
         KS+WXZ78gtSNPaSCOqW1/mouysa1JDWsTJIo+CBj9W1IPqvoyPtlKFG47X4eghKstILu
         nvafIcE2HjITdGsiPFHxDi2NONITHne/8/rQypQTXK3UzUNwiGfJYRgLpxeYataB6Z/6
         KmKASgkjvuj62PF7BWdH7etU1h6vuPPpGI7CLftbHMN17/tx4+VkjIYcitYi+szi0mwx
         Sj2RSMnbr31EUXVy2QqLMOPKZKDs2KKz2on5bNZmyEEBfRztY+b8iVaMEWG1ELjQZ4KA
         36bA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=WHDkGIkGDhi7s/aX5RIG2h076WJQgiwTmFKZsiix88I=;
        b=tGUmktsngMN4KNhApEbBWJUFYGisrVJ0Bd2GQGLzlLOHct7la0fjlTPaR09xXUQqbp
         J5XV5AFfFZlWDafC0tQDsTIg7e3sW/YO4xQJVPxAcLUSKl7wgluB3wGIfxarvUrvJRwG
         kqxhRrkdd2pqo47NhJczqe+gPw8uk1gNJkXxOs+RJ9NPf16rnAwMLv9vLawWge1xSef1
         09+CM9zk+fM7QUuS8h1y9C3O0hMxlHbxy9F5rvh16hG0Fwx33ndInItuA/+M9Igl0XeQ
         j+epOpTP49YYGxVqzzNCcHMPlaaIssrOTJLENJE0EYBaztGO9A4EMIdMR+7sFFGAEzQ0
         Pa2w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=AC2sFIrC;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id d9si15626829pgq.119.2019.08.07.07.56.07
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Wed, 07 Aug 2019 07:56:07 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=AC2sFIrC;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=WHDkGIkGDhi7s/aX5RIG2h076WJQgiwTmFKZsiix88I=; b=AC2sFIrClzvrAuopVrXvwugiY
	8pjCjcoNMRxBAbOu1e+IYWnWwBn23rrvVb3+zo9jSy/rEqV0jtM6OKmuaKJgIPCd+ZEJGVHI1xCUM
	V33yiZR1LBHycuELJYuk3ChIMHbwC3+U3UkD+itrcmrRrXwcGTUiy4Emh3dDvFH8iJCGHKTIyZkSS
	JkM7h5vZfpkNwqmfAGioAVQ7oEBCMiwDFERlYOCfEHok0Ct0gRQBQZhg0acgBiGO6N99OC8PyFqGX
	RBH5duCu835KJqDGvsVYJ2T0t8xRO3dI5YDATQhUwKO6u2/VVkIlC73MRjL16m50yadyh4WpPfYWx
	CslHyrvIQ==;
Received: from willy by bombadil.infradead.org with local (Exim 4.92 #3 (Red Hat Linux))
	id 1hvNM9-00082M-J1; Wed, 07 Aug 2019 14:56:01 +0000
Date: Wed, 7 Aug 2019 07:56:01 -0700
From: Matthew Wilcox <willy@infradead.org>
To: Steven Price <steven.price@arm.com>
Cc: Christoph Hellwig <hch@infradead.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Thomas =?iso-8859-1?Q?Hellstr=F6m_=28VMware=29?= <thomas@shipmail.org>,
	Dave Airlie <airlied@gmail.com>,
	Thomas Hellstrom <thellstrom@vmware.com>,
	Daniel Vetter <daniel.vetter@ffwll.ch>,
	LKML <linux-kernel@vger.kernel.org>,
	dri-devel <dri-devel@lists.freedesktop.org>,
	Jerome Glisse <jglisse@redhat.com>,
	Jason Gunthorpe <jgg@mellanox.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linux-MM <linux-mm@kvack.org>
Subject: Re: drm pull for v5.3-rc1
Message-ID: <20190807145601.GB5482@bombadil.infradead.org>
References: <CAHk-=wiD6a189CXj-ugRzCxA9r1+siSCA0eP_eoZ_bk_bLTRMw@mail.gmail.com>
 <48890b55-afc5-ced8-5913-5a755ce6c1ab@shipmail.org>
 <CAHk-=whwcMLwcQZTmWgCnSn=LHpQG+EBbWevJEj5YTKMiE_-oQ@mail.gmail.com>
 <CAHk-=wghASUU7QmoibQK7XS09na7rDRrjSrWPwkGz=qLnGp_Xw@mail.gmail.com>
 <20190806073831.GA26668@infradead.org>
 <CAHk-=wi7L0MDG7DY39Hx6v8jUMSq3ZCE3QTnKKirba_8KAFNyw@mail.gmail.com>
 <20190806190937.GD30179@bombadil.infradead.org>
 <20190807064000.GC6002@infradead.org>
 <20190807141517.GA5482@bombadil.infradead.org>
 <62cbe523-e8a4-cdfd-90c2-80260cefa5de@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <62cbe523-e8a4-cdfd-90c2-80260cefa5de@arm.com>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Aug 07, 2019 at 03:30:38PM +0100, Steven Price wrote:
> On 07/08/2019 15:15, Matthew Wilcox wrote:
> > On Tue, Aug 06, 2019 at 11:40:00PM -0700, Christoph Hellwig wrote:
> >> On Tue, Aug 06, 2019 at 12:09:38PM -0700, Matthew Wilcox wrote:
> >>> Has anyone looked at turning the interface inside-out?  ie something like:
> >>>
> >>> 	struct mm_walk_state state = { .mm = mm, .start = start, .end = end, };
> >>>
> >>> 	for_each_page_range(&state, page) {
> >>> 		... do something with page ...
> >>> 	}
> >>>
> >>> with appropriate macrology along the lines of:
> >>>
> >>> #define for_each_page_range(state, page)				\
> >>> 	while ((page = page_range_walk_next(state)))
> >>>
> >>> Then you don't need to package anything up into structs that are shared
> >>> between the caller and the iterated function.
> >>
> >> I'm not an all that huge fan of super magic macro loops.  But in this
> >> case I don't see how it could even work, as we get special callbacks
> >> for huge pages and holes, and people are trying to add a few more ops
> >> as well.
> > 
> > We could have bits in the mm_walk_state which indicate what things to return
> > and what things to skip.  We could (and probably should) also use different
> > iterator names if people actually want to iterate different things.  eg
> > for_each_pte_range(&state, pte) as well as for_each_page_range().
> > 
> 
> The iterator approach could be awkward for the likes of my generic
> ptdump implementation[1]. It would require an iterator which returns all
> levels and allows skipping levels when required (to prevent KASAN
> slowing things down too much). So something like:
> 
> start_walk_range(&state);
> for_each_page_range(&state, page) {
> 	switch(page->level) {
> 	case PTE:
> 		...
> 	case PMD:
> 		if (...)
> 			skip_pmd(&state);
> 		...
> 	case HOLE:
> 		....
> 	...
> 	}
> }
> end_walk_range(&state);
> 
> It seems a little fragile - e.g. we wouldn't (easily) get type checking
> that you are actually treating a PTE as a pte_t. The state mutators like
> skip_pmd() also seem a bit clumsy.

Once you're on-board with using a state structure, you can use it in all
kinds of fun ways.  For example:

struct mm_walk_state {
	struct mm_struct *mm;
	unsigned long start;
	unsigned long end;
	unsigned long curr;
	p4d_t p4d;
	pud_t pud;
	pmd_t pmd;
	pte_t pte;
	enum page_entry_size size;
	int flags;
};

For this user, I'd expect something like ...

	DECLARE_MM_WALK_FLAGS(state, mm, start, end,
				MM_WALK_HOLES | MM_WALK_ALL_SIZES);

	walk_each_pte(state) {
		switch (state->size) {
		case PE_SIZE_PTE:
			... 
		case PE_SIZE_PMD:
			if (...(state->pmd))
				continue;
		...
		}
	}

There's no need to have start / end walk function calls.

