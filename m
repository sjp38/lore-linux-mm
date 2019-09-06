Return-Path: <SRS0=SdaL=XB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.0 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8DDF7C43331
	for <linux-mm@archiver.kernel.org>; Fri,  6 Sep 2019 13:41:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3005420650
	for <linux-mm@archiver.kernel.org>; Fri,  6 Sep 2019 13:41:50 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="osdq9PRz"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3005420650
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 90A1E6B0007; Fri,  6 Sep 2019 09:41:49 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8934F6B0008; Fri,  6 Sep 2019 09:41:49 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 75BBD6B000A; Fri,  6 Sep 2019 09:41:49 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0125.hostedemail.com [216.40.44.125])
	by kanga.kvack.org (Postfix) with ESMTP id 4F5426B0007
	for <linux-mm@kvack.org>; Fri,  6 Sep 2019 09:41:49 -0400 (EDT)
Received: from smtpin30.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id E2550181AC9AE
	for <linux-mm@kvack.org>; Fri,  6 Sep 2019 13:41:48 +0000 (UTC)
X-FDA: 75904608696.30.print71_2cd472d3faa26
X-HE-Tag: print71_2cd472d3faa26
X-Filterd-Recvd-Size: 5464
Received: from bombadil.infradead.org (bombadil.infradead.org [198.137.202.133])
	by imf27.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri,  6 Sep 2019 13:41:47 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=eegmsTGmsjmxw5HJRa10m4NP4ml+VRXyFSqt/YxL7Zk=; b=osdq9PRzTHhnM8bKrfYV9bnhT
	OxjygjzekyVrs9BeOpbFjdiwDpZZGtL3LLo0/So0jLvXEpDA7C5B5mOnPMl5AK7+5wx8hDY7fIL8R
	W+Z+qvAWQ4sBhQ4KdKV46mZ1hiMSAC+2tfDKwddikTEkf1WZzPQ/+68k0ZWkBo/dJg9HGqLEqRsxd
	T5pjVdxvTWS8ffeF/XrNGnXyJ3XHSD+8Ylloo1IWuRndopnzrr+epFJmALELupnl/TDhzrvCINFrW
	cIuCuXQ9+Cnr/iqyxJ7m0sKugEnVCAzgP260WQhjWpOIQAIrLfewbGEZHH01ANfSe8NvsV9mYbrkr
	QfTk+Wepw==;
Received: from willy by bombadil.infradead.org with local (Exim 4.92 #3 (Red Hat Linux))
	id 1i6EUj-0003Cg-8a; Fri, 06 Sep 2019 13:41:45 +0000
Date: Fri, 6 Sep 2019 06:41:45 -0700
From: Matthew Wilcox <willy@infradead.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org,
	Song Liu <songliubraving@fb.com>,
	William Kucharski <william.kucharski@oracle.com>,
	Johannes Weiner <jweiner@fb.com>
Subject: Re: [PATCH 3/3] mm: Allow find_get_page to be used for large pages
Message-ID: <20190906134145.GW29434@bombadil.infradead.org>
References: <20190905182348.5319-1-willy@infradead.org>
 <20190905182348.5319-4-willy@infradead.org>
 <20190906125928.urwopgpd66qibbil@box>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190906125928.urwopgpd66qibbil@box>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Sep 06, 2019 at 03:59:28PM +0300, Kirill A. Shutemov wrote:
> > @@ -248,6 +248,15 @@ pgoff_t page_cache_prev_miss(struct address_space *mapping,
> >  #define FGP_NOFS		0x00000010
> >  #define FGP_NOWAIT		0x00000020
> >  #define FGP_FOR_MMAP		0x00000040
> > +/*
> > + * If you add more flags, increment FGP_ORDER_SHIFT (no further than 25).
> 
> Maybe some BUILD_BUG_ON()s to ensure FGP_ORDER_SHIFT is sane?

Yeah, probably a good idea.

> > +/**
> > + * __find_get_page - Find and get a page cache entry.
> > + * @mapping: The address_space to search.
> > + * @offset: The page cache index.
> > + * @order: The minimum order of the entry to return.
> > + *
> > + * Looks up the page cache entries at @mapping between @offset and
> > + * @offset + 2^@order.  If there is a page cache page, it is returned with
> 
> Off by one? :P

Hah!  I thought it reasonable to be ambiguous in the English description
...  it's not entirely uncommon to describe something being 'between A
and B' when meaning ">= A and < B".

> > +static struct page *__find_get_page(struct address_space *mapping,
> > +		unsigned long offset, unsigned int order)
> > +{
> > +	XA_STATE(xas, &mapping->i_pages, offset);
> > +	struct page *page;
> > +
> > +	rcu_read_lock();
> > +repeat:
> > +	xas_reset(&xas);
> > +	page = xas_find(&xas, offset | ((1UL << order) - 1));
> 
> Hm. '|' is confusing. What is expectation about offset?
> Is round_down(offset, 1UL << order) expected to be equal offset?
> If yes, please use '+' instead of '|'.

Might make sense to put in ...

	VM_BUG_ON(offset & ((1UL << order) - 1));

> > +	if (xas_retry(&xas, page))
> > +		goto repeat;
> > +	/*
> > +	 * A shadow entry of a recently evicted page, or a swap entry from
> > +	 * shmem/tmpfs.  Skip it; keep looking for pages.
> > +	 */
> > +	if (xa_is_value(page))
> > +		goto repeat;
> > +	if (!page)
> > +		goto out;
> > +	if (compound_order(page) < order) {
> > +		page = XA_RETRY_ENTRY;
> > +		goto out;
> > +	}
> 
> compound_order() is not stable if you don't have pin on the page.
> Check it after page_cache_get_speculative().

Maybe check both before and after?  If we check it before, we don't bother
to bump the refcount on a page which is too small.

> > @@ -1632,6 +1696,10 @@ EXPORT_SYMBOL(find_lock_entry);
> >   * - FGP_FOR_MMAP: Similar to FGP_CREAT, only we want to allow the caller to do
> >   *   its own locking dance if the page is already in cache, or unlock the page
> >   *   before returning if we had to add the page to pagecache.
> > + * - FGP_PMD: We're only interested in pages at PMD granularity.  If there
> > + *   is no page here (and FGP_CREATE is set), we'll create one large enough.
> > + *   If there is a smaller page in the cache that overlaps the PMD page, we
> > + *   return %NULL and do not attempt to create a page.
> 
> Is it really the best inteface?
> 
> Maybe allow user to ask bitmask of allowed orders? For THP order-0 is fine
> if order-9 has failed.

That's the semantics that filemap_huge_fault() wants.  If the page isn't
available at order-9, it needs to return VM_FAULT_FALLBACK (and the VM
will call into filemap_fault() to handle the regular sized fault).

Now, maybe there are other users who want to specify "create a page of
this size if you can, but if there's already something there smaller,
return that".  We can add another FGP flag when those show up ;-)


Thanks for the review.

