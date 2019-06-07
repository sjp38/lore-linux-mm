Return-Path: <SRS0=5PTg=UG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2A905C468BD
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 16:16:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F10FD2089E
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 16:16:06 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F10FD2089E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6E8636B000E; Fri,  7 Jun 2019 12:16:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 69A106B0266; Fri,  7 Jun 2019 12:16:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5AE5F6B0269; Fri,  7 Jun 2019 12:16:06 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 39B0A6B000E
	for <linux-mm@kvack.org>; Fri,  7 Jun 2019 12:16:06 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id 97so2231248qtb.16
        for <linux-mm@kvack.org>; Fri, 07 Jun 2019 09:16:06 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version:content-transfer-encoding;
        bh=P6Tzjc6ZTPm3CHLHlsoXQ8ibuJ0FdbAXQ1A2p7Jov30=;
        b=MZulHEgSZD2+Yt5TCEzX1+42WVOwe9Prr3y2evfXST+BFPG7Mh4xoqdMXECEr5jsH5
         h6SUbWjIoMCR/N/4baYFHn0oICHR8uHJkXYyGJYjWygRL4pPLLPuptFOQNNXo2vqvSZS
         GbPPKDvTz6CCO+ZIJQGcUIj9Gjy4FQFo5oFKXZYjL36dkpUL6hEjNPWsBFriON/yZ0Jt
         +KwN1N7seMkdOWA9EA7bEfABz1z6ajfUrIjwtmRc4DDrlqr8uXwZ1h1/xol0xzsIDl+N
         p08ZehT3C6sef+GP+XNQz+RQKYc3XAAqJ3zwIEZPu55MqC3dvz8LP4wmZ9PdSvnHz8sq
         7WzA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of aarcange@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=aarcange@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAW4LShxsZgz1UgX/GqRtPsqep+dXGzYgP2xbB0i3Jl55z0F5j6b
	XhY4ENqxe3LWyDUzC5TOljznp6X2EFMKY0olK1MBtcRgWOs/ZbamkBXeRQRgO0pnNKaT/f15iQR
	ZaneEai9pPYz2nwMioAhkepBPwCHQ/Lil/meL3xTyY8xiO5zunLL1hAGQvQdyPjmwuw==
X-Received: by 2002:a37:a24f:: with SMTP id l76mr5862815qke.252.1559924165944;
        Fri, 07 Jun 2019 09:16:05 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwmP53p3/MIstLmaUJAZ1dNNDRut71grMy/RIUdqggtVoYc17PMI+z3hmLhZltQg/680p2S
X-Received: by 2002:a37:a24f:: with SMTP id l76mr5862747qke.252.1559924165245;
        Fri, 07 Jun 2019 09:16:05 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559924165; cv=none;
        d=google.com; s=arc-20160816;
        b=dIyg2IcuFeolfHPDZn6us0Z2zKyIx1skV4sYfj9uwCIfHfWajuqdZn0KSQfo31QA2F
         i379r6ti0NoeFph3KlcPcDhd3Iz3sHUcASH6xxSqrAsK3vkMTdRmagMBkSLtrYCA2U8/
         56CerhWXyhMqLjdN4oRSsZwbMRZ2jAvlMKcrEupYwJo9Ob+IkPoiNpYO7CbteV2++k2z
         FBQcIDlwvCtmHxIoVcOdaZ1uqVkb+MU1thFVqDgeTAL9Pvp7lSeXE4LdMCe3v43ZJ/8d
         G4MdcsYRQAN3Yra69n3jByhPdpCBfZOk9OB7QKuNvClZk45DKkI2g8Byqw4B21Vr/1LH
         mAgw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from;
        bh=P6Tzjc6ZTPm3CHLHlsoXQ8ibuJ0FdbAXQ1A2p7Jov30=;
        b=RoKgEfKWK+FX/C38YCsrQCZdVG7tDUxmu6VyBu8+ixXa+jEuNjy6oUvh4Px1lxMqaW
         wQkZRGdrpqcoC5HZuh1Q0mAeUlf0p6fXBJMLjwTSsD2A4SMEVFxq2djIbpmIzla4NxFm
         gX82oUEfmTLRLq3cN4ln+YumDpXHXhJCgqb51DpOAGaIeBntkj05dpDWbNcKDNy7VCGq
         IhJv7juQO+91ib9NVGKTSm+iHXTODGDaCUtDD/HZi65QnZsVW7lRn2Rum3e9FvQY/hWN
         bjrB43pfTwoFHJ4Ux1tIC7sLsOeCIrVScXQdW6rRufRzp6Fx9CdnxLtf2BAZb8OXZLgc
         CEeQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of aarcange@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=aarcange@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id w142si666376qka.131.2019.06.07.09.16.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 07 Jun 2019 09:16:05 -0700 (PDT)
Received-SPF: pass (google.com: domain of aarcange@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of aarcange@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=aarcange@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 51CE9C01F28C;
	Fri,  7 Jun 2019 16:16:04 +0000 (UTC)
Received: from ultra.random (ovpn-120-155.rdu2.redhat.com [10.10.120.155])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 5264910A4B40;
	Fri,  7 Jun 2019 16:15:59 +0000 (UTC)
From: Andrea Arcangeli <aarcange@redhat.com>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org,
	linux-mm@kvack.org,
	Oleg Nesterov <oleg@redhat.com>,
	Jann Horn <jannh@google.com>,
	Hugh Dickins <hughd@google.com>,
	Mike Rapoport <rppt@linux.vnet.ibm.com>,
	Mike Kravetz <mike.kravetz@oracle.com>,
	Peter Xu <peterx@redhat.com>,
	Jason Gunthorpe <jgg@mellanox.com>,
	"Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>,
	Michal Hocko <mhocko@suse.com>
Subject: [PATCH 1/1] coredump: fix race condition between collapse_huge_page() and core dumping
Date: Fri,  7 Jun 2019 12:15:58 -0400
Message-Id: <20190607161558.32104-1-aarcange@redhat.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.31]); Fri, 07 Jun 2019 16:16:04 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

When fixing the race conditions between the coredump and the mmap_sem
holders outside the context of the process, we focused on
mmget_not_zero()/get_task_mm() callers in commit
04f5866e41fb70690e28397487d8bd8eea7d712a, but those aren't the only
cases where the mmap_sem can be taken outside of the context of the
process as Michal Hocko noticed while backporting that commit to
older -stable kernels.

If mmgrab() is called in the context of the process, but then the
mm_count reference is transferred outside the context of the process,
that can also be a problem if the mmap_sem has to be taken for writing
through that mm_count reference.

khugepaged registration calls mmgrab() in the context of the process,
but the mmap_sem for writing is taken later in the context of the
khugepaged kernel thread.

collapse_huge_page() after taking the mmap_sem for writing doesn't
modify any vma, so it's not obvious that it could cause a problem to
the coredump, but it happens to modify the pmd in a way that breaks an
invariant that pmd_trans_huge_lock() relies upon. collapse_huge_page()
needs the mmap_sem for writing just to block concurrent page faults
that call pmd_trans_huge_lock().

Specifically the invariant that "!pmd_trans_huge()" cannot become
a "pmd_trans_huge()" doesn't hold while collapse_huge_page() runs.

The coredump will call __get_user_pages() without mmap_sem for
reading, which eventually can invoke a lockless page fault which will
need a functional pmd_trans_huge_lock().

So collapse_huge_page() needs to use mmget_still_valid() to check it's
not running concurrently with the coredump... as long as the coredump
can invoke page faults without holding the mmap_sem for reading.

This has "Fixes: khugepaged" to facilitate backporting, but in my view
it's more a bug in the coredump code that will eventually have to be
rewritten to stop invoking page faults without the mmap_sem for
reading. So the long term plan is still to drop all
mmget_still_valid().

Cc: <stable@vger.kernel.org>
Fixes: ba76149f47d8 ("thp: khugepaged")
Reported-by: Michal Hocko <mhocko@suse.com>
Acked-by: Michal Hocko <mhocko@suse.com>
Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 include/linux/sched/mm.h | 4 ++++
 mm/khugepaged.c          | 3 +++
 2 files changed, 7 insertions(+)

diff --git a/include/linux/sched/mm.h b/include/linux/sched/mm.h
index a3fda9f024c3..4a7944078cc3 100644
--- a/include/linux/sched/mm.h
+++ b/include/linux/sched/mm.h
@@ -54,6 +54,10 @@ static inline void mmdrop(struct mm_struct *mm)
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
index a335f7c1fac4..0f7419938008 100644
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

