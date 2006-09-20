Subject: Re: [RFC] page fault retry with NOPAGE_RETRY
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
In-Reply-To: <20060919200533.2874ce36.akpm@osdl.org>
References: <1158274508.14473.88.camel@localhost.localdomain>
	 <20060915001151.75f9a71b.akpm@osdl.org> <45107ECE.5040603@google.com>
	 <1158709835.6002.203.camel@localhost.localdomain>
	 <1158710712.6002.216.camel@localhost.localdomain>
	 <20060919172105.bad4a89e.akpm@osdl.org>
	 <1158717429.6002.231.camel@localhost.localdomain>
	 <20060919200533.2874ce36.akpm@osdl.org>
Content-Type: text/plain
Date: Wed, 20 Sep 2006 15:06:19 +1000
Message-Id: <1158728779.6002.265.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Mike Waychison <mikew@google.com>, linux-mm@kvack.org, Linux Kernel list <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@osdl.org>
List-ID: <linux-mm.kvack.org>

On Tue, 2006-09-19 at 20:05 -0700, Andrew Morton wrote:
> On Wed, 20 Sep 2006 11:57:09 +1000
> Benjamin Herrenschmidt <benh@kernel.crashing.org> wrote:
> 
> > > You forget that the point of this optimisation is to undo mmap_sem while
> > > waiting on the disk IO.  Once we've done that we cannot go looking at ptes
> > > or vmas: another thread could have munapped the whole lot or anything. 
> > > (And we always need to be afraid of use_mm()..)
> > 
> > Wait wait .. .we don't need to have the mmap sem to -look- at a PTE.
> 
> The pte resides in a pagetable page.  Once we've dropped mmap_sem, that
> pagetable page might not be there any more: munmap() might have freed it. 
> We have to retake mmap_sem, do a find_vma() and a new pagetable walk.

Ok, see my other email, we have the mmap_sem anyway so it's fine. Note
that I got a little bit mislead on that "we can wlak the page table
without mmap_sem" because we can on powerpc :) but possibly not on
x86.... we use RCU to free pagetable pages to make that possible because
our hash refill code (equivalent to our TLB miss if you want to see it
that way) has to be able to do that. I think the x86 MMU has some way to
atomically do the walking which is why you don't need that on x86 but I
don't know x86 so ...

Ben.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
