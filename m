Return-Path: <SRS0=NQQQ=W6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.1 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 77C8EC3A5A2
	for <linux-mm@archiver.kernel.org>; Tue,  3 Sep 2019 16:28:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3C32623789
	for <linux-mm@archiver.kernel.org>; Tue,  3 Sep 2019 16:28:40 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="oCJ92zCv"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3C32623789
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CD1626B0003; Tue,  3 Sep 2019 12:28:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C81D26B0005; Tue,  3 Sep 2019 12:28:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B71466B0006; Tue,  3 Sep 2019 12:28:39 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0130.hostedemail.com [216.40.44.130])
	by kanga.kvack.org (Postfix) with ESMTP id 932CA6B0003
	for <linux-mm@kvack.org>; Tue,  3 Sep 2019 12:28:39 -0400 (EDT)
Received: from smtpin03.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id 00167180AD801
	for <linux-mm@kvack.org>; Tue,  3 Sep 2019 16:28:38 +0000 (UTC)
X-FDA: 75894142758.03.burn17_1140517f73d46
X-HE-Tag: burn17_1140517f73d46
X-Filterd-Recvd-Size: 4151
Received: from bombadil.infradead.org (bombadil.infradead.org [198.137.202.133])
	by imf39.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue,  3 Sep 2019 16:28:38 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=A01EoZVAbENBU2ODnei5aZC/eSyCxIe7RviRDSpgglA=; b=oCJ92zCv0vaLqsiIF+BEQ5E5E
	8tWg574OR1tXDNAdgxaEW9ZOtC9RgXU1YeUw55xOc80zTVRnxZCyUCNLfBkNAZiwoSCt+KyE7f7Kk
	ECF8MrNiznXkAufY1RvmwEc4odtOEh9+oHbf3hsI4VKg4VwUYZq5xwAupL2R1uln6DSGhJXwYQuI8
	RZQyCR8PGBPL7nxrArCSdqjcBVWN6LLgHZFUTqJMg7UzRJqLSd6mxYw8FwJFmVgpPJ2xIqwp5z5fm
	/eE8MkNJ96Iu/HNE71eque6R66Ku7pz2Xo1iouPfCUsPb8CZ13tGOYrgSNMyfPJp/XL4BMK5TpA+i
	lQqXK0fyg==;
Received: from willy by bombadil.infradead.org with local (Exim 4.92 #3 (Red Hat Linux))
	id 1i5BfT-000149-Ek; Tue, 03 Sep 2019 16:28:31 +0000
Date: Tue, 3 Sep 2019 09:28:31 -0700
From: Matthew Wilcox <willy@infradead.org>
To: Michal Hocko <mhocko@kernel.org>
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
Message-ID: <20190903162831.GI29434@bombadil.infradead.org>
References: <20190902092341.26712-1-william.kucharski@oracle.com>
 <20190902092341.26712-2-william.kucharski@oracle.com>
 <20190903115748.GS14028@dhcp22.suse.cz>
 <20190903121155.GD29434@bombadil.infradead.org>
 <20190903121952.GU14028@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190903121952.GU14028@dhcp22.suse.cz>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Sep 03, 2019 at 02:19:52PM +0200, Michal Hocko wrote:
> On Tue 03-09-19 05:11:55, Matthew Wilcox wrote:
> > On Tue, Sep 03, 2019 at 01:57:48PM +0200, Michal Hocko wrote:
> > > On Mon 02-09-19 03:23:40, William Kucharski wrote:
> > > > Add an 'order' argument to __page_cache_alloc() and
> > > > do_read_cache_page(). Ensure the allocated pages are compound pages.
> > > 
> > > Why do we need to touch all the existing callers and change them to use
> > > order 0 when none is actually converted to a different order? This just
> > > seem to add a lot of code churn without a good reason. If anything I
> > > would simply add __page_cache_alloc_order and make __page_cache_alloc
> > > call it with order 0 argument.
> > 
> > Patch 2/2 uses a non-zero order.
> 
> It is a new caller and it can use a new function right?
> 
> > I agree it's a lot of churn without
> > good reason; that's why I tried to add GFP_ORDER flags a few months ago.
> > Unfortunately, you didn't like that approach either.
> 
> Is there any future plan that all/most __page_cache_alloc will get a
> non-zero order argument?

I'm not sure about "most".  It will certainly become more common, as
far as I can tell.

> > > Also is it so much to ask callers to provide __GFP_COMP explicitly?
> > 
> > Yes, it's an unreasonable burden on the callers.
> 
> Care to exaplain why? __GFP_COMP tends to be used in the kernel quite
> extensively.

Most of the places which call this function get their gfp_t from
mapping->gfp_mask.  If we only want to allocate a single page, we
must not set __GFP_COMP.  If we want to allocate a large page, we must
set __GFP_COMP.  Rather than require individual filesystems to concern
themselves with this wart of the GFP interface, we can solve it in the
page cache.


