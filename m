Date: Wed, 6 Jun 2007 02:06:51 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 4/4] mm: variable length argument support
Message-Id: <20070606020651.19a89dca.akpm@linux-foundation.org>
In-Reply-To: <1181120061.7348.177.camel@twins>
References: <20070605150523.786600000@chello.nl>
	<20070605151203.790585000@chello.nl>
	<20070606013658.20bcbe2f.akpm@linux-foundation.org>
	<1181120061.7348.177.camel@twins>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: linux-kernel@vger.kernel.org, parisc-linux@lists.parisc-linux.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, Ollie Wild <aaw@google.com>, Ingo Molnar <mingo@elte.hu>, Andi Kleen <ak@suse.de>
List-ID: <linux-mm.kvack.org>

On Wed, 06 Jun 2007 10:54:21 +0200 Peter Zijlstra <a.p.zijlstra@chello.nl> wrote:

> > > It is a bit peculiar in that we have one task with two mm's, one of which is
> > > inactive.
> > > 
> > > ...
> > >
> > > +				flush_cache_page(bprm->vma, kpos,
> > > +						 page_to_pfn(kmapped_page));
> 
> Bah, and my frv cross build bums out on an unrelated change,..
> I'll see if I can get a noMMU arch building, in the mean time, would you
> try this:
> 
> ---
> 
> Since no-MMU doesn't do the fancy inactive mm access there is no need to
> flush cache.
> 
> Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
> ---
> 
> Index: linux-2.6-2/fs/exec.c
> ===================================================================
> --- linux-2.6-2.orig/fs/exec.c	2007-06-05 16:48:52.000000000 +0200
> +++ linux-2.6-2/fs/exec.c	2007-06-06 10:49:19.000000000 +0200
> @@ -428,8 +428,10 @@ static int copy_strings(int argc, char _
>  				kmapped_page = page;
>  				kaddr = kmap(kmapped_page);
>  				kpos = pos & PAGE_MASK;
> +#ifdef CONFIG_MMU
>  				flush_cache_page(bprm->vma, kpos,
>  						 page_to_pfn(kmapped_page));
> +#endif
>  			}
>  			if (copy_from_user(kaddr+offset, str, bytes_to_copy)) {
>  				ret = -EFAULT;
> 

I think the same problem will happen on NOMMU && STACK_GROWS_UP.  There are
several new references to bprm->vma in there, not all inside CONFIG_MMU.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
