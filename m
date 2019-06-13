Return-Path: <SRS0=7jwN=UM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E23F1C31E45
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 10:46:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A8F892173C
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 10:46:10 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="C5JSD5n4"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A8F892173C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3C5E26B0269; Thu, 13 Jun 2019 06:46:10 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 34F3F6B026A; Thu, 13 Jun 2019 06:46:10 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1F0416B026B; Thu, 13 Jun 2019 06:46:10 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id D787D6B0269
	for <linux-mm@kvack.org>; Thu, 13 Jun 2019 06:46:09 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id d2so11689382pla.18
        for <linux-mm@kvack.org>; Thu, 13 Jun 2019 03:46:09 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references;
        bh=pd2UgfTEjIEqeOaghBSIw7YbVcG8PFXXSl39qx+Thxw=;
        b=WkXo1O/U3Nj4FIlwfvBlIjOhXxZuPVoWFyoxi7I7AnMi2p8urrH4G4JRJlZtnJagmG
         SM6wLkWuvHdGEhwT0jiQFz5EQ3AhsfVRt+twqYndjn0wteL4mvXMa6pK9j0rN2J1sr4I
         j4UiT6IlgULXU5OYv10buHsrFGj4zprcQy7Q+L7XcUX2Hv2AuDRfvAt7nmNlmRbYQmQt
         JBybvRgxjt8SxIbb6Z2kDRPexiQyQ+ynJi6EYqCzzLg6MRs6PgQFTRumtCIxHzGBytPf
         nvkmS1dVX5y6Ia0/pJfuO1VP5nNZ1LYBZnay57aqwgkw0AiwKagrcHkXXnmiqShA6Tmu
         5bLA==
X-Gm-Message-State: APjAAAVrXBkYB2NNJnKqD/vRfiWvdcr/6Ezv1Aiu+jOdsEeLXKzQvcZx
	fqZVi6NTJe+sXDBr4VPyx19EqVhsxo56uX6xwACC7GhzVq8tNUuIsy/oott9pRuZu476HfAKsSC
	QIUhc3Qx7+9qQX+tkqMgW+nsBTZHMVmytYk3FnJWmmDMBp8kZQTnlesgqC6NtvEsOBA==
X-Received: by 2002:a17:90a:9905:: with SMTP id b5mr4953748pjp.70.1560422769554;
        Thu, 13 Jun 2019 03:46:09 -0700 (PDT)
X-Received: by 2002:a17:90a:9905:: with SMTP id b5mr4953614pjp.70.1560422768382;
        Thu, 13 Jun 2019 03:46:08 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560422768; cv=none;
        d=google.com; s=arc-20160816;
        b=jsuUGcyPrkhCxDeeQr7zpoqx7ATe2erpMpqta26e+4o/1BZu3pSssnB4PZgpU0yG3b
         oxrW49iDgsbJbHr3RxGNqyWSt6wulXZoW7wD7oPeHb/gQKHIp6J5Vy8xdTSG3fHPu+29
         gZzEI8zHPIW3rz/7+GMPr4/uqb+Fjnpvw18UsALB0fSfdSDzlMge2CCca3rS4UWEZ9/p
         aBiioajfSaFXzSdeiHTMxF7msK16hyQwY7+5TjhHaC2s9hqrqX5JQA3/NmrGvPXI6co1
         qL771NRei6+m9w84WgB77MUk57AUAM+ux6/XFkp7JV36H5renz0v765SzQFeCAfDPCfa
         zYGw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from
         :dkim-signature;
        bh=pd2UgfTEjIEqeOaghBSIw7YbVcG8PFXXSl39qx+Thxw=;
        b=wG+ANmgmdfLKSJG8rRUuwCxSqSpyHUt/6YgnF6Gmg4O8SMm71FHEHs3TQKuYwoZDPr
         QNR7oMc5Nv/Uv72q5y5fcRBzfrL0BrNCIHh2z1n0d53HnOaWBAdHyfy9v2a6Nj+7JmS0
         7dFuc6mcXpNMuVvRIqxkuMEjrGsfKIvTO+bLi/S0HU0R8PQckcQixOnzAb3XaVabP0k8
         6xNxpaJAWO7f/q9FVOmxwcpbyk3z4VxrAxf6OC93ImsiqjCmtTShlmdk2Y9uPyoQTGpI
         LDmL3/nwGb/Pvifn9el3VlBQOK/qyv41JkR1LKt/uXmtgs6/spi/fPj2Vkk3TQaSwytN
         v0tg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=C5JSD5n4;
       spf=pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=kernelfans@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id cc5sor2586581plb.73.2019.06.13.03.46.08
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 13 Jun 2019 03:46:08 -0700 (PDT)
Received-SPF: pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=C5JSD5n4;
       spf=pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=kernelfans@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references;
        bh=pd2UgfTEjIEqeOaghBSIw7YbVcG8PFXXSl39qx+Thxw=;
        b=C5JSD5n4A9lSn7ivR28GTiLFczd6Q2dkFHL4BmaZvwF4xDTrtWHt8tMYismMcyg2uL
         y1rFeektXyRR2wpeaWJlCDw1NHIRjkzD34s2ptRzp0+/Kdf9Frgc3DRtKp5qJoZUw6qa
         MGIqdLmFUHu3zMfzfxWlOd0dAMEDV1H4hxiRRuzK5tN8W6+kg02efURm2aAv+duHDcf8
         +IFdFr0OGdxP7AgFi8gJcL6BB204Je13VF+cOBZwXJouh1qpMrXK6UFIl/Czaepdx8av
         jlgK12fmk34hSjNQaRWPPXxw29ULIxRdwPKsqdpk0lUjzURt+yKoJfflmG/sTo6897ho
         QCxw==
X-Google-Smtp-Source: APXvYqyzzGjKho8nXPrUGm5asBy3qMNefeXotTwKcWnKkde5GEq3MJbTFtzDQgF+NAQZL9mqvTXLkA==
X-Received: by 2002:a17:902:583:: with SMTP id f3mr24314348plf.137.1560422767994;
        Thu, 13 Jun 2019 03:46:07 -0700 (PDT)
Received: from mylaptop.redhat.com ([2408:8207:7825:dd90:9051:d949:55f9:678b])
        by smtp.gmail.com with ESMTPSA id a13sm2813285pgh.6.2019.06.13.03.45.59
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Jun 2019 03:46:07 -0700 (PDT)
From: Pingfan Liu <kernelfans@gmail.com>
To: linux-mm@kvack.org
Cc: Pingfan Liu <kernelfans@gmail.com>,
	Ira Weiny <ira.weiny@intel.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Mike Rapoport <rppt@linux.ibm.com>,
	Dan Williams <dan.j.williams@intel.com>,
	Matthew Wilcox <willy@infradead.org>,
	John Hubbard <jhubbard@nvidia.com>,
	"Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>,
	Keith Busch <keith.busch@intel.com>,
	Christoph Hellwig <hch@infradead.org>,
	Shuah Khan <shuah@kernel.org>,
	linux-kernel@vger.kernel.org
Subject: [PATCHv4 3/3] mm/gup_benchemark: add LONGTERM_BENCHMARK test in gup fast path
Date: Thu, 13 Jun 2019 18:45:02 +0800
Message-Id: <1560422702-11403-4-git-send-email-kernelfans@gmail.com>
X-Mailer: git-send-email 2.7.5
In-Reply-To: <1560422702-11403-1-git-send-email-kernelfans@gmail.com>
References: <1560422702-11403-1-git-send-email-kernelfans@gmail.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Introduce a GUP_LONGTERM_BENCHMARK ioctl to test longterm pin in gup fast
path.

Signed-off-by: Pingfan Liu <kernelfans@gmail.com>
Cc: Ira Weiny <ira.weiny@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Mike Rapoport <rppt@linux.ibm.com>
Cc: Dan Williams <dan.j.williams@intel.com>
Cc: Matthew Wilcox <willy@infradead.org>
Cc: John Hubbard <jhubbard@nvidia.com>
Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
Cc: Keith Busch <keith.busch@intel.com>
Cc: Christoph Hellwig <hch@infradead.org>
Cc: Shuah Khan <shuah@kernel.org>
Cc: linux-kernel@vger.kernel.org
---
 mm/gup_benchmark.c                         | 11 +++++++++--
 tools/testing/selftests/vm/gup_benchmark.c | 10 +++++++---
 2 files changed, 16 insertions(+), 5 deletions(-)

diff --git a/mm/gup_benchmark.c b/mm/gup_benchmark.c
index 7dd602d..83f3378 100644
--- a/mm/gup_benchmark.c
+++ b/mm/gup_benchmark.c
@@ -6,8 +6,9 @@
 #include <linux/debugfs.h>
 
 #define GUP_FAST_BENCHMARK	_IOWR('g', 1, struct gup_benchmark)
-#define GUP_LONGTERM_BENCHMARK	_IOWR('g', 2, struct gup_benchmark)
-#define GUP_BENCHMARK		_IOWR('g', 3, struct gup_benchmark)
+#define GUP_FAST_LONGTERM_BENCHMARK	_IOWR('g', 2, struct gup_benchmark)
+#define GUP_LONGTERM_BENCHMARK	_IOWR('g', 3, struct gup_benchmark)
+#define GUP_BENCHMARK		_IOWR('g', 4, struct gup_benchmark)
 
 struct gup_benchmark {
 	__u64 get_delta_usec;
@@ -53,6 +54,11 @@ static int __gup_benchmark_ioctl(unsigned int cmd,
 			nr = get_user_pages_fast(addr, nr, gup->flags & 1,
 						 pages + i);
 			break;
+		case GUP_FAST_LONGTERM_BENCHMARK:
+			nr = get_user_pages_fast(addr, nr,
+					(gup->flags & 1) | FOLL_LONGTERM,
+					 pages + i);
+			break;
 		case GUP_LONGTERM_BENCHMARK:
 			nr = get_user_pages(addr, nr,
 					    (gup->flags & 1) | FOLL_LONGTERM,
@@ -96,6 +102,7 @@ static long gup_benchmark_ioctl(struct file *filep, unsigned int cmd,
 
 	switch (cmd) {
 	case GUP_FAST_BENCHMARK:
+	case GUP_FAST_LONGTERM_BENCHMARK:
 	case GUP_LONGTERM_BENCHMARK:
 	case GUP_BENCHMARK:
 		break;
diff --git a/tools/testing/selftests/vm/gup_benchmark.c b/tools/testing/selftests/vm/gup_benchmark.c
index c0534e2..ade8acb 100644
--- a/tools/testing/selftests/vm/gup_benchmark.c
+++ b/tools/testing/selftests/vm/gup_benchmark.c
@@ -15,8 +15,9 @@
 #define PAGE_SIZE sysconf(_SC_PAGESIZE)
 
 #define GUP_FAST_BENCHMARK	_IOWR('g', 1, struct gup_benchmark)
-#define GUP_LONGTERM_BENCHMARK	_IOWR('g', 2, struct gup_benchmark)
-#define GUP_BENCHMARK		_IOWR('g', 3, struct gup_benchmark)
+#define GUP_FAST_LONGTERM_BENCHMARK	_IOWR('g', 2, struct gup_benchmark)
+#define GUP_LONGTERM_BENCHMARK	_IOWR('g', 3, struct gup_benchmark)
+#define GUP_BENCHMARK		_IOWR('g', 4, struct gup_benchmark)
 
 struct gup_benchmark {
 	__u64 get_delta_usec;
@@ -37,7 +38,7 @@ int main(int argc, char **argv)
 	char *file = "/dev/zero";
 	char *p;
 
-	while ((opt = getopt(argc, argv, "m:r:n:f:tTLUSH")) != -1) {
+	while ((opt = getopt(argc, argv, "m:r:n:f:tTlLUSH")) != -1) {
 		switch (opt) {
 		case 'm':
 			size = atoi(optarg) * MB;
@@ -54,6 +55,9 @@ int main(int argc, char **argv)
 		case 'T':
 			thp = 0;
 			break;
+		case 'l':
+			cmd = GUP_FAST_LONGTERM_BENCHMARK;
+			break;
 		case 'L':
 			cmd = GUP_LONGTERM_BENCHMARK;
 			break;
-- 
2.7.5

