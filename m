Return-Path: <SRS0=rceO=VX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-10.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C899AC76191
	for <linux-mm@archiver.kernel.org>; Fri, 26 Jul 2019 13:40:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7989522CBD
	for <linux-mm@archiver.kernel.org>; Fri, 26 Jul 2019 13:40:58 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="lqezt7JD"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7989522CBD
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 25DDA6B0006; Fri, 26 Jul 2019 09:40:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1E8E66B0007; Fri, 26 Jul 2019 09:40:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 03A478E0002; Fri, 26 Jul 2019 09:40:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id BE6466B0006
	for <linux-mm@kvack.org>; Fri, 26 Jul 2019 09:40:57 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id 145so33221725pfw.16
        for <linux-mm@kvack.org>; Fri, 26 Jul 2019 06:40:57 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=Ix5e2DioheSQpoO393kqQXTdDUwQudCqdaTtqRAjyxY=;
        b=ENnd7Nu39bKTXyM+nli5San5zUpKvNis/3D1gtX90wAIBmm0dloP19VhaHp4qajBYO
         UaASr5CkPRkIkfqRCPnxYzn8JxvpOpZNr9HkSdXZLpsfSYETBNmrvGKmJsC8/kftQhg4
         7WrHKfNIjcHmumoazXkn8B/X9jzcsiZI1G7nW5smvk/DQTMbN/oW43tiqkTJ6lARFsj3
         qmnj7UrF6iUjjbg1+mqRoS4xxPtrya4mGMshIduAOzmbpoULJQTqbp0WrR41IOzWzmaK
         4/wFgBBU7dpQdvevl4hBFviaxkA2pJS7ulsspWlxqW0m1hej1U+PC7yXWA1Z0tiMW7zW
         N8gA==
X-Gm-Message-State: APjAAAVSp40BSDJQt5dQ9nJuVfSqQtknN1EQ4CxcsqY9rhSwzWrQDA18
	mixdk/kfs3e21mXMVJVSKqRTwlapOHi+v+NUMctPPr/5iNAbBJayAzbEliSuAXDRWYsmbA5CxCK
	wzeQEnDumHt/2JWIFjsT6h/zHNA+GerDnlMIEzyqhNPk0NuEHQAr0n//6LSfTPdgj7Q==
X-Received: by 2002:a17:902:f301:: with SMTP id gb1mr94802517plb.292.1564148457411;
        Fri, 26 Jul 2019 06:40:57 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzwoo7RFnPhcprHYn9F0pO8eqMLdcEJY2U0Nn82Bogcd3cCq+/PtUr+W7NF2TbZu5BiXdde
X-Received: by 2002:a17:902:f301:: with SMTP id gb1mr94802464plb.292.1564148456645;
        Fri, 26 Jul 2019 06:40:56 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564148456; cv=none;
        d=google.com; s=arc-20160816;
        b=i2IIHYeJx3i+jyrpGo6QLGqUQpN/mFtTlH8AQdpLpberRICma8r2kwwgUYCtoo63PV
         OIMIpD5lT157aEIkm4TaJKCryfZk6ypQnq7PEe5bXiG7/0k7EJoFhowC/xETHUwdTzWE
         r5oiU8BU7+8sli/LbhLUZ3GNlZfVONRZ8FlxN1y5006LYCK9X09Pi3WdLH3YQzlb97jq
         B14JXboEPb4ZEwUkZLe+1VovrMaTEwiozo+2CgF/jcwBgfVJUOXx7oTgcFfInmI7G3uy
         Mq7m08EyzTZ0Zlyk16rNvaSTNYVycndKUvvqRQoCFkQNNTsv5oVOLCLapDQsvdkGhp2K
         H+vg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=Ix5e2DioheSQpoO393kqQXTdDUwQudCqdaTtqRAjyxY=;
        b=D2BXCuOSFIsDpWc6VH/gBQyz9wQKzv0MF5qlYFwbdHqyNvM6+yCPEWW2otZee/R3O+
         i0NP2ixayZVk42fn1Z5nob5QUk7shYpDV3siTUQq5sW2ASXVzvDM1Vwu1wGEIPt77kD7
         wAyjSV9yCL/eKrI6QfCawgddsiNneOlic54DptYOkdT7EW31Zo2Ocw0WN48xOUdXfSpk
         piL/HWw82gBqvPsMNvSE8+/5jEb3XyYA68h65xnXEh7tqpoc6WBJZaqENvPDkBZogr+6
         2U2/NKJirPcJRDbmPP1HIEyN8cVPFriEvV8eZC2LNOgmdR5UQOmP7CUYx7M14ahtAPWc
         rmJw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=lqezt7JD;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id v4si11150612pgf.470.2019.07.26.06.40.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 26 Jul 2019 06:40:56 -0700 (PDT)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=lqezt7JD;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 4B7FD22BEF;
	Fri, 26 Jul 2019 13:40:55 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1564148456;
	bh=g1Vj/B5j1Trd98aOkbS5Nj7l1bSCMsfMsN7CB+41oAM=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=lqezt7JD5xlUxv5ZdFAEqftwm2Xj9qPUU8uknark3BJZrXlNfqpij8FIUVXLtHCgl
	 i6fB83xeW0fGK1hh2w474IYegZ2zhsbpYWvGHYmZnw7ch4EtKpf1VZvJqbmrFHnE2w
	 Rad7YjDkI6cWATzNdQj/mXBGsPZL5aoUjM1xFC9o=
From: Sasha Levin <sashal@kernel.org>
To: linux-kernel@vger.kernel.org,
	stable@vger.kernel.org
Cc: Vitaly Wool <vitalywool@gmail.com>,
	Henry Burns <henryburns@google.com>,
	Shakeel Butt <shakeelb@google.com>,
	Jonathan Adams <jwadams@google.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Sasha Levin <sashal@kernel.org>,
	linux-mm@kvack.org
Subject: [PATCH AUTOSEL 5.2 50/85] mm/z3fold: don't try to use buddy slots after free
Date: Fri, 26 Jul 2019 09:39:00 -0400
Message-Id: <20190726133936.11177-50-sashal@kernel.org>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190726133936.11177-1-sashal@kernel.org>
References: <20190726133936.11177-1-sashal@kernel.org>
MIME-Version: 1.0
X-stable: review
X-Patchwork-Hint: Ignore
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Vitaly Wool <vitalywool@gmail.com>

[ Upstream commit bb9a374dfa3a2f46581455ab66cd1d24c5e3d183 ]

As reported by Henry Burns:

Running z3fold stress testing with address sanitization showed zhdr->slots
was being used after it was freed.

  z3fold_free(z3fold_pool, handle)
    free_handle(handle)
      kmem_cache_free(pool->c_handle, zhdr->slots)
    release_z3fold_page_locked_list(kref)
      __release_z3fold_page(zhdr, true)
        zhdr_to_pool(zhdr)
          slots_to_pool(zhdr->slots)  *BOOM*

To fix this, add pointer to the pool back to z3fold_header and modify
zhdr_to_pool to return zhdr->pool.

Link: http://lkml.kernel.org/r/20190708134808.e89f3bfadd9f6ffd7eff9ba9@gmail.com
Fixes: 7c2b8baa61fe  ("mm/z3fold.c: add structure for buddy handles")
Signed-off-by: Vitaly Wool <vitalywool@gmail.com>
Reported-by: Henry Burns <henryburns@google.com>
Reviewed-by: Shakeel Butt <shakeelb@google.com>
Cc: Jonathan Adams <jwadams@google.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
Signed-off-by: Sasha Levin <sashal@kernel.org>
---
 mm/z3fold.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/mm/z3fold.c b/mm/z3fold.c
index 985732c8b025..e1686bf6d689 100644
--- a/mm/z3fold.c
+++ b/mm/z3fold.c
@@ -101,6 +101,7 @@ struct z3fold_buddy_slots {
  * @refcount:		reference count for the z3fold page
  * @work:		work_struct for page layout optimization
  * @slots:		pointer to the structure holding buddy slots
+ * @pool:		pointer to the containing pool
  * @cpu:		CPU which this page "belongs" to
  * @first_chunks:	the size of the first buddy in chunks, 0 if free
  * @middle_chunks:	the size of the middle buddy in chunks, 0 if free
@@ -114,6 +115,7 @@ struct z3fold_header {
 	struct kref refcount;
 	struct work_struct work;
 	struct z3fold_buddy_slots *slots;
+	struct z3fold_pool *pool;
 	short cpu;
 	unsigned short first_chunks;
 	unsigned short middle_chunks;
@@ -320,6 +322,7 @@ static struct z3fold_header *init_z3fold_page(struct page *page,
 	zhdr->start_middle = 0;
 	zhdr->cpu = -1;
 	zhdr->slots = slots;
+	zhdr->pool = pool;
 	INIT_LIST_HEAD(&zhdr->buddy);
 	INIT_WORK(&zhdr->work, compact_page_work);
 	return zhdr;
@@ -426,7 +429,7 @@ static enum buddy handle_to_buddy(unsigned long handle)
 
 static inline struct z3fold_pool *zhdr_to_pool(struct z3fold_header *zhdr)
 {
-	return slots_to_pool(zhdr->slots);
+	return zhdr->pool;
 }
 
 static void __release_z3fold_page(struct z3fold_header *zhdr, bool locked)
-- 
2.20.1

