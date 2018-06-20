Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 4400B6B0003
	for <linux-mm@kvack.org>; Wed, 20 Jun 2018 16:34:56 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id w1-v6so396356plq.8
        for <linux-mm@kvack.org>; Wed, 20 Jun 2018 13:34:56 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m17-v6sor694178pgu.68.2018.06.20.13.34.54
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 20 Jun 2018 13:34:54 -0700 (PDT)
Date: Wed, 20 Jun 2018 13:34:52 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch] mm, oom: fix unnecessary killing of additional
 processes
In-Reply-To: <20180620130311.GM13685@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.21.1806201325330.158126@chino.kir.corp.google.com>
References: <alpine.DEB.2.21.1805241422070.182300@chino.kir.corp.google.com> <alpine.DEB.2.21.1806141339580.4543@chino.kir.corp.google.com> <20180615065541.GA24039@dhcp22.suse.cz> <alpine.DEB.2.21.1806151559360.49038@chino.kir.corp.google.com>
 <20180619083316.GB13685@dhcp22.suse.cz> <20180620130311.GM13685@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, 20 Jun 2018, Michal Hocko wrote:

> On Tue 19-06-18 10:33:16, Michal Hocko wrote:
> [...]
> > As I've said, if you are not willing to work on a proper solution, I
> > will, but my nack holds for this patch until we see no other way around
> > existing and real world problems.
> 
> OK, so I gave it a quick try and it doesn't look all that bad to me.
> This is only for blockable mmu notifiers.  I didn't really try to
> address all the problems down the road - I mean some of the blocking
> notifiers can check the range in their interval tree without blocking
> locks. It is quite probable that only few ranges will be of interest,
> right?
> 
> So this is only to give an idea about the change. It probably even
> doesn't compile. Does that sound sane?

It depends on how invasive we want to make this, it should result in more 
memory being freeable if the invalidate callbacks can guarantee that they 
won't block.  I think it's much more invasive than the proposed patch, 
however.

For the same reason as the mm->mmap_sem backoff, however, this should 
retry for a longer period of time than HZ.  If we can't grab mm->mmap_sem 
the first five times with the trylock because of writer queueing, for 
example, then we only have five attempts for each blockable mmu notifier 
invalidate callback, and any of the numerous locks it can take to declare 
it will not block.

Note that this doesn't solve the issue with setting MMF_OOM_SKIP too early 
on processes with mm->mmap_sem contention or now invalidate callbacks that 
will block; the decision that the mm cannot be reaped should come much 
later.

> diff --git a/arch/x86/kvm/x86.c b/arch/x86/kvm/x86.c
> index 6bcecc325e7e..ac08f5d711be 100644
> --- a/arch/x86/kvm/x86.c
> +++ b/arch/x86/kvm/x86.c
> @@ -7203,8 +7203,9 @@ static void vcpu_load_eoi_exitmap(struct kvm_vcpu *vcpu)
>  	kvm_x86_ops->load_eoi_exitmap(vcpu, eoi_exit_bitmap);
>  }
>  
> -void kvm_arch_mmu_notifier_invalidate_range(struct kvm *kvm,
> -		unsigned long start, unsigned long end)
> +int kvm_arch_mmu_notifier_invalidate_range(struct kvm *kvm,
> +		unsigned long start, unsigned long end,
> +		bool blockable)
>  {
>  	unsigned long apic_address;
>  
> @@ -7215,6 +7216,8 @@ void kvm_arch_mmu_notifier_invalidate_range(struct kvm *kvm,
>  	apic_address = gfn_to_hva(kvm, APIC_DEFAULT_PHYS_BASE >> PAGE_SHIFT);
>  	if (start <= apic_address && apic_address < end)
>  		kvm_make_all_cpus_request(kvm, KVM_REQ_APIC_PAGE_RELOAD);
> +
> +	return 0;
>  }
>  
>  void kvm_vcpu_reload_apic_access_page(struct kvm_vcpu *vcpu)

Auditing the first change in the patch, this is incorrect because 
kvm_make_all_cpus_request() for KVM_REQ_APIC_PAGE_RELOAD can block in 
kvm_kick_many_cpus() and that is after kvm_make_request() has been done.
