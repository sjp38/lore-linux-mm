Date: Tue, 7 May 2002 19:37:14 +0100 (BST)
From: Christian Smith <csmith@micromuse.com>
Subject: Re: Why *not* rmap, anyway?
In-Reply-To: <E174RIu-00049X-00@starship>
Message-ID: <Pine.LNX.4.33.0205071625570.1579-100000@erol>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Daniel Phillips <phillips@bonn-fries.net>
Cc: Rik van Riel <riel@conectiva.com.br>, Joseph A Knapka <jknapka@earthlink.net>, "Martin J. Bligh" <Martin.Bligh@us.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

I can clearly see this is flogging a dead horse, so I'll let it lie, save
the following observations and comments inline:
- The Linux VM is very difficult to pick up. Maybe not conceptually, but 
  the implementation is a nightmare to follow. That's probably why it's so 
  poorly documented.
- While rmap is the way to go, it's still more of a band-aid than an 
  intergrated solution.
- do_page_fault() is definately in the wrong place, or at least, the work 
  it does (it finds the generic vma of the fault. This should be generic 
  code.)
- Most people appear to be aiming towards absolute speed in all cases, 
  without considering the wider picture. Anything that makes choosing the 
  correct page to page out will out do any level of code optimisation due 
  to the obvious limits to IO speed. Looking at Linux VM performance 
  against any of the BSDs and SysV should indicate that a split generic 
  VM/pmap layer is easier to optimise for the heavy load conditions, not
  to mention maintain.
- I find this a fascinating discussion. If anyone fancies posting any 
  pointers to detailed Linux VM docs, that'd be great. I don't want to 
  swamp the list with this, so I'm happy to take anything off list (IRC?)

Finally, I'm not dissing anyone's work, especially not the rmap work from 
Rik. I just think there's a better way, and the stability problems of 
earlier 2.4.x kernels might have been avoided with a simpler VM.

Christian

On Sun, 5 May 2002, Daniel Phillips wrote:

>On Wednesday 24 April 2002 12:50, Christian Smith wrote:
>> On Tue, 23 Apr 2002, Rik van Riel wrote:
>> >On Tue, 23 Apr 2002, Christian Smith wrote:
>> >
>> >> The question becomes, how much work would it be to rip out the Linux MM
>> >> piece-meal, and replace it with an implementation of UVM?
>> >
>> >I doubt we want the Mach pmap layer.
>> 
>> Why not?
>
>Because we use the page tables as part of our essential vm bookkeeping, thus
>eliminating the whole UVM/mach 'memory objects' layer.  There was only ever
>one trick the memory objects layer could do that we could not with our simple
>page table based approach, that being page table sharing.  And now we've found
>a way to do that as well, so there is no longer a single advantage to the
>memory object strategy, while there is a lot of hard-to-read-and-maintain code
>associated with it, and bookkeeping overhead.  (Note I'm not talking about the
>rmap aspect here - that's overhead that buys us something tangible - we
>think.)

IMHO, page tables are not the place to hold this bookkeeping information.

My interest was in replacing, completely, the VM and using a memory object
like layer. With that would come the need for a pmap like layer.

Another benefit to the memory object approach is that memory objects are a
more logical representation of a file mapping, which is essentially what
most memory is (anonymous memory could be thought of as a mapping of an
anonymouse backed by swap space.) This intergrates VM/VFS memory usage.

VFS already knows which pages of an object are mapped. Memory objects 
would be a simple layer on top of that. This doesn't happen in Linux, as 
far as I can fathom.

>
>> It'd surely make porting to new architecures easier
>
>It doesn't really.  Ask Linus if you need to know in gory detail why, or
>better, search the lkml archives.  This comes up regularly, and imho, Linus
>is clearly correct here, both on theoretical grounds and in practice.

Except to port a pmap interface, you need to know only the pmap interface
and target processor. To port Linux VM, you need to know a complex data
structure and associated manipulation API, which may change in future.

>
>In fact, we do have our own abstraction, which is simply a per-architecture
>implementation of the basic page table editing operations.  On architectures
>that support it (ia32, uml, others) the hardware interprets the page tables
>directly.  Otherwise, the contents of the generic page tables are forwarded
>incrementally to the real hardware page tables.
>
>Sticking strictly to the ia32 page table model *is* going to break
>eventually, however it hasn't yet and we have plenty of time to generalize
>the page table model when needed.  Note: 'generalize', not 'lather on a new
>layer'.

I still find this a blinkered outlook. Pmap isn't even a new layer that 
shouldn't be there. There really should be a generic/non-generic split (yes,
I know the page table stuff if generic.)

>
>> (not that
>> I've tried it either way, mind) is there is a clearly defined MMU
>> interface. Pmap can hide the differences between forward mapping page
>> table, TLB or inverted page table lookups,
>
>Not only hide, but interfere with.  For example, in my page table sharing
>patch I treat page directories as first-class objects, with ref counts and
>individual locks.  How do we extend the pmap api to accomodate that?

I shouldn't care. That's the benefit of an opaque API. If page table space 
is a problem, with pmap I can just dump page directories that haven't been 
used for a while (the information would be a redundant copy of the upper
level generic VM.) Afterall, a sleeping process is not going to need to 
handle page faults. And even running process is unlikely to need all it's
page directories at once.

>
>> can do SMP TLB shootdown 
>> transparently.
>
>But we already do that per-architecture, with a generic api.

Possibly a bad example.

>
>> If not the Mach pmap layer, then surely another pmap-like 
>> layer would be beneficial.
>
>How about the one we already have?

I don't like using a data structure as an 'API'. An API ideally gives you 
an interface to what you need to do, not how it's done. Sure, APIs can 
become obsolete, but function calls are MUCH easier to provide legacy 
support for than a large, complex data structure.

>
>> It can handle sparse address space management without the hackery of 
>> n-level page tables, where a couple of years ago, 3 levels was enough for 
>> anyone, but now we're not so sure.
>
>This is true, however we don't need to add a new layer to deal with that,
>just generalize the existing one.  You want to be very careful about where
>you draw that boundaries, to avoid becoming hampered by the lowest common
>denoninator effect.

The problem is that there are no boundaries at the moment.

>
>> The n-level page table doesn't fit in with a high level, platform 
>> independant MM, and doesn't easily work for all classes of low level MMU. 
>> It doesn't really scale up or down.
>
>I don't agree with 'doesn't scale down'.  I partially agree with 'doesn't
>scale up'.  *However*, whatever bookkeeping structure we ultimately end up
>with, it has to permit efficient processing in VM order - otherwise how are
>you going to implement zap_page_range for example?  So it's going to stay
>as some kind of tree, though it doesn't have to remain as rigidly defined
>as it now is.

As far as scaling down goes, I've given an example above of where page
directories (or whole page tables,) can be discarded to save space. 
Resident pages are managed by the vnode, and can be looked quickly when 
needed using the <vnode,offset> hash. For a small platform, it may be 
beneficial to sacrifice page table space when the information is 
redundant. In this sense, the pmap data is simply a cache.

Memory objects can easily do VM order processing. But why would it be
necassary? For trancate() of mapped file, rmap or such like can provide a
better way of unmapping the pages. For unmapping of memory, pmap_remove
should fit the bill.

>
>> Read the papers on UVM at:
>>  http://www.ccrc.wustl.edu/pub/chuck/tech/uvm
>
>Been there, done that :-)

Fair enough:)

-- 
    /"\
    \ /    ASCII RIBBON CAMPAIGN - AGAINST HTML MAIL 
     X                           - AGAINST MS ATTACHMENTS
    / \




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
