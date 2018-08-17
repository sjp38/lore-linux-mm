Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 8AEE36B0784
	for <linux-mm@kvack.org>; Fri, 17 Aug 2018 05:25:03 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id n17-v6so3378359pff.17
        for <linux-mm@kvack.org>; Fri, 17 Aug 2018 02:25:03 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s11-v6sor423031pgp.371.2018.08.17.02.25.01
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 17 Aug 2018 02:25:01 -0700 (PDT)
Date: Fri, 17 Aug 2018 12:24:55 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCHv5 19/19] x86: Introduce CONFIG_X86_INTEL_MKTME
Message-ID: <20180817092455.2ogsxsybfxdesrma@kshutemo-mobl1>
References: <20180717112029.42378-1-kirill.shutemov@linux.intel.com>
 <20180717112029.42378-20-kirill.shutemov@linux.intel.com>
 <20180815074812.GB28093@xo-6d-61-c0.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180815074812.GB28093@xo-6d-61-c0.localdomain>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Machek <pavel@ucw.cz>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Tom Lendacky <thomas.lendacky@amd.com>, Dave Hansen <dave.hansen@intel.com>, Kai Huang <kai.huang@linux.intel.com>, Jacob Pan <jacob.jun.pan@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, Aug 15, 2018 at 09:48:12AM +0200, Pavel Machek wrote:
> Hi!
> 
> > Add new config option to enabled/disable Multi-Key Total Memory
> > Encryption support.
> > 
> > MKTME uses MEMORY_PHYSICAL_PADDING to reserve enough space in per-KeyID
> > direct mappings for memory hotplug.
> > 
> > Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> > ---
> >  arch/x86/Kconfig | 19 ++++++++++++++++++-
> >  1 file changed, 18 insertions(+), 1 deletion(-)
> > 
> > diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
> > index b6f1785c2176..023a22568c06 100644
> > --- a/arch/x86/Kconfig
> > +++ b/arch/x86/Kconfig
> > @@ -1523,6 +1523,23 @@ config ARCH_USE_MEMREMAP_PROT
> >  	def_bool y
> >  	depends on AMD_MEM_ENCRYPT
> >  
> > +config X86_INTEL_MKTME
> > +	bool "Intel Multi-Key Total Memory Encryption"
> > +	select DYNAMIC_PHYSICAL_MASK
> > +	select PAGE_EXTENSION
> > +	depends on X86_64 && CPU_SUP_INTEL
> > +	---help---
> > +	  Say yes to enable support for Multi-Key Total Memory Encryption.
> > +	  This requires an Intel processor that has support of the feature.
> > +
> > +	  Multikey Total Memory Encryption (MKTME) is a technology that allows
> > +	  transparent memory encryption in upcoming Intel platforms.
> > +
> > +	  MKTME is built on top of TME. TME allows encryption of the entirety
> > +	  of system memory using a single key. MKTME allows having multiple
> > +	  encryption domains, each having own key -- different memory pages can
> > +	  be encrypted with different keys.
> > +
> >  # Common NUMA Features
> >  config NUMA
> >  	bool "Numa Memory Allocation and Scheduler Support"
> 
> Would it be good to provide documentation, or link to documentation, explaining
> what security guarantees this is supposed to provide, and what disadvantages (if any)
> it has?

The main goal is to add additional level of isolation between different
tenants of a machine. It mostly targeted to VMs and protect against
leaking information between guests.

In the design kernel (or hypervisor) is trusted and have a mean to access
encrypted memory as long as key is programmed into the CPU.

Worth noting that encryption happens in memory controller so all data in
caches of all levels are plain-text.

The spec can be found here:

https://software.intel.com/sites/default/files/managed/a5/16/Multi-Key-Total-Memory-Encryption-Spec.pdf

> I guess  it costs a bit of performance...

The most overhead is paid on allocation and freeing of encrypted pages:
switching between keyids for a page requires cache flushing.

Access time to encrypted memory *shouldn't* be measurably slower.
Encryption overhead is hidden within other latencies in memory pipeline.

> I see that TME helps with cold boot attacks.

Right.

-- 
 Kirill A. Shutemov
