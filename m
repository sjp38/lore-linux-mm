Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id AAAC76B0038
	for <linux-mm@kvack.org>; Fri, 19 Jan 2018 07:30:59 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id k6so1725653pgt.15
        for <linux-mm@kvack.org>; Fri, 19 Jan 2018 04:30:59 -0800 (PST)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id z14si8390494pgr.243.2018.01.19.04.30.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 19 Jan 2018 04:30:58 -0800 (PST)
Date: Fri, 19 Jan 2018 15:30:51 +0300
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: Re: [mm 4.15-rc8] Random oopses under memory pressure.
Message-ID: <20180119123051.xd5orkoagxanp23d@black.fi.intel.com>
References: <201801172008.CHH39543.FFtMHOOVSQJLFO@I-love.SAKURA.ne.jp>
 <201801181712.BFD13039.LtHOSVMFJQFOFO@I-love.SAKURA.ne.jp>
 <20180118122550.2lhsjx7hg5drcjo4@node.shutemov.name>
 <d8347087-18a6-1709-8aa8-3c6f2d16aa94@linux.intel.com>
 <20180118154026.jzdgdhkcxiliaulp@node.shutemov.name>
 <20180118172213.GI6584@dhcp22.suse.cz>
 <20180119100259.rwq3evikkemtv7q5@node.shutemov.name>
 <20180119103342.GS6584@dhcp22.suse.cz>
 <20180119114917.rvghcgexgbm73xkq@node.shutemov.name>
 <20180119120747.GV6584@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180119120747.GV6584@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Dave Hansen <dave.hansen@linux.intel.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, torvalds@linux-foundation.org, akpm@linux-foundation.org, hannes@cmpxchg.org, iamjoonsoo.kim@lge.com, mgorman@techsingularity.net, tony.luck@intel.com, vbabka@suse.cz, aarcange@redhat.com, hillf.zj@alibaba-inc.com, hughd@google.com, oleg@redhat.com, peterz@infradead.org, riel@redhat.com, srikar@linux.vnet.ibm.com, vdavydov.dev@gmail.com, mingo@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org

On Fri, Jan 19, 2018 at 12:07:47PM +0000, Michal Hocko wrote:
> > >From 861f68c555b87fd6c0ccc3428ace91b7e185b73a Mon Sep 17 00:00:00 2001
> > From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
> > Date: Thu, 18 Jan 2018 18:24:07 +0300
> > Subject: [PATCH] mm, page_vma_mapped: Drop faulty pointer arithmetics in
> >  check_pte()
> > 
> > Tetsuo reported random crashes under memory pressure on 32-bit x86
> > system and tracked down to change that introduced
> > page_vma_mapped_walk().
> > 
> > The root cause of the issue is the faulty pointer math in check_pte().
> > As ->pte may point to an arbitrary page we have to check that they are
> > belong to the section before doing math. Otherwise it may lead to weird
> > results.
> > 
> > It wasn't noticed until now as mem_map[] is virtually contiguous on flatmem or
> > vmemmap sparsemem. Pointer arithmetic just works against all 'struct page'
> > pointers. But with classic sparsemem, it doesn't.
> 
> it doesn't because each section memap is allocated separately and so
> consecutive pfns crossing two sections might have struct pages at
> completely unrelated addresses.

Okay, I'll amend it.

> > Let's restructure code a bit and replace pointer arithmetic with
> > operations on pfns.
> > 
> > Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> > Reported-by: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
> > Fixes: ace71a19cec5 ("mm: introduce page_vma_mapped_walk()")
> > Cc: stable@vger.kernel.org
> > Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> 
> The patch makes sense but there is one more thing to fix here.
> 
> [...]
> >  static bool check_pte(struct page_vma_mapped_walk *pvmw)
> >  {
> > +	unsigned long pfn;
> > +
> >  	if (pvmw->flags & PVMW_MIGRATION) {
> >  #ifdef CONFIG_MIGRATION
> >  		swp_entry_t entry;
> > @@ -41,37 +61,34 @@ static bool check_pte(struct page_vma_mapped_walk *pvmw)
> >  
> >  		if (!is_migration_entry(entry))
> >  			return false;
> > -		if (migration_entry_to_page(entry) - pvmw->page >=
> > -				hpage_nr_pages(pvmw->page)) {
> > -			return false;
> > -		}
> > -		if (migration_entry_to_page(entry) < pvmw->page)
> > -			return false;
> > +
> > +		pfn = migration_entry_to_pfn(entry);
> >  #else
> >  		WARN_ON_ONCE(1);
> >  #endif
> > -	} else {
> 
> now you allow to pass through with uninitialized pfn. We used to return
> true in that case so we should probably keep it in this WARN_ON_ONCE
> case. Please note that I haven't studied this particular case and the
> ifdef is definitely not an act of art but that is a separate topic.

Good catch. Thanks.

I think returning true here is wrong as we don't validate in any way what
is mapped there. I'll put "return false;".

And I take a look if we can drop the #ifdef.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
