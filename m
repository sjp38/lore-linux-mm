Return-Path: <SRS0=ZkFZ=UC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,T_DKIMWL_WL_MED,USER_AGENT_GIT,
	USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E129EC28CC6
	for <linux-mm@archiver.kernel.org>; Mon,  3 Jun 2019 16:56:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A03E0274E3
	for <linux-mm@archiver.kernel.org>; Mon,  3 Jun 2019 16:56:11 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="aMwQlO/u"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A03E0274E3
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 29BF56B0275; Mon,  3 Jun 2019 12:56:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 226246B0276; Mon,  3 Jun 2019 12:56:11 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 09F1D6B0277; Mon,  3 Jun 2019 12:56:11 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f72.google.com (mail-ot1-f72.google.com [209.85.210.72])
	by kanga.kvack.org (Postfix) with ESMTP id D5AF56B0275
	for <linux-mm@kvack.org>; Mon,  3 Jun 2019 12:56:10 -0400 (EDT)
Received: by mail-ot1-f72.google.com with SMTP id j19so9208525otq.12
        for <linux-mm@kvack.org>; Mon, 03 Jun 2019 09:56:10 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:in-reply-to:message-id
         :mime-version:references:subject:from:to:cc;
        bh=UdKHGBZnbXnYOdacGwXVLbo2mp7I3OpbNnEy2rn9dE0=;
        b=Z8hKcOImb/WfVstYincDNqx1U1gTKiggpCLLIyqhe3CbIRg9Aweh3PkEkL68kQw9+a
         c2Oy81pdV82TeVxLAe63Ttmu21QSr4ScppyZ8+6vCxXExq4Sc8mqyT2AtEEZiu/xOz4G
         UrA+thG9KKOkvX7frSoIUK3fv8qgxxCRNVdrUURduFFJFX15wZ4yVFIWsdMW/tuYrOJ5
         +S99Wc5LPjZqobxr4JdYlUVhqRdzh0NPhXHunxJjvbOP5cRg4XKqolAabQTrfSafxw3X
         nX+DnlZACxNhkXwYHXPwivRXFQLkTASDSBEX/LIuDRTlVMQVQ/wqfjfWBU4V32A2gFbN
         AIvA==
X-Gm-Message-State: APjAAAVU7TBeHxEyCrOmdDu62tZLyy3ll+/XncgcfUvwBZp7HsS/Prbw
	onOUh2Y3i7o3dj3zE3un7zGrAxvnWE7Syp/UOTqTk0JRErV/w4XqogLzVZ06wQifu2OMKljlNXX
	N8fy0RV1mlmKpak1KdGH5h6kujejCDanEQNVs4oROeT7+cb04+8HLq2QS5xMX1Z0oDQ==
X-Received: by 2002:a9d:6499:: with SMTP id g25mr1853188otl.184.1559580970586;
        Mon, 03 Jun 2019 09:56:10 -0700 (PDT)
X-Received: by 2002:a9d:6499:: with SMTP id g25mr1853164otl.184.1559580970082;
        Mon, 03 Jun 2019 09:56:10 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559580970; cv=none;
        d=google.com; s=arc-20160816;
        b=QmA9pR3kmAn8C/ORnY9L0dBv6TVYtfG8rryPdXThFWHDY4PPd2Q9iKcX1fHTc+Kn9Y
         xgUW840CdDYYt/fLtcLPUeMNQHHf140dzF6Fy11aU3onzZJUphdqV8d5Eb2zUiiFIEzh
         AFGsLfmQy/3emO6l1dJXgTS86MKS7GljOAVvsP2wWTylOxi7MWcfxlea/U2+eidYWtZw
         KTvv1Nw29UN+nFKMTfEHdNOKEK1TSUuYAjrxaJukMXGwh2ICMNKRrF6P3uOEEYuNaYXj
         CFi7znPGkGS0ygk6N0W366mCJ/bD8BimAfUkOvlY07zUAU7WLEHaflu8hYO/nW0HW5q7
         lzPA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:references:mime-version:message-id:in-reply-to
         :date:dkim-signature;
        bh=UdKHGBZnbXnYOdacGwXVLbo2mp7I3OpbNnEy2rn9dE0=;
        b=wBPbMAJ8h+kx0PjBdI6NCH1k8lnZrQR4lNDzfCZnm3WemLiNjvqkr6DM07ua565ED/
         pobuU0RnZkrMt9wptoG1knbJ/lGD+dWGF3QjFK4WGd68fWz8SUr2/XOVST7U8hiNxmqI
         a0kTZdJPxX687UtK2YNuTd8AGodqTYPswJEfaUh4mmqqFQzdYfGR4fqD9mk730QCfFHq
         DrcECqQyqoCbP+NML7UkP1Tkb/HXoxjHnO2AyZnZOpYdze1YhxYTxyf+cjT/w/lMbo1q
         3F3evZ0Ilto0pwKoRMF16SMyNeyNkb6zajXeqNUVHMiv14crFwpAr7OUYxc2R+B0JAoN
         nEFg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b="aMwQlO/u";
       spf=pass (google.com: domain of 3kvh1xaokci4s5v9wg25d3y66y3w.u64305cf-442dsu2.69y@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3KVH1XAoKCI4s5v9wG25D3y66y3w.u64305CF-442Dsu2.69y@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id x21sor1076601otq.43.2019.06.03.09.56.10
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 03 Jun 2019 09:56:10 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3kvh1xaokci4s5v9wg25d3y66y3w.u64305cf-442dsu2.69y@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b="aMwQlO/u";
       spf=pass (google.com: domain of 3kvh1xaokci4s5v9wg25d3y66y3w.u64305cf-442dsu2.69y@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3KVH1XAoKCI4s5v9wG25D3y66y3w.u64305CF-442Dsu2.69y@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:in-reply-to:message-id:mime-version:references:subject:from:to
         :cc;
        bh=UdKHGBZnbXnYOdacGwXVLbo2mp7I3OpbNnEy2rn9dE0=;
        b=aMwQlO/uqKNquhxQCaOybakc925QpZfJO8wh15xEZQIyCg72vlDGXrUg/ROAuoQDUD
         yCBHc/elg2gmmBaFllCt7o9fko/cMYEXNqMBN5Ib8jP974H6cgrFWFCLBOtmTziaRGQQ
         SwI/Xt1vXIDm1HuVmNbFHcArxU2bsmwx6xs/PbNEoDywCtOeBm47QoZ+wae08e7pzq/K
         a7mRKG2GqnFCVji4AY+94HQ5eVsYgsMp8E/PA4r/OPS0psFqvjDQbyz4YEbR/PgBj2Aq
         436HnabGuSm3Rvtg2LN9VhA8Rs2mRcn4xgL77EZC0LMuRu0EvZQAUUg9zFkbP9a8AWHr
         YN2w==
X-Google-Smtp-Source: APXvYqxMjN/4yHR2ThXEEFJeDuxNxY18SC+MmNXgYJ7rlNGji/L0sGyo9f6aEs2c6lSgFUC7mMKDb3c6mMlyiMDt
X-Received: by 2002:a9d:4109:: with SMTP id o9mr1768838ote.353.1559580969728;
 Mon, 03 Jun 2019 09:56:09 -0700 (PDT)
Date: Mon,  3 Jun 2019 18:55:16 +0200
In-Reply-To: <cover.1559580831.git.andreyknvl@google.com>
Message-Id: <dc3f3092abbc0d48e51b2e2a2ca8f4c4f69fa0f4.1559580831.git.andreyknvl@google.com>
Mime-Version: 1.0
References: <cover.1559580831.git.andreyknvl@google.com>
X-Mailer: git-send-email 2.22.0.rc1.311.g5d7573a151-goog
Subject: [PATCH v16 14/16] tee, arm64: untag user pointers in tee_shm_register
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

tee_shm_register()->optee_shm_unregister()->check_mem_type() uses provided
user pointers for vma lookups (via __check_mem_type()), which can only by
done with untagged pointers.

Untag user pointers in this function.

Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
---
 drivers/tee/tee_shm.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/tee/tee_shm.c b/drivers/tee/tee_shm.c
index 49fd7312e2aa..96945f4cefb8 100644
--- a/drivers/tee/tee_shm.c
+++ b/drivers/tee/tee_shm.c
@@ -263,6 +263,7 @@ struct tee_shm *tee_shm_register(struct tee_context *ctx, unsigned long addr,
 	shm->teedev = teedev;
 	shm->ctx = ctx;
 	shm->id = -1;
+	addr = untagged_addr(addr);
 	start = rounddown(addr, PAGE_SIZE);
 	shm->offset = addr - start;
 	shm->size = length;
-- 
2.22.0.rc1.311.g5d7573a151-goog

