Return-Path: <SRS0=rp0W=VN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-17.4 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT,
	USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D6A0FC76191
	for <linux-mm@archiver.kernel.org>; Tue, 16 Jul 2019 00:05:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 95A2E20880
	for <linux-mm@archiver.kernel.org>; Tue, 16 Jul 2019 00:05:27 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="r/N2p4ZH"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 95A2E20880
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 262AC6B0005; Mon, 15 Jul 2019 20:05:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 213C56B0006; Mon, 15 Jul 2019 20:05:27 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 102696B0007; Mon, 15 Jul 2019 20:05:27 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vk1-f200.google.com (mail-vk1-f200.google.com [209.85.221.200])
	by kanga.kvack.org (Postfix) with ESMTP id DE6FB6B0005
	for <linux-mm@kvack.org>; Mon, 15 Jul 2019 20:05:26 -0400 (EDT)
Received: by mail-vk1-f200.google.com with SMTP id n185so9151744vkf.14
        for <linux-mm@kvack.org>; Mon, 15 Jul 2019 17:05:26 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:message-id:mime-version
         :subject:from:to:cc;
        bh=bM16Cxlynj/iYFnBhEVrgD674cLfvqLU43B4Z5mZd8I=;
        b=BS2al84mZOrWFzW1q8pz+a8NeJHQ/RvfH/bH+EljLVG7tGWfJ6njV/M9ndATAD3Exw
         ZDf32enPKZl6gXtyQWmcqf9y8Zk9I8lDVXEaMfpCFljurRpKruQ1R2u8zjVgRmi2Xneu
         jI6RAtMMFOf6UbVYbHuoaLpYm17/P1xgFrDIRBonk/Z/TeWL6yeadxIZaAE7E2tvvVf0
         coIqHjupU1D8x98Ht9ZVKwGqKIQ738BaXAnPKH1U4llSPYqLKpcES9EAb/uQ5MVsj5u3
         optZoncMqUwDSnUKPp10I/HLSBbF/vjnhoVOF4TlCmX7wBymJ9k2jJtEA/6ViKt+7Ahp
         Qztg==
X-Gm-Message-State: APjAAAVzuTkn6EcW7mquaYgy/3V9ouINNMYeZkQBaJ20e5n2RavOhj79
	BMkEltGi3g862qj2A1KkhETAIJAUcTqeigKfWDXpTaMU9ux4BJ5SqAt6qJlnCrr0VPAkOsN/a6b
	fPDbt14EAjVmo2xOqGJYH5EBZrmeIJqj7MYa/em8yoKzQSGyVvQSIV+MPZGdCAKsL+Q==
X-Received: by 2002:a67:8d8a:: with SMTP id p132mr17641851vsd.103.1563235526542;
        Mon, 15 Jul 2019 17:05:26 -0700 (PDT)
X-Received: by 2002:a67:8d8a:: with SMTP id p132mr17641818vsd.103.1563235525747;
        Mon, 15 Jul 2019 17:05:25 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563235525; cv=none;
        d=google.com; s=arc-20160816;
        b=JFm8BGxXKHRj/eDm3HKAjNvIGR5YUrHUDgX69CXaIXeBwSYtkTNgNKQStDFDvVYHfO
         2oipxLGj7BXZcuy9YiANp24OwWSYRUy96L7o0bZplGR0Ay1Mot5wru04csr8Gg6i4Wy/
         18BMRHir0TPj/i8KMSIe/L1fVZ5fSLoPTSE7xy1ElmG4Lf9gcG5dioP2NI33bAIlyG2A
         10qqAZhfz3OGkoxaaUIy8orh6wMw+xEE6ZCr7B6C33vzz+1MpQw2iyI0GL5Mck9ZdL+v
         qBC+t5LP4Z351cXwEMMVARU9Ffts6lRE/w0atc6A8Ry+1VOh2+jYmnb/uisjIAfI86Sh
         1GQA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:mime-version:message-id:date:dkim-signature;
        bh=bM16Cxlynj/iYFnBhEVrgD674cLfvqLU43B4Z5mZd8I=;
        b=rwZcic+NjVwdKLu0WkzDPNxv62rbc3Tj6g3SUv+3F6I+7tKjhgM2YwOYPI0MlTxbck
         Eh1tBAQ9YblkHlNwQJC1akV41vqK18s6ojJPmdbeUn7umHEFaQqL9FmiiCefTGVUGYMw
         vk+ix7mZdZI/qKRpmnhEM01Oedi5JuFaPBoBqPFvBctz3JP+O5tpYNIBWCT7Jcs0RtTf
         B8weVPPx1tPegrtvJ4buM8ERzJKByg4v9eyW1k9K8smkTTjzAX2Sw2SUjfTJeekDM920
         Ld+v4x1ScMrjkuUyUELpezyWHehHPIWu+KrO+tkTtsgps+aVub/SPcACdBTf8ThlA81a
         44WQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b="r/N2p4ZH";
       spf=pass (google.com: domain of 3xrqtxqokcji309dkxgd9e2aa270.ya8749gj-886hwy6.ad2@flex--henryburns.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3xRQtXQoKCJI309DKxGD9E2AA270.yA8749GJ-886Hwy6.AD2@flex--henryburns.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id r127sor5786237vke.51.2019.07.15.17.05.25
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 15 Jul 2019 17:05:25 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3xrqtxqokcji309dkxgd9e2aa270.ya8749gj-886hwy6.ad2@flex--henryburns.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b="r/N2p4ZH";
       spf=pass (google.com: domain of 3xrqtxqokcji309dkxgd9e2aa270.ya8749gj-886hwy6.ad2@flex--henryburns.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3xRQtXQoKCJI309DKxGD9E2AA270.yA8749GJ-886Hwy6.AD2@flex--henryburns.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:message-id:mime-version:subject:from:to:cc;
        bh=bM16Cxlynj/iYFnBhEVrgD674cLfvqLU43B4Z5mZd8I=;
        b=r/N2p4ZHJhSkKWCbefj7oLG94wDUQjVPvpVsO2bZgKuDB6odzuwkhgqvbFRar5HUSM
         F0Uee5JIrhmDjcjHNCYqP0u8lHTYYSn3P5mPCGUqXgaEfFm0vlsGVxLj41XRkh4JassI
         T55j3gjAdlSg1uZ8LLEGxKrPlRyotdJfmag6H/o9kkWnFeHryKqaCuOkKEDMzD7SCS18
         64inrAv4F0E2JBmU86ETFJNPwo7XAlMBkS+jTgXic46jJcC/gfZFvRu2rZuCrPBU/+DD
         UWyMrmLLTGyjqm4yYyaofcm9Nw3LgJzqsQ+8xMf57fKGz/XDrayl8zrfMiG8bQejHqWU
         TV2A==
X-Google-Smtp-Source: APXvYqyKghXqh+hUwmcq39WhjGsA7PEfDV7IUtnSHADGYoM5Fvn2cKgA8Y0Zc4zvh5r1tKWM+7vjLynajC+dIAJ5
X-Received: by 2002:a1f:dec7:: with SMTP id v190mr11423849vkg.39.1563235525244;
 Mon, 15 Jul 2019 17:05:25 -0700 (PDT)
Date: Mon, 15 Jul 2019 17:05:20 -0700
Message-Id: <20190716000520.230595-1-henryburns@google.com>
Mime-Version: 1.0
X-Mailer: git-send-email 2.22.0.510.g264f2c817a-goog
Subject: [PATCH v2] mm/z3fold.c: Reinitialize zhdr structs after migration
From: Henry Burns <henryburns@google.com>
To: Vitaly Vul <vitaly.vul@sony.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Shakeel Butt <shakeelb@google.com>, 
	Jonathan Adams <jwadams@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, 
	Henry Burns <henryburns@google.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

z3fold_page_migration() calls memcpy(new_zhdr, zhdr, PAGE_SIZE).
However, zhdr contains fields that can't be directly coppied over (ex:
list_head, a circular linked list). We only need to initialize the
linked lists in new_zhdr, as z3fold_isolate_page() already ensures
that these lists are empty

Additionally it is possible that zhdr->work has been placed in a
workqueue. In this case we shouldn't migrate the page, as zhdr->work
references zhdr as opposed to new_zhdr.

Fixes: bba4c5f96ce4 ("mm/z3fold.c: support page migration")
Signed-off-by: Henry Burns <henryburns@google.com>
---
 Changelog since v1:
 - Made comments explicityly refer to new_zhdr->buddy.

 mm/z3fold.c | 10 ++++++++++
 1 file changed, 10 insertions(+)

diff --git a/mm/z3fold.c b/mm/z3fold.c
index 42ef9955117c..f4b2283b19a3 100644
--- a/mm/z3fold.c
+++ b/mm/z3fold.c
@@ -1352,12 +1352,22 @@ static int z3fold_page_migrate(struct address_space *mapping, struct page *newpa
 		z3fold_page_unlock(zhdr);
 		return -EBUSY;
 	}
+	if (work_pending(&zhdr->work)) {
+		z3fold_page_unlock(zhdr);
+		return -EAGAIN;
+	}
 	new_zhdr = page_address(newpage);
 	memcpy(new_zhdr, zhdr, PAGE_SIZE);
 	newpage->private = page->private;
 	page->private = 0;
 	z3fold_page_unlock(zhdr);
 	spin_lock_init(&new_zhdr->page_lock);
+	INIT_WORK(&new_zhdr->work, compact_page_work);
+	/*
+	 * z3fold_page_isolate() ensures that new_zhdr->buddy is empty,
+	 * so we only have to reinitialize it.
+	 */
+	INIT_LIST_HEAD(&new_zhdr->buddy);
 	new_mapping = page_mapping(page);
 	__ClearPageMovable(page);
 	ClearPagePrivate(page);
-- 
2.22.0.510.g264f2c817a-goog

