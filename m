Return-Path: <SRS0=Ax9E=UL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 99C84C31E48
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 15:53:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6C43B21734
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 15:53:11 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6C43B21734
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=collabora.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 087556B0008; Wed, 12 Jun 2019 11:53:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0379B6B000A; Wed, 12 Jun 2019 11:53:10 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E69C76B000D; Wed, 12 Jun 2019 11:53:10 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id 9A5CB6B0008
	for <linux-mm@kvack.org>; Wed, 12 Jun 2019 11:53:10 -0400 (EDT)
Received: by mail-wr1-f71.google.com with SMTP id q2so7521168wrr.18
        for <linux-mm@kvack.org>; Wed, 12 Jun 2019 08:53:10 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version:content-transfer-encoding;
        bh=axgdTi9daKJriv+oESLEdY5xM2l66R7w4L8WWVtYGxI=;
        b=cinbew9n5cIIXPiVnIsQBIU94jlJ7Hv9q3JTxMyCz2789BF9xGjkW7jTZmGut2Qbvl
         WAiLotvGkiQd3kuk56PvYuFwfiDiwM3F7+z9mIWi0f7v0C6UsvMQDkDsaes2/aAAUARC
         nDVWbIdMl8ZH+o9yd14gNcSBZ/oLsJ+22Y5dhOYGR4hVcVMKqrrXRmqH74WWtHCV4+56
         Z5gchhrnaqtzqNxrSgOc5TPOodkkUfL6l5oQ28IBwNjsYEOpcnGzcpiPkI5I9jh81+pB
         yohaEdsKHu+dT2Srkq5A+WkGui9UVBXBt5h3HUOk8Vl5D0EoDqsuoBUVSSD+6arijHzT
         fFSA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of andrealmeid@collabora.com designates 46.235.227.227 as permitted sender) smtp.mailfrom=andrealmeid@collabora.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=collabora.com
X-Gm-Message-State: APjAAAUM7/k/8mwm2O8hM1FK1T8Gwz46jvr4BWeX+UbzrTMXSh3IFotM
	z1jNwxtRX6RUz7/bdjyBQeBMOOmUmfLJKeQNY3D/RyUFcJ1j0qo0xbpO1dzSZ/JS4r0gH6Id991
	+/p6A7RVeYFb2GqrUh12eMD+5OR4WSMHD5Z6E0pzaMxzNV8XM3X5HaklqRreYhUNljQ==
X-Received: by 2002:adf:f083:: with SMTP id n3mr26278120wro.316.1560354790145;
        Wed, 12 Jun 2019 08:53:10 -0700 (PDT)
X-Google-Smtp-Source: APXvYqziFZB9I/L3ABNpMXigKD0okov/btMkAUPo+W5lzLNrJbhPoowbV3gFI3xVH8jG9O3drUZy
X-Received: by 2002:adf:f083:: with SMTP id n3mr26278069wro.316.1560354789271;
        Wed, 12 Jun 2019 08:53:09 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560354789; cv=none;
        d=google.com; s=arc-20160816;
        b=wrKfRwiZjvdVCKlirlh9xsQmP9egZgc14WY+0AmvM1F+kCcnGm83MmmFyLaekL0YsT
         0EeCPsR0CGWL8wdHSg7dqyXQ//+0ocCGAYqu6Dq28kGnMN4RnDwlgBzwVxkI5jbN/jLV
         tkAdK3PssVCIPFqkb/ubjYVhHpRRBz1ee2Mxrp/rcCVzckuY2Z5WbxnfcJ9FgleEXhtc
         aUl7niUuFpAqhNI5Z4J49Gy7W+psmh1e074/K8ACbOUfqtdreIgzxY1/8HKTqgIhlbDt
         nwzmmBiugxXyYRXLL9lg6sM6M2EfOzF4SVVVo2LGMDBOHJrl3nI/gqE1rsU7KJaXbK9M
         YUdQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from;
        bh=axgdTi9daKJriv+oESLEdY5xM2l66R7w4L8WWVtYGxI=;
        b=c9beKvrT6E7bdF47QKQSm3/tQ7OgtHkt9HHmHJ0r1fYFG979zm2xQRkzsr+Uiy2qyI
         eNhY/prFFGEQlJll1Q9AtLrfJOjhIe+axblO6vglYJFKIKGAZAZLNM+/GKXFXdGF0mi3
         zCne3D4GVq4w9vn44/Lsnul1pUAAqj504QTQsxxbFefx+NmRftlwhyVgIOtSToIqw4Z5
         Iq7xt7LbfSK7mOx63UQAVTElpba+NzC2MCNUX61e+oO1Il6ADmh01APvfPNsuM5HK6jt
         +NjZjKNGov/82qYUbfb1czMp9455Ws1r+5qEslizjL9rpq4mBI8C47JlOf/SKlbqbNb7
         02pQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of andrealmeid@collabora.com designates 46.235.227.227 as permitted sender) smtp.mailfrom=andrealmeid@collabora.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=collabora.com
Received: from bhuna.collabora.co.uk (bhuna.collabora.co.uk. [46.235.227.227])
        by mx.google.com with ESMTPS id g3si167522wrx.391.2019.06.12.08.53.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 12 Jun 2019 08:53:09 -0700 (PDT)
Received-SPF: pass (google.com: domain of andrealmeid@collabora.com designates 46.235.227.227 as permitted sender) client-ip=46.235.227.227;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of andrealmeid@collabora.com designates 46.235.227.227 as permitted sender) smtp.mailfrom=andrealmeid@collabora.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=collabora.com
Received: from turingmachine.home (unknown [IPv6:2804:431:d719:d9b5:d711:794d:1c68:5ed3])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	(Authenticated sender: tonyk)
	by bhuna.collabora.co.uk (Postfix) with ESMTPSA id 57C692808F4;
	Wed, 12 Jun 2019 16:53:06 +0100 (BST)
From: =?UTF-8?q?Andr=C3=A9=20Almeida?= <andrealmeid@collabora.com>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org,
	catalin.marinas@arm.com,
	kernel@collabora.com,
	akpm@linux-foundation.org,
	=?UTF-8?q?Andr=C3=A9=20Almeida?= <andrealmeid@collabora.com>
Subject: [PATCH v2 1/2] mm: kmemleak: change error at _write when kmemleak is disabled
Date: Wed, 12 Jun 2019 12:52:30 -0300
Message-Id: <20190612155231.19448-1-andrealmeid@collabora.com>
X-Mailer: git-send-email 2.22.0
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

According to POSIX, EBUSY means that the "device or resource is busy",
and this can lead to people thinking that the file
`/sys/kernel/debug/kmemleak/` is somehow locked or being used by other
process. Change this error code to a more appropriate one.

Signed-off-by: André Almeida <andrealmeid@collabora.com>
---
Hello,

This time I've added the mailing list, not only the maintainers.

Changes in v2:
- Remove pr_error.
- Replace EINVAL for EPERM, since the command isn't invalid, in fact, the
user don't have the permission to trigger commands when kmemleak is
disabled.
- Reword the commit message to be clearer the rationale behind the
patch.

 mm/kmemleak.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/kmemleak.c b/mm/kmemleak.c
index 9dd581d11565..848333a591fa 100644
--- a/mm/kmemleak.c
+++ b/mm/kmemleak.c
@@ -1866,7 +1866,7 @@ static ssize_t kmemleak_write(struct file *file, const char __user *user_buf,
 	}
 
 	if (!kmemleak_enabled) {
-		ret = -EBUSY;
+		ret = -EPERM;
 		goto out;
 	}
 
-- 
2.22.0

