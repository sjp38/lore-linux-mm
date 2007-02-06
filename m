Date: Tue, 6 Feb 2007 10:23:12 +0000
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [RFC/PATCH] prepare_unmapped_area
Message-ID: <20070206102312.GA11783@infradead.org>
References: <200702060405.l1645R7G009668@shell0.pdx.osdl.net> <1170736938.2620.213.camel@localhost.localdomain> <20070206044516.GA16647@wotan.suse.de> <1170738296.2620.220.camel@localhost.localdomain> <20070206095509.GA8714@infradead.org> <1170756442.2620.234.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1170756442.2620.234.camel@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Christoph Hellwig <hch@infradead.org>, Nick Piggin <npiggin@suse.de>, akpm@linux-foundation.org, hugh@veritas.com, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, Feb 06, 2007 at 09:07:22PM +1100, Benjamin Herrenschmidt wrote:
> 
> > Eeek, this is more than fugly.  Dave Hansen suggested to move these
> > checks into a file operation in response to Adam Litke's hugetlb cleanups,
> > and this patch shows he was right :)
> 
> No, you don't understand... There is a fops for get_unmapped_area for
> the "special" file. It's currently not called for MAP_FIXED but that can
> be fixed easily enough (in fact, I have a few ideas to clean up some of
> that code, it's already horrible today).
> 
> The problem is to prevent something -else- from being mapped into one of
> those 256MB area once it's been switched to a different page size.
> 
> Right now, this is done via this hugetlbfs specific hack. I want to
> have instead some way to have the arch "validate" the address after
> get_unmapped_area(), in addition, hugetlbfs wants to "prepare" but that
> could indeed be done in hugetlbfs provided fops->get_unmapped_area() if
> we call it for MAP_FIXED as well.

Can we extent mm->get_unmapped_area for that if it's called for !MAP_FIXED
aswell instead of adding yet another arch hook?

This area is getting a little bit too messy with all the pseudo-generic code
and lots of arch hooks. Personally I'd prefer to let get_unmapped_area
look like the following:


unsigned long
get_unmapped_area(struct file *file, unsigned long addr, unsigned long len,
		  unsigned long pgoff, unsigned long flags)
{
	get_area = current->mm->get_unmapped_area;
	if (file && file->f_op && file->f_op->get_unmapped_area)
		get_area = file->f_op->get_unmapped_area;
	addr = get_area(file, addr, len, pgoff, flags);
	if (IS_ERR_VALUE(addr))
		return addr;
}

aka mm->get_unmapped_area is mandatory, and all arch specific code
is move into it.  We'd provide a default mm->get_unmapped_area that
doesn't even deal with hugetlb for all the trivial architectures,
and any arch that wants to do their own work can do all this through
a signle hook.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
