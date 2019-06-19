Return-Path: <SRS0=1eqM=US=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E6927C31E5B
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 01:14:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B53DC2085A
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 01:14:56 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B53DC2085A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 48B0F6B0006; Tue, 18 Jun 2019 21:14:56 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 43C578E0002; Tue, 18 Jun 2019 21:14:56 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 351948E0001; Tue, 18 Jun 2019 21:14:56 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 179F16B0006
	for <linux-mm@kvack.org>; Tue, 18 Jun 2019 21:14:56 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id n77so13946514qke.17
        for <linux-mm@kvack.org>; Tue, 18 Jun 2019 18:14:56 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version:content-transfer-encoding;
        bh=HIRguDm73ocVtpzL7Hrycn9m6zEH/WxBya6yURKQFLY=;
        b=pjI+rYqvs050/TGEblCBynOjdO7bqrtBdoTPBHz3mvyUMG7InAVNeNO/85di34pwQu
         9ldIuzxJTW9E0jk9DJ4dhucrU+NFJj9itA7LO7jOzZ6mT7S5qsxyGyK+mcSh2YZBjvxr
         fkxhYcsfHmqnda6Fhn6/1Y4ejzJgCz/ZyjM0YBMCFCjVKHrQbBfQ0V1Qv74OdWTQs1bf
         +vkOq+t7B07sZzPHYssDjpDOlp0DRq5v4BjqVOz1MwoMYZxrjxPUEeMMws2dy/XQDBZq
         lGpk5UhUKYEx76qwGw1DmR/uJK4U/oWWIqXtBP76NAKedYyL1ekZo8b9iJbTas6kXQZq
         hKOg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of aarcange@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=aarcange@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWUaPm+4+bDyIWKHGauupt7iGfiC/J7MoPX27PPnzQ+ua491Cmk
	cqa8l67Iu+IdGmQIC/g2AEHh/UOUxNF4cjQMU7DgPRkKdFHVm0WRfdDdyB2il76RfkMLcaiXwtL
	sqgVdzapYsovW3j59WGm2eShMsAuUU4x+7ZkkInXCWBvF5J4LBmehG92ZbXnvNNs0vw==
X-Received: by 2002:ac8:2cd1:: with SMTP id 17mr100466930qtx.356.1560906895786;
        Tue, 18 Jun 2019 18:14:55 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwLKfNX2JkcsemmAG16SuJmVm78wYgEEV3A02dTg87u0u3vpvHNK3RPZdxIXnQJJLd4GpNV
X-Received: by 2002:ac8:2cd1:: with SMTP id 17mr100466890qtx.356.1560906895148;
        Tue, 18 Jun 2019 18:14:55 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560906895; cv=none;
        d=google.com; s=arc-20160816;
        b=QDptkUfUgXSUNgg3lCDVocIvJ41da/YMZidOWHLzzxZaAt2oUIYfZ4pxYYEjugY4+O
         wXP1YGr67dLyEOGuvj3Em0RDqHBeQElST7ZqlGu2eQ/vG9gvFvG+SpIFUJSv9kK3VUjZ
         T16UUq04kR/psrAkj59yPhr9TsWpTW6pl09NntbQdVR65xngZcaOL/RMOUPhVXuLfB6i
         YbqGH6R1NQ/c9Ny7Z5eGECmrOl+CpQ2MNwxXXwYAvwXhEaqxMRwI0GQwLYa3db/wq8ZQ
         Xf0lT2iREFH0HoNnT3I4t1Xqblj/qfaqmis7DWyvYryTV8XGTxpON+3qBJjLogZWguWO
         2fHQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from;
        bh=HIRguDm73ocVtpzL7Hrycn9m6zEH/WxBya6yURKQFLY=;
        b=gXgFN38nff/JNDoGXEng6iyIqLewoj7J2cbNpJr2H8RhyGx0bN0zgKecdp2mNPzkCB
         ZnAwhmv3JsdzyBcd+QPxPUaoXDaUZknE7HKz9myIIJyeaO13RBe1qDjRNPtpmf7xarw8
         BZcqAPsRX674STpen2bSv56fVfyg1gdXR8nQiy7OmFopWmix19B0QmL3gvVcJmd3p/Ge
         hcJLvS8mTl9ZiWqIT3NDLvgjGZABaZOKIy2ykaZ1jytYr1ixs8TfWit2QCCONjZWpV9c
         TusVA3ar9Ez8lSAhy2xQxZpo2pLljdG+wPce9fe8mW5g1/S9YMTgw/OonQQzvjrRjfke
         INcg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of aarcange@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=aarcange@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id n13si1569977qtn.125.2019.06.18.18.14.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 18 Jun 2019 18:14:55 -0700 (PDT)
Received-SPF: pass (google.com: domain of aarcange@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of aarcange@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=aarcange@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.14])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 286FAA70E;
	Wed, 19 Jun 2019 01:14:52 +0000 (UTC)
Received: from ultra.random (ovpn-122-17.rdu2.redhat.com [10.10.122.17])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 22EE636FA;
	Wed, 19 Jun 2019 01:14:51 +0000 (UTC)
From: Andrea Arcangeli <aarcange@redhat.com>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org,
	Rik van Riel <riel@surriel.com>,
	Roman Gushchin <guro@fb.com>,
	Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 1/1] fork,memcg: alloc_thread_stack_node needs to set tsk->stack
Date: Tue, 18 Jun 2019 21:14:50 -0400
Message-Id: <20190619011450.28048-1-aarcange@redhat.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.14
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.29]); Wed, 19 Jun 2019 01:14:52 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Commit 5eed6f1dff87bfb5e545935def3843edf42800f2 corrected two
instances, but there was a third instance of this bug.

Without setting tsk->stack, if memcg_charge_kernel_stack fails, it'll
execute free_thread_stack() on a dangling pointer.

Enterprise kernels are compiled with VMAP_STACK=y so this isn't
critical, but custom VMAP_STACK=n builds should have some performance
advantage, with the drawback of risking to fail fork because
compaction didn't succeed. So as long as VMAP_STACK=n is a supported
option it's worth fixing it upstream.

Fixes: 9b6f7e163cd0 ("mm: rework memcg kernel stack accounting")
Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 kernel/fork.c | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/kernel/fork.c b/kernel/fork.c
index d6c324b1b29e..9ee28dfe7c21 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -248,7 +248,11 @@ static unsigned long *alloc_thread_stack_node(struct task_struct *tsk, int node)
 	struct page *page = alloc_pages_node(node, THREADINFO_GFP,
 					     THREAD_SIZE_ORDER);
 
-	return page ? page_address(page) : NULL;
+	if (likely(page)) {
+		tsk->stack = page_address(page);
+		return tsk->stack;
+	}
+	return NULL;
 #endif
 }
 

