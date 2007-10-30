Subject: Re: vm_ops.page_mkwrite() fails with vmalloc on 2.6.23
From: Stefani Seibold <stefani@seibold.net>
Reply-To: stefani@seibold.net
In-Reply-To: <1193738177.27652.69.camel@twins>
References: <1193064057.16541.1.camel@matrix>
	 <20071029004002.60c7182a.akpm@linux-foundation.org>
	 <45a44e480710290117u492dbe82ra6344baf8bb1e370@mail.gmail.com>
	 <1193677302.27652.56.camel@twins>
	 <45a44e480710291051s7ffbb582x64ea9524c197b48a@mail.gmail.com>
	 <1193681839.27652.60.camel@twins> <1193696211.5644.100.camel@lappy>
	 <45a44e480710291822w5864b3beofcf432930d3e68d3@mail.gmail.com>
	 <1193738177.27652.69.camel@twins>
Content-Type: text/plain
Date: Tue, 30 Oct 2007 11:49:16 +0100
Message-Id: <1193741356.13775.2.camel@matrix>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Jaya Kumar <jayakumar.lkml@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, David Howells <dhowells@redhat.com>, linux-mm@kvack.org, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

Hi,

the question is how can i get all pte's from a vmalloc'ed memory. Due to
the zeroed mapping pointer i dont see how to do this?


Am Dienstag, den 30.10.2007, 10:56 +0100 schrieb Peter Zijlstra:
> On Mon, 2007-10-29 at 21:22 -0400, Jaya Kumar wrote:
> > On 10/29/07, Peter Zijlstra <a.p.zijlstra@chello.nl> wrote:
> > >
> > > [ also, remap_vmalloc_range() suffers similar issues, only file and anon
> > >   have proper rmap ]
> > >
> > > I'm not sure we want full rmap for remap_pfn/vmalloc_range, but perhaps
> > > we could assist drivers in maintaining and using vma lists.
> > >
> > > I think page_mkclean_one() would work if you'd manually set page->index
> > > and iterate the vmas yourself. Although atm I'm not sure of anything so
> > > don't pin me on it.
> > 
> > :-) If it's anybody's fault, it's mine for not testing properly. My bad.
> > 
> > In the case of defio, I think it's no trouble to build a list of vmas
> > at mmap time and then to iterate through them when it's ready for
> > mkclean time as you suggested. I don't fully understand page->index
> > yet. I had thought it was only used by swap cache or file map.
> > 
> > On an unrelated note, I was looking for somewhere to stuff a 16 bit
> > offset (so that I have a cheap way to know which struct page
> > corresponds to which framebuffer block or offset) for another driver.
> > I had thought page->index was it but I think I am wrong now.
> Yeah, page->index is used along with vma->vmpgoff and vma->vm_start to
> determine the address of the page in the given vma:
> 
>   address = vma->vm_start + ((page->index - vma->vm_pgoff) << PAGE_SHIFT);
> 
> and from that address the pte can be found by walking the vma->vm_mm
> page tables.
> 
> So page->index does what you want it to, identify which part of the
> framebuffer this particular page belongs to.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
