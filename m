Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 279246B000D
	for <linux-mm@kvack.org>; Thu,  5 Jul 2018 10:55:51 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id x18-v6so4801201wmc.7
        for <linux-mm@kvack.org>; Thu, 05 Jul 2018 07:55:51 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d11-v6sor3041797wrr.38.2018.07.05.07.55.49
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 05 Jul 2018 07:55:49 -0700 (PDT)
From: osalvador@techadventures.net
Subject: [PATCH] fs, elf: Make sure to page align bss in load_elf_library
Date: Thu,  5 Jul 2018 16:55:39 +0200
Message-Id: <20180705145539.9627-1-osalvador@techadventures.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-fsdevel@vger.kernel.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, mhocko@suse.com, penguin-kernel@i-love.sakura.ne.jp, keescook@chromium.org, nicolas.pitre@linaro.org, Oscar Salvador <osalvador@suse.de>

From: Oscar Salvador <osalvador@suse.de>

The current code does not make sure to page align bss before calling
vm_brk(), and this can lead to a VM_BUG_ON() in __mm_populate()
due to the requested lenght not being correctly aligned.

Let us make sure to align it properly.

Signed-off-by: Oscar Salvador <osalvador@suse.de>
Tested-by: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Reported-by: syzbot+5dcb560fe12aa5091c06@syzkaller.appspotmail.com
---
 fs/binfmt_elf.c | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/fs/binfmt_elf.c b/fs/binfmt_elf.c
index 0ac456b52bdd..816cc921cf36 100644
--- a/fs/binfmt_elf.c
+++ b/fs/binfmt_elf.c
@@ -1259,9 +1259,8 @@ static int load_elf_library(struct file *file)
 		goto out_free_ph;
 	}
 
-	len = ELF_PAGESTART(eppnt->p_filesz + eppnt->p_vaddr +
-			    ELF_MIN_ALIGN - 1);
-	bss = eppnt->p_memsz + eppnt->p_vaddr;
+	len = ELF_PAGEALIGN(eppnt->p_filesz + eppnt->p_vaddr);
+	bss = ELF_PAGEALIGN(eppnt->p_memsz + eppnt->p_vaddr);
 	if (bss > len) {
 		error = vm_brk(len, bss - len);
 		if (error)
-- 
2.13.6
