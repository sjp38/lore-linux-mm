Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id 3C49C6B0038
	for <linux-mm@kvack.org>; Wed, 14 Sep 2016 10:02:20 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id wk8so28384761pab.3
        for <linux-mm@kvack.org>; Wed, 14 Sep 2016 07:02:20 -0700 (PDT)
Received: from NAM03-BY2-obe.outbound.protection.outlook.com (mail-by2nam03on0089.outbound.protection.outlook.com. [104.47.42.89])
        by mx.google.com with ESMTPS id y23si13108107pff.12.2016.09.14.07.02.19
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 14 Sep 2016 07:02:19 -0700 (PDT)
Subject: Re: [RFC PATCH v2 18/20] x86/kvm: Enable Secure Memory Encryption of
 nested page tables
References: <20160822223529.29880.50884.stgit@tlendack-t1.amdoffice.net>
 <20160822223849.29880.35462.stgit@tlendack-t1.amdoffice.net>
 <20160912143555.26lxdu3lv3o5hjp7@pd.tnic>
From: Tom Lendacky <thomas.lendacky@amd.com>
Message-ID: <e163446f-52e6-ff52-0306-83b304173e44@amd.com>
Date: Wed, 14 Sep 2016 09:02:09 -0500
MIME-Version: 1.0
In-Reply-To: <20160912143555.26lxdu3lv3o5hjp7@pd.tnic>
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>
Cc: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org, =?UTF-8?B?UmFkaW0gS3LEjW3DocWZ?= <rkrcmar@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, Joerg Roedel <joro@8bytes.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Ingo Molnar <mingo@redhat.com>, Andy Lutomirski <luto@kernel.org>, "H. Peter
 Anvin" <hpa@zytor.com>, Paolo Bonzini <pbonzini@redhat.com>, Alexander Potapenko <glider@google.com>, Thomas Gleixner <tglx@linutronix.de>, Dmitry Vyukov <dvyukov@google.com>

On 09/12/2016 09:35 AM, Borislav Petkov wrote:
> On Mon, Aug 22, 2016 at 05:38:49PM -0500, Tom Lendacky wrote:
>> Update the KVM support to include the memory encryption mask when creating
>> and using nested page tables.
>>
>> Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
>> ---
>>  arch/x86/include/asm/kvm_host.h |    3 ++-
>>  arch/x86/kvm/mmu.c              |    8 ++++++--
>>  arch/x86/kvm/vmx.c              |    3 ++-
>>  arch/x86/kvm/x86.c              |    3 ++-
>>  4 files changed, 12 insertions(+), 5 deletions(-)
>>
>> diff --git a/arch/x86/include/asm/kvm_host.h b/arch/x86/include/asm/kvm_host.h
>> index 33ae3a4..c51c1cb 100644
>> --- a/arch/x86/include/asm/kvm_host.h
>> +++ b/arch/x86/include/asm/kvm_host.h
>> @@ -1039,7 +1039,8 @@ void kvm_mmu_setup(struct kvm_vcpu *vcpu);
>>  void kvm_mmu_init_vm(struct kvm *kvm);
>>  void kvm_mmu_uninit_vm(struct kvm *kvm);
>>  void kvm_mmu_set_mask_ptes(u64 user_mask, u64 accessed_mask,
>> -		u64 dirty_mask, u64 nx_mask, u64 x_mask, u64 p_mask);
>> +		u64 dirty_mask, u64 nx_mask, u64 x_mask, u64 p_mask,
>> +		u64 me_mask);
> 
> Why do you need a separate mask?
> 
> arch/x86/kvm/mmu.c::set_spte() ORs in shadow_present_mask
> unconditionally. So you can simply do:
> 
> 
> 	kvm_mmu_set_mask_ptes(PT_USER_MASK, PT_ACCESSED_MASK,
> 			      PT_DIRTY_MASK, PT64_NX_MASK, 0,
> 			      PT_PRESENT_MASK | sme_me_mask);
> 
> and have this change much simpler.

Just keeping in step with the way this is done for the other masks.
They each have a specific meaning so I was trying not to combine
them in case they may be used differently in the future.

> 
>>  void kvm_mmu_reset_context(struct kvm_vcpu *vcpu);
>>  void kvm_mmu_slot_remove_write_access(struct kvm *kvm,
>> diff --git a/arch/x86/kvm/mmu.c b/arch/x86/kvm/mmu.c
>> index 3d4cc8cc..a7040f4 100644
>> --- a/arch/x86/kvm/mmu.c
>> +++ b/arch/x86/kvm/mmu.c
>> @@ -122,7 +122,7 @@ module_param(dbg, bool, 0644);
>>  					    * PT32_LEVEL_BITS))) - 1))
>>  
>>  #define PT64_PERM_MASK (PT_PRESENT_MASK | PT_WRITABLE_MASK | shadow_user_mask \
>> -			| shadow_x_mask | shadow_nx_mask)
>> +			| shadow_x_mask | shadow_nx_mask | shadow_me_mask)
> 
> This would be sme_me_mask, of course, like with the baremetal masks.
> 
> Or am I missing something?

Given the current patch, this would be shadow_me_mask since that value
is set by the call to kvm_mmu_set_mask_ptes.

Thanks,
Tom

> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
