Return-Path: <SRS0=qzwp=VQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-10.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3321DC76195
	for <linux-mm@archiver.kernel.org>; Fri, 19 Jul 2019 04:13:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E1DCF2082F
	for <linux-mm@archiver.kernel.org>; Fri, 19 Jul 2019 04:13:03 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="yFYvAD+E"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E1DCF2082F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8B0968E0013; Fri, 19 Jul 2019 00:13:03 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8609D8E0001; Fri, 19 Jul 2019 00:13:03 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7299D8E0013; Fri, 19 Jul 2019 00:13:03 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f70.google.com (mail-yw1-f70.google.com [209.85.161.70])
	by kanga.kvack.org (Postfix) with ESMTP id 4F2E98E0001
	for <linux-mm@kvack.org>; Fri, 19 Jul 2019 00:13:03 -0400 (EDT)
Received: by mail-yw1-f70.google.com with SMTP id d135so22964019ywd.0
        for <linux-mm@kvack.org>; Thu, 18 Jul 2019 21:13:03 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=tzfLdI6Fx3HpnkCJw60MZXnCO/zvInskwvapw5KzgNA=;
        b=aUEKSHYRmuJdsj6e39esuHOIyubXhQyG1tncURcKXLxpAe3nc2vOEfAZ9BrNn1gD3O
         AHBJXCOyhTNomeAqyzGj6EUi+aOI3Xf5DgEZavGsDmgRW6VA56HA/Sv6rSNByVsOfjgP
         phoksnQ7ZfIpw0zC+EZT1GkbmKahB+RzLCY2M8znuuQW5JEecGERdcenZ4kZTQZ+G9K9
         AhsTd59E0Ckotb7LS+Tf14vLcitGEiWn6PqLCBFFFHbWDkfRWBmQ5dBhSnxzPcOlczqZ
         pfhqQ9sW2pu/pFIEkzqInfxD+SmWzV1RTLy1EDOKuQAMnigcmSxgk01PkfwFl3PAFWJq
         jhcQ==
X-Gm-Message-State: APjAAAXJcHlsX8TzFgbeJjxfMduaiQvM88+5qCQvkvcWuujXHmhEQhRp
	eHPgHPbywQ5KfpBacEf4yLKmuzY+iZn3CRGZPKvvCNxFCxZKkY4afegS+Ev3XTxh/5sh7ArWpbh
	17hBdm+wsBO33K1wM43MjpwEGUO3bmvSvNkCRU21BUZuGhjgfShjVr9IpIZVXYkQfVA==
X-Received: by 2002:a81:ae0e:: with SMTP id m14mr32018400ywh.308.1563509583040;
        Thu, 18 Jul 2019 21:13:03 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwPgHpXwnMUnt8HFtIU99VLw9Kuk5mUBQA5sG0AdG7OqZryErpr4N7aNbi/Ozl7qpL9mKOD
X-Received: by 2002:a81:ae0e:: with SMTP id m14mr32018364ywh.308.1563509582332;
        Thu, 18 Jul 2019 21:13:02 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563509582; cv=none;
        d=google.com; s=arc-20160816;
        b=DEz43sQ/8ENZirTIWYatmLn2mRhjm/u6noKGuLDzAnoX8Xrg7kFw/7PQn0JxAs5kap
         2YBIq5ylfbnVk6vcwqgBtCwvthY1NFWaETHa70oJb7URZGvuNYjrnNavFVVMixogZ65W
         rUuNXTIeikmbUzooKAUx1dYswZOhqGIg6zIWUtMMNxre0vM7DocUjPJH6O1s1YPucdYK
         gM8nRoYCk0SYyWlNzLBKdZt2meWzDzEmje7pcljoLYeKBu9MU2TjhzWW70GtVmrISmzD
         O0MvOWCpq2gO6C1DkJsPs2cjPEtU/5UTD+Wpwls8c5m+u3YNOQrsqi2CN7X0FPiHcnZO
         21qw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=tzfLdI6Fx3HpnkCJw60MZXnCO/zvInskwvapw5KzgNA=;
        b=W9DVfjel5jWZhGcXWyKJnBLqJ6qD7/bEPLVeieeNNxj6lkMd5Rv6VZ8+iqr8EpILqd
         sWxX6YDbdJ7SK6UGaqXpBc3ux2bImCxPhwXLxV/zKTuNnK9ACbUeA+3hwr4yG1itxRgW
         urHsg7zSLt+eopm7JZIXMv0AOiXmUagR42S/stnPUdZlbbpjiTNu+uEq/7gRRzrA7epq
         EXPXUCQWOWaQD7uvkbRPZxvk+gL2E+TcUW9VcO9E7sUnqRh6Fq0yy/vjx3bgmtu4XSwI
         3epOruuNogZE4UwZdex9LJHbv9SYQhT5Jqr45qCYgXyF84Cze43asImx6gONOxSHydxC
         BYtA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=yFYvAD+E;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id d80si10952186ywd.339.2019.07.18.21.13.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Jul 2019 21:13:02 -0700 (PDT)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=yFYvAD+E;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 5155721873;
	Fri, 19 Jul 2019 04:13:00 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1563509581;
	bh=cTY1spXsTU02GKM3ghA6n7qzp1UH5eaofLZ+5Ltu6qk=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=yFYvAD+EtbZCJOv4PDopCw8J2Ta5y8tg4eP3D5G/faADxgwFzUP2RF9/OS6GjU1/w
	 NMbQh1GrJqlT3eS2FImSvyQ6yc/7anwKG+MzCo3IQqxTCiisATeFy93EVSNlyenDTZ
	 wFBRatFgfVRjq34+8pWFWS28hsWULUypKibjxYr0=
From: Sasha Levin <sashal@kernel.org>
To: linux-kernel@vger.kernel.org,
	stable@vger.kernel.org
Cc: Jean-Philippe Brucker <jean-philippe.brucker@arm.com>,
	=?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	Michal Hocko <mhocko@suse.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Sasha Levin <sashal@kernel.org>,
	linux-mm@kvack.org
Subject: [PATCH AUTOSEL 4.14 59/60] mm/mmu_notifier: use hlist_add_head_rcu()
Date: Fri, 19 Jul 2019 00:11:08 -0400
Message-Id: <20190719041109.18262-59-sashal@kernel.org>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190719041109.18262-1-sashal@kernel.org>
References: <20190719041109.18262-1-sashal@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
X-stable: review
X-Patchwork-Hint: Ignore
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Jean-Philippe Brucker <jean-philippe.brucker@arm.com>

[ Upstream commit 543bdb2d825fe2400d6e951f1786d92139a16931 ]

Make mmu_notifier_register() safer by issuing a memory barrier before
registering a new notifier.  This fixes a theoretical bug on weakly
ordered CPUs.  For example, take this simplified use of notifiers by a
driver:

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
that the pointer is properly initialized.  But the write side doesn't have
any dependency between (1) and (2), so they could be reordered and the
readers could dereference an invalid mn->ops.  mmu_notifier_register()
does take all the mm locks before adding to the hlist, but those have
acquire semantics which isn't sufficient.

By calling hlist_add_head_rcu() instead of hlist_add_head() we update the
hlist using a store-release, ensuring that readers see prior
initialization of my_struct.  This situation is better illustated by
litmus test MP+onceassign+derefonce.

Link: http://lkml.kernel.org/r/20190502133532.24981-1-jean-philippe.brucker@arm.com
Fixes: cddb8a5c14aa ("mmu-notifiers: core")
Signed-off-by: Jean-Philippe Brucker <jean-philippe.brucker@arm.com>
Cc: Jérôme Glisse <jglisse@redhat.com>
Cc: Michal Hocko <mhocko@suse.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
Signed-off-by: Sasha Levin <sashal@kernel.org>
---
 mm/mmu_notifier.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/mmu_notifier.c b/mm/mmu_notifier.c
index 314285284e6e..70d0efb06374 100644
--- a/mm/mmu_notifier.c
+++ b/mm/mmu_notifier.c
@@ -267,7 +267,7 @@ static int do_mmu_notifier_register(struct mmu_notifier *mn,
 	 * thanks to mm_take_all_locks().
 	 */
 	spin_lock(&mm->mmu_notifier_mm->lock);
-	hlist_add_head(&mn->hlist, &mm->mmu_notifier_mm->list);
+	hlist_add_head_rcu(&mn->hlist, &mm->mmu_notifier_mm->list);
 	spin_unlock(&mm->mmu_notifier_mm->lock);
 
 	mm_drop_all_locks(mm);
-- 
2.20.1

