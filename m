Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 237516B0007
	for <linux-mm@kvack.org>; Thu, 21 Jun 2018 03:45:42 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id 76-v6so1321782wmw.3
        for <linux-mm@kvack.org>; Thu, 21 Jun 2018 00:45:42 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k91-v6si2250458edc.432.2018.06.21.00.45.40
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 21 Jun 2018 00:45:40 -0700 (PDT)
Date: Thu, 21 Jun 2018 09:45:37 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [patch] mm, oom: fix unnecessary killing of additional processes
Message-ID: <20180621074537.GC10465@dhcp22.suse.cz>
References: <alpine.DEB.2.21.1805241422070.182300@chino.kir.corp.google.com>
 <alpine.DEB.2.21.1806141339580.4543@chino.kir.corp.google.com>
 <20180615065541.GA24039@dhcp22.suse.cz>
 <alpine.DEB.2.21.1806151559360.49038@chino.kir.corp.google.com>
 <20180619083316.GB13685@dhcp22.suse.cz>
 <20180620130311.GM13685@dhcp22.suse.cz>
 <alpine.DEB.2.21.1806201325330.158126@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.21.1806201325330.158126@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed 20-06-18 13:34:52, David Rientjes wrote:
> On Wed, 20 Jun 2018, Michal Hocko wrote:
> 
> > On Tue 19-06-18 10:33:16, Michal Hocko wrote:
> > [...]
> > > As I've said, if you are not willing to work on a proper solution, I
> > > will, but my nack holds for this patch until we see no other way around
> > > existing and real world problems.
> > 
> > OK, so I gave it a quick try and it doesn't look all that bad to me.
> > This is only for blockable mmu notifiers.  I didn't really try to
> > address all the problems down the road - I mean some of the blocking
> > notifiers can check the range in their interval tree without blocking
> > locks. It is quite probable that only few ranges will be of interest,
> > right?
> > 
> > So this is only to give an idea about the change. It probably even
> > doesn't compile. Does that sound sane?
> 
> It depends on how invasive we want to make this, it should result in more 
> memory being freeable if the invalidate callbacks can guarantee that they 
> won't block.  I think it's much more invasive than the proposed patch, 
> however.

It is a larger patch for sure but it heads towards a more deterministic
behavior because we know _why_ we are trying. It is a specific and
rarely taken lock that we need. If we get one step further and examine
the range without blocking then we are almost lockless from the oom
reaper POV for most notifiers.

> For the same reason as the mm->mmap_sem backoff, however, this should 
> retry for a longer period of time than HZ.  If we can't grab mm->mmap_sem 
> the first five times with the trylock because of writer queueing, for 
> example, then we only have five attempts for each blockable mmu notifier 
> invalidate callback, and any of the numerous locks it can take to declare 
> it will not block.
> 
> Note that this doesn't solve the issue with setting MMF_OOM_SKIP too early 
> on processes with mm->mmap_sem contention or now invalidate callbacks that 
> will block; the decision that the mm cannot be reaped should come much 
> later.

I do not mind tuning the number of retries or the sleep duration. All
that based on real life examples.

I have asked about a specific mmap_sem contention case several times but
didn't get any answer yet.

> > diff --git a/arch/x86/kvm/x86.c b/arch/x86/kvm/x86.c
> > index 6bcecc325e7e..ac08f5d711be 100644
> > --- a/arch/x86/kvm/x86.c
> > +++ b/arch/x86/kvm/x86.c
> > @@ -7203,8 +7203,9 @@ static void vcpu_load_eoi_exitmap(struct kvm_vcpu *vcpu)
> >  	kvm_x86_ops->load_eoi_exitmap(vcpu, eoi_exit_bitmap);
> >  }
> >  
> > -void kvm_arch_mmu_notifier_invalidate_range(struct kvm *kvm,
> > -		unsigned long start, unsigned long end)
> > +int kvm_arch_mmu_notifier_invalidate_range(struct kvm *kvm,
> > +		unsigned long start, unsigned long end,
> > +		bool blockable)
> >  {
> >  	unsigned long apic_address;
> >  
> > @@ -7215,6 +7216,8 @@ void kvm_arch_mmu_notifier_invalidate_range(struct kvm *kvm,
> >  	apic_address = gfn_to_hva(kvm, APIC_DEFAULT_PHYS_BASE >> PAGE_SHIFT);
> >  	if (start <= apic_address && apic_address < end)
> >  		kvm_make_all_cpus_request(kvm, KVM_REQ_APIC_PAGE_RELOAD);
> > +
> > +	return 0;
> >  }
> >  
> >  void kvm_vcpu_reload_apic_access_page(struct kvm_vcpu *vcpu)
> 
> Auditing the first change in the patch, this is incorrect because 
> kvm_make_all_cpus_request() for KVM_REQ_APIC_PAGE_RELOAD can block in 
> kvm_kick_many_cpus() and that is after kvm_make_request() has been done.

I would have to check the code closer. But doesn't
kvm_make_all_cpus_request call get_cpu which is preempt_disable? I
definitely plan to talk to respective maintainers about these changes of
course.

-- 
Michal Hocko
SUSE Labs
