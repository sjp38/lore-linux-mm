Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e31.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m48G7YSW031720
	for <linux-mm@kvack.org>; Thu, 8 May 2008 12:07:34 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m48G7YmB193208
	for <linux-mm@kvack.org>; Thu, 8 May 2008 10:07:34 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m48G7WTB012122
	for <linux-mm@kvack.org>; Thu, 8 May 2008 10:07:33 -0600
Date: Thu, 8 May 2008 09:07:31 -0700
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: Re: [PATCH] x86: fix PAE pmd_bad bootup warning
Message-ID: <20080508160731.GM23990@us.ibm.com>
References: <b6a2187b0805051806v25fa1272xb08e0b70b9c3408@mail.gmail.com> <20080506124946.GA2146@elte.hu> <Pine.LNX.4.64.0805061435510.32567@blonde.site> <alpine.LFD.1.10.0805061138580.32269@woody.linux-foundation.org> <Pine.LNX.4.64.0805062043580.11647@blonde.site> <alpine.LFD.1.10.0805061302080.32269@woody.linux-foundation.org> <Pine.LNX.4.64.0805062120120.16053@blonde.site>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0805062120120.16053@blonde.site>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Ingo Molnar <mingo@elte.hu>, Jeff Chua <jeff.chua.linux@gmail.com>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Gabriel C <nix.or.die@googlemail.com>, Hans Rosenfeld <hans.rosenfeld@amd.com>, Arjan van de Ven <arjan@linux.intel.com>, Jeremy Fitzhardinge <jeremy@goop.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 06.05.2008 [21:30:44 +0100], Hugh Dickins wrote:
> On Tue, 6 May 2008, Linus Torvalds wrote:
> > On Tue, 6 May 2008, Hugh Dickins wrote:
> > >
> > > Fix Hans' good observation that follow_page() will never find
> > > pmd_huge() because that would have already failed the pmd_bad
> > > test: test pmd_huge in between the pmd_none and pmd_bad tests.
> > > Tighten x86's pmd_huge() check?  No, once it's a hugepage entry,
> > > it can get quite far from a good pmd: for example, PROT_NONE
> > > leaves it with only ACCESSED of the KERN_PGTABLE bits.
> > 
> > I'd much rather have pdm_bad() etc fixed up instead, so that they do
> > a more proper test (not thinking that a PSE page is bad, since it
> > clearly isn't). And then, make them dependent on DEBUG_VM, because
> > doing the proper test will be more expensive.
> 
> But everywhere we use pmd_bad() etc (most are hidden inside
> pmd_none_or_clear_bad() etc) we are expecting never to encounter
> a pmd_huge, unless there's corruption.  follow_page() is the one
> exception, and even in its case I can't find a current user that
> actually could meet a hugepage.  I'd rather tighten up pmd_bad
> (in the PAE and x86_64 cases), than weaken it so far as to let
> hugepages slip through.  Not that pmd_bad often catches anything:
> just coincidentally that 90909090 one today.

There is one case that seems to the source of Hans' problem, as Dave has
figured out: /proc/pid/pagemap, where we fairly straight-forwardly walk
the pagetables.

In there, we unconditionally call pmd_none_or_clear_bad(pmd). And any
userspace process that maps hugepages and then reads in
/proc/pid/pagemap will invoke that path, I think (at least with 2M
pages).

So I agree, you're fixing a potential issue in follow_page() [might
deserve a comment, so someone doesn't go and combine them back later?],
but Hans' issue is most likely related to the pagemap code?

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
