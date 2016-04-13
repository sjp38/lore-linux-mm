Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f50.google.com (mail-wm0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id 9E432828DF
	for <linux-mm@kvack.org>; Wed, 13 Apr 2016 05:57:21 -0400 (EDT)
Received: by mail-wm0-f50.google.com with SMTP id a140so91487643wma.0
        for <linux-mm@kvack.org>; Wed, 13 Apr 2016 02:57:21 -0700 (PDT)
Received: from mail-wm0-f65.google.com (mail-wm0-f65.google.com. [74.125.82.65])
        by mx.google.com with ESMTPS id hh4si38931299wjc.172.2016.04.13.02.57.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Apr 2016 02:57:20 -0700 (PDT)
Received: by mail-wm0-f65.google.com with SMTP id y144so12365882wmd.0
        for <linux-mm@kvack.org>; Wed, 13 Apr 2016 02:57:20 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH] x86: add frame annotation for call_rwsem_down_write_failed_killable
Date: Wed, 13 Apr 2016 11:57:12 +0200
Message-Id: <1460541432-21631-1-git-send-email-mhocko@kernel.org>
In-Reply-To: <1460041951-22347-11-git-send-email-mhocko@kernel.org>
References: <1460041951-22347-11-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@redhat.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, x86@kernel.org, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, linux-arch@vger.kernel.org, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

3387a535ce62 ("x86/asm: Create stack frames in rwsem functions") has
added FRAME_{BEGIN,END} annotations to rwsem asm stubs. The patch
which has added call_rwsem_down_write_failed_killable was based on an
older tree so it didn't know about annotations. Let's add them.

Reported-by: Ingo Molnar <mingo@kernel.org>
Signed-off-by: Michal Hocko <mhocko@suse.com>
---

Hi Ingo,
please apply this on top of [1] when merging to tip/locking/rwsem.
Thanks!

[1] http://lkml.kernel.org/r/1460041951-22347-11-git-send-email-mhocko@kernel.org
 arch/x86/lib/rwsem.S | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/arch/x86/lib/rwsem.S b/arch/x86/lib/rwsem.S
index 4534a7e912f3..a37462a23546 100644
--- a/arch/x86/lib/rwsem.S
+++ b/arch/x86/lib/rwsem.S
@@ -107,10 +107,12 @@ ENTRY(call_rwsem_down_write_failed)
 ENDPROC(call_rwsem_down_write_failed)
 
 ENTRY(call_rwsem_down_write_failed_killable)
+	FRAME_BEGIN
 	save_common_regs
 	movq %rax,%rdi
 	call rwsem_down_write_failed_killable
 	restore_common_regs
+	FRAME_END
 	ret
 ENDPROC(call_rwsem_down_write_failed_killable)
 
-- 
2.8.0.rc3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
