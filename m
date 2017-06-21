Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 39B456B042C
	for <linux-mm@kvack.org>; Wed, 21 Jun 2017 13:47:42 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id d191so181404663pga.15
        for <linux-mm@kvack.org>; Wed, 21 Jun 2017 10:47:42 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id h26si13646592pfk.157.2017.06.21.10.47.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Jun 2017 10:47:41 -0700 (PDT)
Date: Wed, 21 Jun 2017 10:47:40 -0700
From: "Luck, Tony" <tony.luck@intel.com>
Subject: Re: [PATCH] mm/hwpoison: Clear PRESENT bit for kernel 1:1 mappings
 of poison pages
Message-ID: <20170621174740.npbtg2e4o65tyrss@intel.com>
References: <20170616190200.6210-1-tony.luck@intel.com>
 <20170619180147.qolal6mz2wlrjbxk@pd.tnic>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170619180147.qolal6mz2wlrjbxk@pd.tnic>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@suse.de>
Cc: Dave Hansen <dave.hansen@intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Yazen Ghannam <yazen.ghannam@amd.com>

On Mon, Jun 19, 2017 at 08:01:47PM +0200, Borislav Petkov wrote:
> (drop stable from CC)
> 
> You could use git's --suppress-cc= option when sending.

I would if I could work out how to use it. From reading the manual
page there seem to be a few options to this, but none of them appear
to just drop a specific address (apart from my own). :-(

> > +#ifdef CONFIG_X86_64
> > +
> > +void arch_unmap_kpfn(unsigned long pfn)
> > +{
> 
> I guess you can move the ifdeffery inside the function.

If I do, then the compiler will emit an empty function. It's only
a couple of bytes for the "ret" ... but why?  I may change it
to:

   #if defined(arch_unmap_kpfn) && defined(CONFIG_MEMORY_FAILURE)

to narrow down further when we need this.

> > +#if PGDIR_SHIFT + 9 < 63 /* 9 because cpp doesn't grok ilog2(PTRS_PER_PGD) */
> 
> Please no side comments.

Ok.

> Also, explain why the build-time check. (Sign-extension going away for VA
> space yadda yadda..., 5 2/3 level paging :-))

Will add.

> Also, I'm assuming this whole "workaround" of sorts should be Intel-only?

I'd assume that other X86 implementations would face similar issues (unless
they have extremely cautious pre-fetchers and/or no speculation).

I'm also assuming that non-X86 architectures that do recovery may want this
too ... hence hooking the arch_unmap_kpfn() function into the generic
memory_failure() code.

> > +	decoy_addr = (pfn << PAGE_SHIFT) + (PAGE_OFFSET ^ BIT(63));
> > +#else
> > +#error "no unused virtual bit available"
> > +#endif
> > +
> > +	if (set_memory_np(decoy_addr, 1))
> > +		pr_warn("Could not invalidate pfn=0x%lx from 1:1 map \n", pfn);
> 
> WARNING: unnecessary whitespace before a quoted newline
> #107: FILE: arch/x86/kernel/cpu/mcheck/mce.c:1089:
> +               pr_warn("Could not invalidate pfn=0x%lx from 1:1 map \n", pfn);

Oops!  Will fix.

-Tony

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
