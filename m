Return-Path: <SRS0=8Dof=TA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT,USER_IN_DEF_DKIM_WL
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C1CE0C04AA6
	for <linux-mm@archiver.kernel.org>; Tue, 30 Apr 2019 13:25:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 71DDF2075E
	for <linux-mm@archiver.kernel.org>; Tue, 30 Apr 2019 13:25:42 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="MSiPsDRD"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 71DDF2075E
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BC8866B0266; Tue, 30 Apr 2019 09:25:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id ADD2A6B0269; Tue, 30 Apr 2019 09:25:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9548F6B026A; Tue, 30 Apr 2019 09:25:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 719E96B0266
	for <linux-mm@kvack.org>; Tue, 30 Apr 2019 09:25:40 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id k8so11767950qkj.20
        for <linux-mm@kvack.org>; Tue, 30 Apr 2019 06:25:40 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:in-reply-to:message-id
         :mime-version:references:subject:from:to:cc;
        bh=buRPOjJBA3ZIe0xT2AqduI9dnmEg9opX2ORFfRDPnW0=;
        b=mullQ0qTZTQjO7s/FVd9z31tO3WNm3CMg5D0YQtaeSXtaIacUAxnpSf+SYKEC47nkp
         pcmkKhMbHq833vFeKDpcO7UCuhROgX8jMkK5czAlR00/KRfC1DvATrACSOtGIcUOGyiE
         mCMRHWUgaL/W0wLNIRpDIKFPfrJDgWY/RKdLKtlhCNQJ0LO0xW73wkNmjSlF2PA466zP
         5pfUwzz6pG43TAM6ZF7s1bW9U6IDQ4iAo6BwkeITCgumeXCL/WfGet4sMg9mz8BU/zDh
         Q/1OB5lo2ND5vptUvYZ+z5XdEoSkJqO4ftolNWgJrnZ4PCRws2uwHdCQIdELmdD0Jqm3
         cTaQ==
X-Gm-Message-State: APjAAAXXSCmscJiRl2/1ljjFHg2fZnME4MA17fCe0xPmIaJWbWAZreNk
	hKsyJ5LKQfToC9pNZebJXLawtmM4uO+Zv61CMcaY9kJ/uviI7aqdit7nge/ZxQEZGp/4QAR39mX
	67CfJOKXOJ9Do3OlRNWbsMaXMOOp7jY8Adi0Mc66tip+mJg+sQYO6DOy7x8FBEIK/9g==
X-Received: by 2002:ac8:8d4:: with SMTP id y20mr153849qth.13.1556630740193;
        Tue, 30 Apr 2019 06:25:40 -0700 (PDT)
X-Received: by 2002:ac8:8d4:: with SMTP id y20mr153792qth.13.1556630739529;
        Tue, 30 Apr 2019 06:25:39 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556630739; cv=none;
        d=google.com; s=arc-20160816;
        b=AF8/FCutlEJqJid9PZzKvT8r4cROacQa+tFOXPkgn1J6COr//aVe9g9a7OjSRXKalS
         FYCf/+EnCc5Fgp+rJL+UV++2rlb2qPQGuALKLC2/D4IvwLiBrEF0uFF7yI87XJt8Yo88
         tfgS/EsjzyD2VWC4xtJgJSfzA3vJVZ8P1lrVwK4RyJCs34wphww3D1gPXkZ3BOZ68AdN
         it9bdziHOembvYEvHs3N8kbH26F+xVLm4uRDz4EJsddrkO6ke5V7+cypShujdO6eyx+5
         FK7sie+aP4YxU9WKEkEa9jGU6EzgiIL/Ru6hg3hHzwi6yVTFC+d5VFYMP2E2tgxYqVN6
         VVtg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:references:mime-version:message-id:in-reply-to
         :date:dkim-signature;
        bh=buRPOjJBA3ZIe0xT2AqduI9dnmEg9opX2ORFfRDPnW0=;
        b=LB9tUOHHYPSsiYx9YbasjZBIuD1Bn24owIqKyZc2/AHJDGaBWKzXWpLP9plFHhsufu
         OIaO0B67jiCTWVPnfqtrtPY0Le81hh8JPToYEfqI3nTabhJN1c9CQFTHJ7MmG5Yoly+8
         F+EW32H0hV/jVjKWOoChxnd4Y0hjn8yK1BUPxhC3HjDjXlew/XAcFRklaAqPOIBojkbG
         ZCutdA+6ffkFl7GgXO+ENYYfff3KOUSfsY4STo5Cg9IOGvNAT7dGY9IOsdQ76eJUgFJM
         yIW+UGCfrmBNmYMPiKqS3Kl/7QOjKBTkd7PGZ9QRC7Ktnb9eAd1Rlqzjcvx7hbJ+0X/+
         LYjg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=MSiPsDRD;
       spf=pass (google.com: domain of 30kzixaokchkxkaobvhksidlldib.zljifkru-jjhsxzh.lod@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=30kzIXAoKCHkXkaobvhksidlldib.Zljifkru-jjhsXZh.lod@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id f17sor1537355qkg.127.2019.04.30.06.25.39
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 30 Apr 2019 06:25:39 -0700 (PDT)
Received-SPF: pass (google.com: domain of 30kzixaokchkxkaobvhksidlldib.zljifkru-jjhsxzh.lod@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=MSiPsDRD;
       spf=pass (google.com: domain of 30kzixaokchkxkaobvhksidlldib.zljifkru-jjhsxzh.lod@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=30kzIXAoKCHkXkaobvhksidlldib.Zljifkru-jjhsXZh.lod@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:in-reply-to:message-id:mime-version:references:subject:from:to
         :cc;
        bh=buRPOjJBA3ZIe0xT2AqduI9dnmEg9opX2ORFfRDPnW0=;
        b=MSiPsDRD20G5RApt1tKO2qR1lu+49IUxbNva1JnuQQuFWBLmYjGsyYMIbTfczh9PgZ
         LZDjXLLUSTuHLQNcWT+JZ9uqhm42MotSkIywGhSEtO5Qo/efiUjRdnETJ9HiPnIEMC0G
         Psfny8eMA3Hhr5M3y/dGxBagnarVCzNzCOPBE7unSjVZRyN7RZGPxN+EiQrIg6TYKayd
         TbH8puePOyzHgUDHu0r16X0QIZiy8sIilI5NkVuEFwagLhwm1Doy6sj5Nc20vSi1QEC6
         U4ZuKp24KxWFzfXdfPQJckkIwH9zeR4BqyMjbNu7gnM8XYqQKJF/hqcaAUToZRnS5F/8
         +rFw==
X-Google-Smtp-Source: APXvYqzAjOcf9MQ3Z/Pp48cxI+z95y8oMsVd6n1et+BqzlTkjxro8PcOOzrVkSjDVN6zaY8gkVAdj4JwROetfHnZ
X-Received: by 2002:a37:78f:: with SMTP id 137mr13240464qkh.66.1556630738975;
 Tue, 30 Apr 2019 06:25:38 -0700 (PDT)
Date: Tue, 30 Apr 2019 15:25:03 +0200
In-Reply-To: <cover.1556630205.git.andreyknvl@google.com>
Message-Id: <373d33e4cb0087da32ad019fd212414292ce04c8.1556630205.git.andreyknvl@google.com>
Mime-Version: 1.0
References: <cover.1556630205.git.andreyknvl@google.com>
X-Mailer: git-send-email 2.21.0.593.g511ec345e18-goog
Subject: [PATCH v14 07/17] mm, arm64: untag user pointers in mm/gup.c
From: Andrey Konovalov <andreyknvl@google.com>
To: linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, 
	linux-kernel@vger.kernel.org, amd-gfx@lists.freedesktop.org, 
	dri-devel@lists.freedesktop.org, linux-rdma@vger.kernel.org, 
	linux-media@vger.kernel.org, kvm@vger.kernel.org, 
	linux-kselftest@vger.kernel.org
Cc: Catalin Marinas <catalin.marinas@arm.com>, Vincenzo Frascino <vincenzo.frascino@arm.com>, 
	Will Deacon <will.deacon@arm.com>, Mark Rutland <mark.rutland@arm.com>, 
	Andrew Morton <akpm@linux-foundation.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, 
	Kees Cook <keescook@chromium.org>, Yishai Hadas <yishaih@mellanox.com>, Kuehling@google.com, 
	Felix <Felix.Kuehling@amd.com>, Deucher@google.com, 
	Alexander <Alexander.Deucher@amd.com>, Koenig@google.com, 
	Christian <Christian.Koenig@amd.com>, Mauro Carvalho Chehab <mchehab@kernel.org>, 
	Jens Wiklander <jens.wiklander@linaro.org>, Alex Williamson <alex.williamson@redhat.com>, 
	Leon Romanovsky <leon@kernel.org>, Dmitry Vyukov <dvyukov@google.com>, Kostya Serebryany <kcc@google.com>, 
	Evgeniy Stepanov <eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>, 
	Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Jacob Bramley <Jacob.Bramley@arm.com>, 
	Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Robin Murphy <robin.murphy@arm.com>, 
	Chintan Pandya <cpandya@codeaurora.org>, Luc Van Oostenryck <luc.vanoostenryck@gmail.com>, 
	Dave Martin <Dave.Martin@arm.com>, Kevin Brodsky <kevin.brodsky@arm.com>, 
	Szabolcs Nagy <Szabolcs.Nagy@arm.com>, Andrey Konovalov <andreyknvl@google.com>
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

Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
---
 mm/gup.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/mm/gup.c b/mm/gup.c
index 91819b8ad9cc..2f477a0a7180 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -696,6 +696,8 @@ static long __get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
 	if (!nr_pages)
 		return 0;
 
+	start = untagged_addr(start);
+
 	VM_BUG_ON(!!pages != !!(gup_flags & FOLL_GET));
 
 	/*
@@ -858,6 +860,8 @@ int fixup_user_fault(struct task_struct *tsk, struct mm_struct *mm,
 	struct vm_area_struct *vma;
 	vm_fault_t ret, major = 0;
 
+	address = untagged_addr(address);
+
 	if (unlocked)
 		fault_flags |= FAULT_FLAG_ALLOW_RETRY;
 
-- 
2.21.0.593.g511ec345e18-goog

