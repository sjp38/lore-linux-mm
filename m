Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx135.postini.com [74.125.245.135])
	by kanga.kvack.org (Postfix) with SMTP id 2F9C36B0083
	for <linux-mm@kvack.org>; Thu, 16 Feb 2012 08:46:49 -0500 (EST)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH 01/11] perf: Push file_update_time() into perf_mmap_fault()
Date: Thu, 16 Feb 2012 14:46:09 +0100
Message-Id: <1329399979-3647-2-git-send-email-jack@suse.cz>
In-Reply-To: <1329399979-3647-1-git-send-email-jack@suse.cz>
References: <1329399979-3647-1-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: LKML <linux-kernel@vger.kernel.org>
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Eric Sandeen <sandeen@redhat.com>, Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.cz>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Ingo Molnar <mingo@elte.hu>, Paul Mackerras <paulus@samba.org>, Arnaldo Carvalho de Melo <acme@ghostprotocols.net>

CC: Peter Zijlstra <a.p.zijlstra@chello.nl>
CC: Ingo Molnar <mingo@elte.hu>
CC: Paul Mackerras <paulus@samba.org>
CC: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Signed-off-by: Jan Kara <jack@suse.cz>
---
 kernel/events/core.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/kernel/events/core.c b/kernel/events/core.c
index ba36013..61a67f3 100644
--- a/kernel/events/core.c
+++ b/kernel/events/core.c
@@ -3316,8 +3316,10 @@ static int perf_mmap_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
 	int ret = VM_FAULT_SIGBUS;
 
 	if (vmf->flags & FAULT_FLAG_MKWRITE) {
-		if (vmf->pgoff == 0)
+		if (vmf->pgoff == 0) {
 			ret = 0;
+			file_update_time(vma->vm_file);
+		}
 		return ret;
 	}
 
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
