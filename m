Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id BA5266B0037
	for <linux-mm@kvack.org>; Wed, 27 Aug 2014 19:31:01 -0400 (EDT)
Received: by mail-pa0-f46.google.com with SMTP id eu11so12313pac.33
        for <linux-mm@kvack.org>; Wed, 27 Aug 2014 16:31:01 -0700 (PDT)
Received: from relay.sgi.com (relay1.sgi.com. [192.48.180.66])
        by mx.google.com with ESMTP id un9si2953027pac.207.2014.08.27.16.31.00
        for <linux-mm@kvack.org>;
        Wed, 27 Aug 2014 16:31:00 -0700 (PDT)
Message-ID: <53FE6A25.7020208@sgi.com>
Date: Wed, 27 Aug 2014 16:30:45 -0700
From: Mike Travis <travis@sgi.com>
MIME-Version: 1.0
Subject: Re: [PATCH 0/2] x86: Speed up ioremap operations
References: <20140827225927.364537333@asylum.americas.sgi.com>	<20140827160610.4ef142d28fd7f276efd38a51@linux-foundation.org>	<53FE6690.80608@sgi.com> <20140827162006.580e83d57696b5eba203b18c@linux-foundation.org>
In-Reply-To: <20140827162006.580e83d57696b5eba203b18c@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: mingo@redhat.com, tglx@linutronix.de, hpa@zytor.com, msalter@redhat.com, dyoung@redhat.com, riel@redhat.com, peterz@infradead.org, mgorman@suse.de, linux-kernel@vger.kernel.org, x86@kernel.org, linux-mm@kvack.org



On 8/27/2014 4:20 PM, Andrew Morton wrote:
> On Wed, 27 Aug 2014 16:15:28 -0700 Mike Travis <travis@sgi.com> wrote:
> 
>>
>>>
>>>> There are two causes for requiring a restart/reload of the drivers.
>>>> First is periodic preventive maintenance (PM) and the second is if
>>>> any of the devices experience a fatal error.  Both of these trigger
>>>> this excessively long delay in bringing the system back up to full
>>>> capability.
>>>>
>>>> The problem was tracked down to a very slow IOREMAP operation and
>>>> the excessively long ioresource lookup to insure that the user is
>>>> not attempting to ioremap RAM.  These patches provide a speed up
>>>> to that function.
>>>
>>> With what result?
>>>
>>
>> Early measurements on our in house lab system (with far fewer cpus
>> and memory) shows about a 60-75% increase.  They have a 31 devices,
>> 3000+ cpus, 10+Tb of memory.  We have 20 devices, 480 cpus, ~2Tb of
>> memory.  I expect their ioresource list to be about 5-10 times longer.
>> [But their system is in production so we have to wait for the next
>> scheduled PM interval before a live test can be done.]
> 
> So you expect 1+ hours?  That's still nuts.
> 

Actually I expect a lot better improvement.  We are removing cycles
through the I/O resource list and the longer the list, the longer
it takes to pass completely through it.  As mentioned for a 128M
I/O BAR region, that is 32 passes, so we are removing 31 of them.
31 times a list 5-10 times longer should be a much better overall
improvement in the ioremap time.  The startup time of the device
will still be there, though we are encouraging the vendor to look
at starting them up in parallel.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
