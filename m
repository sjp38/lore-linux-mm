Date: Fri, 17 Oct 2008 06:11:45 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [garloff@suse.de: [PATCH 1/1] default mlock limit 32k->64k]
Message-ID: <20081017041145.GB12076@wotan.suse.de>
References: <20081016074319.GD5286@tpkurt2.garloff.de> <20081016154816.c53a6f8e.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20081016154816.c53a6f8e.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Kurt Garloff <garloff@suse.de>, linux-arch@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Oct 16, 2008 at 03:48:16PM -0700, Andrew Morton wrote:
> On Thu, 16 Oct 2008 09:43:19 +0200
> Kurt Garloff <garloff@suse.de> wrote:
> 
> > By default, non-privileged tasks can only mlock() a small amount of
> > memory to avoid a DoS attack by ordinary users. The Linux kernel
> > defaulted to 32k (on a 4k page size system) to accommodate the
> > needs of gpg.
> > However, newer gpg2 needs 64k in various circumstances and otherwise
> > fails miserably, see bnc#329675.
> > 
> > Change the default to 64k, and make it more agnostic to PAGE_SIZE.
> > 
> > Signed-off-by: Kurt Garloff <garloff@suse.de>
> > Signed-off-by: Nick Piggin <npiggin@suse.de>
> > ---
> > Index: linux-2.6.27/include/linux/resource.h
> > ===================================================================
> > --- linux-2.6.27.orig/include/linux/resource.h
> > +++ linux-2.6.27/include/linux/resource.h
> > @@ -59,10 +59,10 @@ struct rlimit {
> >  #define _STK_LIM	(8*1024*1024)
> >  
> >  /*
> > - * GPG wants 32kB of mlocked memory, to make sure pass phrases
> > + * GPG2 wants 64kB of mlocked memory, to make sure pass phrases
> >   * and other sensitive information are never written to disk.
> >   */
> > -#define MLOCK_LIMIT	(8 * PAGE_SIZE)
> > +#define MLOCK_LIMIT	((PAGE_SIZE > 64*1024) ? PAGE_SIZE : 64*1024)
> 
> I dunno.  Is there really much point in chasing userspace changes like
> this?

I think the default is *much* better. Not in terms of exact sizes, but
being consistent over all architectures, and not being ridiculously too
high on 64k page size kernels (which ia64 and powerpc are heading towards)


> Worst case, we end up releasing distributions which work properly on
> newer kernels and which fail to work properly on older kernels.
> 
> I suspect that it would be better to set the default to zero and
> *force* userspace to correctly tune whatever-kernel-they're-running-on
> to match their requirements.

Probably that would have been the best way to go, but changing that now
also means old distros may not work properly with new kernels (which is
probably worse than old kernels not working on new distros, because that
is inevitable anyway).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
