Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx188.postini.com [74.125.245.188])
	by kanga.kvack.org (Postfix) with SMTP id C89466B006C
	for <linux-mm@kvack.org>; Fri, 31 Aug 2012 18:22:13 -0400 (EDT)
From: Lukas Czerner <lczerner@redhat.com>
Subject: [PATCH 00/15 v2] Add invalidatepage_range address space operation
Date: Fri, 31 Aug 2012 18:21:36 -0400
Message-Id: <1346451711-1931-1-git-send-email-lczerner@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-fsdevel@vger.kernel.org
Cc: linux-ext4@vger.kernel.org, tytso@mit.edu, hughd@google.com, linux-mm@kvack.org

This set of patches are aimed to allow truncate_inode_pages_range() handle
ranges which are not aligned at the end of the page. Currently it will
hit BUG_ON() when the end of the range is not aligned. Punch hole feature
however can benefit from this ability saving file systems some work not
forcing them to implement their own invalidate code to handle unaligned
ranges.

In order for this to work we need however new address space operation
invalidatepage_range which should be able to handle page invalidation with
offset and length specified.

patch 01:	Implements the new invalidatepage_range address space
		operation in the mm layer
patch 02 - 05:	Wire the new invalidatepage_range aop to the ext4, xfs and
		ocfs2 file system (which are currently the only file
		systems supporting punch hole not counting tmpfs which has
		its own method) and implement this
		functionality for jbd2 as well.
patch 06:	Change truncate_inode_pages_range() to handle unaligned
		ranges.
patch 07 - 15:	Ext4 specific changes which take benefit from the
		previous truncate_inode_pages_range() change. Not all
		are realated specifically to this change, but all are
		related to the punch hole feature.

v2: Change invalidatepage_range lenght and offset argument to be 'unsigned int'
    Fix range provided to do_invalidatepage_range() in truncate_inode_pages_range()

Thanks!
-Lukas


[PATCH 01/15 v2] mm: add invalidatepage_range address space operation
[PATCH 02/15 v2] jbd2: implement jbd2_journal_invalidatepage_range
[PATCH 03/15 v2] ext4: implement invalidatepage_range aop
[PATCH 04/15 v2] xfs: implement invalidatepage_range aop
[PATCH 05/15 v2] ocfs2: implement invalidatepage_range aop
[PATCH 06/15 v2] mm: teach truncate_inode_pages_range() to handle non
[PATCH 07/15 v2] ext4: Take i_mutex before punching hole
[PATCH 08/15 v2] Revert "ext4: remove no longer used functions in
[PATCH 09/15 v2] Revert "ext4: fix fsx truncate failure"
[PATCH 10/15 v2] ext4: use ext4_zero_partial_blocks in punch_hole
[PATCH 11/15 v2] ext4: remove unused discard_partial_page_buffers
[PATCH 12/15 v2] ext4: remove unused code from ext4_remove_blocks()
[PATCH 13/15 v2] ext4: update ext4_ext_remove_space trace point
[PATCH 14/15 v2] ext4: make punch hole code path work with bigalloc
[PATCH 15/15 v2] ext4: Allow punch hole with bigalloc enabled

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
