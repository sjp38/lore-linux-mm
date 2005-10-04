Message-ID: <434292D3.2040105@shadowen.org>
Date: Tue, 04 Oct 2005 15:33:55 +0100
From: Andy Whitcroft <apw@shadowen.org>
MIME-Version: 1.0
Subject: Re: sparsemem & sparsemem extreme question
References: <20051004065030.GA21741@osiris.boeblingen.de.ibm.com>
In-Reply-To: <20051004065030.GA21741@osiris.boeblingen.de.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Heiko Carstens <heiko.carstens@de.ibm.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Heiko Carstens wrote:

> I did an implementation of CONFIG_SPARSEMEM for s390, which indeed was quite
> easy. Just to find out that it was not sufficient :)
> SPARSEMEM_EXTREME looks better but unfortunately adds another layer of
> indirection.
> I'm just wondering why there is all this indirection stuff here and why not
> have one contiguous aray of struct pages (residing in the vmalloc area) that
> deals with whatever size of memory an architecture wants to support.
> Unused areas just wouldn't have any backing with real pages and on access
> generate a page fault (nobody is supposed to access these pages anyway).
> This would have the advantage that all the primitives like e.g. pfn_to_page
> would be as simple as before, no need to waste large parts of the page flags
> and in addition it would easily allow for memory hotplug on page size
> granularity.
> The only drawbacks are (as far as I can see) a _huge_ virtual mem_map array,
> but that shouldn't matter too much. A real problem could be that the mem_map
> array and therefore the vmalloc area need to be generated quiete early.
> 
> Most probably this has already been thought about before, but I couldn't find
> anything in the achives.

During the implementation of SPARSEMEM_EXTREME other layouts such as the
huge 'partially populated' mem_map were considered.  For a number of our
target architectures kernel virtual address is at a premium so this
would not be suitable for them.  We did consider whether to have
different mechanisms for KVA rich architectures but (if I remember
correctly) benchmarking the implementation seemed to indicate that the
additional indirection was insignificant if even detectable.

The architecture of sparsemem is supposed to allow architecture specific
implementations should that be necessary but I've not yet seen a
compelling arguement for one yet.

On the subject of page flags, I would point out that SPARSEMEM either
reuses already used bits for 32 bit architectures, or makes use of
unused bits in the 64 case.  It doesn't reduce the number of flags bits
available.

-apw

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
