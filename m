Date: Fri, 28 Mar 2008 13:51:04 +0100
From: Jens Axboe <jens.axboe@oracle.com>
Subject: Re: down_spin() implementation
Message-ID: <20080328125104.GK12346@kernel.dk>
References: <1FE6DD409037234FAB833C420AA843ECE9DF60@orsmsx424.amr.corp.intel.com> <20080326123239.GG16721@parisc-linux.org> <1FE6DD409037234FAB833C420AA843ECE9EB1C@orsmsx424.amr.corp.intel.com> <20080327141508.GL16721@parisc-linux.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080327141508.GL16721@parisc-linux.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Matthew Wilcox <matthew@wil.cx>
Cc: "Luck, Tony" <tony.luck@intel.com>, Stephen Rothwell <sfr@canb.auug.org.au>, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, Mar 27 2008, Matthew Wilcox wrote:
> On Wed, Mar 26, 2008 at 01:29:58PM -0700, Luck, Tony wrote:
> > This looks a lot cleaner than my ia64 specific code that
> > used cmpxchg() for the down() operation and fetchadd for
> > the up() ... using a brand new semaphore_spin data type.
> 
> I did brifly consider creating a spinaphore data type, but it's
> significantly less code to create down_spin().
> 
> > It appears to work ... I tried to do some timing comparisons
> > of this generic version against my arch specific one, but the
> > hackbench test case has a run to run variation of a factor of
> > three (from 1min9sec to 3min44sec) so it is hopeless to try
> > and see some small percentage difference.
> 
> Thanks for testing and putting this together in patch form.  I've fixed it
> up to address Jens' astute comment and added it to my semaphore patchset.
> 
> http://git.kernel.org/?p=linux/kernel/git/willy/misc.git;a=shortlog;h=semaphore-20080327
> 
> Stephen, I've updated the 'semaphore' tag to point ot the same place as
> semaphore-20080327, so please change your linux-next tree from pulling
> semaphore-20080314 to just pulling plain 'semaphore'.  I'll use this
> method of tagging from now on.
> 
> Here's the edited patch.
> 
> commit 517df6fedc88af3f871cf827a62ef1a1a2073645
> Author: Matthew Wilcox <matthew@wil.cx>
> Date:   Thu Mar 27 09:49:26 2008 -0400
> 
>     Add down_spin()
>     
>     ia64 would like to use a semaphore in flush_tlb_all() as it can have
>     multiple tokens.  Unfortunately, it's currently nested inside a spinlock,
>     so they can't sleep.  down_spin() is the cheapest solution to implement.
>     
>     Signed-off-by: Tony Luck <tony.luck@intel.com>
>     Signed-off-by: Matthew Wilcox <willy@linux.intel.com>
> 
> diff --git a/include/linux/semaphore.h b/include/linux/semaphore.h
> index a7125da..13b5f32 100644
> --- a/include/linux/semaphore.h
> +++ b/include/linux/semaphore.h
> @@ -78,6 +78,14 @@ extern int __must_check down_trylock(struct semaphore *sem);
>  extern int __must_check down_timeout(struct semaphore *sem, long jiffies);
>  
>  /*
> + * As down(), except this function will spin waiting for the semaphore
> + * instead of sleeping.  It is safe to use while holding a spinlock or
> + * with interrupts disabled.  It should not be called from interrupt
> + * context as this may lead to deadlocks.
> + */
> +extern void down_spin(struct semaphore *sem);
> +
> +/*
>   * Release the semaphore.  Unlike mutexes, up() may be called from any
>   * context and even by tasks which have never called down().
>   */
> diff --git a/kernel/semaphore.c b/kernel/semaphore.c
> index bef977b..a242d87 100644
> --- a/kernel/semaphore.c
> +++ b/kernel/semaphore.c
> @@ -26,6 +26,7 @@ static noinline void __down(struct semaphore *sem);
>  static noinline int __down_interruptible(struct semaphore *sem);
>  static noinline int __down_killable(struct semaphore *sem);
>  static noinline int __down_timeout(struct semaphore *sem, long jiffies);
> +static noinline void __down_spin(struct semaphore *sem, unsigned long flags);
>  static noinline void __up(struct semaphore *sem);
>  
>  void down(struct semaphore *sem)
> @@ -117,6 +118,20 @@ int down_timeout(struct semaphore *sem, long jiffies)
>  }
>  EXPORT_SYMBOL(down_timeout);
>  
> +void down_spin(struct semaphore *sem)
> +{
> +       unsigned long flags;
> +
> +       spin_lock_irqsave(&sem->lock, flags);
> +       if (likely(sem->count > 0)) {
> +               sem->count--;
> +               spin_unlock_irqrestore(&sem->lock, flags);
> +       } else {
> +               __down_spin(sem, flags);
> +       }
> +}
> +EXPORT_SYMBOL(down_spin);
> +
>  void up(struct semaphore *sem)
>  {
>         unsigned long flags;
> @@ -197,6 +212,20 @@ static noinline int __sched __down_timeout(struct semaphore
>         return __down_common(sem, TASK_UNINTERRUPTIBLE, jiffies);
>  }
>  
> +static noinline void __sched __down_spin(struct semaphore *sem,
> +                                                       unsigned long flags)
> +{
> +       struct semaphore_waiter waiter;
> +
> +       list_add_tail(&waiter.list, &sem->wait_list);
> +       waiter.task = current;
> +       waiter.up = 0;
> +
> +       spin_unlock_irqrestore(&sem->lock, flags);
> +       while (!waiter.up)
> +               cpu_relax();
> +}
> +
>  static noinline void __sched __up(struct semaphore *sem)
>  {
>         struct semaphore_waiter *waiter = list_first_entry(&sem->wait_list,

It used to be illegal to pass flags as parameters. IIRC, sparc did some
trickery with it. That may still be the case, I haven't checked in a
long time.

Why not just fold __down_spin() into down_spin() and get rid of that
nasty anyway?

-- 
Jens Axboe

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
