Return-Path: <SRS0=2Zku=W5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 65180C3A5A7
	for <linux-mm@archiver.kernel.org>; Mon,  2 Sep 2019 14:54:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 34AD32173E
	for <linux-mm@archiver.kernel.org>; Mon,  2 Sep 2019 14:54:59 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 34AD32173E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B81556B0003; Mon,  2 Sep 2019 10:54:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B32286B0006; Mon,  2 Sep 2019 10:54:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A473F6B0007; Mon,  2 Sep 2019 10:54:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0064.hostedemail.com [216.40.44.64])
	by kanga.kvack.org (Postfix) with ESMTP id 7DFB46B0003
	for <linux-mm@kvack.org>; Mon,  2 Sep 2019 10:54:58 -0400 (EDT)
Received: from smtpin23.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 0743E6C2F
	for <linux-mm@kvack.org>; Mon,  2 Sep 2019 14:54:58 +0000 (UTC)
X-FDA: 75890277876.23.truck94_e1d2c272571d
X-HE-Tag: truck94_e1d2c272571d
X-Filterd-Recvd-Size: 4189
Received: from foss.arm.com (foss.arm.com [217.140.110.172])
	by imf14.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon,  2 Sep 2019 14:54:56 +0000 (UTC)
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id B66DF344;
	Mon,  2 Sep 2019 07:54:55 -0700 (PDT)
Received: from lakrids.cambridge.arm.com (usa-sjc-imap-foss1.foss.arm.com [10.121.207.14])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 2BC303F59C;
	Mon,  2 Sep 2019 07:54:54 -0700 (PDT)
Date: Mon, 2 Sep 2019 15:54:45 +0100
From: Mark Rutland <mark.rutland@arm.com>
To: Daniel Axtens <dja@axtens.net>
Cc: kasan-dev@googlegroups.com, linux-mm@kvack.org, x86@kernel.org,
	aryabinin@virtuozzo.com, glider@google.com, luto@kernel.org,
	linux-kernel@vger.kernel.org, dvyukov@google.com,
	christophe.leroy@c-s.fr, linuxppc-dev@lists.ozlabs.org,
	gor@linux.ibm.com
Subject: Re: [PATCH v6 1/5] kasan: support backing vmalloc space with real
 shadow memory
Message-ID: <20190902145445.GA12400@lakrids.cambridge.arm.com>
References: <20190902112028.23773-1-dja@axtens.net>
 <20190902112028.23773-2-dja@axtens.net>
 <20190902132220.GA9922@lakrids.cambridge.arm.com>
 <87pnkiu5ta.fsf@dja-thinkpad.axtens.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87pnkiu5ta.fsf@dja-thinkpad.axtens.net>
User-Agent: Mutt/1.11.1+11 (2f07cb52) (2018-12-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Sep 03, 2019 at 12:32:49AM +1000, Daniel Axtens wrote:
> Hi Mark,
> 
> >> +static int kasan_depopulate_vmalloc_pte(pte_t *ptep, unsigned long addr,
> >> +					void *unused)
> >> +{
> >> +	unsigned long page;
> >> +
> >> +	page = (unsigned long)__va(pte_pfn(*ptep) << PAGE_SHIFT);
> >> +
> >> +	spin_lock(&init_mm.page_table_lock);
> >> +
> >> +	if (likely(!pte_none(*ptep))) {
> >> +		pte_clear(&init_mm, addr, ptep);
> >> +		free_page(page);
> >> +	}
> >> +	spin_unlock(&init_mm.page_table_lock);
> >> +
> >> +	return 0;
> >> +}
> >
> > There needs to be TLB maintenance after unmapping the page, but I don't
> > see that happening below.
> >
> > We need that to ensure that errant accesses don't hit the page we're
> > freeing and that new mappings at the same VA don't cause a TLB conflict
> > or TLB amalgamation issue.
> 
> Darn it, I knew there was something I forgot to do! I thought of that
> over the weekend, didn't write it down, and then forgot it when I went
> to respin the patches. You're totally right.
> 
> >
> >> +/*
> >> + * Release the backing for the vmalloc region [start, end), which
> >> + * lies within the free region [free_region_start, free_region_end).
> >> + *
> >> + * This can be run lazily, long after the region was freed. It runs
> >> + * under vmap_area_lock, so it's not safe to interact with the vmalloc/vmap
> >> + * infrastructure.
> >> + */
> >
> > IIUC we aim to only free non-shared shadow by aligning the start
> > upwards, and aligning the end downwards. I think it would be worth
> > mentioning that explicitly in the comment since otherwise it's not
> > obvious how we handle races between alloc/free.
> >
> 
> Oh, I will need to think through that more carefully.
> 
> I think the vmap_area_lock protects us against alloc/free races.

AFAICT, on the alloc side we only hold the vmap_area_lock while
allocating the area in __get_vm_area_node(), but we don't holding the
vmap_area_lock while we populate the page tables for the shadow in
kasan_populate_vmalloc().

So I believe that kasan_populate_vmalloc() can race with
kasan_release_vmalloc().

> I think alignment operates at least somewhat as you've described, and
> while it is important for correctness, I'm not sure I'd say it
> prevented races? I will double check my understanding of
> vmap_area_lock, and I agree the comment needs to be much clearer.

I had assumed that you were trying to only free pages which were
definitely not shared (for which there couldn't possibly be a race to
allocate), by looking at the sibling areas to see if they potentially
overlapped.

Was that not the case?

Thanks,
Mark.

