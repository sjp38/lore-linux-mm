Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx116.postini.com [74.125.245.116])
	by kanga.kvack.org (Postfix) with SMTP id 081CC6B0027
	for <linux-mm@kvack.org>; Tue, 16 Apr 2013 14:08:37 -0400 (EDT)
Date: Tue, 16 Apr 2013 13:08:35 -0500
From: Robin Holt <holt@sgi.com>
Subject: Re: [PATCH] mm: mmu_notifier: re-fix freed page still mapped in
 secondary MMU
Message-ID: <20130416180835.GY3658@sgi.com>
References: <516CF235.4060103@linux.vnet.ibm.com>
 <20130416093131.GJ3658@sgi.com>
 <516D275C.8040406@linux.vnet.ibm.com>
 <20130416112553.GM3658@sgi.com>
 <20130416114322.GN3658@sgi.com>
 <516D4D08.9020602@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <516D4D08.9020602@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>
Cc: Robin Holt <holt@sgi.com>, Andrew Morton <akpm@linux-foundation.org>, Marcelo Tosatti <mtosatti@redhat.com>, Gleb Natapov <gleb@redhat.com>, Avi Kivity <avi.kivity@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, LKML <linux-kernel@vger.kernel.org>, KVM <kvm@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>

On Tue, Apr 16, 2013 at 09:07:20PM +0800, Xiao Guangrong wrote:
> On 04/16/2013 07:43 PM, Robin Holt wrote:
> > Argh.  Taking a step back helped clear my head.
> > 
> > For the -stable releases, I agree we should just go with your
> > revert-plus-hlist_del_init_rcu patch.  I will give it a test
> > when I am in the office.
> 
> Okay. Wait for your test report. Thank you in advance.
> 
> > 
> > For the v3.10 release, we should work on making this more
> > correct and completely documented.
> 
> Better document is always welcomed.
> 
> Double call ->release is not bad, like i mentioned it in the changelog:
> 
> it is really rare (e.g, can not happen on kvm since mmu-notify is unregistered
> after exit_mmap()) and the later call of multiple ->release should be
> fast since all the pages have already been released by the first call.
> 
> But, of course, it's great if you have a _light_ way to avoid this.

Getting my test environment set back up took longer than I would have liked.

Your patch passed.  I got no NULL-pointer derefs.

How would you feel about adding the following to your patch?

diff --git a/include/linux/mmu_notifier.h b/include/linux/mmu_notifier.h
index deca874..ff2fd5f 100644
--- a/include/linux/mmu_notifier.h
+++ b/include/linux/mmu_notifier.h
@@ -157,6 +157,7 @@ struct mmu_notifier_ops {
 struct mmu_notifier {
 	struct hlist_node hlist;
 	const struct mmu_notifier_ops *ops;
+	int released;
 };
 
 static inline int mm_has_notifiers(struct mm_struct *mm)
diff --git a/mm/mmu_notifier.c b/mm/mmu_notifier.c
index 606777a..949704b 100644
--- a/mm/mmu_notifier.c
+++ b/mm/mmu_notifier.c
@@ -44,7 +44,8 @@ void __mmu_notifier_release(struct mm_struct *mm)
 	 * ->release returns.
 	 */
 	id = srcu_read_lock(&srcu);
-	hlist_for_each_entry_rcu(mn, &mm->mmu_notifier_mm->list, hlist)
+	hlist_for_each_entry_rcu(mn, &mm->mmu_notifier_mm->list, hlist) {
+		int released;
 		/*
 		 * if ->release runs before mmu_notifier_unregister it
 		 * must be handled as it's the only way for the driver
@@ -52,8 +53,10 @@ void __mmu_notifier_release(struct mm_struct *mm)
 		 * from establishing any more sptes before all the
 		 * pages in the mm are freed.
 		 */
-		if (mn->ops->release)
+		released = xchg(&mn->released, 1);
+		if (mn->ops->release && !released)
 			mn->ops->release(mn, mm);
+	}
 	srcu_read_unlock(&srcu, id);
 
 	spin_lock(&mm->mmu_notifier_mm->lock);
@@ -214,6 +217,7 @@ static int do_mmu_notifier_register(struct mmu_notifier *mn,
 		mm->mmu_notifier_mm = mmu_notifier_mm;
 		mmu_notifier_mm = NULL;
 	}
+	mn->released = 0;
 	atomic_inc(&mm->mm_count);
 
 	/*
@@ -295,6 +299,7 @@ void mmu_notifier_unregister(struct mmu_notifier *mn, struct mm_struct *mm)
 		 * before freeing the pages.
 		 */
 		int id;
+		int released;
 
 		id = srcu_read_lock(&srcu);
 		/*
@@ -302,7 +307,8 @@ void mmu_notifier_unregister(struct mmu_notifier *mn, struct mm_struct *mm)
 		 * guarantee ->release is called before freeing the
 		 * pages.
 		 */
-		if (mn->ops->release)
+		released = xchg(&mn->released, 1);
+		if (mn->ops->release && !released)
 			mn->ops->release(mn, mm);
 		srcu_read_unlock(&srcu, id);
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
