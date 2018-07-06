Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 4F09C6B0007
	for <linux-mm@kvack.org>; Fri,  6 Jul 2018 12:18:00 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id f5-v6so4879757plf.18
        for <linux-mm@kvack.org>; Fri, 06 Jul 2018 09:18:00 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id l3-v6si7988687pld.223.2018.07.06.09.17.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 06 Jul 2018 09:17:59 -0700 (PDT)
Subject: [PATCH v2 1/2] x86/numa_emulation: Fix emulated-to-physical node
 mapping
From: Dan Williams <dan.j.williams@intel.com>
Date: Fri, 06 Jul 2018 09:08:01 -0700
Message-ID: <153089328103.27680.14778434392225818887.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <153089327581.27680.11402583130804677094.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <153089327581.27680.11402583130804677094.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mingo@kernel.org
Cc: Wei Yang <richard.weiyang@gmail.com>, David Rientjes <rientjes@google.com>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@redhat.com>, x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.orgx86@kernel.org

Without this change the distance table calculation for emulated nodes
may use the wrong numa node and report an incorrect distance.

Cc: Wei Yang <richard.weiyang@gmail.com>
Cc: David Rientjes <rientjes@google.com>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: "H. Peter Anvin" <hpa@zytor.com>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: <x86@kernel.org>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 arch/x86/mm/numa_emulation.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/arch/x86/mm/numa_emulation.c b/arch/x86/mm/numa_emulation.c
index 34a2a3bfde9c..22cbad56acab 100644
--- a/arch/x86/mm/numa_emulation.c
+++ b/arch/x86/mm/numa_emulation.c
@@ -61,7 +61,7 @@ static int __init emu_setup_memblk(struct numa_meminfo *ei,
 	eb->nid = nid;
 
 	if (emu_nid_to_phys[nid] == NUMA_NO_NODE)
-		emu_nid_to_phys[nid] = nid;
+		emu_nid_to_phys[nid] = pb->nid;
 
 	pb->start += size;
 	if (pb->start >= pb->end) {
