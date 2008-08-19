Subject: Re: sparsemem support for mips with highmem
From: "Jon Fraser" <jfraser@broadcom.com>
Reply-to: jfraser@broadcom.com
In-Reply-To: <48AB5959.6090609@cisco.com>
References: <48A4AC39.7020707@sciatl.com>
 <1218753308.23641.56.camel@nimitz> <48A4C542.5000308@sciatl.com>
 <20080815080331.GA6689@alpha.franken.de>
 <1218815299.23641.80.camel@nimitz> <48A5AADE.1050808@sciatl.com>
 <20080815163302.GA9846@alpha.franken.de> <48A5B9F1.3080201@sciatl.com>
 <1218821875.23641.103.camel@nimitz> <48A5C831.3070002@sciatl.com>
 <20080818094412.09086445.rdunlap@xenotime.net>
 <48A9E89C.4020408@linux-foundation.org> <48A9F047.7050906@cisco.com>
 <48AAC54D.8020609@linux-foundation.org> <48AB5959.6090609@cisco.com>
Date: Tue, 19 Aug 2008 19:53:52 -0400
Message-ID: <1219190032.3384.45.camel@chaos.ne.broadcom.com>
MIME-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David VomLehn <dvomlehn@cisco.com>
Cc: Christoph Lameter <cl@linux-foundation.org>, Randy Dunlap <rdunlap@xenotime.net>, C Michael Sundius <Michael.sundius@sciatl.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Thomas Bogendoerfer <tsbogend@alpha.franken.de>, linux-mm@kvack.org, linux-mips@linux-mips.org, Andy Whitcroft <apw@shadowen.org>
List-ID: <linux-mm.kvack.org>

David,

One of the reasons that we've gone to the HIGHMEM solution
is to conserve address space.  We were mapping up to 512Mb of dram space
into the kernel via wired TLB entries.  We have 256MB of dram and
256mb of IO space in kseg0.  This left only 512 mb to map pci space,
vmalloc'd memory, etc.  This wasn't enough, and we couldn't handle
systems with 1gb of memory.  And it was wiring a lot of tlb entries,
which means more tlb faults.

Our processors only had 32 tlb entries, although we've
recently increased that to 64.

We do have to setup a wired tlb entry for the base of the high mem so
that we have access to the page array at the beginning of the high mem
region.  There might be another way to do it, but it's only 1 tlb entry.

Jon,  who is still chasing cache alias issues on a 24k.



On Tue, 2008-08-19 at 16:38 -0700, David VomLehn wrote:
> Christoph Lameter wrote:
> > David VomLehn wrote:
> > 
> >> On MIPS processors, the kernel runs in unmapped memory, i.e. the TLB
> >> isn't even
> >> used, so I don't think you can use that trick. So, this comment doesn't
> >> apply to
> >> all processors.
> > 
> > In that case you have a choice between the overhead of sparsemem lookups in
> > every pfn_to_page or using TLB entries to create a virtually mapped memmap
> > which may create TLB pressure.
> > 
> > The virtually mapped memmap results in smaller code and is typically more
> > effective since the processor caches the TLB entries.
> 
> I'm pretty ignorant on this subject, but I think this is worth discussing. On a 
> MIPS processor, access to low memory bypasses the TLB entirely. I think what you 
> are suggesting is to use mapped addresses to make all of low memory virtually 
> contiguous. On a MIPS processor, we could do this by allocating a "wired" TLB 
> entry for each physically contiguous block of memory. Wired TLB entries are never 
> replaced, so they are very efficient for long-lived mappings such as this. Using 
> the TLB in this way does increase TLB pressure, but most platforms probably have 
> a very small number of "holes" in their memory. So, this may be a small overhead.
> 
> If we took this approach, we could then have a single, simple memmap array where 
> pfn_to_page looks just about the same as it looks with a flat memory model.
> 
> If I'm understand what you are suggesting correctly (a big if), the downside is 
> that we'd pay the cost of a TLB match for each non-cached low memory data access. 
> It seems to me that would be a higher cost than having the occasional, more 
> expensive, sparsemem lookup in pfn_to_page.
> 
> Anyone with more in-depth MIPS processor architecture knowledge care to weigh in 
> on this?
> --
> David VomLehn
> 
> 
> 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
