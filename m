Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx165.postini.com [74.125.245.165])
	by kanga.kvack.org (Postfix) with SMTP id 4DAAF6B0033
	for <linux-mm@kvack.org>; Wed, 24 Jul 2013 00:20:46 -0400 (EDT)
Received: by mail-ee0-f41.google.com with SMTP id d51so735460eek.14
        for <linux-mm@kvack.org>; Tue, 23 Jul 2013 21:20:44 -0700 (PDT)
Date: Wed, 24 Jul 2013 06:20:41 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH v2] mm/hotplug, x86: Disable ARCH_MEMORY_PROBE by default
Message-ID: <20130724042041.GA8504@gmail.com>
References: <1374256068-26016-1-git-send-email-toshi.kani@hp.com>
 <20130722083721.GC25976@gmail.com>
 <1374513120.16322.21.camel@misato.fc.hp.com>
 <20130723080101.GB15255@gmail.com>
 <1374612301.16322.136.camel@misato.fc.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1374612301.16322.136.camel@misato.fc.hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toshi Kani <toshi.kani@hp.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, x86@kernel.org, dave@sr71.net, kosaki.motohiro@gmail.com, isimatu.yasuaki@jp.fujitsu.com, tangchen@cn.fujitsu.com, vasilis.liaskovitis@profitbricks.com


* Toshi Kani <toshi.kani@hp.com> wrote:

> On Tue, 2013-07-23 at 10:01 +0200, Ingo Molnar wrote:
> > * Toshi Kani <toshi.kani@hp.com> wrote:
> > 
> > > > Could we please also fix it to never crash the kernel, even if stupid 
> > > > ranges are provided?
> > > 
> > > Yes, this probe interface can be enhanced to verify the firmware 
> > > information before adding a given memory address.  However, such change 
> > > would interfere its test use of "fake" hotplug, which is only the known 
> > > use-case of this interface on x86.
> > 
> > Not crashing the kernel is not a novel concept even for test interfaces...
> 
> Agreed.
> 
> > Where does the possible crash come from - from using invalid RAM ranges, 
> > right? I.e. on x86 to fix the crash we need to check the RAM is present in 
> > the e820 maps, is marked RAM there, and is not already registered with the 
> > kernel, or so?
> 
> Yes, the crash comes from using invalid RAM ranges.  How to check if the
> RAM is present is different if the system supports hotplug or not.
> 
> > > In order to verify if a given memory address is enabled at run-time (as 
> > > opposed to boot-time), we need to check with ACPI memory device objects 
> > > on x86.  However, system vendors tend to not implement memory device 
> > > objects unless their systems support memory hotplug.  Dave Hansen is 
> > > using this interface for his testing as a way to fake a hotplug event on 
> > > a system that does not support memory hotplug.
> > 
> > All vendors implement e820 maps for the memory present at boot time.
> 
> Yes for boot time.  At run-time, e820 is not guaranteed to represent a
> new memory added. [...]

Yes I know that, the e820 map is boot only.

You claimed that the only purpose of this on x86 was that testing was done 
on non-hotplug systems, using this interface. Non-hotplug systems have 
e820 maps.

> > How does the hotplug event based approach solve double adds? Relies on 
> > the hardware not sending a hot-add event twice for the same memory 
> > area or for an invalid memory area, or does it include fail-safes and 
> > double checks as well to avoid double adds and adding invalid memory? 
> > If yes then that could be utilized here as well.
> 
> In high-level, here is how ACPI memory hotplug works:
> 
> 1. ACPI sends a hotplug event to a new ACPI memory device object that is
> hot-added.
> 2. The kernel is notified, and verifies if the new memory device object
> has not been attached by any handler yet.
> 3. The memory handler is called, and obtains a new memory range from the
> ACPI memory device object. 
> 4. The memory handler calls add_memory() with the new address range.
> 
> The above step 1-4 proceeds automatically within the kernel.  No user 
> input (nor sysfs interface) is necessary.  Step 2 prevents double adds 
> [...]

If this 'new memory device object' is some ACPI detail then I don't see 
how it protects the kernel from a buggy ACPI implementation double adding 
the same physical memory range.

> and step 3 gets a valid address range from the firmware directly.  Step 
> 4 is basically the same as the "probe" interface, but with all the 
> verification up front, this step is safe.

So what verification does the kernel do to ensure that a buggy ACPI 
implementation does not pass us a crappy memory range, such a double 
physical range (represented via separate 'memory device objects'), or a 
range overlapping with an existing physical memory range already known to 
the kernel, or a totally nonsensical range the CPU cannot even access 
physically, etc.?

Also, is there any verification done to make sure that the new memory 
range is actually RAM - i.e. we could write the first and last word of it 
and see whether it gets modified correctly [to keep the sanity check 
fast]?

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
