Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 8EB776B03B6
	for <linux-mm@kvack.org>; Tue, 14 Feb 2017 13:40:29 -0500 (EST)
Received: by mail-it0-f70.google.com with SMTP id w185so38231535ita.5
        for <linux-mm@kvack.org>; Tue, 14 Feb 2017 10:40:29 -0800 (PST)
Received: from EUR01-DB5-obe.outbound.protection.outlook.com (mail-db5eur01on0100.outbound.protection.outlook.com. [104.47.2.100])
        by mx.google.com with ESMTPS id d128si3690253ite.1.2017.02.14.10.40.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 14 Feb 2017 10:40:28 -0800 (PST)
From: Dmitry Safonov <dsafonov@virtuozzo.com>
Subject: [PATCHv5 4/5] x86/mm: check in_compat_syscall() instead TIF_ADDR32 for mmap(MAP_32BIT)
Date: Tue, 14 Feb 2017 21:36:20 +0300
Message-ID: <20170214183621.2537-5-dsafonov@virtuozzo.com>
In-Reply-To: <20170214183621.2537-1-dsafonov@virtuozzo.com>
References: <20170214183621.2537-1-dsafonov@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: 0x7f454c46@gmail.com, Dmitry Safonov <dsafonov@virtuozzo.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter
 Anvin" <hpa@zytor.com>, Andy Lutomirski <luto@kernel.org>, Borislav Petkov <bp@suse.de>, x86@kernel.org, linux-mm@kvack.org, Cyrill Gorcunov <gorcunov@openvz.org>

Result of mmap() calls with MAP_32BIT flag at this moment depends
on thread flag TIF_ADDR32, which is set during exec() for 32-bit apps.
It's broken as the behavior of mmap() shouldn't depend on exec-ed
application's bitness. Instead, it should check the bitness of mmap()
syscall.
How it worked before:
o for 32-bit compatible binaries it is completely ignored. Which was
fine when there were one mmap_base, computed for 32-bit syscalls.
After introducing mmap_compat_base 64-bit syscalls do use computed
for 64-bit syscalls mmap_base, which means that we can allocate 64-bit
address with 64-bit syscall in application launched from 32-bit
compatible binary. And ignoring this flag is not expected behavior.
o for 64-bit ELFs it forces legacy bottom-up allocations and 1Gb address
space restriction for allocations: [0x40000000, 0x80000000) - look at
find_start_end(). Which means that it was wrongly handled for 32-bit
syscalls - they don't need nor this restriction nor legacy mmap
(as we try to keep 32-bit syscalls behavior the same independently of
native/compat mode of ELF being executed).

Changed mmap() behavior for MAP_32BIT flag the way that for 32-bit
syscalls it will be always ignored and for 64-bit syscalls it'll
always return 32-bit pointer restricted with 1Gb adress space,
independently of the binary's bitness of executed application.

Signed-off-by: Dmitry Safonov <dsafonov@virtuozzo.com>
---
 arch/x86/kernel/sys_x86_64.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/arch/x86/kernel/sys_x86_64.c b/arch/x86/kernel/sys_x86_64.c
index 16b43dbe78b1..cc8eaba10104 100644
--- a/arch/x86/kernel/sys_x86_64.c
+++ b/arch/x86/kernel/sys_x86_64.c
@@ -114,7 +114,7 @@ static unsigned long get_mmap_base(int is_legacy)
 static void find_start_end(unsigned long flags, unsigned long *begin,
 			   unsigned long *end)
 {
-	if (!test_thread_flag(TIF_ADDR32) && (flags & MAP_32BIT)) {
+	if (!in_compat_syscall() && (flags & MAP_32BIT)) {
 		/* This is usually used needed to map code in small
 		   model, so it needs to be in the first 31bit. Limit
 		   it to that.  This means we need to move the
@@ -190,7 +190,7 @@ arch_get_unmapped_area_topdown(struct file *filp, const unsigned long addr0,
 		return addr;
 
 	/* for MAP_32BIT mappings we force the legacy mmap base */
-	if (!test_thread_flag(TIF_ADDR32) && (flags & MAP_32BIT))
+	if (!in_compat_syscall() && (flags & MAP_32BIT))
 		goto bottomup;
 
 	/* requesting a specific address */
-- 
2.11.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
