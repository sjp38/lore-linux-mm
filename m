Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id A1E168E0001
	for <linux-mm@kvack.org>; Thu, 27 Dec 2018 22:00:39 -0500 (EST)
Received: by mail-pf1-f200.google.com with SMTP id q64so22168282pfa.18
        for <linux-mm@kvack.org>; Thu, 27 Dec 2018 19:00:39 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n15sor1283036plp.65.2018.12.27.19.00.37
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 27 Dec 2018 19:00:38 -0800 (PST)
From: Pingfan Liu <kernelfans@gmail.com>
Subject: [PATCHv3 2/2] x86/kdump: bugfix, make the behavior of crashkernel=X consistent with kaslr
Date: Fri, 28 Dec 2018 11:00:02 +0800
Message-Id: <1545966002-3075-3-git-send-email-kernelfans@gmail.com>
In-Reply-To: <1545966002-3075-1-git-send-email-kernelfans@gmail.com>
References: <1545966002-3075-1-git-send-email-kernelfans@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-acpi@vger.kernel.org, linux-mm@kvack.org, kexec@lists.infradead.org
Cc: Pingfan Liu <kernelfans@gmail.com>, Tang Chen <tangchen@cn.fujitsu.com>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Michal Hocko <mhocko@suse.com>, Jonathan Corbet <corbet@lwn.net>, Yaowei Bai <baiyaowei@cmss.chinamobile.com>, Pavel Tatashin <pasha.tatashin@oracle.com>, Nicholas Piggin <npiggin@gmail.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Daniel Vacek <neelx@redhat.com>, Mathieu Malaterre <malat@debian.org>, Stefan Agner <stefan@agner.ch>, Dave Young <dyoung@redhat.com>, Baoquan He <bhe@redhat.com>, yinghai@kernel.org, vgoyal@redhat.com, linux-kernel@vger.kernel.org

Customer reported a bug on a high end server with many pcie devices, where
kernel bootup with crashkernel=384M, and kaslr is enabled. Even
though we still see much memory under 896 MB, the finding still failed
intermittently. Because currently we can only find region under 896 MB,
if w/0 ',high' specified. Then KASLR breaks 896 MB into several parts
randomly, and crashkernel reservation need be aligned to 128 MB, that's
why failure is found. It raises confusion to the end user that sometimes
crashkernel=X works while sometimes fails.
If want to make it succeed, customer can change kernel option to
"crashkernel=384M, high". Just this give "crashkernel=xx@yy" a very
limited space to behave even though its grammer looks more generic.
And we can't answer questions raised from customer that confidently:
1) why it doesn't succeed to reserve 896 MB;
2) what's wrong with memory region under 4G;
3) why I have to add ',high', I only require 384 MB, not 3840 MB.

This patch simplifies the method suggested in the mail [1]. It just goes
bottom-up to find a candidate region for crashkernel. The bottom-up may be
better compatible with the old reservation style, i.e. still want to get
memory region from 896 MB firstly, then [896 MB, 4G], finally above 4G.

There is one trivial thing about the compatibility with old kexec-tools:
if the reserved region is above 896M, then old tool will fail to load
bzImage. But without this patch, the old tool also fail since there is no
memory below 896M can be reserved for crashkernel.

[1]: http://lists.infradead.org/pipermail/kexec/2017-October/019571.html
Signed-off-by: Pingfan Liu <kernelfans@gmail.com>
Cc: Tang Chen <tangchen@cn.fujitsu.com>
Cc: "Rafael J. Wysocki" <rjw@rjwysocki.net>
Cc: Len Brown <lenb@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Mike Rapoport <rppt@linux.vnet.ibm.com>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Jonathan Corbet <corbet@lwn.net>
Cc: Yaowei Bai <baiyaowei@cmss.chinamobile.com>
Cc: Pavel Tatashin <pasha.tatashin@oracle.com>
Cc: Nicholas Piggin <npiggin@gmail.com>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Daniel Vacek <neelx@redhat.com>
Cc: Mathieu Malaterre <malat@debian.org>
Cc: Stefan Agner <stefan@agner.ch>
Cc: Dave Young <dyoung@redhat.com>
Cc: Baoquan He <bhe@redhat.com>
Cc: yinghai@kernel.org,
Cc: vgoyal@redhat.com
Cc: linux-kernel@vger.kernel.org
---
 arch/x86/kernel/setup.c | 9 ++++++---
 1 file changed, 6 insertions(+), 3 deletions(-)

diff --git a/arch/x86/kernel/setup.c b/arch/x86/kernel/setup.c
index d494b9b..165f9c3 100644
--- a/arch/x86/kernel/setup.c
+++ b/arch/x86/kernel/setup.c
@@ -541,15 +541,18 @@ static void __init reserve_crashkernel(void)
 
 	/* 0 means: find the address automatically */
 	if (crash_base <= 0) {
+		bool bottom_up = memblock_bottom_up();
+
+		memblock_set_bottom_up(true);
 		/*
 		 * Set CRASH_ADDR_LOW_MAX upper bound for crash memory,
 		 * as old kexec-tools loads bzImage below that, unless
 		 * "crashkernel=size[KMG],high" is specified.
 		 */
 		crash_base = memblock_find_in_range(CRASH_ALIGN,
-						    high ? CRASH_ADDR_HIGH_MAX
-							 : CRASH_ADDR_LOW_MAX,
-						    crash_size, CRASH_ALIGN);
+			(max_pfn * PAGE_SIZE), crash_size, CRASH_ALIGN);
+		memblock_set_bottom_up(bottom_up);
+
 		if (!crash_base) {
 			pr_info("crashkernel reservation failed - No suitable area found.\n");
 			return;
-- 
2.7.4
