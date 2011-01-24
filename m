Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 81AB36B00E7
	for <linux-mm@kvack.org>; Mon, 24 Jan 2011 15:44:48 -0500 (EST)
Date: Mon, 24 Jan 2011 12:44:12 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] fix build error when CONFIG_SWAP is not set
Message-Id: <20110124124412.69a7c814.akpm@linux-foundation.org>
In-Reply-To: <4D3DD366.8000704@mvista.com>
References: <20110124210813.ba743fc5.yuasa@linux-mips.org>
	<4D3DD366.8000704@mvista.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Sergei Shtylyov <sshtylyov@mvista.com>
Cc: Yoichi Yuasa <yuasa@linux-mips.org>, linux-mips <linux-mips@linux-mips.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, 24 Jan 2011 22:30:46 +0300
Sergei Shtylyov <sshtylyov@mvista.com> wrote:

> Hello.
> 
> Yoichi Yuasa wrote:
> 
> > In file included from
> > linux-2.6/arch/mips/include/asm/tlb.h:21,
> >                  from mm/pgtable-generic.c:9:
> > include/asm-generic/tlb.h: In function 'tlb_flush_mmu':
> > include/asm-generic/tlb.h:76: error: implicit declaration of function
> > 'release_pages'
> > include/asm-generic/tlb.h: In function 'tlb_remove_page':
> > include/asm-generic/tlb.h:105: error: implicit declaration of function
> > 'page_cache_release'
> > make[1]: *** [mm/pgtable-generic.o] Error 1
> > 
> > Signed-off-by: Yoichi Yuasa <yuasa@linux-mips.org>
> [...]
> 
> > diff --git a/include/linux/swap.h b/include/linux/swap.h
> > index 4d55932..92c1be6 100644
> > --- a/include/linux/swap.h
> > +++ b/include/linux/swap.h
> > @@ -8,6 +8,7 @@
> >  #include <linux/memcontrol.h>
> >  #include <linux/sched.h>
> >  #include <linux/node.h>
> > +#include <linux/pagemap.h>
> 
>     Hm, if the errors are in <asm-generic/tlb.h>, why add #include in 
> <linux/swap.h>?
> 

The build error is caused by macros which are defined in swap.h.

I worry about the effects of the patch - I don't know which of swap.h
and pagemap.h is the "innermost" header file.  There's potential for
new build errors due to strange inclusion graphs.

err, there's also this, in swap.h:

/* only sparc can not include linux/pagemap.h in this file
 * so leave page_cache_release and release_pages undeclared... */

It would be safer to convert free_page_and_swap_cache() and
free_pages_and_swap_cache() into out-of-line C functions.  Or to
explicitly include pagemap.h into the offending .c files.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
