Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 52CA36B000D
	for <linux-mm@kvack.org>; Mon, 19 Mar 2018 14:18:45 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id i11so8861789pgq.10
        for <linux-mm@kvack.org>; Mon, 19 Mar 2018 11:18:45 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id i15-v6si394478pll.633.2018.03.19.11.18.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 Mar 2018 11:18:44 -0700 (PDT)
From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: [PATCH 4.9 020/241] x86/mm: Make mmap(MAP_32BIT) work correctly
Date: Mon, 19 Mar 2018 19:04:45 +0100
Message-Id: <20180319180752.005376139@linuxfoundation.org>
In-Reply-To: <20180319180751.172155436@linuxfoundation.org>
References: <20180319180751.172155436@linuxfoundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, stable@vger.kernel.org, Dmitry Safonov <dsafonov@virtuozzo.com>, 0x7f454c46@gmail.com, linux-mm@kvack.org, Andy Lutomirski <luto@kernel.org>, Cyrill Gorcunov <gorcunov@openvz.org>, Borislav Petkov <bp@suse.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Thomas Gleixner <tglx@linutronix.de>, Sasha Levin <alexander.levin@microsoft.com>

4.9-stable review patch.  If anyone has any objections, please let me know.

------------------

From: Dmitry Safonov <dsafonov@virtuozzo.com>


[ Upstream commit 3e6ef9c80946f781fc25e8490c9875b1d2b61158 ]

mmap(MAP_32BIT) is broken due to the dependency on the TIF_ADDR32 thread
flag.

For 64bit applications MAP_32BIT will force legacy bottom-up allocations and
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
Signed-off-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
---
 arch/x86/kernel/sys_x86_64.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

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
@@ -175,7 +175,7 @@ arch_get_unmapped_area_topdown(struct fi
 		return addr;
 
 	/* for MAP_32BIT mappings we force the legacy mmap base */
-	if (!test_thread_flag(TIF_ADDR32) && (flags & MAP_32BIT))
+	if (!in_compat_syscall() && (flags & MAP_32BIT))
 		goto bottomup;
 
 	/* requesting a specific address */
