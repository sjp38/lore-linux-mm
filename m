Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id ADFEF8D003B
	for <linux-mm@kvack.org>; Tue, 19 Apr 2011 17:52:54 -0400 (EDT)
Subject: Re: slub: fix panic with DISCONTIGMEM
From: James Bottomley <James.Bottomley@HansenPartnership.com>
In-Reply-To: <alpine.DEB.2.00.1104191633250.23077@router.home>
References: <1303248576.11237.23.camel@mulgrave.site>
	 <alpine.DEB.2.00.1104191633250.23077@router.home>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 19 Apr 2011 16:52:50 -0500
Message-ID: <1303249970.11237.30.camel@mulgrave.site>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: linux-arch@vger.kernel.org, linux-mm@kvack.org, "hugh.dickins@tiscali.co.uk" <hugh.dickins@tiscali.co.uk>, Parisc List <linux-parisc@vger.kernel.org>

On Tue, 2011-04-19 at 16:38 -0500, Christoph Lameter wrote:
> On Tue, 19 Apr 2011, James Bottomley wrote:
> 
> > Slub makes assumptions about page_to_nid() which are violated by
> > DISCONTIGMEM and !NUMA.  This violation results in a panic because
> 
> Fix this by stating correctly by saying "The kernel makes assumptions in
> various subsystems ..."

Slub is a subset of the kernel, so the original wording is a bit more
precise.

> > page_to_nid() can be non-zero for pages in the discontiguous ranges and
> > this leads to a null return by get_node().  The assertion by the
> > maintainer is that DISCONTIGMEM should only be allowed when NUMA is also
> > defined.  However, at least six architectures: alpha, ia64, m32r, m68k,
> 
> That is not what I said. DISCONTIG support needs to be fixed so that the
> core subsystems using page_to_nid() will operate correctly with a !NUMA
> discontig configuration. Core will expect page_to_nid() to only return 0
> on !NUMA.

Well, we can discuss how to proceed going forwards.  The current fact is
that any prior kernel that enables SLUB with DISCONTIGMEM and !NUMA will
eventually go boom when the page allocator returns a page not in the
first pfn array.  That has to be fixed in -stable.  I don't really think
a DISCONTIGMEM re-engineering effort would be the best thing for the
-stable series.

James


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
