In-reply-to: <1201078278.6341.47.camel@lappy> (message from Peter Zijlstra on
	Wed, 23 Jan 2008 09:51:18 +0100)
Subject: Re: [PATCH -v8 3/4] Enable the MS_ASYNC functionality in
	sys_msync()
References: <12010440803930-git-send-email-salikhmetov@gmail.com>
	 <1201044083504-git-send-email-salikhmetov@gmail.com>
	 <1201078035.6341.45.camel@lappy> <1201078278.6341.47.camel@lappy>
Message-Id: <E1JHc0S-00027S-8D@pomaz-ex.szeredi.hu>
From: Miklos Szeredi <miklos@szeredi.hu>
Date: Wed, 23 Jan 2008 10:34:52 +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: a.p.zijlstra@chello.nl
Cc: salikhmetov@gmail.com, linux-mm@kvack.org, jakob@unthought.net, linux-kernel@vger.kernel.org, valdis.kletnieks@vt.edu, riel@redhat.com, ksm@42.dk, staubach@redhat.com, jesper.juhl@gmail.com, torvalds@linux-foundation.org, akpm@linux-foundation.org, protasnb@gmail.com, miklos@szeredi.hu, r.e.wolff@bitwizard.nl, hidave.darkstar@gmail.com, hch@infradead.org
List-ID: <linux-mm.kvack.org>

> On Wed, 2008-01-23 at 09:47 +0100, Peter Zijlstra wrote:
> > On Wed, 2008-01-23 at 02:21 +0300, Anton Salikhmetov wrote:
> 
> > > +static void vma_wrprotect(struct vm_area_struct *vma)
> > > +{
> > > +	unsigned long addr = vma->vm_start;
> > > +	pgd_t *pgd = pgd_offset(vma->vm_mm, addr);
> > > +
> > > +	while (addr < vma->vm_end) {
> > > +		unsigned long next = pgd_addr_end(addr, vma->vm_end);
> > > +
> > > +		if (!pgd_none_or_clear_bad(pgd))
> > > +			vma_wrprotect_pgd_range(vma, pgd, addr, next);
> > > +
> > > +		++pgd;
> > > +		addr = next;
> > > +	}
> > > +}
> > 
> > I think you want to pass start, end here too, you might not need to
> > sweep the whole vma.
> 
> Also, it still doesn't make sense to me why we'd not need to walk the
> rmap, it is all the same file after all.

It's the same file, but not the same memory map.  It basically depends
on how you define msync:

 a) sync _file_ on region defined by this mmap/start/end-address
 b) sync _memory_region_ defined by start/end-address

b) is a perfectly fine definition, and it's consistent with what this
code does.  The fact that POSIX probably implies a) (in a rather
poorly defined way) doesn't make much difference, I think.

Miklos

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
