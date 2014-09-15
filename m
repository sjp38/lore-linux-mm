Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f53.google.com (mail-yh0-f53.google.com [209.85.213.53])
	by kanga.kvack.org (Postfix) with ESMTP id 2734C6B0037
	for <linux-mm@kvack.org>; Mon, 15 Sep 2014 14:51:05 -0400 (EDT)
Received: by mail-yh0-f53.google.com with SMTP id b6so1402773yha.40
        for <linux-mm@kvack.org>; Mon, 15 Sep 2014 11:51:04 -0700 (PDT)
Received: from imap.thunk.org (imap.thunk.org. [2600:3c02::f03c:91ff:fe96:be03])
        by mx.google.com with ESMTPS id a7si10797327yhd.106.2014.09.15.11.51.04
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Mon, 15 Sep 2014 11:51:04 -0700 (PDT)
Subject: Best way to pin a page in ext4?
From: Theodore Ts'o <tytso@mit.edu>
Message-Id: <20140915185102.0944158037A@closure.thunk.org>
Date: Mon, 15 Sep 2014 14:51:01 -0400 (EDT)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-ext4@vger.kernel.org

Hi,

In ext4, we currently use the page cache to store the allocation
bitmaps.  The pages are associated with an internal, in-memory inode
which is located in EXT4_SB(sb)->s_buddy_cache.  Since the pages can be
reconstructed at will, either by reading them from disk (in the case of
the actual allocation bitmap), or by calculating the buddy bitmap from
the allocation bitmap, normally we allow the VM to eject the pags as
necessary.

For a specialty use case, I've been requested to have an optional mode
where the on-disk bitmaps are pinned into memory; this is a situation
where the file system size is known in advance, and the user is willing
to trade off the locked-down memory for the latency gains required by
this use case.

It seems that the simplest way to do that is to use mlock_vma_page()
when the file system is first mounted, and then use munlock_vma_page()
when the file system is unmounted.  However, these functions are in
mm/internal.h, so I figured I'd better ask permission before using
them.   Does this sound like a sane way to do things?

The other approach would be to keep an elevated refcount on the pages in
question, but it seemed it would be more efficient use the mlock
facility since that keeps the pages on an unevictable list.

Does using the mlock/munlock_vma_page() functions make sense?   Any
pitfalls I should worry about?   Note that these pages are never mapped
into userspace, so there is no associated vma; fortunately the functions
don't take a vma argument, their name notwithstanding.....

Thanks,

                                        - Ted

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
