Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx143.postini.com [74.125.245.143])
	by kanga.kvack.org (Postfix) with SMTP id 9D8676B0032
	for <linux-mm@kvack.org>; Mon, 19 Aug 2013 23:24:29 -0400 (EDT)
Message-ID: <5212E12C.5010005@asianux.com>
Date: Tue, 20 Aug 2013 11:23:24 +0800
From: Chen Gang <gang.chen@asianux.com>
MIME-Version: 1.0
Subject: [PATCH] mm/backing-dev.c: check user buffer length before copy data
 to the related user buffer.
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>, Tejun Heo <tj@kernel.org>, jmoyer@redhat.com, Jens Axboe <axboe@kernel.dk>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

'*lenp' may be less than "sizeof(kbuf)", need check it before the next
copy_to_user().

pdflush_proc_obsolete() is called by sysctl which 'procname' is
"nr_pdflush_threads", if the user passes buffer length less than
"sizeof(kbuf)", it will cause issue.


Signed-off-by: Chen Gang <gang.chen@asianux.com>
---
 mm/backing-dev.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/mm/backing-dev.c b/mm/backing-dev.c
index e04454c..2674671 100644
--- a/mm/backing-dev.c
+++ b/mm/backing-dev.c
@@ -649,7 +649,7 @@ int pdflush_proc_obsolete(struct ctl_table *table, int write,
 {
 	char kbuf[] = "0\n";
 
-	if (*ppos) {
+	if (*ppos || *lenp < sizeof(kbuf)) {
 		*lenp = 0;
 		return 0;
 	}
-- 
1.7.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
