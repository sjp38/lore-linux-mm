Message-ID: <19991109114038.13044@colin.muc.de>
Date: Tue, 9 Nov 1999 11:40:38 +0100
From: Andi Kleen <ak@muc.de>
Subject: Re: IO mappings; verify_area() on SMP
References: <19991108134325.A589@it.lv> <19991108215035.A3154@fred.muc.de> <19991109112732.B559@it.lv>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <19991109112732.B559@it.lv>; from Arkadi E. Shishlov on Tue, Nov 09, 1999 at 10:27:32AM +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Arkadi E. Shishlov" <arkadi@it.lv>
Cc: Andi Kleen <ak@muc.de>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Nov 09, 1999 at 10:27:32AM +0100, Arkadi E. Shishlov wrote:
> On Mon, Nov 08, 1999 at 09:50:35PM +0100, Andi Kleen wrote:
> > On Mon, Nov 08, 1999 at 12:43:25PM +0100, Arkadi E. Shishlov wrote:
> > > 
> > >   Second question is about verify_area() safety. Many drivers contain
> > >   following sequence:
> > > 
> > >   if ((ret = verify_area(VERIFY_WRITE, buffer, count)))
> > > 	    return r;
> > >   ...
> > >   copy_to_user(buffer, driver_data_buf, count);
> > > 
> > >   Even protected by cli()/sti() pairs, why multithreaded program on
> > >   SMP machine can't unmap this verified buffer between calls to
> > >   verify_area() and copy_to_user()? Of course it can't be true, but
> > >   maybe somebody can write two-three words about reason that prevent
> > >   this situation.
> > 
> > The verify_area is unnecessary in 2.2. The correct way to do it is:
> > 
> > 	if (copy_to_user(buffer, driver_data_buf, count))
> > 		return -EFAULT;
> > 
> > The above sequence is because a lot of drivers were incorrectly converted
> > from the 2.0 verify_area/memcpy_to_fs method to the 2.2 method. copy_from_user
> > avoids the race you're describing (see Documentation/exception.txt). 
> 
>   Yes. I already read it. But... There is cases where verify_area() is
>   essential. To do copy_to_user() driver need actual data to put to user.
>   To get this data, driver walk through it internal structures and copy
>   data to buffer, then call copy_to_user(). In case of verify_area()
>   it was easy to do internal structures clean-up (packet is read - forget
>   about it) while filling this buffer. In case of copy_to_user() there is
>   two walk-through - first fill buffer, second - if copy_to_user() succeeds,
>   alter driver structures.
>   I can even imagine situation, when driver will be over-complicated, only
>   because it get data from hardware and copy_to_user() fails - driver need
>   to maintain additional buffer to hold this data. But it is rare case.
>   I understand this decision and agree. Will rewrite my driver slightly.

There is no alternative. *_user can sleep, and another thread can unmap
while it is sleeping. So it has to be checking in *_user by the MMU.
 
> 
> 
>   I look at verify_area() function. On i386 architecture it reduces to:
> 
> #define __range_ok(addr,size) ({ \
> 	unsigned long flag,sum; \
> 	asm("addl %3,%1 ; sbbl %0,%0; cmpl %1,%4; sbbl $0,%0" \
> 		:"=&r" (flag), "=r" (sum) \
> 		:"1" (addr),"g" (size),"g" (current->addr_limit.seg)); \
> 	flag; })
> 
>   I don't understand this magic code, but it looks somewhat different from
>   copy_to_user() with all it .fixup's. Why not to create function named
>   memset_to_user() - it will do the work of verify_area() and will be quite
>   cheap.

I don't understand. What __range_ok basically does is to check if the
address is part of the address space reserved for the user. It it wouldn't
do that the user could specify a kernel address and access internal
kernel structures, leading to a security leak. This is a bit complicated
because the kernel sometimes wants to do IO to/from internal buffers (e.g.
for NFS), so the idea of kernel and user memory can be switched (with
set_fs(KERNEL_DS) which sets current->addr_limit). The assembly magic 
above is just a fancy jumpless way to implement this check. It has nothing
to do with memset.


>   I found clear_user() function in arch/i386/lib/usercopy.c:
> 
> unsigned long
> clear_user(void *to, unsigned long n)
> {
> 	if (access_ok(VERIFY_WRITE, to, n))
> 		__do_clear_user(to, n);
> 	return n;
> }
> 
>   Why it is not macro and why it call access_ok()?

See above.

-Andi
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
