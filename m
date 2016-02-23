Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f49.google.com (mail-qg0-f49.google.com [209.85.192.49])
	by kanga.kvack.org (Postfix) with ESMTP id D172C6B0005
	for <linux-mm@kvack.org>; Tue, 23 Feb 2016 09:22:20 -0500 (EST)
Received: by mail-qg0-f49.google.com with SMTP id b67so137090063qgb.1
        for <linux-mm@kvack.org>; Tue, 23 Feb 2016 06:22:20 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id s104si23166962qgd.51.2016.02.23.06.22.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Feb 2016 06:22:20 -0800 (PST)
From: Jeff Moyer <jmoyer@redhat.com>
Subject: Re: [RFC 0/2] New MAP_PMEM_AWARE mmap flag
References: <56C9EDCF.8010007@plexistor.com>
	<CAPcyv4iqAXryz0-WAtvnYf6_Q=ha8F5b-fCUt7DDhYasX=YRUA@mail.gmail.com>
	<56CA1CE7.6050309@plexistor.com>
	<CAPcyv4hpxab=c1g83ARJvrnk_5HFkqS-t3sXpwaRBiXzehFwWQ@mail.gmail.com>
	<56CA2AC9.7030905@plexistor.com>
	<CAPcyv4gQV9Oh9OpHTGuGfTJ_s1C_L7J-VGyto3JMdAcgqyVeAw@mail.gmail.com>
	<20160221223157.GC25832@dastard>
	<x49fuwk7o8a.fsf@segfault.boston.devel.redhat.com>
	<56CC63F2.3040503@plexistor.com>
Date: Tue, 23 Feb 2016 09:22:16 -0500
In-Reply-To: <56CC63F2.3040503@plexistor.com> (Boaz Harrosh's message of "Tue,
	23 Feb 2016 15:51:46 +0200")
Message-ID: <x49si0jcxrb.fsf@segfault.boston.devel.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Boaz Harrosh <boaz@plexistor.com>
Cc: Dave Chinner <david@fromorbit.com>, Arnd Bergmann <arnd@arndb.de>, linux-nvdimm <linux-nvdimm@ml01.01.org>, Oleg Nesterov <oleg@redhat.com>, linux-mm <linux-mm@kvack.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Boaz Harrosh <boaz@plexistor.com> writes:

>> An application creates a file and writes to every single block in the
>> thing, sync's it, closes it.  It then opens it back up, calls mmap with
>> this new MAP_DAX flag or on a file system mounted with -o dax, and
>> proceeds to access the file using loads and stores.  It persists its
>> data by using non-temporal stores, flushing and fencing cpu
>> instructions.
>> 
>> If I understand you correctly, you're saying that that application is
>> not written correctly, because it needs to call fsync to persist
>> metadata (that it presumably did not modify).  Is that right?
>> 
>
> Hi Jeff
>
> I do not understand why you chose to drop my email address from your
> reply? What do I need to feel when this happens?

Hi Boaz,

Sorry you were dropped, that was not my intention; I blame my mailer, as
I did hit reply-all.  No hard feelings?

> And to your questions above. As I answered to Dave.
> This is the novelty of my approach and the big difference between
> what you guys thought with MAP_DAX and my patches as submitted.
>  1. Application will/need to call m/fsync to let the FS the freedom it needs
>  2. The m/fsync as well as the page faults will be very light wait and fast,
>     all that is required from the pmem aware app is to do movnt stores and cl_flushes.

I like the approach for these existing file systems.

> So enjoying both worlds. And actually more:
> With your approach of fallocat(ing) the all space in advance you might as well
> just partition the storage and use the DAX(ed) block device. But with my
> approach you need not pre-allocate and enjoy the over provisioned model and
> the space allocation management of a modern FS. And even with all that still
> enjoy very fast direct mapped stores by not requiring the current slow m/fsync()

Well, that remains to be seen.  Certainly for O_DIRECT appends or hole
filling, there is extra overhead involved when compared to writes to
already-existing blocks.  Apply that to DAX and the overhead will be
much more prominent.  I'm not saying that this is definitely the case,
but I think it's something we'll have to measure going forward.

> I hope you guys stand behind me in my effort to accelerate userspace pmem apps
> and still not break any built in assumptions.

I do like the idea of reducing the msync/fsync overhead, though I admit
I haven't yet looked at the patches in any detail.  My mail in this
thread was primarily an attempt to wrap my head around why the fs needs
the fsync/msync at all.  I've got that cleared up now.

Cheers,
Jeff

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
