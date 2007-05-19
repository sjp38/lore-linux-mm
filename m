Date: Sat, 19 May 2007 03:38:32 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch 2/8] mm: merge populate and nopage into fault (fixes nonlinear)
Message-ID: <20070519013832.GD15569@wotan.suse.de>
References: <200705180737.l4I7b5aR010752@shell0.pdx.osdl.net> <alpine.LFD.0.98.0705180758450.3890@woody.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LFD.0.98.0705180758450.3890@woody.linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, randy.dunlap@oracle.com
List-ID: <linux-mm.kvack.org>

On Fri, May 18, 2007 at 08:11:35AM -0700, Linus Torvalds wrote:
> 
> 
> On Fri, 18 May 2007, akpm@linux-foundation.org wrote:
> > 
> > Nonlinear mappings are (AFAIKS) simply a virtual memory concept that encodes
> > the virtual address -> file offset differently from linear mappings.
> 
> I'm not going to merge this one.
> 
> First off, I don't see the point of renaming "nopage" to "fault". If you 
> are looking for compiler warnings, you might as well just change the 
> prototype and be done with it.

I considered that, but it is going to break a whole lot of drivers (and
I guess some out of tree code FWIW). If you want me to attempt to convert
all drivers in the tree, then...

(BTW, I agree the whole series is late, and I would have rathered it go
in -rc1).


> The new name is not even descriptive, since 
> it's all about nopage, and not about any other kind of faults.

I'm going to convert page_mkwrite over as well.


> [ Side note: why is "address" there in the fault data? It would seem that 
>   anybody that uses it is by definition buggy, so it shouldn't be there if 
>   we're fixing up the interfaces. ]

It could matter for some things... page colouring maybe.


> Also, the commentary says that you're planning on replacing "nopfn" too, 
> which means that returning a "struct page *" is wrong. So the patch is
> introducing a new interface that is already known to be broken. 
> 
> Here's a suggestion:
> 
>  - make "nopage()" return "int" (the status code). Move the "struct page" 
>    pointer into the data area, and add a "pte_t" entry there too, so that 
>    the callee can now decide to fill in one or the other (or neither, if 
>    it returns an error).

Actually, I was thinking about changing to an int return code which
makes the page_mkwrite conversion nicer too. But a pte_t? Yuck Linus!

 
>  - "struct fault_data" is a stupid name. Of *course* it is data: it's a 
>    struct. It can't be code. But it's not even about faults. It's about 
>    missing pages.
> 
>    So call it something else. Maybe just "struct nopage". Or, "struct 
>    vm_fault" at least, so that it's at least not about *random* faults.

The name doesn't bother me so much, but as I said, it is not just going
to be for missing pages. Also, keeping nopage means a full conversion,
wheras we can support nopage with a few lines of backward compatible code.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
