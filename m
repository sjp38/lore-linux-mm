Content-Type: text/plain;
  charset="iso-8859-1"
From: Daniel Phillips <phillips@bonn-fries.net>
Subject: Re: [RFC] Page table sharing
Date: Tue, 19 Feb 2002 03:22:21 +0100
References: <Pine.LNX.4.33.0202181758260.24597-100000@home.transmeta.com>
In-Reply-To: <Pine.LNX.4.33.0202181758260.24597-100000@home.transmeta.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Message-Id: <E16czvB-0000z2-00@starship.berlin>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>, Rik van Riel <riel@conectiva.com.br>
Cc: Hugh Dickins <hugh@veritas.com>, dmccr@us.ibm.com, Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Robert Love <rml@tech9.net>, mingo@redhat.co, Andrew Morton <akpm@zip.com.au>, manfred@colorfullife.com, wli@holomorphy.com
List-ID: <linux-mm.kvack.org>

On February 19, 2002 03:05 am, Linus Torvalds wrote:
> On Mon, 18 Feb 2002, Rik van Riel wrote:
> >
> > The swapout code can remove a page from the page table
> > while another process is in the process of unsharing
> > the page table.
> 
> Ok, I'll buy that. However, looking at that, the locking is not the real
> issue at all:
> 
> When the swapper does a "ptep_get_and_clear()" on a shared pmd, it will
> end up having to not just synchronize with anybody doing unsharing, it
> will have to flush all the TLB's on all the mm's that might be implicated.
> 
> Which implies that the swapper needs to look up all mm's some way anyway,

Ick.  With rmap this is straightforward, but without, what?  flush_tlb_all?
Maybe page tables should be unshared on swapin/out after all, only on arches
that need special tlb treatment, or until we have rmap.

> so the locking gets solved that way.

-- 
Daniel
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
