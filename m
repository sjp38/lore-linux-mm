Return-Path: <SRS0=58dN=SL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EEB50C282CE
	for <linux-mm@archiver.kernel.org>; Tue,  9 Apr 2019 02:49:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A033B213F2
	for <linux-mm@archiver.kernel.org>; Tue,  9 Apr 2019 02:49:39 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="IQx6HQ79"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A033B213F2
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3FB0F6B0008; Mon,  8 Apr 2019 22:49:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 380FA6B000C; Mon,  8 Apr 2019 22:49:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 223016B0010; Mon,  8 Apr 2019 22:49:39 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id E8B436B0008
	for <linux-mm@kvack.org>; Mon,  8 Apr 2019 22:49:38 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id 14so11526503pgf.22
        for <linux-mm@kvack.org>; Mon, 08 Apr 2019 19:49:38 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=+sTnbP4kwIRGvZ3/0p8aO28bolyQS4PZg/H+Zbxqxf0=;
        b=jibhjBHRL7nbpnG4j4rJegp7d01H5/16AAuMpyKrhm/4Jyci4PnPQCMlN+3ZfnisrK
         e7a8EQZxIdCzUN6q9vmvs+5fTUBoMNM8CZ/kdywHM5b+lHQQJafLiFif8HZcapr8X2ju
         aCKeR9bqrT7F4w/nPYRkeT3B/BjyCh2HHyUkSyt2smmhZEsPQc5awb/xStz1pcRGB2XR
         sOHyYHPrau3GSJ6tEC7G0vk26NLm2aXAVznCm5eZR4ip43WmPGVsSziKeeMFZaNnfzbL
         dITQctzYgtz9wItBfdu3FAJw5txjv5CPPdQnTeDczLXskb9m+bUv+kB9UKHCblQH/q8e
         bzcg==
X-Gm-Message-State: APjAAAUW4c49bjvPmVN80bgpg+gGyr1nEqEHAJXoup+79hEMJlea4A+1
	k7xm1gO06y/wiWkxk7nssas9yihPYVRk3vJ7tsTNvK5K+WYj9zPjEuUrlF52xEQWZKB7w0plYkJ
	IZv2zfq8940bYZ7tAXHtAJmn0FpKVNIubdWRC2G/iI22m2S9FZEGKWoXBOLZNBZEK2Q==
X-Received: by 2002:a17:902:421:: with SMTP id 30mr33026983ple.142.1554778178383;
        Mon, 08 Apr 2019 19:49:38 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyF3a3HawzOgZv4aTaNNcy2yw68080ns2mGJLOX7tkB8F1t2daj+dAPmlqBMgFw4zkS9iNf
X-Received: by 2002:a17:902:421:: with SMTP id 30mr33026944ple.142.1554778177628;
        Mon, 08 Apr 2019 19:49:37 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554778177; cv=none;
        d=google.com; s=arc-20160816;
        b=HriWpcvFewiVkG3fZKBtyO6qrPsTERf+g79vsL/oPHpjWbEPJxnDzXaZ3bEy4LXczm
         h62vZcpaDGQnzkwqwrUNe2zVjmXMRJPeBH00AXOT5MgWGW3O3odBLh94FLISq4y/cB49
         MXPovgiV5Jf6ZdBGi3EyzOUeTGnGSZqcztpBckNN4gm6cg3zmJh5tveAnY9apDK4jVFX
         LgUucNHzqUe3dIfKpGQvid5+CoNzgOBQ8W0yj1tmBhsAElh/6gH7LNKcjGECFVgfDc+8
         usm8SxVjrEN3a3uF3j0Q3Tm5bDR5FR16kbdWN1KuZmYX7eSpV4CZ/NNBVTfEzGBgwgx4
         Ojcw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=+sTnbP4kwIRGvZ3/0p8aO28bolyQS4PZg/H+Zbxqxf0=;
        b=TNomkCra4Uoj4HBiQVdMXSsONgsZ/XnsFVF/85CdFwNOAKgHZz7fu0oEoM3Gsg5BpY
         chW8Z2ZGxjKelZv6izFIhFx3g9GCTgB3CatDRAod5f2zZDXVy/dlRYCzqUtirIhEYdxU
         zXcPcBEraDB6sE7SGIDhPA6G3R15yIizl5UM4tYmaR1a2HjnkSX301uFGpLBY4Qq28N8
         +KcOzIgoioETbchxOSG9BK8f68KF4BlEZnkmFWeBIdj+8fKujPWSkcF9L8IrjlqziOIo
         bGlBFR1u5ZteER9RSEG4kGAgWXoXfGPdbwuDyAYf37m56nd+tWmJqg9UiUDQToK/+bRC
         R6UQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=IQx6HQ79;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 198.137.202.133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [198.137.202.133])
        by mx.google.com with ESMTPS id a192si9940428pge.50.2019.04.08.19.49.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 08 Apr 2019 19:49:37 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 198.137.202.133 as permitted sender) client-ip=198.137.202.133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=IQx6HQ79;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 198.137.202.133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=+sTnbP4kwIRGvZ3/0p8aO28bolyQS4PZg/H+Zbxqxf0=; b=IQx6HQ79QqGX7eO8jyasd4v0j
	m0c3D2/Hhq55NUArw4A9igZl44KnhAW/Sv4D9pcn9ybJiD1U9U71AOe4AmNjs6nHdT0V54uLfvQK9
	ZECByfGXchDZxYKEHi1vGG2paLGfUqgreqgIBGpnn5ucQnO01Ft48qBLY1uEMm0VrT3HM/MXxl/Xq
	jwluodV18EV3WZ/b9691OyDEwNOaRBAhZtPtRtEU8kTf0w+Mh/cZmGMTMeSu63RA5m6r6MCKwwv4M
	apckaLCSx3COmCMyv98QI5NS1daHb5QAPSE2I5Bho5fP3vvWu3gX+CrXYF3BcK1Cp7lAr5fNtfs+8
	i11Fn3SWg==;
Received: from willy by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hDgpG-0001c2-5h; Tue, 09 Apr 2019 02:49:30 +0000
Date: Mon, 8 Apr 2019 19:49:29 -0700
From: Matthew Wilcox <willy@infradead.org>
To: Huang Shijie <sjhuang@iluvatar.ai>
Cc: akpm@linux-foundation.org, william.kucharski@oracle.com,
	ira.weiny@intel.com, palmer@sifive.com, axboe@kernel.dk,
	keescook@chromium.org, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH 1/2] mm/gup.c: fix the wrong comments
Message-ID: <20190409024929.GW22763@bombadil.infradead.org>
References: <20190408023746.16916-1-sjhuang@iluvatar.ai>
 <20190408141313.GU22763@bombadil.infradead.org>
 <20190409010832.GA28081@hsj-Precision-5520>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190409010832.GA28081@hsj-Precision-5520>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Apr 09, 2019 at 09:08:33AM +0800, Huang Shijie wrote:
> On Mon, Apr 08, 2019 at 07:13:13AM -0700, Matthew Wilcox wrote:
> > On Mon, Apr 08, 2019 at 10:37:45AM +0800, Huang Shijie wrote:
> > > The root cause is that sg_alloc_table_from_pages() requires the
> > > page order to keep the same as it used in the user space, but
> > > get_user_pages_fast() will mess it up.
> > 
> > I don't understand how get_user_pages_fast() can return the pages in a
> > different order in the array from the order they appear in userspace.
> > Can you explain?
> Please see the code in gup.c:
> 
> 	int get_user_pages_fast(unsigned long start, int nr_pages,
> 				unsigned int gup_flags, struct page **pages)
> 	{
> 		.......
> 		if (gup_fast_permitted(start, nr_pages)) {
> 			local_irq_disable();
> 			gup_pgd_range(addr, end, gup_flags, pages, &nr);               // The @pages array maybe filled at the first time.

Right ... but if it's not filled entirely, it will be filled part-way,
and then we stop.

> 			local_irq_enable();
> 			ret = nr;
> 		}
> 		.......
> 		if (nr < nr_pages) {
> 			/* Try to get the remaining pages with get_user_pages */
> 			start += nr << PAGE_SHIFT;
> 			pages += nr;                                                  // The @pages is moved forward.

Yes, to the point where gup_pgd_range() stopped.

> 			if (gup_flags & FOLL_LONGTERM) {
> 				down_read(&current->mm->mmap_sem);
> 				ret = __gup_longterm_locked(current, current->mm,      // The @pages maybe filled at the second time

Right.

> 				/*
> 				 * retain FAULT_FOLL_ALLOW_RETRY optimization if
> 				 * possible
> 				 */
> 				ret = get_user_pages_unlocked(start, nr_pages - nr,    // The @pages maybe filled at the second time.
> 							      pages, gup_flags);

Yes.  But they'll be in the same order.

> BTW, I do not know why we mess up the page order. It maybe used in some special case.

I'm not discounting the possibility that you've found a bug.
But documenting that a bug exists is not the solution; the solution is
fixing the bug.

