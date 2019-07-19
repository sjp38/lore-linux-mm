Return-Path: <SRS0=qzwp=VQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-10.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4443BC76197
	for <linux-mm@archiver.kernel.org>; Fri, 19 Jul 2019 04:07:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F225F2189F
	for <linux-mm@archiver.kernel.org>; Fri, 19 Jul 2019 04:06:59 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="UWyKZESY"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F225F2189F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 929DB8E000D; Fri, 19 Jul 2019 00:06:59 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8B3F98E0001; Fri, 19 Jul 2019 00:06:59 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 77B848E000D; Fri, 19 Jul 2019 00:06:59 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 40C808E0001
	for <linux-mm@kvack.org>; Fri, 19 Jul 2019 00:06:59 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id b18so17955762pgg.8
        for <linux-mm@kvack.org>; Thu, 18 Jul 2019 21:06:59 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=4gOJ72d8Z3asX005sWwEX+eZ0vU9BN9QWFdz0Lm3Vuw=;
        b=DLOIhv8YmoaRox0q1ZmxPS6iXGomuXG6RDntl5gYExqy74LrWgIKckd4cPd42MHCVZ
         d7jvxqcJ1fgC6letgsvhZcb96Us531PBuGSWL0KmPrjif1s8HAYwqta2xpkEhiGUo7Ce
         4QL+yR3e57HuN5qIn2089Zagy3pPv/4ByLm44hhJ37u5YyhLDFjmqVgTFny/mBv8qRJw
         2SM4fUPjrRsgAWSzJpU0xeHKgCgP73jbZtdpLTfPbjT93nh4z1UJoaERQNNBVEchA3pr
         Qtu29oRmeDBznErzohrwr9TgzB6S9ECEtjIPGWvtmF+dmL3ooTFV84phbSi3YSAaRhgm
         yN4A==
X-Gm-Message-State: APjAAAVacnE6VGTY/cQ7wCuaieurKVz/G4ssFe38u862UDDzj5syA8Zq
	XX/U7okgDb6/CMt8QCK2P3up0hViFTkc4AiCDBQTH6/tPDotd9MjvO2KA4JuHxKwxPAKE16wZRJ
	IsqlLFsS0vT4BYiIQb9oalYTuLPpd1VWaGAJ5/yOBzsj7+plnujeIM1wvsHUrsu69Pg==
X-Received: by 2002:a17:902:70c3:: with SMTP id l3mr53390883plt.92.1563509218929;
        Thu, 18 Jul 2019 21:06:58 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw1VIHl4oyf/HpWSccpuEbVemYDEaTW4X62g0v6bb4mEibtfR8HmCvMgWkkmvDHockoVzlV
X-Received: by 2002:a17:902:70c3:: with SMTP id l3mr53390805plt.92.1563509218193;
        Thu, 18 Jul 2019 21:06:58 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563509218; cv=none;
        d=google.com; s=arc-20160816;
        b=XqoTnREGqypyMV1I1wQmLOqxhHlH2cQ/FFc+Xqf4uYM2C4eY7yTCVg4e1iyT6v04Yp
         EsKVcXhCAgaCtY5QYLSmzElEJ2kSu9PiL3fXcwAgT7LGIWofUbwnaotq7Rt5/uchqsV4
         hcxhR+M/P4ShMFZ4VHQEG8+W8Hm2lAKJKkkHvJvx2E0oU+yaDD5loxPzIIJy/Paf9r7V
         tCjwfwRDAsUsBLJ4T9J6J+yl5suet1XImoRpZHh/9ju6XVyYo4UbU/ixD/0nG+RV/6EU
         xqrvZHBOoIhlprrQ9ClwHHg5kE6sUG19aC3KsSrGjK7eW6E9liHa7XGlmaF7i6jxkAOA
         Ipow==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=4gOJ72d8Z3asX005sWwEX+eZ0vU9BN9QWFdz0Lm3Vuw=;
        b=usYZS9ArWPhQR+qLe7dMyGN6AHiuHbY5S4A3AcJDD5sAz+bks/i8AVyaxWcf7JOV5a
         AcBwAFq9VfpGtKBFI348FLs16Dfk6FdsUhemH6Lu2En5NS+O8tVIfQ2JCD+6QFmb1Hp6
         NgPujsyyBHkvgJuIUffkm2f31pc6LlAj5vgevfcNhDpAzz67fZcGqe+K8lvbuO8+R4Pa
         KYAlmcS63kpuFGYCzazbTey4pIeS6w1hQOlrtyucPSjFRsANjZvedDEU8w3bQ57PAbwa
         HQAl1nPY9w6yqL8aQe0u6ZTTkA5xFjcBa1jAzGwth5b/0ODiOfR219qG31vQtOobQbHJ
         lfww==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=UWyKZESY;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id l2si776002pff.221.2019.07.18.21.06.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Jul 2019 21:06:58 -0700 (PDT)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=UWyKZESY;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id EB88721873;
	Fri, 19 Jul 2019 04:06:56 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1563509217;
	bh=tyRPrOwKObReDHMdAgwbRdxfiTZLlY8WCnzQi9XBHBM=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=UWyKZESYBXt4RUSvIhxCwUmx1BCFI1c3ZGbDVd/+CWN0SdqPZSIp3SrNNN00bJQfa
	 MpFb9laELaoX+hX2mEoyYuP0IxQd71oDoHoNTTCFi83J/64CuE5LgGNRyLrikZfOSZ
	 96KqqjzHovzT6NheY2J/KVfQaYWW6sM6oNZfmzzU=
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
Subject: [PATCH AUTOSEL 5.1 132/141] mm/mmu_notifier: use hlist_add_head_rcu()
Date: Fri, 19 Jul 2019 00:02:37 -0400
Message-Id: <20190719040246.15945-132-sashal@kernel.org>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190719040246.15945-1-sashal@kernel.org>
References: <20190719040246.15945-1-sashal@kernel.org>
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
2.20.1

