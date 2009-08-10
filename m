Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id C8F706B005A
	for <linux-mm@kvack.org>; Mon, 10 Aug 2009 03:44:23 -0400 (EDT)
Date: Mon, 10 Aug 2009 09:44:21 +0200
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] [16/19] HWPOISON: Enable .remove_error_page for
	migration aware file systems
Message-ID: <20090810074421.GA6838@basil.fritz.box>
References: <200908051136.682859934@firstfloor.org> <20090805093643.E0C00B15D8@basil.firstfloor.org> <4A7FBFD1.2010208@hitachi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4A7FBFD1.2010208@hitachi.com>
Sender: owner-linux-mm@kvack.org
To: Hidehiro Kawai <hidehiro.kawai.ez@hitachi.com>
Cc: Andi Kleen <andi@firstfloor.org>, tytso@mit.edu, hch@infradead.org, mfasheh@suse.com, aia21@cantab.net, hugh.dickins@tiscali.co.uk, swhiteho@redhat.com, akpm@linux-foundation.org, npiggin@suse.de, linux-kernel@vger.kernel.org, linux-mm@kvack.org, fengguang.wu@intel.com
List-ID: <linux-mm.kvack.org>

Hi,

> If my understanding is correct, the following scenario can happen:

Yes it can happen.

> 
> 1. An uncorrected error on a dirty page cache page is detected by
>    memory scrubbing
> 2. Kernel unmaps and truncates the page to recover from the error
> 3. An application reads data from the file location corresponding
>    to the truncated page
>    ==> Old or garbage data will be read into a new page cache page

The problem currently is that the error is not sticky enough and
doesn't stay around long enough. It gets reported once,
but not in later IO operations.

However it's a generic problem not unique to hwpoison. Me 
and Fengguang went through the error propagation as our test program
triggered the problem and we looked like it was really a generic problem,
not unique to hardware poison (e.g. the IO error handling 
on metadata has exactly the same problem)

And redesigning VFS IO error reporting was a bit of of scope for hwpoison.
So we decided to not be better than a normal IO error here for now.

An application that handles current IO errors correctly will
also also handle hwpoison IO errors correctly. And application
that doesn't handle current IO errors correctly will also
not necessarily handle hwpoison correctly (it's not better and not worse)
So the hwpoison errors are pretty much the same as the normal IO
errors.

The normal error path probably needs some improvements, in particular
the address space EIO error error likely needs to be more sticky
than it is today.

An application has to handle the error on the first strike.

That is something that could be improved in the VFS -- although I fear
any improvements here could also break compatibility. I don't think
it's a blocker on hwpoison for now. It needs more design
effort and thinking (e.g. likely the address space IO error
bit should be separated into multiple bits)

Perhaps you're interested in working on this?

> 4. The application modifies the data and write back it to the disk
> 5. The file will corrurpt!
> 
> (Yes, the application is wrong to not do the right thing, i.e. fsync,
>  but it's not user's fault!)
> 
> A similar data corruption can be caused by a write I/O error,
> because dirty flag is cleared even if the page couldn't be written
> to the disk.
> 
> However, we have a way to avoid this kind of data corruption at
> least for ext3.  If we mount an ext3 filesystem with data=ordered
> and data_err=abort, all I/O errors on file data block belonging to
> the committing transaction are checked.  When I/O error is found,
> abort journaling and remount the filesystem with read-only to
> prevent further updates.  This kind of feature is very important
> for mission critical systems.

Well it sounds like a potentially useful enhancement to ext3 (or ext4).

One issue is that the default is not ordered anymore since
Linus changed the default.

I'm sure other enhancements for IO errors could be done too.
Some of the file systems also handle them still quite poorly (e.g. btrfs)

But again I don't think it's a blocker for hwpoison.

> I think there are three options,
> 
> (1) drop this patch
> (2) merge this patch with new panic_on_dirty_page_cache_corruption
>     sysctl
> (3) implement a more sophisticated error_remove_page function

(4) accept that hwpoison error handling is not better and not worse than normal
IO error handling.

We opted for (4).


-Andi
-- 
ak@linux.intel.com -- Speaking for myself only.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
