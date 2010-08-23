Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 87C036007EE
	for <linux-mm@kvack.org>; Mon, 23 Aug 2010 11:53:13 -0400 (EDT)
Message-ID: <4C729961.7070308@redhat.com>
Date: Mon, 23 Aug 2010 18:53:05 +0300
From: Avi Kivity <avi@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH v5 07/12] Maintain memslot version number
References: <1279553462-7036-1-git-send-email-gleb@redhat.com> <1279553462-7036-8-git-send-email-gleb@redhat.com>
In-Reply-To: <1279553462-7036-8-git-send-email-gleb@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Gleb Natapov <gleb@redhat.com>
Cc: kvm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mingo@elte.hu, a.p.zijlstra@chello.nl, tglx@linutronix.de, hpa@zytor.com, riel@redhat.com, cl@linux-foundation.org, mtosatti@redhat.com
List-ID: <linux-mm.kvack.org>

  On 07/19/2010 06:30 PM, Gleb Natapov wrote:
> Code that depends on particular memslot layout can track changes and
> adjust to new layout.
>
>
> diff --git a/include/linux/kvm_host.h b/include/linux/kvm_host.h
> index c13cc48..c74ffc0 100644
> --- a/include/linux/kvm_host.h
> +++ b/include/linux/kvm_host.h
> @@ -177,6 +177,7 @@ struct kvm {
>   	raw_spinlock_t requests_lock;
>   	struct mutex slots_lock;
>   	struct mm_struct *mm; /* userspace tied to this vm */
> +	u32 memslot_version;
>   	struct kvm_memslots *memslots;
>   	struct srcu_struct srcu;
>   #ifdef CONFIG_KVM_APIC_ARCHITECTURE
> diff --git a/virt/kvm/kvm_main.c b/virt/kvm/kvm_main.c
> index b78b794..292514c 100644
> --- a/virt/kvm/kvm_main.c
> +++ b/virt/kvm/kvm_main.c
> @@ -733,6 +733,7 @@ skip_lpage:
>   	slots->memslots[mem->slot] = new;
>   	old_memslots = kvm->memslots;
>   	rcu_assign_pointer(kvm->memslots, slots);
> +	kvm->memslot_version++;
>   	synchronize_srcu_expedited(&kvm->srcu);
>
>   	kvm_arch_commit_memory_region(kvm, mem, old, user_alloc);

How does this interact with rcu?  Nothing enforces consistency between 
rcu_dereference(kvm->memslots) and kvm->memslot_version.

Should probably be rcu_dereference(kvm->memslots)->version.

-- 
error compiling committee.c: too many arguments to function

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
