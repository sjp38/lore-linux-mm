Return-Path: <SRS0=KwX8=RE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 74B2DC10F03
	for <linux-mm@archiver.kernel.org>; Fri,  1 Mar 2019 14:38:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0E8FB2084F
	for <linux-mm@archiver.kernel.org>; Fri,  1 Mar 2019 14:38:03 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=lca.pw header.i=@lca.pw header.b="CXOdZ1qk"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0E8FB2084F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lca.pw
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 48D058E0003; Fri,  1 Mar 2019 09:38:03 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 43B7D8E0001; Fri,  1 Mar 2019 09:38:03 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 303548E0003; Fri,  1 Mar 2019 09:38:03 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 046DB8E0001
	for <linux-mm@kvack.org>; Fri,  1 Mar 2019 09:38:03 -0500 (EST)
Received: by mail-qk1-f197.google.com with SMTP id v67so18695422qkl.22
        for <linux-mm@kvack.org>; Fri, 01 Mar 2019 06:38:02 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id;
        bh=u8p6LEaICK87ZAl5dajNGBnd4suIRJImycTZiVBF6mk=;
        b=XE2QKQPJnYfE9OGTtO1NBGTSqaDvrfDif9r4QrxVeJ1oX820v2nr+Thb+dcWrMWYHo
         5U/QY4DwFeTR1b+ZhzsRi8BtzQ8REwZZAJIPf5ZNWNFXFt1ZpQQk81uezvKAkEOG9gHw
         XLXIFiQ+Q2p4udJt91Fjf6Wy7FXjLhu+acWDmEpsJn/uvlY0dE6kwhZIcsoKacJkjs/N
         EvxIGmVuCeTUPVt6Dakzn5kNyZeOhwO6t5PdkGpAzbbALxR7j5fdJFim+0hwoRaP89/B
         keyQMTYQmpx200HYwNbpt2lDoe00sjCAyE+aeETxlv+OwGIpyHxPAMFwmE8xjhuf2u1r
         PwxA==
X-Gm-Message-State: APjAAAW9mG4YZUTW0ETwtdl2AaITcZfwslp81FxcDoXzXA/sLSMj3Oq1
	xTF9fcKAEoxOsWTmAsQw4vPxqPbqyrCHZlYWyeHHdur9VCbIOQM6a40QrPT0a2osFnP2Q9AD/5x
	nSRpzHFOzkm9u6evUfcCXtMtOTVMU4q0lu8ghsijcfRi/yB0Lzddfouak05xXnXxdnr4dooXd2p
	XMBPWDgSauyBTt+wQSdUTcQS8TQTkjAte2EdtF9cA7HJxKLSkzVkes+0M/1gg1iH88YkhQ/QC6u
	sdWCg4tcSeuiIBSoWpJOGSbllnMcAwY++xuYhRhj+NRNllX3SZ355AMt3KQqL2gymtZbLh2B7Ve
	rEXLLLYpbv5n+LcZAA7YgXiERskUo9RWl5hr32/Jna1TAXYmaLt6cU2lX24mh3+6YlXJ12UjzAg
	D
X-Received: by 2002:a05:620a:1328:: with SMTP id p8mr1820870qkj.311.1551451082612;
        Fri, 01 Mar 2019 06:38:02 -0800 (PST)
X-Received: by 2002:a05:620a:1328:: with SMTP id p8mr1820810qkj.311.1551451081513;
        Fri, 01 Mar 2019 06:38:01 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551451081; cv=none;
        d=google.com; s=arc-20160816;
        b=r/AVPlPrH4LfLYwpKStg39wgtL1D/6v8jO5qrhRTPvtR7EdpTfhTHxrH2q/pyr3obp
         y3wkHMcWnbqzltat35vYnT6YA4vr9YHzHD+FuoV2rIlaMz63201WJ/ERnAN1jRhApojX
         b/7VS4G4K5D+JTbrhPF8lwFUitgT61uwUwA/NC5gOWlChky0olafSrWEKxXUCzMqWxCu
         I1mRwlon4A0iX8mVKd0WXR/PI/IRSe5yOl7F5lXDgFGtwWHRjJBi4ZEr5fnpeDzA/bMv
         i6PammHrpc+3FQlP98Ackqr1FdBuPFwBUPbdxoKE27y05EEMNf9viRbwk7xMCPMyxr0V
         b4WA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from:dkim-signature;
        bh=u8p6LEaICK87ZAl5dajNGBnd4suIRJImycTZiVBF6mk=;
        b=O7qVQRoGdjN41ZVcYUsF2Qm7yjLDF5xfGC6S3i+q10nQWo6E3O92XugR43L0Q30FZG
         paM85teFoy+KFKP5zHlg4syxghQ3kSGx2JOfQQMSKsc7oqxfL+VK5amEnb02/EkuIvqk
         yHLiTpxJJ7JRrPUAvRDvDKczLA+XIECQdW9Ywr4ulY6PLkARES/+VRxhH72nlGayzkGA
         9UR2pOl4mEEmnRod2eSQT4JY81GiFtqeZE0blMgsGOXwNPzHjqknLZTNxiHpmhUrkg4O
         GCDXZbeqA9G6X8gRnMZpj6U9iUR/tV7/XIIgaGyE7ex/JGrXOmFVu81SSi0id+ofj1i2
         Lc7Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=CXOdZ1qk;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n52sor27842599qtk.39.2019.03.01.06.38.01
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 01 Mar 2019 06:38:01 -0800 (PST)
Received-SPF: pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=CXOdZ1qk;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=lca.pw; s=google;
        h=from:to:cc:subject:date:message-id;
        bh=u8p6LEaICK87ZAl5dajNGBnd4suIRJImycTZiVBF6mk=;
        b=CXOdZ1qkJEFpDrXmIdbDFbUBBQDnKKwxBoNzQ/nl3UExKo92Qa5WMRtSjviMKpm2rv
         SFoAwTu2thb0beEIxDaXIYP7hZRt9TAWPTy3RW9m6utlnE/sNtmF3tBU7yr5biidOdS1
         CO0cgbA2BXHGnDZTJRrviplkxPAbjiz4PgAL9bneX/QvIEMs/unePVw0WOAz+mapodzN
         hQLgQxaYUNtpH4TrOzljElp03YViaHMFr/8yYAzXxLPhu5EnN72Fghckv+RmBkv8Fuxi
         59CTQYerYdDzTr/vEKgECB9mHb9kaPaFTTp4+PlThUbZlRvcN0BDSDjruZ7JdkjD04vv
         7yLQ==
X-Google-Smtp-Source: APXvYqx0h4cstO+ZyRZVh/m5x9n5LEmfz45jN+4/fx3DH9aqCGTQtRrGaf8xOiVauN2qra/2xB3BKA==
X-Received: by 2002:ac8:1a56:: with SMTP id q22mr4123143qtk.59.1551451081078;
        Fri, 01 Mar 2019 06:38:01 -0800 (PST)
Received: from ovpn-120-151.rdu2.redhat.com (pool-71-184-117-43.bstnma.fios.verizon.net. [71.184.117.43])
        by smtp.gmail.com with ESMTPSA id z126sm15936977qkz.8.2019.03.01.06.38.00
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 01 Mar 2019 06:38:00 -0800 (PST)
From: Qian Cai <cai@lca.pw>
To: akpm@linux-foundation.org,
	hannes@cmpxchg.org,
	mhocko@kernel.org,
	vdavydov.dev@gmail.com
Cc: guro@fb.com,
	jrdr.linux@gmail.com,
	cgroups@vger.kernel.org,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	Qian Cai <cai@lca.pw>
Subject: [PATCH v2] memcg: fix a bad line
Date: Fri,  1 Mar 2019 09:37:34 -0500
Message-Id: <20190301143734.94393-1-cai@lca.pw>
X-Mailer: git-send-email 2.17.2 (Apple Git-113)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000015, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The commit 230671533d64 ("mm: memory.low hierarchical behavior") missed
an asterisk in one of the comments.

mm/memcontrol.c:5774: warning: bad line:                | 0, otherwise.

Acked-by: Souptick Joarder <jrdr.linux@gmail.com>
Signed-off-by: Qian Cai <cai@lca.pw>
---

v2: improve the commit message.

 mm/memcontrol.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index af7f18b32389..d4b96dc4bd8a 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -5747,7 +5747,7 @@ struct cgroup_subsys memory_cgrp_subsys = {
  *
  *             | memory.current, if memory.current < memory.low
  * low_usage = |
-	       | 0, otherwise.
+ *	       | 0, otherwise.
  *
  *
  * Such definition of the effective memory.low provides the expected
-- 
2.17.2 (Apple Git-113)

