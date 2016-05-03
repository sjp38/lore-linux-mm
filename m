Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f200.google.com (mail-ig0-f200.google.com [209.85.213.200])
	by kanga.kvack.org (Postfix) with ESMTP id C30266B0005
	for <linux-mm@kvack.org>; Tue,  3 May 2016 13:28:16 -0400 (EDT)
Received: by mail-ig0-f200.google.com with SMTP id u5so53844256igk.2
        for <linux-mm@kvack.org>; Tue, 03 May 2016 10:28:16 -0700 (PDT)
Received: from mail-oi0-x22b.google.com (mail-oi0-x22b.google.com. [2607:f8b0:4003:c06::22b])
        by mx.google.com with ESMTPS id b5si92995oez.92.2016.05.03.10.28.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 03 May 2016 10:28:15 -0700 (PDT)
Received: by mail-oi0-x22b.google.com with SMTP id x201so35104669oif.3
        for <linux-mm@kvack.org>; Tue, 03 May 2016 10:28:15 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20160503015159.GS26977@dastard>
References: <20160420205923.GA24797@infradead.org>
	<1461434916.3695.7.camel@intel.com>
	<20160425083114.GA27556@infradead.org>
	<1461604476.3106.12.camel@intel.com>
	<20160425232552.GD18496@dastard>
	<1461628381.1421.24.camel@intel.com>
	<20160426004155.GF18496@dastard>
	<x49pot4ebeb.fsf@segfault.boston.devel.redhat.com>
	<20160502230422.GQ26977@dastard>
	<CAPcyv4jDTvSUDGTBZb0MaK_gKxMxWtMecnR_OjLzim1Sdg5Y9g@mail.gmail.com>
	<20160503015159.GS26977@dastard>
Date: Tue, 3 May 2016 10:28:15 -0700
Message-ID: <CAPcyv4jHexooj9bPHPAUJUkJSv2przuA6dv0wZPQUweBffa=bQ@mail.gmail.com>
Subject: Re: [PATCH v2 5/5] dax: handle media errors in dax_do_io
From: Dan Williams <dan.j.williams@intel.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Jeff Moyer <jmoyer@redhat.com>, "Verma, Vishal L" <vishal.l.verma@intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-block@vger.kernel.org" <linux-block@vger.kernel.org>, "hch@infradead.org" <hch@infradead.org>, "xfs@oss.sgi.com" <xfs@oss.sgi.com>, "linux-nvdimm@ml01.01.org" <linux-nvdimm@ml01.01.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "viro@zeniv.linux.org.uk" <viro@zeniv.linux.org.uk>, "axboe@fb.com" <axboe@fb.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-ext4@vger.kernel.org" <linux-ext4@vger.kernel.org>, "Wilcox, Matthew R" <matthew.r.wilcox@intel.com>, "jack@suse.cz" <jack@suse.cz>

On Mon, May 2, 2016 at 6:51 PM, Dave Chinner <david@fromorbit.com> wrote:
> On Mon, May 02, 2016 at 04:25:51PM -0700, Dan Williams wrote:
[..]
> Yes, I know, and it doesn't answer any of the questions I just
> asked. What you just told me is that there is something that is kept
> three levels of abstraction away from a filesystem. So:

Ok, let's answer them.

A lot of your questions seem to assume the filesystem has a leading
role to play with error recovery, that isn't the case with traditional
disk errors and we're not looking to change that situation.  The
filesystem can help with forensics after an error escapes the kernel
and is communicated to userspace, but the ability to reverse map a
sector to a file is just a convenience to identify potential data
loss.

For redundancy in the DAX case I can envision DAX-aware RAID that
makes the potential exposure to bad blocks smaller, but it will always
be the case that the array can be out-of-sync / degraded and has no
choice but to communicate the error to userspace.  So, the answers
below address what we do when we are in that state, and include some
thoughts about follow-on enabling we can do at the DM/MD layer.

>         - What mechanism is to be used for the underlying block
>           device to inform the filesytem that a new bad block was
>           added to this list?

The filesystem doesn't need this notification and doesn't get it today
from RAID.  It's handy for the bad block list to be available to
fs/dax.c and the block layer, but I don't see ext4/xfs having a role
to play with the list and certainly not care about "new error detected
events".  For a DM/MD driver it also does not need to know about new
errors because it will follow the traditional disk model where errors
are handled on access, or discovered and scrubbed during a periodic
array scan.

That said, new errors may get added to the list by having the pmem
driver trigger a rescan of the device whenever a latent error is
discovered (i.e. memcpy_from_pmem() returns -EIO).  The update of the
bad block list is asynchronous.  We also have a task on the todo list
to allow the pmem rescan action to be triggered via sysfs.

>           What context comes along with that
>           notification?

The only notification the file system gets is -EIO on access.
However, assuming we had a DAX-aware RAID driver what infrastructure
would we need to prevent SIGBUS from reaching the application if we
happened to have a redundant copy of the data?

One feature we've talked about for years at LSF/MM but never made any
progress on is a way for a file system to discover and query if the
storage layer can reconstruct data from redundant information.
Assuming we had such an interface there's still the matter of plumbing
a machine check fault through a physical-address-to-sector conversion
and request the block device driver to attempt to provide a redundant
copy.

The in-kernel recovery path, assuming RAID is present, needs more
thought especially considering the limited NMI context of a machine
check notification and the need to trap back into driver code.  I see
the code in fs/dax.c getting involved to translate a
process-physical-address back to a sector, but otherwise the rest of
the filesystem need not be involved.

>         - how does the filesystem query the bad block list without
>           adding layering violations?

Why does the file system need to read the list?

Apologies for answering this question with a question, but these
patches don't assume the filesystem will do anything with a bad block
list.

>         - when does the filesystem need to query the bad block list?
>         - how will the bad block list propagate through DM/MD
>           layers?
>         - how does the filesytem the map the bad block to a
>           path/file/offset without reverse mapping - does this error
>           handling interface really imply the filesystem needs to
>           implement brute force scans at notification time?

No, there is no implication that reverse mapping is a requirement.

>         - Is the filesystem expectd to find the active application or
>           address_space access that triggered the bad block
>           notification to handle them correctly? (e.g. prevent a
>           page fault from failing because we can recover from the
>           error immediately)

With these patches no, but it would be nice to incrementally add that
ability.  I.e. trap machine check faults on non-anonymous memory and
send a request down the stack to recover the sector if the storage
layer has a redundant copy.  Again, fs/dax.c would need extensions to
do this coordination, but I don't foresee the filesystem getting
involved beyond that point.

>         - what exactly is the filesystem supposed to do with the bad
>           block? e.g:
>                 - is the block persistently bad until the filesystem
>                   rewrites it? Over power cycles? Will we get
>                   multiple notifications (e.g. once per boot)?

Bad blocks on persistent memory media remain bad after a reboot.  Per
the ACPI spec the DIMM device tracks the errors and reports them in
response to an "address range scrub" command.  Each boot the libnvdimm
sub-system kicks off a scrub and populates the bad block list per pmem
namespace.  As mentioned above, we want to add the ability to
re-trigger this scrub on-demand, in response to a memcpy_from_pmem()
discovering an error, or after a SIGBUS is communicated to userspace.

>                 - Is the filesystem supposed to intercept
>                   reads/writes to bad blocks once it knows about
>                   them?

No, the driver handles that.

>                 - how is the filesystem supposed to communicate that
>                   there is a bad block in a file back to userspace?

-EIO on access.

>                   Or is userspace supposed to infer that there's a
>                   bad block from EIO and so has to run FIEMAP to
>                   determine if the error really was due to a bad
>                   block?

The information is there to potentially do forensics on why an I/O
encountered an error, but there is no expectation that userspace
follow up on each -EIO with a FIEMAP.

>                 - what happens if there is no running application
>                   that we can report the error to or will handle the
>                   error (e.g. found error by a media scrub or during
>                   boot)?

Same as RAID today, if the array is in sync the bad block will get
re-written during the scrub hopefully in advance of when an
application might discover it.  If no RAID is present then the only
notification is an on-access error.

>         - if the bad block is in filesystem free space, what should
>           the filesystem do with it?

Nothing.  When the free space becomes allocated we rely on the fact
that the filesystem will first zero the blocks.  That zeroing process
will clear the media error.

Now, in rare cases clearing the error might itself fail, but in that
case we just degenerate to the latent error discovery case.

> What I'm failing to communicate is that having and maintaining
> things like bad block lists in a block device is the easy part of
> the problem.
>
> Similarly reporting a bad block flag in FIEMAP is only a few
> lines of code to implement, but that assumes the filesystem has
> already propagated the bad block information into it's internal
> extents lists.
>
> That's the hard part of all this: connecting the two pieces together
> in a sane, reliable, consistent and useful manner. This will form
> the user API, so we need to sort it out before applications start to
> use it.

Applications are already using most of this model today.  The new
enabling we should consider is a way to take advantage of redundancy
at the storage driver layer to prevent errors from being reported to
userspace when redundant data is available.  Preventing
machine-check-SIGBUS signals from reaching applications is a new
general purpose error handling mechanism that might also be useful for
DRAM errors outside of pmem+DAX.

> However, if I'm struggling to understand how I'm supposed to
> connecct up the parts inside a filesytem, then expecting application
> developers to be able to connect the dots in a sane manner is
> bordering on fantasy....

Hopefully it is becoming clearer that we are not proposing anything
radically different than what is present for error recovery today
modulo thinking about the mechanisms to trap and recover a DAX read of
a bad media area via a DM/MD implementation.  DAX writes on the other
hand are more challenging in that we'd likely want to stage them and
wait to commit them until an explicit sync point.  However, this is
still consistent with the DAX programming model.  An application is
free to trade off raw access to the media for higher-order filesystem
and storage layer features provided by the kernel.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
