Date: Wed, 22 Aug 2007 14:15:16 -0500
From: Dean Nelson <dcn@sgi.com>
Subject: Re: [RFC 3/3] SGI Altix cross partition memory (XPMEM)
Message-ID: <20070822191516.GA24018@sgi.com>
References: <20070810010659.GA25427@sgi.com> <20070810011435.GD25427@sgi.com> <20070809231542.f6dcce8c.akpm@linux-foundation.org> <20070822170011.GA20155@sgi.com> <20070822110422.65c990e5.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070822110422.65c990e5.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, tony.luck@intel.com, jes@sgi.com
List-ID: <linux-mm.kvack.org>

On Wed, Aug 22, 2007 at 11:04:22AM -0700, Andrew Morton wrote:
> On Wed, 22 Aug 2007 12:00:11 -0500
> Dean Nelson <dcn@sgi.com> wrote:
> 
> > 
> >   3) WARNING: declaring multiple variables together should be avoided
> > 
> > checkpatch.pl is erroneously commplaining about the following found in five
> > different functions in arch/ia64/sn/kernel/xpmem_pfn.c.
> > 
> > 	int n_pgs = xpmem_num_of_pages(vaddr, size);
> 
> What warning does it generate here?

The WARNING #3 above "declaring multiple variables together should be avoided".
There is only one variable being declared, which happens to be initialized by
the function xpmem_num_of_pages().

> > > - xpmem_fault_handler() appears to have imposed a kernel-wide rule that
> > >   when taking multiple mmap_sems, one should take the lowest-addressed one
> > >   first?  If so, that probably wants a mention in that locking comment in
> > >   filemap.c
> > 
> > Sure. After looking at the lock ordering comment block in mm/filemap.c, it
> > wasn't clear to me how best to document this. Any suggestions/help would
> > be most appreciated.
> 
> umm,
> 
>  * when taking multiple mmap_sems, one should take the lowest-addressed one
>  * first
> 
>  ;)

Thanks.

> > > - xpmem_fault_handler() does atomic_dec(&seg_tg->mm->mm_users).  What
> > >   happens if that was the last reference?
> > 
> > When /dev/xpmem is opened by a user process, xpmem_open() incs mm_users
> > and when it is flushed, xpmem_flush() decs it (via mmput()) after having
> > ensured that no XPMEM attachments exist of this mm. Thus the dec in
> > xpmem_fault_handler() will never take it to 0.
> 
> OK.  Generally if a reviewer asks a question like this, it indicates that a
> code comment is needed.  Because it is likely that others will later wonder
> the same thing.

Will do.

> > > - Has it all been tested with lockdep enabled?  Jugding from all the use
> > >   of SPIN_LOCK_UNLOCKED, it has not.
> > >
> > >   Oh, ia64 doesn't implement lockdep.  For this code, that is deeply
> > >   regrettable.
> > 
> > No, it hasn't been tested with lockdep. But I have switched it from using
> > SPIN_LOCK_UNLOCKED to spin_lock_init().
> > 
> > > ! This code all predates the nopage->fault conversion and won't work in
> > >   current kernels.
> > 
> > I've switched from using nopage to using fault. I read that it is intended
> > that nopfn also goes away. If this is the case, then the BUG_ON if VM_PFNMAP
> > is set would make __do_fault() a rather unfriendly replacement for do_no_pfn().
> > 
> > > - xpmem_attach() does smp_processor_id() in preemptible code.  Lucky that
> > >   ia64 doesn't do preempt?
> > 
> > Actually, the code is fine as is even with preemption configured on. All it's
> > doing is ensuring that the thread was previously pinned to the CPU it's
> > currently running on. If it is, it can't be moved to another CPU via
> > preemption, and if it isn't, the check will fail and we'll return -EINVAL
> > and all is well.
> 
> OK.  Running smp_processor_id() from within preemptible code will generate
> a warning, but the code is sneaky enough to prevent that warning if the
> calling task happens to be pinned to a single CPU.

Would it make more sense in this particular case to replace the call to
smp_processor_id() in xpmem_attach() with a call to raw_smp_processor_id()
instead, and add a comment explaining why?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
