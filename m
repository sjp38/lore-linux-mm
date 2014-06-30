Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 659616B0031
	for <linux-mm@kvack.org>; Mon, 30 Jun 2014 04:57:21 -0400 (EDT)
Received: by mail-pa0-f46.google.com with SMTP id eu11so8214216pac.5
        for <linux-mm@kvack.org>; Mon, 30 Jun 2014 01:57:21 -0700 (PDT)
Received: from heian.cn.fujitsu.com ([59.151.112.132])
        by mx.google.com with ESMTP id lr7si22393600pab.151.2014.06.30.01.57.19
        for <linux-mm@kvack.org>;
        Mon, 30 Jun 2014 01:57:20 -0700 (PDT)
Message-ID: <53B126A2.30108@cn.fujitsu.com>
Date: Mon, 30 Jun 2014 16:58:10 +0800
From: Tang Chen <tangchen@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH 1/1] Move two pinned pages to non-movable node in
 kvm.
References: <20140618061230.GA10948@minantech.com> <53A136C4.5070206@cn.fujitsu.com> <20140619092031.GA429@minantech.com> <20140619190024.GA3887@amt.cnet> <20140620111509.GE20764@minantech.com> <20140620125326.GA22283@amt.cnet> <20140620142622.GA28698@minantech.com> <20140620203146.GA6580@amt.cnet> <20140620203903.GA7838@amt.cnet> <53B0C13C.20206@cn.fujitsu.com> <20140630060047.GI18167@minantech.com>
In-Reply-To: <20140630060047.GI18167@minantech.com>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gleb Natapov <gleb@kernel.org>
Cc: Marcelo Tosatti <mtosatti@redhat.com>, pbonzini@redhat.com, tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, mgorman@suse.de, yinghai@kernel.org, isimatu.yasuaki@jp.fujitsu.com, guz.fnst@cn.fujitsu.com, laijs@cn.fujitsu.com, kvm@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org, linux-kernel@vger.kernel.org, Avi Kivity <avi.kivity@gmail.com>, Tang Chen <tangchen@cn.fujitsu.com>

Hi Gleb,

On 06/30/2014 02:00 PM, Gleb Natapov wrote:
> On Mon, Jun 30, 2014 at 09:45:32AM +0800, Tang Chen wrote:
>> On 06/21/2014 04:39 AM, Marcelo Tosatti wrote:
>>> On Fri, Jun 20, 2014 at 05:31:46PM -0300, Marcelo Tosatti wrote:
>>>>> IIRC your shadow page pinning patch series support flushing of ptes
>>>>> by mmu notifier by forcing MMU reload and, as a result, faulting in of
>>>>> pinned pages during next entry.  Your patch series does not pin pages
>>>>> by elevating their page count.
>>>>
>>>> No but PEBS series does and its required to stop swap-out
>>>> of the page.
>>>
>>> Well actually no because of mmu notifiers.
>>>
>>> Tang, can you implement mmu notifiers for the other breaker of
>>> mem hotplug ?
>>
>> Hi Marcelo,
>>
>> I made a patch to update ept and apic pages when finding them in the
>> next ept violation. And I also updated the APIC_ACCESS_ADDR phys_addr.
>> The pages can be migrated, but the guest crached.
> How does it crash?

It just stopped running. The guest system is dead.
I'll try to debug it and give some more info.

>
>>
>> How do I stop guest from access apic pages in mmu_notifier when the
>> page migration starts ?  Do I need to stop all the vcpus by set vcpu
>> state to KVM_MP_STATE_HALTED ?  If so, the vcpu will not able to go
>> to the next ept violation.
> When apic access page is unmapped from ept pages by mmu notifiers you
> need to set its value in VMCS to a physical address that will never be
> mapped into guest memory. Zero for instance. You can do it by introducing
> new KVM_REQ_ bit and set VMCS value during next vcpu's vmentry. On ept
> violation you need to update VMCS pointer to newly allocated physical
> address, you can use the same KVM_REQ_ mechanism again.
>
>>
>> So, may I write any specific value into APIC_ACCESS_ADDR to stop guest
>> from access to apic page ?
>>
> Any phys address that will never be mapped into guest's memory should work.

Thanks for the advice. I'll try it.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
