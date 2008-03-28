From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: down_spin() implementation
Date: Fri, 28 Mar 2008 11:01:24 +1100
References: <1FE6DD409037234FAB833C420AA843ECE9DF60@orsmsx424.amr.corp.intel.com> <1FE6DD409037234FAB833C420AA843ECE9EB1C@orsmsx424.amr.corp.intel.com> <20080327141508.GL16721@parisc-linux.org>
In-Reply-To: <20080327141508.GL16721@parisc-linux.org>
MIME-Version: 1.0
Content-Disposition: inline
Message-Id: <200803281101.25037.nickpiggin@yahoo.com.au>
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Matthew Wilcox <matthew@wil.cx>
Cc: "Luck, Tony" <tony.luck@intel.com>, Stephen Rothwell <sfr@canb.auug.org.au>, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Friday 28 March 2008 01:15, Matthew Wilcox wrote:
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
> http://git.kernel.org/?p=linux/kernel/git/willy/misc.git;a=shortlog;h=semap
>hore-20080327
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
>     multiple tokens.  Unfortunately, it's currently nested inside a
> spinlock, so they can't sleep.  down_spin() is the cheapest solution to
> implement.

Uhm, how do you use this exactly? All other holders of this
semaphore must have preempt disabled and not sleep, right? (and
so you need a new down() that disables preempt too)

So the only difference between this and a spinlock I guess is
that waiters can sleep rather than spin on contention (except
this down_spin guy, which sleeps).

Oh, I see from the context of Tony's message... so this can *only*
be used when preempt is off, and *only* against other down_spin
lockers.

Bad idea to be hack this into the semaphore code, IMO. It would
take how many lines to implement it properly?


struct {
  atomic_t cur;
  int max;
} ss_t;

void spin_init(ss_t *ss, int max)
{
	&ss->cur = ATOMIC_INIT(0);
	&ss->max = max;
}

void spin_take(ss_t *ss)
{
  preempt_disable();
  while (unlikely(!atomic_add_unless(&ss->cur, 1, &ss->max))) {
    while (atomic_read(&ss->cur) == ss->max)
      cpu_relax();
  }
}

void spin_put(ss_t *ss)
{
  smp_mb();
  atomic_dec(&ss->cur);
  preempt_enable();
}

About the same number as down_spin(). And it is much harder to
misuse. So LOC isn't such a great argument for this kind of thing.

My 2c

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
