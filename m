Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f174.google.com (mail-wi0-f174.google.com [209.85.212.174])
	by kanga.kvack.org (Postfix) with ESMTP id E639D82F64
	for <linux-mm@kvack.org>; Wed, 28 Oct 2015 05:27:55 -0400 (EDT)
Received: by wicll6 with SMTP id ll6so4961937wic.1
        for <linux-mm@kvack.org>; Wed, 28 Oct 2015 02:27:55 -0700 (PDT)
Received: from mail.anarazel.de (mail.anarazel.de. [217.115.131.40])
        by mx.google.com with ESMTP id ho2si55143065wjb.204.2015.10.28.02.27.54
        for <linux-mm@kvack.org>;
        Wed, 28 Oct 2015 02:27:54 -0700 (PDT)
Date: Wed, 28 Oct 2015 10:27:52 +0100
From: Andres Freund <andres@anarazel.de>
Subject: Re: Triggering non-integrity writeback from userspace
Message-ID: <20151028092752.GF29811@alap3.anarazel.de>
References: <20151022131555.GC4378@alap3.anarazel.de>
 <20151024213912.GE8773@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151024213912.GE8773@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

Hi,

Thanks for looking into this.

On 2015-10-25 08:39:12 +1100, Dave Chinner wrote:
> WB_SYNC_ALL is simply a method of saying "writeback all dirty pages
> and don't skip any". That's part of a data integrity operation, but
> it's not what results in data integrity being provided. It may cause
> some latencies caused by blocking on locks or in the request queues,
> so that's what I'd be looking for.

It also means we'll wait for more:
int write_cache_pages(struct address_space *mapping,
		      struct writeback_control *wbc, writepage_t writepage,
		      void *data)
{
...
	if (wbc->sync_mode == WB_SYNC_ALL || wbc->tagged_writepages)
		tag = PAGECACHE_TAG_TOWRITE;
	else
		tag = PAGECACHE_TAG_DIRTY;
...
			if (PageWriteback(page)) {
				if (wbc->sync_mode != WB_SYNC_NONE)
					wait_on_page_writeback(page);
				else
					goto continue_unlock;
			}

> i.e. if the request queues are full, SYNC_FILE_RANGE_WRITE will
> block until all the IO it has been requested to write has been
> submitted to the request queues. Put simply: the IO is asynchronous
> in that we don't wait for completion, but the IO submission is still
> synchronous.

That's desirable in our case because there's a limit to how much
outstanding IO there is.

> Data integrity operations require related file metadata (e.g. block
> allocation trnascations) to be forced to the journal/disk, and a
> device cache flush issued to ensure the data is on stable storage.
> SYNC_FILE_RANGE_WRITE does neither of these things, and hence while
> the IO might be the same pattern as a data integrity operation, it
> does not provide such guarantees.

Which is desired here - the actual integrity is still going to be done
via fsync(). The idea of using SYNC_FILE_RANGE_WRITE beforehand is that
the fsync() will only have to do very little work. The language in
sync_file_range(2) doesn't inspire enough confidence for using it as an
actual integrity operation :/

> > If I followed the code correctly - not a sure thing at all - that means
> > bios are submitted with WRITE_SYNC specified. Not really what's needed
> > in this case.
>
> That just allows the IO scheduler to classify them differently to
> bulk background writeback.

It also influences which writes are merged and which are not, at least
if I understand elv_rq_merge_ok() and the callbacks it calls..

> You don't want to do writeback from the syscall, right? i.e. you'd
> like to expire the inode behind the fd, and schedule background
> writeback to run on it immediately?

Yes, that's exactly what we want. Blocking if a process has done too
much writes is fine tho.

Greetings,

Andres Freund

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
