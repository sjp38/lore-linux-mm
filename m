Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx161.postini.com [74.125.245.161])
	by kanga.kvack.org (Postfix) with SMTP id C42476B0032
	for <linux-mm@kvack.org>; Tue, 23 Jul 2013 04:01:06 -0400 (EDT)
Received: by mail-ee0-f48.google.com with SMTP id b47so4286202eek.35
        for <linux-mm@kvack.org>; Tue, 23 Jul 2013 01:01:05 -0700 (PDT)
Date: Tue, 23 Jul 2013 10:01:01 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH v2] mm/hotplug, x86: Disable ARCH_MEMORY_PROBE by default
Message-ID: <20130723080101.GB15255@gmail.com>
References: <1374256068-26016-1-git-send-email-toshi.kani@hp.com>
 <20130722083721.GC25976@gmail.com>
 <1374513120.16322.21.camel@misato.fc.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1374513120.16322.21.camel@misato.fc.hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toshi Kani <toshi.kani@hp.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, x86@kernel.org, dave@sr71.net, kosaki.motohiro@gmail.com, isimatu.yasuaki@jp.fujitsu.com, tangchen@cn.fujitsu.com, vasilis.liaskovitis@profitbricks.com


* Toshi Kani <toshi.kani@hp.com> wrote:

> > Could we please also fix it to never crash the kernel, even if stupid 
> > ranges are provided?
> 
> Yes, this probe interface can be enhanced to verify the firmware 
> information before adding a given memory address.  However, such change 
> would interfere its test use of "fake" hotplug, which is only the known 
> use-case of this interface on x86.

Not crashing the kernel is not a novel concept even for test interfaces...

Where does the possible crash come from - from using invalid RAM ranges, 
right? I.e. on x86 to fix the crash we need to check the RAM is present in 
the e820 maps, is marked RAM there, and is not already registered with the 
kernel, or so?

> In order to verify if a given memory address is enabled at run-time (as 
> opposed to boot-time), we need to check with ACPI memory device objects 
> on x86.  However, system vendors tend to not implement memory device 
> objects unless their systems support memory hotplug.  Dave Hansen is 
> using this interface for his testing as a way to fake a hotplug event on 
> a system that does not support memory hotplug.

All vendors implement e820 maps for the memory present at boot time.

How is the testing done by Dave Hansen? If it's done by booting with less 
RAM than available (via say the mem=1g boot parameter), and then 
hot-adding some of the missing RAM, then this could be made safe via the 
e820 maps and by consultig the physical memory maps (to avoid double 
registry), right?

How does the hotplug event based approach solve double adds? Relies on the 
hardware not sending a hot-add event twice for the same memory area or for 
an invalid memory area, or does it include fail-safes and double checks as 
well to avoid double adds and adding invalid memory? If yes then that 
could be utilized here as well.

I.e. fragility of an interface is our choice, not some natural given 
property.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
