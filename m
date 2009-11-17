Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id E417A6B004D
	for <linux-mm@kvack.org>; Tue, 17 Nov 2009 02:29:31 -0500 (EST)
Subject: Re: [MM] Make mm counters per cpu instead of atomic
From: "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>
In-Reply-To: <1258440521.11321.32.camel@localhost>
References: <alpine.DEB.1.10.0911041409020.7409@V090114053VZO-1>
	 <1258440521.11321.32.camel@localhost>
Content-Type: text/plain; charset="ISO-8859-1"
Date: Tue, 17 Nov 2009 15:31:41 +0800
Message-Id: <1258443101.11321.33.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "hugh.dickins@tiscali.co.uk" <hugh.dickins@tiscali.co.uk>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, Tejun Heo <tj@kernel.org>, Andi Kleen <andi@firstfloor.org>
List-ID: <linux-mm.kvack.org>

On Tue, 2009-11-17 at 14:48 +0800, Zhang, Yanmin wrote:
> On Wed, 2009-11-04 at 14:14 -0500, Christoph Lameter wrote:
> > From: Christoph Lameter <cl@linux-foundation.org>
> > Subject: Make mm counters per cpu
> > 
> > Changing the mm counters to per cpu counters is possible after the introduction
> > of the generic per cpu operations (currently in percpu and -next).
> > 
> > With that the contention on the counters in mm_struct can be avoided. The
> > USE_SPLIT_PTLOCKS case distinction can go away. Larger SMP systems do not
> > need to perform atomic updates to mm counters anymore. Various code paths
> > can be simplified since per cpu counter updates are fast and batching
> > of counter updates is no longer needed.
> > 
> > One price to pay for these improvements is the need to scan over all percpu
> > counters when the actual count values are needed.
> > 
> > Signed-off-by: Christoph Lameter <cl@linux-foundation.org>
> > 
> > ---
> >  fs/proc/task_mmu.c       |   14 +++++++++-
> >  include/linux/mm_types.h |   16 ++++--------
> >  include/linux/sched.h    |   61 ++++++++++++++++++++---------------------------
> >  kernel/fork.c            |   25 ++++++++++++++-----
> >  mm/filemap_xip.c         |    2 -
> >  mm/fremap.c              |    2 -
> >  mm/init-mm.c             |    3 ++
> >  mm/memory.c              |   20 +++++++--------
> >  mm/rmap.c                |   10 +++----
> >  mm/swapfile.c            |    2 -
> >  10 files changed, 84 insertions(+), 71 deletions(-)
> > 
> > Index: linux-2.6/include/linux/mm_types.h
> > ===================================================================
> > --- linux-2.6.orig/include/linux/mm_types.h	2009-11-04 13:08:33.000000000 -0600
> > +++ linux-2.6/include/linux/mm_types.h	2009-11-04 13:13:42.000000000 -0600
> > @@ -24,11 +24,10 @@ struct address_space;
> 
> > Index: linux-2.6/kernel/fork.c
> > ===================================================================
> > --- linux-2.6.orig/kernel/fork.c	2009-11-04 13:08:33.000000000 -0600
> > +++ linux-2.6/kernel/fork.c	2009-11-04 13:14:19.000000000 -0600
> > @@ -444,6 +444,8 @@ static void mm_init_aio(struct mm_struct
> > 
> >  static struct mm_struct * mm_init(struct mm_struct * mm, struct task_struct *p)
> >  {
> > +	int cpu;
> > +
> >  	atomic_set(&mm->mm_users, 1);
> >  	atomic_set(&mm->mm_count, 1);
> >  	init_rwsem(&mm->mmap_sem);
> > @@ -452,8 +454,11 @@ static struct mm_struct * mm_init(struct
> >  		(current->mm->flags & MMF_INIT_MASK) : default_dump_filter;
> >  	mm->core_state = NULL;
> >  	mm->nr_ptes = 0;
> > -	set_mm_counter(mm, file_rss, 0);
> > -	set_mm_counter(mm, anon_rss, 0);
> > +	for_each_possible_cpu(cpu) {
> > +		struct mm_counter *m;
> > +
> > +		memset(m, sizeof(struct mm_counter), 0);
> Above memset is wrong.
> 1) m isn't initiated;
> 2) It seems the 2nd and the 3rd parameters should be interchanged.
Changing it to below fixes the command hang issue.

        for_each_possible_cpu(cpu) {
                struct mm_counter *m = per_cpu(mm->rss->readers, cpu);

                memset(m, 0, sizeof(struct mm_counter));
        }


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
