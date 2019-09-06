Return-Path: <SRS0=SdaL=XB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.0 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 01997C43140
	for <linux-mm@archiver.kernel.org>; Fri,  6 Sep 2019 15:22:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B63702082C
	for <linux-mm@archiver.kernel.org>; Fri,  6 Sep 2019 15:22:35 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="uaVuV+Md"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B63702082C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5D7436B000E; Fri,  6 Sep 2019 11:22:35 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5AEB66B0271; Fri,  6 Sep 2019 11:22:35 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 49EBC6B0272; Fri,  6 Sep 2019 11:22:35 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0165.hostedemail.com [216.40.44.165])
	by kanga.kvack.org (Postfix) with ESMTP id 2815A6B000E
	for <linux-mm@kvack.org>; Fri,  6 Sep 2019 11:22:35 -0400 (EDT)
Received: from smtpin27.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id D0279824CA20
	for <linux-mm@kvack.org>; Fri,  6 Sep 2019 15:22:34 +0000 (UTC)
X-FDA: 75904862628.27.angle59_3393b42717623
X-HE-Tag: angle59_3393b42717623
X-Filterd-Recvd-Size: 3429
Received: from bombadil.infradead.org (bombadil.infradead.org [198.137.202.133])
	by imf37.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri,  6 Sep 2019 15:22:34 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=amsXgmLbCNJamwfFIFXn2rnERpGQbRQTjFgax85itYA=; b=uaVuV+Md9sVtTAcLDWASA+4QE
	i6DVVm9wwLUMbELe+8eKYNgi4x/TT4iZUo+lXfO5wWH/tf+qpK4HlJzJYg9kQXWW8QQIKn5JwGJ8t
	PhwPdZR2DnXHwvuDKo/Q7HcBv1vWTPJ1F3toteS57I7Mlsl+WoVHRTeFjLdjLMitIicxx63gK7De0
	48st8O4GzQtyilBROXP+GIOcgNBahQp3fiT4d/CAgphtHoKzbGI/HDqXKrJDqT3F6CwDebh94RU8Z
	OA9zMisn1l6mJRgdV6Gg1KBZaS2yHanvPDs/c4PObvZlINpO9QkFw33X8R5FHBQ6TNRC49SZoLmTt
	UaK3RhFgQ==;
Received: from willy by bombadil.infradead.org with local (Exim 4.92 #3 (Red Hat Linux))
	id 1i6G4H-0007Ix-9h; Fri, 06 Sep 2019 15:22:33 +0000
Date: Fri, 6 Sep 2019 08:22:33 -0700
From: Matthew Wilcox <willy@infradead.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org,
	Song Liu <songliubraving@fb.com>,
	William Kucharski <william.kucharski@oracle.com>,
	Johannes Weiner <jweiner@fb.com>
Subject: Re: [PATCH 3/3] mm: Allow find_get_page to be used for large pages
Message-ID: <20190906152230.GY29434@bombadil.infradead.org>
References: <20190905182348.5319-1-willy@infradead.org>
 <20190905182348.5319-4-willy@infradead.org>
 <20190906125928.urwopgpd66qibbil@box>
 <20190906134145.GW29434@bombadil.infradead.org>
 <20190906135215.f4qvsswrjaentvmi@box>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190906135215.f4qvsswrjaentvmi@box>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Sep 06, 2019 at 04:52:15PM +0300, Kirill A. Shutemov wrote:
> On Fri, Sep 06, 2019 at 06:41:45AM -0700, Matthew Wilcox wrote:
> > On Fri, Sep 06, 2019 at 03:59:28PM +0300, Kirill A. Shutemov wrote:
> > > > + * - FGP_PMD: We're only interested in pages at PMD granularity.  If there
> > > > + *   is no page here (and FGP_CREATE is set), we'll create one large enough.
> > > > + *   If there is a smaller page in the cache that overlaps the PMD page, we
> > > > + *   return %NULL and do not attempt to create a page.
> > > 
> > > Is it really the best inteface?
> > > 
> > > Maybe allow user to ask bitmask of allowed orders? For THP order-0 is fine
> > > if order-9 has failed.
> > 
> > That's the semantics that filemap_huge_fault() wants.  If the page isn't
> > available at order-9, it needs to return VM_FAULT_FALLBACK (and the VM
> > will call into filemap_fault() to handle the regular sized fault).
> 
> Ideally, we should not have division between ->fault and ->huge_fault.
> Integrating them together will give a shorter fallback loop and more
> flexible inteface here would give benefit.
> 
> But I guess it's out-of-scope of the patchset.

Heh, just a little bit ... there are about 150 occurrences of
vm_operations_struct in the kernel, and I don't fancy one bit converting
them all to use ->huge_fault instead of ->fault!

