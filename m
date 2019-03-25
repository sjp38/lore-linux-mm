Return-Path: <SRS0=RIH8=R4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 218CEC43381
	for <linux-mm@archiver.kernel.org>; Mon, 25 Mar 2019 22:56:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D6F4620830
	for <linux-mm@archiver.kernel.org>; Mon, 25 Mar 2019 22:56:41 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D6F4620830
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 65CF16B000D; Mon, 25 Mar 2019 18:56:41 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5E5096B000E; Mon, 25 Mar 2019 18:56:41 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4AEC06B0010; Mon, 25 Mar 2019 18:56:41 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 229446B000D
	for <linux-mm@kvack.org>; Mon, 25 Mar 2019 18:56:41 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id g48so11813172qtk.19
        for <linux-mm@kvack.org>; Mon, 25 Mar 2019 15:56:41 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=sWaHJcUV7ws1d0/n1vJBfYGdp8DvVP7zvuodDGSa9lg=;
        b=sZKpDamX44VxmXgNb+Nzx++ZFtC1xlzECJ1c9dUrFG4Ix/yRlcYb3umw6O/uDaZrJD
         VmOva/Op8M6lcT69TjDChM/TUrATtW4AtFY92lRAGlYdUriJCG36L31RRXaVkErS2xOm
         lzt91pXiPZrCLQ6+x9adiA1XTnl7Cde0eGPVXh+Jh0olZlciZLKPX0fUCjwQdXlLUP5L
         0n5MTSPMUf6Lc08gc23AJhnFWRlaHopqUmZtMsOtpBZwCvWAg/ZLV0A2bQmy/EokHzsG
         kEmHSIHF9mxSv56Aw3elpC5BBM+ySQLcuuTc5a9rBbf2TjYto68w+H6BPqYJjpCDIsnl
         Vkcg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of aarcange@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=aarcange@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWXbS1/H/ZZ+ub/Z44WAO4gE1qZmn/XY05DHGj3JeShH/dMB/gn
	XnEoU0xbTZ9bs8wjwkHLQVXIST7aXAT/yLgO4lEI31wq51oLv3zWYzjPAKtzrR0W4hvTXFymkNi
	a45NpdZ6L7mWgV7dtFvlb6dp6DMqjs+GsdTMLcxTXMlobbXm6fhJnL4M1XuhMTpzXAw==
X-Received: by 2002:ac8:544c:: with SMTP id d12mr22140494qtq.199.1553554600909;
        Mon, 25 Mar 2019 15:56:40 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzCvu5qAqpfGFMZ1oXLfENiPw6ehW0FprVuI4Hl9tNMA+vU/8JlqB/mbQk1O2b4YtNQOxex
X-Received: by 2002:ac8:544c:: with SMTP id d12mr22140473qtq.199.1553554600297;
        Mon, 25 Mar 2019 15:56:40 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553554600; cv=none;
        d=google.com; s=arc-20160816;
        b=UgsQ6c4hcnj+COg5tqghxCLeHJPJBf9M/LrY5L5xtCxe2ukjLQoWNqg9qQWC4OSInZ
         1tkmAUJ3ihSS3i74ca76niYpEjyTHR1qdvPwsPh1gZhyklSOti3pcREAzHfkO3xZAcWK
         CvPtdFM5CnrLXqhoq+p6Vo+onU3JLRc6kwVmvEPIguJ0OgXwbXs3KNc0pyCGg8Q/JkUp
         sguOF737nl2Pc2V++JUoahaWmxgwzBrZpxrRXSZIOFi+pEEoWSiftMKxKrRgZ4Zvsgxb
         fnOqpePQiapyShj63DNqImCnFJ80MJpp+HqXn0FmqptWWE8navu0sSkJPvZeAp/bmSOQ
         Ed8g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=sWaHJcUV7ws1d0/n1vJBfYGdp8DvVP7zvuodDGSa9lg=;
        b=Ne6N3oEihTwjlPP8NkJMm4Fp6H4yAVey1Z+EK4aY73oaAofO+j4g/LNHdh/QyNJFas
         D8kkoY1iPPa8W+ztqelxySxSlNZQhGiYOAT/lFCDDxjc61TQwkHziEcxVUVsSTGJt1/H
         1Rk2tQ8QMT+BOOBfyYj97phn7I1dIV8YJVLkYwlxLJc284ViO0USh4SuHz1EOmvdDDEn
         ZAIk8h5S81yMwcCFmunt8jorlFd5UWTyJiuhfHimbKEbusrdIsFZ0EBEHomUH3M6qvs9
         J3YBY9y+TwcQF2qf6o5pmQlDNSiLKMQNcYOGdJPAvZ+KslD2e1RZtplQO+qsYHHtVk32
         +Klg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of aarcange@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=aarcange@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id x5si147026qvc.136.2019.03.25.15.56.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Mar 2019 15:56:40 -0700 (PDT)
Received-SPF: pass (google.com: domain of aarcange@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of aarcange@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=aarcange@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 788ED3086262;
	Mon, 25 Mar 2019 22:56:39 +0000 (UTC)
Received: from sky.random (ovpn-120-118.rdu2.redhat.com [10.10.120.118])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id F1E2E642B5;
	Mon, 25 Mar 2019 22:56:36 +0000 (UTC)
From: Andrea Arcangeli <aarcange@redhat.com>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org,
	zhong jiang <zhongjiang@huawei.com>,
	syzkaller-bugs@googlegroups.com,
	syzbot+cbb52e396df3e565ab02@syzkaller.appspotmail.com,
	Mike Rapoport <rppt@linux.vnet.ibm.com>,
	Mike Kravetz <mike.kravetz@oracle.com>,
	Peter Xu <peterx@redhat.com>,
	Dmitry Vyukov <dvyukov@google.com>
Subject: [PATCH 2/2] mm: change mm_update_next_owner() to update mm->owner with WRITE_ONCE
Date: Mon, 25 Mar 2019 18:56:36 -0400
Message-Id: <20190325225636.11635-3-aarcange@redhat.com>
In-Reply-To: <20190325225636.11635-1-aarcange@redhat.com>
References: <20190325225636.11635-1-aarcange@redhat.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.49]); Mon, 25 Mar 2019 22:56:39 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The RCU reader uses rcu_dereference() inside rcu_read_lock critical
sections, so the writer shall use WRITE_ONCE. Just a cleanup, we still
rely on gcc to emit atomic writes in other places.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 kernel/exit.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/kernel/exit.c b/kernel/exit.c
index 2166c2d92ddc..8361a560cd1d 100644
--- a/kernel/exit.c
+++ b/kernel/exit.c
@@ -422,7 +422,7 @@ void mm_update_next_owner(struct mm_struct *mm)
 	 * freed task structure.
 	 */
 	if (atomic_read(&mm->mm_users) <= 1) {
-		mm->owner = NULL;
+		WRITE_ONCE(mm->owner, NULL);
 		return;
 	}
 
@@ -462,7 +462,7 @@ void mm_update_next_owner(struct mm_struct *mm)
 	 * most likely racing with swapoff (try_to_unuse()) or /proc or
 	 * ptrace or page migration (get_task_mm()).  Mark owner as NULL.
 	 */
-	mm->owner = NULL;
+	WRITE_ONCE(mm->owner, NULL);
 	return;
 
 assign_new_owner:
@@ -483,7 +483,7 @@ void mm_update_next_owner(struct mm_struct *mm)
 		put_task_struct(c);
 		goto retry;
 	}
-	mm->owner = c;
+	WRITE_ONCE(mm->owner, c);
 	task_unlock(c);
 	put_task_struct(c);
 }

