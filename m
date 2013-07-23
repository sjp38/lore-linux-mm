Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx123.postini.com [74.125.245.123])
	by kanga.kvack.org (Postfix) with SMTP id ABCE76B0032
	for <linux-mm@kvack.org>; Mon, 22 Jul 2013 20:35:35 -0400 (EDT)
Message-ID: <1374539678.16322.69.camel@misato.fc.hp.com>
Subject: Re: [PATCH v2] mm/hotplug, x86: Disable ARCH_MEMORY_PROBE by default
From: Toshi Kani <toshi.kani@hp.com>
Date: Mon, 22 Jul 2013 18:34:38 -0600
In-Reply-To: <51ED9CC2.8040604@gmail.com>
References: <1374256068-26016-1-git-send-email-toshi.kani@hp.com>
	  <20130722083721.GC25976@gmail.com>
	 <1374513120.16322.21.camel@misato.fc.hp.com> <51ED9CC2.8040604@gmail.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Cc: Ingo Molnar <mingo@kernel.org>, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, x86@kernel.org, dave@sr71.net, isimatu.yasuaki@jp.fujitsu.com, tangchen@cn.fujitsu.com, vasilis.liaskovitis@profitbricks.com

On Mon, 2013-07-22 at 16:57 -0400, KOSAKI Motohiro wrote:
> (7/22/13 1:12 PM), Toshi Kani wrote:
> > On Mon, 2013-07-22 at 10:37 +0200, Ingo Molnar wrote:
> >> * Toshi Kani <toshi.kani@hp.com> wrote:
> >>
> >>> CONFIG_ARCH_MEMORY_PROBE enables /sys/devices/system/memory/probe
> >>> interface, which allows a given memory address to be hot-added as
> >>> follows. (See Documentation/memory-hotplug.txt for more detail.)
> >>>
> >>> # echo start_address_of_new_memory > /sys/devices/system/memory/probe
> >>>
> >>> This probe interface is required on powerpc. On x86, however, ACPI
> >>> notifies a memory hotplug event to the kernel, which performs its
> >>> hotplug operation as the result. Therefore, regular users do not need
> >>> this interface on x86. This probe interface is also error-prone and
> >>> misleading that the kernel blindly adds a given memory address without
> >>> checking if the memory is present on the system; no probing is done
> >>> despite of its name. The kernel crashes when a user requests to online
> >>> a memory block that is not present on the system. This interface is
> >>> currently used for testing as it can fake a hotplug event.
> >>>
> >>> This patch disables CONFIG_ARCH_MEMORY_PROBE by default on x86, adds
> >>> its Kconfig menu entry on x86, and clarifies its use in Documentation/
> >>> memory-hotplug.txt.
> >>
> >> Could we please also fix it to never crash the kernel, even if stupid
> >> ranges are provided?
> >
> > Yes, this probe interface can be enhanced to verify the firmware
> > information before adding a given memory address.  However, such change
> > would interfere its test use of "fake" hotplug, which is only the known
> > use-case of this interface on x86.
> >
> > In order to verify if a given memory address is enabled at run-time (as
> > opposed to boot-time), we need to check with ACPI memory device objects
> > on x86.  However, system vendors tend to not implement memory device
> > objects unless their systems support memory hotplug.  Dave Hansen is
> > using this interface for his testing as a way to fake a hotplug event on
> > a system that does not support memory hotplug.
> 
> One of possible option is to return EINVAL when system has real hotplug device.
> I mean this interface is only useful when system don't have proper hardware
> feature and doesn't work correctly hardware property and this interface command
> are not consistent.

Thanks for the suggestion.  Unfortunately, such check cannot be added
without some ugliness.  There is no capability bit in ACPI that
indicates if the platform supports memory hotplug.  Let's assume we can
consider that if ACPI has no memory object, then it has no memory
hotplug support.  We still need to distinguish this case from a case
that ACPI has a memory device object but it is disabled (hence, it can
be added later).  However, the two cases are basically handled in the
same way that neither cases call the ACPI memory handlers in
drivers/acpi/acpi_memhotplug.c, where memory-specific code can be added.
Therefore, it will require adding memory device-specific code into the
ACPI scan code itself, which is supposed to be device type-neutral.  So,
it will be hard to sell without a very compelling reason...

I think a long term solution should be to remove this config option from
x86 Kconfig as you suggested before.  For now, we can disable it by
default and document as "test-use" only, which this patch did.
-Toshi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
