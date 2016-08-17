Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id D51286B0253
	for <linux-mm@kvack.org>; Tue, 16 Aug 2016 20:00:53 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id j124so292407684ith.1
        for <linux-mm@kvack.org>; Tue, 16 Aug 2016 17:00:53 -0700 (PDT)
Received: from NAM03-DM3-obe.outbound.protection.outlook.com (mail-dm3nam03on0057.outbound.protection.outlook.com. [104.47.41.57])
        by mx.google.com with ESMTPS id w140si5155412oia.247.2016.08.16.17.00.53
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 16 Aug 2016 17:00:53 -0700 (PDT)
From: Bart Van Assche <bart.vanassche@sandisk.com>
Subject: [PATCH] do_generic_file_read(): Fail immediately if killed
Message-ID: <63068e8e-8bee-b208-8441-a3c39a9d9eb6@sandisk.com>
Date: Tue, 16 Aug 2016 17:00:43 -0700
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Jan Kara <jack@suse.cz>, Hugh Dickins <hughd@google.com>, Oleg Nesterov <oleg@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Linux-fsdevel <linux-fsdevel@vger.kernel.org>

If a fatal signal has been received, fail immediately instead of
trying to read more data.

See also commit ebded02788b5 ("mm: filemap: avoid unnecessary
calls to lock_page when waiting for IO to complete during a read")

Signed-off-by: Bart Van Assche <bart.vanassche@sandisk.com>
Cc: Mel Gorman <mgorman@techsingularity.net>
Cc: Jan Kara <jack@suse.cz>
Cc: Hugh Dickins <hughd@google.com>
Cc: Oleg Nesterov <oleg@redhat.com>
---
 mm/filemap.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/mm/filemap.c b/mm/filemap.c
index 2a9e84f6..bd8ab63 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -1721,7 +1721,9 @@ find_page:
 			 * wait_on_page_locked is used to avoid unnecessarily
 			 * serialisations and why it's safe.
 			 */
-			wait_on_page_locked_killable(page);
+			error = wait_on_page_locked_killable(page);
+			if (unlikely(error))
+				goto readpage_error;
 			if (PageUptodate(page))
 				goto page_ok;
 
-- 
2.9.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
