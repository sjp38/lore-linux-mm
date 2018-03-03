Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id C9C016B0003
	for <linux-mm@kvack.org>; Sat,  3 Mar 2018 17:31:17 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id v2so5774506pgv.23
        for <linux-mm@kvack.org>; Sat, 03 Mar 2018 14:31:17 -0800 (PST)
Received: from NAM01-BN3-obe.outbound.protection.outlook.com (mail-bn3nam01on0095.outbound.protection.outlook.com. [104.47.33.95])
        by mx.google.com with ESMTPS id f89si7423082pfe.185.2018.03.03.14.31.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Sat, 03 Mar 2018 14:31:16 -0800 (PST)
From: Sasha Levin <Alexander.Levin@microsoft.com>
Subject: [PATCH AUTOSEL for 4.9 022/219] x86/mm: Make mmap(MAP_32BIT) work
 correctly
Date: Sat, 3 Mar 2018 22:28:08 +0000
Message-ID: <20180303222716.26640-22-alexander.levin@microsoft.com>
References: <20180303222716.26640-1-alexander.levin@microsoft.com>
In-Reply-To: <20180303222716.26640-1-alexander.levin@microsoft.com>
Content-Language: en-US
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "stable@vger.kernel.org" <stable@vger.kernel.org>
Cc: Dmitry Safonov <dsafonov@virtuozzo.com>, "0x7f454c46@gmail.com" <0x7f454c46@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andy Lutomirski <luto@kernel.org>, Cyrill Gorcunov <gorcunov@openvz.org>, Borislav Petkov <bp@suse.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Thomas Gleixner <tglx@linutronix.de>, Sasha Levin <Alexander.Levin@microsoft.com>

From: Dmitry Safonov <dsafonov@virtuozzo.com>

[ Upstream commit 3e6ef9c80946f781fc25e8490c9875b1d2b61158 ]

mmap(MAP_32BIT) is broken due to the dependency on the TIF_ADDR32 thread
flag.

For 64bit applications MAP_32BIT will force legacy bottom-up allocations an=
d
the 1GB address space restriction even if the application issued a compat
syscall, which should not be subject of these restrictions.

For 32bit applications, which issue 64bit syscalls the newly introduced
mmap base separation into 64-bit and compat bases changed the behaviour
because now a 64-bit mapping is returned, but due to the TIF_ADDR32
dependency MAP_32BIT is ignored. Before the separation a 32-bit mapping was
returned, so the MAP_32BIT handling was irrelevant.

Replace the check for TIF_ADDR32 with a check for the compat syscall. That
solves both the 64-bit issuing a compat syscall and the 32-bit issuing a
64-bit syscall problems.

[ tglx: Massaged changelog ]

Signed-off-by: Dmitry Safonov <dsafonov@virtuozzo.com>
Cc: 0x7f454c46@gmail.com
Cc: linux-mm@kvack.org
Cc: Andy Lutomirski <luto@kernel.org>
Cc: Cyrill Gorcunov <gorcunov@openvz.org>
Cc: Borislav Petkov <bp@suse.de>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Link: http://lkml.kernel.org/r/20170306141721.9188-5-dsafonov@virtuozzo.com
Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
Signed-off-by: Sasha Levin <alexander.levin@microsoft.com>
---
 arch/x86/kernel/sys_x86_64.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/arch/x86/kernel/sys_x86_64.c b/arch/x86/kernel/sys_x86_64.c
index 1119414ab419..c45923e70f82 100644
--- a/arch/x86/kernel/sys_x86_64.c
+++ b/arch/x86/kernel/sys_x86_64.c
@@ -100,7 +100,7 @@ out:
 static void find_start_end(unsigned long flags, unsigned long *begin,
 			   unsigned long *end)
 {
-	if (!test_thread_flag(TIF_ADDR32) && (flags & MAP_32BIT)) {
+	if (!in_compat_syscall() && (flags & MAP_32BIT)) {
 		/* This is usually used needed to map code in small
 		   model, so it needs to be in the first 31bit. Limit
 		   it to that.  This means we need to move the
@@ -175,7 +175,7 @@ arch_get_unmapped_area_topdown(struct file *filp, const=
 unsigned long addr0,
 		return addr;
=20
 	/* for MAP_32BIT mappings we force the legacy mmap base */
-	if (!test_thread_flag(TIF_ADDR32) && (flags & MAP_32BIT))
+	if (!in_compat_syscall() && (flags & MAP_32BIT))
 		goto bottomup;
=20
 	/* requesting a specific address */
--=20
2.14.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
