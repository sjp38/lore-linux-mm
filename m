Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id D6D226008C6
	for <linux-mm@kvack.org>; Tue, 24 Aug 2010 05:04:47 -0400 (EDT)
Message-ID: <4C738B23.6040205@redhat.com>
Date: Tue, 24 Aug 2010 12:04:35 +0300
From: Avi Kivity <avi@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH v5 08/12] Inject asynchronous page fault into a guest
 if page is swapped out.
References: <1279553462-7036-1-git-send-email-gleb@redhat.com> <1279553462-7036-9-git-send-email-gleb@redhat.com> <4C729F10.40005@redhat.com> <20100824075258.GX10499@redhat.com>
In-Reply-To: <20100824075258.GX10499@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Gleb Natapov <gleb@redhat.com>
Cc: kvm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mingo@elte.hu, a.p.zijlstra@chello.nl, tglx@linutronix.de, hpa@zytor.com, riel@redhat.com, cl@linux-foundation.org, mtosatti@redhat.com
List-ID: <linux-mm.kvack.org>

  On 08/24/2010 10:52 AM, Gleb Natapov wrote:
>> This nice cache needs to be outside apf to reduce complexity for
>> reviewers and since it is useful for others.
>>
>> Would be good to have memslot-cached kvm_put_guest() and kvm_get_guest().
> Will look into it.

In the meantime, you can just drop the caching.


>>> +		       struct kvm_arch_async_pf *arch)
>>> +{
>>> +	struct kvm_async_pf *work;
>>> +
>>> +	if (vcpu->async_pf_queued>= ASYNC_PF_PER_VCPU)
>>> +		return 0;
>> 100 == too high.  At 16 vcpus, this allows 1600 kernel threads to
>> wait for I/O.
> Number of kernel threads are limited by other means. Slow work subsystem
> has its own knobs to tune that. Here we limit how much slow work items
> can be queued per vcpu.

OK.

>> Would have been best if we could ask for a page to be paged in
>> asynchronously.
>>
> You mean to have core kernel facility for that? I agree it would be
> nice, but much harder.

Yes, that's what I meant.

-- 
error compiling committee.c: too many arguments to function

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
