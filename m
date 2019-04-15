Return-Path: <SRS0=aXoD=SR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8DB4FC10F12
	for <linux-mm@archiver.kernel.org>; Mon, 15 Apr 2019 18:19:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2EA442073F
	for <linux-mm@archiver.kernel.org>; Mon, 15 Apr 2019 18:19:19 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=android.com header.i=@android.com header.b="ZJpcX7CF"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2EA442073F
Authentication-Results: mail.kernel.org; dmarc=fail (p=quarantine dis=none) header.from=android.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 90D9D6B0003; Mon, 15 Apr 2019 14:19:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8BC4A6B0006; Mon, 15 Apr 2019 14:19:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7AA976B0007; Mon, 15 Apr 2019 14:19:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 43A986B0003
	for <linux-mm@kvack.org>; Mon, 15 Apr 2019 14:19:18 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id 14so10843039pgf.22
        for <linux-mm@kvack.org>; Mon, 15 Apr 2019 11:19:18 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=+9Ht1OHIulmBLnDv7fAGUcF+vOqeIANUhm3itrm+sZ4=;
        b=MXbamPK5IAUcOGtIsum8m7s5hqpRbkTShe5xZQWibXTgWqPEWjt5huEGuKm8ZDr8G+
         +Q+sXB7jQGiFrRtgCzhxmDGUwzBEiKB4ZXcbKCFHW7O+7ytnU6nk5gnEL5e6VWTeDAY0
         NapiOtABK8VkNQ2V3Dl4gYk4+lq2PEFPn1hm43+skI8DIEzJJi2IZmIc5MD/qpwOMnya
         /Eil9tvfSG26Cv9EuDs2cC1yRm35eCHouqzpV0ZW99zw3dow4jFJkN1srQ7r3A9Adl1b
         H97FYHDNR0lY71FGWuP+8H6pEsrCEBPRuwDEoa1ZjQWQWreCJNoTPJYDPm4wUtpKS2+M
         sCIA==
X-Gm-Message-State: APjAAAXGaEzjTZwnLfzoOGiiQN43m1DtOxTVMtS+9iROq8pDNLzQNRbQ
	NFD18AYKMMW1gnUbHoWMBStWTbs2S0c9EtXHooPZdYOaZOrvQfM/DdYIYwf3fCkg8QSZY90WKQj
	zg+frwn+O2tR2kx1MUySSuBdLsSRMKJKhducct3I5NuAZHRvXJhbULIo9+YIsYO2TZg==
X-Received: by 2002:aa7:81d0:: with SMTP id c16mr78175874pfn.132.1555352357848;
        Mon, 15 Apr 2019 11:19:17 -0700 (PDT)
X-Received: by 2002:aa7:81d0:: with SMTP id c16mr78175798pfn.132.1555352357065;
        Mon, 15 Apr 2019 11:19:17 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555352357; cv=none;
        d=google.com; s=arc-20160816;
        b=W5ApVgbaBjvlMt7mwAok+eZtCVMMgXTtvDUBg6aSCnjrCifNUZF+A5Kq02M94Rc430
         hzmTVOuu433/wOJrouH8uGqFkbjKiIpxp3AW80k3ihpqCp1O+668HslUE2VJosGbI4cj
         4/XGxfsobDKuz7QnCo0All/jkSPPWHSCOsVYSjYAzYkJNNwS7yhLKkU69Rzf0ltaADGo
         t7viDgXkSc17OwH5yPcvgFmWcgBTI2v5Q+jvmxlYKHTah6F7J+CFND1LgJk77Te0FVFI
         UJkA1N0n8OPTnBh11O7IaN8tDL+BSkt9Arvx6DT6WyTZe/W3NQqavOaJcXQ6Ly70lMRB
         Szyg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=+9Ht1OHIulmBLnDv7fAGUcF+vOqeIANUhm3itrm+sZ4=;
        b=C0LWJ17mVii/msYVNDhhvkSjRxJvw69pHbKPXAUAYVChaS1mzdSlH/xICyVv7bfvf2
         o1+9msPgfbp/vWAO2NoCJ5X6mQ2cq1BBfkwXjq3WJopzcT6RIutL+m/DQ4UIou37oVbc
         QkWyAGsIEc1EEESn3hRrcE+4jHjZsI1WAf/HdlyUXqAcdJHVuI3pqnhQKYY+r/pAKMm3
         wknt/oPUDWj29Bw08mnRQchc3e11HMbwUbEjoVXN6YFM+JHAfHqFXGo++o+/WD5GKBi9
         65zSFd6EJBVzELDgm+gE0cXi1NuXivnuPrJZ0fPjAz3YL0NWBtWnpcszwvNUh7uehzce
         iCuw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@android.com header.s=20161025 header.b=ZJpcX7CF;
       spf=pass (google.com: domain of trong@android.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=trong@android.com;
       dmarc=pass (p=QUARANTINE sp=QUARANTINE dis=NONE) header.from=android.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id bj5sor65100072plb.25.2019.04.15.11.19.16
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 15 Apr 2019 11:19:17 -0700 (PDT)
Received-SPF: pass (google.com: domain of trong@android.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@android.com header.s=20161025 header.b=ZJpcX7CF;
       spf=pass (google.com: domain of trong@android.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=trong@android.com;
       dmarc=pass (p=QUARANTINE sp=QUARANTINE dis=NONE) header.from=android.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=android.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=+9Ht1OHIulmBLnDv7fAGUcF+vOqeIANUhm3itrm+sZ4=;
        b=ZJpcX7CFaA/SzdYQArwo16RrEwT6AmVLiurkUxOtihCx42136OHaeIeVrBbMd7tXDT
         QJoA5ns0gViTJCSYZ7/N7v1TDbwgNH4SYlXiBBDCfXmOq8ks11Hr6aJU3cixQiqHAMo2
         H62cjKpODBovqRczfNr/t04uWmodnBt7yT7AJ4gaPh0BVz8McXHfy+XcGmpm9FwdZAqk
         odqTZ/QDitN0cVRSd8gpAY9BuiOglECS9zzDxJIqv+h66Bk4NFO7pw1a1CqFHpM7+trp
         A7aPwxu3ftxSwhJHTFTIAYKMtqKQvrZ92r26psduusyim7SQw9Xm6A30kspqTj3aR2kv
         /NaQ==
X-Google-Smtp-Source: APXvYqzic8cbbXK5yK4cvKOPKGfd0ZBC6paV7mqvYOErTUK5I3H8jQtDeHnxH3vhHnOw5FQzDS5Eaw==
X-Received: by 2002:a17:902:703:: with SMTP id 3mr77828574pli.224.1555352356491;
        Mon, 15 Apr 2019 11:19:16 -0700 (PDT)
Received: from trong0.mtv.corp.google.com ([2620:0:1000:1601:c43f:8c1b:f6ef:3dce])
        by smtp.gmail.com with ESMTPSA id r87sm110873788pfa.71.2019.04.15.11.19.15
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Apr 2019 11:19:15 -0700 (PDT)
From: Tri Vo <trong@android.com>
To: jeyu@kernel.org
Cc: ndesaulniers@google.com,
	ghackmann@android.com,
	linux-mm@kvack.org,
	kbuild-all@01.org,
	rdunlap@infradead.org,
	lkp@intel.com,
	linux-kernel@vger.kernel.org,
	pgynther@google.com,
	willy@infradead.org,
	oberpar@linux.ibm.com,
	akpm@linux-foundation.org,
	Tri Vo <trong@android.com>
Subject: [PATCH v2] module: add stubs for within_module functions
Date: Mon, 15 Apr 2019 11:18:33 -0700
Message-Id: <20190415181833.101222-1-trong@android.com>
X-Mailer: git-send-email 2.21.0.392.gf8f6787159e-goog
In-Reply-To: <20190415142229.GA14330@linux-8ccs>
References: <20190415142229.GA14330@linux-8ccs>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Provide stubs for within_module_core(), within_module_init(), and
within_module() to prevent build errors when !CONFIG_MODULES.

v2:
- Generalized commit message, as per Jessica.
- Stubs for within_module_core() and within_module_init(), as per Nick.

Suggested-by: Matthew Wilcox <willy@infradead.org>
Reported-by: Randy Dunlap <rdunlap@infradead.org>
Reported-by: kbuild test robot <lkp@intel.com>
Link: https://marc.info/?l=linux-mm&m=155384681109231&w=2
Signed-off-by: Tri Vo <trong@android.com>
---
 include/linux/module.h | 17 +++++++++++++++++
 1 file changed, 17 insertions(+)

diff --git a/include/linux/module.h b/include/linux/module.h
index 5bf5dcd91009..35d83765bfbd 100644
--- a/include/linux/module.h
+++ b/include/linux/module.h
@@ -709,6 +709,23 @@ static inline bool is_module_text_address(unsigned long addr)
 	return false;
 }
 
+static inline bool within_module_core(unsigned long addr,
+				      const struct module *mod)
+{
+	return false;
+}
+
+static inline bool within_module_init(unsigned long addr,
+				      const struct module *mod)
+{
+	return false;
+}
+
+static inline bool within_module(unsigned long addr, const struct module *mod)
+{
+	return false;
+}
+
 /* Get/put a kernel symbol (calls should be symmetric) */
 #define symbol_get(x) ({ extern typeof(x) x __attribute__((weak)); &(x); })
 #define symbol_put(x) do { } while (0)
-- 
2.21.0.392.gf8f6787159e-goog

