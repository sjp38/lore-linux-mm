Date: Tue, 9 Nov 1999 11:27:32 +0200
From: "Arkadi E. Shishlov" <arkadi@it.lv>
Subject: Re: IO mappings; verify_area() on SMP
Message-ID: <19991109112732.B559@it.lv>
References: <19991108134325.A589@it.lv> <19991108215035.A3154@fred.muc.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <19991108215035.A3154@fred.muc.de>; from Andi Kleen on Mon, Nov 08, 1999 at 09:50:35PM +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@muc.de>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Nov 08, 1999 at 09:50:35PM +0100, Andi Kleen wrote:
> On Mon, Nov 08, 1999 at 12:43:25PM +0100, Arkadi E. Shishlov wrote:
> > 
> >   Second question is about verify_area() safety. Many drivers contain
> >   following sequence:
> > 
> >   if ((ret = verify_area(VERIFY_WRITE, buffer, count)))
> > 	    return r;
> >   ...
> >   copy_to_user(buffer, driver_data_buf, count);
> > 
> >   Even protected by cli()/sti() pairs, why multithreaded program on
> >   SMP machine can't unmap this verified buffer between calls to
> >   verify_area() and copy_to_user()? Of course it can't be true, but
> >   maybe somebody can write two-three words about reason that prevent
> >   this situation.
> 
> The verify_area is unnecessary in 2.2. The correct way to do it is:
> 
> 	if (copy_to_user(buffer, driver_data_buf, count))
> 		return -EFAULT;
> 
> The above sequence is because a lot of drivers were incorrectly converted
> from the 2.0 verify_area/memcpy_to_fs method to the 2.2 method. copy_from_user
> avoids the race you're describing (see Documentation/exception.txt). 

  Yes. I already read it. But... There is cases where verify_area() is
  essential. To do copy_to_user() driver need actual data to put to user.
  To get this data, driver walk through it internal structures and copy
  data to buffer, then call copy_to_user(). In case of verify_area()
  it was easy to do internal structures clean-up (packet is read - forget
  about it) while filling this buffer. In case of copy_to_user() there is
  two walk-through - first fill buffer, second - if copy_to_user() succeeds,
  alter driver structures.
  I can even imagine situation, when driver will be over-complicated, only
  because it get data from hardware and copy_to_user() fails - driver need
  to maintain additional buffer to hold this data. But it is rare case.
  I understand this decision and agree. Will rewrite my driver slightly.


  I look at verify_area() function. On i386 architecture it reduces to:

#define __range_ok(addr,size) ({ \
	unsigned long flag,sum; \
	asm("addl %3,%1 ; sbbl %0,%0; cmpl %1,%4; sbbl $0,%0" \
		:"=&r" (flag), "=r" (sum) \
		:"1" (addr),"g" (size),"g" (current->addr_limit.seg)); \
	flag; })

  I don't understand this magic code, but it looks somewhat different from
  copy_to_user() with all it .fixup's. Why not to create function named
  memset_to_user() - it will do the work of verify_area() and will be quite
  cheap.
  I found clear_user() function in arch/i386/lib/usercopy.c:

unsigned long
clear_user(void *to, unsigned long n)
{
	if (access_ok(VERIFY_WRITE, to, n))
		__do_clear_user(to, n);
	return n;
}

  Why it is not macro and why it call access_ok()?

> verify_area() is a backwards compatibility wrapper around access_ok()
> which only does a security check for kernel mode addresses, it is done
> by copy_*_user too.  The real mapping check is done by the MMU by
> handling the exception.
> 
> Some early 386 don't check properly for page write protection when the CPU
> is in supervisor mode. In this case verify_area does a full walk of the
> page tables to avoid security problems. Unfortunately there is still a race
> with programs that use clone() (does not even need SMP), because when the
> user access sleeps in a page fault another thread can unmap the mapping
> inbetween and cause a kernel crash. Fortunately this only applies to some
> very early 386 steppings, later CPUs don't have this problem (and AFAIK
> no non x86 port except possibly uclinux)
> 
> Hope this helps,

  Yes. Thank you.


arkadi.
-- 
Just arms curvature radius.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
