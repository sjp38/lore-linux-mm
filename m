Date: Sun, 1 Jun 2003 12:58:09 -0700
From: Andrew Morton <akpm@digeo.com>
Subject: Re: 2.5.70-bk4+: oops by mc -v /proc/bus/pci/00/00.0
Message-Id: <20030601125809.4e28453e.akpm@digeo.com>
In-Reply-To: <20030601143439.O626@nightmaster.csn.tu-chemnitz.de>
References: <20030531165523.GA18067@steel.home>
	<20030531195414.10c957b7.akpm@digeo.com>
	<20030601143439.O626@nightmaster.csn.tu-chemnitz.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Oeser <ingo.oeser@informatik.tu-chemnitz.de>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Ingo Oeser <ingo.oeser@informatik.tu-chemnitz.de> wrote:
>
> Hi Andrew,
> 
> On Sat, May 31, 2003 at 07:54:14PM -0700, Andrew Morton wrote:
> > It's pretty lame.  Really we need a proper vma constructor
> > somewhere.
> 
> you mean sth. like this? (Just initialized the members, that I had useful
> defaults for.)
> 
> ...
>  	vm_area_cachep = kmem_cache_create("vm_area_struct",
>  			sizeof(struct vm_area_struct), 0,
> -			0, NULL, NULL);
> +			0, init_vm_area_struct, NULL);
>  	if(!vm_area_cachep)
>  		panic("vma_init: Cannot alloc vm_area_struct SLAB cache");
>  

Well not really.  Yes, a slab-based ctor would be nice, but it requires that
all objects be kfreed in a "constructed" state.  So a full audit/fixup of
all users is needed.

For now I was thinking more along the lines of

struct vma_struct alloc_vma(gfp_flags)
{
	vma = kmem_cache_alloc();
	memset(vma);
	return vma;
}

And then deleting tons of open-coded init stuff elsewhere...
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
