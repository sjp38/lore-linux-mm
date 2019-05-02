Return-Path: <SRS0=Mdb/=TC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-14.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 53276C43219
	for <linux-mm@archiver.kernel.org>; Thu,  2 May 2019 16:31:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1213520652
	for <linux-mm@archiver.kernel.org>; Thu,  2 May 2019 16:31:42 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="qw6j5mpw"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1213520652
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9F8176B0007; Thu,  2 May 2019 12:31:42 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9CF5A6B0008; Thu,  2 May 2019 12:31:42 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8E5326B000A; Thu,  2 May 2019 12:31:42 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 425EC6B0007
	for <linux-mm@kvack.org>; Thu,  2 May 2019 12:31:42 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id f41so1349669ede.1
        for <linux-mm@kvack.org>; Thu, 02 May 2019 09:31:42 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=7Oy1RG3BUKEsx4VUlFgLOKgTT7HGDm6BmTdCPYEVHzI=;
        b=D0EGRr7XAQk22PT59YtzYbPxBPANyldPlgl8Mx+och9t9toNnWcpECnWWsa2KS4E1Z
         V3WRCug2IKFLSaXDcw2bl/bDfj2YasvcynM0bbNc4vU1q5/owLGX3Fnb2/B8xZkEa3Ai
         MDUYogLAaCmdyGM2kDL2HcC7diOYR+adb6zehNh9mKPQg7Oirs8Kn4srm1gRMjh9oGkq
         Ch21V/BGmmq7M7Cd+Lhg/VOeva1lyFWpGLzhuwIcmkTJkSC146rtMtzCALn5GuL0vpZQ
         VJius49JY4KNtHYN4pofSXjlnFp/JxjPrvquVFu0K9NhncNUhdNWN8XGFyl5bVgKtisA
         v5IA==
X-Gm-Message-State: APjAAAU+ZR5CgThWWcnMQbxcDMR01QS6PY9L1PIiob++sFmz3m5ZbHGR
	Bdl8HpBFg02uR6YTFI6kegiHvM7zwDiy45oDL045kFiOnHPWu8ImngjJpyeRsVLVc4XnxOGi8OB
	wIMh2FeNV/UjLo+P+WjIINMWRxG/yHv33BwnVVI0h9FKsIyPlsP9BqQnZFjfVCIHF4g==
X-Received: by 2002:a50:a305:: with SMTP id 5mr3046179edn.164.1556814701528;
        Thu, 02 May 2019 09:31:41 -0700 (PDT)
X-Received: by 2002:a50:a305:: with SMTP id 5mr3046082edn.164.1556814700279;
        Thu, 02 May 2019 09:31:40 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556814700; cv=none;
        d=google.com; s=arc-20160816;
        b=wMfedV8zvo56AHbWeHLNShFio1rjR6pQHWqxIPv/xCvYplIn+NDs0LAtkYPnmrRPtr
         /rSumNK821bq47xzNZucqIudQKJjhozuXf5IjrOKi5k5EW3ZSWjjxPyu3HriO+CBaJz/
         /oG0Xyj4NTIgqEucfWyyI0lpo8q2JdE6q+Aur7dajKFmGG5lnyBlneimOCxFopFJNTpi
         C690caeZrfeoV6ksX237L+aY6O+FdCD6oguIemUUBsKcf8wM7S+zqmQdZHGdpUvpaTlQ
         PYETL5fCCh3v7/5pVPO0k1WBHWJEKZfVUxhcUK4v0gT77/24P6Zgu5iiLnbz9pMwTWhi
         ncpw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=7Oy1RG3BUKEsx4VUlFgLOKgTT7HGDm6BmTdCPYEVHzI=;
        b=nTcx4PupTHDZPTwF1mwABQv+Iidz96f6RulUY3F8VEVL3eYFDTxCGriQjpRm6l88Uc
         p2ejv7Oz9z7a6MbpagHh7F/J6nVHGnHwnajDXNwKmH0tek/c2O+KOeh8hdS4sC4Tlgid
         kWJSmdRd8uC6LU3vyqE39QFQRjp3kqhkpc+4QGKQ2OmA64UCHjX3L45Fan7O/JRLl/wM
         MMzsj5i3yL/LxK5bOf7bQKD/wZmEoPir5m5tQMvgJbG2NfsDC3Lxl91LDa5OmQzloNp4
         pE5MnkQ0i36ozJNCYBhJG0FjOIrJtAt9+LMhoJI5GpEPZNHpP8GeoyHM9UyjGd2ggtkq
         18XQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=qw6j5mpw;
       spf=pass (google.com: domain of natechancellor@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=natechancellor@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b1sor6004934eja.51.2019.05.02.09.31.40
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 02 May 2019 09:31:40 -0700 (PDT)
Received-SPF: pass (google.com: domain of natechancellor@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=qw6j5mpw;
       spf=pass (google.com: domain of natechancellor@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=natechancellor@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=7Oy1RG3BUKEsx4VUlFgLOKgTT7HGDm6BmTdCPYEVHzI=;
        b=qw6j5mpwSwKYxN/oL4IAsK/zH1v/EkIn+dDLKuZam7yyhsQTM8KB9cL677/5Oz7MVy
         IexCjBqxB23TohGwbBNWIteLggib7PQ3HCSGF844ugqO8ODk5dxWwnXEZg9sKL1DIzyR
         J/+ASLTaOgJswbMKQq8KaHH3d5PttebWx1MBEpVqQ93t2Os4ETMG7fcecg0n18fINZuk
         fWyvoeQsc12VsByCTBs3lt6WG9FvJ9kaNvf+e8CIKjw4G35upmxBIcv//uweMZ6jFNL8
         D79gY0owa3HXwk0qwp26NVPUdg9mRp/hYXIhEdDJ1ZNlad7IQv9ewy6AszUJc2gWsEip
         EYWg==
X-Google-Smtp-Source: APXvYqz4jS4aZzqlMk96rIVkIK1ahQvD2cBXh7geHSHkh6Ve3klRmskSiNbCIGL6V2kmJmVabxVeIg==
X-Received: by 2002:a17:906:5fd7:: with SMTP id k23mr2318906ejv.201.1556814699691;
        Thu, 02 May 2019 09:31:39 -0700 (PDT)
Received: from localhost.localdomain ([2a01:4f9:2b:2b84::2])
        by smtp.gmail.com with ESMTPSA id oq25sm7460093ejb.46.2019.05.02.09.31.38
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 02 May 2019 09:31:38 -0700 (PDT)
From: Nathan Chancellor <natechancellor@gmail.com>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>,
	Alexander Potapenko <glider@google.com>,
	Dmitry Vyukov <dvyukov@google.com>
Cc: kasan-dev@googlegroups.com,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	Nick Desaulniers <ndesaulniers@google.com>,
	clang-built-linux@googlegroups.com,
	Nathan Chancellor <natechancellor@gmail.com>
Subject: [PATCH v2] kasan: Initialize tag to 0xff in __kasan_kmalloc
Date: Thu,  2 May 2019 09:30:58 -0700
Message-Id: <20190502163057.6603-1-natechancellor@gmail.com>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190502153538.2326-1-natechancellor@gmail.com>
References: <20190502153538.2326-1-natechancellor@gmail.com>
MIME-Version: 1.0
X-Patchwork-Bot: notify
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

When building with -Wuninitialized and CONFIG_KASAN_SW_TAGS unset, Clang
warns:

mm/kasan/common.c:484:40: warning: variable 'tag' is uninitialized when
used here [-Wuninitialized]
        kasan_unpoison_shadow(set_tag(object, tag), size);
                                              ^~~

set_tag ignores tag in this configuration but clang doesn't realize it
at this point in its pipeline, as it points to arch_kasan_set_tag as
being the point where it is used, which will later be expanded to
(void *)(object) without a use of tag. Initialize tag to 0xff, as it
removes this warning and doesn't change the meaning of the code.

Link: https://github.com/ClangBuiltLinux/linux/issues/465
Signed-off-by: Nathan Chancellor <natechancellor@gmail.com>
---

v1 -> v2:

* Initialize tag to 0xff at Andrey's request

 mm/kasan/common.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/kasan/common.c b/mm/kasan/common.c
index 36afcf64e016..242fdc01aaa9 100644
--- a/mm/kasan/common.c
+++ b/mm/kasan/common.c
@@ -464,7 +464,7 @@ static void *__kasan_kmalloc(struct kmem_cache *cache, const void *object,
 {
 	unsigned long redzone_start;
 	unsigned long redzone_end;
-	u8 tag;
+	u8 tag = 0xff;
 
 	if (gfpflags_allow_blocking(flags))
 		quarantine_reduce();
-- 
2.21.0

