Return-Path: <SRS0=pZwQ=TG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.5 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,T_DKIMWL_WL_MED,USER_AGENT_GIT,USER_IN_DEF_DKIM_WL
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E3584C04AAB
	for <linux-mm@archiver.kernel.org>; Mon,  6 May 2019 16:31:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8F96A2087F
	for <linux-mm@archiver.kernel.org>; Mon,  6 May 2019 16:31:31 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="lVlAxmmY"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8F96A2087F
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E26946B026B; Mon,  6 May 2019 12:31:29 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E00A36B026C; Mon,  6 May 2019 12:31:29 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C9E966B026D; Mon,  6 May 2019 12:31:29 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id ACAC36B026B
	for <linux-mm@kvack.org>; Mon,  6 May 2019 12:31:29 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id w34so15834736qtc.16
        for <linux-mm@kvack.org>; Mon, 06 May 2019 09:31:29 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:in-reply-to:message-id
         :mime-version:references:subject:from:to:cc;
        bh=TZHV8An4OEXfkqFgrZuDjdlNeU7w3PdkPz1ZU4+cbAs=;
        b=th1j8U7Sa1deDPiHFvQ1Ju9XnH1oN43uaMgFG3sHRm0iXVrrWXo2EN97OgLCYzRpBq
         /0PZ3bx6FAWgdlsGYcrXZxkkUFrBZ88j89GNzW5ve108/fC38vmcz22ccBEIdKQjFtmJ
         PxmL+Cqy2zV6avaYoYLvk2xGs7kRoQxe1P0qRFvSkLw+aCdGwT0FuVH2YGT7EXOsE2JC
         j+nTgmpXG/93aA30eEk/RYpptztkAdQzmJYZA5RFeS/SJbd5NTLVmV5WcSDBEOQmBViO
         sjce2gIZy13sOTrHrvBA+HEiojkPKWoBkxPs+H+q9V281HWTt34ZZuLypwQBkR8KiJyA
         s1+g==
X-Gm-Message-State: APjAAAXn8kcaXtjADZMoTjHfDkw26SCXRPBykekvQ+KedoQsYjlQZ0JR
	XkmimSNeo1H6mACwIctxXJQH7GC2IiVyty4SwG4/8VlwBU7/YkSyt/YlLKL1KwpP0CshsTIvG9G
	duqxAx9p8rVnT5ma8xmaNKwjmOlXLgplbmN6XG2uTmhzAKkG4Xoz3MPKeFP79VW5AsQ==
X-Received: by 2002:a37:6445:: with SMTP id y66mr6912447qkb.102.1557160289477;
        Mon, 06 May 2019 09:31:29 -0700 (PDT)
X-Received: by 2002:a37:6445:: with SMTP id y66mr6912400qkb.102.1557160288894;
        Mon, 06 May 2019 09:31:28 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557160288; cv=none;
        d=google.com; s=arc-20160816;
        b=q1kwslD6Zz0oGf4gPOaT7X5lXmUOdXyG0SK83N8zwLvpTsCS4Yc+xhXR43VOT8XeQv
         cm1eji9hib6w3v+OLuRHBr61dNQ2Ir60aJDv1qAJn41WHO6n7po5325s9N9WiGYRj4I7
         6/+XBihN0dcK/fZgNNlOEMbsJcp3dGFaCck3JW2Dt6iigsrzpciIJQf+Cfs7ancJwA7b
         qPJ7kyS/Go8lN85Qqv8k7ZgwzD/1kfrufMNDGe5AB0NIoxJqe6Z6C5RuQm5Aa2crB2Tj
         VqmBCZE/PsTrXXMyjPls8FQm5+EaCH6fBm20LjDiFKVr8+bPZDRI5+b2QxwYUGal4+3m
         vTgg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:references:mime-version:message-id:in-reply-to
         :date:dkim-signature;
        bh=TZHV8An4OEXfkqFgrZuDjdlNeU7w3PdkPz1ZU4+cbAs=;
        b=Xet9jD0Lem4HK9MMXCNmSWhpk2ed6IZMbUcJGA+OiBvrI3CNdY6ot2CcPUanTyIXNR
         CG0FEk4NcbjC/hH5JvjPtZAg1uHzRypbCY+dNdrqWnMUnV79mx2rJQxFp2OGf06S3ZdK
         CDQ14thOHDIhAP0jiukLzgp4cWIuEqrpCubdso+0xZgI6Cbkapvjnxo73B8MOsUspVK+
         9bkh1oDGYm3jnmDS/5knuFh8t7n4DL117UTgBxeQRZpYJIIyRe2xSPgQaQ8N9k4m9IiT
         Iox9Y0pKm3RibV5AGMeE2tjkAIzIoaDk69QjaGvZtBni82d30kHCN39+5+3iMEoDqOv4
         Ee/A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=lVlAxmmY;
       spf=pass (google.com: domain of 3yghqxaokcfet6waxh36e4z77z4x.v75416dg-553etv3.7az@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3YGHQXAoKCFEt6wAxH36E4z77z4x.v75416DG-553Etv3.7Az@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id u47sor8732952qvf.70.2019.05.06.09.31.28
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 06 May 2019 09:31:28 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3yghqxaokcfet6waxh36e4z77z4x.v75416dg-553etv3.7az@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=lVlAxmmY;
       spf=pass (google.com: domain of 3yghqxaokcfet6waxh36e4z77z4x.v75416dg-553etv3.7az@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3YGHQXAoKCFEt6wAxH36E4z77z4x.v75416DG-553Etv3.7Az@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:in-reply-to:message-id:mime-version:references:subject:from:to
         :cc;
        bh=TZHV8An4OEXfkqFgrZuDjdlNeU7w3PdkPz1ZU4+cbAs=;
        b=lVlAxmmY4nFExOi7qcKMHLUyvk1dgMtcIDWsIxNnuOIKi7SENIWoorvqYx22FhFeiH
         qNv3aCOvVP2Cd8JsXC4f5fwupU4T2PFYzqayLiNCFI9HFlqX4lWPhufSiUZxYZlKJbSP
         xpayFPpaQpM+egkX1gh0HyRA3qPTTcL2EH50qtn8LLi1pPJilWqtH0/kYJiIyAq+8b8K
         r7XbnjhrPxJ/+aU0+7xAQJYRuQVqDAYCQIetrAi8pdeAX3hMSEX83RJtSz7KeAzNa4AL
         TEi4LWr1V919AH8PPG3nTQ8k7FsrBwYY7/UQoSLOaq/gIbNGSmHdWR4W58sdfzeJRSfR
         CtWg==
X-Google-Smtp-Source: APXvYqzHIfoRqtGD9gbf6U+p/ZZcVtiOU3rLeCD3rrtZumSW95xfAvgD6n9pasKaBp9DQWdRwfRV+d2riHaf6boR
X-Received: by 2002:a0c:d449:: with SMTP id r9mr16625749qvh.223.1557160288557;
 Mon, 06 May 2019 09:31:28 -0700 (PDT)
Date: Mon,  6 May 2019 18:30:53 +0200
In-Reply-To: <cover.1557160186.git.andreyknvl@google.com>
Message-Id: <d234cd71774f35229bdfc0a793c34d6712b73093.1557160186.git.andreyknvl@google.com>
Mime-Version: 1.0
References: <cover.1557160186.git.andreyknvl@google.com>
X-Mailer: git-send-email 2.21.0.1020.gf2820cf01a-goog
Subject: [PATCH v15 07/17] mm, arm64: untag user pointers in mm/gup.c
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
	Leon Romanovsky <leon@kernel.org>, Dmitry Vyukov <dvyukov@google.com>, Kostya Serebryany <kcc@google.com>, 
	Evgeniy Stepanov <eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>, 
	Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Jacob Bramley <Jacob.Bramley@arm.com>, 
	Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Robin Murphy <robin.murphy@arm.com>, 
	Luc Van Oostenryck <luc.vanoostenryck@gmail.com>, Dave Martin <Dave.Martin@arm.com>, 
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
2.21.0.1020.gf2820cf01a-goog

