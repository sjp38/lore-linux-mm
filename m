Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx157.postini.com [74.125.245.157])
	by kanga.kvack.org (Postfix) with SMTP id 04B1D6B008C
	for <linux-mm@kvack.org>; Wed,  8 May 2013 15:22:35 -0400 (EDT)
Date: Wed, 8 May 2013 12:22:34 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH RESEND] mm: mmu_notifier: re-fix freed page still mapped
 in secondary MMU
Message-Id: <20130508122234.096eac9f16bf5b3dcc0b33c6@linux-foundation.org>
In-Reply-To: <5187449A.1000202@linux.vnet.ibm.com>
References: <5187449A.1000202@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>
Cc: Robin Holt <holt@sgi.com>, stable@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Marcelo Tosatti <mtosatti@redhat.com>, Gleb Natapov <gleb@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>

On Mon, 06 May 2013 13:50:18 +0800 Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com> wrote:

> The commit 751efd8610d3 (mmu_notifier_unregister NULL Pointer deref
> and multiple ->release()) breaks the fix:
>     3ad3d901bbcfb15a5e4690e55350db0899095a68
>     (mm: mmu_notifier: fix freed page still mapped in secondary MMU)
> 
> Since hlist_for_each_entry_rcu() is changed now, we can not revert that patch
> directly, so this patch reverts the commit and simply fix the bug spotted
> by that patch
> 
> This bug spotted by commit 751efd8610d3 is:
> ======
> There is a race condition between mmu_notifier_unregister() and
> __mmu_notifier_release().
> 
> Assume two tasks, one calling mmu_notifier_unregister() as a result of a
> filp_close() ->flush() callout (task A), and the other calling
> mmu_notifier_release() from an mmput() (task B).
> 
>                     A                               B
> t1                                              srcu_read_lock()
> t2              if (!hlist_unhashed())
> t3                                              srcu_read_unlock()
> t4              srcu_read_lock()
> t5                                              hlist_del_init_rcu()
> t6                                              synchronize_srcu()
> t7              srcu_read_unlock()
> t8              hlist_del_rcu()  <--- NULL pointer deref.
> ======
> 
> This can be fixed by using hlist_del_init_rcu instead of hlist_del_rcu.
> 
> The another issue spotted in the commit is
> "multiple ->release() callouts", we needn't care it too much because
> it is really rare (e.g, can not happen on kvm since mmu-notify is unregistered
> after exit_mmap()) and the later call of multiple ->release should be
> fast since all the pages have already been released by the first call.
> Anyway, this issue should be fixed in a separate patch.

The 751efd8610d3 changelog failed to describe how these duplicated
->release calls can occur.  Races with concurrent notifier
registrations, I assume?

> -stable suggestions:
> Any version has commit 751efd8610d3 need to be backported. I find the oldest
> version has this commit is 3.0-stable.
> 
> ...
>
> Andrew, this patch has been tested by Robin and the test shows that the bug
> of "NULL Pointer deref" bas been fixed. However, we have the argument that
> whether the fix of "multiple ->release" should be merged into this patch.
> (This patch just do fix the bug of "NULL Pointer deref")
> 
> Your thought?

Insufficient information :(
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
