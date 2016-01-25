Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f45.google.com (mail-wm0-f45.google.com [74.125.82.45])
	by kanga.kvack.org (Postfix) with ESMTP id AC1C96B0005
	for <linux-mm@kvack.org>; Mon, 25 Jan 2016 05:03:26 -0500 (EST)
Received: by mail-wm0-f45.google.com with SMTP id l65so56912425wmf.1
        for <linux-mm@kvack.org>; Mon, 25 Jan 2016 02:03:26 -0800 (PST)
Received: from outbound-smtp09.blacknight.com (outbound-smtp09.blacknight.com. [46.22.139.14])
        by mx.google.com with ESMTPS id z187si23390722wmb.114.2016.01.25.02.03.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Jan 2016 02:03:25 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail03.blacknight.ie [81.17.254.16])
	by outbound-smtp09.blacknight.com (Postfix) with ESMTPS id 322361C1456
	for <linux-mm@kvack.org>; Mon, 25 Jan 2016 10:03:25 +0000 (GMT)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 0/2] Avoid unnecessary page locks in the generic read path
Date: Mon, 25 Jan 2016 10:03:22 +0000
Message-Id: <1453716204-20409-1-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Hugh Dickins <hughd@google.com>, Jan Kara <jack@suse.cz>, Linux-FSDevel <linux-fsdevel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@techsingularity.net>

A long time ago there was an attempt to merge a patch that reduced the
cost of unlock_page by avoiding the page_waitqueue lookup if there were no
waiters. It was rejected on the grounds of complexity but it was pointed
out that the read paths call lock_page unnecessarily. This series reduces
the number of calls to lock_page when multiple processes read data in at
the same time.

 mm/filemap.c | 90 ++++++++++++++++++++++++++++++++++++++++--------------------
 1 file changed, 60 insertions(+), 30 deletions(-)

-- 
2.6.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
