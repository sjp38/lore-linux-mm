Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx149.postini.com [74.125.245.149])
	by kanga.kvack.org (Postfix) with SMTP id E09D56B0006
	for <linux-mm@kvack.org>; Fri, 18 Jan 2013 07:14:41 -0500 (EST)
Date: Fri, 18 Jan 2013 06:14:39 -0600
From: Robin Holt <holt@sgi.com>
Subject: Re: [PATCH] [Patch] mmu_notifier_unregister NULL Pointer deref fix.
Message-ID: <20130118121439.GR3438@sgi.com>
References: <20130115162956.GH3438@sgi.com>
 <20130116200018.GA3460@sgi.com>
 <20130116210124.GB3460@sgi.com>
 <50F765CC.9040608@linux.vnet.ibm.com>
 <20130117111213.GM3438@sgi.com>
 <50F7EC6B.6030401@linux.vnet.ibm.com>
 <20130117134523.GN3438@sgi.com>
 <50F8B67F.4090901@linux.vnet.ibm.com>
 <20130118024856.GC3460@sgi.com>
 <50F8BBAA.1020904@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <50F8BBAA.1020904@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>
Cc: Robin Holt <holt@sgi.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Avi Kivity <avi@redhat.com>, Hugh Dickins <hughd@google.com>, Marcelo Tosatti <mtosatti@redhat.com>, Sagi Grimberg <sagig@mellanox.co.il>, Haggai Eran <haggaie@mellanox.com>

On Fri, Jan 18, 2013 at 11:04:10AM +0800, Xiao Guangrong wrote:
> On 01/18/2013 10:48 AM, Robin Holt wrote:
> > On Fri, Jan 18, 2013 at 10:42:07AM +0800, Xiao Guangrong wrote:
> >> On 01/17/2013 09:45 PM, Robin Holt wrote:
> >>> On Thu, Jan 17, 2013 at 08:19:55PM +0800, Xiao Guangrong wrote:
> >>>> On 01/17/2013 07:12 PM, Robin Holt wrote:
> >>>>> On Thu, Jan 17, 2013 at 10:45:32AM +0800, Xiao Guangrong wrote:
> >>>>>> On 01/17/2013 05:01 AM, Robin Holt wrote:
> >>>>>>>
> >>>>>>> There is a race condition between mmu_notifier_unregister() and
> >>>>>>> __mmu_notifier_release().
> >>>>>>>
> >>>>>>> Assume two tasks, one calling mmu_notifier_unregister() as a result
> >>>>>>> of a filp_close() ->flush() callout (task A), and the other calling
> >>>>>>> mmu_notifier_release() from an mmput() (task B).
> >>>>>>>
> >>>>>>>                 A                               B
> >>>>>>> t1                                              srcu_read_lock()
> >>>>>>> t2              if (!hlist_unhashed())
> >>>>>>> t3                                              srcu_read_unlock()
> >>>>>>> t4              srcu_read_lock()
> >>>>>>> t5                                              hlist_del_init_rcu()
> >>>>>>> t6                                              synchronize_srcu()
> >>>>>>> t7              srcu_read_unlock()
> >>>>>>> t8              hlist_del_rcu()  <--- NULL pointer deref.
> >>>>>>
> >>>>>> The detailed code here is:
> >>>>>> 	hlist_del_rcu(&mn->hlist);
> >>>>>>
> >>>>>> Can mn be NULL? I do not think so since mn is always the embedded struct
> >>>>>> of the caller, it be freed after calling mmu_notifier_unregister.
> >>>>>
> >>>>> If you look at __mmu_notifier_release() it is using hlist_del_init_rcu()
> >>>>> which will set the hlist->pprev to NULL.  When hlist_del_rcu() is called,
> >>>>> it attempts to update *hlist->pprev = hlist->next and that is where it
> >>>>> takes the NULL pointer deref.
> >>>>
> >>>> Yes, sorry for my careless. So, That can not be fixed by using
> >>>> hlist_del_init_rcu instead?
> >>>
> >>> The problem is the race described above.  Thread 'A' has checked to see
> >>> if n->pprev != NULL.  Based upon that, it did called the mn->release()
> >>> method.  While it was trying to call the release method, thread 'B' ended
> >>> up calling hlist_del_init_rcu() which set n->pprev = NULL.  Then thread
> >>> 'A' got to run again and now it tries to do the hlist_del_rcu() which, as
> >>> part of __hlist_del(), the pprev will be set to n->pprev (which is NULL)
> >>> and then *pprev = n->next; hits the NULL pointer deref hits.
> >>
> >> I mean using hlist_del_init_rcu instead of hlist_del_rcu in
> >> mmu_notifier_unregister(), hlist_del_init_rcu is aware of ->pprev.
> > 
> > How does that address the calling of the ->release() method twice?
> 
> Hmm, what is the problem of it? If it is just for "performance issue", i think
> it is not worth introducing so complex lock rule just for the really rare case.

Complex lock rule?  We merely moved the lock up earlier in code path.
Without this, we have some cases where you get called on ->release()
twice, while the majority of cases your notifier gets called once and
it hits a NULL pointer deref at that.  What is so complex about that?

I originally was going to change both the __mmu_notifier_release()
function and the mmu_notifier_unregister() function to make the sequence,
lock, unlink, unlock, callout, but I thought that, although being more
correct, would get push back despite the fact that the lock is structure
local and likely to only be contended from two threads at the same time.

Thanks,
Robin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
