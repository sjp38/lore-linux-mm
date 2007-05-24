Subject: Re: [patch 3/8] mm: merge nopfn into fault
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
In-Reply-To: <alpine.LFD.0.98.0705231857090.3890@woody.linux-foundation.org>
References: <200705180737.l4I7b6cg010758@shell0.pdx.osdl.net>
	 <alpine.LFD.0.98.0705180817550.3890@woody.linux-foundation.org>
	 <1179963619.32247.991.camel@localhost.localdomain>
	 <20070524014223.GA22998@wotan.suse.de>
	 <alpine.LFD.0.98.0705231857090.3890@woody.linux-foundation.org>
Content-Type: text/plain
Date: Thu, 24 May 2007 13:17:39 +1000
Message-Id: <1179976659.32247.1026.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Nick Piggin <npiggin@suse.de>, akpm@linux-foundation.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 2007-05-23 at 19:04 -0700, Linus Torvalds wrote:
> 
> If you want to install the PFN in the low-level driver, just
> 
>  - pass the whole "struct vm_fault" to the PFN-installing thing (so that 
>    the driver at least doesn't have to muck with the address)

Fair but in the case of spufs, I -do- have to much with the address in
the driver/fs since it's the driver that knows it wants to use 64K page
mappings, and thus need to insert the PTE with the special 64K flag in
the first of the 16 entries of that 64K region -and- align the address
down before passing it to vm_insert_pfn().

There no knowledge of that arch magic in the generic vm_insert_pfn() and
I don't think there should be. It's all understanding between the arch
specific spufs driver and the arch low level page table management.

I know I'm sort of a special case here though, but I think it might make
sense to have in the future the DRM do similar special things to use
larger HW page sizes to map things like framebuffers or large in-VRAM or
in-AGP objects, possibly using an arch helper that does that appropriate
address & pgprot flag munging, but in the end, the actual PTE insertion
is still the generic one and that should work just fine.

Anyway, I don't see any big hurry to change ->nopfn() and it's
associated NOPFN_REFAULT special return code and vm_insert_pfn() helper
from what they are right now. They work for the few special case that
need them just fine and can be kept separate from whatever other work
Nick is doing.

Cheers,
Ben.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
