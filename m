Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx103.postini.com [74.125.245.103])
	by kanga.kvack.org (Postfix) with SMTP id B24B06B005D
	for <linux-mm@kvack.org>; Thu, 12 Jul 2012 14:09:41 -0400 (EDT)
Date: Thu, 12 Jul 2012 20:08:28 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 20/40] autonuma: alloc/free/init mm_autonuma
Message-ID: <20120712180828.GL20382@redhat.com>
References: <1340888180-15355-1-git-send-email-aarcange@redhat.com>
 <1340888180-15355-21-git-send-email-aarcange@redhat.com>
 <20120630051217.GG3975@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120630051217.GG3975@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konrad Rzeszutek Wilk <konrad@darnok.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Hillf Danton <dhillf@gmail.com>, Dan Smith <danms@us.ibm.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Srivatsa Vaddagiri <vatsa@linux.vnet.ibm.com>, Christoph Lameter <cl@linux.com>, Alex Shi <alex.shi@intel.com>, Mauricio Faria de Oliveira <mauricfo@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Don Morris <don.morris@hp.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>

On Sat, Jun 30, 2012 at 01:12:18AM -0400, Konrad Rzeszutek Wilk wrote:
> On Thu, Jun 28, 2012 at 02:56:00PM +0200, Andrea Arcangeli wrote:
> > This is where the mm_autonuma structure is being handled. Just like
> > sched_autonuma, this is only allocated at runtime if the hardware the
> > kernel is running on has been detected as NUMA. On not NUMA hardware
> 
> I think the correct wording is "non-NUMA", not "not NUMA".

That sounds far too easy to me, but I've no idea what's the right is here.

> > the memory cost is reduced to one pointer per mm.
> > 
> > To get rid of the pointer in the each mm, the kernel can be compiled
> > with CONFIG_AUTONUMA=n.
> > 
> > Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
> > ---
> >  kernel/fork.c |    7 +++++++
> >  1 files changed, 7 insertions(+), 0 deletions(-)
> > 
> > diff --git a/kernel/fork.c b/kernel/fork.c
> > index 0adbe09..3e5a0d9 100644
> > --- a/kernel/fork.c
> > +++ b/kernel/fork.c
> > @@ -527,6 +527,8 @@ static void mm_init_aio(struct mm_struct *mm)
> >  
> >  static struct mm_struct *mm_init(struct mm_struct *mm, struct task_struct *p)
> >  {
> > +	if (unlikely(alloc_mm_autonuma(mm)))
> > +		goto out_free_mm;
> 
> So reading that I would think that on non-NUMA machines this would fail
> (since there is nothing to allocate). But that is not the case
> (I hope!?) Perhaps just make the function not return any values?

It doesn't fail, it returns 0 on non-NUMA. It's identical to
alloc_task_autonuma, per prev email.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
