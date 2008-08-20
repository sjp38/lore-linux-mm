Message-ID: <48AC231B.3090801@linux-foundation.org>
Date: Wed, 20 Aug 2008 08:58:51 -0500
From: Christoph Lameter <cl@linux-foundation.org>
MIME-Version: 1.0
Subject: Re: sparsemem support for mips with highmem
References: <48A4AC39.7020707@sciatl.com>	<1218753308.23641.56.camel@nimitz>	<48A4C542.5000308@sciatl.com>	<20080815080331.GA6689@alpha.franken.de>	<1218815299.23641.80.camel@nimitz>	<48A5AADE.1050808@sciatl.com>	<20080815163302.GA9846@alpha.franken.de>	<48A5B9F1.3080201@sciatl.com>	<1218821875.23641.103.camel@nimitz>	<48A5C831.3070002@sciatl.com> <20080818094412.09086445.rdunlap@xenotime.net> <48A9E89C.4020408@linux-foundation.org> <48A9F047.7050906@cisco.com> <48AAC54D.8020609@linux-foundation.org> <48AB5959.6090609@cisco.com>
In-Reply-To: <48AB5959.6090609@cisco.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David VomLehn <dvomlehn@cisco.com>
Cc: Randy Dunlap <rdunlap@xenotime.net>, C Michael Sundius <Michael.sundius@sciatl.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Thomas Bogendoerfer <tsbogend@alpha.franken.de>, linux-mm@kvack.org, linux-mips@linux-mips.org, jfraser@broadcom.com, Andy Whitcroft <apw@shadowen.org>
List-ID: <linux-mm.kvack.org>

David VomLehn wrote:

>> The virtually mapped memmap results in smaller code and is typically more
>> effective since the processor caches the TLB entries.
> 
> I'm pretty ignorant on this subject, but I think this is worth
> discussing. On a MIPS processor, access to low memory bypasses the TLB
> entirely. I think what you are suggesting is to use mapped addresses to
> make all of low memory virtually contiguous. On a MIPS processor, we

No the virtual area is only used to map the memory map (the array of page
structs). That is just a small fraction of memory.


> could do this by allocating a "wired" TLB entry for each physically
> contiguous block of memory. Wired TLB entries are never replaced, so
> they are very efficient for long-lived mappings such as this. Using the
> TLB in this way does increase TLB pressure, but most platforms probably
> have a very small number of "holes" in their memory. So, this may be a
> small overhead.

That would consume precious resources.

Just place the memmap into the vmalloc area gets you there. TLB entries should
be loaded on demand.


> If I'm understand what you are suggesting correctly (a big if), the
> downside is that we'd pay the cost of a TLB match for each non-cached
> low memory data access. It seems to me that would be a higher cost than
> having the occasional, more expensive, sparsemem lookup in pfn_to_page.

The cost going through a TLB mapping is only incurred for accesses to the
memmap array. Not for general memory accesses.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
