Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f175.google.com (mail-wi0-f175.google.com [209.85.212.175])
	by kanga.kvack.org (Postfix) with ESMTP id 8057C6B0038
	for <linux-mm@kvack.org>; Sun, 25 Oct 2015 00:14:48 -0400 (EDT)
Received: by wijp11 with SMTP id p11so123553485wij.0
        for <linux-mm@kvack.org>; Sat, 24 Oct 2015 21:14:47 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id bn7si2813401wjc.186.2015.10.24.21.14.46
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Sat, 24 Oct 2015 21:14:47 -0700 (PDT)
Date: Sat, 24 Oct 2015 21:09:56 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: Triggering non-integrity writeback from userspace
Message-ID: <20151024190956.GA17642@quack.suse.cz>
References: <20151022131555.GC4378@alap3.anarazel.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151022131555.GC4378@alap3.anarazel.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andres Freund <andres@anarazel.de>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

  Hi,

On Thu 22-10-15 15:15:55, Andres Freund wrote:
> postgres regularly has to checkpoint data to disk to be able to free
> data from its journal. We currently use buffered IO and that's not
> going to change short term.
> 
> In a busy database this checkpointing process can write out a lot of
> data. Currently that frequently leads to massive latency spikes
> (c.f. 20140326191113.GF9066@alap3.anarazel.de) for other processed doing
> IO. These happen either when the kernel starts writeback or when, at the
> end of the checkpoint, we issue an fsync() on the datafiles.
> 
> One odd issue there is that the kernel tends to do writeback in a very
> irregular manner. Even if we write data at a constant rate writeback
> very often happens in bulk - not a good idea for preserving
> interactivity.
> 
> What we're preparing to do now is to regularly issue
> sync_file_range(SYNC_FILE_RANGE_WRITE) on a few blocks shortly after
> we've written them to to the OS. That way there's not too much dirty
> data in the page cache, so writeback won't cause latency spikes, and the
> fsync at the end doesn't have to write much if anything.
> 
> That improves things a lot.
> 
> But I still see latency spikes that shouldn't be there given the amount
> of IO. I'm wondering if that is related to the fact that
> SYNC_FILE_RANGE_WRITE ends up doing __filemap_fdatawrite_range with
> WB_SYNC_ALL specified. Given the the documentation for
> SYNC_FILE_RANGE_WRITE I did not expect that:
>  * SYNC_FILE_RANGE_WRITE: start writeout of all dirty pages in the range which
>  * are not presently under writeout.  This is an asynchronous flush-to-disk
>  * operation.  Not suitable for data integrity operations.
> 
> If I followed the code correctly - not a sure thing at all - that means
> bios are submitted with WRITE_SYNC specified. Not really what's needed
> in this case.
> 
> Now I think the docs are somewhat clear that SYNC_FILE_RANGE_WRITE isn't
> there for data integrity, but it might be that people rely on in
> nonetheless. so I'm loathe to suggest changing that. But I do wonder if
> there's a way non-integrity writeback triggering could be exposed to
> userspace. A new fadvise flags seems like a good way to do that -
> POSIX_FADV_DONTNEED actually does non-integrity writeback, but also does
> other things, so it's not suitable for us.

You are absolutely correct that sync_file_range() should issue writeback as
WB_SYNC_NONE and not wait for current writeback in progress. That was an
oversight introduced by commit ee53a891f474 (mm: do_sync_mapping_range
integrity fix) which changed do_sync_mapping_range() to use WB_SYNC_ALL
because it had other users which relied WB_SYNC_ALL semantics. Later that
got copied over to the current sync_file_range() implementation.

I think we should just revert to the very explicitely documented behavior
of sync_file_range(). I'll send a patch for that. Thanks for report.

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
