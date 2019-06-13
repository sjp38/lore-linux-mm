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
	by smtp.lore.kernel.org (Postfix) with ESMTP id C07C5C31E45
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 10:45:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 85F1C2173C
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 10:45:52 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="BYU4x/H5"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 85F1C2173C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 06A936B000D; Thu, 13 Jun 2019 06:45:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F367B6B000E; Thu, 13 Jun 2019 06:45:51 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DB1066B0010; Thu, 13 Jun 2019 06:45:51 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 9FBD46B000D
	for <linux-mm@kvack.org>; Thu, 13 Jun 2019 06:45:51 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id 140so14170264pfa.23
        for <linux-mm@kvack.org>; Thu, 13 Jun 2019 03:45:51 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references;
        bh=f93IclPUPcs3Bt3TjEqqUNMcFkImDI5CNRnqLCqc+P8=;
        b=YkOJKUP3+YAi04z3VJyCWGC3lvMNay2Qj3JCOnoEwSJlF6qLRtGCwPziOE0ItPZYah
         XnY2EvgQI4FrFSzrn8DL1gH64nzeXqzkPQ3cb5tu0m38XNG2ScBIZW2UzwGyx0BsjDCG
         0mvgOngT8Bk5xaFm/bCUngdwSHeXKC3eJqz7EX63Uq82/wzcI4foyyjqZLDX6pzYYyAF
         aeUKNlXh4lS3R3CxjWROtTqh2VWo4AyH9r6/bXVmgGP9B+GOH1G7qXBocaNNcLdPqqg2
         B3wQ7baaesLQ8Os7Pu93IV956gIAWPWey/eH6G4lF0ZmsSHu4Kae4V2QzT5QQlh2ieqY
         Z1NA==
X-Gm-Message-State: APjAAAWSmDTRvvBIfU0OD+FDl7NrZFAbthi35f3NqTiQugMGOffWcXI+
	IkpPwxYUk58AwYGPt5OqD0JvaULW+8H3Ns/gFmRj3S98k4O+MyDG4UauBHm59O4juWDhBm4FrPc
	IYJgn5/BrABdFP1z9Z9InAoc5cZPo7cp+1RctF5yopGQIvwpw4UKonWMKZgeaY3AMcQ==
X-Received: by 2002:a63:68b:: with SMTP id 133mr28665248pgg.385.1560422751159;
        Thu, 13 Jun 2019 03:45:51 -0700 (PDT)
X-Received: by 2002:a63:68b:: with SMTP id 133mr28665133pgg.385.1560422750040;
        Thu, 13 Jun 2019 03:45:50 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560422750; cv=none;
        d=google.com; s=arc-20160816;
        b=Dgcj20HzzbW7mHaLimwS9HzePDg9qeNP5TsnFCmw7PS6+UWJ31DuHKXF6nC18QM9Ok
         0IFMOL8noQmxo0kj7Pa8Dl9+bVjeCj0eHhVHxa/jAHOfnavK7LSGHqx2UPLRP4Ar4TB4
         gx14f1pgupAElF4FRn39cmWHPO9s2zOhmdExvTOTNz1sJ7y69V1N/l6+9OXmWGhbV0Sx
         EwAC5gg/Ep60bB3n9NUkgM1woQmo1t97+tn8I4HAwZxvShcLEb20HR6+UxutJ57WIr/K
         aou/Eh3zaUyawH7rN5Zvpsh0Q2McKW+JpUeyY7ZAF7Jjh9B1aufb5B7DaoO2W4yrq3rQ
         Y+xQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from
         :dkim-signature;
        bh=f93IclPUPcs3Bt3TjEqqUNMcFkImDI5CNRnqLCqc+P8=;
        b=toAEV2C3buT7M+g63HvV4QkNBQFRFxb+B7ihdLmJ2B5jsb7sHsluzYMDpxrgOWUc47
         Ge+8ookuBjxt6R7GKTHJksCPYXKwDU3Mz53jfnHONL1MNfjsm58g/wtpFIsXtWrHML/u
         od7IiHWwiooOFpOR0lfkpUxmBQYZ+o1YVWuOIBY045q5pAx/+5wWLELjZglwwDGr9ssp
         SlqRkoh/rmeI89BM1SyVeoRAxZsElHoQIW1inHg/tkFetsWW+/IJBcbJSpBZwRjdsTjk
         CBkCYsZFp21s5/E4VUQWotwbFvZFJqUi6CXwxinqTpKgzw7QfO7qaPVO87Ls0vcFcWok
         NlaA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="BYU4x/H5";
       spf=pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=kernelfans@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q8sor2597362pll.16.2019.06.13.03.45.49
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 13 Jun 2019 03:45:50 -0700 (PDT)
Received-SPF: pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="BYU4x/H5";
       spf=pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=kernelfans@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references;
        bh=f93IclPUPcs3Bt3TjEqqUNMcFkImDI5CNRnqLCqc+P8=;
        b=BYU4x/H5A/U1vDb2iAJXDaxX8mJ03+iBLBS2s7wEPWjYRW/6/REj+tyFh+ON5yPvJo
         tiCoiYOkqYP+kp556mYNnSX3QOkg5moTm3N6xbZw/Yrrj8L8vCoFdZF01ln2Kg1TSJ20
         l8yyAkVj8u1bv0D1tNhG8nVVbabbFkU6NKgh91Yw/+sfinCHWixpfmjN3+L8OCqLFdT5
         QtU1EFgQvcT1b2S+3dIO4h7MkzFXjGN/IczhQ4oDdb75vFwLc5ZAgem35ipiyzKI9zPX
         VpM54MBVxi/MPr7DE9sfD6fGln7FmUlJGPt2eA9X1qTtZGyKbN356+9p/3dkHHqR5suj
         WN0A==
X-Google-Smtp-Source: APXvYqzjzG1IExx5QhEFhc3PhY3IWUPkhfXxSPgDIyhVJDO97u6bC7ct5htX5h5CIaSIaAPehBv3WA==
X-Received: by 2002:a17:902:b695:: with SMTP id c21mr34964938pls.160.1560422749562;
        Thu, 13 Jun 2019 03:45:49 -0700 (PDT)
Received: from mylaptop.redhat.com ([2408:8207:7825:dd90:9051:d949:55f9:678b])
        by smtp.gmail.com with ESMTPSA id a13sm2813285pgh.6.2019.06.13.03.45.40
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Jun 2019 03:45:48 -0700 (PDT)
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
Subject: [PATCHv4 1/3] mm/gup: rename nr as nr_pinned in get_user_pages_fast()
Date: Thu, 13 Jun 2019 18:45:00 +0800
Message-Id: <1560422702-11403-2-git-send-email-kernelfans@gmail.com>
X-Mailer: git-send-email 2.7.5
In-Reply-To: <1560422702-11403-1-git-send-email-kernelfans@gmail.com>
References: <1560422702-11403-1-git-send-email-kernelfans@gmail.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

To better reflect the held state of pages and make code self-explaining,
rename nr as nr_pinned.

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
 mm/gup.c | 20 ++++++++++----------
 1 file changed, 10 insertions(+), 10 deletions(-)

diff --git a/mm/gup.c b/mm/gup.c
index f173fcb..766ae54 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -2216,7 +2216,7 @@ int get_user_pages_fast(unsigned long start, int nr_pages,
 			unsigned int gup_flags, struct page **pages)
 {
 	unsigned long addr, len, end;
-	int nr = 0, ret = 0;
+	int nr_pinned = 0, ret = 0;
 
 	start &= PAGE_MASK;
 	addr = start;
@@ -2231,25 +2231,25 @@ int get_user_pages_fast(unsigned long start, int nr_pages,
 
 	if (gup_fast_permitted(start, nr_pages)) {
 		local_irq_disable();
-		gup_pgd_range(addr, end, gup_flags, pages, &nr);
+		gup_pgd_range(addr, end, gup_flags, pages, &nr_pinned);
 		local_irq_enable();
-		ret = nr;
+		ret = nr_pinned;
 	}
 
-	if (nr < nr_pages) {
+	if (nr_pinned < nr_pages) {
 		/* Try to get the remaining pages with get_user_pages */
-		start += nr << PAGE_SHIFT;
-		pages += nr;
+		start += nr_pinned << PAGE_SHIFT;
+		pages += nr_pinned;
 
-		ret = __gup_longterm_unlocked(start, nr_pages - nr,
+		ret = __gup_longterm_unlocked(start, nr_pages - nr_pinned,
 					      gup_flags, pages);
 
 		/* Have to be a bit careful with return values */
-		if (nr > 0) {
+		if (nr_pinned > 0) {
 			if (ret < 0)
-				ret = nr;
+				ret = nr_pinned;
 			else
-				ret += nr;
+				ret += nr_pinned;
 		}
 	}
 
-- 
2.7.5

