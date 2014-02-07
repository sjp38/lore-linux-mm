Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f175.google.com (mail-pd0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id C366C6B0031
	for <linux-mm@kvack.org>; Fri,  7 Feb 2014 17:30:54 -0500 (EST)
Received: by mail-pd0-f175.google.com with SMTP id w10so3686449pde.6
        for <linux-mm@kvack.org>; Fri, 07 Feb 2014 14:30:54 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id eb3si6525281pbd.317.2014.02.07.14.30.51
        for <linux-mm@kvack.org>;
        Fri, 07 Feb 2014 14:30:52 -0800 (PST)
Date: Fri, 7 Feb 2014 14:30:50 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 9/9] mm: Remove ifdef condition in include/linux/mm.h
Message-Id: <20140207143050.6bd35ed5c670a3ca143ba59a@linux-foundation.org>
In-Reply-To: <alpine.DEB.2.02.1402071314180.4212@chino.kir.corp.google.com>
References: <a7658fc8f2ab015bffe83de1448cc3db79d2a9fc.1391167128.git.rashika.kheria@gmail.com>
	<63adb3b97f2869d4c7e76d17ef4aa76b8cf599f3.1391167128.git.rashika.kheria@gmail.com>
	<alpine.DEB.2.02.1402071304080.4212@chino.kir.corp.google.com>
	<20140207210705.GB13604@jtriplet-mobl1>
	<alpine.DEB.2.02.1402071314180.4212@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Josh Triplett <josh@joshtriplett.org>, Rashika Kheria <rashika.kheria@gmail.com>, linux-kernel@vger.kernel.org, Rik van Riel <riel@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Jiang Liu <jiang.liu@huawei.com>, Michel Lespinasse <walken@google.com>, linux-mm@kvack.org

On Fri, 7 Feb 2014 13:15:29 -0800 (PST) David Rientjes <rientjes@google.com> wrote:

> On Fri, 7 Feb 2014, Josh Triplett wrote:
> 
> > > > diff --git a/include/linux/mm.h b/include/linux/mm.h
> > > > index 1cedd00..5f8348f 100644
> > > > --- a/include/linux/mm.h
> > > > +++ b/include/linux/mm.h
> > > > @@ -1589,10 +1589,8 @@ static inline int __early_pfn_to_nid(unsigned long pfn)
> > > >  #else
> > > >  /* please see mm/page_alloc.c */
> > > >  extern int __meminit early_pfn_to_nid(unsigned long pfn);
> > > > -#ifdef CONFIG_HAVE_ARCH_EARLY_PFN_TO_NID
> > > >  /* there is a per-arch backend function. */
> > > >  extern int __meminit __early_pfn_to_nid(unsigned long pfn);
> > > > -#endif /* CONFIG_HAVE_ARCH_EARLY_PFN_TO_NID */
> > > >  #endif
> > > >  
> > > >  extern void set_dma_reserve(unsigned long new_dma_reserve);
> > > 
> > > Wouldn't it be better to just declare the __early_pfn_to_nid() in 
> > > mm/page_alloc.c to be static?
> > 
> > Won't that break the ability to override that function in
> > architecture-specific code (as arch/ia64/mm/numa.c does)?
> > 
> 
> Why?  CONFIG_HAVE_ARCH_EARLY_PFN_TO_NID should define where this function 
> is defined so ia64 should have it set and the definition which I'm 
> suggesting be static is only compiled when this is undefined in 
> mm/page_alloc.c.  I'm not sure why we'd want to be messing with the 
> declaration?

__early_pfn_to_nid() must be global if it is implemented in arch/. 

Making it static when it is implemented in core mm makes a bit of
sense, in that it cleans up the non-ia64 namespace and discourages
usage from other compilation units.  But it's is a bit odd and
unexpected to do such a thing.  I'm inclined to happily nuke the ifdef
then go think about something else ;)




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
