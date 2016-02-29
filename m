Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f46.google.com (mail-wm0-f46.google.com [74.125.82.46])
	by kanga.kvack.org (Postfix) with ESMTP id BB8E56B0256
	for <linux-mm@kvack.org>; Mon, 29 Feb 2016 08:27:18 -0500 (EST)
Received: by mail-wm0-f46.google.com with SMTP id l68so36706586wml.0
        for <linux-mm@kvack.org>; Mon, 29 Feb 2016 05:27:18 -0800 (PST)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 05/18] mm, elf: handle vm_brk error
Date: Mon, 29 Feb 2016 14:26:44 +0100
Message-Id: <1456752417-9626-6-git-send-email-mhocko@kernel.org>
In-Reply-To: <1456752417-9626-1-git-send-email-mhocko@kernel.org>
References: <1456752417-9626-1-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: LKML <linux-kernel@vger.kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Alex Deucher <alexander.deucher@amd.com>, Alex Thorlton <athorlton@sgi.com>, Andrea Arcangeli <aarcange@redhat.com>, Andy Lutomirski <luto@amacapital.net>, Benjamin LaHaise <bcrl@kvack.org>, =?UTF-8?q?Christian=20K=C3=B6nig?= <christian.koenig@amd.com>, Daniel Vetter <daniel.vetter@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, David Airlie <airlied@linux.ie>, Davidlohr Bueso <dave@stgolabs.net>, David Rientjes <rientjes@google.com>, "H . Peter Anvin" <hpa@zytor.com>, Hugh Dickins <hughd@google.com>, Ingo Molnar <mingo@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Konstantin Khlebnikov <koct9i@gmail.com>, linux-arch@vger.kernel.org, Mel Gorman <mgorman@suse.de>, Oleg Nesterov <oleg@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Petr Cermak <petrcermak@chromium.org>, Thomas Gleixner <tglx@linutronix.de>, Michal Hocko <mhocko@suse.com>, Alexander Viro <viro@zeniv.linux.org.uk>

From: Michal Hocko <mhocko@suse.com>

load_elf_library doesn't handle vm_brk failure although nothing really
indicates it cannot do that because the function is allowed to fail
due to vm_mmap failures already. This might be not a problem now
but later patch will make vm_brk killable (resp. mmap_sem for write
waiting will become killable) and so the failure will be more probable.

Cc: Alexander Viro <viro@zeniv.linux.org.uk>
Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 fs/binfmt_elf.c | 7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/fs/binfmt_elf.c b/fs/binfmt_elf.c
index 7d914c67a9d0..2e45ae57ea88 100644
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
2.7.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
