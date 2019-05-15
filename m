Return-Path: <SRS0=idO3=TP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DFAC6C04E53
	for <linux-mm@archiver.kernel.org>; Wed, 15 May 2019 08:15:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5FCFC20862
	for <linux-mm@archiver.kernel.org>; Wed, 15 May 2019 08:15:42 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=yandex-team.ru header.i=@yandex-team.ru header.b="yiIhTfm8"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5FCFC20862
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=yandex-team.ru
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C6CF16B0005; Wed, 15 May 2019 04:15:41 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C1D2C6B0006; Wed, 15 May 2019 04:15:41 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AE4956B0007; Wed, 15 May 2019 04:15:41 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lf1-f70.google.com (mail-lf1-f70.google.com [209.85.167.70])
	by kanga.kvack.org (Postfix) with ESMTP id 480F36B0005
	for <linux-mm@kvack.org>; Wed, 15 May 2019 04:15:41 -0400 (EDT)
Received: by mail-lf1-f70.google.com with SMTP id l26so410907lfk.4
        for <linux-mm@kvack.org>; Wed, 15 May 2019 01:15:41 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:from:to:cc:date
         :message-id:user-agent:mime-version:content-transfer-encoding;
        bh=jHxTX7+w5XRXWiyeoOBtShSglDK2yw1HqwPBfT2YxAA=;
        b=kbwhZxpGRt1FDd490BLX3CBnxo65QsPGsUnxxF5WeTlMBoZ+qEMyDW6EanhDn79yxu
         TmAK/wHwZ152hbv8hHNUu0kZhCVIcNDtlOA2QftR1971tF+0Wh1qi3xI6S/mNg4sEcgI
         9Gen7gfFdOfKnkEiLozo1PKxk9EIftf3m3S5h79y0IlWRWXSUg3bwt+vsbW53nRYMABc
         kD+yj1xChI/0o9VrR9SaxdDju/0sLWelM3nlwM2MYBiqsxUU3r487Rp3LUCZ2b+cP/pz
         m5xs+8rwGky7dw92HM2ke+vSgLbGylNlrpZ0rTU7pHiBFqirq7PceIDPjbcr2/Ma2aCh
         RC5Q==
X-Gm-Message-State: APjAAAUJ0ulPrR2aAfkYkOUaLP1UgvGGOiA6qeNX9lGqe00p7ro0fjyy
	uG3yhDXLFZaiCPPVhVlQ4SldWf+mIQQVZ1yxNwELASIPiQ03/kxMNvJJjVL3yK15ZrTBaycHE5A
	d3fJzDRD3bvB6PomtnQHjIXSYgxcpc8/6gaenQKz95r2TPgL4klSBGbUPiPEjuxRtGQ==
X-Received: by 2002:a19:9e47:: with SMTP id h68mr17448881lfe.91.1557908140394;
        Wed, 15 May 2019 01:15:40 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyYm6ESyYlmVBn2ODDDIcGZqnlv78APIGY114oiGu5SRJy4cdTeOxXt6TuU6Ui6gqDuf0Uk
X-Received: by 2002:a19:9e47:: with SMTP id h68mr17448837lfe.91.1557908139249;
        Wed, 15 May 2019 01:15:39 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557908139; cv=none;
        d=google.com; s=arc-20160816;
        b=CHXd6sxVlsfNyxd4PAZP4UyCDQpP6VEO7h2nDdfZguB87VoevwyLtlbCnim8wzL1lT
         sIeghzSCxj7b0TL0nSz8Gx0ipGSli0d4w4YyjwzOnFLVT4PPTGWMJ4iNMT03sGcwziQA
         g/XLCQGfNwAtIQwF05qxGai5KYmClUItKlTnKvXg5zhA4UYgkFJTkVHczgvLtrX33Gry
         JlIAEeyMhc9rtwQvbSWEE4hkMYUAKc05s4OsNLm91AfKxjy7+ke3+nwYQfmjRxhJljQ8
         BjD8l/9cKIIxkNyrSNkvzMUr0gyD3ZT5mFRKe/xgTrvL/SNuQf4/UjlY6h8UOGQZrY6Q
         K4jw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:message-id:date
         :cc:to:from:subject:dkim-signature;
        bh=jHxTX7+w5XRXWiyeoOBtShSglDK2yw1HqwPBfT2YxAA=;
        b=L5iLe/VRrTBoE1kH+RFM33dOv47UkczU2kHGMyWuNYhxuzAoPIbpD940pA15YRX7LZ
         Bjlvt7g8/BqTun9eKM8fjwttR5i8dPvz2XI/2b1nmiU4BLnxbe6rmT5Wg85YaYYEcV++
         F4hPFksJaQOg8kkhGQQT2znJ19zbQKza/ZFdE5wrkUsmNA/I7Bjy/TDWEEV24EotRyZl
         98rCzVMfmzGfQKgihbJA5wY7hnwrwBNTk2PmFLclgbpXlSXsHDBX8vqcBmSUBXR23zYd
         8rdprE6E6Ea1X1m6bJd44BlhFj668gJAkLYXWJt6EweEEfunWnaReYnBQkLHGmQIEI8x
         wC3Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@yandex-team.ru header.s=default header.b=yiIhTfm8;
       spf=pass (google.com: domain of khlebnikov@yandex-team.ru designates 2a02:6b8:0:1472:2741:0:8b6:217 as permitted sender) smtp.mailfrom=khlebnikov@yandex-team.ru;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=yandex-team.ru
Received: from forwardcorp1p.mail.yandex.net (forwardcorp1p.mail.yandex.net. [2a02:6b8:0:1472:2741:0:8b6:217])
        by mx.google.com with ESMTP id m11si937399lji.201.2019.05.15.01.15.38
        for <linux-mm@kvack.org>;
        Wed, 15 May 2019 01:15:39 -0700 (PDT)
Received-SPF: pass (google.com: domain of khlebnikov@yandex-team.ru designates 2a02:6b8:0:1472:2741:0:8b6:217 as permitted sender) client-ip=2a02:6b8:0:1472:2741:0:8b6:217;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@yandex-team.ru header.s=default header.b=yiIhTfm8;
       spf=pass (google.com: domain of khlebnikov@yandex-team.ru designates 2a02:6b8:0:1472:2741:0:8b6:217 as permitted sender) smtp.mailfrom=khlebnikov@yandex-team.ru;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=yandex-team.ru
Received: from mxbackcorp2j.mail.yandex.net (mxbackcorp2j.mail.yandex.net [IPv6:2a02:6b8:0:1619::119])
	by forwardcorp1p.mail.yandex.net (Yandex) with ESMTP id A73FB2E0987;
	Wed, 15 May 2019 11:15:38 +0300 (MSK)
Received: from smtpcorp1o.mail.yandex.net (smtpcorp1o.mail.yandex.net [2a02:6b8:0:1a2d::30])
	by mxbackcorp2j.mail.yandex.net (nwsmtp/Yandex) with ESMTP id RoCJEKO4OP-Fc0KCJcQ;
	Wed, 15 May 2019 11:15:38 +0300
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=yandex-team.ru; s=default;
	t=1557908138; bh=jHxTX7+w5XRXWiyeoOBtShSglDK2yw1HqwPBfT2YxAA=;
	h=Message-ID:Date:To:From:Subject:Cc;
	b=yiIhTfm8Y8WhZ27MzSCHygSHiu5oBt8MnnCw4imtDEH6qA2novSoggL0Mk1CNqZ9T
	 7xF4+sJ+Uco+w51uWRsqF5JueXBt2YYU1CZvrsjb3//DVbmxezl4Kkc7S2+eC/xLEJ
	 XdmVbHG1DwYMOOkK8yT+YETJRQD++p45vkpsltKw=
Authentication-Results: mxbackcorp2j.mail.yandex.net; dkim=pass header.i=@yandex-team.ru
Received: from dynamic-red.dhcp.yndx.net (dynamic-red.dhcp.yndx.net [2a02:6b8:0:40c:ed19:3833:7ce1:2324])
	by smtpcorp1o.mail.yandex.net (nwsmtp/Yandex) with ESMTPSA id TMPGL1lslS-Fbl0Xd6Q;
	Wed, 15 May 2019 11:15:37 +0300
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(Client certificate not present)
Subject: [PATCH] mm: fix protection of mm_struct fields in get_cmdline()
From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>,
 linux-kernel@vger.kernel.org
Cc: Michal Hocko <mhocko@suse.com>, Yang Shi <yang.shi@linux.alibaba.com>
Date: Wed, 15 May 2019 11:15:37 +0300
Message-ID: <155790813764.2995.13706842444028749629.stgit@buzz>
User-Agent: StGit/0.17.1-dirty
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Since commit 88aa7cc688d4 ("mm: introduce arg_lock to protect arg_start|
end and env_start|end in mm_struct") related mm fields are protected with
separate spinlock and mmap_sem held for read is not enough for protection.

Fixes: 88aa7cc688d4 ("mm: introduce arg_lock to protect arg_start|end and env_start|end in mm_struct")
Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
---
 mm/util.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/util.c b/mm/util.c
index e2e4f8c3fa12..540e7c157cf2 100644
--- a/mm/util.c
+++ b/mm/util.c
@@ -717,12 +717,12 @@ int get_cmdline(struct task_struct *task, char *buffer, int buflen)
 	if (!mm->arg_end)
 		goto out_mm;	/* Shh! No looking before we're done */
 
-	down_read(&mm->mmap_sem);
+	spin_lock(&mm->arg_lock);
 	arg_start = mm->arg_start;
 	arg_end = mm->arg_end;
 	env_start = mm->env_start;
 	env_end = mm->env_end;
-	up_read(&mm->mmap_sem);
+	spin_unlock(&mm->arg_lock);
 
 	len = arg_end - arg_start;
 

