Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 5F2816B004A
	for <linux-mm@kvack.org>; Thu,  7 Oct 2010 14:03:52 -0400 (EDT)
Date: Thu, 7 Oct 2010 20:03:40 +0200
From: Gleb Natapov <gleb@redhat.com>
Subject: Re: [PATCH v6 08/12] Handle async PF in a guest.
Message-ID: <20101007180340.GI2397@redhat.com>
References: <1286207794-16120-1-git-send-email-gleb@redhat.com>
 <1286207794-16120-9-git-send-email-gleb@redhat.com>
 <4CADC6C3.3040305@redhat.com>
 <20101007171418.GA2397@redhat.com>
 <4CAE00CB.1070400@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4CAE00CB.1070400@redhat.com>
Sender: owner-linux-mm@kvack.org
To: Avi Kivity <avi@redhat.com>
Cc: kvm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mingo@elte.hu, a.p.zijlstra@chello.nl, tglx@linutronix.de, hpa@zytor.com, riel@redhat.com, cl@linux-foundation.org, mtosatti@redhat.com
List-ID: <linux-mm.kvack.org>

On Thu, Oct 07, 2010 at 07:18:03PM +0200, Avi Kivity wrote:
>  On 10/07/2010 07:14 PM, Gleb Natapov wrote:
> >On Thu, Oct 07, 2010 at 03:10:27PM +0200, Avi Kivity wrote:
> >>   On 10/04/2010 05:56 PM, Gleb Natapov wrote:
> >>  >When async PF capability is detected hook up special page fault handler
> >>  >that will handle async page fault events and bypass other page faults to
> >>  >regular page fault handler. Also add async PF handling to nested SVM
> >>  >emulation. Async PF always generates exit to L1 where vcpu thread will
> >>  >be scheduled out until page is available.
> >>  >
> >>
> >>  Please separate guest and host changes.
> >>
> >>  >+void kvm_async_pf_task_wait(u32 token)
> >>  >+{
> >>  >+	u32 key = hash_32(token, KVM_TASK_SLEEP_HASHBITS);
> >>  >+	struct kvm_task_sleep_head *b =&async_pf_sleepers[key];
> >>  >+	struct kvm_task_sleep_node n, *e;
> >>  >+	DEFINE_WAIT(wait);
> >>  >+
> >>  >+	spin_lock(&b->lock);
> >>  >+	e = _find_apf_task(b, token);
> >>  >+	if (e) {
> >>  >+		/* dummy entry exist ->   wake up was delivered ahead of PF */
> >>  >+		hlist_del(&e->link);
> >>  >+		kfree(e);
> >>  >+		spin_unlock(&b->lock);
> >>  >+		return;
> >>  >+	}
> >>  >+
> >>  >+	n.token = token;
> >>  >+	n.cpu = smp_processor_id();
> >>  >+	init_waitqueue_head(&n.wq);
> >>  >+	hlist_add_head(&n.link,&b->list);
> >>  >+	spin_unlock(&b->lock);
> >>  >+
> >>  >+	for (;;) {
> >>  >+		prepare_to_wait(&n.wq,&wait, TASK_UNINTERRUPTIBLE);
> >>  >+		if (hlist_unhashed(&n.link))
> >>  >+			break;
> >>  >+		local_irq_enable();
> >>
> >>  Suppose we take another apf here.  And another, and another (for
> >>  different pages, while executing schedule()).  What's to prevent
> >>  kernel stack overflow?
> >>
> >Host side keeps track of outstanding apfs and will not send apf for the
> >same phys address twice. It will halt vcpu instead.
> 
> What about different pages, running the scheduler code?
> 
We can get couple of nested apfs, just like we can get nested
interrupts. Since scheduler disables preemption second apf will halt.

> Oh, and we'll run the scheduler recursively.
> 
As rick said scheduler disables preemption.  And this is actually first
thing it does. Otherwise any interrupt may cause recursive scheduler
invocation.
 
--
			Gleb.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
