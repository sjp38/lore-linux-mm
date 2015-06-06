Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id 927B0900016
	for <linux-mm@kvack.org>; Sat,  6 Jun 2015 09:38:27 -0400 (EDT)
Received: by payr10 with SMTP id r10so66844398pay.1
        for <linux-mm@kvack.org>; Sat, 06 Jun 2015 06:38:27 -0700 (PDT)
Received: from smtp2.provo.novell.com (smtp2.provo.novell.com. [137.65.250.81])
        by mx.google.com with ESMTPS id o8si15176344pdr.66.2015.06.06.06.38.21
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sat, 06 Jun 2015 06:38:22 -0700 (PDT)
From: Davidlohr Bueso <dave@stgolabs.net>
Subject: [PATCH 5/5] ipc,sysv: return -EINVAL upon incorrect id/seqnum
Date: Sat,  6 Jun 2015 06:38:00 -0700
Message-Id: <1433597880-8571-6-git-send-email-dave@stgolabs.net>
In-Reply-To: <1433597880-8571-1-git-send-email-dave@stgolabs.net>
References: <1433597880-8571-1-git-send-email-dave@stgolabs.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Manfred Spraul <manfred@colorfullife.com>, dave@stgolabs.net, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Davidlohr Bueso <dbueso@suse.de>

In ipc_obtain_object_check we return -EIDRM when a bogus
sequence number is detected via ipc_checkid, while the ipc
manpages state the following return codes for such errors:

   EIDRM  <ID> points to a removed identifier.
   EINVAL Invalid <ID> value, or unaligned, etc.

EIDRM should only be returned upon a RMID call (->deleted
check), and thus return EINVAL for wrong seq. This difference
in semantics has also caused real bugs, ie:
https://bugzilla.redhat.com/show_bug.cgi?id=246509

Signed-off-by: Davidlohr Bueso <dbueso@suse.de>
---
 ipc/util.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/ipc/util.c b/ipc/util.c
index 15e750d..468b225 100644
--- a/ipc/util.c
+++ b/ipc/util.c
@@ -625,7 +625,7 @@ struct kern_ipc_perm *ipc_obtain_object_check(struct ipc_ids *ids, int id)
 		goto out;
 
 	if (ipc_checkid(out, id))
-		return ERR_PTR(-EIDRM);
+		return ERR_PTR(-EINVAL);
 out:
 	return out;
 }
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
