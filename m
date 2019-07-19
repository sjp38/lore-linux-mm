Return-Path: <SRS0=qzwp=VQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-10.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 84240C76195
	for <linux-mm@archiver.kernel.org>; Fri, 19 Jul 2019 04:14:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3F7E92189D
	for <linux-mm@archiver.kernel.org>; Fri, 19 Jul 2019 04:14:23 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="2FKTdMgn"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3F7E92189D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E06E48E0014; Fri, 19 Jul 2019 00:14:22 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D91878E0001; Fri, 19 Jul 2019 00:14:22 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BE2BE8E0014; Fri, 19 Jul 2019 00:14:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 867F38E0001
	for <linux-mm@kvack.org>; Fri, 19 Jul 2019 00:14:22 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id k9so15134266pls.13
        for <linux-mm@kvack.org>; Thu, 18 Jul 2019 21:14:22 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=BXSW/IZltfT//HOzkneC5GzcWqvvFOv6FEHgICKzkfs=;
        b=oeaq4WRxFY+1e5Spr3uzV85QJCHOsHXc++GgQARzt2fgyuAXnYI1hlapxgQd9nHHLg
         9rwWSXPyHZ3Dg26OVxDZF7PrgkVwa2mzMLxXPb84GBfLn4HmZ7sPTSBrWLJGGToFdz9Y
         BvsLhLE6e8tkj9RfiQKgbRogNo6Z2UYoBTggFWLyXjJgaFX/MzRiaMUL/omcuIdg5HsR
         9NesymUKbF6M6gC+t8LbJXL8Qnymfswh9Tbm4kPcQJ+GmdyOH/VXXQtmLzhGu8OHRI3u
         EqLfz+H2xx8/IbWDyzCof4tBoPQ3jvVy6m9kuSidFiIYfLfB335f/K9OMCSjKpgkp1tg
         fJDQ==
X-Gm-Message-State: APjAAAUrmKoS2tE2ZyJal5mL4FZgPLjoWwYozjN+Ug70zY433a8t3mO7
	33KAEN743ragWSPAVAWGCKBCpvjZFNR9fOhqSLYnJM95ivOvFOe/aHsesrBnx625of/vYDYSagF
	Hj1QZrBaIunMY+9yk7Jp9oS7uIkLRXDoYRuJArowmNXUa+QgN2gPSAEnwjcxgUZgpmg==
X-Received: by 2002:a65:654f:: with SMTP id a15mr50281167pgw.73.1563509662074;
        Thu, 18 Jul 2019 21:14:22 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy1Q3BM+If4wwms+o2AWkYxE/A2+qA6q7u0tYd9PcDRr08eV8CWN27t8SUolhOwG4iUvIrE
X-Received: by 2002:a65:654f:: with SMTP id a15mr50281107pgw.73.1563509661279;
        Thu, 18 Jul 2019 21:14:21 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563509661; cv=none;
        d=google.com; s=arc-20160816;
        b=UF3kOxKKi3zvqTtaJwejdBl6wLJu3uStZPcTXoFrR7n5qo7KcayBwf+JlrQqjWLOOs
         qIqe4TfjoVYSMofSL5JnLA+4i+rgPTpXUi3FXD5Xml7f/ID0jA4oJbtEFH+uJGpsZgSi
         ROrk5ab8nSG/fySPHzVwkfMT2Q62AfRXh1HKWPeNhBs432I+f/eBrZOCX/sXcMkUgOgn
         HW4a/QqkaJHGPN6ZJecXi2T3CF2s8lJE+E8eRXemEkAc8VKOwq6IMaq4mOtjLJaNbItf
         xmxD2+2BuYY9AYP6yvHT4EhDLbNDPZCGQc8FOqtCqeKFe8rjffe6o0HHxBqK+6ujj9iq
         dGew==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=BXSW/IZltfT//HOzkneC5GzcWqvvFOv6FEHgICKzkfs=;
        b=poi3Px23QiP2rXqyBOaKvyvK15QUaKPG4C8PEWiUO29YRe7fzgri5nJEoNOZR40NQ8
         6KOg8+hoCWWArZ5KxB8JtdkOlGi1fXnN4mUcrdjg/RP9lDxyTd5/wbc4JGUh90d66jwl
         sLU3X6zxNJFOGvjzUsjpUBe7SOYzPxbI1dSGtVt4FcH9wxDQ4J+JWRsrA/LJTtB4Q8Qo
         eI+iLs+3RPqra2sEDHOpLkqHH+wkJRuevTdNN8TTelGq//k7UYkMdPatSEXseABYbVL/
         FA+rzq3YJC5ov6SVveK+UgZO7GoKEPqNi2nExY6lTv3xdQ80VBWchLFPI0CPQkryad6c
         9xSA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=2FKTdMgn;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id n13si62665pff.46.2019.07.18.21.14.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Jul 2019 21:14:21 -0700 (PDT)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=2FKTdMgn;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 11FAC21873;
	Fri, 19 Jul 2019 04:14:19 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1563509661;
	bh=wkAGBGsIOz7ocQoR+xQeCTnxMLX7lj5Q/aPZDGMTImU=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=2FKTdMgnKygiNhPdlK4RZBcGRMT6+62sRMSWPZxR2B5epCKRyWv9RlMylkc4eVwmZ
	 jXfQEsW0iJNN6QOUMp7g3DrupxSEONuTY1/Ym08VXKejZHprVtMIUpBPFKCPjLwiDq
	 foEcnhxVsFNFKKW++5LUj9vOjo/rA7xqt8FoEdY0=
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
Subject: [PATCH AUTOSEL 4.9 44/45] mm/mmu_notifier: use hlist_add_head_rcu()
Date: Fri, 19 Jul 2019 00:13:03 -0400
Message-Id: <20190719041304.18849-44-sashal@kernel.org>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190719041304.18849-1-sashal@kernel.org>
References: <20190719041304.18849-1-sashal@kernel.org>
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
index f4259e496f83..7a66e37efb4d 100644
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

