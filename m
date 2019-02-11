Return-Path: <SRS0=4tVm=QS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT,USER_IN_DEF_DKIM_WL
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 832CFC169C4
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 16:32:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3184A21773
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 16:32:11 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="resTFMXs"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3184A21773
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D558C8E00FD; Mon, 11 Feb 2019 11:32:10 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CDDE08E00F6; Mon, 11 Feb 2019 11:32:10 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B7F9C8E00FD; Mon, 11 Feb 2019 11:32:10 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 853E58E00F6
	for <linux-mm@kvack.org>; Mon, 11 Feb 2019 11:32:10 -0500 (EST)
Received: by mail-qt1-f197.google.com with SMTP id 43so7115639qtz.8
        for <linux-mm@kvack.org>; Mon, 11 Feb 2019 08:32:10 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:message-id:mime-version
         :subject:from:to:cc;
        bh=g8j9Hq6BgrsLF5iTVvtuSKrF1yqV6cwx6ZevVFumJ1k=;
        b=VJr3LNbSzNguo5xOAdw33MkjarKc4f+1eaw/un/KuOP/N7/+BvL5U4c51LTAMxIxFl
         DYFTwYw4bbMg8aRfNV10fiv2Q6Q14VzHHWVT0FvoruSgp1fFMd2YS9en0DdeQSYgvQrY
         0CL8+hVOUjlKBEemDcLrWWT9BW2S4kX412FsbLszoNaCGAJv037SWkWny6RiV1lRGu2c
         Q+/jx71fu5PYpTd7krmORv4A1pOHACTi+oEsp1VA7UqmJovw8q1PkkfUPth5JYBYiy6j
         ex7LZ8/fK9UIJBDlYJepm+fw5BuvNULyJmgb0SmIzszmNHzSsAjsfI59GrnQRI1fWiAC
         d5Hw==
X-Gm-Message-State: AHQUAuaS58tpgjh02wBED+ucHdcra+oqLq/VfnAZy6GdY/7dFaj/Wj8K
	u2tPzmZQi3yxrG7gCegrd2Pxnt+mTNDxfDOl9mSB+7zAHKUNfQ5f6vtKIHR6BzEOgr8HF+FK3Y7
	B6uk52N/VEbff29hSCL3Rn2brs/hl72G+iT5TxkBgVCaAU7VQYdQ6fAmaPLG151feuzeBvjTm+z
	PbETmdPo1B2cQ/W+c7RLgsJJ9H2xgEv70FA0D2x3eLkoIz+ZCmhyhkNgwW51DIQg7fyBRAMoLiD
	uHboD+YT2E5hNtND2ODJ0SanaOVk2XNrM3skq2cJAfOFCFKWIHO6+vbMmWmGKzxomR9PDr9Zn4e
	v4Bb6B4saTKC3lmymYUaG1xhPx8oXtz6jOVlHzzwc87aKyVfLEbUPhtwy3jyzpigBpR07NQTY8X
	L
X-Received: by 2002:aed:23a3:: with SMTP id j32mr27376107qtc.205.1549902730264;
        Mon, 11 Feb 2019 08:32:10 -0800 (PST)
X-Received: by 2002:aed:23a3:: with SMTP id j32mr27376071qtc.205.1549902729717;
        Mon, 11 Feb 2019 08:32:09 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549902729; cv=none;
        d=google.com; s=arc-20160816;
        b=x1hH+fPj+vni+GYts2B7UNHZN4UbH8qnW62jXV8CLpvxXV1LtiiMzQa/VfbmVyWHPF
         /S+UH0riwyUPH31bHLncvbaPXsuyhiDS81l8Y5Y1Sqiqk3aIxhDFeApZKvt00IwpK2P9
         IVatfVaW/sj4Q9SLeMjJdkOKmKDg27KPN35DmRgil5rTuAGjCdP+4eYv8LvA0DBhaCnJ
         LI23jUq6FHbyHJ1APQ3wdPxdyh0ylNefQD2QAT3XdXumO9ovaOOLy2y2qb8r8Gp5AxZN
         gwjKb8jmesQVWxtd+Je7Uj0Dg5yrVPVVnQXjSL0jPsQQHzK/t42j6cBgISBN8qq5IRJQ
         2LNg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:mime-version:message-id:date:dkim-signature;
        bh=g8j9Hq6BgrsLF5iTVvtuSKrF1yqV6cwx6ZevVFumJ1k=;
        b=f1gWIQZcrcS7udW68s//JYnYgmhqeEOkm8uf5z5PWZg8wRiiU55I02vDT11v+1a+w6
         O1iNmRpXDGjpNZJJ68o06DFsD+oRaD2KKrWAalZTp83sdsJupaDhDCglrOP+3Jwy+9VM
         xLWJNToasYI2ONQvZ3wKkysfwd5DycpYgKEyds7Kj3+umdYZ0rFbV9uyBdbfJPVdcmCt
         K5mSRKELUQ0W4bmCb25ViGHM7Ed9Gix0uDe4gQuxXw7Ub0GdB+dgD+PvlnRGWYSpUWm5
         uzheVZ1bX742ME2ez2wGvVRk49SHPhoUUajhL3/aXnOZbkx4BxFzmeFaq5scSncAJl/p
         iYow==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=resTFMXs;
       spf=pass (google.com: domain of 3ianhxaukcealcppjiqqing.eqonkpwz-oomxcem.qti@flex--jannh.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3iaNhXAUKCEAlcppjiqqing.eqonkpwz-oomxcem.qti@flex--jannh.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id l6sor12673956qte.24.2019.02.11.08.32.09
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 11 Feb 2019 08:32:09 -0800 (PST)
Received-SPF: pass (google.com: domain of 3ianhxaukcealcppjiqqing.eqonkpwz-oomxcem.qti@flex--jannh.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=resTFMXs;
       spf=pass (google.com: domain of 3ianhxaukcealcppjiqqing.eqonkpwz-oomxcem.qti@flex--jannh.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3iaNhXAUKCEAlcppjiqqing.eqonkpwz-oomxcem.qti@flex--jannh.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:message-id:mime-version:subject:from:to:cc;
        bh=g8j9Hq6BgrsLF5iTVvtuSKrF1yqV6cwx6ZevVFumJ1k=;
        b=resTFMXsv362eCHTHAhm5Pol1eeM3yr3nRd3wz29koaQbZo6yLCKX/5Iz9fnDy0/iM
         W5Abf2BqNvyPOiEYtn1TKiH/Y+79hUfjuYembRmNRQLa9uMj5rK9z+Nm6zo0AgmEKzyb
         ygJf284PlgcabSBZA4heIXW+UluHeJLvN0N0naYgRVZFp06laMAqzY93A+h3kKSt9n/Z
         4HO5rQkeR73XBwOGSL3J0LrRLVtRNWFFRKsVIjIPTbiNCiI5qNSfT8bVL78/p3TLHI7H
         7Jk+cR/7eB2951vuDVYip7w/yx+iV9Y3oKC5rpadIoRVThjxF94wI8Oh/eEBUxjBenu/
         HLhQ==
X-Google-Smtp-Source: AHgI3IZMONOPzWkMyGMVEbG8/au4SeEZWoLdpHNKemt6FuIiFFZh84ZC0chVudOiLVo7JAWl0PGhIF8vIA==
X-Received: by 2002:ac8:1bf2:: with SMTP id m47mr10477070qtk.27.1549902729411;
 Mon, 11 Feb 2019 08:32:09 -0800 (PST)
Date: Mon, 11 Feb 2019 17:32:03 +0100
Message-Id: <20190211163203.33477-1-jannh@google.com>
Mime-Version: 1.0
X-Mailer: git-send-email 2.20.1.791.gb4d0f1c61a-goog
Subject: [PATCH] mmap.2: fix description of treatment of the hint
From: Jann Horn <jannh@google.com>
To: mtk.manpages@gmail.com, jannh@google.com
Cc: linux-man@vger.kernel.org, linux-mm@kvack.org
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.033510, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The current manpage reads to me as if the kernel will always pick a free
space close to the requested address, but that's not the case:

mmap(0x600000000000, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS,
-1, 0) = 0x600000000000
mmap(0x600000000000, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS,
-1, 0) = 0x7f5042859000

You can also see this in the various implementations of
->get_unmapped_area() - if the specified address isn't available, the
kernel basically ignores the hint (apart from the 5level paging hack).

Clarify how this works a bit.

Signed-off-by: Jann Horn <jannh@google.com>
---
 man2/mmap.2 | 7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/man2/mmap.2 b/man2/mmap.2
index fccfb9b3e..8556bbfeb 100644
--- a/man2/mmap.2
+++ b/man2/mmap.2
@@ -71,7 +71,12 @@ If
 .I addr
 is not NULL,
 then the kernel takes it as a hint about where to place the mapping;
-on Linux, the mapping will be created at a nearby page boundary.
+on Linux, the kernel will pick a nearby page boundary (but always above
+or equal to the value specified by
+.IR /proc/sys/vm/mmap_min_addr )
+and attempt to create the mapping there.
+If another mapping already exists there, the kernel picks a new
+address, independent of the hint.
 .\" Before Linux 2.6.24, the address was rounded up to the next page
 .\" boundary; since 2.6.24, it is rounded down!
 The address of the new mapping is returned as the result of the call.
-- 
2.20.1.791.gb4d0f1c61a-goog

