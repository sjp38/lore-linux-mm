Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f174.google.com (mail-wi0-f174.google.com [209.85.212.174])
	by kanga.kvack.org (Postfix) with ESMTP id CA3086B0038
	for <linux-mm@kvack.org>; Thu, 22 Oct 2015 09:16:54 -0400 (EDT)
Received: by wijp11 with SMTP id p11so31611631wij.0
        for <linux-mm@kvack.org>; Thu, 22 Oct 2015 06:16:54 -0700 (PDT)
Received: from mail.anarazel.de (mail.anarazel.de. [217.115.131.40])
        by mx.google.com with ESMTP id hr11si17447066wib.96.2015.10.22.06.16.53
        for <linux-mm@kvack.org>;
        Thu, 22 Oct 2015 06:16:53 -0700 (PDT)
Date: Thu, 22 Oct 2015 15:15:55 +0200
From: Andres Freund <andres@anarazel.de>
Subject: Triggering non-integrity writeback from userspace
Message-ID: <20151022131555.GC4378@alap3.anarazel.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

Hi,

postgres regularly has to checkpoint data to disk to be able to free
data from its journal. We currently use buffered IO and that's not
going to change short term.

In a busy database this checkpointing process can write out a lot of
data. Currently that frequently leads to massive latency spikes
(c.f. 20140326191113.GF9066@alap3.anarazel.de) for other processed doing
IO. These happen either when the kernel starts writeback or when, at the
end of the checkpoint, we issue an fsync() on the datafiles.

One odd issue there is that the kernel tends to do writeback in a very
irregular manner. Even if we write data at a constant rate writeback
very often happens in bulk - not a good idea for preserving
interactivity.

What we're preparing to do now is to regularly issue
sync_file_range(SYNC_FILE_RANGE_WRITE) on a few blocks shortly after
we've written them to to the OS. That way there's not too much dirty
data in the page cache, so writeback won't cause latency spikes, and the
fsync at the end doesn't have to write much if anything.

That improves things a lot.

But I still see latency spikes that shouldn't be there given the amount
of IO. I'm wondering if that is related to the fact that
SYNC_FILE_RANGE_WRITE ends up doing __filemap_fdatawrite_range with
WB_SYNC_ALL specified. Given the the documentation for
SYNC_FILE_RANGE_WRITE I did not expect that:
 * SYNC_FILE_RANGE_WRITE: start writeout of all dirty pages in the range which
 * are not presently under writeout.  This is an asynchronous flush-to-disk
 * operation.  Not suitable for data integrity operations.

If I followed the code correctly - not a sure thing at all - that means
bios are submitted with WRITE_SYNC specified. Not really what's needed
in this case.

Now I think the docs are somewhat clear that SYNC_FILE_RANGE_WRITE isn't
there for data integrity, but it might be that people rely on in
nonetheless. so I'm loathe to suggest changing that. But I do wonder if
there's a way non-integrity writeback triggering could be exposed to
userspace. A new fadvise flags seems like a good way to do that -
POSIX_FADV_DONTNEED actually does non-integrity writeback, but also does
other things, so it's not suitable for us.

Greetings,

Andres Freund

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
