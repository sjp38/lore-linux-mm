Date: Thu, 24 May 2007 03:48:03 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch 2/8] mm: merge populate and nopage into fault (fixes nonlinear)
Message-ID: <20070524014803.GB22998@wotan.suse.de>
References: <200705180737.l4I7b5aR010752@shell0.pdx.osdl.net> <alpine.LFD.0.98.0705180758450.3890@woody.linux-foundation.org> <1179963439.32247.987.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1179963439.32247.987.camel@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, akpm@linux-foundation.org, linux-mm@kvack.org, randy.dunlap@oracle.com
List-ID: <linux-mm.kvack.org>

On Thu, May 24, 2007 at 09:37:19AM +1000, Benjamin Herrenschmidt wrote:
> On Fri, 2007-05-18 at 08:11 -0700, Linus Torvalds wrote:
> 
> > Also, the commentary says that you're planning on replacing "nopfn" too, 
> > which means that returning a "struct page *" is wrong. So the patch is
> > introducing a new interface that is already known to be broken. 
> 
> Agreed.

Yep, I will change it to return the fault type. This makes page_mkwrite
merge cleaner too.


> >  - "struct fault_data" is a stupid name. Of *course* it is data: it's a 
> >    struct. It can't be code. But it's not even about faults. It's about 
> >    missing pages.
> > 
> >    So call it something else. Maybe just "struct nopage". Or, "struct 
> >    vm_fault" at least, so that it's at least not about *random* faults.
> > 
> >  - drop "address" from "struct fault_data". Even if some user were to have 
> >    some reason to use it (doubtful), it should be called somethign long 
> >    and cumbersome, so that you don't use it by mistake, not realizing that 
> >    you should use the page index instead.
> 
> I'd rather have it in, even if it's long and cumbersome :-) As I said,
> there are a few HW drivers around the tree like spufs or some weirdo IBM
> infiniband stuff that do really tricky games with nopage/nopfn and which
> can have good use of it (at the very least, it's useful for debugging to
> printk where the accesses that ended up doing the wrong thing precisely
> was done :-)
> 
> >  - and keep calling it "nopage". 
> 
> Fine by me.

I won't do this. I'll keep calling it fault, because a) it means we keep
the backwards compatible ->nopage path until all drivers are converted,
and b) the page_mkwrite conversion really will make "nopage" the wrong
name.

I don't mind about the struct naming, but struct fault or struct nopage
seems weird to me... but whatever. Maybe we can change it to struct
fault_struct to go along with struct task_struct and struct mm_struct? ;)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
