Return-Path: <SRS0=NQQQ=W6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4C0FDC41514
	for <linux-mm@archiver.kernel.org>; Tue,  3 Sep 2019 12:19:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1752821881
	for <linux-mm@archiver.kernel.org>; Tue,  3 Sep 2019 12:19:55 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1752821881
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A55716B0003; Tue,  3 Sep 2019 08:19:55 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A05D16B0005; Tue,  3 Sep 2019 08:19:55 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 91BBE6B0006; Tue,  3 Sep 2019 08:19:55 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0205.hostedemail.com [216.40.44.205])
	by kanga.kvack.org (Postfix) with ESMTP id 6E38D6B0003
	for <linux-mm@kvack.org>; Tue,  3 Sep 2019 08:19:55 -0400 (EDT)
Received: from smtpin14.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 0D1A1824CA2A
	for <linux-mm@kvack.org>; Tue,  3 Sep 2019 12:19:55 +0000 (UTC)
X-FDA: 75893515950.14.word79_1c54975c95133
X-HE-Tag: word79_1c54975c95133
X-Filterd-Recvd-Size: 3465
Received: from mx1.suse.de (mx2.suse.de [195.135.220.15])
	by imf16.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue,  3 Sep 2019 12:19:54 +0000 (UTC)
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 21EA5B009;
	Tue,  3 Sep 2019 12:19:53 +0000 (UTC)
Date: Tue, 3 Sep 2019 14:19:52 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: William Kucharski <william.kucharski@oracle.com>,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	linux-fsdevel@vger.kernel.org,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Song Liu <songliubraving@fb.com>,
	Bob Kasten <robert.a.kasten@intel.com>,
	Mike Kravetz <mike.kravetz@oracle.com>,
	Chad Mynhier <chad.mynhier@oracle.com>,
	"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
	Johannes Weiner <jweiner@fb.com>
Subject: Re: [PATCH v5 1/2] mm: Allow the page cache to allocate large pages
Message-ID: <20190903121952.GU14028@dhcp22.suse.cz>
References: <20190902092341.26712-1-william.kucharski@oracle.com>
 <20190902092341.26712-2-william.kucharski@oracle.com>
 <20190903115748.GS14028@dhcp22.suse.cz>
 <20190903121155.GD29434@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190903121155.GD29434@bombadil.infradead.org>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue 03-09-19 05:11:55, Matthew Wilcox wrote:
> On Tue, Sep 03, 2019 at 01:57:48PM +0200, Michal Hocko wrote:
> > On Mon 02-09-19 03:23:40, William Kucharski wrote:
> > > Add an 'order' argument to __page_cache_alloc() and
> > > do_read_cache_page(). Ensure the allocated pages are compound pages.
> > 
> > Why do we need to touch all the existing callers and change them to use
> > order 0 when none is actually converted to a different order? This just
> > seem to add a lot of code churn without a good reason. If anything I
> > would simply add __page_cache_alloc_order and make __page_cache_alloc
> > call it with order 0 argument.
> 
> Patch 2/2 uses a non-zero order.

It is a new caller and it can use a new function right?

> I agree it's a lot of churn without
> good reason; that's why I tried to add GFP_ORDER flags a few months ago.
> Unfortunately, you didn't like that approach either.

Is there any future plan that all/most __page_cache_alloc will get a
non-zero order argument?

> > Also is it so much to ask callers to provide __GFP_COMP explicitly?
> 
> Yes, it's an unreasonable burden on the callers.

Care to exaplain why? __GFP_COMP tends to be used in the kernel quite
extensively.

> Those that pass 0 will
> have the test optimised away by the compiler (for the non-NUMA case).
> For the NUMA case, passing zero is going to be only a couple of extra
> instructions to not set the GFP_COMP flag.
> 
> > >  #ifdef CONFIG_NUMA
> > > -extern struct page *__page_cache_alloc(gfp_t gfp);
> > > +extern struct page *__page_cache_alloc(gfp_t gfp, unsigned int order);
> > >  #else
> > > -static inline struct page *__page_cache_alloc(gfp_t gfp)
> > > +static inline struct page *__page_cache_alloc(gfp_t gfp, unsigned int order)
> > >  {
> > > -	return alloc_pages(gfp, 0);
> > > +	if (order > 0)
> > > +		gfp |= __GFP_COMP;
> > > +	return alloc_pages(gfp, order);
> > >  }
> > >  #endif

-- 
Michal Hocko
SUSE Labs

