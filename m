Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id ECDAC6B006A
	for <linux-mm@kvack.org>; Sun,  1 Nov 2009 23:27:18 -0500 (EST)
Message-ID: <4AEE5FA3.1020104@redhat.com>
Date: Sun, 01 Nov 2009 23:27:15 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 01/11] Add shared memory hypercall to PV Linux guest.
References: <1257076590-29559-1-git-send-email-gleb@redhat.com> <1257076590-29559-2-git-send-email-gleb@redhat.com>
In-Reply-To: <1257076590-29559-2-git-send-email-gleb@redhat.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Gleb Natapov <gleb@redhat.com>
Cc: kvm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On 11/01/2009 06:56 AM, Gleb Natapov wrote:
> Add hypercall that allows guest and host to setup per cpu shared
> memory.

While it is pretty obvious that we should implement
the asynchronous pagefaults for KVM, so a swap-in
of a page the host swapped out does not stall the
entire virtual CPU, I believe that adding extra
data accesses at context switch time may not be
the best tradeoff.

It may be better to simply tell the guest what
address is faulting (or give the guest some other
random unique number as a token).  Then, once the
host brings that page into memory, we can send a
signal to the guest with that same token.

The problem of finding the task(s) associated with
that token can be left to the guest.  A little more
complexity on the guest side, but probably worth it
if we can avoid adding cost to the context switch
path.

> +static void kvm_end_context_switch(struct task_struct *next)
> +{
> +	struct kvm_vcpu_pv_shm *pv_shm =
> +		per_cpu(kvm_vcpu_pv_shm, smp_processor_id());
> +
> +	if (!pv_shm)
> +		return;
> +
> +	pv_shm->current_task = (u64)next;
> +}
> +



-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
