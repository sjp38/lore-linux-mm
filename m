Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx104.postini.com [74.125.245.104])
	by kanga.kvack.org (Postfix) with SMTP id 6E6E46B0068
	for <linux-mm@kvack.org>; Mon, 20 Aug 2012 12:56:10 -0400 (EDT)
From: Jim Meyering <jim@meyering.net>
Subject: [PATCH] kmemleak: avoid buffer overrun: NUL-terminate strncpy-copied command
Date: Mon, 20 Aug 2012 18:55:22 +0200
Message-Id: <1345481724-30108-4-git-send-email-jim@meyering.net>
In-Reply-To: <1345481724-30108-1-git-send-email-jim@meyering.net>
References: <1345481724-30108-1-git-send-email-jim@meyering.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Jim Meyering <meyering@redhat.com>, Catalin Marinas <catalin.marinas@arm.com>, linux-mm@kvack.org

From: Jim Meyering <meyering@redhat.com>

strncpy NUL-terminates only when the length of the source string
is smaller than the size of the destination buffer.
The two other strncpy uses (just preceding) happen to be ok
with the current TASK_COMM_LEN (16), because the literals
"hardirq" and "softirq" are both shorter than 16.  However,
technically it'd be better to use strcpy along with a
compile-time assertion that they fit in the buffer.

Signed-off-by: Jim Meyering <meyering@redhat.com>
---
 mm/kmemleak.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/mm/kmemleak.c b/mm/kmemleak.c
index 45eb621..947257f 100644
--- a/mm/kmemleak.c
+++ b/mm/kmemleak.c
@@ -555,6 +555,7 @@ static struct kmemleak_object *create_object(unsigned long ptr, size_t size,
 		 * case, the command line is not correct.
 		 */
 		strncpy(object->comm, current->comm, sizeof(object->comm));
+		object->comm[sizeof(object->comm) - 1] = 0;
 	}

 	/* kernel backtrace */
-- 
1.7.12

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
