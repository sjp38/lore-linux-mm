From: Con Kolivas <kernel@kolivas.org>
Subject: Re: [PATCH] mm: cleanup swap unused warning
Date: Wed, 10 May 2006 21:46:25 +1000
References: <200605102132.41217.kernel@kolivas.org> <20060510043834.70f40ddc.akpm@osdl.org>
In-Reply-To: <20060510043834.70f40ddc.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 8BIT
Content-Disposition: inline
Message-Id: <200605102146.26080.kernel@kolivas.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wednesday 10 May 2006 21:38, Andrew Morton wrote:
> Con Kolivas <kernel@kolivas.org> wrote:
> > Are there any users of swp_entry_t when CONFIG_SWAP is not defined?
>
> Well there shouldn't be.  Making accesses to swp_entry_t.val fail to
> compile if !CONFIG_SWAP might be useful.
>
> > +/*
> > + * A swap entry has to fit into a "unsigned long", as
> > + * the entry is hidden in the "index" field of the
> > + * swapper address space.
> > + */
> > +#ifdef CONFIG_SWAP
> >  typedef struct {
> >  	unsigned long val;
> >  } swp_entry_t;
> > +#else
> > +typedef struct {
> > +	unsigned long val;
> > +} swp_entry_t __attribute__((__unused__));
> > +#endif
>
> We have __attribute_used__, which hides a gcc oddity.

I tried that.

In file included from arch/i386/mm/pgtable.c:11:
include/linux/swap.h:82: warning: a??__used__a?? attribute ignored
In file included from include/linux/suspend.h:8,
                 from init/do_mounts.c:7:
include/linux/swap.h:82: warning: a??__used__a?? attribute ignored
In file included from arch/i386/mm/init.c:22:
include/linux/swap.h:82: warning: a??__used__a?? attribute ignored
  AS      arch/i386/kernel/vsyscall-sysenter.o

etc..

and doesn't fix the warning in vmscan.c. __attribute_used__ is handled 
differently by gcc4 it seems (this is 4.1.0)

-- 
-ck

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
