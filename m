Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f43.google.com (mail-wm0-f43.google.com [74.125.82.43])
	by kanga.kvack.org (Postfix) with ESMTP id 417C56B0009
	for <linux-mm@kvack.org>; Tue, 23 Feb 2016 18:41:02 -0500 (EST)
Received: by mail-wm0-f43.google.com with SMTP id g62so246979010wme.1
        for <linux-mm@kvack.org>; Tue, 23 Feb 2016 15:41:02 -0800 (PST)
Received: from mail-wm0-x22c.google.com (mail-wm0-x22c.google.com. [2a00:1450:400c:c09::22c])
        by mx.google.com with ESMTPS id vh4si250108wjc.49.2016.02.23.15.41.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Feb 2016 15:41:01 -0800 (PST)
Received: by mail-wm0-x22c.google.com with SMTP id g62so222491304wme.0
        for <linux-mm@kvack.org>; Tue, 23 Feb 2016 15:41:01 -0800 (PST)
Message-ID: <56CCEE09.7070204@plexistor.com>
Date: Wed, 24 Feb 2016 01:40:57 +0200
From: Boaz Harrosh <boaz@plexistor.com>
MIME-Version: 1.0
Subject: Re: [RFC 0/2] New MAP_PMEM_AWARE mmap flag
References: <56C9EDCF.8010007@plexistor.com>	<CAPcyv4iqAXryz0-WAtvnYf6_Q=ha8F5b-fCUt7DDhYasX=YRUA@mail.gmail.com>	<56CA1CE7.6050309@plexistor.com>	<CAPcyv4hpxab=c1g83ARJvrnk_5HFkqS-t3sXpwaRBiXzehFwWQ@mail.gmail.com>	<56CA2AC9.7030905@plexistor.com>	<CAPcyv4gQV9Oh9OpHTGuGfTJ_s1C_L7J-VGyto3JMdAcgqyVeAw@mail.gmail.com>	<20160221223157.GC25832@dastard>	<x49fuwk7o8a.fsf@segfault.boston.devel.redhat.com>	<20160222174426.GA30110@infradead.org>	<257B23E37BCB93459F4D566B5EBAEAC550098A32@FMSMSX106.amr.corp.intel.com>	<20160223095225.GB32294@infradead.org>	<56CC686A.9040909@plexistor.com>	<CAPcyv4gTaikkXCG1fPBVT-0DE8Wst3icriUH5cbQH3thuEe-ow@mail.gmail.com>	<56CCD54C.3010600@plexistor.com>	<CAPcyv4iqO=Pzu_r8tV6K2G953c5HqJRdqCE1pymfDmURy8_ODw@mail.gmail.com>	<56CCE647.70408@plexistor.com> <CAPcyv4gLoQm818BzQSqkCbNPztr0JVihmvuhb=d-kSgbrmYFzQ@mail.gmail.com>
In-Reply-To: <CAPcyv4gLoQm818BzQSqkCbNPztr0JVihmvuhb=d-kSgbrmYFzQ@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Christoph Hellwig <hch@infradead.org>, "Rudoff, Andy" <andy.rudoff@intel.com>, Dave Chinner <david@fromorbit.com>, Jeff Moyer <jmoyer@redhat.com>, Arnd Bergmann <arnd@arndb.de>, linux-nvdimm <linux-nvdimm@ml01.01.org>, Oleg Nesterov <oleg@redhat.com>, linux-mm <linux-mm@kvack.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On 02/24/2016 01:23 AM, Dan Williams wrote:
> On Tue, Feb 23, 2016 at 3:07 PM, Boaz Harrosh <boaz@plexistor.com> wrote:
>> On 02/24/2016 12:33 AM, Dan Williams wrote:
> 
>>> The crux of the problem, in my opinion, is that we're asking for an "I
>>> know what I'm doing" flag, and I expect that's an impossible statement
>>> for a filesystem to trust generically.  If you can get MAP_PMEM_AWARE
>>> in, great, but I'm more and more of the opinion that the "I know what
>>> I'm doing" interface should be something separate from today's trusted
>>> filesystems.
>>>
>>
>> I disagree. I'm not saying any "trust me I know what I'm doing" flag.
>> the FS reveals nothing and trusts nothing.
>> All I'm saying is that the libc library I'm using as the new pmem_memecpy()
>> and I'm using that instead of the old memecpy(). So the FS does not need to
>> wipe my face after I eat. Failing to do so just means a bug in the application
> 
> "just means a bug in the application"
> 
> Who gets the bug report when an app gets its cache syncing wrong and
> data corruption ensues, and why isn't the fix for that bug that the
> filesystem simply stops trusting MAP_PMEM_AWARE and synching
> cachelines on behalf of the app when it calls sync as it must for
> metadata consistency.  Problem solved globally for all broken usages
> of MAP_PMEM_AWARE and the flag loses all meaning as a result.
> 

Because this will not fix the application's bugs. Because if the application
is broken then you do not know that this will fix it. It is broken it failed
to uphold the contract it had with the Kernel.

It is like saying lets call fsync on file close because broken apps keep
forgetting to call fsync(). And file close is called even if the app crashes.
Will Dave do that?

No if an app has a bug like this falling to call the proper pmem_xxx routine
in the proper work flow, it might has just forgotten to call fsync, or maybe
still modifying memory after fsync was called. And your babysitting the app
will not help.

> This is the takeaway I've internalized from Dave's pushback of these
> new mmap flags.
> 

We are already used to tell the firefox guys, you did not call fsync and
you lost data on a crash.

We will have a new mantra, "You did not use pmem_memcpy() but used MAP_PMEM_AWARE"
We have contracts like that between Kernel and apps all the time. I fail to see why
this one crossed the line for you?

Again the question is: Can an app do something so stupid that it can break other
apps?

Cheers
Boaz

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
