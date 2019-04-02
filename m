Return-Path: <SRS0=cFM0=SE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 739FEC4360F
	for <linux-mm@archiver.kernel.org>; Tue,  2 Apr 2019 03:10:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 257D52084C
	for <linux-mm@archiver.kernel.org>; Tue,  2 Apr 2019 03:10:26 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=android.com header.i=@android.com header.b="g3m1Y2Sc"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 257D52084C
Authentication-Results: mail.kernel.org; dmarc=fail (p=quarantine dis=none) header.from=android.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B2BDC6B0003; Mon,  1 Apr 2019 23:10:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AD9B66B0005; Mon,  1 Apr 2019 23:10:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9A3E86B0007; Mon,  1 Apr 2019 23:10:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5D4A26B0003
	for <linux-mm@kvack.org>; Mon,  1 Apr 2019 23:10:25 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id l13so5468207pgp.3
        for <linux-mm@kvack.org>; Mon, 01 Apr 2019 20:10:25 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:mime-version:content-transfer-encoding;
        bh=Hp60OTE4ke8iP5Aud+CmanJ0ZyIKgseuIbzLLPcisQY=;
        b=gj2s5yzVeOiOS7A4UbRfQwhy4gWFwjIsBwD8aAillSrFxvnbVjItlwMlUcEKrzZqii
         jGSldyJ7s3JyFEtyUB0L9DMAewfZeGGM5S2CTowJNRqfAFNlnoSbcU18cGFAkhtPXOhv
         mOs/gHFWcxoPhbHkShpNwSdgTG60po1dTuWjinYju64UmqHRaakG08/15lhjm+a+gtcX
         sojnWubrqJZ5+ZLDKDXFAX1KnEWW3MySy5M/sU3RJ18Mzi/7IdK4cmhudOzRkGVgkLU9
         RzFDOByYpsXD1XY+HiOWsS4gCYAf839bN2bR/VVLz3iAZCa2KqIlpxUgNJpJbRblMfph
         +/YA==
X-Gm-Message-State: APjAAAX2i91cBoBpMuUokuajyiB9AxmTNBJQYLSDnrq9LvOlYLwQUuMD
	RbEcCUNu+KO7Cocv5UZ3Rvpw3HvJ0YBCi8HWvDPraLtAka3PgP55BYeMLV7boJKtAkn4TKRGm2Q
	d+7/reAlvGurvJrmVB2hGAD0F9j0DrYM2kmOYE4PIFwDWmp0IG09rY4uoud4u4ivNuQ==
X-Received: by 2002:a63:e653:: with SMTP id p19mr2790700pgj.284.1554174624786;
        Mon, 01 Apr 2019 20:10:24 -0700 (PDT)
X-Received: by 2002:a63:e653:: with SMTP id p19mr2790658pgj.284.1554174624075;
        Mon, 01 Apr 2019 20:10:24 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554174624; cv=none;
        d=google.com; s=arc-20160816;
        b=L3okLok2jArZU+l3LWHVbusy/TsVvJ+KY+oyOD5UmCpIadeNCWoNtJMFk4vP8tl0yW
         gMX2BWSxgSxDNHoQ9wntwwVADR1ixEcMkOrMf2XS9Oo6qNNormvj8nScx2+L+n83A7JX
         x8rNEC6VhmYT0k8hmXbti7Z3Ikw9HKdKoxkgWu3KZtUaUu+miqifeTbm5fTXCCyEJEHF
         76hVKG1OA8dwJjwtFeCLuqEC+/DCeEqN0WYrGgXiv9jBH0X+bdrI1aXEYS8jiZlAjZ+K
         ly8KzDcL0dz15q6X2z0FQmjy9rP+Ru5atub5PeJUJxOB6GqxBk9gA/7x4fXi0F8Dq7Md
         xgVg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:dkim-signature;
        bh=Hp60OTE4ke8iP5Aud+CmanJ0ZyIKgseuIbzLLPcisQY=;
        b=0wMMXYzQeOC0oLC+/BxpETHfrIJbCvcz2qXMY42s1SUaKOVqiJSuqkTJnuArz1dZbe
         KIH5K96PYSO8tH1cTEZqhD1Wu/Qz2d0b9inWSHAvkVzWfvQ4Wh+7/rYic9cskUB5qZq3
         y8EKjng1YGCgZOrU6zkmybCXeBR+75LH35G76kdSB4dwHCljbCvHg5MJAJsapD8eC/r3
         PaNnOKnXvBPeJImzZ/Qp5bidDIvMOS4TY6otKNtfzPNRMdlp1noxsJZTnbz0ELW8Cd+W
         3UxqEwqfoKN562b+wb6c8o+J6kUxQSSctfuEYbuBpUeD/YmphScBIrjyRY0iy9Kzdum0
         qNzw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@android.com header.s=20161025 header.b=g3m1Y2Sc;
       spf=pass (google.com: domain of trong@android.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=trong@android.com;
       dmarc=pass (p=QUARANTINE sp=QUARANTINE dis=NONE) header.from=android.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id bg2sor13337543plb.20.2019.04.01.20.10.23
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 01 Apr 2019 20:10:24 -0700 (PDT)
Received-SPF: pass (google.com: domain of trong@android.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@android.com header.s=20161025 header.b=g3m1Y2Sc;
       spf=pass (google.com: domain of trong@android.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=trong@android.com;
       dmarc=pass (p=QUARANTINE sp=QUARANTINE dis=NONE) header.from=android.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=android.com; s=20161025;
        h=from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=Hp60OTE4ke8iP5Aud+CmanJ0ZyIKgseuIbzLLPcisQY=;
        b=g3m1Y2ScyzDAURubjhsTnVSDieFyBlqPSM2LC7CUatm8gRlzI4Z4XQ8e+sauoBVcMy
         /Si0ZgUXDkb0dPj3vSxlgc5r0s2q7Upfik19UZen265H5YZZ42iiEK9QbuX7YonIPVGD
         d0/tPGVBnFEdWBuZzWmyAl7nqsH30axLzN9a/pDbloDEH6lC9LU9a4jIP9tdhzmsciY5
         S3tIIQOc4z1gsawWCFsfc9AkK7pkcFlCQf4Z5R8i1IFoxZ3IVzHzOFybLqrgNgncMa7W
         Yh4ifra9SolAtD3ZfW1fVy94mG7zhGcdjiK400DReloJN9yY0S5qFzHvofEschSfANPf
         kDSw==
X-Google-Smtp-Source: APXvYqyBVin/OFPJ5V12iXbP2gcs5Osv/4t27BzE77qH7pR8fgo4gJrG7KlV5JQtMOT9MiQxqhVPIg==
X-Received: by 2002:a17:902:2c83:: with SMTP id n3mr69465358plb.281.1554174623140;
        Mon, 01 Apr 2019 20:10:23 -0700 (PDT)
Received: from trong-glaptop.imgcgcw.net ([147.50.13.10])
        by smtp.gmail.com with ESMTPSA id c17sm16168464pfd.76.2019.04.01.20.10.19
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 01 Apr 2019 20:10:22 -0700 (PDT)
From: trong@android.com
To: oberpar@linux.ibm.com,
	akpm@linux-foundation.org
Cc: ndesaulniers@google.com,
	ghackmann@android.com,
	linux-mm@kvack.org,
	kbuild-all@01.org,
	rdunlap@infradead.org,
	lkp@intel.com,
	linux-kernel@vger.kernel.org,
	Tri Vo <trong@android.com>
Subject: [PATCH v3] gcov: fix when CONFIG_MODULES is not set
Date: Tue,  2 Apr 2019 10:09:56 +0700
Message-Id: <20190402030956.48166-1-trong@android.com>
X-Mailer: git-send-email 2.21.0.392.gf8f6787159e-goog
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Tri Vo <trong@android.com>

Fixes: 8c3d220cb6b5 ("gcov: clang support")

Cc: Greg Hackmann <ghackmann@android.com>
Cc: Peter Oberparleiter <oberpar@linux.ibm.com>
Cc: linux-mm@kvack.org
Cc: kbuild-all@01.org
Reported-by: Randy Dunlap <rdunlap@infradead.org>
Reported-by: kbuild test robot <lkp@intel.com>
Link: https://marc.info/?l=linux-mm&m=155384681109231&w=2
Signed-off-by: Nick Desaulniers <ndesaulniers@google.com>
Signed-off-by: Tri Vo <trong@android.com>
---
 kernel/gcov/clang.c   | 4 ++++
 kernel/gcov/gcc_3_4.c | 4 ++++
 kernel/gcov/gcc_4_7.c | 4 ++++
 3 files changed, 12 insertions(+)

diff --git a/kernel/gcov/clang.c b/kernel/gcov/clang.c
index 125c50397ba2..cfb9ce5e0fed 100644
--- a/kernel/gcov/clang.c
+++ b/kernel/gcov/clang.c
@@ -223,7 +223,11 @@ void gcov_info_unlink(struct gcov_info *prev, struct gcov_info *info)
  */
 bool gcov_info_within_module(struct gcov_info *info, struct module *mod)
 {
+#ifdef CONFIG_MODULES
 	return within_module((unsigned long)info->filename, mod);
+#else
+	return false;
+#endif
 }
 
 /* Symbolic links to be created for each profiling data file. */
diff --git a/kernel/gcov/gcc_3_4.c b/kernel/gcov/gcc_3_4.c
index 801ee4b0b969..8fc30f178351 100644
--- a/kernel/gcov/gcc_3_4.c
+++ b/kernel/gcov/gcc_3_4.c
@@ -146,7 +146,11 @@ void gcov_info_unlink(struct gcov_info *prev, struct gcov_info *info)
  */
 bool gcov_info_within_module(struct gcov_info *info, struct module *mod)
 {
+#ifdef CONFIG_MODULES
 	return within_module((unsigned long)info, mod);
+#else
+	return false;
+#endif
 }
 
 /* Symbolic links to be created for each profiling data file. */
diff --git a/kernel/gcov/gcc_4_7.c b/kernel/gcov/gcc_4_7.c
index ec37563674d6..0b6886d4a4dd 100644
--- a/kernel/gcov/gcc_4_7.c
+++ b/kernel/gcov/gcc_4_7.c
@@ -159,7 +159,11 @@ void gcov_info_unlink(struct gcov_info *prev, struct gcov_info *info)
  */
 bool gcov_info_within_module(struct gcov_info *info, struct module *mod)
 {
+#ifdef CONFIG_MODULES
 	return within_module((unsigned long)info, mod);
+#else
+	return false;
+#endif
 }
 
 /* Symbolic links to be created for each profiling data file. */
-- 
2.21.0.392.gf8f6787159e-goog

