Message-ID: <37BD0559.99C5E320@mandrakesoft.com>
Date: Fri, 20 Aug 1999 07:35:53 +0000
From: Thierry Vignaud <tvignaud@mandrakesoft.com>
MIME-Version: 1.0
Subject: Re: [bigmem-patch] 4GB with Linux on IA32
References: <Pine.LNX.4.10.9908170212250.14570-100000@laser.random>
		<37BC07AC.76E81480@mandrakesoft.com> <14268.13703.716732.620692@dukat.scot.redhat.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Andrea Arcangeli <andrea@suse.de>, Alan Cox <alan@lxorguk.ukuu.org.uk>, Kanoj Sarcar <kanoj@google.engr.sgi.com>, torvalds@transmeta.com, Gerhard.Wichert@pdb.siemens.de, Winfried.Gerhard@pdb.siemens.de, x-linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

"Stephen C. Tweedie" wrote:
> 
> Hi,
> 
> On Thu, 19 Aug 1999 13:33:32 +0000, Thierry Vignaud
> <tvignaud@mandrakesoft.com> said:
> 
> > since only recent motherboard support more than 512Mb RAM, and since
> > they used i686 (PPro, P2, P3), why not use the pse36 extension of
> > these cpu that enable to stock the segment length on 24bits, which
> > give 64To when mem unit is 4b page.  this'll make the limit much
> > higher (say 128Mb RAM for the kernel space memory and 15,9To for the
> > user space).
> 
> The PAE36 extensions let you address 64GB of physical memory, but don't
> change the fact that you still have a 32-bit user address space: the
> user space is still limited to 3GB.
> 
> > This would break some api, but why not add foo_64 for each foo()
> > function as glibc does for big files ?  As for standard api such as of
> > libc, i don't think wa have to worry about. There are few Programs
> > which want a lot of memory such as oracle.  For these, we may find a
> > special way of accessing the mem (64bits pointers, 64bit mmap, ...)
> 
> The CPU doesn't support 64 bit pointers.  Kind of makes it a bit
> inefficient to access the user memory if you have to make a system call
> every time. :)
Yes, but we do can use 24:32 referencse (as
pse36_extended_selectors:offset). Each process may own a ldt that allow
him to own several 4Gb segment : code, data, stack, kernel mem mapped,
librairies, shared mem (X11/dga -> fb mem and IPC shm).
Each of these segments is still large up to 4Gb, but the process may
addresse more than 4Gb.
We may have to hack gcc & binutils so they generate references against
new selectors. We may put the kernel mem region that the process see in
another segment and alter includes macros so that they handle acess to
kernel structs via the new selector (es,fs or gs on ix86).
As this could broke a lot of soft, we may define a flag in ELF header
that select 2:2 split of ram or the new scheme.

Another solution : add a new brk36 on ix86 that enable very big apps
(such as oracle) to own multiple 4Gb segment and then give to the
userland developper all the difficulties.

Yes, i know, if someone want a lot of mem, he should switch to a 64 bits
arch, but there are now some servers which manage up to 16Go RAM. WinNT
has put a choose a stupid trick and reinvent their classic solution
(EMS, XMS, ...) by allowing apps to copy blocks from above the 4Gb mem.
This is really stupid but they can say they manage more than 4Gb and not
us.

-- 
MandrakeSoft          http://www.mandrakesoft.com/
	somewhere between the playstation and the super cray
			         	 --Thierry
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
