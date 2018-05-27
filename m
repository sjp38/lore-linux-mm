Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4D0F26B000A
	for <linux-mm@kvack.org>; Sat, 26 May 2018 21:06:51 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id w7-v6so5222761pfd.9
        for <linux-mm@kvack.org>; Sat, 26 May 2018 18:06:51 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id y12-v6si27176832plt.233.2018.05.26.18.06.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 26 May 2018 18:06:50 -0700 (PDT)
Subject: [PATCH 1/2] x86/numa_emulation: Fix emulated-to-physical node
 mapping
From: Dan Williams <dan.j.williams@intel.com>
Date: Sat, 26 May 2018 17:56:52 -0700
Message-ID: <152738261272.11641.17387529225149633595.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <152738260746.11641.13275998345345705617.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <152738260746.11641.13275998345345705617.stgit@dwillia2-desk3.amr.corp.intel.com>
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
