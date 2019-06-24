Return-Path: <SRS0=9FL3=UX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.4 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT,USER_IN_DEF_DKIM_WL autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4D9A3C48BEA
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 14:33:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F394E208E4
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 14:33:23 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="icIOyvO3"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F394E208E4
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BC8CF8E000C; Mon, 24 Jun 2019 10:33:21 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B78E88E0002; Mon, 24 Jun 2019 10:33:21 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9F3158E000C; Mon, 24 Jun 2019 10:33:21 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ua1-f71.google.com (mail-ua1-f71.google.com [209.85.222.71])
	by kanga.kvack.org (Postfix) with ESMTP id 7E3D38E0002
	for <linux-mm@kvack.org>; Mon, 24 Jun 2019 10:33:21 -0400 (EDT)
Received: by mail-ua1-f71.google.com with SMTP id q25so1258522uar.17
        for <linux-mm@kvack.org>; Mon, 24 Jun 2019 07:33:21 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:in-reply-to:message-id
         :mime-version:references:subject:from:to:cc;
        bh=WdcdmcPYcZL0TsO1VpqXvB5XTsCD4Aa27drvhQYmelM=;
        b=bsFotfUoEI9MtuSMbGxpRnrMu+/cWvg7R8Duqmsr21c6MYn9ktiUGUcIdwpp1cEK7Z
         XtU1C+Rw6I1u/7awwqFLZq5cdsDsd4kw88+mwLt32AHRhOVjD3cFQ4w3OeCXhzjQcXKV
         2R24o6bu6kMuVjWs7yj8E3O6T7eBH7q3gTJX8LjwM/NAkyNxhbfJyclrWUdqf6gQ/7y7
         cLpx+aKdlWXAbQ1i3aTdkb3jy0uPw/Xu/ebmCCQ/UOgNrbf14FKUT13W8qJCrlsIcovg
         Pjs3Xx8/2FjfeLdJrr/ifk8JwnN5xqcwd8sy6FkKl/dz2FPxdMJFog+KR1xyhef/eGkD
         brvQ==
X-Gm-Message-State: APjAAAUbimaVc0ECPsqRWfrmvvUV46lVEiinlcOpHep0XTqL6gOH2ty3
	sR6T7wh+a9owsbPuCHcYhbsP0RcVt9THMUG95ZFjkFhARjf4EyoLfIetRm0cvCjfe5tDqbRt2Md
	D0co1b8/Am76EAtngr7IA6ERcCgHYCfEEJKRpl4Xtz5YL2WK1paxUCZG8FoK8FCIU1g==
X-Received: by 2002:a67:eb12:: with SMTP id a18mr33360379vso.119.1561386801171;
        Mon, 24 Jun 2019 07:33:21 -0700 (PDT)
X-Received: by 2002:a67:eb12:: with SMTP id a18mr33360326vso.119.1561386800354;
        Mon, 24 Jun 2019 07:33:20 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561386800; cv=none;
        d=google.com; s=arc-20160816;
        b=THkQgOYB4xFFv8UYt4a3s+edlw3s6pgfR+XX03yJcpOBfhQRiCHdC18+dtGAzaKcCv
         JSMEOW3A+g1j3kRQaOCSpqtjOHvVlo6sOfuayvW4Ws2rL/1uUIf/oCS/z2MQXxvCdE5J
         T0jcNZVdjr5H9iVnI7U5qOJJvWYi+gvEGYySlkJMFqF0oyRdjAZUn2Qoe8AUnVe8psQD
         oxcmTykYewD6kZZi5slyCBOdu6VgD+iT8TbJkOgGTxTWq0HRZ4h8Hq16KCfOu0vyZoqU
         hUxNU4voy8nttdj1kt3Eap/l8oHWlw+Qa0ib2xXtn46HpkLPESy0CRzteOjKEfG49vAK
         cpUQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:references:mime-version:message-id:in-reply-to
         :date:dkim-signature;
        bh=WdcdmcPYcZL0TsO1VpqXvB5XTsCD4Aa27drvhQYmelM=;
        b=tk+SaEzca+79qgLN66Y8oswzc8pmtDhVKXpWa8JRbIk5y91KqLWkETXnqkE8c66Nps
         MfvzeuTUTVr2xwNBhKthct+l/DrI02C4YAfDJ07A9GIFRFDujtEXLoPQn7wRpFlQXt2K
         L+opKC9oeNtYaV4+xrZYP3GwSMxOgGHbn1YhMjBr7oRk8qJvH3l+FftZOBtLwkOJHvDJ
         gkCmou1PdGTU8eccuBSffBeokrrZ8Lljb7MfMp8B4k9O7wthoeh4OJcaYgHfV+LHWNe7
         +QIXXtI+67JfSO1VAjsJQdMnhzdXlV+Mvooeyc/H58gx+k7/rbW9lkc2fAQi5ROKQaOd
         4fiw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=icIOyvO3;
       spf=pass (google.com: domain of 3l98qxqokcca6j9naugjrhckkcha.8kihejqt-iigr68g.knc@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3L98QXQoKCCA6J9NAUGJRHCKKCHA.8KIHEJQT-IIGR68G.KNC@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id f2sor3551636vkb.32.2019.06.24.07.33.20
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 24 Jun 2019 07:33:20 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3l98qxqokcca6j9naugjrhckkcha.8kihejqt-iigr68g.knc@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=icIOyvO3;
       spf=pass (google.com: domain of 3l98qxqokcca6j9naugjrhckkcha.8kihejqt-iigr68g.knc@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3L98QXQoKCCA6J9NAUGJRHCKKCHA.8KIHEJQT-IIGR68G.KNC@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:in-reply-to:message-id:mime-version:references:subject:from:to
         :cc;
        bh=WdcdmcPYcZL0TsO1VpqXvB5XTsCD4Aa27drvhQYmelM=;
        b=icIOyvO3zCCmb1V8FS7xfJSkpaqM0fPXCTMb8P53l/4sddyw376GFk7VntBpgH40Jb
         dlVT0eEdK1fq5jmQgL2mnnKbFXpBzrZuKvOPspNemignJXsBOcwCLAzIsieht3b/IonX
         6zR53XzWDMowl976raMoG4ND2r1RJIjiKAB3ytw9JQwx/injyU+afKGG9i0hRkWS9CDw
         EATvoJg1LGBCFewFDqj3C9titqpFuwNcjn3ZH++ykTRmRXVgWgXvHOfj+CupsqyAB/Yo
         cDDXvnZegW7qBTu946VpVm0cbCpkrGmZnjcy3KK2CuBZhA9rQZ6St5/hoz/kt5af2Epi
         DXZw==
X-Google-Smtp-Source: APXvYqyeP684NrNNIM3KhbFTQXwcDTrmwl6IHcjELxzf0coSdSlRrTjZ+0PmPJg+BCNxcMTgBBiBdQWJwdq50pfN
X-Received: by 2002:a1f:ccc4:: with SMTP id c187mr4784377vkg.56.1561386799794;
 Mon, 24 Jun 2019 07:33:19 -0700 (PDT)
Date: Mon, 24 Jun 2019 16:32:50 +0200
In-Reply-To: <cover.1561386715.git.andreyknvl@google.com>
Message-Id: <3f5c63a871c652369d3cf7741499d1d65413641c.1561386715.git.andreyknvl@google.com>
Mime-Version: 1.0
References: <cover.1561386715.git.andreyknvl@google.com>
X-Mailer: git-send-email 2.22.0.410.gd8fdbe21b5-goog
Subject: [PATCH v18 05/15] mm: untag user pointers in mm/gup.c
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
2.22.0.410.gd8fdbe21b5-goog

