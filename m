Subject: Re: vDSO vs. mm : problems with ppc vdso
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
In-Reply-To: <20060227215416.2bfc1e18.akpm@osdl.org>
References: <1141105154.3767.27.camel@localhost.localdomain>
	 <20060227215416.2bfc1e18.akpm@osdl.org>
Content-Type: text/plain
Date: Tue, 28 Feb 2006 17:08:16 +1100
Message-Id: <1141106896.3767.34.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-mm@kvack.org, hugh@veritas.com, paulus@samba.org, nickpiggin@yahoo.com.au, "David S. Miller" <davem@davemloft.net>
List-ID: <linux-mm.kvack.org>

> As mentioned on IRC, we keep on getting bugs because we don't have a clear
> separation between 64-bit tasks (a task_struct thing) and 64-bit mm's (an
> mm_struct thing).  I'd propose added mm_struct.task_size and testing that
> in the appropriate places.

Ok, What about a patch adding mm->task_size and setting it to TASK_SIZE
asap and use that to fix my bug at least. It would have to be done in 
flush_old_exec(), after the call to flush_thread() at least on powerpc
that's where we properly switch the TIF_32BIT flag. I can't do it
earlier. Does that sound all right ?

I'll send the patch as a reply to this message.

> > The second problem is more subtle and that's where I really need a VM
> > guru to help me assess how bad the situation is and what should be done
> > to fix it.
> > 
> > Since when not-COWed, those vDSO pages are actually kernel pages mapped
> > into every process, they aren't per-se anonymous pages, nor file
> > pages... in fact, they don't quite fit in anything rmap knows about.
> > However, I can't mark the VMA as VM_RESERVED or anything like that since
> > that would prevent COW from working.
> > 
> > Thus we hit some "interesting" code path in rmap of that sort:
> 
> rmap won't touch this page unless your ->nopage handler put it onto the
> page LRU.

It indeed looks like try_to_unmap() is never called if page->mapping is
NULL.

Do you gus see any other case where my "special" vma & those kernel
pages in could be a problem ?

Cheers,
Ben.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
