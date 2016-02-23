Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f179.google.com (mail-ob0-f179.google.com [209.85.214.179])
	by kanga.kvack.org (Postfix) with ESMTP id AFC0D828DF
	for <linux-mm@kvack.org>; Tue, 23 Feb 2016 17:34:00 -0500 (EST)
Received: by mail-ob0-f179.google.com with SMTP id gc3so393352obb.3
        for <linux-mm@kvack.org>; Tue, 23 Feb 2016 14:34:00 -0800 (PST)
Received: from mail-oi0-x234.google.com (mail-oi0-x234.google.com. [2607:f8b0:4003:c06::234])
        by mx.google.com with ESMTPS id h143si1430oib.22.2016.02.23.14.33.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Feb 2016 14:34:00 -0800 (PST)
Received: by mail-oi0-x234.google.com with SMTP id x21so346671oix.2
        for <linux-mm@kvack.org>; Tue, 23 Feb 2016 14:33:59 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <56CCD54C.3010600@plexistor.com>
References: <56C9EDCF.8010007@plexistor.com>
	<CAPcyv4iqAXryz0-WAtvnYf6_Q=ha8F5b-fCUt7DDhYasX=YRUA@mail.gmail.com>
	<56CA1CE7.6050309@plexistor.com>
	<CAPcyv4hpxab=c1g83ARJvrnk_5HFkqS-t3sXpwaRBiXzehFwWQ@mail.gmail.com>
	<56CA2AC9.7030905@plexistor.com>
	<CAPcyv4gQV9Oh9OpHTGuGfTJ_s1C_L7J-VGyto3JMdAcgqyVeAw@mail.gmail.com>
	<20160221223157.GC25832@dastard>
	<x49fuwk7o8a.fsf@segfault.boston.devel.redhat.com>
	<20160222174426.GA30110@infradead.org>
	<257B23E37BCB93459F4D566B5EBAEAC550098A32@FMSMSX106.amr.corp.intel.com>
	<20160223095225.GB32294@infradead.org>
	<56CC686A.9040909@plexistor.com>
	<CAPcyv4gTaikkXCG1fPBVT-0DE8Wst3icriUH5cbQH3thuEe-ow@mail.gmail.com>
	<56CCD54C.3010600@plexistor.com>
Date: Tue, 23 Feb 2016 14:33:59 -0800
Message-ID: <CAPcyv4iqO=Pzu_r8tV6K2G953c5HqJRdqCE1pymfDmURy8_ODw@mail.gmail.com>
Subject: Re: [RFC 0/2] New MAP_PMEM_AWARE mmap flag
From: Dan Williams <dan.j.williams@intel.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Boaz Harrosh <boaz@plexistor.com>
Cc: Christoph Hellwig <hch@infradead.org>, "Rudoff, Andy" <andy.rudoff@intel.com>, Dave Chinner <david@fromorbit.com>, Jeff Moyer <jmoyer@redhat.com>, Arnd Bergmann <arnd@arndb.de>, linux-nvdimm <linux-nvdimm@ml01.01.org>, Oleg Nesterov <oleg@redhat.com>, linux-mm <linux-mm@kvack.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On Tue, Feb 23, 2016 at 1:55 PM, Boaz Harrosh <boaz@plexistor.com> wrote:
[..]
> But seriously please explain the problem. I do not see one.
>
>> I think Christoph has already pointed out the roadmap.  Get the
>> existing crop of DAX bugs squashed
>
> Sure that's always true, I'm a stability freak through and through ask
> the guys who work with me. I like to sleep at night ;-)
>
>> and then *maybe* look at something
>> like a MAP_SYNC to opt-out of userspace needing to call *sync.
>>
>
> MAP_SYNC Is another novelty, which as Dave showed will not be implemented
> by such a legacy filesystem as xfs. any time soon. sync is needed not only
> for memory stores. For me this is a supper set of what I proposed. because
> again any file writes persistence is built of two parts durable data, and
> durable meta-data. My flag says, app takes care of data, then the other part
> can be done another way. For performance sake which is what I care about
> the heavy lifting is done at the data path. the meta data is marginal.
> If you want for completeness sake then fine have another flag.
>
> The new app written will need to do its new pmem_memcpy magic any way.
> then we are saying "do we need to call fsync() or not?"
>
> I hate it that you postpone that to never because it would be nice for
> philosophical sake to not have the app call sync at all. and all these
> years suffer the performance penalty. Instead of putting in a 10 liners
> patch today that has no risks, and yes forces new apps to keep the ugly
> fsync() call, but have the targeted performance today instead of *maybe* never.
>
> my path is a nice intermediate  progression to yours. Yours blocks my needs
> indefinitely?
>
>> [1]: 10.4.6.2 Caching of Temporal vs. Non-Temporal Data
>> "Some older CPU implementations (e.g., Pentium M) allowed addresses
>> being written with a non-temporal store instruction to be updated
>> in-place if the memory type was not WC and line was already in the
>> cache."
>>
>> I wouldn't be surprised if other architectures had similar constraints.
>>
>
> Perhaps you are looking at this from the wrong perspective. Pentium M
> can do this because the two cores shared the same cache. But we are talking
> about POSIX files semantics. Not CPU memory semantics. Some of our problems
> go away.
>
> Or am I missing something out and I'm completely clueless. Please explain
> slowly.
>

So I need to step back from the Pentium M example.  It's already a red
herring because, as Ross points out, prefetch concerns would require
that strawman application to be doing cache flushes itself.

Set that aside and sorry for that diversion.

In general MAP_SYNC, makes more sense semantic sense in that the
filesystem knows that the application is not going to be calling *sync
and it avoids triggering flushes for cachelines we don't care about.

Although if we had MAP_SYNC today we'd still be in the situation that
an app that fails to do its own cache flushes / bypass correctly gets
to keep the broken pieces.

The crux of the problem, in my opinion, is that we're asking for an "I
know what I'm doing" flag, and I expect that's an impossible statement
for a filesystem to trust generically.  If you can get MAP_PMEM_AWARE
in, great, but I'm more and more of the opinion that the "I know what
I'm doing" interface should be something separate from today's trusted
filesystems.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
