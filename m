Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 6F04A8D0002
	for <linux-mm@kvack.org>; Wed, 17 Nov 2010 07:24:24 -0500 (EST)
Received: from kpbe20.cbf.corp.google.com (kpbe20.cbf.corp.google.com [172.25.105.84])
	by smtp-out.google.com with ESMTP id oAHCOJlW032459
	for <linux-mm@kvack.org>; Wed, 17 Nov 2010 04:24:19 -0800
Received: from gxk22 (gxk22.prod.google.com [10.202.11.22])
	by kpbe20.cbf.corp.google.com with ESMTP id oAHCOGwu022709
	for <linux-mm@kvack.org>; Wed, 17 Nov 2010 04:24:18 -0800
Received: by gxk22 with SMTP id 22so314324gxk.29
        for <linux-mm@kvack.org>; Wed, 17 Nov 2010 04:24:16 -0800 (PST)
From: Michel Lespinasse <walken@google.com>
Subject: [PATCH 0/3] Avoid dirtying pages during mlock
Date: Wed, 17 Nov 2010 04:23:55 -0800
Message-Id: <1289996638-21439-1-git-send-email-walken@google.com>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Kosaki Motohiro <kosaki.motohiro@jp.fujitsu.com>, Peter Zijlstra <peterz@infradead.org>, Nick Piggin <npiggin@kernel.dk>, Theodore Tso <tytso@google.com>, Michael Rubin <mrubin@google.com>, Suleiman Souhlal <suleiman@google.com>
List-ID: <linux-mm.kvack.org>

As discussed in linux-mm, mlocking a shared, writable vma currently causes
the corresponding pages to be marked as dirty and queued for writeback.
This seems rather unnecessary given that the pages are not being actually
modified during mlock. It is understood that for non-shared mappings
(file or anon) we want to use a write fault in order to break COW, but
there is just no such need for shared mappings.

The first two patches in this series do not introduce any behavior change.
The intent there is to make it obvious that dirtying file pages is
only done in the (writable, shared) case.  I think this clarifies the
code, but I wouldn't mind dropping these two patches if there is no
consensus about them.

The last patch is where we actually avoid dirtying shared mappings
during mlock. Note that as a side effect of this, we won't call
page_mkwrite() for the mappings that define it, and won't be
pre-allocating data blocks at the FS level if the mapped file was
sparsely allocated. My understanding is that mlock does not need to
provide such guarantee, as evidenced by the fact that it never did for
the filesystems that don't define page_mkwrite() - including some
common ones like ext3. However, I would like to gather feedback on this
from filesystem people as a precaution. If this turns out to be a
showstopper, maybe block preallocation can be added back on using a
different interface.

Large shared mlocks are getting significantly (>2x) faster in my tests,
as the disk can be fully used for reading the file instead of having to
share between this and writeback.

Michel Lespinasse (3):
  do_wp_page: remove the 'reuse' flag
  do_wp_page: clarify dirty_page handling
  mlock: avoid dirtying pages and triggering writeback

 mm/memory.c |   90 ++++++++++++++++++++++++++++++++---------------------------
 mm/mlock.c  |    7 ++++-
 2 files changed, 55 insertions(+), 42 deletions(-)

-- 
1.7.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
