Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5B3B76B0266
	for <linux-mm@kvack.org>; Mon, 16 Jan 2017 07:36:46 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id y143so248277953pfb.6
        for <linux-mm@kvack.org>; Mon, 16 Jan 2017 04:36:46 -0800 (PST)
Received: from EUR02-AM5-obe.outbound.protection.outlook.com (mail-eopbgr00126.outbound.protection.outlook.com. [40.107.0.126])
        by mx.google.com with ESMTPS id i189si21463767pfc.62.2017.01.16.04.36.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 16 Jan 2017 04:36:45 -0800 (PST)
From: Dmitry Safonov <dsafonov@virtuozzo.com>
Subject: [PATCHv2 4/5] x86/mm: for MAP_32BIT check in_compat_syscall() instead TIF_ADDR32
Date: Mon, 16 Jan 2017 15:33:09 +0300
Message-ID: <20170116123310.22697-5-dsafonov@virtuozzo.com>
In-Reply-To: <20170116123310.22697-1-dsafonov@virtuozzo.com>
References: <20170116123310.22697-1-dsafonov@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: 0x7f454c46@gmail.com, Dmitry Safonov <dsafonov@virtuozzo.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter
 Anvin" <hpa@zytor.com>, Andy Lutomirski <luto@kernel.org>, Borislav Petkov <bp@suse.de>, x86@kernel.org, linux-mm@kvack.org

At this momet, logic in arch_get_unmapped_area{,_topdown} for mmaps with
MAP_32BIT flag checks TIF_ADDR32 which means:
o if 32-bit ELF changes mode to 64-bit on x86_64 and then tries to
  mmap() with MAP_32BIT it'll result in addr over 4Gb (as default is
  top-down allocation)
o if 64-bit ELF changes mode to 32-bit and tries mmap() with MAP_32BIT,
  it'll allocate only memory in 1GB space: [0x40000000, 0x80000000).

Fix it by handeling MAP_32BIT in 64-bit syscalls only.
As a little bonus it'll make thread flag a little less used.

Signed-off-by: Dmitry Safonov <dsafonov@virtuozzo.com>
---
 arch/x86/kernel/sys_x86_64.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/arch/x86/kernel/sys_x86_64.c b/arch/x86/kernel/sys_x86_64.c
index 1bf90cd1400c..e7d4bbbe6175 100644
--- a/arch/x86/kernel/sys_x86_64.c
+++ b/arch/x86/kernel/sys_x86_64.c
@@ -100,7 +100,7 @@ SYSCALL_DEFINE6(mmap, unsigned long, addr, unsigned long, len,
 static void find_start_end(unsigned long flags, unsigned long *begin,
 			   unsigned long *end)
 {
-	if (!test_thread_flag(TIF_ADDR32) && (flags & MAP_32BIT)) {
+	if (!in_compat_syscall() && (flags & MAP_32BIT)) {
 		/* This is usually used needed to map code in small
 		   model, so it needs to be in the first 31bit. Limit
 		   it to that.  This means we need to move the
@@ -213,7 +213,7 @@ arch_get_unmapped_area_topdown(struct file *filp, const unsigned long addr0,
 		return addr;
 
 	/* for MAP_32BIT mappings we force the legacy mmap base */
-	if (!test_thread_flag(TIF_ADDR32) && (flags & MAP_32BIT))
+	if (!in_compat_syscall() && (flags & MAP_32BIT))
 		goto bottomup;
 
 	/* requesting a specific address */
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
