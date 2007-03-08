Date: Thu, 8 Mar 2007 12:58:44 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [RFC][PATCH] mm: fix page_mkclean() vs non-linear vmas
Message-ID: <20070308115843.GA22781@wotan.suse.de>
References: <20070307121730.GC18704@wotan.suse.de> <1173271286.6374.166.camel@twins> <20070307130851.GE18704@wotan.suse.de> <1173273562.6374.175.camel@twins> <20070307133649.GF18704@wotan.suse.de> <1173275532.6374.183.camel@twins> <1173278067.6374.188.camel@twins> <20070307150102.GH18704@wotan.suse.de> <1173286682.6374.191.camel@twins> <E1HPGg9-00039z-00@dorka.pomaz.szeredi.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <E1HPGg9-00039z-00@dorka.pomaz.szeredi.hu>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Miklos Szeredi <miklos@szeredi.hu>
Cc: a.p.zijlstra@chello.nl, akpm@linux-foundation.org, mingo@elte.hu, linux-mm@kvack.org, linux-kernel@vger.kernel.org, benh@kernel.crashing.org, jdike@addtoit.com, hugh@veritas.com, torvalds@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Thu, Mar 08, 2007 at 12:21:01PM +0100, Miklos Szeredi wrote:
> > Partial revert of commit: 204ec841fbea3e5138168edbc3a76d46747cc987
> > 
> > Non-linear vmas aren't properly handled by page_mkclean() and fixing that
> > would result in linear scans of all related non-linear vmas per page_mkclean()
> > invocation.
> > 
> > This is deemed too costly, hence re-instate the msync scan for non-linear vmas.
> > 
> > However this can lead to double IO:
> > 
> >  - pages get instanciated with RO mapping
> >  - page takes write fault, and gets marked with PG_dirty
> >  - page gets tagged for writeout and calls page_mkclean()
> >  - page_mkclean() fails to find the dirty pte (and clean it)
> >  - writeout happens and PG_dirty gets cleared.
> >  - user calls msync, the dirty pte is found and the page marked with PG_dirty
> >  - the page gets writen out _again_ even though its not re-dirtied.
> > 
> > To minimize this reset the protection when creating a nonlinear vma.
> > 
> > I'm not at all happy with this, but plain disallowing
> > remap_file_pages on bdis without BDI_CAP_NO_WRITEBACK seems to
> > offend some people, hence restrict it to root only.
> 
> Root only for !BDI_CAP_NO_WRITEBACK mappings doesn't make sense
> because:
> 
>   - just encourages insecure applications
> 
>   - there are no current users that want this and presumable no future
>     uses either
> 
>   - it's a maintenance burden: I'll have to layer the m/ctime update
>     patch on top of this

But you have to update m/ctime for BDI_CAP_NO_WRITEBACK mappings anyway
don't you?

> 
>   - the only pro for this has been that Nick thinks it cool ;)

Nonlinear in general, rather than this specifically.

> I think the proper way to deal with this is to
> 
>   - allow BDI_CAP_NO_WRITEBACK (tmpfs/ramfs) uses, makes database
>     people happy
> 
>   - for !BDI_CAP_NO_WRITEBACK emulate using do_mmap_pgoff(), should be
>     trivial, no userspace ABI breakage

Yeah that sounds OK.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
