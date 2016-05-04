Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 6CDB86B007E
	for <linux-mm@kvack.org>; Wed,  4 May 2016 01:05:15 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id u185so75397110oie.3
        for <linux-mm@kvack.org>; Tue, 03 May 2016 22:05:15 -0700 (PDT)
Received: from mail-oi0-x22a.google.com (mail-oi0-x22a.google.com. [2607:f8b0:4003:c06::22a])
        by mx.google.com with ESMTPS id r3si694483oig.7.2016.05.03.22.05.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 03 May 2016 22:05:14 -0700 (PDT)
Received: by mail-oi0-x22a.google.com with SMTP id x19so52549186oix.2
        for <linux-mm@kvack.org>; Tue, 03 May 2016 22:05:14 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20160504031848.GP18496@dastard>
References: <20160425083114.GA27556@infradead.org>
	<1461604476.3106.12.camel@intel.com>
	<20160425232552.GD18496@dastard>
	<1461628381.1421.24.camel@intel.com>
	<20160426004155.GF18496@dastard>
	<x49pot4ebeb.fsf@segfault.boston.devel.redhat.com>
	<20160502230422.GQ26977@dastard>
	<CAPcyv4jDTvSUDGTBZb0MaK_gKxMxWtMecnR_OjLzim1Sdg5Y9g@mail.gmail.com>
	<20160503015159.GS26977@dastard>
	<CAPcyv4jHexooj9bPHPAUJUkJSv2przuA6dv0wZPQUweBffa=bQ@mail.gmail.com>
	<20160504031848.GP18496@dastard>
Date: Tue, 3 May 2016 22:05:13 -0700
Message-ID: <CAPcyv4iGmYz0gXK=BzeC2agtVD2VzKT6ajzd4bkrCSZ-VSDLYQ@mail.gmail.com>
Subject: Re: [PATCH v2 5/5] dax: handle media errors in dax_do_io
From: Dan Williams <dan.j.williams@intel.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Jeff Moyer <jmoyer@redhat.com>, "Verma, Vishal L" <vishal.l.verma@intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-block@vger.kernel.org" <linux-block@vger.kernel.org>, "hch@infradead.org" <hch@infradead.org>, "xfs@oss.sgi.com" <xfs@oss.sgi.com>, "linux-nvdimm@ml01.01.org" <linux-nvdimm@ml01.01.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "viro@zeniv.linux.org.uk" <viro@zeniv.linux.org.uk>, "axboe@fb.com" <axboe@fb.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-ext4@vger.kernel.org" <linux-ext4@vger.kernel.org>, "Wilcox, Matthew R" <matthew.r.wilcox@intel.com>, "jack@suse.cz" <jack@suse.cz>

On Tue, May 3, 2016 at 8:18 PM, Dave Chinner <david@fromorbit.com> wrote:
> On Tue, May 03, 2016 at 10:28:15AM -0700, Dan Williams wrote:
>> On Mon, May 2, 2016 at 6:51 PM, Dave Chinner <david@fromorbit.com> wrote:
>> > On Mon, May 02, 2016 at 04:25:51PM -0700, Dan Williams wrote:
>> [..]
>> > Yes, I know, and it doesn't answer any of the questions I just
>> > asked. What you just told me is that there is something that is kept
>> > three levels of abstraction away from a filesystem. So:
>>
>> Ok, let's answer them.
>>
>> A lot of your questions seem to assume the filesystem has a leading
>> role to play with error recovery, that isn't the case with traditional
>> disk errors and we're not looking to change that situation.
>
> *cough* BTRFS
>
> New filesystems are mostly being designed with redundancy and
> recovery mechanisms built into them. Hence the high level
> /assumption/ that filesystems aren't going to play a significant
> role in error recovery for pmem storage is, well, somewhat
> disturbing....

It is unfortunate is that you cite the lack of pmem enabling in btrfs
as a reason to block patches that hookup the kernel's existing error
mechanisms for the DAX case.  I expect btrfs multi-device
redundancy-management for pmem to be a more a coherent solution than
what we can achieve with single-device-filesystems + RAID.  I'm trying
not to boil the ocean in this discussion, but Iet's go ahead and rope
in btrfs-devel into this thread so we can make progress on hooking up
SIGBUS notifications for DAX errors and bypassing dax_do_io() to clear
errors.

>> The
>> filesystem can help with forensics after an error escapes the kernel
>> and is communicated to userspace, but the ability to reverse map a
>> sector to a file is just a convenience to identify potential data
>> loss.
>
> So working out what file got corrupted in your terabytes of pmem
> storage is "just a convenience"? I suspect that a rather large
> percentage of admins will disagree with you on this.

Yes, I will point them to their file system maintainer to ask about
reverse mapping support.

>> For redundancy in the DAX case I can envision DAX-aware RAID that
>> makes the potential exposure to bad blocks smaller, but it will always
>> be the case that the array can be out-of-sync / degraded and has no
>> choice but to communicate the error to userspace.  So, the answers
>> below address what we do when we are in that state, and include some
>> thoughts about follow-on enabling we can do at the DM/MD layer.
>>
>> >         - What mechanism is to be used for the underlying block
>> >           device to inform the filesytem that a new bad block was
>> >           added to this list?
>>
>> The filesystem doesn't need this notification and doesn't get it today
>> from RAID.
>
> Why doesn't the filesystem need this notification? Just because we
> don't get it today from a RAID device does not mean we can't use it.

If xfs and ext4 had a use for error notification today we would hook into it.

> Indeed, think about the btrfs scrub operation - it validates
> everything on it's individual block devices, and when it finds a
> problem (e.g. a data CRC error) it notifies a different layer in the
> btrfs code that goes and works out if it can repair the problem from
> redundant copies/parity/mirrors/etc.

Yes, just like RAID, sounds like we should definitely keep that in
mind for the patch set that adds pmem support to btrfs, this isn't
that patch set.

>> It's handy for the bad block list to be available to
>> fs/dax.c and the block layer, but I don't see ext4/xfs having a role
>> to play with the list and certainly not care about "new error detected
>> events".
>
> That's very short-sighted. Just because ext4/xfs don't *currently*
> do this, it doesn't mean other filesystems (existing or new) can't
> make use of notifications, nor that ext4/XFS can't ever make use of
> it, either.

Did I say "can't ever make use of it", no, if you have a need for a
notification for xfs let's work on a notification mechanism.

>
>> For a DM/MD driver it also does not need to know about new
>> errors because it will follow the traditional disk model where errors
>> are handled on access, or discovered and scrubbed during a periodic
>> array scan.
>>
>> That said, new errors may get added to the list by having the pmem
>> driver trigger a rescan of the device whenever a latent error is
>> discovered (i.e. memcpy_from_pmem() returns -EIO).  The update of the
>> bad block list is asynchronous.  We also have a task on the todo list
>> to allow the pmem rescan action to be triggered via sysfs.
>
> IOWs, the pmem driver won't report errors to anyone who can correct
> them until an access to that bad block is made? Even if it means the
> error might go unreported and hence uncorrected for weeks or months
> because no access is made to that bad data?

RAID periodically polls for and fixes bad blocks.  The currently
implementation only polls for errors at driver load.  When we
implement userspace triggered bad blocks scans we could also have a
cron job to periodically kick off a scan, which follows the status quo
for RAID error scanning.

>
>> >           What context comes along with that
>> >           notification?
>>
>> The only notification the file system gets is -EIO on access.
>> However, assuming we had a DAX-aware RAID driver what infrastructure
>> would we need to prevent SIGBUS from reaching the application if we
>> happened to have a redundant copy of the data?
>
> We'd need the same infrastructure at the filesystem layer would
> require if it has a redundant copy of the data. I don't know what
> that is, however, because I know very little about about MCEs and
> signal delivery (which is why I asked this question).

Fair enough.

> [....]
>
>> The in-kernel recovery path, assuming RAID is present, needs more
>> thought especially considering the limited NMI context of a machine
>> check notification and the need to trap back into driver code.
>
> This is precisely the problem I am asking about - I know there is a
> limited context, but how exactly is it limited and what can we
> actually do from this context? e.g. Can we schedule recovery work on
> other CPU cores and wait for it to complete in a MCE notification
> handler?
>
>> I see
>> the code in fs/dax.c getting involved to translate a
>> process-physical-address back to a sector, but otherwise the rest of
>> the filesystem need not be involved.
>
> More /assumptions/ about filesystems not containing or being able to
> recover from redudant copies of data.
>
>>
>> >         - how does the filesystem query the bad block list without
>> >           adding layering violations?
>>
>> Why does the file system need to read the list?
>> Apologies for answering this question with a question, but these
>> patches don't assume the filesystem will do anything with a bad block
>> list.
>
> People keep talking about FIEMAP reporting bad blocks in files! How
> the fuck are we supposed to report bad blocks in a file via FIEMAP
> if the filesystem can't access the bad block list?

Compare FIEMAP results against the badblocks list, or arrange for
FIEMAP to return the errors in file list by parsing the list against
the badblocks list available in the gendisk.  Shall I send a patch?
It does assume we can do a inode to bdev lookup.

>> >         - Is the filesystem expectd to find the active application or
>> >           address_space access that triggered the bad block
>> >           notification to handle them correctly? (e.g. prevent a
>> >           page fault from failing because we can recover from the
>> >           error immediately)
>>
>> With these patches no, but it would be nice to incrementally add that
>> ability.  I.e. trap machine check faults on non-anonymous memory and
>> send a request down the stack to recover the sector if the storage
>> layer has a redundant copy.  Again, fs/dax.c would need extensions to
>> do this coordination, but I don't foresee the filesystem getting
>> involved beyond that point.
>
> Again, the /assumption/ here is that only the block layer has the
> ability to recover, and only sector mapping is required from the fs.

Presently yes, in the future, no.

>
>> >         - what exactly is the filesystem supposed to do with the bad
>> >           block? e.g:
>> >                 - is the block persistently bad until the filesystem
>> >                   rewrites it? Over power cycles? Will we get
>> >                   multiple notifications (e.g. once per boot)?
>>
>> Bad blocks on persistent memory media remain bad after a reboot.  Per
>> the ACPI spec the DIMM device tracks the errors and reports them in
>> response to an "address range scrub" command.  Each boot the libnvdimm
>> sub-system kicks off a scrub and populates the bad block list per pmem
>> namespace.  As mentioned above, we want to add the ability to
>> re-trigger this scrub on-demand, in response to a memcpy_from_pmem()
>> discovering an error, or after a SIGBUS is communicated to userspace.
>>
>> >                 - Is the filesystem supposed to intercept
>> >                   reads/writes to bad blocks once it knows about
>> >                   them?
>>
>> No, the driver handles that.
>
> So, -EIO will be returned to the filesystem on access? If -EIO, then
> we'll have to check over the bad block list to determine if data
> recovery operations are required, right? Perhaps we need a different
> error here to tell the higher layers it's a specific type of error
> (e.g. -EBADBLOCK)?

That sounds reasonable.

>> >                 - how is the filesystem supposed to communicate that
>> >                   there is a bad block in a file back to userspace?
>>
>> -EIO on access.
>
> So no consideration for proactive "data loss has occurred at offset X
> in file /mnt/path/to/file, attempting recovery" messages when the
> error is first detected by the lowest layers?

That sounds reasonable too, what does xfs report today for disk errors?

>> >                   Or is userspace supposed to infer that there's a
>> >                   bad block from EIO and so has to run FIEMAP to
>> >                   determine if the error really was due to a bad
>> >                   block?
>>
>> The information is there to potentially do forensics on why an I/O
>> encountered an error, but there is no expectation that userspace
>> follow up on each -EIO with a FIEMAP.
>
> Ok, so how is userspace driven error recovery supposed to work if it
> can't differentiate the cause of an EIO error? If there's no
> requirement for FIEMAP to report the bad blocks in a file that needs
> recovery, then what is the app supposed to do with the EIO? Indeed,
> what consideration has been given to ensuring the app knows aheadi
> of time that the filesystem FIEMAP implementation will report bad
> blocks if they exist?

So, having a new flavor of FIEMAP that reports bad blocks in a file,
or a new SEEK_BADBLOCK flag for lseek() was proposed for situations
where an application could not simply take a list of badblocks from
sysfs and do an intersection operation with typical FIEMAP results to
see if a file was impacted.

Indeed btrfs is an example where the per-block-device list is unusable
for an application to do this FIEMAP intersection operation, but an
application on a single-device-ext4 filesystem could make use of the
list.

> Of course, the filesystem has to know about the bad blocks to be
> able to do any of this with FIEMAP....

Is there some complication about looking up the gendisk from the inode
that I'm overlooking?  Is there a different location we need to place
the error list to make it easy for the fs to consume?

>> >                 - what happens if there is no running application
>> >                   that we can report the error to or will handle the
>> >                   error (e.g. found error by a media scrub or during
>> >                   boot)?
>>
>> Same as RAID today, if the array is in sync the bad block will get
>> re-written during the scrub hopefully in advance of when an
>> application might discover it.  If no RAID is present then the only
>> notification is an on-access error.
>
> More /assumptions/ that only device level RAID will be able to
> recover....

Presently yes, in the future, no.

>
>> >         - if the bad block is in filesystem free space, what should
>> >           the filesystem do with it?
>>
>> Nothing.  When the free space becomes allocated we rely on the fact
>> that the filesystem will first zero the blocks.  That zeroing process
>> will clear the media error.
>
> The incorrect /assumption/ here is that all allocations will do
> block zeroing first. That's simply wrong. We do that for *user data*
> in XFS and ext4, but we do not do it for metadata as they are not
> accessed by DAX and, being transactionally protected, don't need
> zeroing to prevent stale data exposure.

Ah, great point.  See, I knew if we kept talking, something productive
would come out of this discussion, but I think we're still ok, see
below.

> Hence we have a problem here - the first write to such blocks may
> be metadata writeback of some type and so the filesystem will see
> EIO errors in metadata writes and they'll freak out.

As long as the filesystem writes before it reads metadata we're mostly
ok, because a block error is cleared on write, we don't return -EIO
for them, however...

> What
> now - does this really mean that we'll have to add special IO
> falback code for all internal IO paths to be able to clear pmem bad
> block errors?

...we still have the case where a badblock can develop in metadata
after writing it, we can't do anything about it unless some layer
somewhere implements redundancy.

> Oh, and just a thought: lots of people are pushing for selectable
> FALLOC_FL_NO_HIDE_STALE behaviour which will skip zeroing
> of data blocks on allocation. If this happens, it we also skip
> the zeroing on allocation, so again there is no mechanism to clear
> bad block status in this case.....

Outside of rewriting the file, yes I was aware of this and it breaks
the "delete to clear media errors" recovery model.  My only answer
right now is that we would need to document FALLOC_FL_NO_HIDE_STALE
with notifications about the fact that we lose the side-effect of
clearing latent media errors when block zeroing / trimming on
reallocation is disabled.

> [...]
>
>> > However, if I'm struggling to understand how I'm supposed to
>> > connecct up the parts inside a filesytem, then expecting application
>> > developers to be able to connect the dots in a sane manner is
>> > bordering on fantasy....
>>
>> Hopefully it is becoming clearer that we are not proposing anything
>> radically different than what is present for error recovery today
>> modulo thinking about the mechanisms to trap and recover a DAX read of
>> a bad media area via a DM/MD implementation.
>
> There is a radical difference - there is a pervasive /assumption/ in
> what is being proposed that filesystems are incapable of storing
> redundant information that can be used for error recovery.

That's not an assumption, it is a fact that DAX enabled filesystems
don't account for data redundancy today outside of "let the storage
layer do it".  I'm all for making this situation better than it is.

> The
> current IO stack makes no such assumptions, even if it doesn't
> provide any infrastructure for such functionality.

Great, lets start to fill in that hole with some patches to return
SIGBUS on a DAX fault hitting a bad block, and bypassing dax_do_io()
for O_DIRECT writes so userspace I/O can clear errors instead of
receiving -EIO for a write.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
