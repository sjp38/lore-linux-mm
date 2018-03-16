Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 662206B0027
	for <linux-mm@kvack.org>; Fri, 16 Mar 2018 17:36:26 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id y19so5220255pgv.18
        for <linux-mm@kvack.org>; Fri, 16 Mar 2018 14:36:26 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s20sor2586622pfi.110.2018.03.16.14.36.25
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 16 Mar 2018 14:36:25 -0700 (PDT)
From: Shakeel Butt <shakeelb@google.com>
Subject: SIGSEGV on OSPKE machine
Date: Fri, 16 Mar 2018 14:36:04 -0700
Message-Id: <20180316213604.167305-1-shakeelb@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>, Greg Thelen <gthelen@google.com>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, John Sperbeck <jsperbeck@google.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, x86@kernel.org, Shakeel Butt <shakeelb@google.com>

Hi all,

The following simple program is producing SIGSEGV on machines which have
X86_FEATURE_OSPKE feature on 4.15 kernel.

#include <sys/mman.h>

int main(int argc, char *argv[])
{
	void *p = mmap(0, 4096, PROT_EXEC, MAP_ANONYMOUS|MAP_PRIVATE,
		       -1, 0);
	mprotect(p, 4096, PROT_NONE);
	mprotect(p, 4096, PROT_READ);
	(void)*(volatile unsigned char *)p;
}

On further inspection it seems like transition from PROT_EXEC to
PROT_NONE leaves the exec-only pkey lingering in the vma flags.  That
is, new_vma_pkey is non-zero in do_mprotect_pkey().  Later, then
enabling PROT_READ, the pkey remains and overrides the normal page
protections.

This change seems to help but is this the right way to solve it?

---
 arch/x86/mm/pkeys.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/arch/x86/mm/pkeys.c b/arch/x86/mm/pkeys.c
index d7bc0eea20a5..4a837a220516 100644
--- a/arch/x86/mm/pkeys.c
+++ b/arch/x86/mm/pkeys.c
@@ -94,6 +94,10 @@ int __arch_override_mprotect_pkey(struct vm_area_struct *vma, int prot, int pkey
 	 */
 	if (pkey != -1)
 		return pkey;
+
+	if ((prot & (PROT_READ|PROT_WRITE|PROT_EXEC)) == 0)
+		return 0;
+
 	/*
 	 * Look for a protection-key-drive execute-only mapping
 	 * which is now being given permissions that are not
-- 
2.16.2.804.g6dcf76e118-goog
