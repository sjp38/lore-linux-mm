Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 1CD676B0003
	for <linux-mm@kvack.org>; Tue, 13 Feb 2018 19:53:16 -0500 (EST)
Received: by mail-io0-f197.google.com with SMTP id g24so18810615iob.13
        for <linux-mm@kvack.org>; Tue, 13 Feb 2018 16:53:16 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j94sor4078257iod.230.2018.02.13.16.53.14
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 13 Feb 2018 16:53:15 -0800 (PST)
Date: Tue, 13 Feb 2018 16:53:12 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch 1/2] mm, page_alloc: extend kernelcore and movablecore
 for percent
In-Reply-To: <a064d937-5746-3e14-bb63-5ff9d845a428@oracle.com>
Message-ID: <alpine.DEB.2.10.1802131651140.69963@chino.kir.corp.google.com>
References: <alpine.DEB.2.10.1802121622470.179479@chino.kir.corp.google.com> <a064d937-5746-3e14-bb63-5ff9d845a428@oracle.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jonathan Corbet <corbet@lwn.net>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-doc@vger.kernel.org

On Tue, 13 Feb 2018, Mike Kravetz wrote:

> > diff --git a/Documentation/admin-guide/kernel-parameters.txt b/Documentation/admin-guide/kernel-parameters.txt
> > --- a/Documentation/admin-guide/kernel-parameters.txt
> > +++ b/Documentation/admin-guide/kernel-parameters.txt
> > @@ -1825,30 +1825,30 @@
> >  	keepinitrd	[HW,ARM]
> >  
> >  	kernelcore=	[KNL,X86,IA-64,PPC]
> > -			Format: nn[KMGTPE] | "mirror"
> > -			This parameter
> > -			specifies the amount of memory usable by the kernel
> > -			for non-movable allocations.  The requested amount is
> > -			spread evenly throughout all nodes in the system. The
> > -			remaining memory in each node is used for Movable
> > -			pages. In the event, a node is too small to have both
> > -			kernelcore and Movable pages, kernelcore pages will
> > -			take priority and other nodes will have a larger number
> > -			of Movable pages.  The Movable zone is used for the
> > -			allocation of pages that may be reclaimed or moved
> > -			by the page migration subsystem.  This means that
> > -			HugeTLB pages may not be allocated from this zone.
> > -			Note that allocations like PTEs-from-HighMem still
> > -			use the HighMem zone if it exists, and the Normal
> > -			zone if it does not.
> > -
> > -			Instead of specifying the amount of memory (nn[KMGTPE]),
> > -			you can specify "mirror" option. In case "mirror"
> > +			Format: nn[KMGTPE] | nn% | "mirror"
> > +			This parameter specifies the amount of memory usable by
> > +			the kernel for non-movable allocations.  The requested
> > +			amount is spread evenly throughout all nodes in the
> > +			system as ZONE_NORMAL.  The remaining memory is used for
> > +			movable memory in its own zone, ZONE_MOVABLE.  In the
> > +			event, a node is too small to have both ZONE_NORMAL and
> > +			ZONE_MOVABLE, kernelcore memory will take priority and
> > +			other nodes will have a larger ZONE_MOVABLE.
> > +
> > +			ZONE_MOVABLE is used for the allocation of pages that
> > +			may be reclaimed or moved by the page migration
> > +			subsystem.  This means that HugeTLB pages may not be
> > +			allocated from this zone.  Note that allocations like
> > +			PTEs-from-HighMem still use the HighMem zone if it
> > +			exists, and the Normal zone if it does not.
> 
> I know you are just updating the documentation for the new ability to
> specify a percentage.  However, while looking at this I noticed that
> the existing description is out of date.  HugeTLB pages CAN be treated
> as movable and allocated from ZONE_MOVABLE.
> 
> If you have to respin, could you drop that line while making this change?
> 

Hi Mike,

It's merged in -mm, so perhaps no respin is necessary.  I think a general 
cleanup to this area regarding your work with hugetlb pages would be good.

> > +
> > +			It is possible to specify the exact amount of memory in
> > +			the form of "nn[KMGTPE]", a percentage of total system
> > +			memory in the form of "nn%", or "mirror".  If "mirror"
> >  			option is specified, mirrored (reliable) memory is used
> >  			for non-movable allocations and remaining memory is used
> > -			for Movable pages. nn[KMGTPE] and "mirror" are exclusive,
> > -			so you can NOT specify nn[KMGTPE] and "mirror" at the same
> > -			time.
> > +			for Movable pages.  "nn[KMGTPE]", "nn%", and "mirror"
> > +			are exclusive, so you cannot specify multiple forms.
> >  
> >  	kgdbdbgp=	[KGDB,HW] kgdb over EHCI usb debug port.
> >  			Format: <Controller#>[,poll interval]
> 
> Don't you need to make the same type percentage changes for 'movablecore='?
> 

The majority of the movablecore= documentation simply refers to the 
kernelcore= option as its complement, I'm not sure that we need to go 
in-depth into what the percentage specifiers mean for both options.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
