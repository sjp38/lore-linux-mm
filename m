Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f169.google.com (mail-ie0-f169.google.com [209.85.223.169])
	by kanga.kvack.org (Postfix) with ESMTP id A6EB96B0032
	for <linux-mm@kvack.org>; Tue, 16 Dec 2014 19:08:07 -0500 (EST)
Received: by mail-ie0-f169.google.com with SMTP id y20so14099519ier.0
        for <linux-mm@kvack.org>; Tue, 16 Dec 2014 16:08:07 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id ga9si1178340igd.44.2014.12.16.16.08.06
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Dec 2014 16:08:06 -0800 (PST)
Date: Tue, 16 Dec 2014 16:08:04 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 5/6]
 mm-introduce-do_shared_fault-and-drop-do_fault-fix-fix
Message-Id: <20141216160804.5f7e6feffb910816d2730fd9@linux-foundation.org>
In-Reply-To: <20141215235532.GA16180@node.dhcp.inet.fi>
References: <548f68cf.6xGKPRYKtNb84wM5%akpm@linux-foundation.org>
	<20141215235532.GA16180@node.dhcp.inet.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: linux-mm@kvack.org, ak@linux.intel.com, dave.hansen@linux.intel.com, lliubbo@gmail.com, matthew.r.wilcox@intel.com, mgorman@suse.de, n-horiguchi@ah.jp.nec.com, riel@redhat.com, sasha.levin@oracle.com, hughd@google.com

On Tue, 16 Dec 2014 01:55:32 +0200 "Kirill A. Shutemov" <kirill@shutemov.name> wrote:

> On Mon, Dec 15, 2014 at 03:03:43PM -0800, akpm@linux-foundation.org wrote:
> > From: Andrew Morton <akpm@linux-foundation.org>
> > Subject: mm-introduce-do_shared_fault-and-drop-do_fault-fix-fix
> > 
> > add comment which may not be true :(
> > 
> > Cc: Andi Kleen <ak@linux.intel.com>
> > Cc: Bob Liu <lliubbo@gmail.com>
> > Cc: Dave Hansen <dave.hansen@linux.intel.com>
> > Cc: "Kirill A. Shutemov" <kirill@shutemov.name>
> > Cc: Matthew Wilcox <matthew.r.wilcox@intel.com>
> > Cc: Mel Gorman <mgorman@suse.de>
> > Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> > Cc: Rik van Riel <riel@redhat.com>
> > Cc: Sasha Levin <sasha.levin@oracle.com>
> > Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> > ---
> > 
> >  mm/memory.c |    6 ++++++
> >  1 file changed, 6 insertions(+)
> > 
> > diff -puN mm/memory.c~mm-introduce-do_shared_fault-and-drop-do_fault-fix-fix mm/memory.c
> > --- a/mm/memory.c~mm-introduce-do_shared_fault-and-drop-do_fault-fix-fix
> > +++ a/mm/memory.c
> > @@ -3009,6 +3009,12 @@ static int do_shared_fault(struct mm_str
> >  
> >  	if (set_page_dirty(fault_page))
> >  		dirtied = 1;
> > +	/*
> > +	 * Take a local copy of the address_space - page.mapping may be zeroed
> > +	 * by truncate after unlock_page().   The address_space itself remains
> > +	 * pinned by vma->vm_file's reference.  We rely on unlock_page()'s
> > +	 * release semantics to prevent the compiler from undoing this copying.
> > +	 */
> 
> Looks correct to me.
> 
> We need the same comment or reference to this one in do_wp_page().

Can you please send a patch some time?

> >  	mapping = fault_page->mapping;
> 
> BTW, I noticed that fault_page here can be a tail page: sound subsytem
> allocates its pages with GFP_COMP and maps them with ptes.

hm, why does it use __GFP_COMP?  It could just use plain old
alloc_pages(GFP_KERNEL) then set up a pte per 4k page?

> The problem is
> that we never set ->mapping for tail pages and the check below is always
> false. It seems doesn't cause any problems right now (looks like ->mapping
> is NULL also for head page sound case), but logic is somewhat broken.
> 
> I only triggered the problem when tried to reuse ->mapping in first tail
> page for compound_mapcount in my thp refcounting rework.
> 
> If it sounds right, I will prepare patch to replace the line above and the
> same case in do_wp_page() with
> 
> 	mapping = compound_head(fault_page)->mapping;
> 
> Ok?

Generally I don't think we should encourage (or even permit) random
driver code to use somewhat-internal-to-MM features unless they really
need to.  But I note that a lot of drivers are allocating with
__GFP_COMP.  Why is this?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
