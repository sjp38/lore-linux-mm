Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e1.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m48GXtxY032654
	for <linux-mm@kvack.org>; Thu, 8 May 2008 12:33:55 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m48GXtpe106514
	for <linux-mm@kvack.org>; Thu, 8 May 2008 12:33:55 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m48GXsce005117
	for <linux-mm@kvack.org>; Thu, 8 May 2008 12:33:55 -0400
Date: Thu, 8 May 2008 09:33:52 -0700
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: Re: [PATCH] x86: fix PAE pmd_bad bootup warning
Message-ID: <20080508163352.GN23990@us.ibm.com>
References: <Pine.LNX.4.64.0805061435510.32567@blonde.site> <alpine.LFD.1.10.0805061138580.32269@woody.linux-foundation.org> <Pine.LNX.4.64.0805062043580.11647@blonde.site> <20080506202201.GB12654@escobedo.amd.com> <1210106579.4747.51.camel@nimitz.home.sr71.net> <20080508143453.GE12654@escobedo.amd.com> <1210258350.7905.45.camel@nimitz.home.sr71.net> <20080508151145.GG12654@escobedo.amd.com> <1210261882.7905.49.camel@nimitz.home.sr71.net> <20080508161925.GH12654@escobedo.amd.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080508161925.GH12654@escobedo.amd.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hans Rosenfeld <hans.rosenfeld@amd.com>
Cc: Dave Hansen <dave@linux.vnet.ibm.com>, Hugh Dickins <hugh@veritas.com>, Ingo Molnar <mingo@elte.hu>, Jeff Chua <jeff.chua.linux@gmail.com>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Gabriel C <nix.or.die@googlemail.com>, Arjan van de Ven <arjan@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 08.05.2008 [18:19:25 +0200], Hans Rosenfeld wrote:
> On Thu, May 08, 2008 at 08:51:22AM -0700, Dave Hansen wrote:
> > Is there anything in your dmesg?
> 
> mm/memory.c:127: bad pmd ffff810076801040(80000000720000e7).
> 
> > There was a discussion on LKML in the last couple of days about
> > pmd_bad() triggering on huge pages.  Perhaps we're clearing the mapping
> > with the pmd_none_or_clear_bad(), and *THAT* is leaking the page.
> 
> That makes sense. I remember that explicitly munmapping the huge page
> would still work, but it doesn't. I don't quite remember what I did back
> then to test this, but I probably made some mistake there that led me to
> some false conclusions.

So this seems to lend credence to Dave's hypothesis. Without, as you
were trying before, teaching pagemap all about hugepages, what are our
options?

Can we just skip over the current iteration of the PMD loop (would we
need something similar for the PTE loop for power?) if pmd_huge(pmd)?

Thanks,
Nish

-- 
Nishanth Aravamudan <nacc@us.ibm.com>
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
