Return-Path: <SRS0=pZwQ=TG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.5 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,T_DKIMWL_WL_MED,USER_AGENT_GIT,USER_IN_DEF_DKIM_WL
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 86C29C04AAD
	for <linux-mm@archiver.kernel.org>; Mon,  6 May 2019 16:31:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3B86721655
	for <linux-mm@archiver.kernel.org>; Mon,  6 May 2019 16:31:55 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="hn4rH9KT"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3B86721655
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D892F6B0278; Mon,  6 May 2019 12:31:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D3AE56B0279; Mon,  6 May 2019 12:31:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C28C86B027A; Mon,  6 May 2019 12:31:48 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f197.google.com (mail-oi1-f197.google.com [209.85.167.197])
	by kanga.kvack.org (Postfix) with ESMTP id 971076B0278
	for <linux-mm@kvack.org>; Mon,  6 May 2019 12:31:48 -0400 (EDT)
Received: by mail-oi1-f197.google.com with SMTP id u135so4537870oia.2
        for <linux-mm@kvack.org>; Mon, 06 May 2019 09:31:48 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:in-reply-to:message-id
         :mime-version:references:subject:from:to:cc;
        bh=BvoYtYVsULamnYvbwO19c3h5oHA1gsMsAv5tZYbLYtI=;
        b=o5Hb+iBYEcWpRHLyoukdla7QmZE39kxizCEGNg7QEynm83CaLcRquQsezepv2Gr0l2
         nszIyvNelCYB6hUut29I+0GTG6YPujZQRW3HUYcF/cbdeh1UEFvKg5YA3fvIpnSq+pKe
         tcyMEBWnINbpvmosaOsrNKqVdIyBFXIDTIh7Px/ygQF8lMogc0039bJ+pf+5NBAQodYC
         utC+fBzMoE4nCK2UW84QByq7VbS/veJYaflYJoZa42n2PW7oN9U1FNaAJJOCrn4OhBhx
         Mx9auU637nWfezkrCceuNa8RL/rBQVBw55ik31uzMbQVlt7efcwafJeqgfCY26jiCvx9
         C13A==
X-Gm-Message-State: APjAAAVPHlTr50R39UgN+OKaY5H8XMuPczJRzy2rghipud8DO1Js359S
	8+rAw8CWFD6mhaUuZfoCkfKoMNouAP9EAZIhjN3hDIlEA7ZwoyFSRSRpSXTc2IGarYfAzHY8KbN
	M/pWc7KBV3nZtfnF6YhjVIdb2b6HdEYBnJax2hMeMQC9smQH2KkFm35y5QCO0M6ujrw==
X-Received: by 2002:a05:6830:140d:: with SMTP id v13mr18737370otp.293.1557160308327;
        Mon, 06 May 2019 09:31:48 -0700 (PDT)
X-Received: by 2002:a05:6830:140d:: with SMTP id v13mr18737340otp.293.1557160307694;
        Mon, 06 May 2019 09:31:47 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557160307; cv=none;
        d=google.com; s=arc-20160816;
        b=rjG29SDz7lu4UEPhiLOsTm4yWw/r48sVlJgziivubwsxcVYOynZhpaDrs2wyiDEEm+
         Yw033C27Ew/NOxg/Dv6X4KSC4XcjZ5lhOPgiXL58xiaPNRWal1JsjpR8CqAIvSbIjF62
         NOg/2AB6I+lHxASo0ojqSLlHb1rX5yZFADPjDqZRUAPT+GOlWL1COXXZgow8fpIq3iYq
         8rHtA609fDWJxdmIu1nh5sMhtTPqdt/rNxJXinX5nl+LqkOPl1iVDpzWUOhWydISpeUl
         KeX/ULYoaGKAlW7s6yOLJKj+zrFsANoQe2OLFdYUJWbnFQ7QN3E41GqWw7ywq9RGq6Fd
         MMqw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:references:mime-version:message-id:in-reply-to
         :date:dkim-signature;
        bh=BvoYtYVsULamnYvbwO19c3h5oHA1gsMsAv5tZYbLYtI=;
        b=VLvOlsw4SvHSPaEcQPeugMIbeeNGhsdQ7KSrdxfbt91x/bn2agIavwOqF+1WibsCqo
         kdMh6ZbUee0teZ6wHB7yB7qmRSvqDHaBCPR7X7cNJWvYPoYt8AgTdE68E60S5iYfD8Pz
         zIH7zd1KyqGpvAVO5GQ1XY7Elo6O2ouAzYQyBWORhFDlrClc9Z7O4vQJ/VKGHiwfvQey
         6T20sil/CzfoR06yd405vbOpYoFujY5+Oah4ENkcl+V9dxkEIb7UzO7tJFG68SyaO3Z4
         PjMxnT+xZYqIqj33c2PQmQcHrIfhsCBDoQHBGOtS8+6stGROmr6TabnmRE2c3DuFTwTQ
         KMLA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=hn4rH9KT;
       spf=pass (google.com: domain of 3c2hqxaokcgqcpftgampxniqqing.eqonkpwz-oomxcem.qti@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3c2HQXAoKCGQCPFTGaMPXNIQQING.EQONKPWZ-OOMXCEM.QTI@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id b2sor3704945otp.66.2019.05.06.09.31.47
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 06 May 2019 09:31:47 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3c2hqxaokcgqcpftgampxniqqing.eqonkpwz-oomxcem.qti@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=hn4rH9KT;
       spf=pass (google.com: domain of 3c2hqxaokcgqcpftgampxniqqing.eqonkpwz-oomxcem.qti@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3c2HQXAoKCGQCPFTGaMPXNIQQING.EQONKPWZ-OOMXCEM.QTI@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:in-reply-to:message-id:mime-version:references:subject:from:to
         :cc;
        bh=BvoYtYVsULamnYvbwO19c3h5oHA1gsMsAv5tZYbLYtI=;
        b=hn4rH9KTek8R37jjBWMcf/SnTi9wO6imyjbK43Qo3YFFy0w0QB9ppRC7K8TE7v3vlN
         nPLbzWoXhcOl9RZZTW0CT+GOCLOJRZHlTgH0IFE90/0mo3gA6Benvmv0xM9qlEM2L7iM
         a5/5EdryhXK5o1zmP38+JskPbuvRNi2KBDqgGoYwdgZckW/t0t3zXYlgA28tCgQWx38p
         zeMjQt/2TKtd8YWaOZqpDqkiV1tfPRGdf11R4Vmzgti01WpJ/ug4M22kRPfo4KNLvnrQ
         G8KQ2Dx3TZLoioP3vZYIMjrpzIYzmaefwwMqniR4qNzu+AscTWd9F/aHBCgCKh66bnIf
         LcNw==
X-Google-Smtp-Source: APXvYqy3zk1gAf1HD3ERPdP+fu/IbJWPYjnwXEpH7KM/4Kolrw9tSDmooPMwqXT4nvIVhZWlBkow5/TqTCzeTPOv
X-Received: by 2002:a9d:6008:: with SMTP id h8mr18251374otj.55.1557160307352;
 Mon, 06 May 2019 09:31:47 -0700 (PDT)
Date: Mon,  6 May 2019 18:30:59 +0200
In-Reply-To: <cover.1557160186.git.andreyknvl@google.com>
Message-Id: <66d044ab9445dcf36a96205a109458ac23f38b73.1557160186.git.andreyknvl@google.com>
Mime-Version: 1.0
References: <cover.1557160186.git.andreyknvl@google.com>
X-Mailer: git-send-email 2.21.0.1020.gf2820cf01a-goog
Subject: [PATCH v15 13/17] IB, arm64: untag user pointers in ib_uverbs_(re)reg_mr()
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

ib_uverbs_(re)reg_mr() use provided user pointers for vma lookups (through
e.g. mlx4_get_umem_mr()), which can only by done with untagged pointers.

Untag user pointers in these functions.

Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
---
 drivers/infiniband/core/uverbs_cmd.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/drivers/infiniband/core/uverbs_cmd.c b/drivers/infiniband/core/uverbs_cmd.c
index 062a86c04123..36e7b52577d0 100644
--- a/drivers/infiniband/core/uverbs_cmd.c
+++ b/drivers/infiniband/core/uverbs_cmd.c
@@ -708,6 +708,8 @@ static int ib_uverbs_reg_mr(struct uverbs_attr_bundle *attrs)
 	if (ret)
 		return ret;
 
+	cmd.start = untagged_addr(cmd.start);
+
 	if ((cmd.start & ~PAGE_MASK) != (cmd.hca_va & ~PAGE_MASK))
 		return -EINVAL;
 
@@ -790,6 +792,8 @@ static int ib_uverbs_rereg_mr(struct uverbs_attr_bundle *attrs)
 	if (ret)
 		return ret;
 
+	cmd.start = untagged_addr(cmd.start);
+
 	if (cmd.flags & ~IB_MR_REREG_SUPPORTED || !cmd.flags)
 		return -EINVAL;
 
-- 
2.21.0.1020.gf2820cf01a-goog

