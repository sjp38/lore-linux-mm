Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 180636B003D
	for <linux-mm@kvack.org>; Thu,  5 Feb 2009 22:12:54 -0500 (EST)
Message-Id: <20090206031125.693559239@cmpxchg.org>
Date: Fri, 06 Feb 2009 04:11:25 +0100
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [PATCH 0/3] [PATCH 0/3] swsusp: shrink file cache first
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Rafael J. Wysocki" <rjw@sisk.pl>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

[ grumble.  always check software for new behaviour after upgrade.
  sorry for the mess up :/ ]

Hello!

here are three patches that adjust the memory shrinking code used for
suspend-to-disk.

The first two patches are cleanups only and can probably go in
regardless of the third one.

The third patch changes the shrink_all_memory() logic to drop the file
cache first before touching any mapped files and only then goes for
anon pages.

The reason is that everything not shrunk before suspension has to go
into the image and will be 'prefaulted' before the processes can
resume and the system is usable again, so the image should be small
and contain only pages that are likely to be used right after resume
again.  And this in turn means that the inactive file cache is the
best point to start decimating used memory.

Also, right now, subsequent faults of contiguously mapped files are
likely to perform better than swapin (see
http://kernelnewbies.org/KernelProjects/SwapoutClustering), so not
only file cache is preferred over other pages, but file pages over
anon pages in general.

Testing up to this point shows that the patch does what is intended,
shrinking file cache in favor of anon pages.  But whether the idea is
correct to begin with is a bit hard to quantify and I am still working
on it, so RFC only.

	Hannes

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
