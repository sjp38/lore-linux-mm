Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx106.postini.com [74.125.245.106])
	by kanga.kvack.org (Postfix) with SMTP id AB2C26B0031
	for <linux-mm@kvack.org>; Wed, 24 Jul 2013 12:59:37 -0400 (EDT)
Message-ID: <1374685121.16322.218.camel@misato.fc.hp.com>
Subject: Re: [PATCH v2] mm/hotplug, x86: Disable ARCH_MEMORY_PROBE by default
From: Toshi Kani <toshi.kani@hp.com>
Date: Wed, 24 Jul 2013 10:58:41 -0600
In-Reply-To: <20130724042041.GA8504@gmail.com>
References: <1374256068-26016-1-git-send-email-toshi.kani@hp.com>
	 <20130722083721.GC25976@gmail.com>
	 <1374513120.16322.21.camel@misato.fc.hp.com>
	 <20130723080101.GB15255@gmail.com>
	 <1374612301.16322.136.camel@misato.fc.hp.com>
	 <20130724042041.GA8504@gmail.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, x86@kernel.org, dave@sr71.net, kosaki.motohiro@gmail.com, isimatu.yasuaki@jp.fujitsu.com, tangchen@cn.fujitsu.com, vasilis.liaskovitis@profitbricks.com

On Wed, 2013-07-24 at 06:20 +0200, Ingo Molnar wrote:
> * Toshi Kani <toshi.kani@hp.com> wrote:
> 
> > On Tue, 2013-07-23 at 10:01 +0200, Ingo Molnar wrote:
> > > * Toshi Kani <toshi.kani@hp.com> wrote:
> > > 
> > > > > Could we please also fix it to never crash the kernel, even if stupid 
> > > > > ranges are provided?
> > > > 
> > > > Yes, this probe interface can be enhanced to verify the firmware 
> > > > information before adding a given memory address.  However, such change 
> > > > would interfere its test use of "fake" hotplug, which is only the known 
> > > > use-case of this interface on x86.
> > > 
> > > Not crashing the kernel is not a novel concept even for test interfaces...
> > 
> > Agreed.
> > 
> > > Where does the possible crash come from - from using invalid RAM ranges, 
> > > right? I.e. on x86 to fix the crash we need to check the RAM is present in 
> > > the e820 maps, is marked RAM there, and is not already registered with the 
> > > kernel, or so?
> > 
> > Yes, the crash comes from using invalid RAM ranges.  How to check if the
> > RAM is present is different if the system supports hotplug or not.
> > 
> > > > In order to verify if a given memory address is enabled at run-time (as 
> > > > opposed to boot-time), we need to check with ACPI memory device objects 
> > > > on x86.  However, system vendors tend to not implement memory device 
> > > > objects unless their systems support memory hotplug.  Dave Hansen is 
> > > > using this interface for his testing as a way to fake a hotplug event on 
> > > > a system that does not support memory hotplug.
> > > 
> > > All vendors implement e820 maps for the memory present at boot time.
> > 
> > Yes for boot time.  At run-time, e820 is not guaranteed to represent a
> > new memory added. [...]
> 
> Yes I know that, the e820 map is boot only.
> 
> You claimed that the only purpose of this on x86 was that testing was done 
> on non-hotplug systems, using this interface. Non-hotplug systems have 
> e820 maps.

Right.  Sorry, I first thought that the interface needed to work as
defined, i.e. detect a new memory.  But for the test purpose on
non-hotplug systems, that is not necessary.  So, I agree that we can
check e820.

I summarized two options in the email below.
https://lkml.org/lkml/2013/7/23/602

Option 1) adds a check with e820.  Option 2) deprecates the interface by
removing the config option from x86 Kconfig.  I was thinking that we
could evaluate two options after this patch gets in.  Does it make
sense?   

> > > How does the hotplug event based approach solve double adds? Relies on 
> > > the hardware not sending a hot-add event twice for the same memory 
> > > area or for an invalid memory area, or does it include fail-safes and 
> > > double checks as well to avoid double adds and adding invalid memory? 
> > > If yes then that could be utilized here as well.
> > 
> > In high-level, here is how ACPI memory hotplug works:
> > 
> > 1. ACPI sends a hotplug event to a new ACPI memory device object that is
> > hot-added.
> > 2. The kernel is notified, and verifies if the new memory device object
> > has not been attached by any handler yet.
> > 3. The memory handler is called, and obtains a new memory range from the
> > ACPI memory device object. 
> > 4. The memory handler calls add_memory() with the new address range.
> > 
> > The above step 1-4 proceeds automatically within the kernel.  No user 
> > input (nor sysfs interface) is necessary.  Step 2 prevents double adds 
> > [...]
> 
> If this 'new memory device object' is some ACPI detail then I don't see 
> how it protects the kernel from a buggy ACPI implementation double adding 
> the same physical memory range.

You are right that the kernel is not fully protected from buggy ACPI.
In case of double adding, though, such hot-add operation fails
gracefully since add_memory() returns with -EEXIST.  But if buggy ACPI
returns an invalid RAM range, then it can crash the system, just like an
invalid address in e820 can crash the system as well.

> > and step 3 gets a valid address range from the firmware directly.  Step 
> > 4 is basically the same as the "probe" interface, but with all the 
> > verification up front, this step is safe.
> 
> So what verification does the kernel do to ensure that a buggy ACPI 
> implementation does not pass us a crappy memory range, such a double 
> physical range (represented via separate 'memory device objects'), or a 
> range overlapping with an existing physical memory range already known to 
> the kernel, or a totally nonsensical range the CPU cannot even access 
> physically, etc.?

The kernel checks if the status of an ACPI memory device object is
marked as enabled.  But it does not protect from buggy ACPI because
anything can be wrong... 

Overlapping and double add cases are verified in add_memory(), i.e.
register_memory_resource() fails.

If an address range is unique & wrong, we have no protection from it.

> Also, is there any verification done to make sure that the new memory 
> range is actually RAM - i.e. we could write the first and last word of it 
> and see whether it gets modified correctly [to keep the sanity check 
> fast]?

No such check is performed -- just like we don't at boot-time.

This may sound bad, but in my experience, such obvious bugs are quickly
found and fixed during the FW development phase.


Thanks,
-Toshi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
