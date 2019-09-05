Return-Path: <SRS0=ftCo=XA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BDE82C43331
	for <linux-mm@archiver.kernel.org>; Thu,  5 Sep 2019 18:51:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7213320825
	for <linux-mm@archiver.kernel.org>; Thu,  5 Sep 2019 18:51:07 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7213320825
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=codewreck.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F3F9F6B0003; Thu,  5 Sep 2019 14:51:05 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EEFC66B0005; Thu,  5 Sep 2019 14:51:05 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E05D86B0007; Thu,  5 Sep 2019 14:51:05 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0055.hostedemail.com [216.40.44.55])
	by kanga.kvack.org (Postfix) with ESMTP id B999E6B0003
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 14:51:05 -0400 (EDT)
Received: from smtpin18.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id 5D3E0180AD801
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 18:51:05 +0000 (UTC)
X-FDA: 75901759290.18.bikes35_43a4e9a24c821
X-HE-Tag: bikes35_43a4e9a24c821
X-Filterd-Recvd-Size: 4140
Received: from nautica.notk.org (nautica.notk.org [91.121.71.147])
	by imf21.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 18:51:04 +0000 (UTC)
Received: by nautica.notk.org (Postfix, from userid 1001)
	id 4A755C009; Thu,  5 Sep 2019 20:51:03 +0200 (CEST)
Date: Thu, 5 Sep 2019 20:50:48 +0200
From: Dominique Martinet <asmadeus@codewreck.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: linux-mm@kvack.org
Subject: Re: How to use huge pages in drivers?
Message-ID: <20190905185048.GA23588@nautica>
References: <20190903182627.GA6079@nautica>
 <20190903184230.GJ29434@bombadil.infradead.org>
 <20190903212815.GA7518@nautica>
 <20190904170056.GA9825@nautica>
 <20190904175032.GL29434@bombadil.infradead.org>
 <20190905154400.GA30549@nautica>
 <20190905181555.GQ29434@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20190905181555.GQ29434@bombadil.infradead.org>
User-Agent: Mutt/1.5.21 (2010-09-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Matthew Wilcox wrote on Thu, Sep 05, 2019:
> On Thu, Sep 05, 2019 at 05:44:00PM +0200, Dominique Martinet wrote:
> > Question though - is it ok to insert small pages if the huge_fault
> > handler is called with PE_SIZE_PMD ?
> > (I think the pte insertion will automatically create the pmd, but would
> > be good to confirm)
> 
> No, you need to return VM_FAULT_FALLBACK, at which point the generic code
> will create a PMD for you and then call your ->fault handler which can
> insert PTEs.

Hmm, that's a shame actually.
There is a rather costly round-trip between linux and mckernel to
determine what page size is used for this virtual address on the remote
side and to get the corresponding physical address, so basically when we
get the fault we do know know if this will be a PMD or PTE. 

I'd rather avoid having to do one round-trip at the PMD stage, get told
this is a PTE, temporarily give up and wait to be called again with
PE_SIZE_PTE and do a second round-trip in this case.
I didn't see anywhere in the vm_fault struct that I could piggy-back to
remember something from the previous call, and I'm pretty sure it would
be a bad idea to use the vma's vm_private_data here because there could
be multiple faults in parallel on other threads.


Looking at vmf_insert_pfn(), it will allocate a pmd because of
insert_pfn's get_locked_pte, so it does end up working (I never return a
page - we always return VM_FAULT_NOPAGE on success, so I do not see the
harm in doing it early if we can)

Following the code in __handle_vm_fault assuming the pmd fault would
have returned fallback I do not see any harm here - the pmd actually
already has been allocated here (at pmd level fault), it's just set to
none.

Not exactly pretty, though, and very definitely no guarantee it'll keep
working... I'll stick a comment saying what we should do at least :P

> It works the same way from PUDs to PMDs by the way, in case you ever
> have a 1GB mapping ;-)

Yes, already returning fallback in this case - but I'm just assuming
that won't happen so no round-trip here :)


> > Now that I've set it as dax I think it actually makes sense as in
> > "there's memory here that points to something linux no longer manages
> > directly, just let it be" and we might benefit from the other exceptions
> > dax have, I'll need to look at what this implies in more details...
> 
> I think that should be fine, but I don't really know RHEL 7.3 all that
> well ;-)

Good enough for me, tests will tell me what I broke :)


> No problem ... these APIs are relatively new and not necessarily all
> that intuitive.

Looking at a recent vanilla linux on evening and rhel's kernel at work
didn't help on my side (some fun differences like the VM_HUGE_FAULT flag
in the vma, but now I understand it was added for abi compatibility it
does make sense after I found about it - on an older module the function
could just have been left uninitialized and thus non-null yet not valid)

Definitely did help to point at huge_fault() again.


Thanks,
-- 
Dominique

