Message-ID: <3B21050C.8A3699A9@earthlink.net>
Date: Fri, 08 Jun 2001 11:02:04 -0600
From: "Joseph A. Knapka" <jknapka@earthlink.net>
MIME-Version: 1.0
Subject: Re: temp. mem mappings
References: <3B2DF994@MailAndNews.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: cohutta <cohutta@MailAndNews.com>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

cohutta wrote:
> 
> >===== Original Message From "Stephen C. Tweedie" <sct@redhat.com> =====
> >Hi,
> >
> >On Wed, Jun 06, 2001 at 05:14:26PM -0400, cohutta wrote:
> >
> >> I think this is part of the problem: on my 1 GB system, the
> >> ACPI tables are at physical 0x3fffxxxx == virtual 0xffffxxxx,
> >> which could conflict with the APIC and IOAPIC mappings
> >> (from fixmap.h).
> >
> >Shouldn't be --- the fixmaps should be part of the kernel's dynamic
> >virtual area, which is not identity mapped.  You can still map those
> >physical addresses via kmap() on a highmem system (and a 1GB machine
> >should be running a highmem kernel).
> 
> Well i now have a 768 MB machine, but i don't think that
> makes a big difference with the problem that i am seeing
> in mapping this ACPI memory early in setup_arch() [x86].
> 
> >> Well, i'm talking about physical memory, but it's marked as ACPI
> >> data.
> >
> >If it is marked PG_Reserved, then ioremap() will work on it despite it
> >being inside the normal physical memory area.  If not, kmap() will
> >still work.
> >
> >> Another part of the problem is that I need to do this early in
> >> arch/i386/kernel/setup.c::setup_arch(), like between calls to
> >> paging_init() and init_apic_mappings().  I can't use ioremap()
> >> here can i?  ioremap() calls get_vm_area() which calls
> >> kmalloc(), and i don't think i can use kmalloc() just yet.
> >
> >Right --- you can use alloc_pages but we haven't done the
> >initialisation of the kmalloc slabsl by this point.
> 
> My testing indicates that i can't use __get_free_page(GFP_KERNEL)
> any time during setup_arch() [still x86].  It causes a BUG
> in slab.c (line 920) [linux 2.4.5].  Did I misunderstand you?
> Do you have another suggestion?

Oops. You can't use __get_free_page() or alloc_pages() until
mem_init() is called, which occurs in main/init.c:start_kernel()
quite some time after setup_arch() has happened.

If you need pages before mem_init() happens, but after paging_init()
has completed in setup_arch(), then use alloc_bootmem()/free_bootmem().
Any bootmem you alloc and don't free will end up being reserved.

-- Joe
 

-- Joseph A. Knapka
"You know how many remote castles there are along the gorges? You
 can't MOVE for remote castles!" -- Lu Tze re. Uberwald
// Linux MM Documentation in progress:
// http://home.earthlink.net/~jknapka/linux-mm/vmoutline.html
* Evolution is an "unproven theory" in the same sense that gravity is. *
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
