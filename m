Date: Mon, 3 Mar 2008 12:04:37 -0800 (PST)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [patch 4/6] xip: support non-struct page backed memory
In-Reply-To: <6934efce0803031138g725f0ec4ra683d56615b7dbe0@mail.gmail.com>
Message-ID: <alpine.LFD.1.00.0803031152240.17889@woody.linux-foundation.org>
References: <20080118045649.334391000@suse.de>  <20080118045755.735923000@suse.de>  <6934efce0803010014p2cc9a5edu5fee2029c0104a07@mail.gmail.com>  <47CBB44D.7040203@de.ibm.com>  <alpine.LFD.1.00.0803031037560.17889@woody.linux-foundation.org>
 <6934efce0803031138g725f0ec4ra683d56615b7dbe0@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jared Hulbert <jaredeh@gmail.com>
Cc: carsteno@de.ibm.com, npiggin@suse.de, Andrew Morton <akpm@linux-foundation.org>, mschwid2@linux.vnet.ibm.com, heicars2@linux.vnet.ibm.com, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>


On Mon, 3 Mar 2008, Jared Hulbert wrote:
> 
> By 1:1 you mean virtual + offset == physical + offset right?

Right. It's a special case, and it's an important special case because 
it's the only one that is fast to do.

It's not very common, but it's common enough that it's worth doing.

That said, xip should probably never have used virt_to_phys() in the first 
place. It should be limited to purely architecture-specific memory 
management routines.

[ There's a number of drivers that need "physical" addresses for DMA, and 
  that use virt_to_phys, but they should use the DMA interfaces 
  that do this right, and even for legacy things that don't use the proper 
  DMA allocator things virt_to_phys is wrong, because it's about _bus_ 
  addresses, not CPU physical addresses. Only architecture code can know 
  when the two actually mean the same thing ]

Quite frankly, I think it's totally wrong to use kernel-virtual addresses 
in those interfaces in first place. Either you use "struct page *" or you 
use a pfn number. Nothing else is simply valid.

			Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
