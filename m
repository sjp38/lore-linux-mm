Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx132.postini.com [74.125.245.132])
	by kanga.kvack.org (Postfix) with SMTP id 1F5126B0070
	for <linux-mm@kvack.org>; Tue, 18 Dec 2012 02:34:33 -0500 (EST)
Received: by mail-da0-f42.google.com with SMTP id z17so179231dal.15
        for <linux-mm@kvack.org>; Mon, 17 Dec 2012 23:34:32 -0800 (PST)
Date: Mon, 17 Dec 2012 23:34:30 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm: Suppress mm/memory.o warning on older compilers if
 !CONFIG_NUMA_BALANCING
In-Reply-To: <20121217124949.3024dda3.akpm@linux-foundation.org>
Message-ID: <alpine.DEB.2.00.1212172306150.29320@chino.kir.corp.google.com>
References: <20121217114917.GF9887@suse.de> <20121217124949.3024dda3.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kbuild test robot <fengguang.wu@intel.com>

On Mon, 17 Dec 2012, Andrew Morton wrote:

> > The kbuild test robot reported the following after the merge of Automatic
> > NUMA Balancing when cross-compiling for avr32.
> > 
> > mm/memory.c: In function 'do_pmd_numa_page':
> > mm/memory.c:3593: warning: no return statement in function returning non-void
> > 
> > The code is unreachable but the avr32 cross-compiler was not new enough
> > to know that. This patch suppresses the warning.
> > 
> > Signed-off-by: Mel Gorman <mgorman@suse.de>
> > ---
> >  mm/memory.c |    1 +
> >  1 file changed, 1 insertion(+)
> > 
> > diff --git a/mm/memory.c b/mm/memory.c
> > index e6a3b93..23f1fdf 100644
> > --- a/mm/memory.c
> > +++ b/mm/memory.c
> > @@ -3590,6 +3590,7 @@ static int do_pmd_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
> >  		     unsigned long addr, pmd_t *pmdp)
> >  {
> >  	BUG();
> > +	return 0;
> >  }
> >  #endif /* CONFIG_NUMA_BALANCING */
> 
> Odd.  avr32's BUG() includes a call to unreachable(), which should
> evaluate to "do { } while (1)".  Can you check that this is working?
> 
> Perhaps it _is_ working, but the compiler incorrectly thinks that the
> function can return?
> 

This isn't the typical "control reaches end of non-void function", the 
warning is merely stating there is no return statement in the function 
which happens to be the case (and it has nothing to do with avr32, it 
will be the same on all archs).  This is one of the last things that gcc 
does after it parses a function declaration and will be emitted with 
-Wreturn-type unless the function in question is main() and it isn't 
marked with __attribute__((noreturn)).  If you're testing this, try making 
the function statically defined and it should show up even with 
do {} while(1).

And for CONFIG_BUG=n this ends up being do {} while (0) which is just a 
no-op and would end up returning that "control reaches end of non-void 
function" warning.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
