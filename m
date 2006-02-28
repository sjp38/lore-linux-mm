Date: Mon, 27 Feb 2006 22:20:55 -0800
From: Andrew Morton <akpm@osdl.org>
Subject: Re: vDSO vs. mm : problems with ppc vdso
Message-Id: <20060227222055.4d877f16.akpm@osdl.org>
In-Reply-To: <1141106896.3767.34.camel@localhost.localdomain>
References: <1141105154.3767.27.camel@localhost.localdomain>
	<20060227215416.2bfc1e18.akpm@osdl.org>
	<1141106896.3767.34.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: linux-mm@kvack.org, hugh@veritas.com, paulus@samba.org, nickpiggin@yahoo.com.au, davem@davemloft.net
List-ID: <linux-mm.kvack.org>

Benjamin Herrenschmidt <benh@kernel.crashing.org> wrote:
>
> 
> > As mentioned on IRC, we keep on getting bugs because we don't have a clear
> > separation between 64-bit tasks (a task_struct thing) and 64-bit mm's (an
> > mm_struct thing).  I'd propose added mm_struct.task_size and testing that
> > in the appropriate places.
> 
> Ok, What about a patch adding mm->task_size and setting it to TASK_SIZE
> asap and use that to fix my bug at least. It would have to be done in 
> flush_old_exec(), after the call to flush_thread() at least on powerpc
> that's where we properly switch the TIF_32BIT flag. I can't do it
> earlier. Does that sound all right ?

It should be done with some care - I suspect this will become *the*
way in which we recognise a 64-bit mm and quite a bit of stuff will end up
migrating to it.  We do need input from the various 64-bit people who have
wrestled with these things.

> I'll send the patch as a reply to this message.

Please copy linux-arch.

> > > The second problem is more subtle and that's where I really need a VM
> > > guru to help me assess how bad the situation is and what should be done
> > > to fix it.
> > > 
> > > Since when not-COWed, those vDSO pages are actually kernel pages mapped
> > > into every process, they aren't per-se anonymous pages, nor file
> > > pages... in fact, they don't quite fit in anything rmap knows about.
> > > However, I can't mark the VMA as VM_RESERVED or anything like that since
> > > that would prevent COW from working.
> > > 
> > > Thus we hit some "interesting" code path in rmap of that sort:
> > 
> > rmap won't touch this page unless your ->nopage handler put it onto the
> > page LRU.
> 
> It indeed looks like try_to_unmap() is never called if page->mapping is
> NULL.

It's not ->mapping.  It's the fact that rmap only operates on pages which
were found on the LRU.  If you don't add it to the LRU (and surely you do
not) then no problem.

> Do you gus see any other case where my "special" vma & those kernel
> pages in could be a problem ?

It sounds just like a sound card DMA buffer to me - that's a solved
problem?  (Well, we keep unsolving it, but it's a relatively common
pattern).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
