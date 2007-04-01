From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCH 1/4] x86_64: Switch to SPARSE_VIRTUAL
Date: Sun, 1 Apr 2007 12:46:51 +0200
References: <20070401071024.23757.4113.sendpatchset@schroedinger.engr.sgi.com> <20070401071029.23757.78021.sendpatchset@schroedinger.engr.sgi.com>
In-Reply-To: <20070401071029.23757.78021.sendpatchset@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200704011246.52238.ak@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, Martin Bligh <mbligh@google.com>, linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Sunday 01 April 2007 09:10, Christoph Lameter wrote:
> x86_64 make SPARSE_VIRTUAL the default
> 
> x86_64 is using 2M page table entries to map its 1-1 kernel space.
> We implement the virtual memmap also using 2M page table entries.
> So there is no difference at all to FLATMEM. Both schemes require
> a page table and a TLB.

Hmm, this means there is at least 2MB worth of struct page on every node?
Or do you have overlaps with other memory (I think you have)
In that case you have to handle the overlap in change_page_attr()

Also your "generic" vmemmap code doesn't look very generic, but
rather x86 specific. I didn't think huge pages could be easily
set up this way in many other architectures.  

And when you reserve virtual space somewhere you should 
update Documentation/x86_64/mm.txt. Also you didn't adjust 
the end of the vmalloc area so in theory vmalloc could run
into your vmemmap.

> Thus the SPARSEMEM becomes the most efficient way of handling
> virt_to_page, pfn_to_page and friends for UP, SMP and NUMA.

Do you have any benchmarks numbers to prove it? There seem to be a few
benchmarks where the discontig virt_to_page is a problem
(although I know ways to make it more efficient), and sparsemem
is normally slower. Still some numbers would be good.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
