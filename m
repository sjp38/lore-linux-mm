Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f197.google.com (mail-ot0-f197.google.com [74.125.82.197])
	by kanga.kvack.org (Postfix) with ESMTP id 2EBA96B0033
	for <linux-mm@kvack.org>; Wed, 13 Dec 2017 10:08:22 -0500 (EST)
Received: by mail-ot0-f197.google.com with SMTP id r11so1342034ote.20
        for <linux-mm@kvack.org>; Wed, 13 Dec 2017 07:08:22 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id s188si581450oia.511.2017.12.13.07.08.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Dec 2017 07:08:15 -0800 (PST)
Subject: Re: pkeys: Support setting access rights for signal handlers
References: <5fee976a-42d4-d469-7058-b78ad8897219@redhat.com>
 <c034f693-95d1-65b8-2031-b969c2771fed@intel.com>
 <5965d682-61b2-d7da-c4d7-c223aa396fab@redhat.com>
 <aa4d127f-0315-3ac9-3fdf-1f0a89cf60b8@intel.com>
 <20171212231324.GE5460@ram.oc3035372033.ibm.com>
 <9dc13a32-b1a6-8462-7e19-cfcf9e2c151e@redhat.com>
 <20171213113544.GG5460@ram.oc3035372033.ibm.com>
From: Florian Weimer <fweimer@redhat.com>
Message-ID: <9f86d79e-165a-1b8e-32dd-7e4e8579da59@redhat.com>
Date: Wed, 13 Dec 2017 16:08:09 +0100
MIME-Version: 1.0
In-Reply-To: <20171213113544.GG5460@ram.oc3035372033.ibm.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ram Pai <linuxram@us.ibm.com>
Cc: Dave Hansen <dave.hansen@intel.com>, linux-mm <linux-mm@kvack.org>, x86@kernel.org, linux-arch <linux-arch@vger.kernel.org>, linux-x86_64@vger.kernel.org, Linux API <linux-api@vger.kernel.org>

On 12/13/2017 12:35 PM, Ram Pai wrote:
> On Wed, Dec 13, 2017 at 03:14:36AM +0100, Florian Weimer wrote:
>> On 12/13/2017 12:13 AM, Ram Pai wrote:
>>
>>> On POWER, the value of the pkey_read() i.e contents the AMR
>>> register(pkru equivalent), is always the same regardless of its
>>> context; signal handler or not.
>>>
>>> In other words, the permission of any allocated key will not
>>> reset in a signal handler context.
>>
>> That's certainly the simpler semantics, but I don't like how they
>> differ from x86.
>>
>> Is the AMR register reset to the original value upon (regular)
>> return from the signal handler?
> 
> The AMR bits are not touched upon (regular) return from the signal
> handler.
> 
> If the signal handler changes the bits in the AMR, they will continue
> to be so, even after return from the signal handler.
> 
> To illustrate with an example, lets say AMR value is 'x' and signal
> handler is invoked.  The value of AMR will be 'x' in the context of the
> signal handler.  On return from the signal handler the value of AMR will
> continue to be 'x'. However if signal handler changes the value of AMR
> to 'y', the value of AMR will be 'y' on return from the signal handler.

Okay, this model is really quite different from x86.  Is there a good 
reason for the difference?  Could we change the x86 implementation to 
behave in the same way?  Or alternatively, change the POWER 
implementation to match the existing x86 behavior?

>>> I was not aware that x86 would reset the key permissions in signal
>>> handler.  I think, the proposed behavior for PKEY_ALLOC_SETSIGNAL should
>>> actually be the default behavior.
>>
>> Note that PKEY_ALLOC_SETSIGNAL does something different: It requests
>> that the kernel sets the access rights for the key to the bits
>> specified at pkey_alloc time when the signal handler is invoked.  So
>> there is still a reset with PKEY_ALLOC_SETSIGNAL, but to a different
>> value.  It did not occur to me that it might be desirable to avoid
>> resetting the value on a per-key basis.
> 
> Ah. ok i see the subtle difference proposed by your semantics.
> 
> Will the following behavior work?
> 
> 'No bits will be reset to its initial value unless the key has been
> allocated with PKEY_ALLOC_*RE*SETSIGNAL flag'.

The existing x86 interface defaults to resetting the bits, 
unfortunately.  I'm not sure if we can or should change this now.

For my purposes, the POWER semantics would work fine as far as I can 
see.  The reset-to-default is really problematic.  I don't actually need 
the configurable behavior, but I implemented it this way to achieve a 
maximum of backwards compatibility.

Thanks,
Florian

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
