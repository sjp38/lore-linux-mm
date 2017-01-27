Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 1B9176B0260
	for <linux-mm@kvack.org>; Fri, 27 Jan 2017 16:00:53 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id 14so365088295pgg.4
        for <linux-mm@kvack.org>; Fri, 27 Jan 2017 13:00:53 -0800 (PST)
Received: from EUR02-VE1-obe.outbound.protection.outlook.com (mail-eopbgr20111.outbound.protection.outlook.com. [40.107.2.111])
        by mx.google.com with ESMTPS id c85si5460162pfk.224.2017.01.27.13.00.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 27 Jan 2017 13:00:52 -0800 (PST)
From: Dmitry Safonov <dsafonov@virtuozzo.com>
Subject: [PATCHv3 4/5] x86/mm: check in_compat_syscall() instead TIF_ADDR32 for mmap(MAP_32BIT)
Date: Sat, 28 Jan 2017 00:00:28 +0300
Message-ID: <20170127210029.31566-5-dsafonov@virtuozzo.com>
In-Reply-To: <20170127210029.31566-1-dsafonov@virtuozzo.com>
References: <20170127210029.31566-1-dsafonov@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: 0x7f454c46@gmail.com, Dmitry Safonov <dsafonov@virtuozzo.com>, Thomas
 Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter
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
index 90be0839441d..533e879e9cdf 100644
--- a/arch/x86/kernel/sys_x86_64.c
+++ b/arch/x86/kernel/sys_x86_64.c
@@ -101,7 +101,7 @@ SYSCALL_DEFINE6(mmap, unsigned long, addr, unsigned long, len,
 static void find_start_end(unsigned long flags, unsigned long *begin,
 			   unsigned long *end)
 {
-	if (!test_thread_flag(TIF_ADDR32) && (flags & MAP_32BIT)) {
+	if (!in_compat_syscall() && (flags & MAP_32BIT)) {
 		/* This is usually used needed to map code in small
 		   model, so it needs to be in the first 31bit. Limit
 		   it to that.  This means we need to move the
@@ -195,7 +195,7 @@ arch_get_unmapped_area_topdown(struct file *filp, const unsigned long addr0,
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
