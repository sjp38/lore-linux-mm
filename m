Return-Path: <SRS0=ftCo=XA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D1533C00306
	for <linux-mm@archiver.kernel.org>; Thu,  5 Sep 2019 15:44:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 31509206BB
	for <linux-mm@archiver.kernel.org>; Thu,  5 Sep 2019 15:44:19 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 31509206BB
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=codewreck.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 175306B026C; Thu,  5 Sep 2019 11:44:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0FEFA6B026E; Thu,  5 Sep 2019 11:44:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F2F4B6B026F; Thu,  5 Sep 2019 11:44:17 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0229.hostedemail.com [216.40.44.229])
	by kanga.kvack.org (Postfix) with ESMTP id CC2EE6B026C
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 11:44:17 -0400 (EDT)
Received: from smtpin10.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id 694A8180AD7C3
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 15:44:17 +0000 (UTC)
X-FDA: 75901288554.10.badge37_2560ccf889924
X-HE-Tag: badge37_2560ccf889924
X-Filterd-Recvd-Size: 3873
Received: from nautica.notk.org (nautica.notk.org [91.121.71.147])
	by imf23.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 15:44:16 +0000 (UTC)
Received: by nautica.notk.org (Postfix, from userid 1001)
	id 0F415C009; Thu,  5 Sep 2019 17:44:15 +0200 (CEST)
Date: Thu, 5 Sep 2019 17:44:00 +0200
From: Dominique Martinet <asmadeus@codewreck.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: linux-mm@kvack.org
Subject: Re: How to use huge pages in drivers?
Message-ID: <20190905154400.GA30549@nautica>
References: <20190903182627.GA6079@nautica>
 <20190903184230.GJ29434@bombadil.infradead.org>
 <20190903212815.GA7518@nautica>
 <20190904170056.GA9825@nautica>
 <20190904175032.GL29434@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20190904175032.GL29434@bombadil.infradead.org>
User-Agent: Mutt/1.5.21 (2010-09-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Matthew Wilcox wrote on Wed, Sep 04, 2019:
> >  - the vma was created with a vm_flags including VM_MIXEDMAP for some
> > reason, I don't know why.
> > If I change it to VM_PFNMAP (which sounds better here from the little I
> > understand of this as we do not need cow and looks a bit simpler?), I
> > can remove the vm_insert_page() path and use the vmf_insert_pfn one
> > instead, which appears to work fine for simple programs... But the
> > kernel thread for my network adapter (bxi... which is not upstream
> > either I guess.. sigh..) no longer tries to fault via my custom .fault
> > vm operation... Which means I probably did need MIXEDMAP ?
> 
> Strange ... PFNMAP absolutely should try to fault via the ->fault
> vm operation (although see below)

It does fault in some context, just not in another.. A bit weird but
I'll stick to MIXEDMAP for now - I'm really curious as to what the
difference is, "normal" applications seem to work fine with either mode,
it's only the bxi driver that 

> > I tried adding a huge_fault vm op thinking it might be called with a
> > more appropriate pmd but it doesn't seem to be called at all in my
> > case..? I would have assumed from the code that it would try every page
> 
> You shouldn't be calling vmf_insert_pfn_pmd() from a regular ->fault
> handler, as by then the fault handler has already inserted a PMD.
> The ->huge_fault handler is the place to call it from.
> 
> You may need to force PMD-alignment for your call to mmap().

I was missing setting the VM_HUGE_FAULT vm_flags2 bit in the vma - the
huge_fault handler is now called, and I no longer have the pre-existing
pmd problem; that's a much better solution than manually fiddling with
flags :)

Question though - is it ok to insert small pages if the huge_fault
handler is called with PE_SIZE_PMD ?
(I think the pte insertion will automatically create the pmd, but would
be good to confirm)


Now I've got this I'm back to where I stood with my kludge though,
programs work until they exit, and the zap_huge_pmd() function tries to
withdraw the pagetable from some magic field that was never set in my
case... I realize this is old code no longer upstream, but my new
workaround for this (looking at the zap_huge_pmd function) was to
pretend my file is dax.
Now that I've set it as dax I think it actually makes sense as in
"there's memory here that points to something linux no longer manages
directly, just let it be" and we might benefit from the other exceptions
dax have, I'll need to look at what this implies in more details...


> Hope these pointers are slightly more useful than a rubber duck ;-)

Much appreciated, thank you for taking the time! :)

Off to debug my network driver for the PFNMAP behaviour next, and then
some more testing... I'm sure I broke something seemingly unrelated on
the other side of the project!

-- 
Dominique

