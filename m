Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id EB0F98E0001
	for <linux-mm@kvack.org>; Thu, 10 Jan 2019 19:26:43 -0500 (EST)
Received: by mail-pl1-f198.google.com with SMTP id ay11so7203175plb.20
        for <linux-mm@kvack.org>; Thu, 10 Jan 2019 16:26:43 -0800 (PST)
Received: from smtprelay.synopsys.com (smtprelay.synopsys.com. [198.182.47.9])
        by mx.google.com with ESMTPS id c3si7995688plr.178.2019.01.10.16.26.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Jan 2019 16:26:42 -0800 (PST)
From: Vineet Gupta <vineet.gupta1@synopsys.com>
Subject: [PATCH 1/3] coredump: Replace opencoded set_mask_bits()
Date: Thu, 10 Jan 2019 16:26:25 -0800
Message-ID: <1547166387-19785-2-git-send-email-vgupta@synopsys.com>
In-Reply-To: <1547166387-19785-1-git-send-email-vgupta@synopsys.com>
References: <1547166387-19785-1-git-send-email-vgupta@synopsys.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-snps-arc@lists.infradead.org, linux-mm@kvack.org, peterz@infradead.org, Vineet Gupta <vineet.gupta1@synopsys.com>, Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org

Cc: Alexander Viro <viro@zeniv.linux.org.uk>
Cc: Peter Zijlstra (Intel) <peterz@infradead.org>
Cc: linux-fsdevel@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
Link: http://lkml.kernel.org/g/20150807115710.GA16897@redhat.com
Acked-by: Oleg Nesterov <oleg@redhat.com>
Signed-off-by: Vineet Gupta <vgupta@synopsys.com>
---
 fs/exec.c | 7 +------
 1 file changed, 1 insertion(+), 6 deletions(-)

diff --git a/fs/exec.c b/fs/exec.c
index fb72d36f7823..df7f05362283 100644
--- a/fs/exec.c
+++ b/fs/exec.c
@@ -1944,15 +1944,10 @@ EXPORT_SYMBOL(set_binfmt);
  */
 void set_dumpable(struct mm_struct *mm, int value)
 {
-	unsigned long old, new;
-
 	if (WARN_ON((unsigned)value > SUID_DUMP_ROOT))
 		return;
 
-	do {
-		old = READ_ONCE(mm->flags);
-		new = (old & ~MMF_DUMPABLE_MASK) | value;
-	} while (cmpxchg(&mm->flags, old, new) != old);
+	set_mask_bits(&mm->flags, MMF_DUMPABLE_MASK, value);
 }
 
 SYSCALL_DEFINE3(execve,
-- 
2.7.4
