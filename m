Message-ID: <20011226211554.14975.qmail@web12305.mail.yahoo.com>
Date: Wed, 26 Dec 2001 13:15:54 -0800 (PST)
From: Ravi K <kravi26@yahoo.com>
Subject: Re: few doubts in mm
In-Reply-To: <3C297B9E.65C4767@inablers.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: vishwanath@inablers.net
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

There is some good documentation on the Linux MM site
(http://linux-mm.org) which might help you.  Here are
some details that I know.

The virtual-to-physical conversion on x386 happens
like this:

- 10 (most significant) bits are used to index into
the page global directory (PGD).
- The PGD entry points to a page containing 1024 page
table entries (PTE).
- The next 10 bits of the address are used to get the
correct PTE.
- PTE points to a page of size 4096 bytes.
- The last 12 bits are used as offset within the page.

That is: 
10 bits for PGD + 10 bits for PTE + 12 bits offset

Note:
If the PSE (Page Size Extension) flag is set in the
PGD entry, the second level indexing (PGD->PTE) does
not happen. Instead, the PGD entry points to a 4MB
page and the last 22 bits are directly used as offset
within the page.
 
 Intel provides a 'Physical Address Extension'
(PAE)mode on some processors (Pentium Pro and above).
In this mode, the address size is 36-bits allowing for
up to 64GB of memory can be addressed.  Three-level
page table is used in case of PAE mode.
 
If PAE is enabled when building the Linux kernel,
virtual-to-physical conversion happens like this:
 
- 2 bits are used to index into the page global
directory.
- The PGD entry points a page containing 512 page
middle directory (PMD) entries.
- The next 9 bits of the address are used to get the
correct PMD.
- PMD entry points to a page containing 512 PTEs.
- The next 9 bits of the address are used to get the
correct PTE.
- The last 12 bits are used as offset within the page.
 
So: 2 bits for PGD + 9 bits for PMD + 9 bits for PTE +
12 bits offset
 
Note:
 Even though the address size is 36-bits, the virtual
address space is still limited to 4GB (32-bits).
 PGD, PMD and PTEs are 64-bit wide in PAE mode.
 In PAE mode, the PSE flag will be set in the PMD.

Hope this helps
Ravi.

PS: I feel your question would be more appropriate on
the kernel newbies list (kernelnewbies@nl.linux.org)


--- Vishwanath <vishwanath@inablers.net> wrote:
> Hi all
> I am new to this mailing list and also Memory
> management in linux.
> I have a doubt that how exactly the convertion of
> virtual address to
> physical addr
> happens. As for i have read in Linux Kernel
> Internals, it says there is
> some thing
> called page directory, page middle dir and page
> table, The virtual addr
> is divided into
> 4 parts(len not mentioned), The first part is index
> to page dir.
> 
> What exactly the page dir entry contains an address
> or a number index to
> page middle dir, if index,
> then where the base addr of page dir is stored, and
> base addr of page
> middle dir, and page tabe are
> stored.
> 
> How exactly this happens, The book also says that
> x86 supports only 2
> level convertion.
> How do i find out what my machine supports, i have
> linux kernel code of
> v2.4.x
> 
> Please do help me out.
> 
> Thanx in advance
> Vishy

__________________________________________________
Do You Yahoo!?
Send your FREE holiday greetings online!
http://greetings.yahoo.com
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
