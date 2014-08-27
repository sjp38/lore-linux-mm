Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 6A6B26B0035
	for <linux-mm@kvack.org>; Wed, 27 Aug 2014 19:54:36 -0400 (EDT)
Received: by mail-pa0-f49.google.com with SMTP id kq14so82117pab.8
        for <linux-mm@kvack.org>; Wed, 27 Aug 2014 16:54:35 -0700 (PDT)
Received: from relay.sgi.com (relay1.sgi.com. [192.48.180.66])
        by mx.google.com with ESMTP id wc6si3266757pab.112.2014.08.27.16.54.34
        for <linux-mm@kvack.org>;
        Wed, 27 Aug 2014 16:54:35 -0700 (PDT)
Message-ID: <53FE6FAA.6010806@sgi.com>
Date: Wed, 27 Aug 2014 16:54:18 -0700
From: Mike Travis <travis@sgi.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/2] x86: Optimize resource lookups for ioremap
References: <20140827225927.364537333@asylum.americas.sgi.com>	<20140827225927.602319674@asylum.americas.sgi.com>	<20140827160515.c59f1c191fde5f788a7c42f6@linux-foundation.org>	<53FE6515.6050102@sgi.com>	<20140827161854.0619a04653b336d3adc755f3@linux-foundation.org>	<53FE68E4.4090902@sgi.com> <20140827163745.774e9b5c591e8f9cf7542a4d@linux-foundation.org>
In-Reply-To: <20140827163745.774e9b5c591e8f9cf7542a4d@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: mingo@redhat.com, tglx@linutronix.de, hpa@zytor.com, msalter@redhat.com, dyoung@redhat.com, riel@redhat.com, peterz@infradead.org, mgorman@suse.de, linux-kernel@vger.kernel.org, x86@kernel.org, linux-mm@kvack.org, Alex Thorlton <athorlton@sgi.com>



On 8/27/2014 4:37 PM, Andrew Morton wrote:
> On Wed, 27 Aug 2014 16:25:24 -0700 Mike Travis <travis@sgi.com> wrote:
> 
>>>
>>> <looks at the code>
>>>
>>> Doing strcmp("System RAM") is rather a hack.  Is there nothing in
>>> resource.flags which can be used?  Or added otherwise?
>>
>> I agree except this mimics the page_is_ram function:
>>
>>         while ((res.start < res.end) &&
>>                 (find_next_iomem_res(&res, "System RAM", true) >= 0)) {
> 
> Yeah.  Sigh.
> 
>> So it passes the same literal string which then find_next does the
>> same strcmp on it:
>>
>>                 if (p->flags != res->flags)
>>                         continue;
>>                 if (name && strcmp(p->name, name))
>>                         continue;
>>
>> I should add back in the check to insure name is not NULL.
> 
> If we're still at 1+ hours then little bodges like this are nowhere
> near sufficient and sterner stuff will be needed.
> 
> Do we actually need the test?  My googling turns up zero instances of
> anyone reporting the "ioremap on RAM pfn" warning.

We get them more than we like, mostly from 3rd party vendors, and
esp. those that merely port their windows drivers to linux.
> 
> Where's the rest of the time being spent?

This device has a huge internal memory and  many processing devices.
So it loads up an operating system and starts a bunch of pseudo network
connections through the PCI-e/driver interface.  It was hard to
determine what percentage the ioremap played in the overall starting
time (based on what info we were able to collect).  But the ioremap
was definitely the largest part of the 'modprobe' operation.  I think
realistically that's all we have control over.

(But as I mentioned, we are encouraging the vendor to look into starting
the devices in parallel.  The overlap will cut down the overall time by
quite a bit, being there are 31 devices.)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
