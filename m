Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 139A96B004D
	for <linux-mm@kvack.org>; Mon,  2 Nov 2009 02:07:25 -0500 (EST)
Date: Mon, 2 Nov 2009 09:07:20 +0200
From: Gleb Natapov <gleb@redhat.com>
Subject: Re: [PATCH 01/11] Add shared memory hypercall to PV Linux guest.
Message-ID: <20091102070720.GF29477@redhat.com>
References: <1257076590-29559-1-git-send-email-gleb@redhat.com>
 <1257076590-29559-2-git-send-email-gleb@redhat.com>
 <4AEE5FA3.1020104@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4AEE5FA3.1020104@redhat.com>
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: kvm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Sun, Nov 01, 2009 at 11:27:15PM -0500, Rik van Riel wrote:
> On 11/01/2009 06:56 AM, Gleb Natapov wrote:
> >Add hypercall that allows guest and host to setup per cpu shared
> >memory.
> 
> While it is pretty obvious that we should implement
> the asynchronous pagefaults for KVM, so a swap-in
> of a page the host swapped out does not stall the
> entire virtual CPU, I believe that adding extra
> data accesses at context switch time may not be
> the best tradeoff.
> 
> It may be better to simply tell the guest what
> address is faulting (or give the guest some other
> random unique number as a token).  Then, once the
> host brings that page into memory, we can send a
> signal to the guest with that same token.
> 
> The problem of finding the task(s) associated with
> that token can be left to the guest.  A little more
> complexity on the guest side, but probably worth it
> if we can avoid adding cost to the context switch
> path.
> 
This is precisely what this series implements. The function below
is leftover from previous implementation, not used by the rest of the
patch and removed by a later patch. Just a left over from rebase. Sorry
about that. Will be fixed for future submissions.

> >+static void kvm_end_context_switch(struct task_struct *next)
> >+{
> >+	struct kvm_vcpu_pv_shm *pv_shm =
> >+		per_cpu(kvm_vcpu_pv_shm, smp_processor_id());
> >+
> >+	if (!pv_shm)
> >+		return;
> >+
> >+	pv_shm->current_task = (u64)next;
> >+}
> >+
> 
> 
> 
> -- 
> All rights reversed.

--
			Gleb.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
