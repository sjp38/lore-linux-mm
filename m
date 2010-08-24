Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 53C776B01F0
	for <linux-mm@kvack.org>; Tue, 24 Aug 2010 08:32:52 -0400 (EDT)
Message-ID: <4C73BC02.7090606@redhat.com>
Date: Tue, 24 Aug 2010 15:33:06 +0300
From: Avi Kivity <avi@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH v5 08/12] Inject asynchronous page fault into a guest
 if page is swapped out.
References: <1279553462-7036-1-git-send-email-gleb@redhat.com> <1279553462-7036-9-git-send-email-gleb@redhat.com> <4C729F10.40005@redhat.com> <20100824122844.GA10499@redhat.com>
In-Reply-To: <20100824122844.GA10499@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Gleb Natapov <gleb@redhat.com>
Cc: kvm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mingo@elte.hu, a.p.zijlstra@chello.nl, tglx@linutronix.de, hpa@zytor.com, riel@redhat.com, cl@linux-foundation.org, mtosatti@redhat.com
List-ID: <linux-mm.kvack.org>

  On 08/24/2010 03:28 PM, Gleb Natapov wrote:
> On Mon, Aug 23, 2010 at 07:17:20PM +0300, Avi Kivity wrote:
>>> +static int apf_put_user(struct kvm_vcpu *vcpu, u32 val)
>>> +{
>>> +	if (unlikely(vcpu->arch.apf_memslot_ver !=
>>> +		     vcpu->kvm->memslot_version)) {
>>> +		u64 gpa = vcpu->arch.apf_msr_val&   ~0x3f;
>>> +		unsigned long addr;
>>> +		int offset = offset_in_page(gpa);
>>> +
>>> +		addr = gfn_to_hva(vcpu->kvm, gpa>>   PAGE_SHIFT);
>>> +		vcpu->arch.apf_data = (u32 __user *)(addr + offset);
>>> +		if (kvm_is_error_hva(addr)) {
>>> +			vcpu->arch.apf_data = NULL;
>>> +			return -EFAULT;
>>> +		}
>>> +	}
>>> +
>>> +	return put_user(val, vcpu->arch.apf_data);
>>> +}
>> This nice cache needs to be outside apf to reduce complexity for
>> reviewers and since it is useful for others.
>>
>> Would be good to have memslot-cached kvm_put_guest() and kvm_get_guest().
>>
> Something like this? (only compile tested)

Yes, exactly.

-- 
error compiling committee.c: too many arguments to function

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
