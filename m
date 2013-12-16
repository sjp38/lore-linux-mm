Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ea0-f182.google.com (mail-ea0-f182.google.com [209.85.215.182])
	by kanga.kvack.org (Postfix) with ESMTP id 486A46B0035
	for <linux-mm@kvack.org>; Mon, 16 Dec 2013 05:14:29 -0500 (EST)
Received: by mail-ea0-f182.google.com with SMTP id a15so2105919eae.41
        for <linux-mm@kvack.org>; Mon, 16 Dec 2013 02:14:28 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e2si12832084eeg.93.2013.12.16.02.14.28
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 16 Dec 2013 02:14:28 -0800 (PST)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH 0/3] Fix bugs in munlock
Date: Mon, 16 Dec 2013 11:14:13 +0100
Message-Id: <1387188856-21027-1-git-send-email-vbabka@suse.cz>
In-Reply-To: <52AE07B4.4020203@oracle.com>
References: <52AE07B4.4020203@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Sasha Levin <sasha.levin@oracle.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, joern@logfs.org, Michel Lespinasse <walken@google.com>, Vlastimil Babka <vbabka@suse.cz>

This patch mini-series is a result of Sasha Levin's bug reports via trinity.

First two patches are quite straightforward fixes for bugs introduced in 3.12,
and earlier versions have been tested. Sasha, can you please test the final
versions of the first two (together) again? The first one added an extra
VM_BUG_ON.

The third is based on me noticing there might still be an (older than 3.12)
race with a THP page split with non-fatal but still bad consequences, such as
pages being kept mlocked. Since this is quite rare and was not reported, any
review agreeing that it can really happen would be great. Testing as well, of
course.  So it's kind of RFC at this point.

Vlastimil Babka (3):
  mm: munlock: fix a bug where THP tail page is encountered
  mm: munlock: fix deadlock in __munlock_pagevec()
  mm: munlock: fix potential race with THP page split

 mm/mlock.c | 116 ++++++++++++++++++++++++++++++++++++++++---------------------
 1 file changed, 76 insertions(+), 40 deletions(-)

-- 
1.8.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
