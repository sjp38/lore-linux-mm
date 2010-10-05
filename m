Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 3E0776B0071
	for <linux-mm@kvack.org>; Tue,  5 Oct 2010 15:53:40 -0400 (EDT)
Date: Tue, 5 Oct 2010 16:51:50 -0300
From: Marcelo Tosatti <mtosatti@redhat.com>
Subject: Re: [PATCH v6 10/12] Handle async PF in non preemptable context
Message-ID: <20101005195149.GC1786@amt.cnet>
References: <1286207794-16120-1-git-send-email-gleb@redhat.com>
 <1286207794-16120-11-git-send-email-gleb@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1286207794-16120-11-git-send-email-gleb@redhat.com>
Sender: owner-linux-mm@kvack.org
To: Gleb Natapov <gleb@redhat.com>
Cc: kvm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, avi@redhat.com, mingo@elte.hu, a.p.zijlstra@chello.nl, tglx@linutronix.de, hpa@zytor.com, riel@redhat.com, cl@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Mon, Oct 04, 2010 at 05:56:32PM +0200, Gleb Natapov wrote:
> If async page fault is received by idle task or when preemp_count is
> not zero guest cannot reschedule, so do sti; hlt and wait for page to be
> ready. vcpu can still process interrupts while it waits for the page to
> be ready.
> 
> Acked-by: Rik van Riel <riel@redhat.com>
> Signed-off-by: Gleb Natapov <gleb@redhat.com>
> ---
>  arch/x86/kernel/kvm.c |   40 ++++++++++++++++++++++++++++++++++------
>  1 files changed, 34 insertions(+), 6 deletions(-)
> 
> diff --git a/arch/x86/kernel/kvm.c b/arch/x86/kernel/kvm.c
> index 36fb3e4..f73946f 100644
> --- a/arch/x86/kernel/kvm.c
> +++ b/arch/x86/kernel/kvm.c
> @@ -37,6 +37,7 @@
>  #include <asm/cpu.h>
>  #include <asm/traps.h>
>  #include <asm/desc.h>
> +#include <asm/tlbflush.h>
>  
>  #define MMU_QUEUE_SIZE 1024
>  
> @@ -78,6 +79,8 @@ struct kvm_task_sleep_node {
>  	wait_queue_head_t wq;
>  	u32 token;
>  	int cpu;
> +	bool halted;
> +	struct mm_struct *mm;
>  };
>  
>  static struct kvm_task_sleep_head {
> @@ -106,6 +109,11 @@ void kvm_async_pf_task_wait(u32 token)
>  	struct kvm_task_sleep_head *b = &async_pf_sleepers[key];
>  	struct kvm_task_sleep_node n, *e;
>  	DEFINE_WAIT(wait);
> +	int cpu, idle;
> +
> +	cpu = get_cpu();
> +	idle = idle_cpu(cpu);
> +	put_cpu();
>  
>  	spin_lock(&b->lock);
>  	e = _find_apf_task(b, token);
> @@ -119,19 +127,33 @@ void kvm_async_pf_task_wait(u32 token)
>  
>  	n.token = token;
>  	n.cpu = smp_processor_id();
> +	n.mm = current->active_mm;
> +	n.halted = idle || preempt_count() > 1;
> +	atomic_inc(&n.mm->mm_count);

Can't see why this reference is needed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
