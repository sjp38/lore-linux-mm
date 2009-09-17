Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id E666F6B0055
	for <linux-mm@kvack.org>; Thu, 17 Sep 2009 11:21:43 -0400 (EDT)
From: Jan Kara <jack@suse.cz>
Subject: [RFC] [PATCH 0/7] Improve VFS to handle better mmaps when blocksize < pagesize (v3)
Date: Thu, 17 Sep 2009 17:21:40 +0200
Message-Id: <1253200907-31392-1-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
To: linux-fsdevel@vger.kernel.org
Cc: LKML <linux-kernel@vger.kernel.org>, linux-ext4@vger.kernel.org, linux-mm@kvack.org, npiggin@suse.de
List-ID: <linux-mm.kvack.org>


  Hi,

  here is my next attempt to solve a problems arising with mmaped writes when
blocksize < pagesize. To recall what's the problem:

We'd like to use page_mkwrite() to allocate blocks under a page which is
becoming writeably mmapped in some process address space. This allows a
filesystem to return a page fault if there is not enough space available, user
exceeds quota or similar problem happens, rather than silently discarding data
later when writepage is called.

On filesystems where blocksize < pagesize the situation is complicated though.
Think for example that blocksize = 1024, pagesize = 4096 and a process does:
  ftruncate(fd, 0);
  pwrite(fd, buf, 1024, 0);
  map = mmap(NULL, 4096, PROT_WRITE, MAP_SHARED, fd, 0);
  map[0] = 'a';  ----> page_mkwrite() for index 0 is called
  ftruncate(fd, 10000); /* or even pwrite(fd, buf, 1, 10000) */
  fsync(fd); ----> writepage() for index 0 is called

At the moment page_mkwrite() is called, filesystem can allocate only one block
for the page because i_size == 1024. Otherwise it would create blocks beyond
i_size which is generally undesirable. But later at writepage() time, we would
like to have blocks allocated for the whole page (and in principle we have to
allocate them because user could have filled the page with data after the
second ftruncate()).
---

  The patches depend on Nick's truncate calling convention rewrite. The first
three patches in the patchset are just cleanups. The series converts ext4 and
ext2 filesystems just to give an idea how conversion of a filesystem will
look like.
  A few notes to the changes the main patch (patch number 4) does:
1) zeroing of tail of the last block now does not happen in writepage (which is
racy anyway as Nick pointed out) and foo_truncate_page but rather when i_size
is going to be extended.
2) writeback path does not care about i_size anymore, it uses buffer flags
instead. An exception is a nobh case where we have to use i_size. Thus
filesystems not using nobh code can update i_size in write_end without holding
page_lock.  Filesystems using nobh code still have to update i_size under the
page_lock since otherwise __mpage_writepage could come early, write just part
of the page, and clear all dirty bits, thus causing a data loss.
3) converted filesystems have to make sure that the buffers with valid data
to write are either mapped or delay before they call block_write_full_page.
The idea is that they should use page_mkwrite() to setup buffers.

  Both ext2 and ext4 have survived some beating with fsx-linux so they should
be at least moderately safe to use :). Any comments?
									Honza

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
