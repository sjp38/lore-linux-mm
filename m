Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id 97BF46B0031
	for <linux-mm@kvack.org>; Fri,  7 Feb 2014 20:02:05 -0500 (EST)
Received: by mail-pa0-f51.google.com with SMTP id ld10so3899948pab.10
        for <linux-mm@kvack.org>; Fri, 07 Feb 2014 17:02:05 -0800 (PST)
Received: from mail-pd0-x233.google.com (mail-pd0-x233.google.com [2607:f8b0:400e:c02::233])
        by mx.google.com with ESMTPS id r7si6867849pbk.177.2014.02.07.17.02.04
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 07 Feb 2014 17:02:04 -0800 (PST)
Received: by mail-pd0-f179.google.com with SMTP id fp1so3427250pdb.24
        for <linux-mm@kvack.org>; Fri, 07 Feb 2014 17:02:04 -0800 (PST)
Date: Fri, 7 Feb 2014 17:02:02 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 9/9] mm: Remove ifdef condition in include/linux/mm.h
In-Reply-To: <20140207232711.GA16836@jtriplet-mobl1>
Message-ID: <alpine.DEB.2.02.1402071654560.775@chino.kir.corp.google.com>
References: <a7658fc8f2ab015bffe83de1448cc3db79d2a9fc.1391167128.git.rashika.kheria@gmail.com> <63adb3b97f2869d4c7e76d17ef4aa76b8cf599f3.1391167128.git.rashika.kheria@gmail.com> <alpine.DEB.2.02.1402071304080.4212@chino.kir.corp.google.com>
 <20140207210705.GB13604@jtriplet-mobl1> <alpine.DEB.2.02.1402071314180.4212@chino.kir.corp.google.com> <20140207143050.6bd35ed5c670a3ca143ba59a@linux-foundation.org> <alpine.DEB.2.02.1402071503120.24644@chino.kir.corp.google.com>
 <20140207232711.GA16836@jtriplet-mobl1>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Josh Triplett <josh@joshtriplett.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rashika Kheria <rashika.kheria@gmail.com>, linux-kernel@vger.kernel.org, Rik van Riel <riel@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Jiang Liu <jiang.liu@huawei.com>, Michel Lespinasse <walken@google.com>, linux-mm@kvack.org

On Fri, 7 Feb 2014, Josh Triplett wrote:

> > Why??  If CONFIG_HAVE_ARCH_EARLY_PFN_TO_NID then, yes, we need it to be 
> > global.  Otherwise it's perfectly fine just being static in file scope.  
> > This causes the compilation unit to break when you compile it, not wait 
> > until vmlinux and find undefined references.
> > 
> > I see no reason it can't be done like this in mm/page_alloc.c:
> > 
> > 	#ifdef CONFIG_HAVE_ARCH_EARLY_PFN_TO_NID
> > 	extern int __meminit __early_pfn_to_nid(unsigned long pfn);
> 
> No, a .c file should not have an extern declaration in it.  This should
> live in an appropriate header file, to be included in both page_alloc.c
> and any arch file that defines an overriding function.
> 

Ok, so you have religious beliefs about extern being used in files ending 
in .c and don't mind the 2900 occurrences of it in the kernel tree and 
desire 14 line obfuscation in header files with comments to what is being 
defined in .c files such as "please see mm/page_alloc.c" as mm.h has.  
Good point.

> > Both of these options look much better than
> > 
> > 	include/linux/mm.h:
> > 
> > 	#if !defined(CONFIG_HAVE_MEMBLOCK_NODE_MAP) && \
> > 	    !defined(CONFIG_HAVE_ARCH_EARLY_PFN_TO_NID)
> > 	static inline int __early_pfn_to_nid(unsigned long pfn)
> > 	{
> > 	        return 0;
> > 	}
> > 	#else
> > 	/* please see mm/page_alloc.c */
> > 	extern int __meminit early_pfn_to_nid(unsigned long pfn);
> > 	#ifdef CONFIG_HAVE_ARCH_EARLY_PFN_TO_NID
> > 	/* there is a per-arch backend function. */
> > 	extern int __meminit __early_pfn_to_nid(unsigned long pfn);
> > 	#endif /* CONFIG_HAVE_ARCH_EARLY_PFN_TO_NID */
> > 	#endif
> > 
> > where all this confusion is originating from.
> 
> The proposal is to first simplify those ifdefs by eliminating the inner
> one in the #else; I agree with Andrew that we ought to go ahead and take
> that step given the patch at hand, and then figure out if there's an
> additional simplification possible.
> 

If additional simplification is possible?  Yeah, it's __weak which is 
designed for this purpose.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
