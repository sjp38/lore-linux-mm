Date: Mon, 12 Nov 2007 16:42:37 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: x86_64: Make sparsemem/vmemmap the default memory model
In-Reply-To: <200711130059.34346.ak@suse.de>
Message-ID: <Pine.LNX.4.64.0711121615120.29328@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0711121549370.29178@schroedinger.engr.sgi.com>
 <200711130059.34346.ak@suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Mel Gorman <mel@csn.ul.ie>, Andy Whitcroft <apw@shadowen.org>
List-ID: <linux-mm.kvack.org>

On Tue, 13 Nov 2007, Andi Kleen wrote:

> On Tuesday 13 November 2007 00:52:14 Christoph Lameter wrote:
> > Use sparsemem as the only memory model for UP, SMP and NUMA.
> > 
> > Measurements indicate that DISCONTIGMEM has a higher
> > overhead than sparsemem. And FLATMEMs benefits are minimal. So I think its
> > best to simply standardize on sparsemem.
> 
> How about the memory overhead? Is it the same too?
> And code size vs flatmem?

SMP Sparsemem
-------------

Kernel size:

   text    data     bss     dec     hex filename
3849268  397739 1264856 5511863  541ab7 vmlinux

             total       used       free     shared    buffers     cached
Mem:       8242252      41164    8201088          0        352      11512
-/+ buffers/cache:      29300    8212952
Swap:      9775512          0    9775512

SMP Flatmem
-----------

Kernel size:

   text    data     bss     dec     hex filename
3844612  397739 1264536 5506887  540747 vmlinux

So 4.5k growth in text size vs. FLATMEM.

             total       used       free     shared    buffers     cached
Mem:       8244052      40544    8203508          0        352      11484
-/+ buffers/cache:      28708    8215344

2k growth in overall memory use after boot.



NUMA discontig:

   text    data     bss     dec     hex filename
3888124  470659 1276504 5635287  55fcd7 vmlinux

             total       used       free     shared    buffers     cached
Mem:       8256256      56908    8199348          0        352      11496
-/+ buffers/cache:      45060    8211196
Swap:      9775512          0    9775512

NUMA sparse:

   text    data     bss     dec     hex filename
3896428  470659 1276824 5643911  561e87 vmlinux


8k text growth. Given that we fully inline virt_to_page and friends now 
that is rather good.

             total       used       free     shared    buffers     cached
Mem:       8264720      57240    8207480          0        352      11516
-/+ buffers/cache:      45372    8219348
Swap:      9775512          0    9775512

Hmmm... More memory free? How did that happen? More pages cached for some 
reason. The total available memory is increased by 8k.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
