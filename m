Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 3D3B26B004D
	for <linux-mm@kvack.org>; Wed, 25 Nov 2009 07:45:56 -0500 (EST)
Message-ID: <4B0D26F4.5010407@redhat.com>
Date: Wed, 25 Nov 2009 14:45:40 +0200
From: Avi Kivity <avi@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 05/12] Handle asynchronous page fault in a PV guest.
References: <1258985167-29178-1-git-send-email-gleb@redhat.com> <1258985167-29178-6-git-send-email-gleb@redhat.com>
In-Reply-To: <1258985167-29178-6-git-send-email-gleb@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Gleb Natapov <gleb@redhat.com>
Cc: kvm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mingo@elte.hu, a.p.zijlstra@chello.nl, tglx@linutronix.de, hpa@zytor.com, riel@redhat.com
List-ID: <linux-mm.kvack.org>

On 11/23/2009 04:06 PM, Gleb Natapov wrote:
> Asynchronous page fault notifies vcpu that page it is trying to access
> is swapped out by a host. In response guest puts a task that caused the
> fault to sleep until page is swapped in again. When missing page is
> brought back into the memory guest is notified and task resumes execution.
>
> +
> +static void apf_task_wait(struct task_struct *tsk, u32 token)
> +{
> +	u32 key = hash_32(token, KVM_TASK_SLEEP_HASHBITS);
> +	struct kvm_task_sleep_head *b =&async_pf_sleepers[key];
> +	struct kvm_task_sleep_node n, *e;
> +	DEFINE_WAIT(wait);
> +
> +	spin_lock(&b->lock);
> +	e = _find_apf_task(b, token);
> +	if (e) {
> +		/* dummy entry exist ->  wake up was delivered ahead of PF */
> +		hlist_del(&e->link);
> +		kfree(e);
> +		spin_unlock(&b->lock);
> +		return;
> +	}
> +
> +	n.token = token;
> +	init_waitqueue_head(&n.wq);
> +	hlist_add_head(&n.link,&b->list);
> +	spin_unlock(&b->lock);
> +
> +	for (;;) {
> +		prepare_to_wait(&n.wq,&wait, TASK_UNINTERRUPTIBLE);
> +		if (hlist_unhashed(&n.link))
> +			break;
>    

This looks safe without b->lock, but please add a comment explaining why 
it is safe.

> +int kvm_handle_pf(struct pt_regs *regs, unsigned long error_code)
> +{
> +	u32 reason, token;
> +
> +	if (!per_cpu(apf_reason, smp_processor_id()).enabled)
> +		return 0;
> +
> +	reason = per_cpu(apf_reason, smp_processor_id()).reason;
> +	per_cpu(apf_reason, smp_processor_id()).reason = 0;
>    

Use __get_cpu_var(), shorter.

> @@ -270,11 +399,14 @@ static void __init kvm_smp_prepare_boot_cpu(void)
>
>   void __init kvm_guest_init(void)
>   {
> +	int i;
>    

\n

>   	if (!kvm_para_available())
>   		return;
>
>   	paravirt_ops_setup();
>   	register_reboot_notifier(&kvm_pv_reboot_nb);
> +	for (i = 0; i<  KVM_TASK_SLEEP_HASHSIZE; i++)
> +		spin_lock_init(&async_pf_sleepers[i].lock);
>   #ifdef CONFIG_SMP
>   	smp_ops.smp_prepare_boot_cpu = kvm_smp_prepare_boot_cpu;
>   #else
>    


-- 
error compiling committee.c: too many arguments to function

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
