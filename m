Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f41.google.com (mail-oi0-f41.google.com [209.85.218.41])
	by kanga.kvack.org (Postfix) with ESMTP id 7C39E6B0253
	for <linux-mm@kvack.org>; Thu,  3 Dec 2015 12:59:20 -0500 (EST)
Received: by oixx65 with SMTP id x65so54361267oix.0
        for <linux-mm@kvack.org>; Thu, 03 Dec 2015 09:59:20 -0800 (PST)
Received: from g9t5008.houston.hp.com (g9t5008.houston.hp.com. [15.240.92.66])
        by mx.google.com with ESMTPS id q8si8900687obe.17.2015.12.03.09.59.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 Dec 2015 09:59:19 -0800 (PST)
Message-ID: <1449168859.9855.54.camel@hpe.com>
Subject: Re: [PATCH v3 1/3] resource: Add @flags to region_intersects()
From: Toshi Kani <toshi.kani@hpe.com>
Date: Thu, 03 Dec 2015 11:54:19 -0700
In-Reply-To: <CA+55aFw22JD8W2cy3w=5VcU9-ENXSP9utmhGB2NeiDVqwpnUSw@mail.gmail.com>
References: <1448404418-28800-1-git-send-email-toshi.kani@hpe.com>
	 <1448404418-28800-2-git-send-email-toshi.kani@hpe.com>
	 <20151201135000.GB4341@pd.tnic>
	 <CAPcyv4g2n9yTWye2aVvKMP0X7mrm_NLKmGd5WBO2SesTj77gbg@mail.gmail.com>
	 <20151201171322.GD4341@pd.tnic>
	 <CA+55aFw22JD8W2cy3w=5VcU9-ENXSP9utmhGB2NeiDVqwpnUSw@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Borislav Petkov <bp@alien8.de>
Cc: Dan Williams <dan.j.williams@intel.com>, Andrew Morton <akpm@linux-foundation.org>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Tony Luck <tony.luck@intel.com>, Vishal L Verma <vishal.l.verma@intel.com>, Linux MM <linux-mm@kvack.org>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, Linux ACPI <linux-acpi@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Tue, 2015-12-01 at 09:19 -0800, Linus Torvalds wrote:
> On Tue, Dec 1, 2015 at 9:13 AM, Borislav Petkov <bp@alien8.de> wrote:
> > 
> > Oh sure, I didn't mean you. I was simply questioning that whole
> > identify-resource-by-its-name approach. And that came with:
> > 
> > 67cf13ceed89 ("x86: optimize resource lookups for ioremap")
> > 
> > I just think it is silly and that we should be identifying resource
> > things in a more robust way.
> 
> I could easily imagine just adding a IORESOURCE_RAM flag (or SYSMEM or
> whatever). That sounds sane. I agree that comparing the string is
> ugly.
> 
> > Btw, the ->name thing in struct resource has been there since a *long*
> > time
> 
> It's pretty much always been there.  It is indeed meant for things
> like /proc/iomem etc, and as a debug aid when printing conflicts,
> yadda yadda. Just showing the numbers is usually useless for figuring
> out exactly *what* something conflicts with.

I agree that regular memory should have its own type, which separates
itself from MMIO.  By looking at how IORESOURCE types are used, this change
has the following challenges, and I am sure I missed some more.

1. Large number of IORESOURCE_MEM usage
Adding a new type for regular memory will require inspecting the codes
using IORESOURCE_MEM currently, and modify them to use the new type if
their target ranges are regular memory.  There are many references to this
type across multiple architectures and drivers, which make this inspection
and testing challenging.

http://lxr.free-electrons.com/ident?i=IORESOURCE_MEM

2. Lack of free flags bit in resource
The flags bits are defined in include/linux/ioport.h.  The flags are
defined as unsigned long, which is 32-bit in 32-bit config.  The most of
the bits have been assigned already.  Bus-specific bits for IORESOURCE_MEM
have been assigned mostly as well (line 82).

3. Interaction with pnp subsystem
The same IORESOURCE types and bus-specific flags are used by the pnp
subsystem.  pnp_mem objects represent IORESOURCE_MEM type listed by
pnp_dev.  Adding a new IORESOURCE type likely requires adding a new object
type and its interfaces to pnp.

4. I/O resource names represent allocation types
While IORESOURCE types represent hardware types and capabilities, the
string names represent resource allocation types and usages.  For instance,
regular memory is allocated for the OS as "System RAM", kdump as "Crash
kernel", FW as "ACPI Tables", and so on.  Hence, a new type representing
"System RAM" needs to be usage based, which is different from the current
IORESOURCE types.

I think this work will require a separate patch series at least.  For this
patch series, supporting error injections to NVDIMM, I propose that we make
the change suggested by Dan:

"We could define 'const char *system_ram = "System RAM"' somewhere andthen
do pointer comparisons to cut down on the thrash of adding newflags to
'struct resource'?"

Let me know if you have any suggestions/concerns. 

Thanks,
-Toshi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
