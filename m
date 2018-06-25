Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 9BEEF6B0006
	for <linux-mm@kvack.org>; Mon, 25 Jun 2018 03:57:21 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id r8-v6so4672886pgq.2
        for <linux-mm@kvack.org>; Mon, 25 Jun 2018 00:57:21 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h26-v6si13733693pfd.253.2018.06.25.00.57.19
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 25 Jun 2018 00:57:20 -0700 (PDT)
Date: Mon, 25 Jun 2018 09:57:15 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH] mm, oom: distinguish blockable mode for mmu notifiers
Message-ID: <20180625075715.GA28965@dhcp22.suse.cz>
References: <20180622150242.16558-1-mhocko@kernel.org>
 <d617fc1d-28a7-3441-7465-bedf4dc69976@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <d617fc1d-28a7-3441-7465-bedf4dc69976@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Paolo Bonzini <pbonzini@redhat.com>
Cc: LKML <linux-kernel@vger.kernel.org>, kvm@vger.kernel.org, Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, linux-mm@kvack.org, Andrea Arcangeli <aarcange@redhat.com>, =?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>

On Sun 24-06-18 10:11:21, Paolo Bonzini wrote:
> On 22/06/2018 17:02, Michal Hocko wrote:
> > @@ -7215,6 +7216,8 @@ void kvm_arch_mmu_notifier_invalidate_range(struct kvm *kvm,
> >  	apic_address = gfn_to_hva(kvm, APIC_DEFAULT_PHYS_BASE >> PAGE_SHIFT);
> >  	if (start <= apic_address && apic_address < end)
> >  		kvm_make_all_cpus_request(kvm, KVM_REQ_APIC_PAGE_RELOAD);
> > +
> > +	return 0;
> 
> This is wrong, gfn_to_hva can sleep.

Hmm, I have tried to crawl the call chain and haven't found any
sleepable locks taken. Maybe I am just missing something.
__kvm_memslots has a complex locking assert. I do not see we would take
slots_lock anywhere from the notifier call path. IIUC that means that
users_count has to be zero at that time. I have no idea how that is
guaranteed.
 
> You could do the the kvm_make_all_cpus_request unconditionally, but only
> if !blockable is a really rare thing.  OOM would be fine, since the
> request actually would never be processed, but I'm afraid of more uses
> of !blockable being introduced later.

Well, if this is not generally guaranteed then I have to come up with a
different flag. E.g. OOM_CONTEXT that would be more specific to
contrains for the callback.
-- 
Michal Hocko
SUSE Labs
