Message-ID: <20020405170621.49726.qmail@web12308.mail.yahoo.com>
Date: Fri, 5 Apr 2002 09:06:21 -0800 (PST)
From: Ravi <kravi26@yahoo.com>
Subject: Re: How CPU(x86) resolve kernel address
In-Reply-To: <Pine.GSO.4.10.10204051648440.18364-100000@mailhub.cdac.ernet.in>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Sanket Rathi <sanket.rathi@cdac.ernet.in>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> I read all about the memory management in linux. all thing are clear
> to me like there is 3GB space for user procee and 1GB for kernel and 
> thats why kernel address always greater then 0xC0000000. But one 
> thing is not clear that is for kernel address there is no page table,


 Page table for kernel addresses does exist. Take a look at how
'swapper_pg_dir' is set up in pagetable_init() (arch/i386/mm/init.c).
init_mm->pgd points to swapper_pg_dir, so kernel threads and the idle
context use this page table.
 Most of the time, the kernel executes in the context of a user
process. Each process' page table contains mappings for kernel virtual
addresses also. 

> actually there is no need because this is one to one mapping to 
> physical memory 

 Once paging is turned on, there is always a need for page table. The
one-to-one mapping is a feature of Linux (and maybe any other OS), not
required by the processor. Also, there is no one-to-one mapping in case
of kernel addresses obtained by interfaces like vmalloc(), kmap() and
ioremap().

> what is the mechanism by which CPU translate kernel address into 
> physical address 

  The CPU does not treat kernel addresses differently in case of
virtual-physical translation. 

> ( Somewhere i heard that CPU ignore
> some of the upper bits of address if so then how much bits and why).
 
  12 least significant bits of the Page directory entry and page table
entry are used for flags. Since the least page size supported on i386
is 4k, the last 12 bits always correspond to the offset within a page.
So they are not needed for address translation. [The flags are defined
in include/asm-i386/pgtable.h].

Hope this helps,
Ravi.

__________________________________________________
Do You Yahoo!?
Yahoo! Tax Center - online filing with TurboTax
http://taxes.yahoo.com/
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
