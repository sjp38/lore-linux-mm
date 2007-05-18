Date: Fri, 18 May 2007 08:11:35 -0700 (PDT)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [patch 2/8] mm: merge populate and nopage into fault (fixes
 nonlinear)
In-Reply-To: <200705180737.l4I7b5aR010752@shell0.pdx.osdl.net>
Message-ID: <alpine.LFD.0.98.0705180758450.3890@woody.linux-foundation.org>
References: <200705180737.l4I7b5aR010752@shell0.pdx.osdl.net>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, npiggin@suse.de, randy.dunlap@oracle.com
List-ID: <linux-mm.kvack.org>


On Fri, 18 May 2007, akpm@linux-foundation.org wrote:
> 
> Nonlinear mappings are (AFAIKS) simply a virtual memory concept that encodes
> the virtual address -> file offset differently from linear mappings.

I'm not going to merge this one.

First off, I don't see the point of renaming "nopage" to "fault". If you 
are looking for compiler warnings, you might as well just change the 
prototype and be done with it. The new name is not even descriptive, since 
it's all about nopage, and not about any other kind of faults.

[ Side note: why is "address" there in the fault data? It would seem that 
  anybody that uses it is by definition buggy, so it shouldn't be there if 
  we're fixing up the interfaces. ]

Also, the commentary says that you're planning on replacing "nopfn" too, 
which means that returning a "struct page *" is wrong. So the patch is
introducing a new interface that is already known to be broken. 

Here's a suggestion:

 - make "nopage()" return "int" (the status code). Move the "struct page" 
   pointer into the data area, and add a "pte_t" entry there too, so that 
   the callee can now decide to fill in one or the other (or neither, if 
   it returns an error).

 - "struct fault_data" is a stupid name. Of *course* it is data: it's a 
   struct. It can't be code. But it's not even about faults. It's about 
   missing pages.

   So call it something else. Maybe just "struct nopage". Or, "struct 
   vm_fault" at least, so that it's at least not about *random* faults.

 - drop "address" from "struct fault_data". Even if some user were to have 
   some reason to use it (doubtful), it should be called somethign long 
   and cumbersome, so that you don't use it by mistake, not realizing that 
   you should use the page index instead.

 - and keep calling it "nopage". 

But regardless, it's *way* too late for introducing things like this that 
don't even fix a bug after -rc1.

			Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
