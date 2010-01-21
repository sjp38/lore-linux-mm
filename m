Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 846FE6B00A3
	for <linux-mm@kvack.org>; Thu, 21 Jan 2010 04:02:58 -0500 (EST)
Message-ID: <4B58181B.60405@redhat.com>
Date: Thu, 21 Jan 2010 11:02:19 +0200
From: Avi Kivity <avi@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH v3 04/12] Add "handle page fault" PV helper.
References: <1262700774-1808-5-git-send-email-gleb@redhat.com> <1263490267.4244.340.camel@laptop> <20100117144411.GI31692@redhat.com> <4B541D08.9040802@zytor.com> <20100118085022.GA30698@redhat.com> <4B5510B1.9010202@zytor.com> <20100119065537.GF14345@redhat.com> <4B55E5D8.1070402@zytor.com> <20100119174438.GA19450@redhat.com> <4B5611A9.4050301@zytor.com> <20100120100254.GC5238@redhat.com> <4B5740CD.4020005@zytor.com>
In-Reply-To: <4B5740CD.4020005@zytor.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "H. Peter Anvin" <hpa@zytor.com>
Cc: Gleb Natapov <gleb@redhat.com>, Peter Zijlstra <peterz@infradead.org>, kvm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mingo@elte.hu, tglx@linutronix.de, riel@redhat.com, cl@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On 01/20/2010 07:43 PM, H. Peter Anvin wrote:
> On 01/20/2010 02:02 AM, Gleb Natapov wrote:
>>
>>> You can have the guest OS take an exception on a vector above 31 just
>>> fine; you just need it to tell the hypervisor which vector it, the OS,
>>> assigned for this purpose.
>>>
>> VMX doesn't allow to inject hardware exception with vector greater 
>> then 31.
>> SDM 3B section 23.2.1.3.
>>
>
> OK, you're right.  I had missed that... I presume it was done for 
> implementation reasons.

My expectation is that is was done for forward compatibility reasons.

>
>> I can inject the event as HW interrupt on vector greater then 32 but not
>> go through APIC so EOI will not be required. This sounds 
>> non-architectural
>> and I am not sure kernel has entry point code for this kind of event, it
>> has one for exception and one for interrupts that goes through 
>> __do_IRQ()
>> which assumes that interrupts should be ACKed.
>
> You can also just emulate the state transition -- since you know 
> you're dealing with a flat protected-mode or long-mode OS (and just 
> make that a condition of enabling the feature) you don't have to deal 
> with all the strange combinations of directions that an unrestricted 
> x86 event can take.  Since it's an exception, it is unconditional.

Do you mean create the stack frame manually?  I'd really like to avoid 
that for many reasons, one of which is performance (need to do all the 
virt-to-phys walks manually), the other is that we're certain to end up 
with something horribly underspecified.  I'd really like to keep as 
close as possible to the hardware.  For the alternative approach, see Xen.

-- 
error compiling committee.c: too many arguments to function

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
