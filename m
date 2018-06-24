Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 0CEDA6B0003
	for <linux-mm@kvack.org>; Sun, 24 Jun 2018 04:11:25 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id i14-v6so7427327wrq.1
        for <linux-mm@kvack.org>; Sun, 24 Jun 2018 01:11:24 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id d17-v6sor1044655wrn.61.2018.06.24.01.11.23
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 24 Jun 2018 01:11:23 -0700 (PDT)
Subject: Re: [RFC PATCH] mm, oom: distinguish blockable mode for mmu notifiers
References: <20180622150242.16558-1-mhocko@kernel.org>
From: Paolo Bonzini <pbonzini@redhat.com>
Message-ID: <d617fc1d-28a7-3441-7465-bedf4dc69976@redhat.com>
Date: Sun, 24 Jun 2018 10:11:21 +0200
MIME-Version: 1.0
In-Reply-To: <20180622150242.16558-1-mhocko@kernel.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, LKML <linux-kernel@vger.kernel.org>
Cc: Michal Hocko <mhocko@suse.com>, kvm@vger.kernel.org, =?UTF-8?B?UmFkaW0gS3LEjW3DocWZ?= <rkrcmar@redhat.com>, linux-mm@kvack.org, Andrea Arcangeli <aarcange@redhat.com>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>

On 22/06/2018 17:02, Michal Hocko wrote:
> @@ -7215,6 +7216,8 @@ void kvm_arch_mmu_notifier_invalidate_range(struct kvm *kvm,
>  	apic_address = gfn_to_hva(kvm, APIC_DEFAULT_PHYS_BASE >> PAGE_SHIFT);
>  	if (start <= apic_address && apic_address < end)
>  		kvm_make_all_cpus_request(kvm, KVM_REQ_APIC_PAGE_RELOAD);
> +
> +	return 0;

This is wrong, gfn_to_hva can sleep.

You could do the the kvm_make_all_cpus_request unconditionally, but only
if !blockable is a really rare thing.  OOM would be fine, since the
request actually would never be processed, but I'm afraid of more uses
of !blockable being introduced later.

Thanks,

Paolo
