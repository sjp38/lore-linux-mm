Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 710CC6B0003
	for <linux-mm@kvack.org>; Fri, 22 Jun 2018 10:29:22 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id i12-v6so545418edq.15
        for <linux-mm@kvack.org>; Fri, 22 Jun 2018 07:29:22 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v8-v6si880486edi.315.2018.06.22.07.29.20
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 22 Jun 2018 07:29:20 -0700 (PDT)
Date: Fri, 22 Jun 2018 16:29:17 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [patch] mm, oom: fix unnecessary killing of additional processes
Message-ID: <20180622142917.GB10465@dhcp22.suse.cz>
References: <alpine.DEB.2.21.1805241422070.182300@chino.kir.corp.google.com>
 <alpine.DEB.2.21.1806141339580.4543@chino.kir.corp.google.com>
 <20180615065541.GA24039@dhcp22.suse.cz>
 <alpine.DEB.2.21.1806151559360.49038@chino.kir.corp.google.com>
 <20180619083316.GB13685@dhcp22.suse.cz>
 <20180620130311.GM13685@dhcp22.suse.cz>
 <alpine.DEB.2.21.1806201325330.158126@chino.kir.corp.google.com>
 <20180621074537.GC10465@dhcp22.suse.cz>
 <alpine.DEB.2.21.1806211347050.213939@chino.kir.corp.google.com>
 <20180622074257.GQ10465@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180622074257.GQ10465@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri 22-06-18 09:42:57, Michal Hocko wrote:
> On Thu 21-06-18 13:50:53, David Rientjes wrote:
> > On Thu, 21 Jun 2018, Michal Hocko wrote:
> > 
> > > > > diff --git a/arch/x86/kvm/x86.c b/arch/x86/kvm/x86.c
> > > > > index 6bcecc325e7e..ac08f5d711be 100644
> > > > > --- a/arch/x86/kvm/x86.c
> > > > > +++ b/arch/x86/kvm/x86.c
> > > > > @@ -7203,8 +7203,9 @@ static void vcpu_load_eoi_exitmap(struct kvm_vcpu *vcpu)
> > > > >  	kvm_x86_ops->load_eoi_exitmap(vcpu, eoi_exit_bitmap);
> > > > >  }
> > > > >  
> > > > > -void kvm_arch_mmu_notifier_invalidate_range(struct kvm *kvm,
> > > > > -		unsigned long start, unsigned long end)
> > > > > +int kvm_arch_mmu_notifier_invalidate_range(struct kvm *kvm,
> > > > > +		unsigned long start, unsigned long end,
> > > > > +		bool blockable)
> > > > >  {
> > > > >  	unsigned long apic_address;
> > > > >  
> > > > > @@ -7215,6 +7216,8 @@ void kvm_arch_mmu_notifier_invalidate_range(struct kvm *kvm,
> > > > >  	apic_address = gfn_to_hva(kvm, APIC_DEFAULT_PHYS_BASE >> PAGE_SHIFT);
> > > > >  	if (start <= apic_address && apic_address < end)
> > > > >  		kvm_make_all_cpus_request(kvm, KVM_REQ_APIC_PAGE_RELOAD);
> > > > > +
> > > > > +	return 0;
> > > > >  }
> > > > >  
> > > > >  void kvm_vcpu_reload_apic_access_page(struct kvm_vcpu *vcpu)
> > > > 
> > > > Auditing the first change in the patch, this is incorrect because 
> > > > kvm_make_all_cpus_request() for KVM_REQ_APIC_PAGE_RELOAD can block in 
> > > > kvm_kick_many_cpus() and that is after kvm_make_request() has been done.
> > > 
> > > I would have to check the code closer. But doesn't
> > > kvm_make_all_cpus_request call get_cpu which is preempt_disable? I
> > > definitely plan to talk to respective maintainers about these changes of
> > > course.
> > > 
> > 
> > preempt_disable() is required because it calls kvm_kick_many_cpus() with 
> > wait == true because KVM_REQ_APIC_PAGE_RELOAD sets KVM_REQUEST_WAIT and 
> > thus the smp_call_function_many() is going to block until all cpus can run 
> > ack_flush().
> 
> I will make sure to talk to the maintainer of the respective code to
> do the nonblock case correctly.

I've just double checked this particular code and the wait path and this
one is not a sleep. It is a busy wait for IPI to get handled. So this
one should be OK AFAICS. Anyway I will send an RFC and involve
respective maintainers to make sure I am not making any incorrect
assumptions.
-- 
Michal Hocko
SUSE Labs
