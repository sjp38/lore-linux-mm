Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 243BD6B038B
	for <linux-mm@kvack.org>; Sun, 19 Feb 2017 05:04:16 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id 2so88423405pfz.5
        for <linux-mm@kvack.org>; Sun, 19 Feb 2017 02:04:16 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id o1si15375651pld.43.2017.02.19.02.04.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 19 Feb 2017 02:04:15 -0800 (PST)
Received: from pps.filterd (m0098396.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v1JA3dUk012872
	for <linux-mm@kvack.org>; Sun, 19 Feb 2017 05:04:14 -0500
Received: from e37.co.us.ibm.com (e37.co.us.ibm.com [32.97.110.158])
	by mx0a-001b2d01.pphosted.com with ESMTP id 28ppuhcx37-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Sun, 19 Feb 2017 05:04:14 -0500
Received: from localhost
	by e37.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Sun, 19 Feb 2017 03:04:13 -0700
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [PATCH V3 0/3] Numabalancing preserve write fix
Date: Sun, 19 Feb 2017 15:33:42 +0530
Message-Id: <1487498625-10891-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, Rik van Riel <riel@surriel.com>, Mel Gorman <mgorman@techsingularity.net>, paulus@ozlabs.org, benh@kernel.crashing.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

This patch series address an issue w.r.t THP migration and autonuma
preserve write feature. migrate_misplaced_transhuge_page() cannot deal with
concurrent modification of the page. It does a page copy without
following the migration pte sequence. IIUC, this was done to keep the
migration simpler and at the time of implemenation we didn't had THP
page cache which would have required a more elaborate migration scheme.
That means thp autonuma migration expect the protnone with saved write
to be done such that both kernel and user cannot update
the page content. This patch series enables archs like ppc64 to do that.
We are good with the hash translation mode with the current code,
because we never create a hardware page table entry for a protnone pte. 

Changes form V2:
* Fix kvm crashes due to ksm not clearing savedwrite bit.

Changes from V1:
* Update the patch so that it apply cleanly to upstream.
* Add acked-by from Michael Neuling

Aneesh Kumar K.V (3):
  mm/autonuma: Let architecture override how the write bit should be
    stashed in a protnone pte.
  mm/ksm: Handle protnone saved writes when making page write protect
  powerpc/mm/autonuma: Switch ppc64 to its own implementeation of saved
    write

 arch/powerpc/include/asm/book3s/64/pgtable.h | 52 ++++++++++++++++++++++++----
 include/asm-generic/pgtable.h                | 24 +++++++++++++
 mm/huge_memory.c                             |  6 ++--
 mm/ksm.c                                     |  9 +++--
 mm/memory.c                                  |  2 +-
 mm/mprotect.c                                |  4 +--
 6 files changed, 82 insertions(+), 15 deletions(-)

-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
