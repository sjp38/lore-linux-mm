Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx206.postini.com [74.125.245.206])
	by kanga.kvack.org (Postfix) with SMTP id 3DEC86B0069
	for <linux-mm@kvack.org>; Tue, 15 Jan 2013 11:29:58 -0500 (EST)
Date: Tue, 15 Jan 2013 10:29:56 -0600
From: Robin Holt <holt@sgi.com>
Subject: Question/problem with mmu_notifier_unregister.
Message-ID: <20130115162956.GH3438@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-mm@kvack.org

Andrea,

On a community or upcoming distro based kernel, I have one XPMEM test
which is failing.  The following patch (with lots of context) fixes it.
I do not yet understand the cause of the race condition.  I did hope it
would be obvious to you and save me the time of investigating further.

The first test finds mn->hlist is on the chain.  The new second test
does not.  I have verified that neither xpmem nor gru is calling to
unregister the same mmu_notifier twice.  It is very difficult to find the
problem as the test case requires a very long time to trip.  To increase
the likelihood, I run many copies in parallel.  Each is 2 processes each
with one pthread.  I run two per socket on an 8 core per socket system
with 256 socket system.  When one job hits the null pointer deref, I can
have many thousands of lines of debug before the other jobs stop running.
Each process has /dev/gru mapped into their address space.  They have
used xpmem to attach part of the address space of the other process.
The tasks are exiting at approximately the same time.  The race seems to
be with one pthread hitting the final mmput at about the same time as the
other task is getting into the filp_close->flush() callout.

I have a couple other things to work on today, and will likely try to
chase this failure more tomorrow.  With this patch, I have not been able
to trigger any other issues in many hours of testing.  The test likewise
runs for many hours on a RHEL 6.3 based system and a SLES11 SP2 based
system so it might have something to do with the change in srcu locking.

Thanks,
Robin Holt


diff --git a/mm/mmu_notifier.c b/mm/mmu_notifier.c
index 8a5ac8c..e2c9827 100644
--- a/mm/mmu_notifier.c
+++ b/mm/mmu_notifier.c
@@ -297,37 +299,38 @@ void mmu_notifier_unregister(struct mmu_notifier *mn, struct mm_struct *mm)
        if (!hlist_unhashed(&mn->hlist)) {
                /*
                 * SRCU here will force exit_mmap to wait ->release to finish
                 * before freeing the pages.
                 */
                int id;
 
                id = srcu_read_lock(&srcu);
                /*
                 * exit_mmap will block in mmu_notifier_release to
                 * guarantee ->release is called before freeing the
                 * pages.
                 */
                if (mn->ops->release)
                        mn->ops->release(mn, mm);
                srcu_read_unlock(&srcu, id);
 
                spin_lock(&mm->mmu_notifier_mm->lock);
-               hlist_del_rcu(&mn->hlist);
+               if (!hlist_unhashed(&mn->hlist))
+                       hlist_del_rcu(&mn->hlist);
                spin_unlock(&mm->mmu_notifier_mm->lock);
        }
 
        /*
         * Wait any running method to finish, of course including
         * ->release if it was run by mmu_notifier_relase instead of us.
         */
        synchronize_srcu(&srcu);
 
        BUG_ON(atomic_read(&mm->mm_count) <= 0);
 
        mmdrop(mm);
 }
 EXPORT_SYMBOL_GPL(mmu_notifier_unregister);
 
 static int __init mmu_notifier_init(void)
 {
        return init_srcu_struct(&srcu);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
