Return-Path: <SRS0=9FL3=UX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_MUTT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 36CEEC48BE9
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 16:52:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F0861204EC
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 16:52:15 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F0861204EC
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 790F48E0003; Mon, 24 Jun 2019 12:52:15 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7489C8E0002; Mon, 24 Jun 2019 12:52:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 609028E0003; Mon, 24 Jun 2019 12:52:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 113808E0002
	for <linux-mm@kvack.org>; Mon, 24 Jun 2019 12:52:15 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id b21so21205325edt.18
        for <linux-mm@kvack.org>; Mon, 24 Jun 2019 09:52:15 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=vnaYT7xz8hzZ9utgOxwBGCOEmkU1KLZSf5Bef1pBtfE=;
        b=Vh6LxSwtwybnZdDkHEsGdAIXzXdBwUy3ZlVYH7mbnN6PZHacW/gSij9LlS+35CfhK7
         GR8EW+UMV8OMEFa9+bvHHc8qhA6y8Z3gzg5jR6yb4sX/N5no75B7h6PTdfwS/aJgY5h1
         2xDLmLBAsfg+ENIt7i5BETC+HcXjAPyUxWVpyxQZwG3Oq9W849mJKrI+utgCxv09Qy2s
         Kjj/Yv5rtk6xiQEM6FSVqqYr8WtWimrn5id8oNzYriP3nFd9yAn99903DXKi7Dty3mGc
         ffWuur4ul49z0ERRlKSwEzmTkqA2jaoM6L9UEj2NTCBzvcG+mpf2RJbuxOuWBhBn1KBw
         M7XQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mark.rutland@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=mark.rutland@arm.com
X-Gm-Message-State: APjAAAVW2XqBETEEDyw5aYa63hbMXvOd5sp/g6PKAGay2rossiOi5UZ+
	WEntBPq4nYsG1ivygNd0qD1GH3wN3mcXJAjsNRevlYWLkdiHR6EBdNjZPqXNGfmctgSBC7vI/jO
	Ry8tiyUPHEf0gWI7rA2Zgz+PunDychz17zNfq9dAyITO9MghqksS3fseN/LesRClQbA==
X-Received: by 2002:a05:6402:1801:: with SMTP id g1mr72500331edy.262.1561395134613;
        Mon, 24 Jun 2019 09:52:14 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwG7se8RUAq7NoQiXhNcXx3Ku6Mxa4syQN9Kf4tIxuYE5zy1tCks2eLaYlWIvAecbUKxqoW
X-Received: by 2002:a05:6402:1801:: with SMTP id g1mr72500245edy.262.1561395133673;
        Mon, 24 Jun 2019 09:52:13 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561395133; cv=none;
        d=google.com; s=arc-20160816;
        b=HY9OJ8tEC7XtSwvdV1dXy+cnJc7/XHJYzI4a27H2Xd9USqs6Qs/ME1A63H5E9p6pIz
         XoYaX+GrNDSfYMkuPkjjeS7E/1pnQSaSTmZ1MmhL+LmwPutoMkK2O/n2utFxK4wrzjvT
         rd3SrBiX82VF6Im92lpnUYLYqqXRdm9ky+pX/+B5P7oYTtiGLcOfrlh82/+JeVNj9g7c
         /6bRq57KIbCj2HAlJK26Vb/l4nz+LqgTmvNQx+NsbSeAjNpo3BBN9If8VHo/uerj/rw3
         yoo2MELbP9pGct3vulGzFnMymw9a19IOxNmjNXzFDVRbe3wu4Td8bW4hc/sZhW+g/kGi
         iBbg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=vnaYT7xz8hzZ9utgOxwBGCOEmkU1KLZSf5Bef1pBtfE=;
        b=aqFeOu4XI84YWqGkG69BoAqfYSAMXuwl0M86obF2lTAHnJ9xqfstqFpHrbfL8XbwzM
         HTymKXffMuaSigmwKPCAYqJGS1LMaIh/jZtEMIQ3FCzXBooXJvk3EZMz+4oTq7hw7PYY
         hyZiZzzal9Hb3DgB349Mri+lqbQedgnYJAiIC27c5N/t4mm8u7R2StQJq81gQ3TVqqVY
         /u4f45GtK55mSXu1JjEXrS640LKtakXxOCTY1kIf24WDAh/T5YceoAS+aAsm8RwJUYNJ
         tmGv0VetOFAUCVnwUNAude7Ay5hVn6GS8XqMiKspP2gI1D2SVvRM7hpb6JBaH7K+Qp7L
         hq/Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mark.rutland@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=mark.rutland@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id v1si7310911ejv.304.2019.06.24.09.52.13
        for <linux-mm@kvack.org>;
        Mon, 24 Jun 2019 09:52:13 -0700 (PDT)
Received-SPF: pass (google.com: domain of mark.rutland@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mark.rutland@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=mark.rutland@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id ABF5E360;
	Mon, 24 Jun 2019 09:52:12 -0700 (PDT)
Received: from lakrids.cambridge.arm.com (usa-sjc-imap-foss1.foss.arm.com [10.121.207.14])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 223FE3F71E;
	Mon, 24 Jun 2019 09:52:10 -0700 (PDT)
Date: Mon, 24 Jun 2019 17:52:01 +0100
From: Mark Rutland <mark.rutland@arm.com>
To: Steve Capper <Steve.Capper@arm.com>
Cc: Anshuman Khandual <Anshuman.Khandual@arm.com>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>,
	"akpm@linux-foundation.org" <akpm@linux-foundation.org>,
	Catalin Marinas <Catalin.Marinas@arm.com>,
	Will Deacon <Will.Deacon@arm.com>,
	"mhocko@suse.com" <mhocko@suse.com>,
	"ira.weiny@intel.com" <ira.weiny@intel.com>,
	"david@redhat.com" <david@redhat.com>, "cai@lca.pw" <cai@lca.pw>,
	"logang@deltatee.com" <logang@deltatee.com>,
	James Morse <James.Morse@arm.com>,
	"cpandya@codeaurora.org" <cpandya@codeaurora.org>,
	"arunks@codeaurora.org" <arunks@codeaurora.org>,
	"dan.j.williams@intel.com" <dan.j.williams@intel.com>,
	"mgorman@techsingularity.net" <mgorman@techsingularity.net>,
	"osalvador@suse.de" <osalvador@suse.de>,
	Ard Biesheuvel <Ard.Biesheuvel@arm.com>, nd <nd@arm.com>
Subject: Re: [PATCH V6 3/3] arm64/mm: Enable memory hot remove
Message-ID: <20190624165148.GA9847@lakrids.cambridge.arm.com>
References: <1560917860-26169-1-git-send-email-anshuman.khandual@arm.com>
 <1560917860-26169-4-git-send-email-anshuman.khandual@arm.com>
 <20190621143540.GA3376@capper-debian.cambridge.arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190621143540.GA3376@capper-debian.cambridge.arm.com>
User-Agent: Mutt/1.11.1+11 (2f07cb52) (2018-12-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jun 21, 2019 at 03:35:53PM +0100, Steve Capper wrote:
> Hi Anshuman,
> 
> On Wed, Jun 19, 2019 at 09:47:40AM +0530, Anshuman Khandual wrote:
> > The arch code for hot-remove must tear down portions of the linear map and
> > vmemmap corresponding to memory being removed. In both cases the page
> > tables mapping these regions must be freed, and when sparse vmemmap is in
> > use the memory backing the vmemmap must also be freed.
> > 
> > This patch adds a new remove_pagetable() helper which can be used to tear
> > down either region, and calls it from vmemmap_free() and
> > ___remove_pgd_mapping(). The sparse_vmap argument determines whether the
> > backing memory will be freed.
> > 
> > remove_pagetable() makes two distinct passes over the kernel page table.
> > In the first pass it unmaps, invalidates applicable TLB cache and frees
> > backing memory if required (vmemmap) for each mapped leaf entry. In the
> > second pass it looks for empty page table sections whose page table page
> > can be unmapped, TLB invalidated and freed.
> > 
> > While freeing intermediate level page table pages bail out if any of its
> > entries are still valid. This can happen for partially filled kernel page
> > table either from a previously attempted failed memory hot add or while
> > removing an address range which does not span the entire page table page
> > range.
> > 
> > The vmemmap region may share levels of table with the vmalloc region.
> > There can be conflicts between hot remove freeing page table pages with
> > a concurrent vmalloc() walking the kernel page table. This conflict can
> > not just be solved by taking the init_mm ptl because of existing locking
> > scheme in vmalloc(). Hence unlike linear mapping, skip freeing page table
> > pages while tearing down vmemmap mapping.
> > 
> > While here update arch_add_memory() to handle __add_pages() failures by
> > just unmapping recently added kernel linear mapping. Now enable memory hot
> > remove on arm64 platforms by default with ARCH_ENABLE_MEMORY_HOTREMOVE.
> > 
> > This implementation is overall inspired from kernel page table tear down
> > procedure on X86 architecture.
> > 
> > Acked-by: David Hildenbrand <david@redhat.com>
> > Signed-off-by: Anshuman Khandual <anshuman.khandual@arm.com>
> > ---
> 
> FWIW:
> Acked-by: Steve Capper <steve.capper@arm.com>
> 
> One minor comment below though.
> 
> >  arch/arm64/Kconfig  |   3 +
> >  arch/arm64/mm/mmu.c | 290 ++++++++++++++++++++++++++++++++++++++++++++++++++--
> >  2 files changed, 284 insertions(+), 9 deletions(-)
> > 
> > diff --git a/arch/arm64/Kconfig b/arch/arm64/Kconfig
> > index 6426f48..9375f26 100644
> > --- a/arch/arm64/Kconfig
> > +++ b/arch/arm64/Kconfig
> > @@ -270,6 +270,9 @@ config HAVE_GENERIC_GUP
> >  config ARCH_ENABLE_MEMORY_HOTPLUG
> >  	def_bool y
> >  
> > +config ARCH_ENABLE_MEMORY_HOTREMOVE
> > +	def_bool y
> > +
> >  config SMP
> >  	def_bool y
> >  
> > diff --git a/arch/arm64/mm/mmu.c b/arch/arm64/mm/mmu.c
> > index 93ed0df..9e80a94 100644
> > --- a/arch/arm64/mm/mmu.c
> > +++ b/arch/arm64/mm/mmu.c
> > @@ -733,6 +733,250 @@ int kern_addr_valid(unsigned long addr)
> >  
> >  	return pfn_valid(pte_pfn(pte));
> >  }
> > +
> > +#ifdef CONFIG_MEMORY_HOTPLUG
> > +static void free_hotplug_page_range(struct page *page, size_t size)
> > +{
> > +	WARN_ON(!page || PageReserved(page));
> > +	free_pages((unsigned long)page_address(page), get_order(size));
> > +}
> 
> We are dealing with power of 2 number of pages, it makes a lot more
> sense (to me) to replace the size parameter with order.
> 
> Also, all the callers are for known compile-time sizes, so we could just
> translate the size parameter as follows to remove any usage of get_order?
> PAGE_SIZE -> 0
> PMD_SIZE -> PMD_SHIFT - PAGE_SHIFT
> PUD_SIZE -> PUD_SHIFT - PAGE_SHIFT

Now that I look at this again, the above makes sense to me.

I'd requested the current form (which I now realise is broken), since
back in v2 the code looked like:

static void free_pagetable(struct page *page, int order)
{
	...
	free_pages((unsigned long)page_address(page), order);
	...
}

... with callsites looking like:

free_pagetable(pud_page(*pud), get_order(PUD_SIZE));

... which I now see is off by PAGE_SHIFT, and we inherited that bug in
the current code, so the calculated order is vastly larger than it
should be. It's worrying that doesn't seem to be caught by anything in
testing. :/

Anshuman, could you please fold in Steve's suggested change? I'll look
at the rest of the series shortly, so no need to resend that right away,
but it would be worth sorting out.

Thanks,
Mark.

