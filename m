Return-Path: <SRS0=8wNw=XE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1240FC49ED9
	for <linux-mm@archiver.kernel.org>; Mon,  9 Sep 2019 18:12:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D199521924
	for <linux-mm@archiver.kernel.org>; Mon,  9 Sep 2019 18:12:27 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=soleen.com header.i=@soleen.com header.b="GJFu06c6"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D199521924
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=soleen.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5F9F56B0006; Mon,  9 Sep 2019 14:12:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 534DF6B0007; Mon,  9 Sep 2019 14:12:27 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 363806B0008; Mon,  9 Sep 2019 14:12:27 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0011.hostedemail.com [216.40.44.11])
	by kanga.kvack.org (Postfix) with ESMTP id 0AC946B0006
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 14:12:27 -0400 (EDT)
Received: from smtpin26.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 9EB4E181AC9AE
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 18:12:26 +0000 (UTC)
X-FDA: 75916177092.26.bird85_6c93478403f43
X-HE-Tag: bird85_6c93478403f43
X-Filterd-Recvd-Size: 4377
Received: from mail-qt1-f196.google.com (mail-qt1-f196.google.com [209.85.160.196])
	by imf42.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 18:12:25 +0000 (UTC)
Received: by mail-qt1-f196.google.com with SMTP id g13so16863413qtj.4
        for <linux-mm@kvack.org>; Mon, 09 Sep 2019 11:12:25 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=soleen.com; s=google;
        h=from:to:subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=KZlSM1+HYlx5AabYJySSHWoh4S6JQNg+E/eloF1WuIo=;
        b=GJFu06c6b4ZEhDQxac7Ve4vAwFHNQhisIoJMubb/W8uwe/MrKpZAsrxNQcd4Jt7g5J
         e4MiEhIHIZFc0CSkOjzAFJt5WxtVG7fjoQzEZfBjGiK4PnOzAQqYggmgip0rS3UjFkby
         IEn2kXuW+ZA/7BhqbRDUv0NteV9mBcLQei1106HP4bWY/NH2IzNUdo8DGHHYDUfIiLFz
         8gRB2ZS9V/MExaDThngqFosNAd/W335oiclHxgCS64sgHqkapgnUdv1u/sH0MsWHKKTe
         cC+q7016fokkyS14WHlyKW1VcDfYEHq13tZzXK/nNPIn+Cz4yS65A1M2qPE1C3bOZZf1
         4gFg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=KZlSM1+HYlx5AabYJySSHWoh4S6JQNg+E/eloF1WuIo=;
        b=GUGDLcdlctXcdmiuTzS3VD9APS9IM/wql8rIxG4OYnJJUZpIZGd+mk0qPK/152XcHd
         U7uvtawQNLRgTjgUV20vvKNoXWZmL3ptlaJY6xVNqWPEknMVg53+KHqH74k5CvLkigjO
         KShoZPII8ErLO4stYu+0JJMbLcyS3j3+ut+r/XRZINLDyF/Bdt2Bil7yOHnHrKRkGGyX
         VJN1qq4kk7aEVzVwYT71IiC/CQGcqDOgJm2vn1RCPp+CE+SaEFihxVvdQo+PjztgHCgB
         YGDb6wEiqUNiz1C8s3Ox6RtSI4JRVAGz61cqYwWN0ZNcGKCbjasM+waMnNU2tnx/Tp1d
         MaoQ==
X-Gm-Message-State: APjAAAUw+dOzEvWjTaUYeKUyVBuLScV4T/BFzXgar2Wbnqw/e+4btwce
	ZBUf7jWDQjPeRvVUFJYLR1LV9g==
X-Google-Smtp-Source: APXvYqwsApv+H9SarYLtc162JJu+MtiHP3Mrfk3gX2yiHqY711FHTOWynPIJ6PSuaanROg7YMihraA==
X-Received: by 2002:a0c:c15d:: with SMTP id i29mr15399213qvh.5.1568052745416;
        Mon, 09 Sep 2019 11:12:25 -0700 (PDT)
Received: from localhost.localdomain (c-73-69-118-222.hsd1.nh.comcast.net. [73.69.118.222])
        by smtp.gmail.com with ESMTPSA id q8sm5611310qtj.76.2019.09.09.11.12.24
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Mon, 09 Sep 2019 11:12:24 -0700 (PDT)
From: Pavel Tatashin <pasha.tatashin@soleen.com>
To: pasha.tatashin@soleen.com,
	jmorris@namei.org,
	sashal@kernel.org,
	ebiederm@xmission.com,
	kexec@lists.infradead.org,
	linux-kernel@vger.kernel.org,
	corbet@lwn.net,
	catalin.marinas@arm.com,
	will@kernel.org,
	linux-arm-kernel@lists.infradead.org,
	marc.zyngier@arm.com,
	james.morse@arm.com,
	vladimir.murzin@arm.com,
	matthias.bgg@gmail.com,
	bhsharma@redhat.com,
	linux-mm@kvack.org,
	mark.rutland@arm.com
Subject: [PATCH v4 01/17] kexec: quiet down kexec reboot
Date: Mon,  9 Sep 2019 14:12:05 -0400
Message-Id: <20190909181221.309510-2-pasha.tatashin@soleen.com>
X-Mailer: git-send-email 2.23.0
In-Reply-To: <20190909181221.309510-1-pasha.tatashin@soleen.com>
References: <20190909181221.309510-1-pasha.tatashin@soleen.com>
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Here is a regular kexec command sequence and output:
=3D=3D=3D=3D=3D
$ kexec --reuse-cmdline -i --load Image
$ kexec -e
[  161.342002] kexec_core: Starting new kernel

Welcome to Buildroot
buildroot login:
=3D=3D=3D=3D=3D

Even when "quiet" kernel parameter is specified, "kexec_core: Starting
new kernel" is printed.

This message has  KERN_EMERG level, but there is no emergency, it is a
normal kexec operation, so quiet it down to appropriate KERN_NOTICE.

Machines that have slow console baud rate benefit from less output.

Signed-off-by: Pavel Tatashin <pasha.tatashin@soleen.com>
Reviewed-by: Simon Horman <horms@verge.net.au>
---
 kernel/kexec_core.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/kernel/kexec_core.c b/kernel/kexec_core.c
index d5870723b8ad..2c5b72863b7b 100644
--- a/kernel/kexec_core.c
+++ b/kernel/kexec_core.c
@@ -1169,7 +1169,7 @@ int kernel_kexec(void)
 		 * CPU hotplug again; so re-enable it here.
 		 */
 		cpu_hotplug_enable();
-		pr_emerg("Starting new kernel\n");
+		pr_notice("Starting new kernel\n");
 		machine_shutdown();
 	}
=20
--=20
2.23.0


