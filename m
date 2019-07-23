Return-Path: <SRS0=2U+7=VU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-17.4 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT,USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4B812C761A8
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 17:59:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0917B218A0
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 17:59:24 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="XwZfpnbX"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0917B218A0
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AC1818E000C; Tue, 23 Jul 2019 13:59:23 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A72678E0002; Tue, 23 Jul 2019 13:59:23 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8EBB18E000C; Tue, 23 Jul 2019 13:59:23 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 70D3C8E0002
	for <linux-mm@kvack.org>; Tue, 23 Jul 2019 13:59:23 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id x7so39141694qtp.15
        for <linux-mm@kvack.org>; Tue, 23 Jul 2019 10:59:23 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:in-reply-to:message-id
         :mime-version:references:subject:from:to:cc;
        bh=4Wn1GFyfxt3NCYf4PGNTFvqYM1MN1tNvgEFxNqktnk8=;
        b=ehu0SF9H7sKnJ8MLn2PFWfgGQ7WaKm+cMCFfy0QzeKrqEnq9Jin0bLO5+d0f6iRpOq
         dpsf7M6Gw+s+sH2qnkG2Mm2mRaXj7ukdMw/JsbdZ8dGn2Xa4isYBcGK1I41RKdk6+taA
         1NO3F+GmXzDIYmSadMkiLcw3+aOlxDzhf/dtQUvjir/Ct0OaEwQ0git7HXfuH5prQm1n
         iI7/y/HRJ32T/weuSV/AP9y7EBEfKTyujIQVrmCHtOb1K/66GUROzOiY9KDAHol6grJM
         bWH3g0l/Qxv0N+5OeWOscx1LS9nyMW5goGNtvTZ08RhLZNAnxyFX6dXlpOKNawT6mgBA
         xV1w==
X-Gm-Message-State: APjAAAW+udCRfheZw8FDVhcsaY0hmcOPCWl1YBKG30n8+cY6+krQDUEk
	sdUvYzrAfJnnJuG8+vlnJl6Wi/Rwbiyo53Ew/umkJVpikyRup3K1TUXU2lijOilSHLZQYCDHIGf
	w2/1TSCqc69FMH/RlP+aTmTBG6sJj0AwxULZBh0558eM6H4WYV43KcgxycZsnnZx1WQ==
X-Received: by 2002:a37:98c3:: with SMTP id a186mr51731249qke.498.1563904763233;
        Tue, 23 Jul 2019 10:59:23 -0700 (PDT)
X-Received: by 2002:a37:98c3:: with SMTP id a186mr51731239qke.498.1563904762727;
        Tue, 23 Jul 2019 10:59:22 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563904762; cv=none;
        d=google.com; s=arc-20160816;
        b=NJQVvp+6NIQfqglfp3UOd0GHyk8jGIEGokIUEiu9Il0MuTxZQUXQ0/SjM0wHJN8GzI
         gMyhub5UQ8howHIsN3VQ/Kz+Go8oui4UFThSMHlyxpYgjc2oVA/Dtn4Jlv3LOVtfGJEp
         RitNFwq2yXriZfQNH5nEgtRpOYqk8Bw391Ddyq/6dQL9q1XoEL/a0IqA/t1LBG4MSC3c
         Hng3PKm8MrffEEAvGos7MYw1x0aZ+aGQZ6jekl1+Z0CT6EiXSmjUAY4vAJlwdNPLNEwU
         zXDm9k6ZyCNMvJAlJtgSpdPSVAvUiTCrBDdClSlrnV2o4lUKXIDNJ3WOmiaYIB4qYuC/
         /SeQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:references:mime-version:message-id:in-reply-to
         :date:dkim-signature;
        bh=4Wn1GFyfxt3NCYf4PGNTFvqYM1MN1tNvgEFxNqktnk8=;
        b=jjYMdLUSDO7PFSXsfqQ+0HTWGU3Mm9mgGHwwFqqSFOg+8HIzh0ADpVMOzd/Kuj7gv+
         uJVEfYEE7gmr4B7vOI5aLGWO2gO9MoCDIWgsTkMRcXvXcqXKHcTJ5BcW5k+rQJS1Mjz1
         bQ2f4Ijo6VwtjGNHMTknQx0VxKM7ZNAveFUSEI/MgCl937Bi9kdPLKWQQEl5vygc6o4W
         +Bab8kPcTK1HgM2pFZAQtAzosCKc4fSzVbArHMbuENi1C1KY061inJAX5NZrmOFalO5T
         IHCYh1/YsioKnMr0b7IYNJ4tk+rp2gADC5nOagnjJCcztbHN1uGXNaBj7w3FEsYUw5Aw
         fBDA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=XwZfpnbX;
       spf=pass (google.com: domain of 3-ko3xqokcf05i8m9tfiqgbjjbg9.7jhgdips-hhfq57f.jmb@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3-ko3XQoKCF05I8M9TFIQGBJJBG9.7JHGDIPS-HHFQ57F.JMB@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id c73sor24926420qkb.105.2019.07.23.10.59.22
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 23 Jul 2019 10:59:22 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3-ko3xqokcf05i8m9tfiqgbjjbg9.7jhgdips-hhfq57f.jmb@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=XwZfpnbX;
       spf=pass (google.com: domain of 3-ko3xqokcf05i8m9tfiqgbjjbg9.7jhgdips-hhfq57f.jmb@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3-ko3XQoKCF05I8M9TFIQGBJJBG9.7JHGDIPS-HHFQ57F.JMB@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:in-reply-to:message-id:mime-version:references:subject:from:to
         :cc;
        bh=4Wn1GFyfxt3NCYf4PGNTFvqYM1MN1tNvgEFxNqktnk8=;
        b=XwZfpnbXFN1ibF12kJh4UX27GKqgHpAYVMgncvRg2XMsGuyHBAM2BbcbV2FMLG6KI2
         Eail8AtVvVEkdWyRNAKDAPdYJBEXOQRcSGAF4Z+pO2ORJP6spfMGKAIf7M0K0GlZ5J+x
         8yVEMOwDv+oyp2b+30vvjnV2SNVEvVcKU1T+4yjg+W1ok7J01teWzQ68jS7jmU8ro/kC
         Oxn9FlCYKBVtK3Jwi5MWr/zhUNuljezL1OPreJbqbiZZtnxrZ1CQ3LvL2shMV2iJ2vVT
         olnzEJp2mTvJs0fngbdCdc/sbDwJUI9/28M468SMn/xpTOjrRZ2LIWF7gDkmDS+GMcl9
         Q1sg==
X-Google-Smtp-Source: APXvYqy0Hkccu8SUSwSAcf0RwepBseg9rSnBcrNaRpXVNhE8d6jRb6uSi4vWmbN3MkxTqVVfEdk8tSl4b+EbX0xe
X-Received: by 2002:a37:4f47:: with SMTP id d68mr50765232qkb.104.1563904762211;
 Tue, 23 Jul 2019 10:59:22 -0700 (PDT)
Date: Tue, 23 Jul 2019 19:58:42 +0200
In-Reply-To: <cover.1563904656.git.andreyknvl@google.com>
Message-Id: <4731bddba3c938658c10ff4ed55cc01c60f4c8f8.1563904656.git.andreyknvl@google.com>
Mime-Version: 1.0
References: <cover.1563904656.git.andreyknvl@google.com>
X-Mailer: git-send-email 2.22.0.709.g102302147b-goog
Subject: [PATCH v19 05/15] mm: untag user pointers in mm/gup.c
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

This patch is a part of a series that extends kernel ABI to allow to pass
tagged user pointers (with the top byte set to something else other than
0x00) as syscall arguments.

mm/gup.c provides a kernel interface that accepts user addresses and
manipulates user pages directly (for example get_user_pages, that is used
by the futex syscall). Since a user can provided tagged addresses, we need
to handle this case.

Add untagging to gup.c functions that use user addresses for vma lookups.

Reviewed-by: Khalid Aziz <khalid.aziz@oracle.com>
Reviewed-by: Vincenzo Frascino <vincenzo.frascino@arm.com>
Reviewed-by: Kees Cook <keescook@chromium.org>
Reviewed-by: Catalin Marinas <catalin.marinas@arm.com>
Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
---
 mm/gup.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/mm/gup.c b/mm/gup.c
index 98f13ab37bac..1c1c97ec63df 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -799,6 +799,8 @@ static long __get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
 	if (!nr_pages)
 		return 0;
 
+	start = untagged_addr(start);
+
 	VM_BUG_ON(!!pages != !!(gup_flags & FOLL_GET));
 
 	/*
@@ -961,6 +963,8 @@ int fixup_user_fault(struct task_struct *tsk, struct mm_struct *mm,
 	struct vm_area_struct *vma;
 	vm_fault_t ret, major = 0;
 
+	address = untagged_addr(address);
+
 	if (unlocked)
 		fault_flags |= FAULT_FLAG_ALLOW_RETRY;
 
-- 
2.22.0.709.g102302147b-goog

