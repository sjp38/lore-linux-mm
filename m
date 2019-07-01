Return-Path: <SRS0=jfnU=U6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-10.0 required=3.0 tests=DATE_IN_FUTURE_06_12,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1A7C5C06511
	for <linux-mm@archiver.kernel.org>; Mon,  1 Jul 2019 10:32:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CEF2E206A3
	for <linux-mm@archiver.kernel.org>; Mon,  1 Jul 2019 10:32:44 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CEF2E206A3
Authentication-Results: mail.kernel.org; dmarc=fail (p=quarantine dis=none) header.from=vmware.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6EB318E0007; Mon,  1 Jul 2019 06:32:44 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6742F8E0002; Mon,  1 Jul 2019 06:32:44 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4EFDD8E0007; Mon,  1 Jul 2019 06:32:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f205.google.com (mail-pg1-f205.google.com [209.85.215.205])
	by kanga.kvack.org (Postfix) with ESMTP id 11D6D8E0002
	for <linux-mm@kvack.org>; Mon,  1 Jul 2019 06:32:44 -0400 (EDT)
Received: by mail-pg1-f205.google.com with SMTP id o16so6213963pgk.18
        for <linux-mm@kvack.org>; Mon, 01 Jul 2019 03:32:44 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version;
        bh=m2ABSez10NsjyZLoNHNYp82v2fZDDIVB7Dh3Iq8opcs=;
        b=eOEoUVS6H706D+zaQzerkdGxp0tIxudtxYHPy3kJnubuwvSm0RzohB826sPm+fAieX
         EWGtTrXbHkzQxhf/pcfNLQPJANxFtv90Irl8rhxvhj2Clykn1vGJq3Luq1zWqC7IamNp
         P/B7zVEURtxytu4q0T1toG6kSABtD6wY8G612WQKfELn3bClZ+clztzLztIe3a9aggf7
         BRV4xBUsV1Si8tPNFto/F5NP4O2iMajJSzkIW0LuSpz2eHGoAHtEGC/uPRgufe0Y/paY
         IIi5pTgFKNoKRfag4UiZfGFIdfRrqlBsFTS0wHUIv3nJtfyfu+oip12caTN3jYlAZzR8
         uNYw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of akaher@vmware.com designates 208.91.0.189 as permitted sender) smtp.mailfrom=akaher@vmware.com;       dmarc=pass (p=QUARANTINE sp=NONE dis=NONE) header.from=vmware.com
X-Gm-Message-State: APjAAAUwxrVT5Ib2PD6CqABzdZMt5VU69mWqtmHl4z/jFFwcOHOae7GC
	2tSqNvjL/SKc4jj+IsqCegfMeQqvL1r0MocDkmGrH52ussvYXxB/KImZOqnTMxzJirzHY909WBo
	xz9hl3SIaeO9hUNQPQfaQUo2VKFuv11FvkLYstFK5hHhUwNxy8CB5qpLai0zMWCEfUQ==
X-Received: by 2002:a17:902:2ba7:: with SMTP id l36mr27883322plb.334.1561977163722;
        Mon, 01 Jul 2019 03:32:43 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzndquMPvSO6FWc8Ff3lCDkDnW9i2R0CSamHGqvtUyLoVN9fFHiWgETFhgmzW3G7PO8X7Y+
X-Received: by 2002:a17:902:2ba7:: with SMTP id l36mr27883251plb.334.1561977162918;
        Mon, 01 Jul 2019 03:32:42 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561977162; cv=none;
        d=google.com; s=arc-20160816;
        b=lWiIPAauUB0Jn3uCDxIkWVkM9s/nCZAB/CFMek0VgiR8jUtuzSTGVcjm6Bjzhb+DZr
         eNX8hVADJQAZmGRFliZ0xq+01WyFUNzzy91MoWokhqwlxAEEac2ptdXKEWpTld8t+NmI
         eHttB+j6JleuttAL8kUw4g6UPyHoiohFduw9up2pJMyL/JLUbcQft+JKGL+4WA1dmx+N
         W7+1crbZ+IntiSqe5BoTMdXwjEahSRvGYueESCxd2uVZCD45Xt1PMjvg0S3bH5SKszPU
         GZHMN+D675QzpRuinpAa2niDlDrOtiunHysfMAYawwUc4DlY0myNPTHbRyCye3FWTIEK
         owNg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:in-reply-to:message-id:date:subject:cc:to
         :from;
        bh=m2ABSez10NsjyZLoNHNYp82v2fZDDIVB7Dh3Iq8opcs=;
        b=vbY6qHWgjKdiut+53imfusn/1GjhMPlAadSYEPp/IZvrM3vIfnRuacmRcKWTre9yJC
         s5nhHdV1vNVro+5LWwFmCaGlrKpOTELQtvURe95kqKx/JElfqYwCNe0+Ll4GIcMF1B57
         isve76+mK43ZMSTt4q7pkBPBWZWXx6w0ucZ0ymzgwmuoa8nmSLjVD63UE++WDQk6bZdO
         3hQAFm1ulxi7U03UfQw2HCgTYvPCYa0H1zHbMUcO10Tp7f6fAi2ytMOqbs/M/LCqVi84
         UCyxn5EB2vXD2R/npSeQJznLP4QwMuCqeoZxo+MXzBBdPnPPmjOfV/9S+W2Iybz5JCEI
         VlxA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of akaher@vmware.com designates 208.91.0.189 as permitted sender) smtp.mailfrom=akaher@vmware.com;
       dmarc=pass (p=QUARANTINE sp=NONE dis=NONE) header.from=vmware.com
Received: from EX13-EDG-OU-001.vmware.com (ex13-edg-ou-001.vmware.com. [208.91.0.189])
        by mx.google.com with ESMTPS id d7si3801228pfd.185.2019.07.01.03.32.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 01 Jul 2019 03:32:42 -0700 (PDT)
Received-SPF: pass (google.com: domain of akaher@vmware.com designates 208.91.0.189 as permitted sender) client-ip=208.91.0.189;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of akaher@vmware.com designates 208.91.0.189 as permitted sender) smtp.mailfrom=akaher@vmware.com;
       dmarc=pass (p=QUARANTINE sp=NONE dis=NONE) header.from=vmware.com
Received: from sc9-mailhost3.vmware.com (10.113.161.73) by
 EX13-EDG-OU-001.vmware.com (10.113.208.155) with Microsoft SMTP Server id
 15.0.1156.6; Mon, 1 Jul 2019 03:32:40 -0700
Received: from akaher-lnx-dev.eng.vmware.com (unknown [10.110.19.203])
	by sc9-mailhost3.vmware.com (Postfix) with ESMTP id 313D240FF2;
	Mon,  1 Jul 2019 03:32:34 -0700 (PDT)
From: Ajay Kaher <akaher@vmware.com>
To: <aarcange@redhat.com>, <jannh@google.com>, <oleg@redhat.com>,
	<peterx@redhat.com>, <rppt@linux.ibm.com>, <jgg@mellanox.com>,
	<mhocko@suse.com>
CC: <jglisse@redhat.com>, <akpm@linux-foundation.org>,
	<mike.kravetz@oracle.com>, <viro@zeniv.linux.org.uk>,
	<riandrews@android.com>, <arve@android.com>, <yishaih@mellanox.com>,
	<dledford@redhat.com>, <sean.hefty@intel.com>, <hal.rosenstock@gmail.com>,
	<matanb@mellanox.com>, <leonro@mellanox.com>, <gregkh@linuxfoundation.org>,
	<torvalds@linux-foundation.org>, <linux-fsdevel@vger.kernel.org>,
	<linux-mm@kvack.org>, <devel@driverdev.osuosl.org>,
	<linux-rdma@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<stable@vger.kernel.org>, <akaher@vmware.com>, <srivatsab@vmware.com>,
	<amakhalov@vmware.com>, Hugh Dickins <hughd@google.com>, Mike Rapoport
	<rppt@linux.vnet.ibm.com>
Subject: [PATCH v5 3/3] [v4.9.y] coredump: fix race condition between collapse_huge_page() and core dumping 
Date: Tue, 2 Jul 2019 00:02:07 +0530
Message-ID: <1562005928-1929-3-git-send-email-akaher@vmware.com>
X-Mailer: git-send-email 2.7.4
In-Reply-To: <1562005928-1929-1-git-send-email-akaher@vmware.com>
References: <1562005928-1929-1-git-send-email-akaher@vmware.com>
MIME-Version: 1.0
Content-Type: text/plain
Received-SPF: None (EX13-EDG-OU-001.vmware.com: akaher@vmware.com does not
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

