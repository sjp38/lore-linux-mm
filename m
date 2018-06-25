Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 92BAB6B000E
	for <linux-mm@kvack.org>; Mon, 25 Jun 2018 04:10:23 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id j8-v6so8622671wrh.18
        for <linux-mm@kvack.org>; Mon, 25 Jun 2018 01:10:23 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x67-v6sor2175516wma.82.2018.06.25.01.10.22
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 25 Jun 2018 01:10:22 -0700 (PDT)
Subject: Re: [RFC PATCH] mm, oom: distinguish blockable mode for mmu notifiers
References: <20180622150242.16558-1-mhocko@kernel.org>
 <d617fc1d-28a7-3441-7465-bedf4dc69976@redhat.com>
 <20180625075715.GA28965@dhcp22.suse.cz>
From: Paolo Bonzini <pbonzini@redhat.com>
Message-ID: <e7f3289e-3ee3-3f02-1947-9e4327e1a864@redhat.com>
Date: Mon, 25 Jun 2018 10:10:18 +0200
MIME-Version: 1.0
In-Reply-To: <20180625075715.GA28965@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: LKML <linux-kernel@vger.kernel.org>, kvm@vger.kernel.org, =?UTF-8?B?UmFkaW0gS3LEjW3DocWZ?= <rkrcmar@redhat.com>, linux-mm@kvack.org, Andrea Arcangeli <aarcange@redhat.com>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>

On 25/06/2018 09:57, Michal Hocko wrote:
> On Sun 24-06-18 10:11:21, Paolo Bonzini wrote:
>> On 22/06/2018 17:02, Michal Hocko wrote:
>>> @@ -7215,6 +7216,8 @@ void kvm_arch_mmu_notifier_invalidate_range(struct kvm *kvm,
>>>  	apic_address = gfn_to_hva(kvm, APIC_DEFAULT_PHYS_BASE >> PAGE_SHIFT);
>>>  	if (start <= apic_address && apic_address < end)
>>>  		kvm_make_all_cpus_request(kvm, KVM_REQ_APIC_PAGE_RELOAD);
>>> +
>>> +	return 0;
>>
>> This is wrong, gfn_to_hva can sleep.
> 
> Hmm, I have tried to crawl the call chain and haven't found any
> sleepable locks taken. Maybe I am just missing something.
> __kvm_memslots has a complex locking assert. I do not see we would take
> slots_lock anywhere from the notifier call path. IIUC that means that
> users_count has to be zero at that time. I have no idea how that is
> guaranteed.

Nevermind, ENOCOFFEE.  This is gfn_to_hva, not gfn_to_pfn.  It only
needs SRCU.

Paolo
