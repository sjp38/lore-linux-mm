Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 9635C8E0001
	for <linux-mm@kvack.org>; Thu, 10 Jan 2019 19:26:48 -0500 (EST)
Received: by mail-pl1-f197.google.com with SMTP id h10so7184646plk.12
        for <linux-mm@kvack.org>; Thu, 10 Jan 2019 16:26:48 -0800 (PST)
Received: from smtprelay.synopsys.com (smtprelay2.synopsys.com. [198.182.60.111])
        by mx.google.com with ESMTPS id v9si10761030pgo.23.2019.01.10.16.26.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Jan 2019 16:26:47 -0800 (PST)
From: Vineet Gupta <vineet.gupta1@synopsys.com>
Subject: [PATCH 2/3] fs: inode_set_flags() replace opencoded set_mask_bits()
Date: Thu, 10 Jan 2019 16:26:26 -0800
Message-ID: <1547166387-19785-3-git-send-email-vgupta@synopsys.com>
In-Reply-To: <1547166387-19785-1-git-send-email-vgupta@synopsys.com>
References: <1547166387-19785-1-git-send-email-vgupta@synopsys.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-snps-arc@lists.infradead.org, linux-mm@kvack.org, peterz@infradead.org, Vineet Gupta <vineet.gupta1@synopsys.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Theodore Ts'o <tytso@mit.edu>, linux-fsdevel@vger.kernel.org

It seems that 5f16f3225b0624 and 00a1a053ebe5, both with same commitlog
("ext4: atomically set inode->i_flags in ext4_set_inode_flags()")
introduced the set_mask_bits API, but somehow missed not using it in
ext4 in the end

Also, set_mask_bits is used in fs quite a bit and we can possibly come up
with a generic llsc based implementation (w/o the cmpxchg loop)

Cc: Alexander Viro <viro@zeniv.linux.org.uk>
Cc: Theodore Ts'o <tytso@mit.edu>
Cc: Peter Zijlstra (Intel) <peterz@infradead.org>
Cc: linux-fsdevel@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
Signed-off-by: Vineet Gupta <vgupta@synopsys.com>
---
 fs/inode.c | 8 +-------
 1 file changed, 1 insertion(+), 7 deletions(-)

diff --git a/fs/inode.c b/fs/inode.c
index 0cd47fe0dbe5..799b0c4beda8 100644
--- a/fs/inode.c
+++ b/fs/inode.c
@@ -2096,14 +2096,8 @@ EXPORT_SYMBOL(inode_dio_wait);
 void inode_set_flags(struct inode *inode, unsigned int flags,
 		     unsigned int mask)
 {
-	unsigned int old_flags, new_flags;
-
 	WARN_ON_ONCE(flags & ~mask);
-	do {
-		old_flags = READ_ONCE(inode->i_flags);
-		new_flags = (old_flags & ~mask) | flags;
-	} while (unlikely(cmpxchg(&inode->i_flags, old_flags,
-				  new_flags) != old_flags));
+	set_mask_bits(&inode->i_flags, mask, flags);
 }
 EXPORT_SYMBOL(inode_set_flags);
 
-- 
2.7.4
