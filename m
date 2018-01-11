Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id BC1E96B0260
	for <linux-mm@kvack.org>; Wed, 10 Jan 2018 21:03:26 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id m7so1655962pgv.17
        for <linux-mm@kvack.org>; Wed, 10 Jan 2018 18:03:26 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id ba12sor114000plb.71.2018.01.10.18.03.25
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 10 Jan 2018 18:03:25 -0800 (PST)
From: Kees Cook <keescook@chromium.org>
Subject: [PATCH 05/38] stddef.h: Introduce sizeof_field()
Date: Wed, 10 Jan 2018 18:02:37 -0800
Message-Id: <1515636190-24061-6-git-send-email-keescook@chromium.org>
In-Reply-To: <1515636190-24061-1-git-send-email-keescook@chromium.org>
References: <1515636190-24061-1-git-send-email-keescook@chromium.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Kees Cook <keescook@chromium.org>, Linus Torvalds <torvalds@linux-foundation.org>, David Windsor <dave@nullcore.net>, Alexander Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Christoph Hellwig <hch@infradead.org>, Christoph Lameter <cl@linux.com>, "David S. Miller" <davem@davemloft.net>, Laura Abbott <labbott@redhat.com>, Mark Rutland <mark.rutland@arm.com>, "Martin K. Petersen" <martin.petersen@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Christian Borntraeger <borntraeger@de.ibm.com>, Christoffer Dall <christoffer.dall@linaro.org>, Dave Kleikamp <dave.kleikamp@oracle.com>, Jan Kara <jack@suse.cz>, Luis de Bethencourt <luisbg@kernel.org>, Marc Zyngier <marc.zyngier@arm.com>, Rik van Riel <riel@redhat.com>, Matthew Garrett <mjg59@google.com>, linux-fsdevel@vger.kernel.org, linux-arch@vger.kernel.org, netdev@vger.kernel.org, linux-mm@kvack.org, kernel-hardening@lists.openwall.com

The size of fields within a structure is needed in a few places in the
kernel already, and will be needed for the usercopy whitelisting when
declaring whitelist regions within structures. This creates a dedicated
macro and redefines offsetofend() to use it.

Existing usage, ignoring the 1200+ lustre assert uses:

$ git grep -E 'sizeof\(\(\((struct )?[a-zA-Z_]+ \*\)0\)->' | \
	grep -v staging/lustre | wc -l
65

Signed-off-by: Kees Cook <keescook@chromium.org>
---
 include/linux/stddef.h | 10 +++++++++-
 1 file changed, 9 insertions(+), 1 deletion(-)

diff --git a/include/linux/stddef.h b/include/linux/stddef.h
index 2181719fd907..998a4ba28eba 100644
--- a/include/linux/stddef.h
+++ b/include/linux/stddef.h
@@ -20,12 +20,20 @@ enum {
 #endif
 
 /**
+ * sizeof_field(TYPE, MEMBER)
+ *
+ * @TYPE: The structure containing the field of interest
+ * @MEMBER: The field to return the size of
+ */
+#define sizeof_field(TYPE, MEMBER) sizeof((((TYPE *)0)->MEMBER))
+
+/**
  * offsetofend(TYPE, MEMBER)
  *
  * @TYPE: The type of the structure
  * @MEMBER: The member within the structure to get the end offset of
  */
 #define offsetofend(TYPE, MEMBER) \
-	(offsetof(TYPE, MEMBER)	+ sizeof(((TYPE *)0)->MEMBER))
+	(offsetof(TYPE, MEMBER)	+ sizeof_field(TYPE, MEMBER))
 
 #endif
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
