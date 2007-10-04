Date: Thu, 4 Oct 2007 16:48:01 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] remove throttle_vm_writeout()
Message-Id: <20071004164801.d8478727.akpm@linux-foundation.org>
In-Reply-To: <E1Ida56-0002Zz-00@dorka.pomaz.szeredi.hu>
References: <E1IdPla-0002Bd-00@dorka.pomaz.szeredi.hu>
	<20071004145640.18ced770.akpm@linux-foundation.org>
	<E1IdZLg-0002Wr-00@dorka.pomaz.szeredi.hu>
	<20071004160941.e0c0c7e5.akpm@linux-foundation.org>
	<E1Ida56-0002Zz-00@dorka.pomaz.szeredi.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Miklos Szeredi <miklos@szeredi.hu>
Cc: wfg@mail.ustc.edu.cn, a.p.zijlstra@chello.nl, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, 05 Oct 2007 01:26:12 +0200
Miklos Szeredi <miklos@szeredi.hu> wrote:

> > This is a somewhat general problem: a userspace process is in the IO path. 
> > Userspace block drivers, for example - pretty much anything which involves
> > kernel->userspace upcalls for storage applications.
> > 
> > I solved it once in the past by marking the userspace process as
> > PF_MEMALLOC and I beleive that others have implemented the same hack.
> > 
> > I suspect that what we need is a general solution, and that the solution
> > will involve explicitly telling the kernel that this process is one which
> > actually cleans memory and needs special treatment.
> > 
> > Because I bet there will be other corner-cases where such a process needs
> > kernel help, and there might be optimisation opportunities as well.
> > 
> > Problem is, any such mark-me-as-special syscall would need to be
> > privileged, and FUSE servers presently don't require special perms (do
> > they?)
> 
> No, and that's a rather important feature, that I'd rather not give
> up.

Can fuse do it?  Perhaps the fs can diddle the server's task_struct at
registration time?

>  But with the dirty limiting, the memory cleaning really shouldn't
> be a problem, as there is plenty of memory _not_ used for dirty file
> data, that the filesystem can use during the writeback.

I don't think I understand that.  Sure, it _shouldn't_ be a problem.  But it
_is_.  That's what we're trying to fix, isn't it?

> So the only thing the kernel should be careful about, is not to block
> on an allocation if not strictly necessary.
> 
> Actually a trivial fix for this problem could be to just tweak the
> thresholds, so to make the above scenario impossible.  Although I'm
> still not convinced, this patch is perfect, because the dirty
> threshold can actually change in time...
> 
> Index: linux/mm/page-writeback.c
> ===================================================================
> --- linux.orig/mm/page-writeback.c      2007-10-05 00:31:01.000000000 +0200
> +++ linux/mm/page-writeback.c   2007-10-05 00:50:11.000000000 +0200
> @@ -515,6 +515,12 @@ void throttle_vm_writeout(gfp_t gfp_mask
>          for ( ; ; ) {
>                 get_dirty_limits(&background_thresh, &dirty_thresh, NULL, NULL);
> 
> +               /*
> +                * Make sure the theshold is over the hard limit of
> +                * dirty_thresh + ratelimit_pages * nr_cpus
> +                */
> +               dirty_thresh += ratelimit_pages * num_online_cpus();
> +
>                  /*
>                   * Boost the allowable dirty threshold a bit for page
>                   * allocators so they don't get DoS'ed by heavy writers

I can probably kind of guess what you're trying to do here.  But if
ratelimit_pages * num_online_cpus() exceeds the size of the offending zone
then things might go bad.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
