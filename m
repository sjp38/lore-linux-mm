Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 8ADD28D003B
	for <linux-mm@kvack.org>; Wed, 20 Apr 2011 11:03:04 -0400 (EDT)
Subject: Re: [PATCH v3] mm: make expand_downwards symmetrical to
 expand_upwards
From: James Bottomley <James.Bottomley@HansenPartnership.com>
In-Reply-To: <alpine.DEB.2.00.1104200943580.9266@router.home>
References: <20110420102314.4604.A69D9226@jp.fujitsu.com>
	 <BANLkTi=mxWwLPEnB+rGg29b06xNUD0XvsA@mail.gmail.com>
	 <20110420161615.462D.A69D9226@jp.fujitsu.com>
	 <BANLkTimfpY3gq8oY6bPDajBW7JN6Hp+A0A@mail.gmail.com>
	 <20110420112020.GA31296@parisc-linux.org>
	 <BANLkTim+m-v-4k17HUSOYSbmNFDtJTgD6g@mail.gmail.com>
	 <1303308938.2587.8.camel@mulgrave.site>
	 <alpine.DEB.2.00.1104200943580.9266@router.home>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 20 Apr 2011 10:02:59 -0500
Message-ID: <1303311779.2587.19.camel@mulgrave.site>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>, Matthew Wilcox <matthew@wil.cx>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, linux-parisc@vger.kernel.org, David Rientjes <rientjes@google.com>, Ingo Molnar <mingo@elte.hu>, x86 maintainers <x86@kernel.org>, linux-arch@vger.kernel.org, Mel Gorman <mel@csn.ul.ie>

On Wed, 2011-04-20 at 09:50 -0500, Christoph Lameter wrote:
> On Wed, 20 Apr 2011, James Bottomley wrote:
> 
> >      1. We can look at what imposing NUMA on the DISCONTIGMEM archs
> >         would do ... the embedded ones are going to be hardest hit, but
> >         if it's not too much extra code, it might be palatable.
> >      2. The other is that we can audit mm to look at all the node
> >         assumptions in the non-numa case.  My suspicion is that
> >         accidentally or otherwise, it mostly works for the normal case,
> >         so there might not be much needed to pull it back to working
> >         properly for DISCONTIGMEM.
> 
> The older code may work. SLAB f.e. does not call page_to_nid() in the
> !NUMA case but keeps special metadata structures around in each slab page
> that records the node used for allocation. The problem is with new code
> added/revised in the last 5 years or so that uses page_to_nid() and
> allocates only a single structure for !NUMA. There are also VM_BUG_ONs in
> the page allocator that should trigger if page_to_nid() returns strange
> values. I wonder why that never occurred.

Actually, I think slab got changed when discontigmem was added ...
that's why it all works OK.

> >      3. Finally we could look at deprecating DISCONTIGMEM in favour
> of >         SPARSEMEM, but we'd still need to fix -stable for that case.
> >         Especially as it will take time to convert all the architectures
> 
> The fix needed is to mark DISCONTIGMEM without NUMA as broken for now. We
> need an audit of the core VM before removing that or making it contingent
> on the configurations of various VM subsystems.

Don't be stupid ... that would cause six architectures to get marked
broken.

> > I'm certainly with Matthew: DISCONTIGMEM is supposed to be a lightweight
> > framework which allows machines with split physical memory ranges to
> > work.  That's a very common case nowadays.  Numa is supposed to be a
> > heavyweight framework to preserve node locality for non-uniform memory
> > access boxes (which none of the DISCONTIGMEM && !NUMA systems are).
> 
> Well yes but we have SPARSE for that today. DISCONTIG with multiple per
> pgdat structures in a !NUMA case is just weird and unexpected for many who
> have done VM coding in the last years.

Look, I'm not really interested in who understands what.  The fact is we
have six architectures with the possibility for DISCONTIGMEM && !NUMA,
so that's the case we need to fix in -stable.

They oops with SLUB, as far as I can tell, there are still no oops
reports with SLAB.  The simplest -stable fix seems to be to mark SLUB
broken on DISCONTIGMEM && !NUMA.

James


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
