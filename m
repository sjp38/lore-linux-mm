Subject: Re: Atomic operation for physically moving a page (for
	memory	defragmentation)
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <20040624071959.B76D970A2D@sv1.valinux.co.jp>
References: <20040619031536.61508.qmail@web10902.mail.yahoo.com>
	 <1087619137.4921.93.camel@nighthawk>
	 <20040623.205906.71913783.taka@valinux.co.jp>
	 <1088024190.28102.24.camel@nighthawk>
	 <20040624071959.B76D970A2D@sv1.valinux.co.jp>
Content-Type: text/plain
Message-Id: <1088076699.3918.234.camel@nighthawk>
Mime-Version: 1.0
Date: Thu, 24 Jun 2004 04:31:39 -0700
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: IWAMOTO Toshihiro <iwamoto@valinux.co.jp>
Cc: Hirokazu Takahashi <taka@valinux.co.jp>, ashwin_s_rao@yahoo.com, Valdis.Kletnieks@vt.edu, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, 2004-06-24 at 00:19, IWAMOTO Toshihiro wrote:
> At Wed, 23 Jun 2004 13:56:30 -0700,
> Dave Hansen wrote:
> > 
> > On Wed, 2004-06-23 at 04:59, Hirokazu Takahashi wrote:
> > > We should know that many part of kernel code will access the page
> > > without holding a lock_page(). The lock_page() can't block them.
> > 
> > No, but it will block them from establishing a new PTE to the page.  You
> > need to:
> > 
> > 1. make sure no new PTEs can be established to the page
> > 2. make sure there are no valid PTEs to the page.
> > 3. do the move
> > 
> > My suggestion relates to 1, only.
> 
> I wonder if you are talking exclusively about swap (anonymous) pages,
> where lock_page() might work.

I was talking about access to the pages through the user page tables,
only.  You can't really fully prevent other access to them, because some
other kernel user could always do something like kmap() and write to the
page.  There's probably some handy-dandy way to trap these kinds of
accesses in hardware, but Linux itself certainly can't provide that
guarantee without some restructuring to check for these areas any time
that a set_pte() is done.  

Remember, we don't do things like rmap for the *kernel* users of pages. 

> (I wonder why lock_page() is needed in do_swap_page(), btw.)
> 
> For page caches, usually lock_page() cannot prevent accesses to them,
> and there are several kernel functions which don't need PTE mappings
> for access.  One of such functions is do_generic_mapping_read().

You'll also have a generic problem with anything that does DMA, or that
uses the kernel page tables of any kind (kmap, vmalloc, etc...).

The DMA problem is a lot easier when there's an IOMMU, and even easier
on a partitioned ppc64 system where we have a virtualization layer to
take care of any areas under DMA that might undergo remapping. 

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
