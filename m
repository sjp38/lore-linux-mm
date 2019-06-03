Return-Path: <SRS0=ZkFZ=UC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,T_DKIMWL_WL_MED,USER_AGENT_GIT,
	USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 27835C28CC6
	for <linux-mm@archiver.kernel.org>; Mon,  3 Jun 2019 16:55:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D2759274E8
	for <linux-mm@archiver.kernel.org>; Mon,  3 Jun 2019 16:55:51 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="URpy1zkC"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D2759274E8
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 624586B026F; Mon,  3 Jun 2019 12:55:51 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 581B46B0270; Mon,  3 Jun 2019 12:55:51 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3FB526B0271; Mon,  3 Jun 2019 12:55:51 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f72.google.com (mail-ot1-f72.google.com [209.85.210.72])
	by kanga.kvack.org (Postfix) with ESMTP id 16A586B026F
	for <linux-mm@kvack.org>; Mon,  3 Jun 2019 12:55:51 -0400 (EDT)
Received: by mail-ot1-f72.google.com with SMTP id b64so6122383otc.3
        for <linux-mm@kvack.org>; Mon, 03 Jun 2019 09:55:51 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:in-reply-to:message-id
         :mime-version:references:subject:from:to:cc;
        bh=ZBmZ0AJkpI6Le2BTudY9LfSDHiJInTNRilsGVrjkAC4=;
        b=WBDbfIHuyjlKe9ZVujlTxntZ/G50jjVanPZIeYF7xCe2crBuuOQpnurw9I3bpzHUHa
         Mgsnj2tGwWKCdyXHVW86xVvgk0gEDVAQt3QokbgJ6HehMTZtx7MEnYeLX+Rg0a1ICudg
         9RVcREhQRaNmyvURsMhvgy8aPIlHx21DZFrVnm+Ovi5Vrqx2GiHEdEizisvbwWbGIzZe
         zPGZDjqsuK9VwaH6k5UuAl2RlEf6GLDYpA0z31GRBtyW2flc/QSYORQ+l71OU20iZAsf
         WES+LHr9TdM3czhGFlSAIhwYp9nvZXd4+/IA50xsmajNN8Dw4e/R/bTGBDiaw3jcXzgp
         /Qyw==
X-Gm-Message-State: APjAAAUg8qB+uLLT3gnrNOO3T8HTmsX8MyYAui8ZX0Kxar05Z8GHWDfJ
	enxUZFxsNLm8qvVepdJsjNgmWq4/vij6ovl8ifDJnsSa8RLXD9gNdpY7jVbIRx+PtElRw3MQSy0
	dJzdDOu1u7t4f24t7zdgQBMxAwC06TyDuAH8YIxugVnQ2fFgY5dUU7eG5klmr9uYp1g==
X-Received: by 2002:a9d:7147:: with SMTP id y7mr215130otj.152.1559580950755;
        Mon, 03 Jun 2019 09:55:50 -0700 (PDT)
X-Received: by 2002:a9d:7147:: with SMTP id y7mr215100otj.152.1559580950153;
        Mon, 03 Jun 2019 09:55:50 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559580950; cv=none;
        d=google.com; s=arc-20160816;
        b=Q8pFjxEIzaB3tu5v7rdwbfC5gc1oP1P5NATXOBLeLxTwHru4zB3Z0EfC5fsTH22jvy
         SOi/rmeMmLPwaiDiJl81UKj+8RHyUmSuu7ZhiPoQ92z5qqxktrev8NbTecekv2DH+5aX
         k7BzfPB5b7jDa55CKBixfwABS9FGbhm5hqjJbVyTMs9zrE2eLBeO5iCwypElFfBO11SF
         euNrBjDXCOIyMnM88oVS4Yerz4uBn2kvAFTK3I7q0mRb4zoFGFMjRUf8BHDiEAZVfIHQ
         CX8uj9uy7+LkzfdTRrovIoK8U3MYXTELlMGpVdGc5Tg8WazLUZCDXYrFp065C/FbAHut
         iikA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:references:mime-version:message-id:in-reply-to
         :date:dkim-signature;
        bh=ZBmZ0AJkpI6Le2BTudY9LfSDHiJInTNRilsGVrjkAC4=;
        b=ZxiHVX4AOvvUh9eZdNoq9aOtH6DrL8PTZN/OVeqA8pQ1m+KJBujNy+p6rmm3TE/R4X
         Zbpqctt60IzhqW54qW7U0CmKXF3V691p7TWWRZYfTzY/jvTpnLga8FpWp7dgoCf2e4G9
         E6OLH1Tvbe4HaYkgX+FO+Ojyo+RglnSE0uYYwMNavwh6ZBMi2JKuVxPMVNGCOksSMCJq
         zA6jg6Wx6gJb69dKuZXPN+OZKoIQQ3YzMjicQc3NRCvqy0RLhhW5B7kV8pQsPOFr5pW1
         4+T9DZcBj9YmpDIxMuM2aTZdeiDP3JAFHnXeQjdBtUI/Rb9iEagNqnPkvaD2j3nCfY0b
         glWQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=URpy1zkC;
       spf=pass (google.com: domain of 3fvh1xaokchoylbpcwiltjemmejc.amkjglsv-kkityai.mpe@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3FVH1XAoKCHoYlbpcwiltjemmejc.amkjglsv-kkitYai.mpe@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id d10sor5724388oih.81.2019.06.03.09.55.50
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 03 Jun 2019 09:55:50 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3fvh1xaokchoylbpcwiltjemmejc.amkjglsv-kkityai.mpe@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=URpy1zkC;
       spf=pass (google.com: domain of 3fvh1xaokchoylbpcwiltjemmejc.amkjglsv-kkityai.mpe@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3FVH1XAoKCHoYlbpcwiltjemmejc.amkjglsv-kkitYai.mpe@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:in-reply-to:message-id:mime-version:references:subject:from:to
         :cc;
        bh=ZBmZ0AJkpI6Le2BTudY9LfSDHiJInTNRilsGVrjkAC4=;
        b=URpy1zkCsiHDZT4QO7sl51daLEh3EGQ+QBRWhBXCE891aX0bBPmoAKSOA31jx1eR/L
         lVC6wRB0VJkhYxePvRUt+LMH36W5FFHQFgoa3GPev4OVYVi3rHZ7c3DIf31iffj+WRWq
         O/UwDncv5Fut/rLbuSahvZjC3AOwYT8i5PrP8W6A3ApbgszBZnpxe6Ijm9sVziVKebM1
         iMXDrWTNGRgrpGSzVkD4uXSftJythbi88SDUBif5NioLplX3HzpUrRyFyzSWH4dNAKRr
         WMIQ2F6id96lYcVo97o9s2zuDCTDHymNEv75yNnQamJ6cKIMShowZNQgGMTsd3D7DLBr
         FGuQ==
X-Google-Smtp-Source: APXvYqy+jD2zPLosNFGdbJ9ezUNMRGpcmbF5VcOnmGNGlPs/hbYWUHg1PJfAxR5NSiop2ABNMtv5Bkf3tC6COzAd
X-Received: by 2002:aca:4c3:: with SMTP id 186mr1626180oie.12.1559580949610;
 Mon, 03 Jun 2019 09:55:49 -0700 (PDT)
Date: Mon,  3 Jun 2019 18:55:10 +0200
In-Reply-To: <cover.1559580831.git.andreyknvl@google.com>
Message-Id: <51f44a12c4e81c9edea8dcd268f820f5d1fad87c.1559580831.git.andreyknvl@google.com>
Mime-Version: 1.0
References: <cover.1559580831.git.andreyknvl@google.com>
X-Mailer: git-send-email 2.22.0.rc1.311.g5d7573a151-goog
Subject: [PATCH v16 08/16] fs, arm64: untag user pointers in copy_mount_options
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

In copy_mount_options a user address is being subtracted from TASK_SIZE.
If the address is lower than TASK_SIZE, the size is calculated to not
allow the exact_copy_from_user() call to cross TASK_SIZE boundary.
However if the address is tagged, then the size will be calculated
incorrectly.

Untag the address before subtracting.

Reviewed-by: Catalin Marinas <catalin.marinas@arm.com>
Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
---
 fs/namespace.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/namespace.c b/fs/namespace.c
index b26778bdc236..2e85712a19ed 100644
--- a/fs/namespace.c
+++ b/fs/namespace.c
@@ -2993,7 +2993,7 @@ void *copy_mount_options(const void __user * data)
 	 * the remainder of the page.
 	 */
 	/* copy_from_user cannot cross TASK_SIZE ! */
-	size = TASK_SIZE - (unsigned long)data;
+	size = TASK_SIZE - (unsigned long)untagged_addr(data);
 	if (size > PAGE_SIZE)
 		size = PAGE_SIZE;
 
-- 
2.22.0.rc1.311.g5d7573a151-goog

