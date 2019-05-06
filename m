Return-Path: <SRS0=pZwQ=TG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.5 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,T_DKIMWL_WL_MED,USER_AGENT_GIT,USER_IN_DEF_DKIM_WL
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1A3B9C04AAE
	for <linux-mm@archiver.kernel.org>; Mon,  6 May 2019 16:31:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C38182087F
	for <linux-mm@archiver.kernel.org>; Mon,  6 May 2019 16:31:37 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="Q6QAvdDC"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C38182087F
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 526056B0270; Mon,  6 May 2019 12:31:36 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4AE4F6B0271; Mon,  6 May 2019 12:31:36 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 377566B0272; Mon,  6 May 2019 12:31:36 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 16D9E6B0270
	for <linux-mm@kvack.org>; Mon,  6 May 2019 12:31:36 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id k20so15881447qtk.13
        for <linux-mm@kvack.org>; Mon, 06 May 2019 09:31:36 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:in-reply-to:message-id
         :mime-version:references:subject:from:to:cc;
        bh=RiesdCLpp+R0f3O9XnLGGd6rw9hYPfKFlydZlXAyMMc=;
        b=tFjdZE5Sw5g5NiC0uLgecGSBstXWO0Oq2F1pgIXu0YS7BP24WeAGC4r6qYhxn1n/GY
         hyS61IPBY+ET3nwoeGIAgWMP6XfRnMYLjF2voY4icA9QREvmwD2+AC2zJilAhOCXDir/
         0RGKggNlXW751t4AS2Ey/uDcFZjWTNWN92LcbyL4vWXjyJUjmDX0FVve2zVVLeFDzv3L
         ehJUDBUWWzlWaawbRoBGs3qhO2HGdkYWd83VfAwqMlw97gb4uhTcdfjQXjnZ7FUEEdh9
         Z23b8ZgxepPjnPouykSCYW8ABqn+McTuDHWmrmwx8Z+JQtZ3UeMuEyDKcjfXju9wOq5w
         oUAw==
X-Gm-Message-State: APjAAAV2uQRBQ58+/OaxQSRO68GCBPpNqA5ZrEYZgP4OuCZqHY36oCkd
	sL8n7hOOQhPmlZ/ihhTJcQbEIHOGU0CbTw9j76QyvtcLO5i+MlorFVx7JqTz+EkThBGy5F8ALvP
	PgRmKAPiU3O+EVITK6l9yK0IDfEqSbnCygF84uWR0KHeKhdNAnuymSJw4+WT8wuMySw==
X-Received: by 2002:ac8:1119:: with SMTP id c25mr23084336qtj.165.1557160295840;
        Mon, 06 May 2019 09:31:35 -0700 (PDT)
X-Received: by 2002:ac8:1119:: with SMTP id c25mr23084278qtj.165.1557160295085;
        Mon, 06 May 2019 09:31:35 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557160295; cv=none;
        d=google.com; s=arc-20160816;
        b=JGhXZ+szAUQv51Or+CVMVbcOgqtiXERkXmRPrVjsDh9h25TP+ouQIccLfw2yU+Cu1E
         1UGhcJuiklXh/hnqg6fMXpaZS4pzclBDMLpIjn2aly7nbJExriRK+GDGDJNTsNYyz+4n
         1+FKoU5VMtpQQ8ODYtqnahidavWaVgrpRrdaCQQEHFS8DO85jMCoeQ44P/YsJoElbtM7
         bYcGYXUUn2vLm8WG9UJ7VtkZnx4ydcWpnlCj2Sf17YMRcR6L7PFk1ZpczlLeOyVRylix
         MDmhxBdVjmFvri/Ft5rrhDnbDdEQE92Vp4DP+gueO6juTiU3C2BDizFHiasU0QSVOIN8
         /FaQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:references:mime-version:message-id:in-reply-to
         :date:dkim-signature;
        bh=RiesdCLpp+R0f3O9XnLGGd6rw9hYPfKFlydZlXAyMMc=;
        b=wmlmfaH4VzwVou4CtNO/FJ0yF1pOCGaR1CMpY7iKM+cTbh5TTtPy+CY+7DsuxcIatq
         tTY6LmWX+EiN0rGUm8RnkKjyfpjv79yxkS01b/F59LWff0PVuPZUjnD4PsdOBcDo9gyy
         Wln2t7jurdgHpfv8ZNZJ1ZhhP4t4UWS263GEnD3N3PNAkX+IiI0bqHY6OM5zVUP3JEkS
         8AUFw4GwbfUE/6jEj4eW6eJplBTSkFBDBJioWKooSt3a/KycoYzZrBaeBZQQI9Zmh6t6
         /4BCnmJvAfEZCLBzooedE0FQkLgrFOzLhLNFIG5ghoaOhutQBS5lHc1Lavy1OK1/Yubt
         Aj2w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=Q6QAvdDC;
       spf=pass (google.com: domain of 3zmhqxaokcfczc2g3n9cka5dd5a3.1dba7cjm-bb9kz19.dg5@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3ZmHQXAoKCFczC2G3N9CKA5DD5A3.1DBA7CJM-BB9Kz19.DG5@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id m4sor6434015qkd.142.2019.05.06.09.31.35
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 06 May 2019 09:31:35 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3zmhqxaokcfczc2g3n9cka5dd5a3.1dba7cjm-bb9kz19.dg5@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=Q6QAvdDC;
       spf=pass (google.com: domain of 3zmhqxaokcfczc2g3n9cka5dd5a3.1dba7cjm-bb9kz19.dg5@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3ZmHQXAoKCFczC2G3N9CKA5DD5A3.1DBA7CJM-BB9Kz19.DG5@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:in-reply-to:message-id:mime-version:references:subject:from:to
         :cc;
        bh=RiesdCLpp+R0f3O9XnLGGd6rw9hYPfKFlydZlXAyMMc=;
        b=Q6QAvdDCFNZuLS9ja3NkrMR3RvJ0S09G7HKj9q0ktYjp11DSu6sbwte4Z+MCgpdXSa
         OGL0kcCil/ti4co+BeFvhTmmJ7+RXsHFsfK1hhHv1eec6VZbNopqVkjLet50ydoaeiwT
         XvmlmBaXIzsx1T6Dyaajg7Bz5pq9Axsw6cJNm2DtIdCFs4IeQzb8CYH1eWRXRhTqPi8L
         9AZ0ieEA2P7xzH+IK3hHC6FzJl7z9XjQD9wvxFqfvRNHuz4Kvz+PKDcTznem4kO3i/YF
         7eAO6TlPEh3PGwlYJ/3xngzxB39JPbQ+aqDHIcDB8TtrzW/euZk2kR1+K4+g3OqdGfdF
         qJTQ==
X-Google-Smtp-Source: APXvYqxNt6uYI1SB2jQypHitLB3ZO6cfBHn8QWvA0b8eMRqYbeBN0u2XyLJdNX/EJB3bCPY6PcnOySobJPUt2l9F
X-Received: by 2002:a37:9ed6:: with SMTP id h205mr2433459qke.152.1557160294772;
 Mon, 06 May 2019 09:31:34 -0700 (PDT)
Date: Mon,  6 May 2019 18:30:55 +0200
In-Reply-To: <cover.1557160186.git.andreyknvl@google.com>
Message-Id: <ac2ca3454b1ae8856ea2e29a1316fea50a30c788.1557160186.git.andreyknvl@google.com>
Mime-Version: 1.0
References: <cover.1557160186.git.andreyknvl@google.com>
X-Mailer: git-send-email 2.21.0.1020.gf2820cf01a-goog
Subject: [PATCH v15 09/17] fs, arm64: untag user pointers in copy_mount_options
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

In copy_mount_options a user address is being subtracted from TASK_SIZE.
If the address is lower than TASK_SIZE, the size is calculated to not
allow the exact_copy_from_user() call to cross TASK_SIZE boundary.
However if the address is tagged, then the size will be calculated
incorrectly.

Untag the address before subtracting.

Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
---
 fs/namespace.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/namespace.c b/fs/namespace.c
index c9cab307fa77..c27e5713bf04 100644
--- a/fs/namespace.c
+++ b/fs/namespace.c
@@ -2825,7 +2825,7 @@ void *copy_mount_options(const void __user * data)
 	 * the remainder of the page.
 	 */
 	/* copy_from_user cannot cross TASK_SIZE ! */
-	size = TASK_SIZE - (unsigned long)data;
+	size = TASK_SIZE - (unsigned long)untagged_addr(data);
 	if (size > PAGE_SIZE)
 		size = PAGE_SIZE;
 
-- 
2.21.0.1020.gf2820cf01a-goog

