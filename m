Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx112.postini.com [74.125.245.112])
	by kanga.kvack.org (Postfix) with SMTP id 4D37F6B0006
	for <linux-mm@kvack.org>; Fri, 18 Jan 2013 10:14:32 -0500 (EST)
Date: Fri, 18 Jan 2013 09:14:30 -0600
From: Robin Holt <holt@sgi.com>
Subject: Re: [PATCH] [Patch] mmu_notifier_unregister NULL Pointer deref fix.
Message-ID: <20130118151430.GD3460@sgi.com>
References: <20130116210124.GB3460@sgi.com>
 <50F765CC.9040608@linux.vnet.ibm.com>
 <20130117111213.GM3438@sgi.com>
 <50F7EC6B.6030401@linux.vnet.ibm.com>
 <20130117134523.GN3438@sgi.com>
 <50F8B67F.4090901@linux.vnet.ibm.com>
 <20130118024856.GC3460@sgi.com>
 <50F8BBAA.1020904@linux.vnet.ibm.com>
 <20130118121439.GR3438@sgi.com>
 <50F94562.6010909@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <50F94562.6010909@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>
Cc: Robin Holt <holt@sgi.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Avi Kivity <avi@redhat.com>, Hugh Dickins <hughd@google.com>, Marcelo Tosatti <mtosatti@redhat.com>, Sagi Grimberg <sagig@mellanox.co.il>, Haggai Eran <haggaie@mellanox.com>

On Fri, Jan 18, 2013 at 08:51:46PM +0800, Xiao Guangrong wrote:
> On 01/18/2013 08:14 PM, Robin Holt wrote:
> > On Fri, Jan 18, 2013 at 11:04:10AM +0800, Xiao Guangrong wrote:
> >> On 01/18/2013 10:48 AM, Robin Holt wrote:
> >>> On Fri, Jan 18, 2013 at 10:42:07AM +0800, Xiao Guangrong wrote:
> >>>> On 01/17/2013 09:45 PM, Robin Holt wrote:
> >>>>> On Thu, Jan 17, 2013 at 08:19:55PM +0800, Xiao Guangrong wrote:
> >>>>>> On 01/17/2013 07:12 PM, Robin Holt wrote:
> >>>>>>> On Thu, Jan 17, 2013 at 10:45:32AM +0800, Xiao Guangrong wrote:
> >>>>>>>> On 01/17/2013 05:01 AM, Robin Holt wrote:
> >>>>>>>>>
> >>>>>>>>> There is a race condition between mmu_notifier_unregister() and
> >>>>>>>>> __mmu_notifier_release().
> >>>>>>>>>
> >>>>>>>>> Assume two tasks, one calling mmu_notifier_unregister() as a result
> >>>>>>>>> of a filp_close() ->flush() callout (task A), and the other calling
> >>>>>>>>> mmu_notifier_release() from an mmput() (task B).
> >>>>>>>>>
> >>>>>>>>>                 A                               B
> >>>>>>>>> t1                                              srcu_read_lock()
> >>>>>>>>> t2              if (!hlist_unhashed())
> >>>>>>>>> t3                                              srcu_read_unlock()
> >>>>>>>>> t4              srcu_read_lock()
> >>>>>>>>> t5                                              hlist_del_init_rcu()
> >>>>>>>>> t6                                              synchronize_srcu()
> >>>>>>>>> t7              srcu_read_unlock()
> >>>>>>>>> t8              hlist_del_rcu()  <--- NULL pointer deref.
> >>>>>>>>
> >>>>>>>> The detailed code here is:
> >>>>>>>> 	hlist_del_rcu(&mn->hlist);
> >>>>>>>>
> >>>>>>>> Can mn be NULL? I do not think so since mn is always the embedded struct
> >>>>>>>> of the caller, it be freed after calling mmu_notifier_unregister.
> >>>>>>>
> >>>>>>> If you look at __mmu_notifier_release() it is using hlist_del_init_rcu()
> >>>>>>> which will set the hlist->pprev to NULL.  When hlist_del_rcu() is called,
> >>>>>>> it attempts to update *hlist->pprev = hlist->next and that is where it
> >>>>>>> takes the NULL pointer deref.
> >>>>>>
> >>>>>> Yes, sorry for my careless. So, That can not be fixed by using
> >>>>>> hlist_del_init_rcu instead?
> >>>>>
> >>>>> The problem is the race described above.  Thread 'A' has checked to see
> >>>>> if n->pprev != NULL.  Based upon that, it did called the mn->release()
> >>>>> method.  While it was trying to call the release method, thread 'B' ended
> >>>>> up calling hlist_del_init_rcu() which set n->pprev = NULL.  Then thread
> >>>>> 'A' got to run again and now it tries to do the hlist_del_rcu() which, as
> >>>>> part of __hlist_del(), the pprev will be set to n->pprev (which is NULL)
> >>>>> and then *pprev = n->next; hits the NULL pointer deref hits.
> >>>>
> >>>> I mean using hlist_del_init_rcu instead of hlist_del_rcu in
> >>>> mmu_notifier_unregister(), hlist_del_init_rcu is aware of ->pprev.
> >>>
> >>> How does that address the calling of the ->release() method twice?
> >>
> >> Hmm, what is the problem of it? If it is just for "performance issue", i think
> >> it is not worth introducing so complex lock rule just for the really rare case.
> > 
> > Complex lock rule?  We merely moved the lock up earlier in code path.
> > Without this, we have some cases where you get called on ->release()
> > twice, while the majority of cases your notifier gets called once and
> > it hits a NULL pointer deref at that.  What is so complex about that?
> 
> 
> Aha, if we use hlist_del_init_rcu() instead of hlist_del_rcu, can the NULL deref
> bug be fixed?
> 
> - If yes, you'd better make it as a simple patch, it is good for backport. Then
>   make the second patch to fix the "problem" of calling ->release twice.
> 
> - if no. Could you please detail the changelog. From the changelog, i only see
>   the bug is cased by calling hlist_del_rcu on the unhashed node.

What is it about this patch makes you think it is complex?  There are:

1) 11 Lines relocated.
2) 5 new lines added (4 four an optimization, 1 for "else" case).
3) 5 blank line introduced.
4) 1 comment line fixed.

I would happily remove the optimization which brings us down to an else
case.  That could be removed by introducing a temporary variable as well,
but that seems pointless.

Bottom line, I do not see how this patch, as-is or with some slight
tweaking, is not already candidate material for the -stable trees.
It is certainly not complex and significantly improves an inconsistency
with how the unregister notifier has worked for a few years.  It is a new
behavior which is contrary to the comments in mmu_notifier.h which says:

         * Called either by mmu_notifier_unregister or when the mm is
         * being destroyed by exit_mmap, always before all pages are
...
        void (*release)(struct mmu_notifier *mn,

That does not say "and/or", it says "or" which used to be "once and
only once", but is now "once, unless it is twice".  This new behavior
was affecting some of our test jobs, but the failures were so sporadic
that we were not making any progress on identifying the failures until we
stumbled on a test case which more frequently failed, then refined that
test to trigger easily.

My reluctance to not improving the double callout is I would need to repeat
a significant amount of testing to ensure the other problems are also
fixed with just the removal of the NULL pointer deref.  I believe they
are, but I am not certain.

Thanks,
Robin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
