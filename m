Date: Thu, 7 Jun 2001 21:38:06 -0400
From: cohutta <cohutta@MailAndNews.com>
Subject: RE: temp. mem mappings
Message-ID: <3B2DF994@MailAndNews.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

>===== Original Message From "Stephen C. Tweedie" <sct@redhat.com> =====
>Hi,
>
>On Wed, Jun 06, 2001 at 05:14:26PM -0400, cohutta wrote:
>
>> I think this is part of the problem: on my 1 GB system, the
>> ACPI tables are at physical 0x3fffxxxx == virtual 0xffffxxxx,
>> which could conflict with the APIC and IOAPIC mappings
>> (from fixmap.h).
>
>Shouldn't be --- the fixmaps should be part of the kernel's dynamic
>virtual area, which is not identity mapped.  You can still map those
>physical addresses via kmap() on a highmem system (and a 1GB machine
>should be running a highmem kernel).

Well i now have a 768 MB machine, but i don't think that
makes a big difference with the problem that i am seeing
in mapping this ACPI memory early in setup_arch() [x86].

>> Well, i'm talking about physical memory, but it's marked as ACPI
>> data.
>
>If it is marked PG_Reserved, then ioremap() will work on it despite it
>being inside the normal physical memory area.  If not, kmap() will
>still work.
>
>> Another part of the problem is that I need to do this early in
>> arch/i386/kernel/setup.c::setup_arch(), like between calls to
>> paging_init() and init_apic_mappings().  I can't use ioremap()
>> here can i?  ioremap() calls get_vm_area() which calls
>> kmalloc(), and i don't think i can use kmalloc() just yet.
>
>Right --- you can use alloc_pages but we haven't done the
>initialisation of the kmalloc slabsl by this point.

My testing indicates that i can't use __get_free_page(GFP_KERNEL)
any time during setup_arch() [still x86].  It causes a BUG
in slab.c (line 920) [linux 2.4.5].  Did I misunderstand you?
Do you have another suggestion?

[for others who need it, not Stephen:
  __get_free_page() -> __get_free_pages() -> alloc_pages()
  -> __alloc_pages() ]

>_Why_ do you need access to the ACPI tables so early, though?

ACPI tables have much to say about booting on newer x86 systems.
I'll try to be more specific later, when i can.

>Cheers,
> Stephen

Thanks Stephen.
/c/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
