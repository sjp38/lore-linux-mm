Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx151.postini.com [74.125.245.151])
	by kanga.kvack.org (Postfix) with SMTP id DB99F6B0044
	for <linux-mm@kvack.org>; Fri, 16 Mar 2012 15:28:20 -0400 (EDT)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH] numa_emulation: fix cpumask_of_node()
Date: Fri, 16 Mar 2012 20:28:11 +0100
Message-Id: <1331926091-22548-2-git-send-email-aarcange@redhat.com>
In-Reply-To: <1331926091-22548-1-git-send-email-aarcange@redhat.com>
References: <1331926091-22548-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-numa@vger.kernel.org
Cc: Andi Kleen <andi@firstfloor.org>, Johannes Weiner <jweiner@redhat.com>, Andrew Morton <akpm@linux-foundation.org>

Without this fix the cpumask_of_node() for a fake=numa=2 is:

cpumask 0 ff
cpumask 1 ff

with the fix it's correct and it's set to:

cpumask 0 55
cpumask 1 aa

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 arch/x86/mm/numa_emulation.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/arch/x86/mm/numa_emulation.c b/arch/x86/mm/numa_emulation.c
index 46db568..740b0a3 100644
--- a/arch/x86/mm/numa_emulation.c
+++ b/arch/x86/mm/numa_emulation.c
@@ -60,7 +60,7 @@ static int __init emu_setup_memblk(struct numa_meminfo *ei,
 	eb->nid = nid;
 
 	if (emu_nid_to_phys[nid] == NUMA_NO_NODE)
-		emu_nid_to_phys[nid] = pb->nid;
+		emu_nid_to_phys[nid] = nid;
 
 	pb->start += size;
 	if (pb->start >= pb->end) {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
