Date: Thu, 25 Apr 2002 16:19:22 +0100 (BST)
From: Christian Smith <csmith@micromuse.com>
Subject: Re: Why *not* rmap, anyway?
In-Reply-To: <Pine.LNX.4.44L.0204241112090.7447-100000@duckman.distro.conectiva>
Message-ID: <Pine.LNX.4.33.0204251240510.1968-100000@erol>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 24 Apr 2002, Rik van Riel wrote:

>On Wed, 24 Apr 2002, Christian Smith wrote:
>> On Tue, 23 Apr 2002, Rik van Riel wrote:
>> >On Tue, 23 Apr 2002, Christian Smith wrote:
>> >
>> >> The question becomes, how much work would it be to rip out the Linux MM
>> >> piece-meal, and replace it with an implementation of UVM?
>> >
>> >I doubt we want the Mach pmap layer.
>>
>> Why not? It'd surely make porting to new architecures easier (not that
>> I've tried it either way, mind)
>
>You really need to read the pmap code and interface instead
>of repeating the statements made by other people. Have you
>ever taken a close look at the overhead implicit in the pmap
>layer ?

Just how much overhead is there? The only overhead that would come into 
play would/should be when:
- On a TLB based MMU, when there is a soft page fault and a pmap 
  implementation doesn't cache translations over and above those in the 
  TLB.
- Inverted page table when the required <address_space,virtual_address> 
  lookup fails.
- When mapping in a new page after a hard page fault (small compared to 
  the overhead of paging in from backing store.)

>
>
>> interface. Pmap can hide the differences between forward mapping page
>> table, TLB or inverted page table lookups, can do SMP TLB shootdown
>> transparently. If not the Mach pmap layer, then surely another pmap-like
>> layer would be beneficial.
>
>Then how about the Linux pmap layer ?
>
>The datastructure is a radix tree, which happens to map 1 to 1
>with the MMU on most architectures. On architectures that don't
>have forward page tables Linux fills in the hardware's translation
>tables with data from those radix trees.

Thus resulting in redundant information. The benefit of the pmap/hat 
is that on architectures with forward mapping, this can be used as is, 
whereas other MMU architectures can dispense with the middle man 
completely.

For a "pmap" interface, the "Linux pmap" is horribly complex. Not only the 
fact that it is a three level page table, but also that fact that it 
contains swap information.

It's a similar situation to what <4.4BSD was in, when they had their VAX
based paging VM. Upon moving to Mach VM, they could do all sorts of
optimasations that were simply not viable with the old VM, and improved
performance significantly, as well as simplified maintainance and eased
porting.

Same with SunOS's hat based VM, Same with SysV when they inherited the
SunOS VM.

About the only other major OS I know of that uses the page table as their 
primary VM management data structure is the NT kernel.

When it comes down to it, the platform independant part of VM works with
address space identifiers, virtual addresses, physical addresses and
protection attributes. That should then be all the pmap interface exposes,
and is indeed all that the Mach pmap interface exposes. A clean 
seperation.

>
>
>> It can handle sparse address space management without the hackery of
>> n-level page tables, where a couple of years ago, 3 levels was enough for
>> anyone, but now we're not so sure.
>>
>> The n-level page table doesn't fit in with a high level, platform
>> independant MM, and doesn't easily work for all classes of low level MMU.
>> It doesn't really scale up or down.
>
>Do you have any arguments or are you just repeating what you
>read somewhere else ?

And an argument I've read is any less valid because...

Actually, the scaling issue is something I've thought about as I have an 
interest in small systems, that don't really want to be wasting pages for 
page tables that can't be discarded or reused until they are finished 
with. With the current Linux VM, page tables are not discardable or 
reusable. With an opaque pmap interface, page tables can be discarded if 
they haven't been used for a while and the subsequent free memory used 
elsewhere.

Similarly for big systems, a server with hundreds of processes has to keep 
all the page tables resident, even if most of the processes are idle 
99.9% of the time.

>
>Just think about it for a second ... the radix tree structure
>of page tables are as good a datastructure as any other.
>
>The mythical "sparse mappings" seem to be very rare in real
>life and I'm not convinced they are a reason to change all of
>our VM.

I'm worried that the rmap fix is a band-aid on a hacked i386 based VM
system. Rather than trying to adapt a previously hacked solution, it might 
be better just to wipe the slate clean.

>
>
>regards,
>
>Rik
>

-- 
    /"\
    \ /    ASCII RIBBON CAMPAIGN - AGAINST HTML MAIL 
     X                           - AGAINST MS ATTACHMENTS
    / \



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
