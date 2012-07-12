Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx199.postini.com [74.125.245.199])
	by kanga.kvack.org (Postfix) with SMTP id E80916B0068
	for <linux-mm@kvack.org>; Thu, 12 Jul 2012 14:27:56 -0400 (EDT)
Date: Thu, 12 Jul 2012 20:27:28 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 20/40] autonuma: alloc/free/init mm_autonuma
Message-ID: <20120712182728.GM20382@redhat.com>
References: <1340888180-15355-1-git-send-email-aarcange@redhat.com>
 <1340888180-15355-21-git-send-email-aarcange@redhat.com>
 <4FF06DBD.6020901@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4FF06DBD.6020901@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Hillf Danton <dhillf@gmail.com>, Dan Smith <danms@us.ibm.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Johannes Weiner <hannes@cmpxchg.org>, Srivatsa Vaddagiri <vatsa@linux.vnet.ibm.com>, Christoph Lameter <cl@linux.com>, Alex Shi <alex.shi@intel.com>, Mauricio Faria de Oliveira <mauricfo@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Don Morris <don.morris@hp.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>

Hi Rik,

On Sun, Jul 01, 2012 at 11:33:17AM -0400, Rik van Riel wrote:
> On 06/28/2012 08:56 AM, Andrea Arcangeli wrote:
> 
> > diff --git a/kernel/fork.c b/kernel/fork.c
> > index 0adbe09..3e5a0d9 100644
> > --- a/kernel/fork.c
> > +++ b/kernel/fork.c
> > @@ -527,6 +527,8 @@ static void mm_init_aio(struct mm_struct *mm)
> >
> >   static struct mm_struct *mm_init(struct mm_struct *mm, struct task_struct *p)
> >   {
> > +	if (unlikely(alloc_mm_autonuma(mm)))
> > +		goto out_free_mm;
> >   	atomic_set(&mm->mm_users, 1);
> >   	atomic_set(&mm->mm_count, 1);
> >   	init_rwsem(&mm->mmap_sem);
> 
> I wonder if it would be possible to defer the allocation
> of the mm_autonuma struct to knuma_scand, so short lived
> processes never have to allocate and free the mm_autonuma
> structure.
> 
> That way we only have a function call at exit time, and
> the branch inside kfree that checks for a null pointer.

It would be possible to convert them to prepare_mm/task_autonuma (the
mm side especially would be a branch once in a while) but it would
then become impossible to inherit the mm/task stats across
fork/clone. Right now the default is to reset them, but two sysfs
switches control that, and I wouldn't drop those until I've the time
to experiment how large kernel builds are affected by enabling the
stats inheritance. Right now kernel builds are unaffected because of
the default stat-resetting behavior and gcc too quick to be measured.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
