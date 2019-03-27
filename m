Return-Path: <SRS0=JxSR=R6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5B05CC43381
	for <linux-mm@archiver.kernel.org>; Wed, 27 Mar 2019 18:17:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0E52621741
	for <linux-mm@archiver.kernel.org>; Wed, 27 Mar 2019 18:17:02 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="MUvQZIES"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0E52621741
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 095296B0286; Wed, 27 Mar 2019 14:17:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 01A996B0288; Wed, 27 Mar 2019 14:17:01 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DFDE26B0289; Wed, 27 Mar 2019 14:17:01 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 961806B0286
	for <linux-mm@kvack.org>; Wed, 27 Mar 2019 14:17:01 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id z26so14634879pfa.7
        for <linux-mm@kvack.org>; Wed, 27 Mar 2019 11:17:01 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=jDVBzzK+WLpPQuthFGnYHZWjDVTFJrtG5e/s0YG+j3o=;
        b=dPkZwlVIWMOXKgqLMn1Pswo/c7ntm7p35ZlaQpq2W8UGL7qxUHZOIuMMDqW5FbwFZt
         38YMvWqY9YseSz5KJavv3S8jHejosgxcss60cDDEFgYDybpSlZ35JC6OTFOQxn9Zz4pr
         qOj08WCjfRjbj7201I+4A9jEBz7WlOtd3B5jLhZINklAp8pb8o2OwRhlWSWGJCZDOWxJ
         BrpDsFa82WHc21sY4TVY4pjOkdoMXrRn1mt1p+YlmLeXABmtBpVq4V8LfIlcZqSeiUgf
         +awz3ODAjZj9aLH8L6CjAvXrjGB5uGC30X566pQnWbWP7VdQ65kliUCol9bDDSAnv5kO
         xHjA==
X-Gm-Message-State: APjAAAVEszR6kG3Ku60+nPQ1EDw6yJYQbK5dO5pevpF5dgahrJd423XA
	l+vMJ5eJq6HPV7WpfzV0/xvBV+9bBWkRjKnUlZy++JNL1fTE2sdXNZ+iRDoSE85yazvaR3ulQuj
	QJYsLNNEojU/QZJ+oXhYSeW/76iBZD+i3MUWy0HQ4KBazSErUW7v3h4U97Opz0RRDUg==
X-Received: by 2002:a17:902:6b03:: with SMTP id o3mr38339479plk.126.1553710621252;
        Wed, 27 Mar 2019 11:17:01 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxVzE2ctFJQK1jfb5wl2HPKoOXukexj18sDEK4VHSe/9GLGlyusirDn/KRmK9/02+qGuMp0
X-Received: by 2002:a17:902:6b03:: with SMTP id o3mr38339426plk.126.1553710620543;
        Wed, 27 Mar 2019 11:17:00 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553710620; cv=none;
        d=google.com; s=arc-20160816;
        b=dBUxI6vD6ryV+722fQiyOFjIOF2Oh3xq4f8I3dnAs1COtjn8yVvN9gVa0KVYqzN6i5
         /BbgwvJXeaBJweJW6zPb8600YR1rnNG3anrLhlohc4kSCsYETliU6dRVU6lkii//S0Q6
         +RLQ0h6TN/Sb4JkAhr2zasfgqs94+d9JQ/JT4zGXXltQh7hFksr8OWtiTBZNB5+0e0Jh
         KvEvEeb95yxuI7NTK/415MS1TkvFS88PoNuTUkAMh/1115akeKVF2j5DflQKz5NUEunf
         8rYspqENVnZjOe/FhC/EUDTL4HtH4kSts1uiHKEIg5DpvBbtJx8D6wT9ydIbjOiSMMTk
         aztg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=jDVBzzK+WLpPQuthFGnYHZWjDVTFJrtG5e/s0YG+j3o=;
        b=nIVDt3e4WbOxntHxMlS2mZfkXcD5h57XRCg9telAFjk+ThZbtF4TjLZt/m1LOmVWdl
         UtcnDUEdrtN/v9JwJbN1Db9bPzYPf8y8o/9uwlyg4jdfO3RRvjIDdQtbqbEaUq0Bp87w
         XSe+znzTAxKpKHe9/yB3u+RCazXKDzxux1710/XrsA8gEYFYCEFkQ41I0tf2TRkMKa7T
         Dc+UckB1Pb0sb49pulgD8U3OhXLWQ7eVYDJiIl45WPE2H+IpI08XaCP9AAsnHBbt7hh7
         GUReKqbitcovj7bAtpFW4dG01nC3bgJghRLgQZixxH0/EdtcEeBVW1qTkwXPGTeCdn5h
         n3Qw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=MUvQZIES;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id 129si1118882pfz.159.2019.03.27.11.17.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Mar 2019 11:17:00 -0700 (PDT)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=MUvQZIES;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id A13F92082F;
	Wed, 27 Mar 2019 18:16:58 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1553710620;
	bh=vZlZSwjI0j1qTEE66ehzHcxXT94pw+35NscVhJmlVwM=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=MUvQZIES8fuCF9Xm/nBZwSY3SNN4pqVIhmWtohyvMv+ji+BmA0J1EHKl9bm0ge8V/
	 ckUQb2U0KOxjhNcWueuV2AYceYiMQrkaApNXfTzVPgKrT7xa3VUfsblC1nh8C//a5u
	 YtIWnbUb5ssChU/5piR7grexKJ921bpx53r2QzTo=
From: Sasha Levin <sashal@kernel.org>
To: linux-kernel@vger.kernel.org,
	stable@vger.kernel.org
Cc: Vlastimil Babka <vbabka@suse.cz>,
	Alexander Potapenko <glider@google.com>,
	Dmitry Vyukov <dvyukov@google.com>,
	Andrea Arcangeli <aarcange@redhat.com>,
	"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
	Michal Hocko <mhocko@suse.com>,
	David Rientjes <rientjes@google.com>,
	Yisheng Xie <xieyisheng1@huawei.com>,
	zhong jiang <zhongjiang@huawei.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Sasha Levin <sashal@kernel.org>,
	linux-mm@kvack.org
Subject: [PATCH AUTOSEL 4.14 017/123] mm, mempolicy: fix uninit memory access
Date: Wed, 27 Mar 2019 14:14:41 -0400
Message-Id: <20190327181628.15899-17-sashal@kernel.org>
X-Mailer: git-send-email 2.19.1
In-Reply-To: <20190327181628.15899-1-sashal@kernel.org>
References: <20190327181628.15899-1-sashal@kernel.org>
MIME-Version: 1.0
X-Patchwork-Hint: Ignore
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Vlastimil Babka <vbabka@suse.cz>

[ Upstream commit 2e25644e8da4ed3a27e7b8315aaae74660be72dc ]

Syzbot with KMSAN reports (excerpt):

==================================================================
BUG: KMSAN: uninit-value in mpol_rebind_policy mm/mempolicy.c:353 [inline]
BUG: KMSAN: uninit-value in mpol_rebind_mm+0x249/0x370 mm/mempolicy.c:384
CPU: 1 PID: 17420 Comm: syz-executor4 Not tainted 4.20.0-rc7+ #15
Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS
Google 01/01/2011
Call Trace:
  __dump_stack lib/dump_stack.c:77 [inline]
  dump_stack+0x173/0x1d0 lib/dump_stack.c:113
  kmsan_report+0x12e/0x2a0 mm/kmsan/kmsan.c:613
  __msan_warning+0x82/0xf0 mm/kmsan/kmsan_instr.c:295
  mpol_rebind_policy mm/mempolicy.c:353 [inline]
  mpol_rebind_mm+0x249/0x370 mm/mempolicy.c:384
  update_tasks_nodemask+0x608/0xca0 kernel/cgroup/cpuset.c:1120
  update_nodemasks_hier kernel/cgroup/cpuset.c:1185 [inline]
  update_nodemask kernel/cgroup/cpuset.c:1253 [inline]
  cpuset_write_resmask+0x2a98/0x34b0 kernel/cgroup/cpuset.c:1728

...

Uninit was created at:
  kmsan_save_stack_with_flags mm/kmsan/kmsan.c:204 [inline]
  kmsan_internal_poison_shadow+0x92/0x150 mm/kmsan/kmsan.c:158
  kmsan_kmalloc+0xa6/0x130 mm/kmsan/kmsan_hooks.c:176
  kmem_cache_alloc+0x572/0xb90 mm/slub.c:2777
  mpol_new mm/mempolicy.c:276 [inline]
  do_mbind mm/mempolicy.c:1180 [inline]
  kernel_mbind+0x8a7/0x31a0 mm/mempolicy.c:1347
  __do_sys_mbind mm/mempolicy.c:1354 [inline]

As it's difficult to report where exactly the uninit value resides in
the mempolicy object, we have to guess a bit.  mm/mempolicy.c:353
contains this part of mpol_rebind_policy():

        if (!mpol_store_user_nodemask(pol) &&
            nodes_equal(pol->w.cpuset_mems_allowed, *newmask))

"mpol_store_user_nodemask(pol)" is testing pol->flags, which I couldn't
ever see being uninitialized after leaving mpol_new().  So I'll guess
it's actually about accessing pol->w.cpuset_mems_allowed on line 354,
but still part of statement starting on line 353.

For w.cpuset_mems_allowed to be not initialized, and the nodes_equal()
reachable for a mempolicy where mpol_set_nodemask() is called in
do_mbind(), it seems the only possibility is a MPOL_PREFERRED policy
with empty set of nodes, i.e.  MPOL_LOCAL equivalent, with MPOL_F_LOCAL
flag.  Let's exclude such policies from the nodes_equal() check.  Note
the uninit access should be benign anyway, as rebinding this kind of
policy is always a no-op.  Therefore no actual need for stable
inclusion.

Link: http://lkml.kernel.org/r/a71997c3-e8ae-a787-d5ce-3db05768b27c@suse.cz
Link: http://lkml.kernel.org/r/73da3e9c-cc84-509e-17d9-0c434bb9967d@suse.cz
Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
Reported-by: syzbot+b19c2dc2c990ea657a71@syzkaller.appspotmail.com
Cc: Alexander Potapenko <glider@google.com>
Cc: Dmitry Vyukov <dvyukov@google.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Michal Hocko <mhocko@suse.com>
Cc: David Rientjes <rientjes@google.com>
Cc: Yisheng Xie <xieyisheng1@huawei.com>
Cc: zhong jiang <zhongjiang@huawei.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
Signed-off-by: Sasha Levin <sashal@kernel.org>
---
 mm/mempolicy.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 1331645a3794..b0e99ea0c3db 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -349,7 +349,7 @@ static void mpol_rebind_policy(struct mempolicy *pol, const nodemask_t *newmask)
 {
 	if (!pol)
 		return;
-	if (!mpol_store_user_nodemask(pol) &&
+	if (!mpol_store_user_nodemask(pol) && !(pol->flags & MPOL_F_LOCAL) &&
 	    nodes_equal(pol->w.cpuset_mems_allowed, *newmask))
 		return;
 
-- 
2.19.1

