Subject: Re: Merging Nonlinear and Numa style memory hotplug
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <20040624135838.F009.YGOTO@us.fujitsu.com>
References: <20040623184303.25D9.YGOTO@us.fujitsu.com>
	 <1088083724.3918.390.camel@nighthawk>
	 <20040624135838.F009.YGOTO@us.fujitsu.com>
Content-Type: text/plain
Message-Id: <1088116621.3918.1060.camel@nighthawk>
Mime-Version: 1.0
Date: Thu, 24 Jun 2004 15:37:02 -0700
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Yasunori Goto <ygoto@us.fujitsu.com>
Cc: Linux Kernel ML <linux-kernel@vger.kernel.org>, Linux Hotplug Memory Support <lhms-devel@lists.sourceforge.net>, Linux-Node-Hotplug <lhns-devel@lists.sourceforge.net>, linux-mm <linux-mm@kvack.org>, "BRADLEY CHRISTIANSEN [imap]" <bradc1@us.ibm.com>
List-ID: <linux-mm.kvack.org>

On Thu, 2004-06-24 at 15:19, Yasunori Goto wrote:
> BTW, I have a question about nonlinear patch.
> It is about difference between phys_section[] and mem_section[]
> I suppose that phys_section[] looks like no-meaning now.
> If it isn't necessary, __va() and __pa() translation can be more simple.
> What is the purpose of phys_section[]. Is it for ppc64?

This is the fun (read: confusing) part of nonlinear.

The mem_section[] array is where the pointer to the mem_map for the
section is stored, obviously.  It's indexed virtually, so that something
at a virtual address is in section number (address >> SECTION_SHIFT). 
So, that makes it easy to go from a virtual address to a 'struct page'
inside of the mem_map[].

But, given a physical address (or a pfn for that matter), you sometimes
also need to get to a 'struct page'.  It is for that reason that we have
the phys_section[] array.  Each entry in the phys_section[] points back
to a mem_section[], which then contains the mem_map[].

pfn_to_page(unsigned long pfn)
{
       return
&mem_section[phys_section[pfn_to_section(pfn)]].mem_map[section_offset_pfn(pfn)];
}

pfn_to_section(pfn) does a (pfn >> (SECTION_SHIFT - PAGE_SHIFT)), then
uses that section number to index into the phys_section[] array, which
gives an index into the mem_section[] array, from which you can get the
'struct page'.  


-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
