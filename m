Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f174.google.com (mail-pf0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id 6200282F69
	for <linux-mm@kvack.org>; Mon, 22 Feb 2016 12:44:32 -0500 (EST)
Received: by mail-pf0-f174.google.com with SMTP id c10so99288057pfc.2
        for <linux-mm@kvack.org>; Mon, 22 Feb 2016 09:44:32 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id o12si40966344pfa.162.2016.02.22.09.44.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 Feb 2016 09:44:31 -0800 (PST)
Date: Mon, 22 Feb 2016 09:44:26 -0800
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [RFC 0/2] New MAP_PMEM_AWARE mmap flag
Message-ID: <20160222174426.GA30110@infradead.org>
References: <56C9EDCF.8010007@plexistor.com>
 <CAPcyv4iqAXryz0-WAtvnYf6_Q=ha8F5b-fCUt7DDhYasX=YRUA@mail.gmail.com>
 <56CA1CE7.6050309@plexistor.com>
 <CAPcyv4hpxab=c1g83ARJvrnk_5HFkqS-t3sXpwaRBiXzehFwWQ@mail.gmail.com>
 <56CA2AC9.7030905@plexistor.com>
 <CAPcyv4gQV9Oh9OpHTGuGfTJ_s1C_L7J-VGyto3JMdAcgqyVeAw@mail.gmail.com>
 <20160221223157.GC25832@dastard>
 <x49fuwk7o8a.fsf@segfault.boston.devel.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <x49fuwk7o8a.fsf@segfault.boston.devel.redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jeff Moyer <jmoyer@redhat.com>
Cc: Dave Chinner <david@fromorbit.com>, Dan Williams <dan.j.williams@intel.com>, Arnd Bergmann <arnd@arndb.de>, linux-nvdimm <linux-nvdimm@ml01.01.org>, Oleg Nesterov <oleg@redhat.com>, linux-mm <linux-mm@kvack.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On Mon, Feb 22, 2016 at 10:34:45AM -0500, Jeff Moyer wrote:
> > of the application and so file metadata changes may still be in
> > volatile RAM even though the application has flushed it's data.
> 
> Once you hand out a persistent memory mapping, you sure as heck can't
> switch blocks around behind the back of the application.

You might not even have allocated the blocks at the time of the mmap,
although for pmem remapping it after a page fault has actually allocated
the block would be rather painful.

> But even if we're not dealing with persistent memory, you seem to imply
> that applications needs to fsync just in case the file system did
> something behind its back.  In other words, an application opening a
> fully allocated file and using fdatasync will also need to call fsync,
> just in case.  Is that really what you're suggesting?

You above statement looks rather confused.  The only difference between
fdatasync and sync is that the former does not write out metadata not
required to find the file data (usually that's just timestamps).  So if
you already use fdatasync or msync properly you don't need to fsync
again.  But you need to use one of the above methods to ensure your
data is persistent on the medium.

> > Applications have no idea what the underlying filesystem and storage
> > is doing and so they cannot assume that complete data integrity is
> > provided by userspace driven CPU cache flush instructions on their
> > file data.
> 
> This is surprising to me, and goes completely against the proposed
> programming model.  In fact, this is a very basic tenet of the operation
> of the nvml libraries on pmem.io.

It's simply impossible to provide.  But then again pmem.io seems to be
much more about hype than reality anyway.

> An application creates a file and writes to every single block in the
> thing, sync's it, closes it.  It then opens it back up, calls mmap with
> this new MAP_DAX flag or on a file system mounted with -o dax, and
> proceeds to access the file using loads and stores.  It persists its
> data by using non-temporal stores, flushing and fencing cpu
> instructions.
> 
> If I understand you correctly, you're saying that that application is
> not written correctly, because it needs to call fsync to persist
> metadata (that it presumably did not modify).  Is that right?

Exactly.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
