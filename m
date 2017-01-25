Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 9AE866B0033
	for <linux-mm@kvack.org>; Wed, 25 Jan 2017 18:15:34 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id r126so41208253wmr.2
        for <linux-mm@kvack.org>; Wed, 25 Jan 2017 15:15:34 -0800 (PST)
Received: from mail-wm0-x244.google.com (mail-wm0-x244.google.com. [2a00:1450:400c:c09::244])
        by mx.google.com with ESMTPS id g11si24201688wmi.59.2017.01.25.15.15.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 Jan 2017 15:15:33 -0800 (PST)
Received: by mail-wm0-x244.google.com with SMTP id d140so46288093wmd.2
        for <linux-mm@kvack.org>; Wed, 25 Jan 2017 15:15:33 -0800 (PST)
Date: Thu, 26 Jan 2017 01:15:29 +0200
From: Ahmed Samy <f.fallen45@gmail.com>
Subject: Re: ioremap_page_range: remapping of physical RAM ranges
Message-ID: <20170125231529.GA14993@devmasch>
References: <CADY3hbEy+oReL=DePFz5ZNsnvWpm55Q8=mRTxCGivSL64gAMMA@mail.gmail.com>
 <072b4406-16ef-cdf6-e968-711a60ca9a3f@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <072b4406-16ef-cdf6-e968-711a60ca9a3f@nvidia.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Hubbard <jhubbard@nvidia.com>
Cc: linux-mm@kvack.org, zhongjiang@huawei.com

On Wed, Jan 25, 2017 at 02:27:27PM -0800, John Hubbard wrote:
> 
> Hi A. Samy,
> 
> I'm sorry this caught you by surprise, let's try get your use case covered.
> 
> My thinking on this was: the exported ioremap* family of functions was
> clearly intended to provide just what the name says: mapping of IO (non-RAM)
> memory. If normal RAM is to be re-mapped, then it should not be done
> "casually" in a driver, as a (possibly unintended) side effect of a function
> that implies otherwise. Either it should be done within the core mm code, or
> perhaps a new, better-named wrapper could be provided, for cases such as
> yours.
Hi John,

I agree.  I assume whoever exported it was also doing it for the same
purpose as mine[?]
> 
> After a very quick peek at your github code, it seems that your mm_remap()
> routine already has some code in common with __ioremap_caller(), so I'm
> thinking that we could basically promote your mm_remap to the in-tree kernel
> and EXPORT it, and maybe factor out the common parts (or not--it's small,
> after all). Thoughts? If you like it, I'll put something together here.
That'd be a good solution, it's actually sometimes useful to remap physical
ram in general, specifically for memory imaging tools, etc.

How about also exporting walk_system_ram_range()?  It seems to be defined
conditionally, so I am not sure if that would be a good idea.
	[ See also mm_cache_ram_ranges() in mm.c in github a?? it's also a hacky
	  way to get RAM ranges.  ]

How about something like:

	/* vm_flags incase locking is required, in my case, I need it for VMX
	 * root where there is no interrupts.  */
	void *remap_ram_range(unsigned long phys, unsigned long size,
			      unsigned long vm_flags)
	{
		struct vm_struct *area;
		unsigned long psize;
		unsigned long vaddr;

		psize = (size >> PAGE_SHIFT) + (size & (PAGE_SIZE - 1)) != 0;
		area = get_vm_area_caller(size, VM_IOREMAP | vm_flags, 
					  __builtin_return_address(0));
		if (!area)
			return NULL;

		area->phys_addr = phys & ~(PAGE_SIZE - 1);
		vaddr = (unsigned long)area->addr;
		if (remap_page_range(vaddr, vaddr + size, phys, size))
			goto err_remap;

		return (void *)vaddr + phys & (PAGE_SIZE - 1);
err_remap:
		free_vm_area(area);
		return NULL;
	}

Of course you can add protection, etc.
> 
> thanks
> john h
> 
Thanks,
	asamy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
