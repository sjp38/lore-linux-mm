Return-Path: <SRS0=U/7Q=V7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.7 required=3.0 tests=DATE_IN_FUTURE_06_12,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id ADA14C433FF
	for <linux-mm@archiver.kernel.org>; Sat,  3 Aug 2019 19:59:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 681CB2075C
	for <linux-mm@archiver.kernel.org>; Sat,  3 Aug 2019 19:59:18 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 681CB2075C
Authentication-Results: mail.kernel.org; dmarc=fail (p=quarantine dis=none) header.from=vmware.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1D6076B0008; Sat,  3 Aug 2019 15:59:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 186D36B000A; Sat,  3 Aug 2019 15:59:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 075AA6B000C; Sat,  3 Aug 2019 15:59:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id C4E306B0008
	for <linux-mm@kvack.org>; Sat,  3 Aug 2019 15:59:17 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id 145so50575566pfw.16
        for <linux-mm@kvack.org>; Sat, 03 Aug 2019 12:59:17 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version;
        bh=m2ABSez10NsjyZLoNHNYp82v2fZDDIVB7Dh3Iq8opcs=;
        b=QSnDbz6+OUf8DldxNejwz5sbcr+efBoA/b6Vyaznu8BtgK2PvvykFIheWf2kSH/tTs
         RQIwh87ml9zui59FEpb7KxtKAFbEhAu5gyZbNqkRUXcD8zdvUYoRfGLJbnKYjiiZvWov
         TtgklJKOvJHjpjO0Sbn2Se2flZJhh7M/qFqwC9woZZXQAU7GuwYvodmglLDuC1+bfkJP
         RdZ4dMsdXkpnBMGoCpoX/JCY0eBM5KJxmhGd3yvKmkMa/p1yN9mfT9z3Ak83sCFzPYXQ
         Y8wzZ3OGXnnxQ2zyXn9qNX92nkcUcgLb634jHQUsjUTsFKQAZiYe6SsjMa33DnJXmrHj
         sZxQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of akaher@vmware.com designates 208.91.0.190 as permitted sender) smtp.mailfrom=akaher@vmware.com;       dmarc=pass (p=QUARANTINE sp=NONE dis=NONE) header.from=vmware.com
X-Gm-Message-State: APjAAAW1u5yei4hcCah/yIAZkkGo/r6skJOmavLq4BBtoZ9mWU5S6woR
	L2lGStFCVNBVjs1ygT77FzXOC6IBfQVMTKetE8Wat5qZj721eS8CwEk8bEkKT9ugiW9xyUqzm53
	+H4IRjAZdm6yGglcNuIybplLTfWWIKfT4neac784Q1iP84TnG6LyTqDs2jGpYUtr81A==
X-Received: by 2002:a62:107:: with SMTP id 7mr66567805pfb.4.1564862357438;
        Sat, 03 Aug 2019 12:59:17 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyLWs9BBTFDlAy+3K+A7U8epgBpi3xnQ9rcXI1bw4/HATeWDBYkG2cc7MZsJ+CoJ/6WmYWm
X-Received: by 2002:a62:107:: with SMTP id 7mr66567767pfb.4.1564862356480;
        Sat, 03 Aug 2019 12:59:16 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564862356; cv=none;
        d=google.com; s=arc-20160816;
        b=Xe/FTW8PLNQbZYNHyXaTtzxoU7cBi5Q7lbIRtfHTMg3yXy+YdFaWa5Fm2fkG+LVtAZ
         vkWcRnln/zFD2voU+bXHCVWh6KQe8fE22c6Wvu88CnG4mcFVufTs1QqzXuRCWs2s7y+X
         0g2A6Kyy+jLDZW80xTf4fqk0b/ATf/FoEZ7fAhgCdrjoPoymsjkj9woR53anUOh5adOr
         XoCk7cqHwYaHcSYsnY2mEM3SD7ARu12rrgssDz5xeNQ2t4kybf8xjkx5T1bIEq9RMZFf
         B1cASUEgqAZwBUiycHNjVKECnJ4GjID556WJ++hRPKRQA/OULw2nySTTTXat5hmu3Oe7
         gstQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:in-reply-to:message-id:date:subject:cc:to
         :from;
        bh=m2ABSez10NsjyZLoNHNYp82v2fZDDIVB7Dh3Iq8opcs=;
        b=cLNUlyPHq98v+f/l07y+q220emdm2ip1a3MbFzNPlqLzeSJmTgFLyxbaNWOQ9dlWML
         eLGmm51cfbMldFu+tf+aBC35u9izHUu0UCECF5tASdOHiU5tFg3a9z3UpjxCtkvJOsZt
         CpgwAK/iXfXXu5/Sn7/bl9zgaiJsu/qlBJuv1YgIPM7IvGmmscjITZTqm4WlJz0bPJsr
         LDpvLi+VvJDr8MyjRwWOUgOtWiEKbPLEt1Y98JRBX1ryrN0l1wADbep87SvKaprGMs6s
         Rt2zi+hIGeksPG89Tl1r+GnRfIEnSqjAOak+M5e3xS/Fv82Ia9pIXc4dVqbuMPG3RtKO
         BJLw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of akaher@vmware.com designates 208.91.0.190 as permitted sender) smtp.mailfrom=akaher@vmware.com;
       dmarc=pass (p=QUARANTINE sp=NONE dis=NONE) header.from=vmware.com
Received: from EX13-EDG-OU-002.vmware.com (ex13-edg-ou-002.vmware.com. [208.91.0.190])
        by mx.google.com with ESMTPS id h36si38195442plb.199.2019.08.03.12.59.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Sat, 03 Aug 2019 12:59:16 -0700 (PDT)
Received-SPF: pass (google.com: domain of akaher@vmware.com designates 208.91.0.190 as permitted sender) client-ip=208.91.0.190;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of akaher@vmware.com designates 208.91.0.190 as permitted sender) smtp.mailfrom=akaher@vmware.com;
       dmarc=pass (p=QUARANTINE sp=NONE dis=NONE) header.from=vmware.com
Received: from sc9-mailhost2.vmware.com (10.113.161.72) by
 EX13-EDG-OU-002.vmware.com (10.113.208.156) with Microsoft SMTP Server id
 15.0.1156.6; Sat, 3 Aug 2019 12:59:09 -0700
Received: from akaher-lnx-dev.eng.vmware.com (unknown [10.110.19.203])
	by sc9-mailhost2.vmware.com (Postfix) with ESMTP id F3F59B26C6;
	Sat,  3 Aug 2019 15:59:07 -0400 (EDT)
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
	<stable@vger.kernel.org>, <akaher@vmware.com>, <srinidhir@vmware.com>,
	<bvikas@vmware.com>, <srivatsab@vmware.com>, <srivatsa@csail.mit.edu>,
	<amakhalov@vmware.com>, <vsirnapalli@vmware.com>, Hugh Dickins
	<hughd@google.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: [PATCH v6 3/3] [v4.9.y] coredump: fix race condition between collapse_huge_page() and core dumping 
Date: Sun, 4 Aug 2019 09:29:27 +0530
Message-ID: <1564891168-30016-3-git-send-email-akaher@vmware.com>
X-Mailer: git-send-email 2.7.4
In-Reply-To: <1564891168-30016-1-git-send-email-akaher@vmware.com>
References: <1564891168-30016-1-git-send-email-akaher@vmware.com>
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

