Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id D21246B0279
	for <linux-mm@kvack.org>; Wed, 21 Jun 2017 20:03:31 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id j186so989514pge.12
        for <linux-mm@kvack.org>; Wed, 21 Jun 2017 17:03:31 -0700 (PDT)
Received: from ipmail04.adl6.internode.on.net (ipmail04.adl6.internode.on.net. [150.101.137.141])
        by mx.google.com with ESMTP id a8si15629689ple.184.2017.06.21.17.03.29
        for <linux-mm@kvack.org>;
        Wed, 21 Jun 2017 17:03:31 -0700 (PDT)
Date: Thu, 22 Jun 2017 10:02:35 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [RFC PATCH 2/2] mm, fs: daxfile, an interface for
 byte-addressable updates to pmem
Message-ID: <20170622000235.GN17542@dastard>
References: <CAPcyv4iPb69e+rE3fJUzm9U_P_dLfhantU9mvYmV-R0oQee4rA@mail.gmail.com>
 <CALCETrVY38h2ajpod2U_2pdHSp8zO4mG2p19h=OnnHmhGTairw@mail.gmail.com>
 <20170619132107.GG11993@dastard>
 <CALCETrUe0igzK0RZTSSondkCY3ApYQti89tOh00f0j_APrf_dQ@mail.gmail.com>
 <20170620004653.GI17542@dastard>
 <CALCETrVuoPDRuuhc9X8eVCYiFUzWLSTRkcjbD6jas_2J2GixNQ@mail.gmail.com>
 <20170620101145.GJ17542@dastard>
 <CALCETrVCJkm5SCxAtNMW36eONHsFw1s0dkVnDAs4vAXvEKMsPw@mail.gmail.com>
 <20170621014032.GL17542@dastard>
 <CALCETrVYmbyNS-btvsN_M-QyWPZA_Y_4JXOM893g7nhZA+WviQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALCETrVYmbyNS-btvsN_M-QyWPZA_Y_4JXOM893g7nhZA+WviQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>
Cc: Dan Williams <dan.j.williams@intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, andy.rudoff@intel.com, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, linux-nvdimm <linux-nvdimm@lists.01.org>, Linux API <linux-api@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Jeff Moyer <jmoyer@redhat.com>, Linux FS Devel <linux-fsdevel@vger.kernel.org>, Christoph Hellwig <hch@lst.de>

On Tue, Jun 20, 2017 at 10:18:24PM -0700, Andy Lutomirski wrote:
> On Tue, Jun 20, 2017 at 6:40 PM, Dave Chinner <david@fromorbit.com> wrote:
> >> A per-inode
> >> count of the number of live DAX mappings or of the number of struct
> >> file instances that have requested DAX would work here.
> >
> > For what purpose does this serve? The reflink invalidates all the
> > existing mappings, so the next write access causes a fault and then
> > page_mkwrite is called and the shared extent will get COWed....
> 
> The same purpose as XFS's FS_XFLAG_DAX (assuming I'm understanding it
> right), except that IMO an API that doesn't involve making a change to
> an inode that sticks around would be nice.  The inode flag has the
> unfortunate property that, if two different programs each try to set
> the flag, mmap, write, and clear the flag, they'll stomp on each other
> and risk data corruption.
> 
> I admit I'm now thoroughly confused as to exactly what XFS does here
> -- does FS_XFLAG_DAX persist across unmount/mount?

Yes, it is.

i.e. DAX on XFS does not rely on a naive fs-wide mount option. You
can have applications on pmem filesystems use either DAX or normal
IO based on directory/inode flags.  Something doesn't work with DAX,
so just remove the DAX flags from the directories/inodes, and it
will safely and transparently switch to page-cache based IO.

<snip>

> Here's the overall point I'm trying to make: unprivileged programs
> that want to write to DAX files with userspace commit mechanisms
> (CLFLUSHOPT;SFENCE, etc) should be able to do so reliably, without
> privilege, and with reasonably clean APIs.  Ideally they could do this
> to any file they have write access to.

The privilege argument is irrelevant now - it was /suggested/
initially as a way of preventing people from shooting themselves in
the foot based on the immutable file model. It's clear that's not
desired, and it's not a show stopper. 

> Programs that want to write to
> mmapped files, DAX or otherwise, without latency spikes due to
> .page_mkwrite should be able to opt in to a heavier weight mechanism.
> But these two issues are someone independent, and I think they should
> be solved separately.

You seem to be calling the "fdatasync on every page fault" the
"lightweight" option. That's the brute-force-with-big-hammer
solution - it's most definitely not lightweight as every page fault
has extra overhead to call ->fsync(). Sure, the API is simple, but
the runtime overhead is significant.

The lightweight *runtime* option is to set up the file in such a
way that there is never any extra overhead at page fault time.  This
is what immutable extent maps provide.  Indeed, because the mappings
never change, you could use hardware dirty tracking if you wanted,
as there's no need to look up the filesystem to do writeback as
everything needed for writeback was mapped at page fault time.  This
"map first and then just write when you need to" is *exactly how
swap files work*.

Even if you are considering the complexity of the APIs, it's hardly
a "heavyweight" when it only requires a single call to fallocate()
before mmap() to set up the immutable extents on the file...

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
