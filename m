Return-Path: <SRS0=Mdb/=TC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4E283C43219
	for <linux-mm@archiver.kernel.org>; Thu,  2 May 2019 13:38:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1651E2075E
	for <linux-mm@archiver.kernel.org>; Thu,  2 May 2019 13:38:25 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1651E2075E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A2C456B0003; Thu,  2 May 2019 09:38:24 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9DC4F6B0006; Thu,  2 May 2019 09:38:24 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8F1826B0007; Thu,  2 May 2019 09:38:24 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 44AF16B0003
	for <linux-mm@kvack.org>; Thu,  2 May 2019 09:38:24 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id z5so1082221edz.3
        for <linux-mm@kvack.org>; Thu, 02 May 2019 06:38:24 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version:content-transfer-encoding;
        bh=c4gQzEkO2QF6JtavkynFk4gbYyaIDHsw2X/LZQAVqeI=;
        b=YXsMH0KpfRiQX4qHpeayt+twPigKkJes68vJvc517AyqMQ+MBxw/8FDKF/vMapyphr
         yGMUnUdea840AdzLbaBmptvAv+VdOo444nb6OVSLNSw001Ltwlp02t+oBzCumYvJaEGW
         F5wHOJofaPt1g1j9zxT0KEfrG2g4RlLrnvjY+soaq+h+yunxWlLRZs/0AKAX485AYgko
         09iRXlSmVNIKx8jfNM4iENbOq8c8iEer/TIkP5ylbE/cfQX6Rckqd/oWGZ76STGtFwCQ
         RE+Vy5vcY3hn8XPCfk1pRWb2fUwYgg9kRmgHmQGlbo8wTirm6+0asDED1HJcCTCLsHZI
         ZXzg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jean-philippe.brucker@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=jean-philippe.brucker@arm.com
X-Gm-Message-State: APjAAAV0PMRnHpeFhQrZG4AfNikmHvx8w58qyERi+OoIpRDocIa2z38h
	l74QizILUMqWBkYut7hMZ3fggXgLJ8q9QbT0ir9G34OkTj0i0OstkVOKYOdyGupwR73kFqqAuOs
	KSZCppp98r+MLTstUcGfd1l5CQjH+HSOgtVFQ72WJWZdqxSv5J4QWL1cZD6dNGWPEMA==
X-Received: by 2002:a17:906:655:: with SMTP id t21mr1814247ejb.64.1556804303738;
        Thu, 02 May 2019 06:38:23 -0700 (PDT)
X-Google-Smtp-Source: APXvYqye+i2W3d2pM0XFqRaw+pCNq0T84pH4ZDKS0TsHVz7cQx4tVp65y1V6e7UxAwYk9zvzXpLv
X-Received: by 2002:a17:906:655:: with SMTP id t21mr1814181ejb.64.1556804301997;
        Thu, 02 May 2019 06:38:21 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556804301; cv=none;
        d=google.com; s=arc-20160816;
        b=hqy5eO1qGL3SJJSk639MmeiQlMA72ELpFUUMDPO5eJd8ZdUNw8h3/DADNuMK7hJEH7
         ElpeuPyT6PAp9w8FXxQ/uyGzs9oc0f31mJB688x0YrgTSCPOBIxGygRwOk7nWZgbv/VT
         LydL6cdvxTv+cr38+8NkxquL86sI30ceNP99CEOFu2u7YoffaMgoGPUAeSEiElxOGfzh
         l0gBsijVnYTTMG1qx7cf+z7QYXxuZFRyUOxPdiPjWLfbZsal0erUq1nkRzG7m6/2Efjg
         haYbtWZtblF+gBJZ6i2TzsO2IQ0TU0G2uo8aYthNjypnEEEk1GvLic4IBuGJpewFS7tJ
         CCng==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from;
        bh=c4gQzEkO2QF6JtavkynFk4gbYyaIDHsw2X/LZQAVqeI=;
        b=dXPaNR8abeD8RijC3QxkOCth5u77XA5Oh4wXto6DnrkpOqhBI2sP33C0UrK90LmHEN
         qVNRCkxWPuWkP/mQLdmrbpuAaoCx6JFAPKL15IsQc9dT4T/aYjHErgOXP7FUppwjutSh
         ilUm0j53Ld+O8u5tl4y+ErwPIugI/lyoiffwxBcFbm5fzMKowszCOVtEy53Lf+2djLtE
         O4MkXV+XEWnMbxyAqlnttQ2pM8Lk8w3C+nV87ca7Xp6E+4KdmXCKjrjyO4/DLzwi80Cs
         ur+R87wqksPDbrqcIqjtfR6crCpJ8SqrqnK5cqe0Fedxl0sNh6IzJ4aN2nbu2w3SZ5nZ
         pWQw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jean-philippe.brucker@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=jean-philippe.brucker@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id q38si798923eda.156.2019.05.02.06.38.21
        for <linux-mm@kvack.org>;
        Thu, 02 May 2019 06:38:21 -0700 (PDT)
Received-SPF: pass (google.com: domain of jean-philippe.brucker@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jean-philippe.brucker@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=jean-philippe.brucker@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id A5CC7374;
	Thu,  2 May 2019 06:38:20 -0700 (PDT)
Received: from ostrya.cambridge.arm.com (ostrya.cambridge.arm.com [10.1.196.129])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPA id AF8313F719;
	Thu,  2 May 2019 06:38:19 -0700 (PDT)
From: Jean-Philippe Brucker <jean-philippe.brucker@arm.com>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org,
	jglisse@redhat.com,
	mhocko@suse.com
Subject: [PATCH] mm/mmu_notifier: Use hlist_add_head_rcu()
Date: Thu,  2 May 2019 14:35:32 +0100
Message-Id: <20190502133532.24981-1-jean-philippe.brucker@arm.com>
X-Mailer: git-send-email 2.21.0
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Make mmu_notifier_register() safer by issuing a memory barrier before
registering a new notifier. This fixes a theoretical bug on weakly ordered
CPUs. For example, take this simplified use of notifiers by a driver:

	my_struct->mn.ops = &my_ops; /* (1) */
	mmu_notifier_register(&my_struct->mn, mm)
		...
		hlist_add_head(&mn->hlist, &mm->mmu_notifiers); /* (2) */
		...

Once mmu_notifier_register() releases the mm locks, another thread can
invalidate a range:

	mmu_notifier_invalidate_range()
		...
		hlist_for_each_entry_rcu(mn, &mm->mmu_notifiers, hlist) {
			if (mn->ops->invalidate_range)

The read side relies on the data dependency between mn and ops to ensure
that the pointer is properly initialized. But the write side doesn't have
any dependency between (1) and (2), so they could be reordered and the
readers could dereference an invalid mn->ops. mmu_notifier_register() does
take all the mm locks before adding to the hlist, but those have acquire
semantics which isn't sufficient.

By calling hlist_add_head_rcu() instead of hlist_add_head() we update
the hlist using a store-release, ensuring that readers see prior
initialization of my_struct. This situation is better illustated by
litmus test MP+onceassign+derefonce.

Fixes: cddb8a5c14aa ("mmu-notifiers: core")
Signed-off-by: Jean-Philippe Brucker <jean-philippe.brucker@arm.com>
---
 mm/mmu_notifier.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/mmu_notifier.c b/mm/mmu_notifier.c
index 9c884abc7850..9f246c960e65 100644
--- a/mm/mmu_notifier.c
+++ b/mm/mmu_notifier.c
@@ -276,7 +276,7 @@ static int do_mmu_notifier_register(struct mmu_notifier *mn,
 	 * thanks to mm_take_all_locks().
 	 */
 	spin_lock(&mm->mmu_notifier_mm->lock);
-	hlist_add_head(&mn->hlist, &mm->mmu_notifier_mm->list);
+	hlist_add_head_rcu(&mn->hlist, &mm->mmu_notifier_mm->list);
 	spin_unlock(&mm->mmu_notifier_mm->lock);
 
 	mm_drop_all_locks(mm);
-- 
2.21.0

