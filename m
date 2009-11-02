Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 904526B0083
	for <linux-mm@kvack.org>; Mon,  2 Nov 2009 10:54:17 -0500 (EST)
Date: Mon, 2 Nov 2009 17:54:10 +0200
From: Gleb Natapov <gleb@redhat.com>
Subject: Re: [PATCH 03/11] Handle asynchronous page fault in a PV guest.
Message-ID: <20091102155410.GE27911@redhat.com>
References: <1257076590-29559-1-git-send-email-gleb@redhat.com>
 <1257076590-29559-4-git-send-email-gleb@redhat.com>
 <4AEED2C6.6030508@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4AEED2C6.6030508@redhat.com>
Sender: owner-linux-mm@kvack.org
To: Avi Kivity <avi@redhat.com>
Cc: kvm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, Nov 02, 2009 at 02:38:30PM +0200, Avi Kivity wrote:
> On 11/01/2009 01:56 PM, Gleb Natapov wrote:
> >Asynchronous page fault notifies vcpu that page it is trying to access
> >is swapped out by a host. In response guest puts a task that caused the
> >fault to sleep until page is swapped in again. When missing page is
> >brought back into the memory guest is notified and task resumes execution.
> >
> >diff --git a/arch/x86/include/asm/kvm_para.h b/arch/x86/include/asm/kvm_para.h
> >index 90708b7..61e2aa3 100644
> >--- a/arch/x86/include/asm/kvm_para.h
> >+++ b/arch/x86/include/asm/kvm_para.h
> >@@ -52,6 +52,9 @@ struct kvm_mmu_op_release_pt {
> >
> >  #define KVM_PV_SHM_FEATURES_ASYNC_PF		(1<<  0)
> >
> >+#define KVM_PV_REASON_PAGE_NP 1
> >+#define KVM_PV_REASON_PAGE_READY 2
> 
> _NOT_PRESENT would improve readability.
> 
> >+static void apf_task_wait(struct task_struct *tsk, u64 token)
> >  {
> >+	u64 key = hash_64(token, KVM_TASK_SLEEP_HASHBITS);
> >+	struct kvm_task_sleep_head *b =&async_pf_sleepers[key];
> >+	struct kvm_task_sleep_node n, *e;
> >+	DEFINE_WAIT(wait);
> >+
> >+	spin_lock(&b->lock);
> >+	e = _find_apf_task(b, token);
> >+	if (e) {
> >+		/* dummy entry exist ->  wake up was delivered ahead of PF */
> >+		hlist_del(&e->link);
> >+		kfree(e);
> >+		spin_unlock(&b->lock);
> >+		return;
> >+	}
> >+
> >+	n.token = token;
> >+	init_waitqueue_head(&n.wq);
> >+	hlist_add_head(&n.link,&b->list);
> >+	spin_unlock(&b->lock);
> >+
> >+	for (;;) {
> >+		prepare_to_wait(&n.wq,&wait, TASK_UNINTERRUPTIBLE);
> >+		if (hlist_unhashed(&n.link))
> >+			break;
> 
> Don't you need locking here?  At least for the implied memory barriers.
> 
May be memory barrier will be enough. Will look at it.

> >+		schedule();
> >+	}
> >+	finish_wait(&n.wq,&wait);
> >+
> >+	return;
> >+}
> >+
> >+static void apf_task_wake(u64 token)
> >+{
> >+	u64 key = hash_64(token, KVM_TASK_SLEEP_HASHBITS);
> >+	struct kvm_task_sleep_head *b =&async_pf_sleepers[key];
> >+	struct kvm_task_sleep_node *n;
> >+
> >+	spin_lock(&b->lock);
> >+	n = _find_apf_task(b, token);
> >+	if (!n) {
> >+		/* PF was not yet handled. Add dummy entry for the token */
> >+		n = kmalloc(sizeof(*n), GFP_ATOMIC);
> >+		if (!n) {
> >+			printk(KERN_EMERG"async PF can't allocate memory\n");
> 
> Worrying.  We could have an emergency pool of one node per cpu, and
> disable apf if we use it until it's returned.  But that's a lot of
> complexity for an edge case, so a simpler solution would be welcome.
> 
Currently this code can't trigger since "wake up" is always sent on the
same vcpu as "not present", but I don't want this implementation detail
to be part of guest/host interface. Idea you've described can be easy
to implement. Will look into it.

> >+int kvm_handle_pf(struct pt_regs *regs, unsigned long error_code)
> >+{
> >+	u64 reason, token;
> >  	struct kvm_vcpu_pv_shm *pv_shm =
> >  		per_cpu(kvm_vcpu_pv_shm, smp_processor_id());
> >
> >  	if (!pv_shm)
> >-		return;
> >+		return 0;
> >+
> >+	reason = pv_shm->reason;
> >+	pv_shm->reason = 0;
> >+
> >+	token = pv_shm->param;
> >+
> >+	switch (reason) {
> >+	default:
> >+		return 0;
> >+	case KVM_PV_REASON_PAGE_NP:
> >+		/* real page is missing. */
> >+		apf_task_wait(current, token);
> >+		break;
> >+	case KVM_PV_REASON_PAGE_READY:
> >+		apf_task_wake(token);
> >+		break;
> >+	}
> 
> Ah, reason is not a bitmask but an enumerator.  __u32 is more
> friendly to i386 in that case.
> 
OK. Will need padding for 64 bit host case.

> Much of the code here is arch independent and would work well on
> non-x86 kvm ports.  But we can always lay the burden of moving it on
> the non-x86 maintainers.
> 
> -- 
> error compiling committee.c: too many arguments to function

--
			Gleb.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
