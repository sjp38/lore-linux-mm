Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f199.google.com (mail-ot0-f199.google.com [74.125.82.199])
	by kanga.kvack.org (Postfix) with ESMTP id A63F26B0279
	for <linux-mm@kvack.org>; Thu, 22 Jun 2017 00:08:20 -0400 (EDT)
Received: by mail-ot0-f199.google.com with SMTP id o27so3525787otd.15
        for <linux-mm@kvack.org>; Wed, 21 Jun 2017 21:08:20 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id j8si115030otb.384.2017.06.21.21.08.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Jun 2017 21:08:19 -0700 (PDT)
Received: from mail-ua0-f172.google.com (mail-ua0-f172.google.com [209.85.217.172])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id CDF1A22B66
	for <linux-mm@kvack.org>; Thu, 22 Jun 2017 04:08:18 +0000 (UTC)
Received: by mail-ua0-f172.google.com with SMTP id g40so4603531uaa.3
        for <linux-mm@kvack.org>; Wed, 21 Jun 2017 21:08:18 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170622000235.GN17542@dastard>
References: <CAPcyv4iPb69e+rE3fJUzm9U_P_dLfhantU9mvYmV-R0oQee4rA@mail.gmail.com>
 <CALCETrVY38h2ajpod2U_2pdHSp8zO4mG2p19h=OnnHmhGTairw@mail.gmail.com>
 <20170619132107.GG11993@dastard> <CALCETrUe0igzK0RZTSSondkCY3ApYQti89tOh00f0j_APrf_dQ@mail.gmail.com>
 <20170620004653.GI17542@dastard> <CALCETrVuoPDRuuhc9X8eVCYiFUzWLSTRkcjbD6jas_2J2GixNQ@mail.gmail.com>
 <20170620101145.GJ17542@dastard> <CALCETrVCJkm5SCxAtNMW36eONHsFw1s0dkVnDAs4vAXvEKMsPw@mail.gmail.com>
 <20170621014032.GL17542@dastard> <CALCETrVYmbyNS-btvsN_M-QyWPZA_Y_4JXOM893g7nhZA+WviQ@mail.gmail.com>
 <20170622000235.GN17542@dastard>
From: Andy Lutomirski <luto@kernel.org>
Date: Wed, 21 Jun 2017 21:07:57 -0700
Message-ID: <CALCETrX0n0-JxJbisrVnM6QME3uToW_x26xN3Z-t0-1yDvWn4Q@mail.gmail.com>
Subject: Re: [RFC PATCH 2/2] mm, fs: daxfile, an interface for
 byte-addressable updates to pmem
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Andy Lutomirski <luto@kernel.org>, Dan Williams <dan.j.williams@intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, "Rudoff, Andy" <andy.rudoff@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, linux-nvdimm <linux-nvdimm@lists.01.org>, Linux API <linux-api@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Jeff Moyer <jmoyer@redhat.com>, Linux FS Devel <linux-fsdevel@vger.kernel.org>, Christoph Hellwig <hch@lst.de>

On Wed, Jun 21, 2017 at 5:02 PM, Dave Chinner <david@fromorbit.com> wrote:
>
> You seem to be calling the "fdatasync on every page fault" the

It's the opposite of fdatasync().  It needs to sync whatever metadata
is needed to find the data.  The data doesn't need to be synced.

> "lightweight" option. That's the brute-force-with-big-hammer
> solution - it's most definitely not lightweight as every page fault
> has extra overhead to call ->fsync(). Sure, the API is simple, but
> the runtime overhead is significant.

It's lightweight in terms of its impact on the filesystem.  It doesn't
need any persistent setup -- you can just use it.

> Even if you are considering the complexity of the APIs, it's hardly
> a "heavyweight" when it only requires a single call to fallocate()
> before mmap() to set up the immutable extents on the file...

So what would the exact semantics be?  In particular, how can it fail?
 If I do the fallocate(), is it absolutely promised that the extent
map won't get out of sync between what mmap sees and what's on disk?
Do user programs need to worry about colliding with each other when
one does fallocate() to DAXify a file and the other does fallocate()
to unDAXify a file?  Does this particular fallocate() call still keep
its effect after a reboot?

These issues are why I think it would be nicer to have an API that
makes a particular mapping or fd be unconditionally *correct* and then
to provide something else that makes it avoid latency spikes.

Is there an actual concrete proposal that's reviewable?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
