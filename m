Return-Path: <SRS0=QSbQ=V3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9172AC0650F
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 17:54:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 57D7E2089E
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 17:54:23 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="key not found in DNS" (0-bit key) header.d=codeaurora.org header.i=@codeaurora.org header.b="HhkLI3mn";
	dkim=fail reason="key not found in DNS" (0-bit key) header.d=codeaurora.org header.i=@codeaurora.org header.b="HhkLI3mn"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 57D7E2089E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=codeaurora.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C0DC88E000C; Tue, 30 Jul 2019 13:54:22 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BBE4B8E0001; Tue, 30 Jul 2019 13:54:22 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A86738E000C; Tue, 30 Jul 2019 13:54:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6FAFD8E0001
	for <linux-mm@kvack.org>; Tue, 30 Jul 2019 13:54:22 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id d190so41263339pfa.0
        for <linux-mm@kvack.org>; Tue, 30 Jul 2019 10:54:22 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:dmarc-filter:from
         :to:cc:subject:date:message-id;
        bh=zeF8/xIVDStEv2ZBDCCfoWWJXwtYX94jXKiOmwg+z8o=;
        b=e8YBn+CQjGUwjlChg1E7a+zFs/RTjZkjSMCTq9/Dn1xbkv9vJ8nXQjg05Sw6FGj1By
         zN8yTh15d6w60y6LoSOd36cHb6PU3a3S2+Jz7arCJXZh8UzVyoj09cKpqhISGIjssb5J
         PSzvcNNfzF1hFNKCM7Xzs9dZ3qtJQtjM3ZLK6mlJBE7ATROjDPuA6O3V/x4x6QhITj27
         JCHSI8nfeRpLCOdPwtiHYDPlcTzUKX3ApVCGQpgssbr/gsM33QvqnMuuRLIifFjzj4+P
         HjYWPUhVrxnc4W26xFdy0DCMuF06qAbMXqyr/QjS71CIL1/Yw8n7f+Ci9zEb7WHd6wvL
         G6+w==
X-Gm-Message-State: APjAAAUcv35Bopc8e6NN7ZCHJAjUv+c42D0kMOMJ/VcRFDOU2WDcmIaz
	Yo9yj9KTCaORjqUooWlEI87kh028GM5xEbnv4arTbsxZAQYp2Sf7KuXsm/Pufj+owEVF9WBiNcJ
	0CysGIeljiDA9yRTK8QnYSzaGgYuskUGHCbMpP8gta5Rsni1WCfaUk+Xw3zA+7J3WEw==
X-Received: by 2002:aa7:8641:: with SMTP id a1mr43252839pfo.177.1564509262069;
        Tue, 30 Jul 2019 10:54:22 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxKGajWpk2fdysShMYfkAeEuJlYUUUcSYmFLdDMwCD/c36l1sIrXrdKoVoxl6yP+m3vV9p6
X-Received: by 2002:aa7:8641:: with SMTP id a1mr43252806pfo.177.1564509261284;
        Tue, 30 Jul 2019 10:54:21 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564509261; cv=none;
        d=google.com; s=arc-20160816;
        b=yrNjdDX+T6bib4qhag8/sjCR5JZ1zOESBe8WdxU3s6U2I0TIYEexHfoadWMuxiQZj/
         q2fXER9d9pntNJTJqvVjEL08AmubZDKl1dJjN15B7O3wuSfpfcsG61YriP+bYezt9WHW
         i9i3e+ZI6UhsrW1owQ6HJOU0buKYfhvIODe6jC/zQMFvgWQZm3lKFlT8KCVRiVkZkyi3
         17TaSU02FjC/PU8p34jmpxec+bQqvP4eLNF9S5mOvGcKSIrmCUljxCaVhug7v2L99XqP
         bFmBauDpUUbJdmR7sPdzz+YTfu7N2dimCfyDGF/PGhx2Wuz/7oEDDEZNLhS1XEB0kFRK
         jMNQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from:dmarc-filter:dkim-signature
         :dkim-signature;
        bh=zeF8/xIVDStEv2ZBDCCfoWWJXwtYX94jXKiOmwg+z8o=;
        b=InFkDEg8ZgpjXZO/oe6FLfbEk/vSdgrXUoQJJsdQhL0pPmMJsv2nTJpzb9kFkGj3HM
         Xz0V/PX2ZCqdqFg0W2BzEENEUQ1dlxfSqcqDCGBcfC24jLViRTOiSsxB9cR9C5OFtiNv
         dzaw2W9dsyFSnfyXP3oc4SJeLP3+YFqiujy++ue8zZW377PvV4v5uDDNeyAYx/s4YVyc
         ffdPPB72Tf3dxqK3dh/VWF9pdeE+zDkpQcm8HFPwP+yw3Vcqo883H6E3gYBWUUKmODke
         fU/UM3JCWaLigZFcRzMYp6pLc1yWpP7BAIW4bdmpmnPLFX2vlJKqZRV9LSeWVagY1Uuk
         rzwA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@codeaurora.org header.s=default header.b=HhkLI3mn;
       dkim=pass header.i=@codeaurora.org header.s=default header.b=HhkLI3mn;
       spf=pass (google.com: domain of isaacm@codeaurora.org designates 198.145.29.96 as permitted sender) smtp.mailfrom=isaacm@codeaurora.org
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.29.96])
        by mx.google.com with ESMTPS id c19si31644030pfi.256.2019.07.30.10.54.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 30 Jul 2019 10:54:21 -0700 (PDT)
Received-SPF: pass (google.com: domain of isaacm@codeaurora.org designates 198.145.29.96 as permitted sender) client-ip=198.145.29.96;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@codeaurora.org header.s=default header.b=HhkLI3mn;
       dkim=pass header.i=@codeaurora.org header.s=default header.b=HhkLI3mn;
       spf=pass (google.com: domain of isaacm@codeaurora.org designates 198.145.29.96 as permitted sender) smtp.mailfrom=isaacm@codeaurora.org
Received: by smtp.codeaurora.org (Postfix, from userid 1000)
	id EFE4260736; Tue, 30 Jul 2019 17:54:20 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=codeaurora.org;
	s=default; t=1564509260;
	bh=SiHOslm33TKp3uM0b2CsOrfbOok3Z7O03LFNxQsXv/M=;
	h=From:To:Cc:Subject:Date:From;
	b=HhkLI3mnLCUAvo6B+gyuVgHIEoUFryU4bKpFS+qp4AwVZ3Ac7QNXZRSylqSO8lK/A
	 eLdYQt8nc/CJHzTfrqDVNiWy31besAPLEAzMofVSM3pmOcpq8yuyZHvmdrrfe/nYEd
	 g2Obgc+iVNjkBmpW/KOjhrJEY0XM3t+pA7ZtTxKk=
Received: from isaacm-linux.qualcomm.com (i-global254.qualcomm.com [199.106.103.254])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-SHA256 (128/128 bits))
	(No client certificate requested)
	(Authenticated sender: isaacm@smtp.codeaurora.org)
	by smtp.codeaurora.org (Postfix) with ESMTPSA id F3F9C60364;
	Tue, 30 Jul 2019 17:54:19 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=codeaurora.org;
	s=default; t=1564509260;
	bh=SiHOslm33TKp3uM0b2CsOrfbOok3Z7O03LFNxQsXv/M=;
	h=From:To:Cc:Subject:Date:From;
	b=HhkLI3mnLCUAvo6B+gyuVgHIEoUFryU4bKpFS+qp4AwVZ3Ac7QNXZRSylqSO8lK/A
	 eLdYQt8nc/CJHzTfrqDVNiWy31besAPLEAzMofVSM3pmOcpq8yuyZHvmdrrfe/nYEd
	 g2Obgc+iVNjkBmpW/KOjhrJEY0XM3t+pA7ZtTxKk=
DMARC-Filter: OpenDMARC Filter v1.3.2 smtp.codeaurora.org F3F9C60364
Authentication-Results: pdx-caf-mail.web.codeaurora.org; dmarc=none (p=none dis=none) header.from=codeaurora.org
Authentication-Results: pdx-caf-mail.web.codeaurora.org; spf=none smtp.mailfrom=isaacm@codeaurora.org
From: "Isaac J. Manjarres" <isaacm@codeaurora.org>
To: keescook@chromium.org,
	crecklin@redhat.com
Cc: "Isaac J. Manjarres" <isaacm@codeaurora.org>,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	gregkh@linuxfoundation.org,
	psodagud@codeaurora.org,
	tsoni@codeaurora.org,
	eberman@codeaurora.org,
	stable@vger.kernel.org
Subject: [PATCH] mm/usercopy: Use memory range to be accessed for wraparound check
Date: Tue, 30 Jul 2019 10:54:13 -0700
Message-Id: <1564509253-23287-1-git-send-email-isaacm@codeaurora.org>
X-Mailer: git-send-email 1.9.1
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Currently, when checking to see if accessing n bytes starting at
address "ptr" will cause a wraparound in the memory addresses,
the check in check_bogus_address() adds an extra byte, which is
incorrect, as the range of addresses that will be accessed is
[ptr, ptr + (n - 1)].

This can lead to incorrectly detecting a wraparound in the
memory address, when trying to read 4 KB from memory that is
mapped to the the last possible page in the virtual address
space, when in fact, accessing that range of memory would not
cause a wraparound to occur.

Use the memory range that will actually be accessed when
considering if accessing a certain amount of bytes will cause
the memory address to wrap around.

Fixes: f5509cc18daa ("mm: Hardened usercopy")
Co-developed-by: Prasad Sodagudi <psodagud@codeaurora.org>
Signed-off-by: Prasad Sodagudi <psodagud@codeaurora.org>
Signed-off-by: Isaac J. Manjarres <isaacm@codeaurora.org>
Cc: stable@vger.kernel.org
Reviewed-by: William Kucharski <william.kucharski@oracle.com>
Acked-by: Kees Cook <keescook@chromium.org>
---
 mm/usercopy.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/usercopy.c b/mm/usercopy.c
index 2a09796..98e92486 100644
--- a/mm/usercopy.c
+++ b/mm/usercopy.c
@@ -147,7 +147,7 @@ static inline void check_bogus_address(const unsigned long ptr, unsigned long n,
 				       bool to_user)
 {
 	/* Reject if object wraps past end of memory. */
-	if (ptr + n < ptr)
+	if (ptr + (n - 1) < ptr)
 		usercopy_abort("wrapped address", NULL, to_user, 0, ptr + n);
 
 	/* Reject if NULL or ZERO-allocation. */
-- 
The Qualcomm Innovation Center, Inc. is a member of the Code Aurora Forum,
a Linux Foundation Collaborative Project

