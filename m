Return-Path: <SRS0=Ax9E=UL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.3 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT,
	USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 91210C31E4B
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 11:43:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 501FB215EA
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 11:43:54 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="ZYQEd649"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 501FB215EA
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EB1FE6B000A; Wed, 12 Jun 2019 07:43:53 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E396F6B000D; Wed, 12 Jun 2019 07:43:53 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D03C56B000E; Wed, 12 Jun 2019 07:43:53 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id AEE6D6B000A
	for <linux-mm@kvack.org>; Wed, 12 Jun 2019 07:43:53 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id w184so13510372qka.15
        for <linux-mm@kvack.org>; Wed, 12 Jun 2019 04:43:53 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:in-reply-to:message-id
         :mime-version:references:subject:from:to:cc;
        bh=lneYlz8LHaEiU1JdbWuWSlmR06MpCpkboyQbci6TbSY=;
        b=KKxpMhn3YuukOlp93Iz5UzTlyxDxXYu782Yjy5g7hfburfWy16aNOQshaugXyY3Wki
         jCoGF9dAAA7aCGufe3AxcVzcBHTJKKqZJ3VPZwOQoEl+cgWV/Lr0Cs6lElJfFbuk2xb3
         dt0dAjT9iBfGhVqhJl1tcrXFgtZR2z4tWh7ZV4QAu510SqNIsJX6W/F+Ln+rMNCyQ14V
         Pc8yImrcVCppW21/WAmYA843zZYFZHqUhx0xFccFF0HSCWllIODXgxaOr19UvubrWxHE
         cLgE+lIGrGnRog2vUOZpFF2uQDka+U6RMQWmge55/BSzD3jPbOwkLn0EQBfZOo7ryciB
         ULZw==
X-Gm-Message-State: APjAAAXdxVmL4aVU2VqEqmfcn7Gh7VALIJ57DYqA0oimqGXmD1tyKVA4
	xVToMbHP+DHSL+gaVPToyg2wCHqjiN7uxzEwMbI+CLzMnSpIndINCfBm4yzwP7oVJNMuPhkGJPB
	3j7kbKWSFK2Z1/vx66rycmVWppUDsopuYAlwu0F7k5XXk2oLtn0SsVZYHBsd1ojhrxg==
X-Received: by 2002:a37:5d44:: with SMTP id r65mr47491713qkb.221.1560339833497;
        Wed, 12 Jun 2019 04:43:53 -0700 (PDT)
X-Received: by 2002:a37:5d44:: with SMTP id r65mr47491684qkb.221.1560339833002;
        Wed, 12 Jun 2019 04:43:53 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560339832; cv=none;
        d=google.com; s=arc-20160816;
        b=mLMuAkHReGt0MOC+kJ3mUUBcZWMVJrEJB7TZkT+Da1HpA0qIx43s4Kiazyzocut5kU
         2cgEkM2Nx/MkENOWF0gKfmFChAfjrn4TTCgdYCaIjOpf+n1qxDZ+ycSgsROm9lWlmT/1
         mvMT9M2J5JguLVJt8Q18S7hdJ8tkcaanQfOY/yhPO2Na5Kr10dCROMGysQ/TwEnC3Rnz
         yBUZcNZnY6SJ2PwTad6TGtsj/R5Ihm/xEnsOIJBuflHcdLf7cwbJoOU75Wd6uMAQk41x
         PvNq0u06E7LJlOgq1jje+UKMInEgcKESTZ+S3diWn9osB2mRDmAuGzPfhf+umwtzFoXm
         YjbQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:references:mime-version:message-id:in-reply-to
         :date:dkim-signature;
        bh=lneYlz8LHaEiU1JdbWuWSlmR06MpCpkboyQbci6TbSY=;
        b=URC/oc1ad6eIy8UOVmiGemOUqNeaZYsrYLGbvW2As9ZtBFbJaLnx2qQLwL3auK0EDQ
         uAm+KNnKM9BEFv2Uh5F4m7g6RpK9WLhzP5kw2ueKJfhyso2zJZZ3Z0Wk1uJJj3uGApAb
         bpx+p0ZCzyOMwiZNYmA9W5j4LpetzRnyvLzHadKlsfHPAhztjcGpzlShpVFM6nuKK+Ul
         sgqpI6KaWHpnhk9CKb+NI4gbgT72MP/WHB6e53rowTJWX12hoZdfzjKjjgOvHdLKob4L
         r9wNFdnuzCwRX2mQfBekTVNLeFUiSeIj1I3tJT87xM7ajfQldFA8DfZNAMitQSqzEw3r
         kUdw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=ZYQEd649;
       spf=pass (google.com: domain of 3eouaxqokcdureuivpbemcxffxcv.tfdczelo-ddbmrtb.fix@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3eOUAXQoKCDUReUiVpbemcXffXcV.TfdcZelo-ddbmRTb.fiX@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id v203sor6904144qka.50.2019.06.12.04.43.52
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 12 Jun 2019 04:43:52 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3eouaxqokcdureuivpbemcxffxcv.tfdczelo-ddbmrtb.fix@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=ZYQEd649;
       spf=pass (google.com: domain of 3eouaxqokcdureuivpbemcxffxcv.tfdczelo-ddbmrtb.fix@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3eOUAXQoKCDUReUiVpbemcXffXcV.TfdcZelo-ddbmRTb.fiX@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:in-reply-to:message-id:mime-version:references:subject:from:to
         :cc;
        bh=lneYlz8LHaEiU1JdbWuWSlmR06MpCpkboyQbci6TbSY=;
        b=ZYQEd649LLsr0eo67tg5mBkc6yqoxRRkUvXmz72kCnd/9DceAYIH632RHTy/L9FYgN
         XB0cqiUT3202g16B44AOr6KGjUuUQCuOjjfhX/1rdyfTYvOLIoAOYVJQEyUECaYKw2EI
         wRT/I+bn5+fj2NWK1Uq2bsCtdk4XPg+CFAKbAVJ1PN2JQI+rUil/RmfEGI1P+fH7HVvB
         bi61I1IZdPLHbF9O0x6GFnVgN1H+PpiOuX7A6ltMyEW2b4fJxpc44OPAWrBW3bGwUHZL
         UOaZyEvgJIbhkL4J+WjiYsF7XS5CEf84amjDEh8dkaorHVY5qClgPk6YQHyQ5aqjEpT+
         PVjA==
X-Google-Smtp-Source: APXvYqycBZ/jgN95w1hvszVcRcdW7P9Dg7ub2DyBfBHGpLBHXa9MwJ+9kmDh7H9YZkcwArOGpwiZYJEXckCXcJ6D
X-Received: by 2002:a37:a5d5:: with SMTP id o204mr25506301qke.155.1560339832693;
 Wed, 12 Jun 2019 04:43:52 -0700 (PDT)
Date: Wed, 12 Jun 2019 13:43:22 +0200
In-Reply-To: <cover.1560339705.git.andreyknvl@google.com>
Message-Id: <8f65548bef8544d49980a92d221b74440d544c1e.1560339705.git.andreyknvl@google.com>
Mime-Version: 1.0
References: <cover.1560339705.git.andreyknvl@google.com>
X-Mailer: git-send-email 2.22.0.rc2.383.gf4fbbf30c2-goog
Subject: [PATCH v17 05/15] mm, arm64: untag user pointers in mm/gup.c
From: Andrey Konovalov <andreyknvl@google.com>
To: linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, 
	linux-kernel@vger.kernel.org, amd-gfx@lists.freedesktop.org, 
	dri-devel@lists.freedesktop.org, linux-rdma@vger.kernel.org, 
	linux-media@vger.kernel.org, kvm@vger.kernel.org, 
	linux-kselftest@vger.kernel.org
Cc: Catalin Marinas <catalin.marinas@arm.com>, Vincenzo Frascino <vincenzo.frascino@arm.com>, 
	Will Deacon <will.deacon@arm.com>, Mark Rutland <mark.rutland@arm.com>, 
	Andrew Morton <akpm@linux-foundation.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, 
	Kees Cook <keescook@chromium.org>, Yishai Hadas <yishaih@mellanox.com>, 
	Felix Kuehling <Felix.Kuehling@amd.com>, Alexander Deucher <Alexander.Deucher@amd.com>, 
	Christian Koenig <Christian.Koenig@amd.com>, Mauro Carvalho Chehab <mchehab@kernel.org>, 
	Jens Wiklander <jens.wiklander@linaro.org>, Alex Williamson <alex.williamson@redhat.com>, 
	Leon Romanovsky <leon@kernel.org>, Luc Van Oostenryck <luc.vanoostenryck@gmail.com>, 
	Dave Martin <Dave.Martin@arm.com>, Khalid Aziz <khalid.aziz@oracle.com>, enh <enh@google.com>, 
	Jason Gunthorpe <jgg@ziepe.ca>, Christoph Hellwig <hch@infradead.org>, Dmitry Vyukov <dvyukov@google.com>, 
	Kostya Serebryany <kcc@google.com>, Evgeniy Stepanov <eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>, 
	Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Jacob Bramley <Jacob.Bramley@arm.com>, 
	Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Robin Murphy <robin.murphy@arm.com>, 
	Kevin Brodsky <kevin.brodsky@arm.com>, Szabolcs Nagy <Szabolcs.Nagy@arm.com>, 
	Andrey Konovalov <andreyknvl@google.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This patch is a part of a series that extends arm64 kernel ABI to allow to
pass tagged user pointers (with the top byte set to something else other
than 0x00) as syscall arguments.

mm/gup.c provides a kernel interface that accepts user addresses and
manipulates user pages directly (for example get_user_pages, that is used
by the futex syscall). Since a user can provided tagged addresses, we need
to handle this case.

Add untagging to gup.c functions that use user addresses for vma lookups.

Reviewed-by: Kees Cook <keescook@chromium.org>
Reviewed-by: Catalin Marinas <catalin.marinas@arm.com>
Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
---
 mm/gup.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/mm/gup.c b/mm/gup.c
index ddde097cf9e4..c37df3d455a2 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -802,6 +802,8 @@ static long __get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
 	if (!nr_pages)
 		return 0;
 
+	start = untagged_addr(start);
+
 	VM_BUG_ON(!!pages != !!(gup_flags & FOLL_GET));
 
 	/*
@@ -964,6 +966,8 @@ int fixup_user_fault(struct task_struct *tsk, struct mm_struct *mm,
 	struct vm_area_struct *vma;
 	vm_fault_t ret, major = 0;
 
+	address = untagged_addr(address);
+
 	if (unlocked)
 		fault_flags |= FAULT_FLAG_ALLOW_RETRY;
 
-- 
2.22.0.rc2.383.gf4fbbf30c2-goog

