Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f52.google.com (mail-qg0-f52.google.com [209.85.192.52])
	by kanga.kvack.org (Postfix) with ESMTP id B512F6B0009
	for <linux-mm@kvack.org>; Tue, 23 Feb 2016 18:28:52 -0500 (EST)
Received: by mail-qg0-f52.google.com with SMTP id b35so1415715qge.0
        for <linux-mm@kvack.org>; Tue, 23 Feb 2016 15:28:52 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id f17si206194qhc.19.2016.02.23.15.28.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Feb 2016 15:28:51 -0800 (PST)
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
	<20160222174426.GA30110@infradead.org>
	<257B23E37BCB93459F4D566B5EBAEAC550098A32@FMSMSX106.amr.corp.intel.com>
	<20160223095225.GB32294@infradead.org>
	<56CC686A.9040909@plexistor.com>
	<CAPcyv4gTaikkXCG1fPBVT-0DE8Wst3icriUH5cbQH3thuEe-ow@mail.gmail.com>
	<56CCD54C.3010600@plexistor.com>
	<CAPcyv4iqO=Pzu_r8tV6K2G953c5HqJRdqCE1pymfDmURy8_ODw@mail.gmail.com>
Date: Tue, 23 Feb 2016 18:28:48 -0500
In-Reply-To: <CAPcyv4iqO=Pzu_r8tV6K2G953c5HqJRdqCE1pymfDmURy8_ODw@mail.gmail.com>
	(Dan Williams's message of "Tue, 23 Feb 2016 14:33:59 -0800")
Message-ID: <x49egc3c8gf.fsf@segfault.boston.devel.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Boaz Harrosh <boaz@plexistor.com>, Christoph Hellwig <hch@infradead.org>, "Rudoff, Andy" <andy.rudoff@intel.com>, Dave Chinner <david@fromorbit.com>, Arnd Bergmann <arnd@arndb.de>, linux-nvdimm <linux-nvdimm@ml01.01.org>, Oleg Nesterov <oleg@redhat.com>, linux-mm <linux-mm@kvack.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Dan Williams <dan.j.williams@intel.com> writes:

> In general MAP_SYNC, makes more sense semantic sense in that the
> filesystem knows that the application is not going to be calling *sync

and so it makes sure its metadata is consistent after a write fault.

What you wrote is true for both MAP_SYNC and MAP_PMEM_AWARE.  :)

I assume you meant that MAP_SYNC is semantically cleaner from the file
system developer's point of view, yes?  Boaz, it might be helpful for
you to write down how an application might be structured to make use of
MAP_PMEM_AWARE.  Up to this point, I've been assuming you'd call it
whenever an application would call pcommit (or whatever the incantation
is on current CPUs).

> Although if we had MAP_SYNC today we'd still be in the situation that
> an app that fails to do its own cache flushes / bypass correctly gets
> to keep the broken pieces.

Dan, we already have this problem with existing storage and existing
interfaces.  Nothing changes with dax.

> The crux of the problem, in my opinion, is that we're asking for an "I
> know what I'm doing" flag, and I expect that's an impossible statement
> for a filesystem to trust generically.

The file system already trusts that.  If an application doesn't use
fsync properly, guess what, it will break.  This line of reasoning
doesn't make any sense to me.

> If you can get MAP_PMEM_AWARE in, great, but I'm more and more of the
> opinion that the "I know what I'm doing" interface should be something
> separate from today's trusted filesystems.

Just so I understand you, MAP_PMEM_AWARE isn't the "I know what I'm
doing" interface, right?

It sounds like we're a long way off from anything like MAP_SYNC going
in.  What I think would be useful at this stage is to come up with a
programming model we can all agree on.  ;-)  Crucially, I want to avoid
the O_DIRECT quagmire of different file systems behaving differently,
and having no way to actually query what behavior you're going to get.

Cheers,
Jeff

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
