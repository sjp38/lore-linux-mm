Date: Mon, 8 Nov 1999 21:50:35 +0100
From: Andi Kleen <ak@muc.de>
Subject: Re: IO mappings; verify_area() on SMP
Message-ID: <19991108215035.A3154@fred.muc.de>
References: <19991108134325.A589@it.lv>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <19991108134325.A589@it.lv>; from Arkadi E. Shishlov on Mon, Nov 08, 1999 at 12:43:25PM +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Arkadi E. Shishlov" <arkadi@it.lv>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Nov 08, 1999 at 12:43:25PM +0100, Arkadi E. Shishlov wrote:
> 
>   Second question is about verify_area() safety. Many drivers contain
>   following sequence:
> 
>   if ((ret = verify_area(VERIFY_WRITE, buffer, count)))
> 	    return r;
>   ...
>   copy_to_user(buffer, driver_data_buf, count);
> 
>   Even protected by cli()/sti() pairs, why multithreaded program on
>   SMP machine can't unmap this verified buffer between calls to
>   verify_area() and copy_to_user()? Of course it can't be true, but
>   maybe somebody can write two-three words about reason that prevent
>   this situation.

The verify_area is unnecessary in 2.2. The correct way to do it is:

	if (copy_to_user(buffer, driver_data_buf, count))
		return -EFAULT;

The above sequence is because a lot of drivers were incorrectly converted
from the 2.0 verify_area/memcpy_to_fs method to the 2.2 method. copy_from_user
avoids the race you're describing (see Documentation/exception.txt). 

verify_area() is a backwards compatibility wrapper around access_ok()
which only does a security check for kernel mode addresses, it is done
by copy_*_user too.  The real mapping check is done by the MMU by
handling the exception.

Some early 386 don't check properly for page write protection when the CPU
is in supervisor mode. In this case verify_area does a full walk of the
page tables to avoid security problems. Unfortunately there is still a race
with programs that use clone() (does not even need SMP), because when the
user access sleeps in a page fault another thread can unmap the mapping
inbetween and cause a kernel crash. Fortunately this only applies to some
very early 386 steppings, later CPUs don't have this problem (and AFAIK
no non x86 port except possibly uclinux)

Hope this helps,

-Andi
-- 
This is like TV. I don't like TV.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
