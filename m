Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 0722A6B004F
	for <linux-mm@kvack.org>; Thu, 12 Mar 2009 10:12:10 -0400 (EDT)
Subject: Re: [PATCH] fix/improve generic page table walker
From: Matt Mackall <mpm@selenic.com>
In-Reply-To: <20090312093335.6dd67251@skybase>
References: <20090311144951.58c6ab60@skybase>
	 <1236792263.3205.45.camel@calx>  <20090312093335.6dd67251@skybase>
Content-Type: text/plain
Date: Thu, 12 Mar 2009 09:10:14 -0500
Message-Id: <1236867014.3213.16.camel@calx>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Martin Schwidefsky <schwidefsky@de.ibm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Gerald Schaefer <gerald.schaefer@de.ibm.com>, akpm@linux-foundation.org, Hugh Dickins <hugh@veritas.com>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

[Nick and Hugh, maybe you can shed some light on this for me]

On Thu, 2009-03-12 at 09:33 +0100, Martin Schwidefsky wrote:
> On Wed, 11 Mar 2009 12:24:23 -0500
> Matt Mackall <mpm@selenic.com> wrote:
> 
> > On Wed, 2009-03-11 at 14:49 +0100, Martin Schwidefsky wrote:
> > > From: Martin Schwidefsky <schwidefsky@de.ibm.com>
> > > 
> > > On s390 the /proc/pid/pagemap interface is currently broken. This is
> > > caused by the unconditional loop over all pgd/pud entries as specified
> > > by the address range passed to walk_page_range. The tricky bit here
> > > is that the pgd++ in the outer loop may only be done if the page table
> > > really has 4 levels. For the pud++ in the second loop the page table needs
> > > to have at least 3 levels. With the dynamic page tables on s390 we can have
> > > page tables with 2, 3 or 4 levels. Which means that the pgd and/or the
> > > pud pointer can get out-of-bounds causing all kinds of mayhem.
> > 
> > Not sure why this should be a problem without delving into the S390
> > code. After all, x86 has 2, 3, or 4 levels as well (at compile time) in
> > a way that's transparent to the walker.
> 
> Its hard to understand without looking at the s390 details. The main
> difference between x86 and s390 in that respect is that on s390 the
> number of page table levels is determined at runtime on a per process
> basis. A compat process uses 2 levels, a 64 bit process starts with 3
> levels and can "upgrade" to 4 levels if something gets mapped above
> 4TB. Which means that a *pgd can point to a region-second (2**53 bytes),
> a region-third (2**42 bytes) or a segment table (2**31 bytes), a *pud
> can point to a region-third or a segment table. The page table
> primitives know about this semantic, in particular pud_offset and
> pmd_offset check the type of the page table pointed to by *pgd and *pud
> and do nothing with the pointer if it is a lower level page table.
> The only operation I can not "patch" is the pgd++/pud++ operation.

So in short, sometimes a pgd_t isn't really a pgd_t at all. It's another
object with different semantics that generic code can trip over.

Can I get you to explain why this is necessary or even preferable to
doing it the generic way where pgd_t has a fixed software meaning
regardless of how many hardware levels are in play?

-- 
http://selenic.com : development and support for Mercurial and Linux


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
