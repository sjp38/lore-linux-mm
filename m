Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e6.ny.us.ibm.com (8.12.11/8.12.11) with ESMTP id j6CKbDAH019892
	for <linux-mm@kvack.org>; Tue, 12 Jul 2005 16:37:13 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay04.pok.ibm.com (8.12.10/NCO/VERS6.7) with ESMTP id j6CKbCXR186382
	for <linux-mm@kvack.org>; Tue, 12 Jul 2005 16:37:12 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11/8.13.3) with ESMTP id j6CKbC7Y025419
	for <linux-mm@kvack.org>; Tue, 12 Jul 2005 16:37:12 -0400
Date: Tue, 12 Jul 2005 13:37:09 -0700
From: Mike Kravetz <kravetz@us.ibm.com>
Subject: Re: [PATCH] gurantee DMA area for alloc_bootmem_low()
Message-ID: <20050712203709.GA6230@w-mikek2.ibm.com>
References: <20050712152715.44CD.Y-GOTO@jp.fujitsu.com> <20050712183021.GC3987@w-mikek2.ibm.com> <1121196565.5992.2.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1121196565.5992.2.camel@localhost>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: Yasunori Goto <y-goto@jp.fujitsu.com>, linux-mm <linux-mm@kvack.org>, "Luck, Tony" <tony.luck@intel.com>, ia64 list <linux-ia64@vger.kernel.org>, "Martin J. Bligh" <mbligh@mbligh.org>
List-ID: <linux-mm.kvack.org>

On Tue, Jul 12, 2005 at 12:29:25PM -0700, Dave Hansen wrote:
> On Tue, 2005-07-12 at 11:30 -0700, Mike Kravetz wrote:
> > FYI - While hacking on the memory hotplug code, I added a special
> > '#define MAX_DMA_PHYSADDR' to get around this issue on such architectures.
> > Most likely, this isn't elegant enough as a real solution.  But it does
> > point out that __pa(MAX_DMA_ADDRESS) doesn't always give you what you
> > expect.
> 
> Didn't we create a MAX_DMA_PHYSADDR or something, so that people could
> do this if they want?

Yes, but that only 'exists' in the hotplug patch set.

My point was simply that __pa(MAX_DMA_ADDRESS) doesn't give you what
you want on all archs.  This patch could add something like MAX_DMA_ADDRESS
to get around the issue.  

I believe that __pa(MAX_DMA_ADDRESS) is also 'incorrectly' used in
the bootmem macros.

#define alloc_bootmem(x) \
        __alloc_bootmem((x), SMP_CACHE_BYTES, __pa(MAX_DMA_ADDRESS))
#define alloc_bootmem_pages(x) \
        __alloc_bootmem((x), PAGE_SIZE, __pa(MAX_DMA_ADDRESS))

But, in these cases __pa(MAX_DMA_ADDRESS) is the 'goal' argument.  And
as such, being 'incorrect' is not much of an issue.  Especially on archs
that can do DMA anywhere.

-- 
Mike
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
