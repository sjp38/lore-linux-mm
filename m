Received: from mate.bln.innominate.de (cerberus.innominate.de [212.84.234.251])
	by hermes.mixx.net (Postfix) with ESMTP id 2AEC8F803
	for <linux-mm@kvack.org>; Tue, 15 Aug 2000 10:32:33 +0200 (CEST)
From: Daniel Phillips <news-innominate.list.linux.mm@innominate.de>
Reply-To: Daniel Phillips <daniel.phillips@innominate.de>
Subject: Syncing the page cache, take 2
Date: Tue, 15 Aug 2000 10:32:14 +0200
Message-ID: <news2mail-3999000E.4BED1557@innominate.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

My earlier attempt to state the problem was not as clear as it could have been.

This is really a VFS problem not a mm problem per se, but since the two have
become so closely intertwined I'm bringing it up here.

There seems to be something missing in the current VFS (please correct me if I'm
wrong): the sync code totally ignores the page cache, so when you do a sync
you're only syncing the buffer cache and not file data that may have been mapped
into the page cache by file_write or file_mmap.

OK, if that is indeed the case then it needs to be fixed.

Since it needs to be fixed then this is a good time to state a particular need
that I have in my filesystem project: for optimal operation I need to be able to
sync the page cache to the buffer cache selectively.  An appropriate granularity
would be per-mapping.  So I would like to have a VFS call something like:

    void write_mapping_now (struct address_space *mapping, int sync)

This is modelled on the write_inode_now function.  (Not that I think that's the
greatest name in the world - I'm just trying to continue the pattern.)  The
exact semantics of write_mapping_now would likely be subject to considerable
discussion, but its effect on the page case is clear: for every dirty page in
the 
mapping address_space_operations->writepage should be called once.  This would
give me the syncing ability I need.

Arguably, write_mapping_now should be called by write_inode_now.

--
Daniel



-- 
Daniel
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
