Return-Path: <SRS0=8949=Q3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0AFD7C4360F
	for <linux-mm@archiver.kernel.org>; Wed, 20 Feb 2019 12:24:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A1FC72147A
	for <linux-mm@archiver.kernel.org>; Wed, 20 Feb 2019 12:24:29 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="P5wIHcJw"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A1FC72147A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 056528E000D; Wed, 20 Feb 2019 07:24:29 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 006C08E0002; Wed, 20 Feb 2019 07:24:28 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E5F3D8E000D; Wed, 20 Feb 2019 07:24:28 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id A6F5D8E0002
	for <linux-mm@kvack.org>; Wed, 20 Feb 2019 07:24:28 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id m3so18684704pfj.14
        for <linux-mm@kvack.org>; Wed, 20 Feb 2019 04:24:28 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=me4pNO26rwyoESSLvYT67P6JAcOIH6WaRv2PXlW5qoc=;
        b=K4fQoLG7u/0kY0JjAQOreg5/Zw62NexMuEcB06MqZ9jyXfbl27G+9sEpyChaDzXvKE
         MZzDzTQ3CdWQCf2doTEBbRYOrHtH1gddJkEnDrkn1xwn0xox6fwJyuSJbHDsQaVXUdFF
         BU7IS7l1Lf77yX75zOpTUPGpD0mpTWSm/+vb4roQ/5pPCy9Amdq3zzgUNpA/cmNrPTPj
         20sej1KQSVD97BQ/mRekJ1yQxFkinkZ0XEUWB7/gmhdEbt/iBANy17o0xrFXZPHoDFYG
         n3GRRVY4jleOlREmybff25H7J4VBbe+DjP9G69Vc47yAFvQptwmP8WfVu4GFLbkN/6a6
         9CsA==
X-Gm-Message-State: AHQUAuZGT1RZ63DZLT4xH0vJMzTBzXFNgRwOws2pSSyiXWeYYVka7HF8
	IZzPHviXtRnFS7HGfy0WYKiUgxXcbIpYFoq+WnJkfRhlWqnBvhdyz+YarPur7xV4d3e/+tsrXY3
	s+fmb2CM/F215gaukPQcQxnSxiF4Q8pGwlGNN+ufswasoJr7OP/2HD8IblxRF5u+fow==
X-Received: by 2002:a63:ed03:: with SMTP id d3mr28590136pgi.275.1550665468248;
        Wed, 20 Feb 2019 04:24:28 -0800 (PST)
X-Google-Smtp-Source: AHgI3IaRhhRcaZv0XuhX9dOpynOGdOr6Y90DVYHMFKpBL76x8pugtGsQ4kg28x+yifGcRds42KLW
X-Received: by 2002:a63:ed03:: with SMTP id d3mr28590001pgi.275.1550665465791;
        Wed, 20 Feb 2019 04:24:25 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550665465; cv=none;
        d=google.com; s=arc-20160816;
        b=hoTSGO81Pz1sYHPFAVyf8DQi23QVtsurjWiFWHmfTqUaDi8vSOUCJwyNgWX6TQx9jk
         QVINP0TuePNK3TKqr/j/6D3qdr8nrHdiRgJfqfqEX4KWnsJe8Dpb1svK/vq4gXbETfwa
         DGrK45C88+4G2/1M0/VOP4Ep65tzgYkSI81iIXTUoREnVpQljeH5Msdx5QCph/4N3/oY
         FYHGBy5w90oq7vV984NJz1663p9Uwy0YuW4IIO8uJl9eX6m/atKVLT7UraluoaYTjGa9
         OBNHykfRDJSVpV5hA1AkBE2Qp36jckYJl36fq23jDBSU7vOE09tgUdOWNxwYwVkaiIqh
         QXaA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=me4pNO26rwyoESSLvYT67P6JAcOIH6WaRv2PXlW5qoc=;
        b=zZd0bT06FuDxUBGaYfTs61YKXG7Qoh2LrP8Nu7ZOUymPMOXdhyYwkqHDxSUdkKD4Q8
         lj+n43FXB51x+PVHmRbY8NTAhlMKAvDT3P/btogo6hrei9cb0TSEvle7+vTJAB9/f3qd
         VRMhAyDgPFHGubYjD2ciWaaQlPacO6jHV+/yOzcbJwqg92lkgifwN5bNtsH2N8qQemdj
         psGazL7HphXvjAdzt+T95AkwViHQoa13cweLZut+6cYtV4Ld4g4R6AmLu6V0vWeXAoir
         Iq1c8OztCsBREl4mprXZkad3MzytTz3XlnBJPqfb8B9TXPoqaDo7b//313bpK2JGZbe7
         cQIw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=P5wIHcJw;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id f12si17674143pgo.562.2019.02.20.04.24.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 20 Feb 2019 04:24:25 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=P5wIHcJw;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=me4pNO26rwyoESSLvYT67P6JAcOIH6WaRv2PXlW5qoc=; b=P5wIHcJw++x9NBZ+COTzGh5uI
	YibiVWkfYoz45QhgxupEDHHGRevMJLd7+co34jvYWdWb3NkRTngZAbsO7DYJQ/CQP5ogcC4GGj1br
	fqFne0WaVqvADch1gbehMTxtnFx2gz1SS6zn/ql2C87/qbg2Ap8bHfobT4Rva4HavgBFbx3limBsB
	BlfAuCeIApATr/hPBMgdrj6F7JO8r/p1TKGdBANQMYMOgrLH6Yqxhu9cRDorGto6rS/+huOrGn/us
	Fx805Y5J2150xDmc0YtM77Uh2CnlNeP0wcjzWsAVlADl5ZBwG6vH6k1h3L3LoPgj9OD3xNhYyIoWn
	XWJYFP7GQ==;
Received: from willy by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1gwQvC-0004yo-Rs; Wed, 20 Feb 2019 12:24:18 +0000
Date: Wed, 20 Feb 2019 04:24:18 -0800
From: Matthew Wilcox <willy@infradead.org>
To: Anshuman Khandual <anshuman.khandual@arm.com>
Cc: Yu Zhao <yuzhao@google.com>, Catalin Marinas <catalin.marinas@arm.com>,
	Will Deacon <will.deacon@arm.com>,
	"Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Nick Piggin <npiggin@gmail.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Joel Fernandes <joel@joelfernandes.org>,
	"Kirill A . Shutemov" <kirill@shutemov.name>,
	Mark Rutland <mark.rutland@arm.com>,
	Ard Biesheuvel <ard.biesheuvel@linaro.org>,
	Chintan Pandya <cpandya@codeaurora.org>,
	Jun Yao <yaojun8558363@gmail.com>,
	Laura Abbott <labbott@redhat.com>,
	linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
	linux-arch@vger.kernel.org, linux-mm@kvack.org
Subject: Re: [PATCH v2 1/3] arm64: mm: use appropriate ctors for page tables
Message-ID: <20190220122418.GE12668@bombadil.infradead.org>
References: <20190214211642.2200-1-yuzhao@google.com>
 <20190218231319.178224-1-yuzhao@google.com>
 <863acc9a-53fb-86ad-4521-828ee8d9c222@arm.com>
 <20190219053205.GA124985@google.com>
 <8f9b0bfb-b787-fa3e-7322-73a56a618aa8@arm.com>
 <20190219222828.GA68281@google.com>
 <f7e4db43-b836-4ac2-1aea-922be585d8b1@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <f7e4db43-b836-4ac2-1aea-922be585d8b1@arm.com>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Feb 20, 2019 at 03:57:59PM +0530, Anshuman Khandual wrote:
> On 02/20/2019 03:58 AM, Yu Zhao wrote:
> > On Tue, Feb 19, 2019 at 11:47:12AM +0530, Anshuman Khandual wrote:
> >> On 02/19/2019 11:02 AM, Yu Zhao wrote:
> >>> On Tue, Feb 19, 2019 at 09:51:01AM +0530, Anshuman Khandual wrote:
> >>>> On 02/19/2019 04:43 AM, Yu Zhao wrote:
> >>>>> For pte page, use pgtable_page_ctor(); for pmd page, use
> >>>>> pgtable_pmd_page_ctor() if not folded; and for the rest (pud,
> >>>>> p4d and pgd), don't use any.
> >>>> pgtable_page_ctor()/dtor() is not optional for any level page table page
> >>>> as it determines the struct page state and zone statistics.
> >>>
> >>> This is not true. pgtable_page_ctor() is only meant for user pte
> >>> page. The name isn't perfect (we named it this way before we had
> >>> split pmd page table lock, and never bothered to change it).
> >>>
> >>> The commit cccd843f54be ("mm: mark pages in use for page tables")
> >>> clearly states so:
> >>>   Note that only pages currently accounted as NR_PAGETABLES are
> >>>   tracked as PageTable; this does not include pgd/p4d/pud/pmd pages.
> >>
> >> I think the commit is the following one and it does say so. But what is
> >> the rationale of tagging only PTE page as PageTable and updating the zone
> >> stat but not doing so for higher level page table pages ? Are not they
> >> used as page table pages ? Should not they count towards NR_PAGETABLE ?
> >>
> >> 1d40a5ea01d53251c ("mm: mark pages in use for page tables")
> > 
> > Well, I was just trying to clarify how the ctor is meant to be used.
> > The rational behind it is probably another topic.
> > 
> > For starters, the number of pmd/pud/p4d/pgd is at least two orders
> > of magnitude less than the number of pte, which makes them almost
> > negligible. And some archs use kmem for them, so it's infeasible to
> > SetPageTable on or account them in the way the ctor does on those
> > archs.
> 
> I understand the kmem cases which are definitely problematic and should
> be fixed. IIRC there is a mechanism to custom init pages allocated for
> slab cache with a ctor function which in turn can call pgtable_page_ctor().
> But destructor helper support for slab has been dropped I guess.

You can't put a spinlock in the struct page if the page is allocated
through slab.  Slab uses basically all of struct page for its own
purposes.  I tried to make that clear with the new layout of struct
page where everything's in a union discriminated by what the page is
allocated for.

