Return-Path: <SRS0=aa49=T6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6CBB7C28CC3
	for <linux-mm@archiver.kernel.org>; Thu, 30 May 2019 16:33:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0E89A25DB6
	for <linux-mm@archiver.kernel.org>; Thu, 30 May 2019 16:33:39 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0E89A25DB6
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=canonical.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 582836B026F; Thu, 30 May 2019 12:33:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 532116B0271; Thu, 30 May 2019 12:33:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 422516B0274; Thu, 30 May 2019 12:33:39 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id 09D4E6B026F
	for <linux-mm@kvack.org>; Thu, 30 May 2019 12:33:39 -0400 (EDT)
Received: by mail-wr1-f71.google.com with SMTP id u11so2714043wri.19
        for <linux-mm@kvack.org>; Thu, 30 May 2019 09:33:38 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version:content-transfer-encoding;
        bh=RSR4Y6uOXU6ci8DfFnO8AOJl33fqkg0nWOTwVJa4CRg=;
        b=RoLZS6+bd1VEskTkKoV9swCjikRqc2NTZWrFg+VVaeWECPGUmhplWPRxYueFhtxX4P
         r3Pib7q/76qNLBNqVOFzeFyTvF7OJSCcdRBxsccNxtSYMzHeSAh3CtMtE/7ZhN0Rduc6
         tmAg4ZFKkttwgTApvuyBBTWvDczHa9TyXIzqnP9uDtcw6PZ1bDoT9nyFMH8SzTedUHIm
         iekri2Vm5Tfn07yQ9dE+L1QZAxbuFHqe7Q9YVEXinstRYqYaPJPbTSkFxKERO/tsD1yZ
         Mn3iJS+q1cOpfk9UAWQK7vu/YwGHAUwqSutqxXY+08eacdwa3BV6HbVe/B+V5BNadi5l
         Ju6Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of colin.king@canonical.com designates 91.189.89.112 as permitted sender) smtp.mailfrom=colin.king@canonical.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=canonical.com
X-Gm-Message-State: APjAAAXBDNXQkgapxvGoJD80yOo4V2+sXlJ6oVN3ivSquoEibdk9DFDa
	atJyNomK2DtRYgHvD8XsdiuNViluBPDnycgaPWCJEYhb2aFmy4IMwU4fX291FEPTyr76c9xfoo3
	ZhYxLC/QJoHMS/gwyfslmoee8/nvP1YcpzIzLUpr5KFZx/xUJLclsSTsxc8jph/XQBA==
X-Received: by 2002:adf:e705:: with SMTP id c5mr3322303wrm.270.1559234018385;
        Thu, 30 May 2019 09:33:38 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzWjDTjzC8REXpc40q05w5R0iie4zBTsNq/VIhexnE2jzW+oC/UDRUMLusuWfeYU6FIQ0DF
X-Received: by 2002:adf:e705:: with SMTP id c5mr3322258wrm.270.1559234017477;
        Thu, 30 May 2019 09:33:37 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559234017; cv=none;
        d=google.com; s=arc-20160816;
        b=0LDpug2khoutzvt4d1w993b4gEnx5a0uzlFGKQSh1nA7zYOa/xHTohueX76C32nnRI
         2QlbYaEJLbk+RZ7+qbPlMRkI0LvIgwd9XA3lRl+5vAoIIWNELj33lVzuHtxWqF0Vy1fL
         FoMKpiUNWBFd61/tangTfZ/ie48/X2ISGzVVG4+z+1TZOUSAWJEYEW9lcRnu7WYFJJNI
         B5q4vkv/P6f5scycSy9dRq75uuGOjElLjFGqkTcpAQmVWhR/mPfoQ1L9jfvZrKZzjdvm
         /U14lDkEPEY0DBaiixw7ioxedGuyvqslkoNXdHrYPWq86qzV/7WO15qBcSnWEuBSVrdz
         3/1g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from;
        bh=RSR4Y6uOXU6ci8DfFnO8AOJl33fqkg0nWOTwVJa4CRg=;
        b=XRiov6J2drE5mpEpQTg/z+SnfmaP679tfYLq4NZtyEVhDavPRhHw8byUQr/WLoxGu6
         m/E/qo+wgAOpcknUzOpgX9MiusnOfdQRPBTwL1DJ3ZLMCEAWyK3XeBiKgreLppkdRyif
         1tnTO9YTKirkpFfQOinkEaM0EWXH6oSioDh/Snqfnb2lGHmMLkaea8ovxmDPSLOmtyOa
         lcVHP2vbw8gw0lyf3VFXe4a4YsBgrW67I/lXbjtd+epmTfcyBQnqY6u201Vlz5aB0pDG
         10/HuVvUpmFBlJmvuxZFOqxZWdJVm/FhbnKKKVKc3+XjqJOCRZC7d1p10/TFIw2KvJ/j
         xoyQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of colin.king@canonical.com designates 91.189.89.112 as permitted sender) smtp.mailfrom=colin.king@canonical.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=canonical.com
Received: from youngberry.canonical.com (youngberry.canonical.com. [91.189.89.112])
        by mx.google.com with ESMTPS id r1si2192208wrq.390.2019.05.30.09.33.37
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 30 May 2019 09:33:37 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of colin.king@canonical.com designates 91.189.89.112 as permitted sender) client-ip=91.189.89.112;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of colin.king@canonical.com designates 91.189.89.112 as permitted sender) smtp.mailfrom=colin.king@canonical.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=canonical.com
Received: from 1.general.cking.uk.vpn ([10.172.193.212] helo=localhost)
	by youngberry.canonical.com with esmtpsa (TLS1.0:RSA_AES_256_CBC_SHA1:32)
	(Exim 4.76)
	(envelope-from <colin.king@canonical.com>)
	id 1hWNzk-0003HE-Ds; Thu, 30 May 2019 16:33:36 +0000
From: Colin King <colin.king@canonical.com>
To: Andrew Morton <akpm@linux-foundation.org>,
	Vitaly Wool <vitalywool@gmail.com>,
	linux-mm@kvack.org
Cc: kernel-janitors@vger.kernel.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH][next] z3fold: remove redundant assignment to bud
Date: Thu, 30 May 2019 17:33:36 +0100
Message-Id: <20190530163336.5148-1-colin.king@canonical.com>
X-Mailer: git-send-email 2.20.1
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Colin Ian King <colin.king@canonical.com>

The variable bud is initialized with the value 'LAST' which is never
read and bud is reassigned later on the return from the call to the
function handle_to_buddy. This initialization is redundant and
can be removed.

Addresses-Coverity: ("Unused value")
Signed-off-by: Colin Ian King <colin.king@canonical.com>
---
 mm/z3fold.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/z3fold.c b/mm/z3fold.c
index 2bc3dbde6255..0a62bc293de4 100644
--- a/mm/z3fold.c
+++ b/mm/z3fold.c
@@ -1176,7 +1176,7 @@ static void z3fold_free(struct z3fold_pool *pool, unsigned long handle)
 {
 	struct z3fold_header *zhdr;
 	struct page *page;
-	enum buddy bud = LAST; /* initialize to !HEADLESS */
+	enum buddy bud;
 
 	zhdr = get_z3fold_header(handle);
 
-- 
2.20.1

