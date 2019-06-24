Return-Path: <SRS0=9FL3=UX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.7 required=3.0 tests=DATE_IN_FUTURE_06_12,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3A5AAC43613
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 13:03:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 08B18213F2
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 13:03:12 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 08B18213F2
Authentication-Results: mail.kernel.org; dmarc=fail (p=quarantine dis=none) header.from=vmware.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 94CC36B0008; Mon, 24 Jun 2019 09:03:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8D7F48E0003; Mon, 24 Jun 2019 09:03:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 776EA8E0002; Mon, 24 Jun 2019 09:03:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 3BBD76B0008
	for <linux-mm@kvack.org>; Mon, 24 Jun 2019 09:03:12 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id q11so940921pll.22
        for <linux-mm@kvack.org>; Mon, 24 Jun 2019 06:03:12 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version;
        bh=m2ABSez10NsjyZLoNHNYp82v2fZDDIVB7Dh3Iq8opcs=;
        b=YiqIU3/7QtbHjDJTjYVcAD4JHTVc1gtFlo6DMpcKo7buqQkautCht+MelT/kY2y7lt
         LSxquJWmeE/9mC19JeASSAuMgGyLfeFlmOgsNwNvqLCEc+lpudrmE6/7i7o5Pksbo955
         tZOa8nsFARFIXSNbx+ycnrN4jKnTF0aOXP0qJorZiciq7Fgjhw5q5vrPVo55iaIy3TpH
         FtUOG/unDOkjSIxS6xmPGMO+OuGO+yDSmWQJNzhQO/nHxxiII7pXAdSDOA+UDnKpPHos
         j9zlPQdCBa5sYnC0cV8EIXdGhNLLBt5EggIqGyJbFt8SiNCZBjj2tgT7/cUT5t8Wv737
         LM2w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of akaher@vmware.com designates 208.91.0.190 as permitted sender) smtp.mailfrom=akaher@vmware.com;       dmarc=pass (p=QUARANTINE sp=NONE dis=NONE) header.from=vmware.com
X-Gm-Message-State: APjAAAXg17SCDR6NIoiK/AyjKRRDMEFTg20hYjT/C2cY5rUXecQLZ6xi
	kKqT3Pa3uAZCVGUCBbSgID8sAviboDX9T74U3/UCVIhiEi/yFUmuH3KN+v9nOXdB62Jctp6zU9B
	ivj+KOwR9lgtiAlOcqGfnwEeirMngk2lbhSEUXBnWpfzDSwi+o8ETx2KyAnOtl/Fw4w==
X-Received: by 2002:a17:90a:32ed:: with SMTP id l100mr24476944pjb.11.1561381391896;
        Mon, 24 Jun 2019 06:03:11 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzkZ83MbCv+guwXnpfBN+orGPgPaoXeiAs8NUGpU54HAktoGolngWJrDhMX4+eBgQJjUTvF
X-Received: by 2002:a17:90a:32ed:: with SMTP id l100mr24476870pjb.11.1561381391170;
        Mon, 24 Jun 2019 06:03:11 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561381391; cv=none;
        d=google.com; s=arc-20160816;
        b=D68WZ9xCvr8OL+5TTFnNwE6+KHUZ+pTJCiz2T8sGDByncPTYSFBk7nUMuCaaCs3F2l
         4XVxx0fGSZwczmE0J/MHrPzO+EQ83JuPhrBPMDDSEKg1NPtktvy9N4wVZBLanU7rpN8m
         XmbCtkJtl3zmhOg7p7RX0Wln/WUsJpK7MdYDPdEOvhRfxFLCiMF641oyBDYFXti6VA0m
         0Cgyc8eDBKJau38vPRnNi508NAjw5l1T7n9BZcA8CdzhJjljByXundnmGXIp6qMyRKQe
         QY09UJZOJ7YGZ5hNYcJCkKsaIa8k1RObBayXBEWbcxbps5fiGGFUMAG+pThNEWTYTgEG
         aYWw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:in-reply-to:message-id:date:subject:cc:to
         :from;
        bh=m2ABSez10NsjyZLoNHNYp82v2fZDDIVB7Dh3Iq8opcs=;
        b=Nb4FHC53o6ojq0cMkkRKWLDvmzqYKitXwe+/RbMkpHzLI1Nmz6TkcAi5JTN0G7Vm00
         nbb6Dn/gZ11UlPo2HRnaSgNOAt5P5yGzhxI2E+CfKzhePDd1JN48LGrxfZSGw3GX385o
         FUC5KnaPVy8D0MK5NNjo2069GZ97UWXltCj6XlzJnYYiCib9hNoFO1O5gGa1qZ/EAVHI
         7XLrqN1vKEOqXalMvQOMTc0D5f/SWa1lawHddQAskdX97fFl1z7wGRBHWwysPCXkbt5K
         jeX2s7zMgfPO2VTBWdRUfofAtsIU8nAgCIwOGYd/B1Yfell8/gGTTYmdMl/NmzqtmTEy
         FyAA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of akaher@vmware.com designates 208.91.0.190 as permitted sender) smtp.mailfrom=akaher@vmware.com;
       dmarc=pass (p=QUARANTINE sp=NONE dis=NONE) header.from=vmware.com
Received: from EX13-EDG-OU-002.vmware.com (ex13-edg-ou-002.vmware.com. [208.91.0.190])
        by mx.google.com with ESMTPS id v19si9941240plo.404.2019.06.24.06.03.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 24 Jun 2019 06:03:11 -0700 (PDT)
Received-SPF: pass (google.com: domain of akaher@vmware.com designates 208.91.0.190 as permitted sender) client-ip=208.91.0.190;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of akaher@vmware.com designates 208.91.0.190 as permitted sender) smtp.mailfrom=akaher@vmware.com;
       dmarc=pass (p=QUARANTINE sp=NONE dis=NONE) header.from=vmware.com
Received: from sc9-mailhost3.vmware.com (10.113.161.73) by
 EX13-EDG-OU-002.vmware.com (10.113.208.156) with Microsoft SMTP Server id
 15.0.1156.6; Mon, 24 Jun 2019 06:03:08 -0700
Received: from akaher-lnx-dev.eng.vmware.com (unknown [10.110.19.203])
	by sc9-mailhost3.vmware.com (Postfix) with ESMTP id 69A894135D;
	Mon, 24 Jun 2019 06:03:03 -0700 (PDT)
From: Ajay Kaher <akaher@vmware.com>
To: <aarcange@redhat.com>, <jannh@google.com>, <oleg@redhat.com>,
	<peterx@redhat.com>, <rppt@linux.ibm.com>, <jgg@mellanox.com>,
	<mhocko@suse.com>
CC: <jglisse@redhat.com>, <akpm@linux-foundation.org>,
	<mike.kravetz@oracle.com>, <viro@zeniv.linux.org.uk>,
	<riandrews@android.com>, <arve@android.com>, <yishaih@mellanox.com>,
	<dledford@redhat.com>, <sean.hefty@intel.com>, <hal.rosenstock@gmail.com>,
	<matanb@mellanox.com>, <leonro@mellanox.com>,
	<linux-fsdevel@vger.kernel.org>, <linux-mm@kvack.org>,
	<devel@driverdev.osuosl.org>, <linux-rdma@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <stable@vger.kernel.org>,
	<akaher@vmware.com>, <srivatsab@vmware.com>, <amakhalov@vmware.com>, Hugh
 Dickins <hughd@google.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Linus
 Torvalds <torvalds@linux-foundation.org>, Greg Kroah-Hartman
	<gregkh@linuxfoundation.org>
Subject: [PATCH v4 3/3] [v4.9.y] coredump: fix race condition between mmget_not_zero()/get_task_mm() and core dumping
Date: Tue, 25 Jun 2019 02:33:05 +0530
Message-ID: <1561410186-3919-3-git-send-email-akaher@vmware.com>
X-Mailer: git-send-email 2.7.4
In-Reply-To: <1561410186-3919-1-git-send-email-akaher@vmware.com>
References: <1561410186-3919-1-git-send-email-akaher@vmware.com>
MIME-Version: 1.0
Content-Type: text/plain
Received-SPF: None (EX13-EDG-OU-002.vmware.com: akaher@vmware.com does not
 designate permitted sender hosts)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Andrea Arcangeli <aarcange@redhat.com>

coredump: fix race condition between collapse_huge_page() and core dumping

commit 59ea6d06cfa9247b586a695c21f94afa7183af74 upstream.

When fixing the race conditions between the coredump and the mmap_sem
holders outside the context of the process, we focused on
mmget_not_zero()/get_task_mm() callers in 04f5866e41fb70 ("coredump: fix
race condition between mmget_not_zero()/get_task_mm() and core
dumping"), but those aren't the only cases where the mmap_sem can be
taken outside of the context of the process as Michal Hocko noticed
while backporting that commit to older -stable kernels.

If mmgrab() is called in the context of the process, but then the
mm_count reference is transferred outside the context of the process,
that can also be a problem if the mmap_sem has to be taken for writing
through that mm_count reference.

khugepaged registration calls mmgrab() in the context of the process,
but the mmap_sem for writing is taken later in the context of the
khugepaged kernel thread.

collapse_huge_page() after taking the mmap_sem for writing doesn't
modify any vma, so it's not obvious that it could cause a problem to the
coredump, but it happens to modify the pmd in a way that breaks an
invariant that pmd_trans_huge_lock() relies upon.  collapse_huge_page()
needs the mmap_sem for writing just to block concurrent page faults that
call pmd_trans_huge_lock().

Specifically the invariant that "!pmd_trans_huge()" cannot become a
"pmd_trans_huge()" doesn't hold while collapse_huge_page() runs.

The coredump will call __get_user_pages() without mmap_sem for reading,
which eventually can invoke a lockless page fault which will need a
functional pmd_trans_huge_lock().

So collapse_huge_page() needs to use mmget_still_valid() to check it's
not running concurrently with the coredump...  as long as the coredump
can invoke page faults without holding the mmap_sem for reading.

This has "Fixes: khugepaged" to facilitate backporting, but in my view
it's more a bug in the coredump code that will eventually have to be
rewritten to stop invoking page faults without the mmap_sem for reading.
So the long term plan is still to drop all mmget_still_valid().

Link: http://lkml.kernel.org/r/20190607161558.32104-1-aarcange@redhat.com
Fixes: ba76149f47d8 ("thp: khugepaged")
Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
Reported-by: Michal Hocko <mhocko@suse.com>
Acked-by: Michal Hocko <mhocko@suse.com>
Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: Oleg Nesterov <oleg@redhat.com>
Cc: Jann Horn <jannh@google.com>
Cc: Hugh Dickins <hughd@google.com>
Cc: Mike Rapoport <rppt@linux.vnet.ibm.com>
Cc: Mike Kravetz <mike.kravetz@oracle.com>
Cc: Peter Xu <peterx@redhat.com>
Cc: Jason Gunthorpe <jgg@mellanox.com>
Cc: <stable@vger.kernel.org>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
Signed-off-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
[Ajay: Just adjusted to apply on v4.9]
Signed-off-by: Ajay Kaher <akaher@vmware.com>
---
 include/linux/mm.h | 4 ++++
 mm/khugepaged.c    | 3 +++
 2 files changed, 7 insertions(+)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index c239984..8852158 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1194,6 +1194,10 @@ void unmap_vmas(struct mmu_gather *tlb, struct vm_area_struct *start_vma,
  * followed by taking the mmap_sem for writing before modifying the
  * vmas or anything the coredump pretends not to change from under it.
  *
+ * It also has to be called when mmgrab() is used in the context of
+ * the process, but then the mm_count refcount is transferred outside
+ * the context of the process to run down_write() on that pinned mm.
+ *
  * NOTE: find_extend_vma() called from GUP context is the only place
  * that can modify the "mm" (notably the vm_start/end) under mmap_sem
  * for reading and outside the context of the process, so it is also
diff --git a/mm/khugepaged.c b/mm/khugepaged.c
index e0cfc3a..8217ee5 100644
--- a/mm/khugepaged.c
+++ b/mm/khugepaged.c
@@ -1004,6 +1004,9 @@ static void collapse_huge_page(struct mm_struct *mm,
 	 * handled by the anon_vma lock + PG_lock.
 	 */
 	down_write(&mm->mmap_sem);
+	result = SCAN_ANY_PROCESS;
+	if (!mmget_still_valid(mm))
+		goto out;
 	result = hugepage_vma_revalidate(mm, address, &vma);
 	if (result)
 		goto out;
-- 
2.7.4

