Return-Path: <SRS0=qzwp=VQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-10.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DB7A2C76188
	for <linux-mm@archiver.kernel.org>; Fri, 19 Jul 2019 04:15:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 96A6021851
	for <linux-mm@archiver.kernel.org>; Fri, 19 Jul 2019 04:15:33 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="OR5MbLg+"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 96A6021851
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 441378E0015; Fri, 19 Jul 2019 00:15:33 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3CB5E8E0001; Fri, 19 Jul 2019 00:15:33 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 26C268E0015; Fri, 19 Jul 2019 00:15:33 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id E43C58E0001
	for <linux-mm@kvack.org>; Fri, 19 Jul 2019 00:15:32 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id g21so17926712pfb.13
        for <linux-mm@kvack.org>; Thu, 18 Jul 2019 21:15:32 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=amCNZVg1ToumtpytLGQBBV9RcLfGLmVIvquKTpuM7PA=;
        b=ecGtbkaT5eUr9BU9LBdc+VQOsHOvew8rxJvkmu0BnuiTAXWJEWUnBXuzqMSd893j0s
         UVgcpTUvyBdPG8BmqaG11U3FQRTTEc2LYLnmo8Us5gZZTubTnv9aoj33j9xi6W6OCeux
         ybwBwuMvd3wFVlgL31AqOhCsiKEOv8fiuVgSaSV8UUrvHoxFQ7o4MZQ9qfcMqBC3mBX1
         LH2lRNVeOc+nWYSp6kGxJAguw4ZorCzxm2/0GGmAbgP6lfCaMAhcyS2UBzhUKkq27b4T
         aCMLgZKAnx+kmie1Ozcw2oq5Y1r/YHaYzluvglvZhCqb9S9XFIdPi+U2410A+nzMK0+l
         4yOQ==
X-Gm-Message-State: APjAAAX5xNgAhio6tyNzW7u8CYTqPHrBuF4WEcIOb+7PEBYD2siitelE
	fAD91c6LobvzFHUcqhwNcMMNIb+1XRR1vSs+26xZzxkxdpe8q+mTqGOmno9SE5M9TfpFS8HsSH0
	t21LLVi2v60VbFvV5n3ze0x5feMJ8pSF2e4kAANT57GGTn3Yd7SiWzLPq/htPpJW+mQ==
X-Received: by 2002:a65:5584:: with SMTP id j4mr21459640pgs.258.1563509732393;
        Thu, 18 Jul 2019 21:15:32 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwm4V/te9ZejxeZ44B0bKwcRuWqN+OfBEtsRn61Ri3EoFdqcrMF4lzg421IC9KO0/ZDw6cs
X-Received: by 2002:a65:5584:: with SMTP id j4mr21459585pgs.258.1563509731585;
        Thu, 18 Jul 2019 21:15:31 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563509731; cv=none;
        d=google.com; s=arc-20160816;
        b=Jjw1xiCYFNOI+LFZ16TN0CGnwD07rDbQOSYkTZ7Ya+4vsnhcMIILElV/kD2yiAswe5
         KHSBDarukjrhVFs8jayiDiDadgCdTGqUa7JnoPV758mxsMq3NuLH0rvfCnxcCsnlEZkl
         wKA11xJNItn3qlSkTbMHcozenZ1GllSUbwSQb7NryqiPc8v2RY3kAucPDboRvNoMYo8U
         GYfL/MkzoFinzWeCj/pmTXnK3dzKhHlurVGmfyaDgWcrD5iPURrmfuXTwgYTTwxZhZbq
         3D2ZRiYVajh2xCPHYgVGrv4uX2Z07DXD/oPUVEg0NvLCHaMdal6szcy43ylqhc6Pqe/1
         Y7xQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=amCNZVg1ToumtpytLGQBBV9RcLfGLmVIvquKTpuM7PA=;
        b=mkWUf2XO03B7MLsjCN1PslXxGEru+v2594Z4kRAoaRqZxYYkQfkt7+Udu/ztnuJGZG
         nmwYmGjOuw+fzd8Zkr7kuxY4XqS7vlYRwVQUljesIvvRIakDu6wr+/Ep1zR6bMqK941K
         swjYG3Z1/qfokNJ3QI+KVfuQ8XnVPfGfhioV3MP6yCF5nLgifXcJxHTyLwEjDgc2bP0+
         Y39HvxmLobzhsMKAAtwSNnyxqKUU3issQMRIHBzX868gKKVKFwsWveorKmMM8wxCHLXk
         MA0BAHOnFq+5UGLy05V4Yyl1cbwaG3Yw0OkhGEt1KMNQjzLQaDvIY0FVFaeHnvvWUlff
         eNwQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=OR5MbLg+;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id m128si700879pfm.97.2019.07.18.21.15.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Jul 2019 21:15:31 -0700 (PDT)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=OR5MbLg+;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 571BA21851;
	Fri, 19 Jul 2019 04:15:30 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1563509731;
	bh=3Q+l1xujR7u/fv7C7HJEW+f+9AEe60aJjqb+rtS+TWk=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=OR5MbLg+ZiMzcguHv+zVZFK/0p0dxDPloXnygwvYaYtzzU8ogqnqrX+Qgyj/TdQrq
	 OrZXpLJoRhSYoIgEpXCpdfHc7YFuIrkBYxC4ZsQ2thtIGA/98FOx7pUv6DXMYj9k/3
	 otWjAr4mrCiBniWSQEYgrgeMbjWu2iji46yHdLdU=
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
Subject: [PATCH AUTOSEL 4.4 34/35] mm/mmu_notifier: use hlist_add_head_rcu()
Date: Fri, 19 Jul 2019 00:14:22 -0400
Message-Id: <20190719041423.19322-34-sashal@kernel.org>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190719041423.19322-1-sashal@kernel.org>
References: <20190719041423.19322-1-sashal@kernel.org>
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
index 5fbdd367bbed..ad90b8f85223 100644
--- a/mm/mmu_notifier.c
+++ b/mm/mmu_notifier.c
@@ -286,7 +286,7 @@ static int do_mmu_notifier_register(struct mmu_notifier *mn,
 	 * thanks to mm_take_all_locks().
 	 */
 	spin_lock(&mm->mmu_notifier_mm->lock);
-	hlist_add_head(&mn->hlist, &mm->mmu_notifier_mm->list);
+	hlist_add_head_rcu(&mn->hlist, &mm->mmu_notifier_mm->list);
 	spin_unlock(&mm->mmu_notifier_mm->lock);
 
 	mm_drop_all_locks(mm);
-- 
2.20.1

