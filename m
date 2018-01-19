Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 7E5DE6B0038
	for <linux-mm@kvack.org>; Fri, 19 Jan 2018 07:07:54 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id x188so962577wmg.2
        for <linux-mm@kvack.org>; Fri, 19 Jan 2018 04:07:54 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y8si7277410wrh.446.2018.01.19.04.07.52
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 19 Jan 2018 04:07:53 -0800 (PST)
Date: Fri, 19 Jan 2018 13:07:47 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [mm 4.15-rc8] Random oopses under memory pressure.
Message-ID: <20180119120747.GV6584@dhcp22.suse.cz>
References: <CA+55aFyxyjN0Mqnz66B4a0R+uR8DdfxdMhcg5rJVi8LwnpSRfA@mail.gmail.com>
 <201801172008.CHH39543.FFtMHOOVSQJLFO@I-love.SAKURA.ne.jp>
 <201801181712.BFD13039.LtHOSVMFJQFOFO@I-love.SAKURA.ne.jp>
 <20180118122550.2lhsjx7hg5drcjo4@node.shutemov.name>
 <d8347087-18a6-1709-8aa8-3c6f2d16aa94@linux.intel.com>
 <20180118154026.jzdgdhkcxiliaulp@node.shutemov.name>
 <20180118172213.GI6584@dhcp22.suse.cz>
 <20180119100259.rwq3evikkemtv7q5@node.shutemov.name>
 <20180119103342.GS6584@dhcp22.suse.cz>
 <20180119114917.rvghcgexgbm73xkq@node.shutemov.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180119114917.rvghcgexgbm73xkq@node.shutemov.name>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Dave Hansen <dave.hansen@linux.intel.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, torvalds@linux-foundation.org, kirill.shutemov@linux.intel.com, akpm@linux-foundation.org, hannes@cmpxchg.org, iamjoonsoo.kim@lge.com, mgorman@techsingularity.net, tony.luck@intel.com, vbabka@suse.cz, aarcange@redhat.com, hillf.zj@alibaba-inc.com, hughd@google.com, oleg@redhat.com, peterz@infradead.org, riel@redhat.com, srikar@linux.vnet.ibm.com, vdavydov.dev@gmail.com, mingo@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org

On Fri 19-01-18 14:49:17, Kirill A. Shutemov wrote:
> On Fri, Jan 19, 2018 at 11:33:42AM +0100, Michal Hocko wrote:
> > On Fri 19-01-18 13:02:59, Kirill A. Shutemov wrote:
> > > On Thu, Jan 18, 2018 at 06:22:13PM +0100, Michal Hocko wrote:
> > > > On Thu 18-01-18 18:40:26, Kirill A. Shutemov wrote:
> > > > [...]
> > > > > +	/*
> > > > > +	 * Make sure that pages are in the same section before doing pointer
> > > > > +	 * arithmetics.
> > > > > +	 */
> > > > > +	if (page_to_section(pvmw->page) != page_to_section(page))
> > > > > +		return false;
> > > > 
> > > > OK, THPs shouldn't cross memory sections AFAIK. My brain is meltdown
> > > > these days so this might be a completely stupid question. But why don't
> > > > you simply compare pfns? This would be just simpler, no?
> > > 
> > > In original code, we already had pvmw->page around and I thought it would
> > > be easier to get page for the pte intead of looking for pfn for both
> > > sides.
> > > 
> > > We these changes it's no longer the case.
> > > 
> > > Do you care enough to send a patch? :)
> > 
> > Well, memory sections are sparsemem concept IIRC. Unless I've missed
> > something page_to_section is quarded by SECTION_IN_PAGE_FLAGS and that
> > is conditional to CONFIG_SPARSEMEM. THP is a generic code so using it
> > there is wrong unless I miss some subtle detail here.
> > 
> > Comparing pfn should be generic enough.
> 
> Good point.
> 
> What about something like this?
> 
> >From 861f68c555b87fd6c0ccc3428ace91b7e185b73a Mon Sep 17 00:00:00 2001
> From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
> Date: Thu, 18 Jan 2018 18:24:07 +0300
> Subject: [PATCH] mm, page_vma_mapped: Drop faulty pointer arithmetics in
>  check_pte()
> 
> Tetsuo reported random crashes under memory pressure on 32-bit x86
> system and tracked down to change that introduced
> page_vma_mapped_walk().
> 
> The root cause of the issue is the faulty pointer math in check_pte().
> As ->pte may point to an arbitrary page we have to check that they are
> belong to the section before doing math. Otherwise it may lead to weird
> results.
> 
> It wasn't noticed until now as mem_map[] is virtually contiguous on flatmem or
> vmemmap sparsemem. Pointer arithmetic just works against all 'struct page'
> pointers. But with classic sparsemem, it doesn't.

it doesn't because each section memap is allocated separately and so
consecutive pfns crossing two sections might have struct pages at
completely unrelated addresses.

> Let's restructure code a bit and replace pointer arithmetic with
> operations on pfns.
> 
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Reported-by: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
> Fixes: ace71a19cec5 ("mm: introduce page_vma_mapped_walk()")
> Cc: stable@vger.kernel.org
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

The patch makes sense but there is one more thing to fix here.

[...]
>  static bool check_pte(struct page_vma_mapped_walk *pvmw)
>  {
> +	unsigned long pfn;
> +
>  	if (pvmw->flags & PVMW_MIGRATION) {
>  #ifdef CONFIG_MIGRATION
>  		swp_entry_t entry;
> @@ -41,37 +61,34 @@ static bool check_pte(struct page_vma_mapped_walk *pvmw)
>  
>  		if (!is_migration_entry(entry))
>  			return false;
> -		if (migration_entry_to_page(entry) - pvmw->page >=
> -				hpage_nr_pages(pvmw->page)) {
> -			return false;
> -		}
> -		if (migration_entry_to_page(entry) < pvmw->page)
> -			return false;
> +
> +		pfn = migration_entry_to_pfn(entry);
>  #else
>  		WARN_ON_ONCE(1);
>  #endif
> -	} else {

now you allow to pass through with uninitialized pfn. We used to return
true in that case so we should probably keep it in this WARN_ON_ONCE
case. Please note that I haven't studied this particular case and the
ifdef is definitely not an act of art but that is a separate topic.

> -		if (is_swap_pte(*pvmw->pte)) {
> -			swp_entry_t entry;
> +	} else if (is_swap_pte(*pvmw->pte)) {
> +		swp_entry_t entry;
>  
> -			entry = pte_to_swp_entry(*pvmw->pte);
> -			if (is_device_private_entry(entry) &&
> -			    device_private_entry_to_page(entry) == pvmw->page)
> -				return true;
> -		}
> +		/* Handle un-addressable ZONE_DEVICE memory */
> +		entry = pte_to_swp_entry(*pvmw->pte);
> +		if (!is_device_private_entry(entry))
> +			return false;
>  
> +		pfn = device_private_entry_to_pfn(entry);
> +	} else {
>  		if (!pte_present(*pvmw->pte))
>  			return false;
>  
> -		/* THP can be referenced by any subpage */
> -		if (pte_page(*pvmw->pte) - pvmw->page >=
> -				hpage_nr_pages(pvmw->page)) {
> -			return false;
> -		}
> -		if (pte_page(*pvmw->pte) < pvmw->page)
> -			return false;
> +		pfn = pte_pfn(*pvmw->pte);
>  	}
>  
> +	if (pfn < page_to_pfn(pvmw->page))
> +		return false;
> +
> +	/* THP can be referenced by any subpage */
> +	if (pfn - page_to_pfn(pvmw->page) >= hpage_nr_pages(pvmw->page))
> +		return false;
> +
>  	return true;
>  }
>  
> -- 
>  Kirill A. Shutemov

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
