Return-Path: <SRS0=iTus=TK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 55FBDC04A6B
	for <linux-mm@archiver.kernel.org>; Fri, 10 May 2019 07:21:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 125E8217D6
	for <linux-mm@archiver.kernel.org>; Fri, 10 May 2019 07:21:40 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 125E8217D6
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 59AAE6B026A; Fri, 10 May 2019 03:21:38 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 522E96B026B; Fri, 10 May 2019 03:21:38 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 39EAB6B026C; Fri, 10 May 2019 03:21:38 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 0C5836B026A
	for <linux-mm@kvack.org>; Fri, 10 May 2019 03:21:38 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id a12so4680840qkb.3
        for <linux-mm@kvack.org>; Fri, 10 May 2019 00:21:38 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=UYXKxPKXPsTybNC4JZhfndIieIgXto0Au/T3tY/gXyg=;
        b=pnWPnqwnV0EssN1TibGFxLx4ekHgf0wbHAVabCb5bHwcaUi468gk7FjB9jfpdBub/q
         PHtjE19BO+ySKsHArqVeQguG4I/m8kmpj1l9lxQP64ERghmCor0+dIL3hjLHg7seOIHc
         saZTIKHm+ds4ZV1GCEl8aTstPHBMoU80DVQeeu6bshzAwXDh/+qLETgbO6bDk9zxQ2FI
         mMijAbb7FriMv/yq07Ul5mjej9jqc/N742Sw/2VHhsWILrOum8FyH9IIBiGN1iNNwVJ3
         vaZMTaGT9AyIBdlHC8iLU8u4WscpcyJ80Ev67aUQZ8NKLSPqjSFYfpXP6hyfL0aNld33
         rsCA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of oleksandr@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=oleksandr@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAVlj7Wel7hri7EIpAR0odV4NPPRe+BsRzuRBbB3kSMCTHueSUC4
	pFBaSmNMYDeSgyvZJLctu/3HgVE/ZeCpn7+OfQCcqM97dmOk1MO8w2IDr/AlvnfNXnAi9ofsSGx
	RELYyhZEJZF1ZLDqqoZVThOILvMgN5YOS7aRcBSHS9JRrwiuZP0IFKiK+URPQley48w==
X-Received: by 2002:ac8:1671:: with SMTP id x46mr8142681qtk.240.1557472897829;
        Fri, 10 May 2019 00:21:37 -0700 (PDT)
X-Received: by 2002:ac8:1671:: with SMTP id x46mr8142653qtk.240.1557472897209;
        Fri, 10 May 2019 00:21:37 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557472897; cv=none;
        d=google.com; s=arc-20160816;
        b=U27kWFEEcGQZFk5D7I8/os0iZq1i1LXECATQor1w7AH/u60qGHP0If8xUV293zYbJv
         /syEHhlldhKAkh7AUkdxTJxvINmaRro+g2vseKsMR6MZBFJEet7dQ1ok/ifATfPgXUFD
         pzp+e0P6TpDfunQoy/R4RJlLBgjVI971NjtPGqEtHFosxg6h806gJngJo0nqlUMzxonq
         qD6Swr0/VQC6yElbo1sSTcDUXqkWtOvsqtGJa3hswAP6Yy/J4keGaI7b7kbnFPTm0tBJ
         cQcAfHaPdQ42kIOpI5TvXGxytUVT7aILXG65mvGwPYbJDP37ZtgAevD6C/18w2JNodtw
         NmYg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=UYXKxPKXPsTybNC4JZhfndIieIgXto0Au/T3tY/gXyg=;
        b=BqQTRu/9Y/DwptajCOM6RSr4cbwO9Y/TH897zMye1XnYmu3TeNwyUi3G2pfaiZ0Ism
         IHw/blYGkz9Kr5wOsTfiXb7RAihaludjHjxo02EFKia8HYQnScCz9xyGhxF/amr4/q+G
         ntI+KsrEBNZ+MCwP6PRK9MnWc1mQwRJ0DWG3iu39qX+iyCW2IIsLpoWBjaydPsL9VA2/
         V8xKV8oppjcftO9v9E6+ZVeIYqW+r82ES3mhxrNes15TjQUL423qppUg03ka0xViyOSx
         Tsmk6vC63km3PvzRzbAug1NcaQIj6sBBzLhEoifmv840LegA+YVSbkZppz54Y4N5x57t
         3asQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of oleksandr@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=oleksandr@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y12sor3533473qve.24.2019.05.10.00.21.37
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 10 May 2019 00:21:37 -0700 (PDT)
Received-SPF: pass (google.com: domain of oleksandr@redhat.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of oleksandr@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=oleksandr@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Google-Smtp-Source: APXvYqxw5WeE0e1Tl0rCWVbYdCmPx9jVnpRz2LqMlAgWX6iwo8mnCouCMFYdDyqwFsbfVQdq2npsFA==
X-Received: by 2002:a0c:b907:: with SMTP id u7mr7761329qvf.189.1557472896947;
        Fri, 10 May 2019 00:21:36 -0700 (PDT)
Received: from localhost (nat-pool-brq-t.redhat.com. [213.175.37.10])
        by smtp.gmail.com with ESMTPSA id b19sm2308808qkk.51.2019.05.10.00.21.35
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 10 May 2019 00:21:36 -0700 (PDT)
From: Oleksandr Natalenko <oleksandr@redhat.com>
To: linux-kernel@vger.kernel.org
Cc: Kirill Tkhai <ktkhai@virtuozzo.com>,
	Vlastimil Babka <vbabka@suse.cz>,
	Michal Hocko <mhocko@suse.com>,
	Matthew Wilcox <willy@infradead.org>,
	Pavel Tatashin <pasha.tatashin@oracle.com>,
	Timofey Titovets <nefelim4ag@gmail.com>,
	Aaron Tomlin <atomlin@redhat.com>,
	linux-mm@kvack.org
Subject: [PATCH RFC 4/4] mm/ksm: add automerging documentation
Date: Fri, 10 May 2019 09:21:25 +0200
Message-Id: <20190510072125.18059-5-oleksandr@redhat.com>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190510072125.18059-1-oleksandr@redhat.com>
References: <20190510072125.18059-1-oleksandr@redhat.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Document KSM "always" mode kernel cmdline option as well as
corresponding sysfs knob.

Signed-off-by: Oleksandr Natalenko <oleksandr@redhat.com>
---
 Documentation/admin-guide/kernel-parameters.txt | 7 +++++++
 Documentation/admin-guide/mm/ksm.rst            | 7 +++++++
 2 files changed, 14 insertions(+)

diff --git a/Documentation/admin-guide/kernel-parameters.txt b/Documentation/admin-guide/kernel-parameters.txt
index 2b8ee90bb644..510766a3fa05 100644
--- a/Documentation/admin-guide/kernel-parameters.txt
+++ b/Documentation/admin-guide/kernel-parameters.txt
@@ -2008,6 +2008,13 @@
 			0: force disabled
 			1: force enabled
 
+	ksm_mode=
+			[KNL]
+			Format: [madvise|always]
+			Default: madvise
+			Can be used to control the default behavior of the system
+			with respect to merging anonymous memory.
+
 	kvm.ignore_msrs=[KVM] Ignore guest accesses to unhandled MSRs.
 			Default is 0 (don't ignore, but inject #GP)
 
diff --git a/Documentation/admin-guide/mm/ksm.rst b/Documentation/admin-guide/mm/ksm.rst
index 9303786632d1..9af730640da7 100644
--- a/Documentation/admin-guide/mm/ksm.rst
+++ b/Documentation/admin-guide/mm/ksm.rst
@@ -78,6 +78,13 @@ KSM daemon sysfs interface
 The KSM daemon is controlled by sysfs files in ``/sys/kernel/mm/ksm/``,
 readable by all but writable only by root:
 
+mode
+        * set madvise to deduplicate only madvised memory
+        * set always to allow deduplicating all the anonymous memory
+          (applies to newly allocated memory only)
+
+        Default: madvise (maintains old behaviour)
+
 pages_to_scan
         how many pages to scan before ksmd goes to sleep
         e.g. ``echo 100 > /sys/kernel/mm/ksm/pages_to_scan``.
-- 
2.21.0

