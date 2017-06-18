Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 47AA06B0279
	for <linux-mm@kvack.org>; Sat, 17 Jun 2017 23:15:08 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id e191so13718969oih.4
        for <linux-mm@kvack.org>; Sat, 17 Jun 2017 20:15:08 -0700 (PDT)
Received: from mail-ot0-x22b.google.com (mail-ot0-x22b.google.com. [2607:f8b0:4003:c0f::22b])
        by mx.google.com with ESMTPS id 94si2581519otm.251.2017.06.17.20.15.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 17 Jun 2017 20:15:06 -0700 (PDT)
Received: by mail-ot0-x22b.google.com with SMTP id r67so50740884ota.1
        for <linux-mm@kvack.org>; Sat, 17 Jun 2017 20:15:06 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CALCETrUfv26pvmyQ1gOkKbzfSXK2DnmeBG6VmSWjFy1WBhknTw@mail.gmail.com>
References: <149766212410.22552.15957843500156182524.stgit@dwillia2-desk3.amr.corp.intel.com>
 <149766213493.22552.4057048843646200083.stgit@dwillia2-desk3.amr.corp.intel.com>
 <CALCETrU1Hg=q4cdQDex--3nVBfwRC1o=9pC6Ss77Z8Lxg7ZJLg@mail.gmail.com>
 <CAPcyv4j4UEegViDJcLZjVv5AFGC18-DcvHFnhZatB0hH3BY85g@mail.gmail.com> <CALCETrUfv26pvmyQ1gOkKbzfSXK2DnmeBG6VmSWjFy1WBhknTw@mail.gmail.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Sat, 17 Jun 2017 20:15:05 -0700
Message-ID: <CAPcyv4iPb69e+rE3fJUzm9U_P_dLfhantU9mvYmV-R0oQee4rA@mail.gmail.com>
Subject: Re: [RFC PATCH 2/2] mm, fs: daxfile, an interface for
 byte-addressable updates to pmem
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, linux-nvdimm <linux-nvdimm@lists.01.org>, Linux API <linux-api@vger.kernel.org>, Dave Chinner <david@fromorbit.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Jeff Moyer <jmoyer@redhat.com>, Linux FS Devel <linux-fsdevel@vger.kernel.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, Christoph Hellwig <hch@lst.de>

On Sat, Jun 17, 2017 at 4:50 PM, Andy Lutomirski <luto@kernel.org> wrote:
> On Sat, Jun 17, 2017 at 2:52 PM, Dan Williams <dan.j.williams@intel.com> wrote:
>> On Sat, Jun 17, 2017 at 9:25 AM, Andy Lutomirski <luto@kernel.org> wrote:
>>>
>>> Can you remind those of us who haven't played with DAX in a while what
>>> the problem is with mmapping a DAX file without this patchset?  If
>>> there's some bookkkeeping needed to make sure that the filesystem will
>>> invalidate all the mappings if it decides to move the file, maybe that
>>> should be the default rather than needing a new syscall.
>>
>> The bookkeeping to invalidate mappings when the filesystem moves a
>> block is already there.
>>
>> Without this patchset an application needs to call fsync/msync after
>> any write to a DAX mapping otherwise there is no guarantee the
>> filesystem has written the metadata to find the updated block after a
>> crash or power loss event. Even if the sync operation is reduced to a
>> minimal cmpxchg in userspace to check if the filesystem-metadata is
>> dirty, that mechanism doesn't translate to a virtualized environment,
>> as requiring guests to trigger host fsync()s is not feasible. It's a
>> half-step solution when you can instead just ask the filesystem to
>> never move blocks, as Dave proposed many months back.
>>
>> We stepped back from that proposal when it looked like a significant
>> amount of per-filesystem work to introduce the capability and it was
>> not clear that application developers would tolerate the side effects
>> of this 'immutable' semantic. However, the implementation is dead
>> simple since ext4 and xfs already need to make
>> block-allocation-immutable semantics available for swapfiles. We also
>> have application developers telling us they are ok with the semantics,
>> especially because it catches Linux up to other operating environments
>> that are already on board with allowing this type of access to pmem
>> through a filesystem. This patchset gives pmem application developers
>> what they want without any additional burden on filesystem
>> implementations.
>
> I see.
>
> I have a couple of minor-ish issues with the current proposal, then.
> One is that I think the terminology should be changed to still make
> sense if filesystems or VFS improves to make this approach
> unnecessary.  Rather than saying "this file is now static", perhaps
> users should set a flag with the explicit semantics that "mmaps of
> this file are guaranteed not to lose data due to the kernel's
> activities", IOW that mmaps will be at least as durable as a direct
> mapping of DAX memory.  Then the kernel has the flexibility to add a
> future implementation in which, instead of pinning the file, the
> filesystem just knows to keep metadata synced before allowing
> page_mkwrite to re-enable writes to an mmapped DAX file.

Yes, sounds good to me. Rename the flag to DAXCTL_F_SYNC to indicate
updates via mmap to this file are synchronous as far as block
allocation metadata is concerned. Future filesystems are then free to
always support this synchronous mode without using the swapfile hack.

> My other objection is that the syscall intentionally leaks a reference
> to the file.  This means it needs overflow protection and it probably
> shouldn't ever be allowed to use it without privilege.

We only hold the one reference while S_DAXFILE is set, so I think the
protection is there, and per Dave's original proposal this requires
CAP_LINUX_IMMUTABLE.

> Why can't the underlying issue be easily fixed, though?  Could
> .page_mkwrite just make sure that metadata is synced when the FS uses
> DAX?

Yes, it most definitely could and that idea has been floated.

> On a DAX fs, syncing metadata should be extremely fast.  This
> could be conditioned on an madvise or mmap flag if performance might
> be an issue.  As far as I know, this change alone should be
> sufficient.

The hang up is that it requires per-fs enabling as it needs to be
careful to manage mmap_sem vs fs journal locks for example. I know the
in-development NOVA [1] filesystem is planning to support this out of
the gate. ext4 would be open to implementing it, but I think xfs is
cold on the idea. Christoph originally proposed it here [2], before
Dave went on to propose immutable semantics.

[1]: https://github.com/NVSL/NOVA
[2]: https://lists.01.org/pipermail/linux-nvdimm/2016-February/004609.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
