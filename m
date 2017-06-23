Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f197.google.com (mail-ot0-f197.google.com [74.125.82.197])
	by kanga.kvack.org (Postfix) with ESMTP id 76AFB6B0279
	for <linux-mm@kvack.org>; Thu, 22 Jun 2017 23:08:23 -0400 (EDT)
Received: by mail-ot0-f197.google.com with SMTP id u74so23167286ota.0
        for <linux-mm@kvack.org>; Thu, 22 Jun 2017 20:08:23 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id g16si1002138otf.347.2017.06.22.20.08.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Jun 2017 20:08:22 -0700 (PDT)
Received: from mail-ua0-f170.google.com (mail-ua0-f170.google.com [209.85.217.170])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id A101422B6C
	for <linux-mm@kvack.org>; Fri, 23 Jun 2017 03:08:21 +0000 (UTC)
Received: by mail-ua0-f170.google.com with SMTP id g40so29657411uaa.3
        for <linux-mm@kvack.org>; Thu, 22 Jun 2017 20:08:21 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170623005214.GO17542@dastard>
References: <20170619132107.GG11993@dastard> <CALCETrUe0igzK0RZTSSondkCY3ApYQti89tOh00f0j_APrf_dQ@mail.gmail.com>
 <20170620004653.GI17542@dastard> <CALCETrVuoPDRuuhc9X8eVCYiFUzWLSTRkcjbD6jas_2J2GixNQ@mail.gmail.com>
 <20170620101145.GJ17542@dastard> <CALCETrVCJkm5SCxAtNMW36eONHsFw1s0dkVnDAs4vAXvEKMsPw@mail.gmail.com>
 <20170621014032.GL17542@dastard> <CALCETrVYmbyNS-btvsN_M-QyWPZA_Y_4JXOM893g7nhZA+WviQ@mail.gmail.com>
 <20170622000235.GN17542@dastard> <CALCETrX0n0-JxJbisrVnM6QME3uToW_x26xN3Z-t0-1yDvWn4Q@mail.gmail.com>
 <20170623005214.GO17542@dastard>
From: Andy Lutomirski <luto@kernel.org>
Date: Thu, 22 Jun 2017 20:07:59 -0700
Message-ID: <CALCETrUwEYoJ3U47GdJ-TGW4VaUHJ5eaYq5BJFe6-RwigZ+DdQ@mail.gmail.com>
Subject: Re: [RFC PATCH 2/2] mm, fs: daxfile, an interface for
 byte-addressable updates to pmem
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Andy Lutomirski <luto@kernel.org>, Dan Williams <dan.j.williams@intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, "Rudoff, Andy" <andy.rudoff@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, linux-nvdimm <linux-nvdimm@lists.01.org>, Linux API <linux-api@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Jeff Moyer <jmoyer@redhat.com>, Linux FS Devel <linux-fsdevel@vger.kernel.org>, Christoph Hellwig <hch@lst.de>

On Thu, Jun 22, 2017 at 5:52 PM, Dave Chinner <david@fromorbit.com> wrote:
> On Wed, Jun 21, 2017 at 09:07:57PM -0700, Andy Lutomirski wrote:
>> On Wed, Jun 21, 2017 at 5:02 PM, Dave Chinner <david@fromorbit.com> wrote:
>> >
>> > You seem to be calling the "fdatasync on every page fault" the
>>
>> It's the opposite of fdatasync().  It needs to sync whatever metadata
>> is needed to find the data.  The data doesn't need to be synced.
>
> So much wrong with that statement.
>
> Andy, what does fdatasync() do when you have a data-clean,
> metadata-dirty file (e.g. you just punched a hole  or preallocated
> more space via fallocate())?  Hint: it doesn't sync any data
> because the mapping tree is clean, but it still syncs the dirty
> metadata needed to access the data.
>
> Now, what does a file where we do direct IO writes look like? Yup,
> the mapping tree always remains clean and so it's only ever going to
> appear to the kernel as a *data-clean, metadata-dirty* file. So,
> after a direct IO write is done, what operation do we need to run to
> ensure that we can always access the data?
>
> Yup, it's fdatasync().

Fair enough.  Except that fdatasync() goes through dax_writeback_one()
(I think), which deals with cache flushes (via wb_cache_pmem()).  This
special type of sync shouldn't need to do that, so it's not really
quite fdatasync().

>> > "lightweight" option. That's the brute-force-with-big-hammer
>> > solution - it's most definitely not lightweight as every page fault
>> > has extra overhead to call ->fsync(). Sure, the API is simple, but
>> > the runtime overhead is significant.
>>
>> It's lightweight in terms of its impact on the filesystem.  It doesn't
>> need any persistent setup -- you can just use it.
>
> Well, no, that's wrong, because we have to co-ordinate multiple
> concurrent accesses to the data in the kernel. What happens when
> some other process writes to the file *at the same time* but does
> not use userspace sync? We aren't tracking dirty regions on the
> inode mapping because we've been told not to do that, so fsync()
> from that other process *won't sync the data it wrote*. IOws, the
> kernel has failed to provide the guarantee that userspace wants it
> to provide.

...

> What I'd like to avoid is creating another kernel bypass mechanism
> where we allow coherency and/or integrity to be fucked up in a way that
> we can't fix without giving up all the performance that the kernel
> bypass provides userspace apps. Constrain the cases where kernel
> bypass is allowed, and we avoid all the crappy corner cases where
> our only answer to users with corrupt data is "the man page advises
> application developers not to do that".

Ah, I see, a DAX file makes regular write() flush out the cache
automatically.  But I think the situation may be fucked up
integrity-wise anyway.  If you make an immutable-extent DAX file and a
DAX-unaware process mmaps() it and writes to the mapping, what flushes
the CPU cache?  Isn't part of the point of the magic immutable-extent
mode that it wouldn't have to track dirty extents?  Can it keep track
of which mappings are DAX-aware (via an mmap() flag, I assume)?  Would
all mappings of a DAX immutable-extent file be forced to be uncached
(or writethrough or WC or some type that allows fsync to be fast)?

Can you send a link to your fallocate email?  I'm having trouble finding it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
