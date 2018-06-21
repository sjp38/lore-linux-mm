Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 31E3C6B0003
	for <linux-mm@kvack.org>; Thu, 21 Jun 2018 03:54:54 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id i2-v6so1685604wrm.5
        for <linux-mm@kvack.org>; Thu, 21 Jun 2018 00:54:54 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m28-v6si2241153eda.442.2018.06.21.00.54.52
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 21 Jun 2018 00:54:52 -0700 (PDT)
Date: Thu, 21 Jun 2018 09:54:51 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [patch] mm, oom: fix unnecessary killing of additional processes
Message-ID: <20180621075451.GD10465@dhcp22.suse.cz>
References: <alpine.DEB.2.21.1805241422070.182300@chino.kir.corp.google.com>
 <alpine.DEB.2.21.1806141339580.4543@chino.kir.corp.google.com>
 <20180615065541.GA24039@dhcp22.suse.cz>
 <alpine.DEB.2.21.1806151559360.49038@chino.kir.corp.google.com>
 <20180619083316.GB13685@dhcp22.suse.cz>
 <20180620130311.GM13685@dhcp22.suse.cz>
 <alpine.DEB.2.21.1806201325330.158126@chino.kir.corp.google.com>
 <20180621074537.GC10465@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180621074537.GC10465@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu 21-06-18 09:45:37, Michal Hocko wrote:
> On Wed 20-06-18 13:34:52, David Rientjes wrote:
> > On Wed, 20 Jun 2018, Michal Hocko wrote:
[...]
> > > diff --git a/arch/x86/kvm/x86.c b/arch/x86/kvm/x86.c
> > > index 6bcecc325e7e..ac08f5d711be 100644
> > > --- a/arch/x86/kvm/x86.c
> > > +++ b/arch/x86/kvm/x86.c
> > > @@ -7203,8 +7203,9 @@ static void vcpu_load_eoi_exitmap(struct kvm_vcpu *vcpu)
> > >  	kvm_x86_ops->load_eoi_exitmap(vcpu, eoi_exit_bitmap);
> > >  }
> > >  
> > > -void kvm_arch_mmu_notifier_invalidate_range(struct kvm *kvm,
> > > -		unsigned long start, unsigned long end)
> > > +int kvm_arch_mmu_notifier_invalidate_range(struct kvm *kvm,
> > > +		unsigned long start, unsigned long end,
> > > +		bool blockable)
> > >  {
> > >  	unsigned long apic_address;
> > >  
> > > @@ -7215,6 +7216,8 @@ void kvm_arch_mmu_notifier_invalidate_range(struct kvm *kvm,
> > >  	apic_address = gfn_to_hva(kvm, APIC_DEFAULT_PHYS_BASE >> PAGE_SHIFT);
> > >  	if (start <= apic_address && apic_address < end)
> > >  		kvm_make_all_cpus_request(kvm, KVM_REQ_APIC_PAGE_RELOAD);
> > > +
> > > +	return 0;
> > >  }
> > >  
> > >  void kvm_vcpu_reload_apic_access_page(struct kvm_vcpu *vcpu)
> > 
> > Auditing the first change in the patch, this is incorrect because 
> > kvm_make_all_cpus_request() for KVM_REQ_APIC_PAGE_RELOAD can block in 
> > kvm_kick_many_cpus() and that is after kvm_make_request() has been done.
> 
> I would have to check the code closer. But doesn't
> kvm_make_all_cpus_request call get_cpu which is preempt_disable?

Sorry I meant kvm_make_vcpus_request_mask. kvm_make_all_cpus_request
only does a GFP_ATOMIC allocation on top.
-- 
Michal Hocko
SUSE Labs
