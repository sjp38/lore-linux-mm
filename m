Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f44.google.com (mail-wm0-f44.google.com [74.125.82.44])
	by kanga.kvack.org (Postfix) with ESMTP id 04EA76B0005
	for <linux-mm@kvack.org>; Tue, 26 Jan 2016 09:09:33 -0500 (EST)
Received: by mail-wm0-f44.google.com with SMTP id b14so132314827wmb.1
        for <linux-mm@kvack.org>; Tue, 26 Jan 2016 06:09:32 -0800 (PST)
Received: from outbound-smtp07.blacknight.com (outbound-smtp07.blacknight.com. [46.22.139.12])
        by mx.google.com with ESMTPS id ej8si2023328wjd.175.2016.01.26.06.09.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Jan 2016 06:09:32 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail05.blacknight.ie [81.17.254.26])
	by outbound-smtp07.blacknight.com (Postfix) with ESMTPS id 8728F1C17D7
	for <linux-mm@kvack.org>; Tue, 26 Jan 2016 14:09:31 +0000 (GMT)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 0/2] Avoid unnecessary page locks in the generic read path v2r1
Date: Tue, 26 Jan 2016 14:09:28 +0000
Message-Id: <1453817370-10399-1-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Hugh Dickins <hughd@google.com>, Jan Kara <jack@suse.cz>, Linux-FSDevel <linux-fsdevel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@techsingularity.net>

Changelog since V1
o Use lock_page_killable consistently do_generic_file_read		(jan)

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
