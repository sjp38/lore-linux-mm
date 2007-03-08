Subject: Re: [RFC][PATCH] mm: fix page_mkclean() vs non-linear vmas
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <E1HPGg9-00039z-00@dorka.pomaz.szeredi.hu>
References: <1173264462.6374.140.camel@twins>
	 <20070307110035.GE5555@wotan.suse.de> <1173268086.6374.157.camel@twins>
	 <20070307121730.GC18704@wotan.suse.de> <1173271286.6374.166.camel@twins>
	 <20070307130851.GE18704@wotan.suse.de> <1173273562.6374.175.camel@twins>
	 <20070307133649.GF18704@wotan.suse.de> <1173275532.6374.183.camel@twins>
	 <1173278067.6374.188.camel@twins>  <20070307150102.GH18704@wotan.suse.de>
	 <1173286682.6374.191.camel@twins>
	 <E1HPGg9-00039z-00@dorka.pomaz.szeredi.hu>
Content-Type: text/plain
Date: Thu, 08 Mar 2007 12:37:04 +0100
Message-Id: <1173353824.9438.15.camel@twins>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Miklos Szeredi <miklos@szeredi.hu>
Cc: npiggin@suse.de, akpm@linux-foundation.org, mingo@elte.hu, linux-mm@kvack.org, linux-kernel@vger.kernel.org, benh@kernel.crashing.org, jdike@addtoit.com, hugh@veritas.com, torvalds@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Thu, 2007-03-08 at 12:21 +0100, Miklos Szeredi wrote:
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

AFAIK no other OS does this against regular filesystems (hear-say)

>   - it's a maintenance burden: I'll have to layer the m/ctime update
>     patch on top of this
> 
>   - the only pro for this has been that Nick thinks it cool ;)
> 
> I think the proper way to deal with this is to
> 
>   - allow BDI_CAP_NO_WRITEBACK (tmpfs/ramfs) uses, makes database
>     people happy

And UML once the remap_file_pages_prot() stuff is merged.

>   - for !BDI_CAP_NO_WRITEBACK emulate using do_mmap_pgoff(), should be
>     trivial, no userspace ABI breakage

I can live with that.

However this still leaves the non-linear reclaim (Nick pointed it out as
a potential DoS and other people have corroborated this). I have no idea
on that to do about that.

Oracle seems to mlock these things anyway, but UML surely would not.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
