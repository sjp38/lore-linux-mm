Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e3.ny.us.ibm.com (8.12.11/8.12.11) with ESMTP id jA4Kw1fR011995
	for <linux-mm@kvack.org>; Fri, 4 Nov 2005 15:58:01 -0500
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay02.pok.ibm.com (8.12.10/NCO/VERS6.7) with ESMTP id jA4Kw1Bu102472
	for <linux-mm@kvack.org>; Fri, 4 Nov 2005 15:58:01 -0500
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11/8.13.3) with ESMTP id jA4Kw16p021409
	for <linux-mm@kvack.org>; Fri, 4 Nov 2005 15:58:01 -0500
Date: Fri, 4 Nov 2005 12:57:58 -0800
From: Mike Kravetz <kravetz@us.ibm.com>
Subject: Re: [PATCH] powerpc: mem_init crash for sparsemem
Message-ID: <20051104205758.GA5397@w-mikek2.ibm.com>
References: <200511041631.17237.arnd@arndb.de> <436BC20B.9070704@shadowen.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <436BC20B.9070704@shadowen.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andy Whitcroft <apw@shadowen.org>
Cc: Arnd Bergmann <arnd@arndb.de>, linuxppc64-dev@ozlabs.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Nov 04, 2005 at 08:18:19PM +0000, Andy Whitcroft wrote:
> Arnd Bergmann wrote:
> > I have a Cell blade with some broken memory in the middle of the
> > physical address space and this is correctly detected by the
> > firmware, but not relocated. When I enable CONFIG_SPARSEMEM,
> > the memsections for the nonexistant address space do not
> > get struct page entries allocated, as expected.
> > 
> > However, mem_init for the non-NUMA configuration tries to
> > access these pages without first looking if they are there.

This earlier statement in mem_init (or at least the comment),

num_physpages = max_pfn;        /* RAM is assumed contiguous */

may be a cause for concern.  I'm pretty sure max_pfn has previously
been set based on the value of lmb_end_of_DRAM().  My guess is that we
are going to report the system as having more memory that it actually
does (will not account for the hole(s)).

That being said, the pfn_valid() check is still needed here.  But,
it looks like that code was originally written under the assumption
that there were no holes.

Can someone 'more in the know' of ppc architecture comment on the
ram is contiguous assumption?  Is this no longer the case?
-- 
Mike

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
