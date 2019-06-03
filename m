Return-Path: <SRS0=ZkFZ=UC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,T_DKIMWL_WL_MED,URIBL_BLOCKED,
	USER_AGENT_GIT,USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2F621C282CE
	for <linux-mm@archiver.kernel.org>; Mon,  3 Jun 2019 16:55:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DBCB7274C8
	for <linux-mm@archiver.kernel.org>; Mon,  3 Jun 2019 16:55:44 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="eM3yvxS7"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DBCB7274C8
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6BB726B026D; Mon,  3 Jun 2019 12:55:44 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6454D6B026E; Mon,  3 Jun 2019 12:55:44 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4E81F6B026F; Mon,  3 Jun 2019 12:55:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 204996B026D
	for <linux-mm@kvack.org>; Mon,  3 Jun 2019 12:55:44 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id 37so8093618qtc.7
        for <linux-mm@kvack.org>; Mon, 03 Jun 2019 09:55:44 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:in-reply-to:message-id
         :mime-version:references:subject:from:to:cc;
        bh=8pgHCk5wEiyaTFCxwJKfncM1f+2WF9g+TqLFqNfWufQ=;
        b=c4CPXdq0RNhg1puIv09xLqmHoakkNciK39a3s9cwF1YeGGAyNhMTO7emNZSiwngvtu
         yUnlHK8ordTe0D4QeDvoFYjxA8va52izrUJzXGRR0KkU9ki7VT1+EJIrm7Cn0fc+BIPd
         uPL7YeK3XQ+RsUf77o+Iq7kJEkFRAfdJ/qGUEszxSIm8slosZIpizER3y+MqgGTQEYTN
         o6m1v9hpTf0FpMZ5trs/V0q7kyunZD3AeJ8iSwPWId5iUuIHjeEFvqAr1Veih2NNYNcH
         psNOL6MbvJLnE4/8X5Gu/dsJBWde1S7N8semMyV5YF3+K5Am5tByXKf6hMxl9EcxRKXa
         WKhA==
X-Gm-Message-State: APjAAAUUAyaQs1mBgoEZxfOQlfKAGJ3rW2rIFnI5Umnhz60ceRv3xrF2
	HRNysoM0s2AEBpshePl1gcYqW31hOkxmLVhwYQa0DGw50F/mhzOcKJvJ/ftvw4Fwaqsd3p2xSFr
	QGVYtbEOm3+ZiPYeznd8Vh55vCfzwTBT8FC/tnraAkLj2GgOLkvQwtnIu3f/rkoaLkw==
X-Received: by 2002:ac8:124c:: with SMTP id g12mr11477513qtj.57.1559580943870;
        Mon, 03 Jun 2019 09:55:43 -0700 (PDT)
X-Received: by 2002:ac8:124c:: with SMTP id g12mr11477473qtj.57.1559580943228;
        Mon, 03 Jun 2019 09:55:43 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559580943; cv=none;
        d=google.com; s=arc-20160816;
        b=DGZbfKQ0zJrM2C4IporOa5apF6wG/iVQARhAsGS1KPJEsm5i/EkhtuEvummtbnrvw0
         dYYX3PFsFa1mI53kRo3oSVLcQHv7XoXmJYcwdNJ0irv9A/5PTZ5iQIivkuTj0BKbLSp0
         ue7kqmF2XDhh6JVFu2GrrT1aChn2UuvXXmSKwHczb8XAss4SDLSRK5j36uqSHnvLeXED
         Q+d5JFqNHMLvuuTK2//Zm8G6tqMUUYNreK6vMHGfOB2csPvfJq9v7eCdpJBsceSdE2J1
         SPwg03XI1tHKP4onz+VMdbo1hoaSI6qzHD2fsRCsTFlWpBtUNa8yQNf0t69Arb1eurGS
         8z/Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:references:mime-version:message-id:in-reply-to
         :date:dkim-signature;
        bh=8pgHCk5wEiyaTFCxwJKfncM1f+2WF9g+TqLFqNfWufQ=;
        b=JfyGK5nf2kgK6ZyLoeBb+g0E243xSjA7GUDcQyc6ZOBf4MVBq02eQ3FukHvY+FHKo6
         vlrZ6uPbIhUCdbbH2+9IBA8xGjdfCfWXj1Gi/KnBg7CBTgAKcINMnkfNWCYzjVKvic2S
         cfeQn4nJK604gkcnNKJIOzEyhiTZFo7chdMlv3WhqS3R6DnrtcqEqcXubVSwCMtXGgVf
         Hj2ejiG+7qOlTKUdt93fZUb49YbNAt1Y6dT6+hnTUxEozqFe+VntA/T+EuZUOzpn5H3q
         ItFJurWWocuFVAzsFJ6ZxFbasOK4TYha2obYu8Z59BmLUsXD3Hxbbagc8Of7jnLg0LjH
         WR0w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=eM3yvxS7;
       spf=pass (google.com: domain of 3dlh1xaokchmreuivpbemcxffxcv.tfdczelo-ddbmrtb.fix@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3DlH1XAoKCHMReUiVpbemcXffXcV.TfdcZelo-ddbmRTb.fiX@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id t10sor1716917qvm.12.2019.06.03.09.55.43
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 03 Jun 2019 09:55:43 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3dlh1xaokchmreuivpbemcxffxcv.tfdczelo-ddbmrtb.fix@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=eM3yvxS7;
       spf=pass (google.com: domain of 3dlh1xaokchmreuivpbemcxffxcv.tfdczelo-ddbmrtb.fix@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3DlH1XAoKCHMReUiVpbemcXffXcV.TfdcZelo-ddbmRTb.fiX@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:in-reply-to:message-id:mime-version:references:subject:from:to
         :cc;
        bh=8pgHCk5wEiyaTFCxwJKfncM1f+2WF9g+TqLFqNfWufQ=;
        b=eM3yvxS7rzZ2nnFYrRtwMpVwIimBA7OeBVGUKG05qqQOYpi+Zis4iOHoCqOn+3sjDh
         2SabES8eFCAsnon36EZg8qxjmj+CW/08eSPui+O8M8q9qj9EihXzk/kg7mFnv1ofmO2L
         6gdrPpvdTVeWEXirSohkSFcGd3CTquZjzaE1d3uIrVhOjCiqBdkigRuAKI8/ID1Mi6ud
         zk8tRRsd3G4px7QGEmRqWs1oq4KZBZQ84TPIW2/PRqcP/P9TeozrBt0HPw3seUNx6jqU
         wgzokqzg3Z9TB08A/q6k7ggwnJy6GtgW83uc4Qh4qCVWwdITo0WCqdd0x9WCtndSuvUL
         /u8A==
X-Google-Smtp-Source: APXvYqyNatgo8rHVRn4VlhemarHIUF3AdcvyBy1EVpeL8RHKUhqmEsOqMc7TMbe6ArCDJ95BM6gVWf7qKnPTt9YN
X-Received: by 2002:a0c:9233:: with SMTP id a48mr6236042qva.66.1559580942841;
 Mon, 03 Jun 2019 09:55:42 -0700 (PDT)
Date: Mon,  3 Jun 2019 18:55:08 +0200
In-Reply-To: <cover.1559580831.git.andreyknvl@google.com>
Message-Id: <e1f6d268135f683fd70c2af27e75f694d7ffaf48.1559580831.git.andreyknvl@google.com>
Mime-Version: 1.0
References: <cover.1559580831.git.andreyknvl@google.com>
X-Mailer: git-send-email 2.22.0.rc1.311.g5d7573a151-goog
Subject: [PATCH v16 06/16] mm, arm64: untag user pointers in mm/gup.c
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
2.22.0.rc1.311.g5d7573a151-goog

