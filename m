Return-Path: <SRS0=424v=UT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4E552C4646C
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 02:21:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 16632217D4
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 02:21:30 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 16632217D4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B45176B000A; Wed, 19 Jun 2019 22:21:29 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AF6248E0002; Wed, 19 Jun 2019 22:21:29 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A0B268E0001; Wed, 19 Jun 2019 22:21:29 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 80BF26B000A
	for <linux-mm@kvack.org>; Wed, 19 Jun 2019 22:21:29 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id g30so1646102qtm.17
        for <linux-mm@kvack.org>; Wed, 19 Jun 2019 19:21:29 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=uZWZF/ts0L0/JdFkWSzEUhYz+Ba9eyZsNkgqvbsHxug=;
        b=ax9TYG2lYvH8AX1Dm0TlCP0CdyldrZbpC9uLUCvH+cSnO/jjJ/V/sPNBLIKHYDTezh
         EJ1/7K28igJlj9Hz/AEMp/Zi6JUvCm7CerFbM38oRwnGXNn/j23Zfp1gqmrip5VT/nPW
         nWjMeU5D6dH907TfVSBQmgZFdSQVoduVj9N0mc+91XjYmzOYq9Y6Iog/HcGHfmHObuBN
         ramqOB0gT33k6f4XFdPg10EL8DisUJZgKx74w/L4jcx/v2v2FsyFBlWJlYEpiPHKTy3P
         AyVJOLsE2vQXG7rojy4Ibz0Trwl4Ndah6WejZshLpGbF242DgM0IV6XyZcGlruhmqGr4
         O4PA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWzA+0F77/gEY0vUx8Np1nF0CIDi6F/ZkkhcclAtUkHA+UZl3o5
	ZACc6kGLcIosC64C/u95J6QY96i1yzgL6gfZ2LWZ8RvAOiJGecO6PQSp0fK5ZlboVdmJAMEELBh
	Mwckw+5wyOxCrpUy5zwJWhuvjWkBLDVHRsscGerfPwOebmXWAAvzu9IxA5IQoRpb6sQ==
X-Received: by 2002:ac8:17ac:: with SMTP id o41mr36757594qtj.184.1560997289321;
        Wed, 19 Jun 2019 19:21:29 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz/PLtt/dEALTn5A8NvPn85L03ASbaxnE37ZGw56jL2a3rYuT/E88eyUgmCbopmLvzG+nPN
X-Received: by 2002:ac8:17ac:: with SMTP id o41mr36757554qtj.184.1560997288575;
        Wed, 19 Jun 2019 19:21:28 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560997288; cv=none;
        d=google.com; s=arc-20160816;
        b=m+5VzYAqGLmjZVSyIMzMW+YZw2ccU0HXRopojM9jp8pYKpV7doz55vKFdfyOGM0TOP
         UxbXH55gMn3tVlrgNUpdCj/G88dp8YWt9JqvLL8QiJKWIcKuSv7cbOh8gW6PS3GUpVEr
         E6ehjPipc2JV86eNMxlP5juvT+9tisfwnRb6JhM2t779ux54tuXy7D0cnNaETkpYxUp3
         bBw7LetpBJ8xIfY3J20gGmz1ZhObTNzL3hUGREyLINmDeaXNTeCeALEvfQQtt7LsWD4Y
         nWyme4APAkeFHgeQ2bWQDqTSruA+uAYXidiSc0bYVMt36wu3lK8qXaeDKXc1PjUJxtS7
         /vdg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=uZWZF/ts0L0/JdFkWSzEUhYz+Ba9eyZsNkgqvbsHxug=;
        b=u8Ft5qrDShEIiWA+QU+xD47JeV2wG75LmtLHH00AZofLe2D69KcBbR8SBw9p8VDK6k
         05HbqfEWpGsC5mBPQsFBgIWMNTk71l5ESkotT40ugcnfJJVN0sGHxOPgMj71Agwzj+6q
         xeudnTM3SD0SrOHkFSH9HwZSDPSSneObyqdM9smisSa7LmNyUp6VwM96/XpWgYM88mKb
         d9K8B+BMtRuvd9nfS9v58ud0DaaTsx4YYL5ucPsrwGT9kP3H/3FY3nJMnvGT3CCxW55W
         KJbqAxQm4yr9wRkclLfTtqE0CE1/f9fi3/4wgex2JagwuAWSn9C1F9vTRc4BgFyH7bCG
         jskA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id n63si13801728qka.114.2019.06.19.19.21.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Jun 2019 19:21:28 -0700 (PDT)
Received-SPF: pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id C7DC5308427C;
	Thu, 20 Jun 2019 02:21:27 +0000 (UTC)
Received: from xz-x1.redhat.com (ovpn-12-78.pek2.redhat.com [10.72.12.78])
	by smtp.corp.redhat.com (Postfix) with ESMTP id D62B91001E69;
	Thu, 20 Jun 2019 02:21:18 +0000 (UTC)
From: Peter Xu <peterx@redhat.com>
To: linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Cc: David Hildenbrand <david@redhat.com>,
	Hugh Dickins <hughd@google.com>,
	Maya Gokhale <gokhale2@llnl.gov>,
	Jerome Glisse <jglisse@redhat.com>,
	Pavel Emelyanov <xemul@virtuozzo.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	peterx@redhat.com,
	Martin Cracauer <cracauer@cons.org>,
	Denis Plotnikov <dplotnikov@virtuozzo.com>,
	Shaohua Li <shli@fb.com>,
	Andrea Arcangeli <aarcange@redhat.com>,
	Mike Kravetz <mike.kravetz@oracle.com>,
	Marty McFadden <mcfadden8@llnl.gov>,
	Mike Rapoport <rppt@linux.vnet.ibm.com>,
	Mel Gorman <mgorman@suse.de>,
	"Kirill A . Shutemov" <kirill@shutemov.name>,
	"Dr . David Alan Gilbert" <dgilbert@redhat.com>
Subject: [PATCH v5 05/25] mm: gup: allow VM_FAULT_RETRY for multiple times
Date: Thu, 20 Jun 2019 10:19:48 +0800
Message-Id: <20190620022008.19172-6-peterx@redhat.com>
In-Reply-To: <20190620022008.19172-1-peterx@redhat.com>
References: <20190620022008.19172-1-peterx@redhat.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.40]); Thu, 20 Jun 2019 02:21:27 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This is the gup counterpart of the change that allows the VM_FAULT_RETRY
to happen for more than once.

Reviewed-by: Jerome Glisse <jglisse@redhat.com>
Signed-off-by: Peter Xu <peterx@redhat.com>
---
 mm/gup.c     | 17 +++++++++++++----
 mm/hugetlb.c |  6 ++++--
 2 files changed, 17 insertions(+), 6 deletions(-)

diff --git a/mm/gup.c b/mm/gup.c
index 58d282115d9b..ac8d5b73c212 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -647,7 +647,10 @@ static int faultin_page(struct task_struct *tsk, struct vm_area_struct *vma,
 	if (*flags & FOLL_NOWAIT)
 		fault_flags |= FAULT_FLAG_ALLOW_RETRY | FAULT_FLAG_RETRY_NOWAIT;
 	if (*flags & FOLL_TRIED) {
-		VM_WARN_ON_ONCE(fault_flags & FAULT_FLAG_ALLOW_RETRY);
+		/*
+		 * Note: FAULT_FLAG_ALLOW_RETRY and FAULT_FLAG_TRIED
+		 * can co-exist
+		 */
 		fault_flags |= FAULT_FLAG_TRIED;
 	}
 
@@ -1062,17 +1065,23 @@ static __always_inline long __get_user_pages_locked(struct task_struct *tsk,
 		if (likely(pages))
 			pages += ret;
 		start += ret << PAGE_SHIFT;
+		lock_dropped = true;
 
+retry:
 		/*
 		 * Repeat on the address that fired VM_FAULT_RETRY
-		 * without FAULT_FLAG_ALLOW_RETRY but with
+		 * with both FAULT_FLAG_ALLOW_RETRY and
 		 * FAULT_FLAG_TRIED.
 		 */
 		*locked = 1;
-		lock_dropped = true;
 		down_read(&mm->mmap_sem);
 		ret = __get_user_pages(tsk, mm, start, 1, flags | FOLL_TRIED,
-				       pages, NULL, NULL);
+				       pages, NULL, locked);
+		if (!*locked) {
+			/* Continue to retry until we succeeded */
+			BUG_ON(ret != 0);
+			goto retry;
+		}
 		if (ret != 1) {
 			BUG_ON(ret > 1);
 			if (!pages_done)
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index ba179c2fa8fb..d9c739f9a28e 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -4317,8 +4317,10 @@ long follow_hugetlb_page(struct mm_struct *mm, struct vm_area_struct *vma,
 				fault_flags |= FAULT_FLAG_ALLOW_RETRY |
 					FAULT_FLAG_RETRY_NOWAIT;
 			if (flags & FOLL_TRIED) {
-				VM_WARN_ON_ONCE(fault_flags &
-						FAULT_FLAG_ALLOW_RETRY);
+				/*
+				 * Note: FAULT_FLAG_ALLOW_RETRY and
+				 * FAULT_FLAG_TRIED can co-exist
+				 */
 				fault_flags |= FAULT_FLAG_TRIED;
 			}
 			ret = hugetlb_fault(mm, vma, vaddr, fault_flags);
-- 
2.21.0

