Return-Path: <SRS0=qzwp=VQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-10.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AD35EC76195
	for <linux-mm@archiver.kernel.org>; Fri, 19 Jul 2019 04:10:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5DDE821872
	for <linux-mm@archiver.kernel.org>; Fri, 19 Jul 2019 04:10:42 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="fa2mh0NB"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5DDE821872
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 09ADA8E0011; Fri, 19 Jul 2019 00:10:42 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 04BEF8E0001; Fri, 19 Jul 2019 00:10:41 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E7D948E0011; Fri, 19 Jul 2019 00:10:41 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id B3A7C8E0001
	for <linux-mm@kvack.org>; Fri, 19 Jul 2019 00:10:41 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id z14so10949241pgr.22
        for <linux-mm@kvack.org>; Thu, 18 Jul 2019 21:10:41 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=j68g3xP5dT/28mgpIBMlvTbOQ9yxyTPBgnuVizOxHf0=;
        b=cFeAApzl7nHAkwFk5mDLzQFoIV1VPNDKQ3W08G44yzorOjjN1fZkqHmaowT4u0C/V7
         o+mxWse0g8VvsdGC/keVi0VhoOOFCOxozR+ih8h6WU/qKIwKWYFMCz+5kLhj1pJVVZGv
         w4zWlk1zQAxmNLHbmkZlPGrLVxcshTI06bO3StvsvIE+VoJ4trC674zltGUfe9sPFRlS
         VaTANyG4Pag64a0OpvCVfgQ9wMoDyD4WLpwIf8ToNGbBTxges+OpkYoNo24q4VboTVJg
         ayLJgiplVKMjYWKCsA0EZUqV6inPPp6IiSB+TdLC+cvroCJmdooNgZ5ELBWtDkni4Zhu
         g4fw==
X-Gm-Message-State: APjAAAVWQN4cWyIfbdBmdQC+cLtDhEKSmQIOR40fwq7fAK2h6YSiNfe+
	1oPIKDvcVwHCsR0iQeBgMdJesDqyCz14bZV/YzLu4lWAHIpO8fCcmB2Tv9+jEFMkAPm2fv93DsH
	rx8dukzED5UzVB9U4DvYgRkxxI1BKCjFHA6XZCh3iLERRSFJnRdC8DSWpWQFE0eyccA==
X-Received: by 2002:a63:3c5:: with SMTP id 188mr50767880pgd.394.1563509441278;
        Thu, 18 Jul 2019 21:10:41 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxsz3ybDdZJsajK/tffv39L0El97WFkXDAn19sLa/uy+/fALzsB0h0ytdXuNukNdS+tpf2Z
X-Received: by 2002:a63:3c5:: with SMTP id 188mr50767828pgd.394.1563509440511;
        Thu, 18 Jul 2019 21:10:40 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563509440; cv=none;
        d=google.com; s=arc-20160816;
        b=EiT40VpXfsiAQpN29+OUF/uqTThXyVyMXLLQ7vDlmol20lLSYmplYyYDBCaVnkpdM0
         fOZqP3Qe0mKO+2ujYb/M7j0syn8NrhuAvvgovCkGpOxe1zMNK9E8FTllwGWHSITMF6BX
         Kqgu4+l4T62s7riFYFeBtmh9WibMa12qn3vCYp7R+nPCItzdBWzILkC2dwJFT2uG5i86
         T0xe4WGz8Uv4CEeoBQDtZ6U8JeAsY7xf8Y+v9ZMfjSboX3hg3WbjaFv327PI4WUYB672
         hfVk9OsQhQbs6mcJgwJBoU+E6wsqNYxesMs+ba1thQnc+fSy2M4ovYe/AoIVsA8CEXTF
         AtYA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=j68g3xP5dT/28mgpIBMlvTbOQ9yxyTPBgnuVizOxHf0=;
        b=eo6sxlW/DZFAxg3FfGV44FGr5XUVy6YuLJ6Kc211nnNxTZIs7aQ/NZzGTAn12YocWc
         6HoMdYFXGYQxclUFClddx2wPB9z1A/1/0kLDYI5p+Hi0NcD/4cqfni3U+fQhnzYkIiEa
         qKvH3mBU00BraxykVxDC3B4t1uJ5a5qoILJU5Lf65IW3ByTNzWc5w4D3oalHIUcPMHdt
         PAt91Qs0r5l/m2N8ExtkcgMEhdRMP/QtNKLmeMKenSIR6Nv/HMAHCsXm4oZ7vKaSlsn3
         mp22H6Q1xSG7K5MEwGkw4AE02MdGIM99C7A8N80SstsFQX7S/w2LK2lqejldwQsa4SZW
         8WIg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=fa2mh0NB;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id 73si4159395pgg.72.2019.07.18.21.10.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Jul 2019 21:10:40 -0700 (PDT)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=fa2mh0NB;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 40A812189D;
	Fri, 19 Jul 2019 04:10:39 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1563509440;
	bh=ijB9av6DrhXc91gE0CblfZ+XGFXvzBrHZFhDPDU0TSY=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=fa2mh0NBTzgVUViCTt0xQn7pOM6ks0nfM1KlK6YYkd3jCX006jol5FWGGUUoN/1ZU
	 i4TSEriVd2qsgg+rnmzn/L30Osc19Os+IJLXqGPgNZD/IhCa1glfrVHHbY8JVJy+ol
	 SjUzsGdr/YzimEGg8id3aurvwnTVnglZfPlFZCzU=
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
Subject: [PATCH AUTOSEL 4.19 093/101] mm/mmu_notifier: use hlist_add_head_rcu()
Date: Fri, 19 Jul 2019 00:07:24 -0400
Message-Id: <20190719040732.17285-93-sashal@kernel.org>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190719040732.17285-1-sashal@kernel.org>
References: <20190719040732.17285-1-sashal@kernel.org>
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
index 82bb1a939c0e..06dedb175572 100644
--- a/mm/mmu_notifier.c
+++ b/mm/mmu_notifier.c
@@ -316,7 +316,7 @@ static int do_mmu_notifier_register(struct mmu_notifier *mn,
 	 * thanks to mm_take_all_locks().
 	 */
 	spin_lock(&mm->mmu_notifier_mm->lock);
-	hlist_add_head(&mn->hlist, &mm->mmu_notifier_mm->list);
+	hlist_add_head_rcu(&mn->hlist, &mm->mmu_notifier_mm->list);
 	spin_unlock(&mm->mmu_notifier_mm->lock);
 
 	mm_drop_all_locks(mm);
-- 
2.20.1

