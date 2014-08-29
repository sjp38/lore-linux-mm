Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f180.google.com (mail-ig0-f180.google.com [209.85.213.180])
	by kanga.kvack.org (Postfix) with ESMTP id CB1CD6B0035
	for <linux-mm@kvack.org>; Fri, 29 Aug 2014 16:44:43 -0400 (EDT)
Received: by mail-ig0-f180.google.com with SMTP id hn18so3216463igb.7
        for <linux-mm@kvack.org>; Fri, 29 Aug 2014 13:44:43 -0700 (PDT)
Received: from relay.sgi.com (relay2.sgi.com. [192.48.180.65])
        by mx.google.com with ESMTP id g5si114761igo.0.2014.08.29.13.44.42
        for <linux-mm@kvack.org>;
        Fri, 29 Aug 2014 13:44:43 -0700 (PDT)
Message-ID: <5400E62F.8000405@sgi.com>
Date: Fri, 29 Aug 2014 13:44:31 -0700
From: Mike Travis <travis@sgi.com>
MIME-Version: 1.0
Subject: Re: [PATCH 0/2] x86: Speed up ioremap operations
References: <20140829195328.511550688@asylum.americas.sgi.com> <20140829131602.72c422ebd2fd3fba426379e8@linux-foundation.org>
In-Reply-To: <20140829131602.72c422ebd2fd3fba426379e8@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: mingo@redhat.com, tglx@linutronix.de, hpa@zytor.com, msalter@redhat.com, dyoung@redhat.com, riel@redhat.com, peterz@infradead.org, mgorman@suse.de, linux-kernel@vger.kernel.org, x86@kernel.org, linux-mm@kvack.org, Alex Thorlton <athorlton@sgi.com>, Cliff Wickman <cpw@SGI.com>, Russ Anderson <rja@sgi.com>



On 8/29/2014 1:16 PM, Andrew Morton wrote:
> On Fri, 29 Aug 2014 14:53:28 -0500 Mike Travis <travis@sgi.com> wrote:
> 
>>
>> We have a large university system in the UK that is experiencing
>> very long delays modprobing the driver for a specific I/O device.
>> The delay is from 8-10 minutes per device and there are 31 devices
>> in the system.  This 4 to 5 hour delay in starting up those I/O
>> devices is very much a burden on the customer.
>>
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
>>
> 
> Really would prefer to have some quantitative testing results in here,
> as that is the entire point of the patchset.  And it leaves the reader
> wondering "how much of this severe problem remains?".

Okay, I have some results from testing.  The modprobe time appears to
be affected quite a bit by previous activity on the ioresource list,
which I suspect is due to cache preloading.  While the overall
improvement is impacted by other overhead of starting the devices,
this drastically improves the modprobe time.

Also our system is considerably smaller so the percentages gained
will not be the same.  Best case improvement with the modprobe
on our 20 device smallish system was from 'real    5m51.913s' to
'real    0m18.275s'.

> Also, the -stable backport is a big ask, isn't it?  It's arguably
> notabug and the affected number of machines is small.
> 

Ingo had suggested this.  We are definitely pushing it to our distro
suppliers for our customers.  Whether it's a big deal for smaller
systems is up in the air.  Note that the customer system has 31 devices
on an SSI that includes a large number of other IB and SAS devices
as well as a number of nodes which all which have discontiguous memory
segments.  I'm envisioning an ioresource list that numbers at least
several hundred entries.  While that's somewhat indicative of typical
UV systems it is generally not that common otherwise.

So I guess the -stable is merely a suggestion, not a request.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
