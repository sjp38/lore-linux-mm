Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id BADD46B0387
	for <linux-mm@kvack.org>; Tue, 14 Feb 2017 00:32:24 -0500 (EST)
Received: by mail-it0-f69.google.com with SMTP id 203so17045996ith.3
        for <linux-mm@kvack.org>; Mon, 13 Feb 2017 21:32:24 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id h193si13001725ioh.195.2017.02.13.21.32.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 13 Feb 2017 21:32:24 -0800 (PST)
Received: from pps.filterd (m0098416.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v1E5VF8Z007665
	for <linux-mm@kvack.org>; Tue, 14 Feb 2017 00:32:23 -0500
Received: from e33.co.us.ibm.com (e33.co.us.ibm.com [32.97.110.151])
	by mx0b-001b2d01.pphosted.com with ESMTP id 28kts41xw2-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 14 Feb 2017 00:32:23 -0500
Received: from localhost
	by e33.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Mon, 13 Feb 2017 22:32:22 -0700
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [PATCH V2 0/2] Numabalancing preserve write fix
Date: Tue, 14 Feb 2017 11:01:52 +0530
Message-Id: <1487050314-3892-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
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

Changes from V1:
* Update the patch so that it apply cleanly to upstream.
* Add acked-by from Michael Neuling

Aneesh Kumar K.V (2):
  mm/autonuma: Let architecture override how the write bit should be
    stashed in a protnone pte.
  powerpc/mm/autonuma: Switch ppc64 to its own implementeation of saved
    write

 arch/powerpc/include/asm/book3s/64/mmu-hash.h |  3 +++
 arch/powerpc/include/asm/book3s/64/pgtable.h  | 32 +++++++++++++++++++++++++--
 include/asm-generic/pgtable.h                 | 16 ++++++++++++++
 mm/huge_memory.c                              |  4 ++--
 mm/memory.c                                   |  2 +-
 mm/mprotect.c                                 |  4 ++--
 6 files changed, 54 insertions(+), 7 deletions(-)

-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
