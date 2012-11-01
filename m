Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx194.postini.com [74.125.245.194])
	by kanga.kvack.org (Postfix) with SMTP id 466C46B0074
	for <linux-mm@kvack.org>; Thu,  1 Nov 2012 18:56:45 -0400 (EDT)
Message-ID: <5092FE22.30906@panasas.com>
Date: Thu, 1 Nov 2012 15:56:34 -0700
From: Boaz Harrosh <bharrosh@panasas.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/3] bdi: Track users that require stable page writes
References: <20121101075805.16153.64714.stgit@blackbox.djwong.org> <20121101075813.16153.94581.stgit@blackbox.djwong.org> <5092BDA2.6090001@panasas.com> <20121101185756.GI19591@blackbox.djwong.org>
In-Reply-To: <20121101185756.GI19591@blackbox.djwong.org>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Darrick J. Wong" <darrick.wong@oracle.com>
Cc: axboe@kernel.dk, lucho@ionkov.net, tytso@mit.edu, sage@inktank.com, ericvh@gmail.com, mfasheh@suse.com, dedekind1@gmail.com, adrian.hunter@intel.com, dhowells@redhat.com, sfrench@samba.org, jlbec@evilplan.org, rminnich@sandia.gov, linux-cifs@vger.kernel.org, jack@suse.cz, martin.petersen@oracle.com, neilb@suse.de, david@fromorbit.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-mtd@lists.infradead.org, linux-fsdevel@vger.kernel.org, v9fs-developer@lists.sourceforge.net, ceph-devel@vger.kernel.org, linux-ext4@vger.kernel.org, linux-afs@lists.infradead.org, ocfs2-devel@oss.oracle.com

On 11/01/2012 11:57 AM, Darrick J. Wong wrote:
> On Thu, Nov 01, 2012 at 11:21:22AM -0700, Boaz Harrosh wrote:
>> On 11/01/2012 12:58 AM, Darrick J. Wong wrote:
>>> This creates a per-backing-device counter that tracks the number of users which
>>> require pages to be held immutable during writeout.  Eventually it will be used
>>> to waive wait_for_page_writeback() if nobody requires stable pages.
>>>
>>
>> There is two things I do not like:
>> 1. Please remind me why we need the users counter?
>>    If the device needs it, it will always be needed. The below 
>>    queue_unrequire_stable_pages call at blk_integrity_unregister
>>    only happens at device destruction time, no?
>>
>>    It was also said that maybe individual filesystems would need
>>    stable pages where other FSs using the same BDI do not. But
>>    since the FS is at the driving seat in any case, it can just
>>    do wait_for_writeback() regardless and can care less about
>>    the bdi flag and the other FSs. Actually all those FSs already
>>    do this this, and do not need any help. So this reason is
>>    mute.
> 
> The counter exists so that a filesystem can forcibly enable stable page writes
> even if the underlying device doesn't require it, because the generic fs/mm
> waiting only happens if stable_pages_required=1.  The idea here was to allow a
> filesystem that needs stable page writes for its own purposes (i.e. data block
> checksumming) to be able to enforce the requirement even if the disk doesn't
> care (or doesn't exist).
> 

But the filesystem does not need BDI flag to do that, It can just call
wait_on_page_writeback() directly and or any other waiting like cifs does,
and this way will not affect any other partitions of the same BDI. So this flag
is never needed by the FS, it is always to service the device.

> But maybe there are no such filesystems?
> 

Exactly, all the FSs that do care, already take care of it.

> <shrug> I don't really like the idea that you can dirty a page during writeout,
> which means that the disk could write the before page, the after page, or some
> weird mix of the two, and all you get is a promise that the after page will get
> rewritten if the power doesn't go out.  Not to mention that it could happen
> again. :)
> 

I guess that's life. But what is the difference between a modification of a page
that comes 1 nanosecond before the end_write_back, and another one that came
1 nano after end_write_back. To the disk it looks like the same load pattern.

I do have in mind a way that we can minimize these redirty-while-writeback by 90% but
I don't care enough (And am not paid) to fix it, so the contention is currently worse
then what it could be.

>> 2. I hate the atomic_read for every mkwrite. I think we can do
>>    better, since as you noted it can never be turned off, only
>>    on, at init time. And because of 1. above it is not dynamic.
>>    I think I like your previous simple bool better.
> 
> I doubt the counter would change much; I could probably change it to something
> less heavyweight if it's really a problem.
> 

I hope you are convinced that a counter is not needed, and a simple bool like
before is enough

Thanks
Boaz

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
