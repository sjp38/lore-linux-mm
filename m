Return-Path: <SRS0=zrK/=W7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A8EDFC3A5A8
	for <linux-mm@archiver.kernel.org>; Wed,  4 Sep 2019 17:01:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 57DD021670
	for <linux-mm@archiver.kernel.org>; Wed,  4 Sep 2019 17:01:15 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 57DD021670
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=codewreck.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D89276B0003; Wed,  4 Sep 2019 13:01:14 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D394F6B0006; Wed,  4 Sep 2019 13:01:14 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C76BA6B0007; Wed,  4 Sep 2019 13:01:14 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0116.hostedemail.com [216.40.44.116])
	by kanga.kvack.org (Postfix) with ESMTP id A8E0B6B0003
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 13:01:14 -0400 (EDT)
Received: from smtpin02.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id 58CB0180AD804
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 17:01:14 +0000 (UTC)
X-FDA: 75897853668.02.roof93_44e27ddd97931
X-HE-Tag: roof93_44e27ddd97931
X-Filterd-Recvd-Size: 4560
Received: from nautica.notk.org (nautica.notk.org [91.121.71.147])
	by imf07.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 17:01:13 +0000 (UTC)
Received: by nautica.notk.org (Postfix, from userid 1001)
	id 94F13C009; Wed,  4 Sep 2019 19:01:11 +0200 (CEST)
Date: Wed, 4 Sep 2019 19:00:56 +0200
From: Dominique Martinet <asmadeus@codewreck.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: linux-mm@kvack.org
Subject: Re: How to use huge pages in drivers?
Message-ID: <20190904170056.GA9825@nautica>
References: <20190903182627.GA6079@nautica>
 <20190903184230.GJ29434@bombadil.infradead.org>
 <20190903212815.GA7518@nautica>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20190903212815.GA7518@nautica>
User-Agent: Mutt/1.5.21 (2010-09-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Dominique Martinet wrote on Tue, Sep 03, 2019:
> Matthew Wilcox wrote on Tue, Sep 03, 2019:
> > > What I'd like to know is:
> > >  - we know (assuming the other side isn't too bugged, but if it is we're
> > > fucked up anyway) exactly what huge-page-sized physical memory range has
> > > been mapped on the other side, is there a way to manually gather the
> > > pages corresponding and merge them into a huge page?
> > 
> > You're using the word 'page' here, but I suspect what you really mean is
> > "pfn" or "pte".  As you've described it, it doesn't matter what data structure
> > Linux is using for the memory, since Linux doesn't know about the memory.
> 
> Correct, we're already using vmf_insert_pfn

Actually let me take that back, vmf_insert_pfn is only used if
pfn_valid() is false, probably as a safeguard of sort(?).
The normal case went with pfn_to_page(pfn) + vm_insert_page() so, as
things stands.
I do have a few more questions if you could humor me a bit more...

 - the vma was created with a vm_flags including VM_MIXEDMAP for some
reason, I don't know why.
If I change it to VM_PFNMAP (which sounds better here from the little I
understand of this as we do not need cow and looks a bit simpler?), I
can remove the vm_insert_page() path and use the vmf_insert_pfn one
instead, which appears to work fine for simple programs... But the
kernel thread for my network adapter (bxi... which is not upstream
either I guess.. sigh..) no longer tries to fault via my custom .fault
vm operation... Which means I probably did need MIXEDMAP ?

I'm honestly not sure where to read up on what these two flags imply,
looking at the page fault handler code I do not see why the request from
a kernel thread would care what kind of vma it is...


 - ignoring that for now (it's not like I need to switch to PFNMAP);
adding vmf_insert_pfn_pmd() for when the remote side uses large pages,
it complains that the vmf->pmd is not a pmd_none nor huge nor a devmap
(this check appears specific to rhel7 kernel, I could temporarily test
with an upstream kernel but the network adapter won't work there so I'll
need this to work on this ultimately)

It looks like handle_mm_fault() will always try to allocate a pmd so it
should never be empty in my fault handler, and I don't see anything else
than vmf_insert_pfn_pmd() setting the mkdevmap flag, and it's not huge
either...
(on a dump, the the pmd content is 175cb18067, so these flags according
to crash for x86_64 are (PRESENT|RW|USER|ACCESSED|DIRTY))

I tried adding a huge_fault vm op thinking it might be called with a
more appropriate pmd but it doesn't seem to be called at all in my
case..? I would have assumed from the code that it would try every page

and if I try to somehow force it by using pmd_mkdevmap on the vmf->pmd,
things appear to work until the process exits and zap_page does a null
deref on pgtable_trans_huge_withdraw because the pgtable was never
deposited - this looks gone on newer kernels, but once again I do not
see where these should come from; I'm just assuming I reap what I sew
messing with the flags.



Long story short, I think I have some deeper undestanding problem about
the whole thing. Do I also need to use some specific flags when that
special file is mmap'd to allow huge_fault to be called ?
I think transparent_hugepage_enabled(vma) is fine, but the vmf.pmd found
in __handle_mm_fault is probably already not none at this point...?



Thanks again, feel free to ignore me for a bit longer I'll keep digging
my own grave, writing to a rubber duck that might have an idea of how
far the wrong way I've gone already helps... :D
-- 
Dominique


