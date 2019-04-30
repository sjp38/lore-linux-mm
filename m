Return-Path: <SRS0=8Dof=TA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT,USER_IN_DEF_DKIM_WL
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id ADF29C43219
	for <linux-mm@archiver.kernel.org>; Tue, 30 Apr 2019 13:25:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6596121707
	for <linux-mm@archiver.kernel.org>; Tue, 30 Apr 2019 13:25:39 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="pHAUFUPI"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6596121707
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B773A6B0010; Tue, 30 Apr 2019 09:25:37 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B2B186B0266; Tue, 30 Apr 2019 09:25:37 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9815B6B0269; Tue, 30 Apr 2019 09:25:37 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vs1-f69.google.com (mail-vs1-f69.google.com [209.85.217.69])
	by kanga.kvack.org (Postfix) with ESMTP id 686796B0010
	for <linux-mm@kvack.org>; Tue, 30 Apr 2019 09:25:37 -0400 (EDT)
Received: by mail-vs1-f69.google.com with SMTP id z133so2346165vsc.8
        for <linux-mm@kvack.org>; Tue, 30 Apr 2019 06:25:37 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:in-reply-to:message-id
         :mime-version:references:subject:from:to:cc;
        bh=CVV6psz/Vns5azsm7jZt0BKocrzPfr2CsD5f51mITmQ=;
        b=gwiBKUke4D9C2tx/hJ9WjzZOsVUVZ675jcC0X/WVCofU5GmHhAilhjVhp6ke3ndqhc
         V28HNgRDxPhSy0zH/Azs7K8gCSewlS/kd4oWKOJC5WuSSGbEo/Iy1987b5uyBBVjdKlo
         MB4Sg5cAiK71HceFeTBkOWNaG6zB5EIeZEWaTjU121xxz+9H5OXxLtrmgkb2/rH59wue
         sQs6GHSwINqjSAErB/Wf446EeCIYgZdeTI9jdS255pL2MyTTVGf6wdh0elbTc6Oi3yrb
         l0mkpgNPSEnc06mHAjdUNEqMe6GY328TK+remYRTZOucrFmLito3c+GbRaRMt+EAoqKW
         hWBw==
X-Gm-Message-State: APjAAAUU79TugJVekG5gVqpuTa8fqHCCQHnKR7bXvRvUb4R7mFOPZHDl
	Ce+pZtZ7xpSKIpguEjDMh9CZm+GsBdDp+DhNPCaeY1PCcawRfpGJuoRYyqP9fOn1rv5K0dF+6ky
	6wCipEa7eu3ZJq0DfSomQIEf2pVMtivZEzvahL2xsRqU3DAE+BAzJlhvCWTaUa3NKig==
X-Received: by 2002:a1f:b4ce:: with SMTP id d197mr35597876vkf.57.1556630737089;
        Tue, 30 Apr 2019 06:25:37 -0700 (PDT)
X-Received: by 2002:a1f:b4ce:: with SMTP id d197mr35597842vkf.57.1556630736418;
        Tue, 30 Apr 2019 06:25:36 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556630736; cv=none;
        d=google.com; s=arc-20160816;
        b=Iq9RWWnrFgTHfN/4r39T50Y8gGlhzHbh2VI2L0n89EVByEp3AJwI87UrkmpYB7fAl0
         sDMtaVXdgCKzfELdwVqAuvGAF62SAtqRAAOdTSfrVVeu6PJB+B51KnMtCDIBcjkHP8rM
         rBiHtc1I/MdCgsD72voL3tdgXvK+mBfLanSN0AOuv40xe0ryR/ldecbp2KjTqZNQem1Q
         1lYqVM8gMNzjK4iyRNs86Yi/YvQPQNJ2W5l5W6qXUdZ7UnTHDNsAo5oa727IoGSTKGmE
         KAkgnOgF0SFVz2bwcxDhD+hQOV/ZIhXu8Z+PM3TAs3LH57ziC+b0PWiWoU1dvUuI9sko
         JTjA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:references:mime-version:message-id:in-reply-to
         :date:dkim-signature;
        bh=CVV6psz/Vns5azsm7jZt0BKocrzPfr2CsD5f51mITmQ=;
        b=nKl1qKRHrO4xPye83Zn9tOOWZxOWhwOlxnkvOQh/A+b4jXVycnoCpBygyWcvAkpi7r
         hLy00w32leazhN3fFKAt9uNCDs8kPcnUZW/yqhS5It/7OZ2z0Ik0CQXROhZm4oW/Tw+e
         oyTj8JmItLSQLdN+kSPla7RZSi73njSP0n+YRgWj3PWgPk6nEbTuJvPi0eMnHLkMiP4r
         /Zq832PoTdIWBTWv7Uyl/d1Ay/KXFKkJHoC7Bh3CxsllcmrRHdGZErDdWmYm0a60nBYg
         /v/CzTWd01bQQPUkO0658ltgNosJSpCjoOXjdGXQpCkawzJIx813P0rTeZca/W8DLq2w
         Bvqw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=pHAUFUPI;
       spf=pass (google.com: domain of 30ezixaokchcviymztfiqgbjjbgz.xjhgdips-hhfqvxf.jmb@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=30EzIXAoKCHcViYmZtfiqgbjjbgZ.Xjhgdips-hhfqVXf.jmb@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id f65sor4455312vsd.43.2019.04.30.06.25.36
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 30 Apr 2019 06:25:36 -0700 (PDT)
Received-SPF: pass (google.com: domain of 30ezixaokchcviymztfiqgbjjbgz.xjhgdips-hhfqvxf.jmb@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=pHAUFUPI;
       spf=pass (google.com: domain of 30ezixaokchcviymztfiqgbjjbgz.xjhgdips-hhfqvxf.jmb@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=30EzIXAoKCHcViYmZtfiqgbjjbgZ.Xjhgdips-hhfqVXf.jmb@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:in-reply-to:message-id:mime-version:references:subject:from:to
         :cc;
        bh=CVV6psz/Vns5azsm7jZt0BKocrzPfr2CsD5f51mITmQ=;
        b=pHAUFUPIK00HUvs8fYzbfMDhOtYuRZOYj18jl6SUOemiz8hMuVoEwpyBcBFZsdPfRy
         CP69mD/DWkxSBrhRr7+Ao/OQBLtynTBk0B9gn31tW8yWHjU69Q7PB4ZDpgvtdnhUTEzK
         8CbwpHg2uux/P91ru8mr0G2/NpJ+DVwloVARu7ft7n27vA6hkWJDGMY1mugB3YmYuyhT
         OwmXeDxT9woV4yHQlsAA+KWTEq0dG80iCwsoH+0J1dhKu1C33LiknxZR75he7h2J78XE
         ZKdvpYjQpomJrWqZzF9raVXk6z/lSdaqbAYdD0YzglrS0vRmztdJidedrkfiqCqRVd3N
         hnSw==
X-Google-Smtp-Source: APXvYqxbH0hW8IUGPJRsH+MKg4I9yJOI2DrUXBayHbDSUEVQsqLwVaAkxsd+/0KcP5RvItcIqz2adgVjyHXkB8kF
X-Received: by 2002:a67:dd01:: with SMTP id y1mr18718014vsj.39.1556630736057;
 Tue, 30 Apr 2019 06:25:36 -0700 (PDT)
Date: Tue, 30 Apr 2019 15:25:02 +0200
In-Reply-To: <cover.1556630205.git.andreyknvl@google.com>
Message-Id: <80f7d6a2f68adb1c41ef5baf8973537380c681b0.1556630205.git.andreyknvl@google.com>
Mime-Version: 1.0
References: <cover.1556630205.git.andreyknvl@google.com>
X-Mailer: git-send-email 2.21.0.593.g511ec345e18-goog
Subject: [PATCH v14 06/17] mm: untag user pointers in do_pages_move
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

do_pages_move() is used in the implementation of the move_pages syscall.

Untag user pointers in this function.

Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
---
 mm/migrate.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/mm/migrate.c b/mm/migrate.c
index 663a5449367a..c014a07135f0 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -1617,6 +1617,7 @@ static int do_pages_move(struct mm_struct *mm, nodemask_t task_nodes,
 		if (get_user(node, nodes + i))
 			goto out_flush;
 		addr = (unsigned long)p;
+		addr = untagged_addr(addr);
 
 		err = -ENODEV;
 		if (node < 0 || node >= MAX_NUMNODES)
-- 
2.21.0.593.g511ec345e18-goog

