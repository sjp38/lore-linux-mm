Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 4D1836B0279
	for <linux-mm@kvack.org>; Mon, 12 Jun 2017 10:31:58 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id l128so35717207iol.12
        for <linux-mm@kvack.org>; Mon, 12 Jun 2017 07:31:58 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id g197sor3019312itg.37.2017.06.12.07.31.57
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 12 Jun 2017 07:31:57 -0700 (PDT)
Date: Mon, 12 Jun 2017 08:31:55 -0600
From: Tycho Andersen <tycho@docker.com>
Subject: Re: [RFC v4 3/3] xpfo: add support for hugepages
Message-ID: <20170612143155.j6f63nijpij77a7t@smitten>
References: <20170607211653.14536-1-tycho@docker.com>
 <20170607211653.14536-4-tycho@docker.com>
 <d8d4070e-a97d-c431-74ad-5ba1a30b5e18@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <d8d4070e-a97d-c431-74ad-5ba1a30b5e18@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laura Abbott <labbott@redhat.com>
Cc: linux-mm@kvack.org, Juerg Haefliger <juergh@gmail.com>, kernel-hardening@lists.openwall.com

Hi Laura,

Thanks for taking a look.

On Fri, Jun 09, 2017 at 05:23:06PM -0700, Laura Abbott wrote:
> > -	set_pte_atomic(pte, pfn_pte(page_to_pfn(page), canon_pgprot(prot)));
> > +
> > +	BUG_ON(!pte);
> > +
> > +	switch (level) {
> > +	case PG_LEVEL_4K:
> > +		set_pte_atomic(pte, pfn_pte(page_to_pfn(page), canon_pgprot(prot)));
> > +		break;
> > +	case PG_LEVEL_2M:
> > +	case PG_LEVEL_1G: {
> > +		struct cpa_data cpa;
> > +		int do_split;
> > +
> > +		memset(&cpa, 0, sizeof(cpa));
> > +		cpa.vaddr = kaddr;
> > +		cpa.pages = &page;
> > +		cpa.mask_set = prot;
> > +		pgprot_val(cpa.mask_clr) = ~pgprot_val(prot);
> > +		cpa.numpages = 1;
> > +		cpa.flags = 0;
> > +		cpa.curpage = 0;
> > +		cpa.force_split = 0;
> > +
> > +		do_split = try_preserve_large_page(pte, (unsigned long)kaddr, &cpa);
> > +		if (do_split < 0)
> 
> I can't reproduce the failure you describe in the cover letter but are you sure this
> check is correct?

The check seems to only happen when splitting up a large page,
indicating that...

> It looks like try_preserve_large_page can return 1 on failure
> and you still need to call split_large_page.

...yes, you're absolutely right. When I fix this, it now fails to
boot, stalling on unpacking the initramfs. So it seems something else
is wrong too.

Cheers,

Tycho

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
