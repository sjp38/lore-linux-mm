Message-ID: <45751712.80301@yahoo.com.au>
Date: Tue, 05 Dec 2006 17:52:02 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Status of buffered write path (deadlock fixes)
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux Memory Management <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, linux-kernel <linux-kernel@vger.kernel.org>
Cc: Mark Fasheh <mark.fasheh@oracle.com>, OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>, Andrew Morton <akpm@google.com>
List-ID: <linux-mm.kvack.org>

Hi,

I'd like to try to state where we are WRT the buffered write patches,
and ask for comments. Sorry for the wide cc list, but this is an
important issue which hasn't had enough review.

Well the next -mm will include everything we've done so far. I won't
repost patches unless someone would like to comment on a specific one.

I think the core generic_file_buffered_write is fairly robust, after
fixing the efault and zerolength iov problems picked up in testing
(thanks, very helpful!).

So now I *believe* we have an approach that solves the deadlock and
doesn't expose transient or stale data, transient zeroes, or anything
like that.

Error handling is getting close, but there may be cases that nobody
has picked up, and I've noticed a couple which I'll explain below.

I think we do the right thing WRT pagecache error handling: a
!uptodate page remains !uptodate, an uptodate page can handle the
write being done in several parts. Comments in the patches attempt
to explain how this works. I think it is pretty straightforward.

But WRT block allocation in the case of errors, it needs more review.

Block allocation:
- prepare_write can allocate blocks
- prepare_write doesn't need to initialize the pagecache on top of
   these blocks where it is within the range specified in prepare_write
   (because the copy_from_user will initialise it correctly)
- In the case of a !uptodate page, unless the page is brought uptodate
   (ie the copy_from_user completely succeeds) and marked dirty, then
   a read that sneaks in after we unlock the page (to retry the write)
   will try to bring it uptodate by pulling in the uninitialised blocks.

Problem 1:
I think that allocating blocks outside i_size is OK WRT uninitialised
data, because we update i_size only after a successful copy. However,
I don't think we trim these blocks off (eg. perhaps the "prepare_write
may have instantiated a few blocks" path should be the normal error
path for both the copy_from_user and the commit_write error cases as
well?)

We allocate blocks within holes, but these don't need to be trimmed: it
is enough to just zero out any new buffers. It might be nicer if we had
some kind of way to punch a hole, but it is a rare corner case.

Problem 2:
nobh error handling[*]. We have just a single buffer that is used for
each block in the prepare_write path, so the "zero new buffers" trick
doesn't work.

I think one solution to this could be to allocate all buffers for the
page like normal, and then strip them off when commit_write succeeds?
This would allow the zero_new_buffers path to work properly.

[*] Actually I think there is a problem with the mainline nobh error
handling in that a whole page of blocks will get zeroed on failure,
even valid data that isn't being touched by the write.

Finally, filesystems. Only OGAWA Hirofumi and Mark Fasheh have given much
feedback so far. I've tried to grok ext2/3 and think they'll work OK, and
have at least *looked* at all the rest. However in the worst case, there
might be many subtle and different problems :( Filesystem developers need
to review this, please. I don't want to cc every filesystem dev list, but
if anybody thinks it would be helpful to forward this then please do.

Well, that's about where its at. Block allocation problems 1 and 2
shouldn't be too hard to fix, but I would like confirmation / suggestions.

Thanks,
Nick

--
SUSE Labs, Novell Inc.

Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
