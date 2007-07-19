Date: Thu, 19 Jul 2007 22:01:18 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [BUGFIX]{PATCH] flush icache on ia64 take2
Message-Id: <20070719220118.73f40346.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <469F5372.7010703@bull.net>
References: <20070706112901.16bb5f8a.kamezawa.hiroyu@jp.fujitsu.com>
	<20070719155632.7dbfb110.kamezawa.hiroyu@jp.fujitsu.com>
	<469F5372.7010703@bull.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Zoltan Menyhart <Zoltan.Menyhart@bull.net>
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, tony.luck@intel.com, nickpiggin@yahoo.com.au, mike@stroyan.net, dmosberger@gmail.com, y-goto@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

On Thu, 19 Jul 2007 14:05:06 +0200
Zoltan Menyhart <Zoltan.Menyhart@bull.net> wrote:

> KAMEZAWA Hiroyuki wrote:
> 
> > Then, what should I do more for fixing this SIGILL problem ?
> > 
> > -Kame
> 
> I can think of a relatively cheap solution:
> 
Maybe I should take performance numbers with the patch.

But is it too costly that flushing icache page only if a page is newly
installed into the system (PG_arch1) && it is mapped as executable ?

I don't want to leak this (stupid) corner case to the file system layer.
Hmm...can't we do clever flushing (like your idea) in VM layer ?

-Kame
> New pages are allocated with the bit PG_arch_1 off, see
> page_cache_read() ... prep_new_page(), i.e. the I-cache is
> not coherent with the D-cache.
> 
> page_cache_read() should add a macro, say:
> 
> 	ARCH_PREP_PAGE_BEFORE_READ(page);
> 
> before actually calling mapping->a_ops->readpage(file, page).
> 
> This macro can be for ia64 something like:
> 
> do { if (CPU_has_split_L2_I_cache) set_bit(PG_arch_1, &page->flags); }
> 
> and empty for the the architectures non concerned.
> 
> The file systems which are identified not to use HW tools to
> avoid split I-cache incoherency, e.g. nfs_readpage(), are required
> to add a macro, say:
> 
> 	ARCH_CHECK_READ_PAGE_COHERENCY(page);
> 
> This macro can be for ia64:
> 
> do { if (CPU_has_split_L2_I_cache) clear_bit(PG_arch_1, &page->flags); }
> 
> and empty for the the architectures non concerned.
> 
> Back to do_no_page():
> if the new PTE includes the exec bit and PG_arch_1 is set,
> the page has to be flushed from the I-cache before the PTE is
> made globally visible.
> 
> File systems using local block devices with DMA are considered
> to be safe, with the exceptions of the bounce buffers.
> 
> When you copy into the destination page, another macro should be
> added, say:
> 
> 	ARCH_CHECK_BOUNCE_READ_COHERENCY(bio_vec);
> 
> #define ARCH_CHECK_BOUNCE_READ_COHERENCY(bio_vec) \
> 		ARCH_CHECK_READ_PAGE_COHERENCY(bio_vec->bv_page)
> 
> Remote DMA based network file systems, e.g. Lustre on Quadrics,
> Infiniband are also considered to be safe.
> 
> Thanks,
> 
> Zoltan
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
