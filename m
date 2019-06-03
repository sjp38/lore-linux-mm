Return-Path: <SRS0=ZkFZ=UC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DC8D6C28CC7
	for <linux-mm@archiver.kernel.org>; Mon,  3 Jun 2019 09:11:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A453A27E66
	for <linux-mm@archiver.kernel.org>; Mon,  3 Jun 2019 09:11:56 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=linaro.org header.i=@linaro.org header.b="m8TntvGG"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A453A27E66
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linaro.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3D19C6B026D; Mon,  3 Jun 2019 05:11:56 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 35B2E6B026E; Mon,  3 Jun 2019 05:11:56 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 222FD6B026F; Mon,  3 Jun 2019 05:11:56 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lf1-f70.google.com (mail-lf1-f70.google.com [209.85.167.70])
	by kanga.kvack.org (Postfix) with ESMTP id AC1326B026D
	for <linux-mm@kvack.org>; Mon,  3 Jun 2019 05:11:55 -0400 (EDT)
Received: by mail-lf1-f70.google.com with SMTP id a25so3619315lfl.0
        for <linux-mm@kvack.org>; Mon, 03 Jun 2019 02:11:55 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:mime-version:content-transfer-encoding;
        bh=5XNaoGruNIsOtSVFYVpHUufh5QsS/no9n1jDse4Rp8w=;
        b=WCNqZP17uo/wUsdTR75ROwyTTa9OYNoHC8NFKCPnIevxkrp0GRi2VLVym4w+ZXsI1T
         ybovzXztYgJLD6kEa9f1lqkBJZb/13CkSB+zJpxCBCzJjvMjtGpHg917boYjbYIs1xbk
         F9JH2eVVjQ9IUAa0f1Go/7kbq+fSOw38Z9iEUk7p6Vy+E4jwpa4Jvi25cPxSwOV9Y88Q
         cJXSi/V5oy/Kz8THoURuCVP97EBErt1g12hzcZwKIlIT6pOuPXBmtM57cUC3kakx49k/
         ZSRu+FBXg1I3+uq7w6Sensf7+RW8N3wzdS0S1WnwmPpnvs/AQ64Q7EgP3QyG1viLiZhC
         2ocA==
X-Gm-Message-State: APjAAAV17pTmImDT3zfK3TVRfUvkArO1Jdot97Lb+vVHsgNOMvq6KtNf
	X3ORy1NXCoc8bp++OdzdPGsnz8RI1xE/kLcxqhZDm9ubLtw+w/TrSWbxrMbehYtbV6ZmWxngPxo
	oi0AHJwDyN8yYNKt8g3zP4mUmVVOBFXeiFwY85HCMLo4X3NdTXXGGbXJZ0eF86ERtgQ==
X-Received: by 2002:a2e:998b:: with SMTP id w11mr5859222lji.179.1559553115149;
        Mon, 03 Jun 2019 02:11:55 -0700 (PDT)
X-Received: by 2002:a2e:998b:: with SMTP id w11mr5859189lji.179.1559553114429;
        Mon, 03 Jun 2019 02:11:54 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559553114; cv=none;
        d=google.com; s=arc-20160816;
        b=DCkMlGPUOjJHwO1AcSjXA9uMgRsChOMQ6liKPBxoSRoQdgQPqZwTNQkmuZ9Wk1p6W/
         lvU6X/VaKDnW/tUYEQBGy1QEK60OxYgBWkUwxtwAqd1PvkdfVwmKgHgiWLfaycaPJhpX
         L8+JkbLIQGdAAYbYmSr73zirsAUt8q/T0mtbzVwNEktBViJpgtrxaHnwyCIkNtU4Jbx/
         mNVJRUZA5YekE3UftQmXAWiGHxziETqzYl/UBcpG+4M1caa/0CfMh/DqChITiEqiFxJx
         PmFiVS3/jyeb78cjlCxo5+iV4SVkaLbVLoFoRFJDHZnPBZcUQiIp31bmeW6s8Wwr8M01
         KTMQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:dkim-signature;
        bh=5XNaoGruNIsOtSVFYVpHUufh5QsS/no9n1jDse4Rp8w=;
        b=QYtkKCbTsGtn1hC/GBrNlumTsZCWs39jiqbzwm/W3kPtU2mdWQU+kSaphG52h9IJBU
         juH83g7dGrePNEr4NkAZ+lgwyyQNAkKrg8cr/8Y3QqTyUNPkz9zyKvs6ozT6zPbhbyse
         ti9t4XTLlGMwYmX+OxsDlJz8VylAvjWTDOpM2TRoffQy1zJ1THGoxUQomLf9KhVVynIH
         4sXlZCz6isrmBRFCeXMh+hKm9sLjxVF+UbcNZ//ajAj1UR3C9hDAF4OLc1dEPX+wo37S
         1tiO553nBYVIOQY+cQ+SQ0sWoPK0iswcmmZCBG/ls0XBWLk20Agx+n4cG3HzGkf28DAx
         nEGw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@linaro.org header.s=google header.b=m8TntvGG;
       spf=pass (google.com: domain of anders.roxell@linaro.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=anders.roxell@linaro.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=linaro.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j24sor746881ljg.21.2019.06.03.02.11.54
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 03 Jun 2019 02:11:54 -0700 (PDT)
Received-SPF: pass (google.com: domain of anders.roxell@linaro.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@linaro.org header.s=google header.b=m8TntvGG;
       spf=pass (google.com: domain of anders.roxell@linaro.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=anders.roxell@linaro.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=linaro.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=linaro.org; s=google;
        h=from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=5XNaoGruNIsOtSVFYVpHUufh5QsS/no9n1jDse4Rp8w=;
        b=m8TntvGGhp0nYiHzaLLgTeZH1zwY5/yRgl2nyz0ER5PyLel0dSm+tojV8of8NrYXdJ
         ROgD6B+fEUl11Un8LTOvnK0YL4ds+DV47qkf7zOGLYh6wdxK8n9kXbpwYFjBIFTlaFy/
         1uCrd7uKIBnt9W56O4f46yzLjALCSg0JRomG/rMTW7uDkv6GC/YbQkPUzHmGgxjnNee4
         wWqlpepwZGd3i5/tiyZxjndumPxjtBYxA3m6Dl7QX0egpCHIWc3oXuK9c5O9vXTH9ti9
         zVKRf77SGa+OKdPBJ//O0CfKalF8FMz9GDRFiOvoJffLCLwlwy+ccbi6HjbSDdJj4aVL
         M31g==
X-Google-Smtp-Source: APXvYqz0nK8j9w8+kGKqX2cJgLQC6n+s4vTFl2Evus/yUMhfrH/qQzL0327hx3BN5Ar4ER05Wijy9w==
X-Received: by 2002:a2e:984a:: with SMTP id e10mr5408494ljj.113.1559553114060;
        Mon, 03 Jun 2019 02:11:54 -0700 (PDT)
Received: from localhost (c-1c3670d5.07-21-73746f28.bbcust.telenor.se. [213.112.54.28])
        by smtp.gmail.com with ESMTPSA id y127sm3040022lff.34.2019.06.03.02.11.53
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 03 Jun 2019 02:11:53 -0700 (PDT)
From: Anders Roxell <anders.roxell@linaro.org>
To: aryabinin@virtuozzo.com
Cc: kasan-dev@googlegroups.com,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	tglx@linutronix.de,
	mingo@redhat.com,
	Anders Roxell <anders.roxell@linaro.org>
Subject: [PATCH] mm: kasan: mark file report so ftrace doesn't trace it
Date: Mon,  3 Jun 2019 11:11:48 +0200
Message-Id: <20190603091148.24898-1-anders.roxell@linaro.org>
X-Mailer: git-send-email 2.20.1
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

__kasan_report() triggers ftrace and the preempt_count() in ftrace
causes a call to __asan_load4(), breaking the circular dependency by
making report as no trace for ftrace.

Signed-off-by: Anders Roxell <anders.roxell@linaro.org>
---
 mm/kasan/Makefile | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/mm/kasan/Makefile b/mm/kasan/Makefile
index 08b43de2383b..2b2da731483c 100644
--- a/mm/kasan/Makefile
+++ b/mm/kasan/Makefile
@@ -3,12 +3,14 @@ KASAN_SANITIZE := n
 UBSAN_SANITIZE_common.o := n
 UBSAN_SANITIZE_generic.o := n
 UBSAN_SANITIZE_generic_report.o := n
+UBSAN_SANITIZE_report.o := n
 UBSAN_SANITIZE_tags.o := n
 KCOV_INSTRUMENT := n
 
 CFLAGS_REMOVE_common.o = $(CC_FLAGS_FTRACE)
 CFLAGS_REMOVE_generic.o = $(CC_FLAGS_FTRACE)
 CFLAGS_REMOVE_generic_report.o = $(CC_FLAGS_FTRACE)
+CFLAGS_REMOVE_report.o = $(CC_FLAGS_FTRACE)
 CFLAGS_REMOVE_tags.o = $(CC_FLAGS_FTRACE)
 
 # Function splitter causes unnecessary splits in __asan_load1/__asan_store1
@@ -17,6 +19,7 @@ CFLAGS_REMOVE_tags.o = $(CC_FLAGS_FTRACE)
 CFLAGS_common.o := $(call cc-option, -fno-conserve-stack -fno-stack-protector)
 CFLAGS_generic.o := $(call cc-option, -fno-conserve-stack -fno-stack-protector)
 CFLAGS_generic_report.o := $(call cc-option, -fno-conserve-stack -fno-stack-protector)
+CFLAGS_report.o := $(call cc-option, -fno-conserve-stack -fno-stack-protector)
 CFLAGS_tags.o := $(call cc-option, -fno-conserve-stack -fno-stack-protector)
 
 obj-$(CONFIG_KASAN) := common.o init.o report.o
-- 
2.20.1

