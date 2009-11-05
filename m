Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 1C0326B0044
	for <linux-mm@kvack.org>; Thu,  5 Nov 2009 03:22:58 -0500 (EST)
Message-ID: <4AF28B49.7000509@redhat.com>
Date: Thu, 05 Nov 2009 10:22:33 +0200
From: Avi Kivity <avi@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 02/11] Add "handle page fault" PV helper.
References: <1257076590-29559-1-git-send-email-gleb@redhat.com> <1257076590-29559-3-git-send-email-gleb@redhat.com> <20091102092214.GB8933@elte.hu> <4AEF2D0A.4070807@redhat.com> <4AEF3419.1050200@redhat.com> <4AEF6CC3.4000508@redhat.com> <4AEFB823.4040607@redhat.com> <0A882F4D99BBF6449D58E61AAFD7EDD6339E7098@pdsmsx502.ccr.corp.intel.com>
In-Reply-To: <0A882F4D99BBF6449D58E61AAFD7EDD6339E7098@pdsmsx502.ccr.corp.intel.com>
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: "Tian, Kevin" <kevin.tian@intel.com>
Cc: Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@elte.hu>, Gleb Natapov <gleb@redhat.com>, "kvm@vger.kernel.org" <kvm@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>
List-ID: <linux-mm.kvack.org>

On 11/05/2009 08:44 AM, Tian, Kevin wrote:
>> From: Avi Kivity
>> Sent: 2009Ae11OA3EO 12:57
>>
>> On 11/03/2009 01:35 AM, Rik van Riel wrote:
>>     
>>>> We can't add an exception vector since all the existing 
>>>>         
>> ones are either
>>     
>>>> taken or reserved.
>>>>         
>>>
>>> I believe some are reserved for operating system use.
>>>       
>> Table 6-1 says:
>>
>>   9 |  | Coprocessor Segment Overrun (reserved)  |  Fault |  No  | 
>> Floating-point instruction.2
>>   15 |  !a |  (Intel reserved. Do not use.) |   | No |
>>   20-31 |  !a | Intel reserved. Do not use.  |
>>   32-255 |  !a  | User Defined (Non-reserved) Interrupts |  Interrupt  
>> |   | External interrupt or INT n instruction.
>>
>> So we can only use 32-255, but these are not fault-like 
>> exceptions that 
>> can be delivered with interrupts disabled.
>>
>>     
> would you really want to inject a fault-like exception here? Fault
> is architurally synchronous event while here apf is more like an 
> asynchronous interrupt as it's not caused by guest itself. If 
> guest is with interrupt disabled, preemption won't happen and 
> apf path just ends up "wait for page" hypercall to waste cycles.
>   

An async page fault is, despite its name, synchronous, since it is
associated with an instruction. It must either be delivered immediately
or not at all.

It's true that in kernel mode you can't do much with an apf if
interrupts are disabled, but you still want to receive apfs for user
mode with interrupts disabled (for example due to interrupt shadow).

-- 
error compiling committee.c: too many arguments to function

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
