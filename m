Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id 6C5196B0262
	for <linux-mm@kvack.org>; Tue, 26 Apr 2016 08:56:42 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id 68so11465438lfq.2
        for <linux-mm@kvack.org>; Tue, 26 Apr 2016 05:56:42 -0700 (PDT)
Received: from mail-wm0-f68.google.com (mail-wm0-f68.google.com. [74.125.82.68])
        by mx.google.com with ESMTPS id cj2si29888790wjc.54.2016.04.26.05.56.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Apr 2016 05:56:35 -0700 (PDT)
Received: by mail-wm0-f68.google.com with SMTP id w143so4194148wmw.3
        for <linux-mm@kvack.org>; Tue, 26 Apr 2016 05:56:35 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 05/18] mm, elf: handle vm_brk error
Date: Tue, 26 Apr 2016 14:56:12 +0200
Message-Id: <1461675385-5934-6-git-send-email-mhocko@kernel.org>
In-Reply-To: <1461675385-5934-1-git-send-email-mhocko@kernel.org>
References: <1461675385-5934-1-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Vlastimil Babka <vbabka@suse.cz>

From: Michal Hocko <mhocko@suse.com>

load_elf_library doesn't handle vm_brk failure although nothing really
indicates it cannot do that because the function is allowed to fail
due to vm_mmap failures already. This might be not a problem now
but later patch will make vm_brk killable (resp. mmap_sem for write
waiting will become killable) and so the failure will be more probable.

Cc: Alexander Viro <viro@zeniv.linux.org.uk>
Acked-by: Vlastimil Babka <vbabka@suse.cz>
Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 fs/binfmt_elf.c | 7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/fs/binfmt_elf.c b/fs/binfmt_elf.c
index 81381cc0dd17..37455ee5aeec 100644
--- a/fs/binfmt_elf.c
+++ b/fs/binfmt_elf.c
@@ -1176,8 +1176,11 @@ static int load_elf_library(struct file *file)
 	len = ELF_PAGESTART(eppnt->p_filesz + eppnt->p_vaddr +
 			    ELF_MIN_ALIGN - 1);
 	bss = eppnt->p_memsz + eppnt->p_vaddr;
-	if (bss > len)
-		vm_brk(len, bss - len);
+	if (bss > len) {
+		error = vm_brk(len, bss - len);
+		if (BAD_ADDR(error))
+			goto out_free_ph;
+	}
 	error = 0;
 
 out_free_ph:
-- 
2.8.0.rc3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
