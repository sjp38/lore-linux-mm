Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f45.google.com (mail-qg0-f45.google.com [209.85.192.45])
	by kanga.kvack.org (Postfix) with ESMTP id 682A3828E6
	for <linux-mm@kvack.org>; Mon, 22 Feb 2016 10:34:50 -0500 (EST)
Received: by mail-qg0-f45.google.com with SMTP id b35so113255298qge.0
        for <linux-mm@kvack.org>; Mon, 22 Feb 2016 07:34:50 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id n39si5912651qkh.9.2016.02.22.07.34.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 Feb 2016 07:34:49 -0800 (PST)
From: Jeff Moyer <jmoyer@redhat.com>
Subject: Re: [RFC 0/2] New MAP_PMEM_AWARE mmap flag
References: <56C9EDCF.8010007@plexistor.com>
	<CAPcyv4iqAXryz0-WAtvnYf6_Q=ha8F5b-fCUt7DDhYasX=YRUA@mail.gmail.com>
	<56CA1CE7.6050309@plexistor.com>
	<CAPcyv4hpxab=c1g83ARJvrnk_5HFkqS-t3sXpwaRBiXzehFwWQ@mail.gmail.com>
	<56CA2AC9.7030905@plexistor.com>
	<CAPcyv4gQV9Oh9OpHTGuGfTJ_s1C_L7J-VGyto3JMdAcgqyVeAw@mail.gmail.com>
	<20160221223157.GC25832@dastard>
Date: Mon, 22 Feb 2016 10:34:45 -0500
In-Reply-To: <20160221223157.GC25832@dastard> (Dave Chinner's message of "Mon,
	22 Feb 2016 09:31:57 +1100")
Message-ID: <x49fuwk7o8a.fsf@segfault.boston.devel.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Dan Williams <dan.j.williams@intel.com>, Arnd Bergmann <arnd@arndb.de>, linux-nvdimm <linux-nvdimm@ml01.01.org>, Oleg Nesterov <oleg@redhat.com>, linux-mm <linux-mm@kvack.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Hi, Dave,

Dave Chinner <david@fromorbit.com> writes:

>> Another potential issue is that MAP_PMEM_AWARE is not enough on its
>> own.  If the filesystem or inode does not support DAX the application
>> needs to assume page cache semantics.  At a minimum MAP_PMEM_AWARE
>> requests would need to fail if DAX is not available.
>
> They will always still need to call msync()/fsync() to guarantee
> data integrity, because the filesystem metadata that indexes the
> data still needs to be committed before data integrity can be
> guaranteed. i.e. MAP_PMEM_AWARE by itself it not sufficient for data
> integrity, and so the app will have to be written like any other app
> that uses page cache based mmap().
>
> Indeed, the application cannot even assume that a fully allocated
> file does not require msync/fsync because the filesystem may be
> doing things like dedupe, defrag, copy on write, etc behind the back
> of the application and so file metadata changes may still be in
> volatile RAM even though the application has flushed it's data.

Once you hand out a persistent memory mapping, you sure as heck can't
switch blocks around behind the back of the application.

But even if we're not dealing with persistent memory, you seem to imply
that applications needs to fsync just in case the file system did
something behind its back.  In other words, an application opening a
fully allocated file and using fdatasync will also need to call fsync,
just in case.  Is that really what you're suggesting?

> Applications have no idea what the underlying filesystem and storage
> is doing and so they cannot assume that complete data integrity is
> provided by userspace driven CPU cache flush instructions on their
> file data.

This is surprising to me, and goes completely against the proposed
programming model.  In fact, this is a very basic tenet of the operation
of the nvml libraries on pmem.io.

That aside, let me see if I understand you correctly.

An application creates a file and writes to every single block in the
thing, sync's it, closes it.  It then opens it back up, calls mmap with
this new MAP_DAX flag or on a file system mounted with -o dax, and
proceeds to access the file using loads and stores.  It persists its
data by using non-temporal stores, flushing and fencing cpu
instructions.

If I understand you correctly, you're saying that that application is
not written correctly, because it needs to call fsync to persist
metadata (that it presumably did not modify).  Is that right?

-Jeff

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
