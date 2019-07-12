Return-Path: <SRS0=GtRI=VJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 33408C742B3
	for <linux-mm@archiver.kernel.org>; Fri, 12 Jul 2019 12:02:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F006F2083B
	for <linux-mm@archiver.kernel.org>; Fri, 12 Jul 2019 12:02:35 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="mZ6PnB60"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F006F2083B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6C94F8E013F; Fri, 12 Jul 2019 08:02:35 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 679688E00DB; Fri, 12 Jul 2019 08:02:35 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 58EC18E013F; Fri, 12 Jul 2019 08:02:35 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 222548E00DB
	for <linux-mm@kvack.org>; Fri, 12 Jul 2019 08:02:35 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id r7so5088120plo.6
        for <linux-mm@kvack.org>; Fri, 12 Jul 2019 05:02:35 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:mime-version:content-transfer-encoding;
        bh=38IvB5KypHDAuaY3YawsJEBcvuco56ouTYCrEb+HEU0=;
        b=AJv/oDozkmS5l5N92O8VG3XJPsucejFJfAAXjprxnSiVTI6VhOaTMSqZWJSzNgVSQf
         TAYH1B/84oKHWBRw/cF0MNITQAGfI4lOomCBJMexk3aJgYArvoHmPED5aG+kUqfFlH9Z
         assIQpukYdeisHMNVHS12ba/GcU+C+uF5oxDCA2kwnWxDgkmjkN3YjKNO/FevB5B4Xx5
         i2xAyiQVoi4iyJJem8h6tsAoE2E49cAgmLXNe/rmXbQ23WyeeBMGIEGQQrX+QizXU0/1
         FmMq0NjJ8sfabRBXwetgTGqdpH1y6bfJpf73rVSJKm/q6VW9Oq/TxelEBE86lBlHuYbv
         gshQ==
X-Gm-Message-State: APjAAAWTQeDOoI647gmmrxicbsAWwi7Tpj/q5XxAVkK/LMh7Kp9z6KPP
	C4p5e9UaPCMERb/K/2Dg3kKW+KdzGLsuVIcT7EsHFjjCt/y+b6ZtrKnjU5SAuLPtORwLZGnE/6P
	WnayhkT5SdUmhtqpqvemP9vYK/oznmKRN0ViEzlrSpDDujq4wP+MzHadoyCLbu2yoGg==
X-Received: by 2002:a17:902:be12:: with SMTP id r18mr10496905pls.341.1562932954739;
        Fri, 12 Jul 2019 05:02:34 -0700 (PDT)
X-Received: by 2002:a17:902:be12:: with SMTP id r18mr10496825pls.341.1562932953948;
        Fri, 12 Jul 2019 05:02:33 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562932953; cv=none;
        d=google.com; s=arc-20160816;
        b=taUS2o6F8I4bgbIcGmE74QlGL3SjuzDC0h91kwITL+pJ88jMElKdu+8Kq4EiVxx8gT
         C/qInJWXCHA2DsUswQxKmICY2Ul6Pw5MoaVhSIm4OmEIKK+aFjfbymNW1ECG7UxKnEIX
         MFtDeYxh9T5trHzv8vChzv7FqQbJulmFLReoVgn1LWrQ9PJS41i3UkNR87sNPjlD1nZs
         OrauINucYpLnSvRB4WyI3RLXVJtBPdWnWhoZKa+OG5HLrMkD06hzKmDhgIG/lVmKFvzG
         oCyZsTVG6dYpeAPls7abuMGmMYVr/Pg2BBt0e/8bs3V02Df6DnR85afNnXC8w9xaDHgh
         Ja7g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:dkim-signature;
        bh=38IvB5KypHDAuaY3YawsJEBcvuco56ouTYCrEb+HEU0=;
        b=AsXgVSvG3NeZiqy2QYOO6/AOHGc1XYOKyIqnkOYvPBbRB86ImXduV7ttwJCBnS3niu
         LWVFj/fFs/hMqVEPjl1v7np6WobZAJYqKeKsyxtvfGoPLogt2KK1Q3kay+uqelPHfp5b
         5K0JigUr9n9Tx5GviYVQZdUu7p2EimUeB6rAi9rBcilM/BCSBM1hx/2XeeVyszdZuVRr
         XlBl9W9KPhGP+j8fqnw7r4H1W4SoACqg5bhRy5Z/gRkiM0iKnD37pjCAG9aTeLXcaAc+
         RkFSslmjAkit2hCVruhjZXnuAXpGHFx0bX3n5gtBtj1NVE0aug+Pz+kJt/1z/HvTOgEl
         GDIQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=mZ6PnB60;
       spf=pass (google.com: domain of lpf.vector@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=lpf.vector@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id cu6sor10602795pjb.22.2019.07.12.05.02.33
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 12 Jul 2019 05:02:33 -0700 (PDT)
Received-SPF: pass (google.com: domain of lpf.vector@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=mZ6PnB60;
       spf=pass (google.com: domain of lpf.vector@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=lpf.vector@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=38IvB5KypHDAuaY3YawsJEBcvuco56ouTYCrEb+HEU0=;
        b=mZ6PnB60as+zd8jQQHihMl6Lq71efQ8gvN2pJtswPVRzB6N/hPqe6FewYIYcF/Tx54
         w3JV1LABmcpp/rKonz9KdKdLcVK/rG5Krf9Jt5ttzc1nQ3ljvY7PDTPlei0Bgi33WA11
         Aa7nCUZQTwoJEhqgXjWw2kDIJVJThfZveZw836caUJMdNr9YV0WVg4j1y1RSyUfFslqS
         qPc286RqXst+zYYpOLQQYE4vBzfeELhFv5O+twhKjyouGtlc3pJexk2o6BXD1itXeGw1
         9tWIRGS5A6A6UtO2ZxTXX4YuzCvw86x9n52+47vXBUJKham10y5GFtrjCzq257QjiP1Z
         cJvQ==
X-Google-Smtp-Source: APXvYqyoi0Y6qlEL1iMKqyin6FJjShBWPRtQHr7DHceYStTR3VArKTv7hCnMQqSJv7vqsXDyyqTB9g==
X-Received: by 2002:a17:90a:b394:: with SMTP id e20mr11269156pjr.76.1562932953693;
        Fri, 12 Jul 2019 05:02:33 -0700 (PDT)
Received: from localhost.localdomain.localdomain ([2408:823c:c11:478:b8c3:8577:bf2f:2])
        by smtp.gmail.com with ESMTPSA id a128sm4605496pfb.185.2019.07.12.05.02.26
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Fri, 12 Jul 2019 05:02:33 -0700 (PDT)
From: Pengfei Li <lpf.vector@gmail.com>
To: akpm@linux-foundation.org
Cc: urezki@gmail.com,
	rpenyaev@suse.de,
	peterz@infradead.org,
	guro@fb.com,
	rick.p.edgecombe@intel.com,
	rppt@linux.ibm.com,
	aryabinin@virtuozzo.com,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	Pengfei Li <lpf.vector@gmail.com>
Subject: [PATCH v4 0/2] mm/vmalloc.c: improve readability and rewrite vmap_area
Date: Fri, 12 Jul 2019 20:02:11 +0800
Message-Id: <20190712120213.2825-1-lpf.vector@gmail.com>
X-Mailer: git-send-email 2.21.0
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

v3 -> v4:
* Base on next-20190711
* patch 1: From: Uladzislau Rezki (Sony) <urezki@gmail.com> (author)
  - https://lkml.org/lkml/2019/7/3/661
* patch 2: Modify the layout of struct vmap_area for readability

v2 -> v3:
* patch 1-4: Abandoned
* patch 5:
  - Eliminate "flags" (suggested by Uladzislau Rezki)
  - Base on https://lkml.org/lkml/2019/6/6/455
    and https://lkml.org/lkml/2019/7/3/661

v1 -> v2:
* patch 3: Rename __find_vmap_area to __search_va_in_busy_tree
           instead of __search_va_from_busy_tree.
* patch 5: Add motivation and necessary test data to the commit
           message.
* patch 5: Let va->flags use only some low bits of va_start
           instead of completely overwriting va_start.

The current implementation of struct vmap_area wasted space.

After applying this commit, sizeof(struct vmap_area) has been
reduced from 11 words to 8 words.

Pengfei Li (1):
  mm/vmalloc.c: Modify struct vmap_area to reduce its size

Uladzislau Rezki (Sony) (1):
  mm/vmalloc: do not keep unpurged areas in the busy tree

 include/linux/vmalloc.h | 40 ++++++++++++++++-----
 mm/vmalloc.c            | 79 ++++++++++++++++++++++++++++-------------
 2 files changed, 86 insertions(+), 33 deletions(-)

-- 
2.21.0

