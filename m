Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f177.google.com (mail-pd0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id 717726B0031
	for <linux-mm@kvack.org>; Fri,  7 Feb 2014 18:09:13 -0500 (EST)
Received: by mail-pd0-f177.google.com with SMTP id x10so3690125pdj.8
        for <linux-mm@kvack.org>; Fri, 07 Feb 2014 15:09:12 -0800 (PST)
Received: from mail-pb0-x22e.google.com (mail-pb0-x22e.google.com [2607:f8b0:400e:c01::22e])
        by mx.google.com with ESMTPS id q5si6617952pae.259.2014.02.07.15.09.11
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 07 Feb 2014 15:09:12 -0800 (PST)
Received: by mail-pb0-f46.google.com with SMTP id um1so3844948pbc.19
        for <linux-mm@kvack.org>; Fri, 07 Feb 2014 15:09:11 -0800 (PST)
Date: Fri, 7 Feb 2014 15:09:09 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 9/9] mm: Remove ifdef condition in include/linux/mm.h
In-Reply-To: <20140207143050.6bd35ed5c670a3ca143ba59a@linux-foundation.org>
Message-ID: <alpine.DEB.2.02.1402071503120.24644@chino.kir.corp.google.com>
References: <a7658fc8f2ab015bffe83de1448cc3db79d2a9fc.1391167128.git.rashika.kheria@gmail.com> <63adb3b97f2869d4c7e76d17ef4aa76b8cf599f3.1391167128.git.rashika.kheria@gmail.com> <alpine.DEB.2.02.1402071304080.4212@chino.kir.corp.google.com>
 <20140207210705.GB13604@jtriplet-mobl1> <alpine.DEB.2.02.1402071314180.4212@chino.kir.corp.google.com> <20140207143050.6bd35ed5c670a3ca143ba59a@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Josh Triplett <josh@joshtriplett.org>, Rashika Kheria <rashika.kheria@gmail.com>, linux-kernel@vger.kernel.org, Rik van Riel <riel@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Jiang Liu <jiang.liu@huawei.com>, Michel Lespinasse <walken@google.com>, linux-mm@kvack.org

On Fri, 7 Feb 2014, Andrew Morton wrote:

> > > > > diff --git a/include/linux/mm.h b/include/linux/mm.h
> > > > > index 1cedd00..5f8348f 100644
> > > > > --- a/include/linux/mm.h
> > > > > +++ b/include/linux/mm.h
> > > > > @@ -1589,10 +1589,8 @@ static inline int __early_pfn_to_nid(unsigned long pfn)
> > > > >  #else
> > > > >  /* please see mm/page_alloc.c */
> > > > >  extern int __meminit early_pfn_to_nid(unsigned long pfn);
> > > > > -#ifdef CONFIG_HAVE_ARCH_EARLY_PFN_TO_NID
> > > > >  /* there is a per-arch backend function. */
> > > > >  extern int __meminit __early_pfn_to_nid(unsigned long pfn);
> > > > > -#endif /* CONFIG_HAVE_ARCH_EARLY_PFN_TO_NID */
> > > > >  #endif
> > > > >  
> > > > >  extern void set_dma_reserve(unsigned long new_dma_reserve);
> > > > 
> > > > Wouldn't it be better to just declare the __early_pfn_to_nid() in 
> > > > mm/page_alloc.c to be static?
> > > 
> > > Won't that break the ability to override that function in
> > > architecture-specific code (as arch/ia64/mm/numa.c does)?
> > > 
> > 
> > Why?  CONFIG_HAVE_ARCH_EARLY_PFN_TO_NID should define where this function 
> > is defined so ia64 should have it set and the definition which I'm 
> > suggesting be static is only compiled when this is undefined in 
> > mm/page_alloc.c.  I'm not sure why we'd want to be messing with the 
> > declaration?
> 
> __early_pfn_to_nid() must be global if it is implemented in arch/. 
> 

Why??  If CONFIG_HAVE_ARCH_EARLY_PFN_TO_NID then, yes, we need it to be 
global.  Otherwise it's perfectly fine just being static in file scope.  
This causes the compilation unit to break when you compile it, not wait 
until vmlinux and find undefined references.

I see no reason it can't be done like this in mm/page_alloc.c:

	#ifdef CONFIG_HAVE_ARCH_EARLY_PFN_TO_NID
	extern int __meminit __early_pfn_to_nid(unsigned long pfn);
	#else
	static int __meminit __early_pfn_to_nid(unsigned long pfn)
	{
		...
	}

or delcare __early_pfn_to_nid() to have __attribute__((weak)) and override 
it when CONFIG_HAVE_ARCH_EARLY_PFN_TO_NID (and get rid of the pointless 
CONFIG option entirely at that point).

Both of these options look much better than

	include/linux/mm.h:

	#if !defined(CONFIG_HAVE_MEMBLOCK_NODE_MAP) && \
	    !defined(CONFIG_HAVE_ARCH_EARLY_PFN_TO_NID)
	static inline int __early_pfn_to_nid(unsigned long pfn)
	{
	        return 0;
	}
	#else
	/* please see mm/page_alloc.c */
	extern int __meminit early_pfn_to_nid(unsigned long pfn);
	#ifdef CONFIG_HAVE_ARCH_EARLY_PFN_TO_NID
	/* there is a per-arch backend function. */
	extern int __meminit __early_pfn_to_nid(unsigned long pfn);
	#endif /* CONFIG_HAVE_ARCH_EARLY_PFN_TO_NID */
	#endif

where all this confusion is originating from.

It's obviously up to your taste in how to proceed, but the latter looks 
sloppy to me and is the reason we have so many unreferenced prototypes in 
header files.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
