Date: Thu, 7 Jun 2001 11:00:33 +0100
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: temp. mem mappings
Message-ID: <20010607110033.Q1757@redhat.com>
References: <3B2C3149@MailAndNews.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <3B2C3149@MailAndNews.com>; from cohutta@MailAndNews.com on Wed, Jun 06, 2001 at 05:14:26PM -0400
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: cohutta <cohutta@MailAndNews.com>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi,

On Wed, Jun 06, 2001 at 05:14:26PM -0400, cohutta wrote:

> I think this is part of the problem: on my 1 GB system, the
> ACPI tables are at physical 0x3fffxxxx == virtual 0xffffxxxx,
> which could conflict with the APIC and IOAPIC mappings
> (from fixmap.h).

Shouldn't be --- the fixmaps should be part of the kernel's dynamic
virtual area, which is not identity mapped.  You can still map those
physical addresses via kmap() on a highmem system (and a 1GB machine
should be running a highmem kernel).

> Well, i'm talking about physical memory, but it's marked as ACPI
> data.

If it is marked PG_Reserved, then ioremap() will work on it despite it
being inside the normal physical memory area.  If not, kmap() will
still work.

> Another part of the problem is that I need to do this early in
> arch/i386/kernel/setup.c::setup_arch(), like between calls to
> paging_init() and init_apic_mappings().  I can't use ioremap()
> here can i?  ioremap() calls get_vm_area() which calls
> kmalloc(), and i don't think i can use kmalloc() just yet.

Right --- you can use alloc_pages but we haven't done the
initialisation of the kmalloc slabsl by this point.

_Why_ do you need access to the ACPI tables so early, though?

Cheers,
 Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
