Date: Wed, 6 Jun 2001 17:14:26 -0400
From: cohutta <cohutta@MailAndNews.com>
Subject: RE: temp. mem mappings
Message-ID: <3B2C3149@MailAndNews.com>
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
>On Tue, Jun 05, 2001 at 04:42:52PM -0400, cohutta wrote:
>
>> I don't really want to play with the page tables if i can help it.
>> I didn't use ioremap() because it's real system memory, not IO bus
>> memory.
>>
>> How much normal memory is identity-mapped at boot on x86?
>> Is it more than 8 MB?
>
>> I'm trying to read some ACPI tables, like the FACP.
>> On my system, this is at physical address 0x3fffd7d7 (e.g.).
>
>It depends at what time during boot.  Some ACPI memory is reusable
>once the system boots: the kernel parses the table then frees up the
>memory which the BIOS initialised.
>
>VERY early in boot, while the VM is still getting itself set up, there
>is only a minimal mapping set up by the boot loader code.  However,
>once the VM is initialised far enough to let you play with page
>tables, all memory will be identity-mapped up to just below the 1GB
>watermark.

I think this is part of the problem: on my 1 GB system, the
ACPI tables are at physical 0x3fffxxxx == virtual 0xffffxxxx,
which could conflict with the APIC and IOAPIC mappings
(from fixmap.h).
I removed 256 MB, but i still have a few problems.

>> kmap() ends up calling set_pte(), which is close to what i am
>> already doing.  i'm having a problem on the unmap side when i
>> am done with the temporary mapping.
>
>kunmap().  :-)  But kmap only works on CONFIG_HIGHMEM kernel builds.
>On kernels built without high memory support, kmap will not allow you
>to access memory beyond the normal physical memory boundary.

Well, i'm talking about physical memory, but it's marked as ACPI
data.

Another part of the problem is that I need to do this early in
arch/i386/kernel/setup.c::setup_arch(), like between calls to
paging_init() and init_apic_mappings().  I can't use ioremap()
here can i?  ioremap() calls get_vm_area() which calls
kmalloc(), and i don't think i can use kmalloc() just yet.

methinks that i'm back to a modification of Timur's suggestion--
a bunch of manual page dir/table changes.

Any other suggestions or corrections to my comments?

thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
