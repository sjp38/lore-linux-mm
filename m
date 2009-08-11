Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 3D4C66B004F
	for <linux-mm@kvack.org>; Mon, 10 Aug 2009 23:51:03 -0400 (EDT)
Received: from mlsv1.hitachi.co.jp (unknown [133.144.234.166])
	by mail4.hitachi.co.jp (Postfix) with ESMTP id 2BCB733CC9
	for <linux-mm@kvack.org>; Tue, 11 Aug 2009 12:51:05 +0900 (JST)
Message-ID: <4A80EAA3.7040107@hitachi.com>
Date: Tue, 11 Aug 2009 12:50:59 +0900
From: Hidehiro Kawai <hidehiro.kawai.ez@hitachi.com>
MIME-Version: 1.0
Subject: Re: [PATCH] [16/19] HWPOISON: Enable .remove_error_page for migration
    aware file systems
References: <200908051136.682859934@firstfloor.org>
    <20090805093643.E0C00B15D8@basil.firstfloor.org>
    <4A7FBFD1.2010208@hitachi.com> <20090810074421.GA6838@basil.fritz.box>
In-Reply-To: <20090810074421.GA6838@basil.fritz.box>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: tytso@mit.edu, hch@infradead.org, mfasheh@suse.com, aia21@cantab.net, hugh.dickins@tiscali.co.uk, swhiteho@redhat.com, akpm@linux-foundation.org, npiggin@suse.de, linux-kernel@vger.kernel.org, linux-mm@kvack.org, fengguang.wu@intel.com, Satoshi OSHIMA <satoshi.oshima.fk@hitachi.com>, Taketoshi Sakuraba <taketoshi.sakuraba.hc@hitachi.com>
List-ID: <linux-mm.kvack.org>

Andi Kleen wrote:

>>1. An uncorrected error on a dirty page cache page is detected by
>>   memory scrubbing
>>2. Kernel unmaps and truncates the page to recover from the error
>>3. An application reads data from the file location corresponding
>>   to the truncated page
>>   ==> Old or garbage data will be read into a new page cache page
> 
> The problem currently is that the error is not sticky enough and
> doesn't stay around long enough. It gets reported once,
> but not in later IO operations.
> 
> However it's a generic problem not unique to hwpoison. Me 

Yes, it's a generic problem, and introducing a sticky error flag
is one of the approach to solve the problem.  I think it is a good
approach because it doesn't depend on individual filesystems.

> And application
> that doesn't handle current IO errors correctly will also
> not necessarily handle hwpoison correctly (it's not better and not worse)

This is my main concern.  I'd like to prevent re-corruption even if
applications don't have good manners.

As for usual I/O error, ext3/4 can now do it by using data=ordered and
data_err=abort mount options.  Moreover, if you mount the ext3/4
filesystem with the additional errors=panic option, kernel gets
panic on write error instead of read-only remount.  Customers
who regard data integrity is very important require these features.

But this patch (PATCH 16/19) introduce this problem again, because
it doesn't provide a way to shut out further writes to the fs.
Of course, we can do it by setting tolerant level to 0 or
memory_failure_recovery to 0.  But it would be overkill.
That is why I suggested this:
>>(2) merge this patch with new panic_on_dirty_page_cache_corruption
>>    sysctl


> That is something that could be improved in the VFS -- although I fear
> any improvements here could also break compatibility. I don't think
> it's a blocker on hwpoison for now. It needs more design
> effort and thinking (e.g. likely the address space IO error
> bit should be separated into multiple bits)
> 
> Perhaps you're interested in working on this?

Yes.  Transient IO errors have a potential for causing re-corruption
problem.  Now ext3/4 provide ways to prevent it, but not the other
filesystems.  We would need a generic way.
 
>>4. The application modifies the data and write back it to the disk
>>5. The file will corrurpt!
>>
>>(Yes, the application is wrong to not do the right thing, i.e. fsync,
>> but it's not user's fault!)
>>
>>A similar data corruption can be caused by a write I/O error,
>>because dirty flag is cleared even if the page couldn't be written
>>to the disk.
>>
>>However, we have a way to avoid this kind of data corruption at
>>least for ext3.  If we mount an ext3 filesystem with data=ordered
>>and data_err=abort, all I/O errors on file data block belonging to
>>the committing transaction are checked.  When I/O error is found,
>>abort journaling and remount the filesystem with read-only to
>>prevent further updates.  This kind of feature is very important
>>for mission critical systems.
> 
> Well it sounds like a potentially useful enhancement to ext3 (or ext4).
> 
> One issue is that the default is not ordered anymore since
> Linus changed the default.

Yes, but what is important is whether the system provides
such feature or not.

> I'm sure other enhancements for IO errors could be done too.
> Some of the file systems also handle them still quite poorly (e.g. btrfs)
> 
> But again I don't think it's a blocker for hwpoison.

Unfortunately, it can be a blocker.  As I stated, we can block the
possible re-corruption caused by transient IO errors on ext3/4
filesystems.  But applying this patch (PATCH 16/19), re-corruption
can happen even if we use data=ordered, data_err=abort and
errors=panic mount options.

So...

>>I think there are three options,
>>
>>(1) drop this patch
>>(2) merge this patch with new panic_on_dirty_page_cache_corruption
>>    sysctl
>>(3) implement a more sophisticated error_remove_page function
> 
> (4) accept that hwpoison error handling is not better and not worse than normal
> IO error handling.
> 
> We opted for (4).

Could you consider adopting (2) or (3)?  Fengguang's sticky EIO
approach (http://lkml.org/lkml/2009/6/11/294) is also OK.
I hope HWPOISON patches are merged into 2.6.32.  So (2) is the
best answer for me, because it's simple and less intrusive.

Thanks,
-- 
Hidehiro Kawai
Hitachi, Systems Development Laboratory
Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
