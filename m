Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f174.google.com (mail-ie0-f174.google.com [209.85.223.174])
	by kanga.kvack.org (Postfix) with ESMTP id 63ABE6B0037
	for <linux-mm@kvack.org>; Wed, 27 Aug 2014 19:15:43 -0400 (EDT)
Received: by mail-ie0-f174.google.com with SMTP id at20so203989iec.19
        for <linux-mm@kvack.org>; Wed, 27 Aug 2014 16:15:43 -0700 (PDT)
Received: from relay.sgi.com (relay1.sgi.com. [192.48.180.66])
        by mx.google.com with ESMTP id i8si7467725igh.54.2014.08.27.16.15.42
        for <linux-mm@kvack.org>;
        Wed, 27 Aug 2014 16:15:42 -0700 (PDT)
Message-ID: <53FE6690.80608@sgi.com>
Date: Wed, 27 Aug 2014 16:15:28 -0700
From: Mike Travis <travis@sgi.com>
MIME-Version: 1.0
Subject: Re: [PATCH 0/2] x86: Speed up ioremap operations
References: <20140827225927.364537333@asylum.americas.sgi.com> <20140827160610.4ef142d28fd7f276efd38a51@linux-foundation.org>
In-Reply-To: <20140827160610.4ef142d28fd7f276efd38a51@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: mingo@redhat.com, tglx@linutronix.de, hpa@zytor.com, msalter@redhat.com, dyoung@redhat.com, riel@redhat.com, peterz@infradead.org, mgorman@suse.de, linux-kernel@vger.kernel.org, x86@kernel.org, linux-mm@kvack.org



On 8/27/2014 4:06 PM, Andrew Morton wrote:
> On Wed, 27 Aug 2014 17:59:27 -0500 Mike Travis <travis@sgi.com> wrote:
> 
>>
>> We have a large university system in the UK that is experiencing
>> very long delays modprobing the driver for a specific I/O device.
>> The delay is from 8-10 minutes per device and there are 31 devices
>> in the system.  This 4 to 5 hour delay in starting up those I/O
>> devices is very much a burden on the customer.
> 
> That's nuts.

Exactly!  The customer was (as expected) not terribly pleased... :)
> 
>> There are two causes for requiring a restart/reload of the drivers.
>> First is periodic preventive maintenance (PM) and the second is if
>> any of the devices experience a fatal error.  Both of these trigger
>> this excessively long delay in bringing the system back up to full
>> capability.
>>
>> The problem was tracked down to a very slow IOREMAP operation and
>> the excessively long ioresource lookup to insure that the user is
>> not attempting to ioremap RAM.  These patches provide a speed up
>> to that function.
> 
> With what result?
> 

Early measurements on our in house lab system (with far fewer cpus
and memory) shows about a 60-75% increase.  They have a 31 devices,
3000+ cpus, 10+Tb of memory.  We have 20 devices, 480 cpus, ~2Tb of
memory.  I expect their ioresource list to be about 5-10 times longer.
[But their system is in production so we have to wait for the next
scheduled PM interval before a live test can be done.]

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
