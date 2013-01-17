Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx205.postini.com [74.125.245.205])
	by kanga.kvack.org (Postfix) with SMTP id 984456B0069
	for <linux-mm@kvack.org>; Thu, 17 Jan 2013 06:12:15 -0500 (EST)
Date: Thu, 17 Jan 2013 05:12:13 -0600
From: Robin Holt <holt@sgi.com>
Subject: Re: [PATCH] [Patch] mmu_notifier_unregister NULL Pointer deref fix.
Message-ID: <20130117111213.GM3438@sgi.com>
References: <20130115162956.GH3438@sgi.com>
 <20130116200018.GA3460@sgi.com>
 <20130116210124.GB3460@sgi.com>
 <50F765CC.9040608@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <50F765CC.9040608@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>
Cc: Robin Holt <holt@sgi.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Avi Kivity <avi@redhat.com>, Hugh Dickins <hughd@google.com>, Marcelo Tosatti <mtosatti@redhat.com>, Sagi Grimberg <sagig@mellanox.co.il>, Haggai Eran <haggaie@mellanox.com>

On Thu, Jan 17, 2013 at 10:45:32AM +0800, Xiao Guangrong wrote:
> On 01/17/2013 05:01 AM, Robin Holt wrote:
> > 
> > There is a race condition between mmu_notifier_unregister() and
> > __mmu_notifier_release().
> > 
> > Assume two tasks, one calling mmu_notifier_unregister() as a result
> > of a filp_close() ->flush() callout (task A), and the other calling
> > mmu_notifier_release() from an mmput() (task B).
> > 
> >                 A                               B
> > t1                                              srcu_read_lock()
> > t2              if (!hlist_unhashed())
> > t3                                              srcu_read_unlock()
> > t4              srcu_read_lock()
> > t5                                              hlist_del_init_rcu()
> > t6                                              synchronize_srcu()
> > t7              srcu_read_unlock()
> > t8              hlist_del_rcu()  <--- NULL pointer deref.
> 
> The detailed code here is:
> 	hlist_del_rcu(&mn->hlist);
> 
> Can mn be NULL? I do not think so since mn is always the embedded struct
> of the caller, it be freed after calling mmu_notifier_unregister.

If you look at __mmu_notifier_release() it is using hlist_del_init_rcu()
which will set the hlist->pprev to NULL.  When hlist_del_rcu() is called,
it attempts to update *hlist->pprev = hlist->next and that is where it
takes the NULL pointer deref.

> 
> > 
> > Tested with this patch applied.  My test case which was failing
> > approximately every 300th iteration passed 25,000 tests.
> 
> Could you please share your test case?

I could but it would be very useless.  It depends upon having a SGI
UV system with GRUs and and xpmem kernel module loaded.  If you would
really like all the bits, I could provide them, but you will not be able
to reproduce the failure.

Thanks,
Robin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
