Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f197.google.com (mail-ig0-f197.google.com [209.85.213.197])
	by kanga.kvack.org (Postfix) with ESMTP id C8F186B0260
	for <linux-mm@kvack.org>; Mon,  2 May 2016 19:25:52 -0400 (EDT)
Received: by mail-ig0-f197.google.com with SMTP id fn8so14838782igb.1
        for <linux-mm@kvack.org>; Mon, 02 May 2016 16:25:52 -0700 (PDT)
Received: from mail-ob0-x236.google.com (mail-ob0-x236.google.com. [2607:f8b0:4003:c01::236])
        by mx.google.com with ESMTPS id s67si134884ota.46.2016.05.02.16.25.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 02 May 2016 16:25:51 -0700 (PDT)
Received: by mail-ob0-x236.google.com with SMTP id j9so1244695obd.3
        for <linux-mm@kvack.org>; Mon, 02 May 2016 16:25:51 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20160502230422.GQ26977@dastard>
References: <1459303190-20072-6-git-send-email-vishal.l.verma@intel.com>
	<x49twj26edj.fsf@segfault.boston.devel.redhat.com>
	<20160420205923.GA24797@infradead.org>
	<1461434916.3695.7.camel@intel.com>
	<20160425083114.GA27556@infradead.org>
	<1461604476.3106.12.camel@intel.com>
	<20160425232552.GD18496@dastard>
	<1461628381.1421.24.camel@intel.com>
	<20160426004155.GF18496@dastard>
	<x49pot4ebeb.fsf@segfault.boston.devel.redhat.com>
	<20160502230422.GQ26977@dastard>
Date: Mon, 2 May 2016 16:25:51 -0700
Message-ID: <CAPcyv4jDTvSUDGTBZb0MaK_gKxMxWtMecnR_OjLzim1Sdg5Y9g@mail.gmail.com>
Subject: Re: [PATCH v2 5/5] dax: handle media errors in dax_do_io
From: Dan Williams <dan.j.williams@intel.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Jeff Moyer <jmoyer@redhat.com>, "Verma, Vishal L" <vishal.l.verma@intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-block@vger.kernel.org" <linux-block@vger.kernel.org>, "hch@infradead.org" <hch@infradead.org>, "xfs@oss.sgi.com" <xfs@oss.sgi.com>, "linux-nvdimm@ml01.01.org" <linux-nvdimm@ml01.01.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "viro@zeniv.linux.org.uk" <viro@zeniv.linux.org.uk>, "axboe@fb.com" <axboe@fb.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-ext4@vger.kernel.org" <linux-ext4@vger.kernel.org>, "Wilcox, Matthew R" <matthew.r.wilcox@intel.com>, "jack@suse.cz" <jack@suse.cz>

On Mon, May 2, 2016 at 4:04 PM, Dave Chinner <david@fromorbit.com> wrote:
> On Mon, May 02, 2016 at 11:18:36AM -0400, Jeff Moyer wrote:
>> Dave Chinner <david@fromorbit.com> writes:
>>
>> > On Mon, Apr 25, 2016 at 11:53:13PM +0000, Verma, Vishal L wrote:
>> >> On Tue, 2016-04-26 at 09:25 +1000, Dave Chinner wrote:
>> > You're assuming that only the DAX aware application accesses it's
>> > files.  users, backup programs, data replicators, fileystem
>> > re-organisers (e.g.  defragmenters) etc all may access the files and
>> > they may throw errors. What then?
>>
>> I'm not sure how this is any different from regular storage.  If an
>> application gets EIO, it's up to the app to decide what to do with that.
>
> Sure - they'll fail. But the question I'm asking is that if the
> application that owns the data is supposed to do error recovery,
> what happens when a 3rd party application hits an error? If that
> consumes the error, the the app that owns the data won't ever get a
> chance to correct the error.
>
> This is a minefield - a 3rd party app that swallows and clears DAX
> based IO errors is a data corruption vector. can yo imagine if
> *grep* did this? The model that is being promoted here effectively
> allows this sort of behaviour - I don't really think we
> should be architecting an error recovery strategy that has the
> capability to go this wrong....

Since when does grep write to a file on error?

>
>> >> > Where does the application find the data that was lost to be able to
>> >> > rewrite it?
>> >>
>> >> The data that was lost is gone -- this assumes the application has some
>> >> ability to recover using a journal/log or other redundancy - yes, at the
>> >> application layer. If it doesn't have this sort of capability, the only
>> >> option is to restore files from a backup/mirror.
>> >
>> > So the architecture has a built in assumption that only userspace
>> > can handle data loss?
>>
>> Remember that the proposed programming model completely bypasses the
>> kernel, so yes, it is expected that user-space will have to deal with
>> the problem.
>
> No, it doesn't completely bypass the kernel - the kernel is the
> infrastructure that catches the errors in the first place, and it
> owns and controls all the metadata that corresponds to the physical
> location of that error. The only thing the kernel doesn't own is the
> *contents* of that location.
>
>> > What about filesytsems like NOVA, that use log structured design to
>> > provide DAX w/ update atomicity and can potentially also provide
>> > redundancy/repair through the same mechanisms? Won't pmem native
>> > filesystems with built in data protection features like this remove
>> > the need for adding all this to userspace applications?
>>
>> I don't think we'll /only/ support NOVA for pmem.  So we'll have to deal
>> with this for existing file systems, right?
>
> Yes, but that misses my point that it seems that the design is only
> focussed on userspace and existing filesystems and there is no
> consideration of kernel side functionality that could do transparent
> recovery....
>
>> > If so, shouldn't that be the focus of development rahter than
>> > placing the burden on userspace apps to handle storage repair
>> > situations?
>>
>> It really depends on the programming model.  In the model Vishal is
>> talking about, either the applications themselves or the libraries they
>> link to are expected to implement the redundancies where necessary.
>
> IOWs, filesystems no longer have any control over data integrity.
> Yet it's the filesystem developers who will still be responsible for
> data integrity and when the filesystem has a data coruption event
> we'll get blamed and the filesystem gets a bad name, even though
> it's entirely the applications fault. We've seen this time and time
> again - application developers cannot be trusted to guarantee data
> integrity. yes, some apps will be fine, but do you really expect
> application devs that refuse to use fsync because it's too slow are
> going to have a different approach to integrity when it comes to
> DAX?

Yes, completely agree.  The applications that will implement competent
error recovery with these mechanisms will be vanishingly small, and
there is definite room for a kernel data-redundancy solution that
builds on these patches.

>
>> >> > There's an implicit assumption that applications will keep redundant
>> >> > copies of their data at the /application layer/ and be able to
>> >> > automatically repair it?
>>
>> That's one way to do things.  It really depends on the application what
>> it will do for recovery.
>>
>> >> > And then there's the implicit assumption that it will unlink and
>> >> > free the entire file before writing a new copy
>>
>> I think Vishal was referring to restoring from backup.  cp itself will
>> truncate the file before overwriting, iirc.
>
> Which version of cp? what happens if they use --sparse and the error
> is in a zeroed region? There's so many assumptions about undefined userspace
> environment, application and user behaviour being made here, and
> it's all being handwaved away.
>
> I'm asking for this to be defined, demonstrated and documented as a
> working model that cannot be abused and doesn't have holes the size
> of trucks in it, not handwaving...

You lost me...  how are these patches abusing the existing semantics
of -EIO and write to clear?

>> >> To summarize, the two cases we want to handle are:
>> >> 1. Application has inbuilt recovery:
>> >>   - hits badblock
>> >>   - figures out it is able to recover the data
>> >>   - handles SIGBUS or EIO
>> >>   - does a (sector aligned) write() to restore the data
>> >
>> > The "figures out" step here is where >95% of the work we'd have to
>> > do is. And that's in filesystem and block layer code, not
>> > userspace, and userspace can't do that work in a signal handler.
>> > And it  can still fall down to the second case when the application
>> > doesn't have another copy of the data somewhere.
>>
>> I read that "figures out" step as the application determining whether or
>> not it had a redundant copy.
>
> Another undocumented assumption, that doesn't simplify what needs to
> be done. Indeed, userspace can't do that until it is in SIGBUS
> context, which tends to imply applications need to do a major amount
> of work from within the signal handler....
>
>> > FWIW, we don't have a DAX enabled filesystem that can do
>> > reverse block mapping, so we're a year or two away from this being a
>> > workable production solution from the filesystem perspective. And
>> > AFAICT, it's not even on the roadmap for dm/md layers.
>>
>> Do we even need that?  What if we added an FIEMAP flag for determining
>> bad blocks.
>
> So you're assuming that the filesystem has been informed of the bad
> blocks and has already marked the bad regions of the file in it's
> extent list?
>
> How does that happen? What mechanism is used for the underlying
> block device to inform the filesytem that theirs a bad LBA, and how
> does the filesytem the map that to a path/file/offset with reverse
> mapping? Or is there some other magic that hasn't been explained
> happening here?

In 4.5 we added this:

commit 99e6608c9e7414ae4f2168df8bf8fae3eb49e41f
Author: Vishal Verma <vishal.l.verma@intel.com>
Date:   Sat Jan 9 08:36:51 2016 -0800

    block: Add badblock management for gendisks

    NVDIMM devices, which can behave more like DRAM rather than block
    devices, may develop bad cache lines, or 'poison'. A block device
    exposed by the pmem driver can then consume poison via a read (or
    write), and cause a machine check. On platforms without machine
    check recovery features, this would mean a crash.

    The block device maintaining a runtime list of all known sectors that
    have poison can directly avoid this, and also provide a path forward
    to enable proper handling/recovery for DAX faults on such a device.

    Use the new badblock management interfaces to add a badblocks list to
    gendisks.

    Signed-off-by: Vishal Verma <vishal.l.verma@intel.com>
    Signed-off-by: Dan Williams <dan.j.williams@intel.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
