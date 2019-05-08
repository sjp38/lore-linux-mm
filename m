Return-Path: <SRS0=OmxZ=TI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BC7EEC04A6B
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 14:47:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 72AE2216F4
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 14:47:55 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 72AE2216F4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 73F156B02D7; Wed,  8 May 2019 10:46:53 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6A0426B02D9; Wed,  8 May 2019 10:46:53 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 58F576B02DA; Wed,  8 May 2019 10:46:53 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 1DED26B02D9
	for <linux-mm@kvack.org>; Wed,  8 May 2019 10:46:53 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id x13so12801228pgl.10
        for <linux-mm@kvack.org>; Wed, 08 May 2019 07:46:53 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=gHNz/kCOwnG9rzVvAEsX8yaXn6m+YaYxBKDTK443Tfo=;
        b=roJu3I1fhQZALzobxatXivVk5DXtENL6ph4Ld+SflGmYMpscY6jw2ucDZINaCVuuYP
         zaEFWGHnIFEKIauVQ6gEEgLA7LIDh6XPS0+MkpW5So75EJUhYaPUzAtrlr9/qObsRykp
         Nrhrcheyhk6/RKrd4KoQrH9WhSoasCRaDS9hTioJevLIbGyNRXVozw+X1nHvk5SLBWdc
         4D4KejGdbAew06YNPxc8rJqM145KVZ9qbv/an1/9m7g/fBw20q3HbkhVNwLrGKk1aZy/
         UfstEauIVhpQZRlrGfp+O54SzLbS/aiWyGj64baXbnlpMlNjMQG6yao6DOU0Gwx95+Fw
         Wykg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of kirill.shutemov@linux.intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=kirill.shutemov@linux.intel.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAWLNcaDJA4veeK+G0c7k5d+CgComHaSreQjQADJxbCPkX26gyip
	E8sNHzNa08zoAcvewkNL23/DO/hrdIo3CCvqMiq9/Pv3JEtvc37XJeqsSGqZVHgk/aSqKfhwua1
	3MTqYOMvyHbmt5dCWMltUQ7tW5/YcvSCNYdcPBVlUXxzNC3Of/MGoiD6SZLelUL6yZQ==
X-Received: by 2002:a62:6842:: with SMTP id d63mr50169246pfc.9.1557326812737;
        Wed, 08 May 2019 07:46:52 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwlhj7TiXaO8N9P0eS2kBNAfgCYTU/NTGFb7DhAbPfFcvR2B6EfmHroHRPST02N3ZYFcZVJ
X-Received: by 2002:a62:6842:: with SMTP id d63mr50154277pfc.9.1557326690597;
        Wed, 08 May 2019 07:44:50 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557326690; cv=none;
        d=google.com; s=arc-20160816;
        b=M2Sk7WqkvnQCxBXfYtVF4CS+AFq8o5P6mjrnsFpepUlZpFdw2tWcw0Z41Ekdtv/FxW
         t0pR6STt+J1ew6W9Cba4mN1DiAy70o7i86LNROnQo3qV7fiRdrAU4fDjmqNg8GZ+xXwC
         VlIIBy/hUvPCW6n7c4v/3oCvqDN92vO5tpKZeexslLgXe+h7luuawmCzs0KuyUfWmIJO
         5VA/+c5DY8qTfATM+xHK37jsSjjYFlcbSBtOXFolr/TDfLbz8hW+xIwPP3E5bhF2sZ9z
         Se06ngCfb9zukAX4mGe+h2fAAoK81jQFk2rMp07s8BYr6NjpDxLu6qgUJG4XUto4m5hJ
         6bVw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=gHNz/kCOwnG9rzVvAEsX8yaXn6m+YaYxBKDTK443Tfo=;
        b=oqENP1aetGDV+TsYmu5kzFgDtQtLsmtF2CZ7h7VNdca8sXojcDC5giVivah/CS6MO9
         Gwu+pry0vZbpgRR1GATbLt8nlwkAFDySxh0E2Ap3s3gpHJ9xd6YBVaivRbfqsUfXE63q
         PeCMn6TokyNRKIzmNdKiVqUxgopggeP/P3wip7lCGwlIpXz0AfyADTIbsl7yPcj0fl2n
         vKBxiwcUCfz1FuNT2V18tFDmlUE5Zu0xyUqr9jg7q4NZcS84PzuO8uTi53o7japlBKO+
         p2SHV5pqT9UiOe3XaoauRQjVdxzjrXtpWvD7Az3LeQay0KUQjyBlhs5WU8NXTqZNFoz0
         gG3Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of kirill.shutemov@linux.intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=kirill.shutemov@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id q8si24066889pgf.3.2019.05.08.07.44.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 May 2019 07:44:50 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of kirill.shutemov@linux.intel.com designates 134.134.136.20 as permitted sender) client-ip=134.134.136.20;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of kirill.shutemov@linux.intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=kirill.shutemov@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga002.jf.intel.com ([10.7.209.21])
  by orsmga101.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 08 May 2019 07:44:50 -0700
X-ExtLoop1: 1
Received: from black.fi.intel.com ([10.237.72.28])
  by orsmga002.jf.intel.com with ESMTP; 08 May 2019 07:44:45 -0700
Received: by black.fi.intel.com (Postfix, from userid 1000)
	id 19F92F6E; Wed,  8 May 2019 17:44:31 +0300 (EEST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
To: Andrew Morton <akpm@linux-foundation.org>,
	x86@kernel.org,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Borislav Petkov <bp@alien8.de>,
	Peter Zijlstra <peterz@infradead.org>,
	Andy Lutomirski <luto@amacapital.net>,
	David Howells <dhowells@redhat.com>
Cc: Kees Cook <keescook@chromium.org>,
	Dave Hansen <dave.hansen@intel.com>,
	Kai Huang <kai.huang@linux.intel.com>,
	Jacob Pan <jacob.jun.pan@linux.intel.com>,
	Alison Schofield <alison.schofield@intel.com>,
	linux-mm@kvack.org,
	kvm@vger.kernel.org,
	keyrings@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	"Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH, RFC 47/62] mm: Restrict MKTME memory encryption to anonymous VMAs
Date: Wed,  8 May 2019 17:44:07 +0300
Message-Id: <20190508144422.13171-48-kirill.shutemov@linux.intel.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190508144422.13171-1-kirill.shutemov@linux.intel.com>
References: <20190508144422.13171-1-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Alison Schofield <alison.schofield@intel.com>

Memory encryption is only supported for mappings that are ANONYMOUS.
Test the VMA's in an encrypt_mprotect() request to make sure they all
meet that requirement before encrypting any.

The encrypt_mprotect syscall will return -EINVAL and will not encrypt
any VMA's if this check fails.

Signed-off-by: Alison Schofield <alison.schofield@intel.com>
Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 mm/mprotect.c | 24 ++++++++++++++++++++++++
 1 file changed, 24 insertions(+)

diff --git a/mm/mprotect.c b/mm/mprotect.c
index 38d766b5cc20..53bd41f99a67 100644
--- a/mm/mprotect.c
+++ b/mm/mprotect.c
@@ -346,6 +346,24 @@ static int prot_none_walk(struct vm_area_struct *vma, unsigned long start,
 	return walk_page_range(start, end, &prot_none_walk);
 }
 
+/*
+ * Encrypted mprotect is only supported on anonymous mappings.
+ * If this test fails on any single VMA, the entire mprotect
+ * request fails.
+ */
+static bool mem_supports_encryption(struct vm_area_struct *vma, unsigned long end)
+{
+	struct vm_area_struct *test_vma = vma;
+
+	do {
+		if (!vma_is_anonymous(test_vma))
+			return false;
+
+		test_vma = test_vma->vm_next;
+	} while (test_vma && test_vma->vm_start < end);
+	return true;
+}
+
 int
 mprotect_fixup(struct vm_area_struct *vma, struct vm_area_struct **pprev,
 	       unsigned long start, unsigned long end, unsigned long newflags,
@@ -532,6 +550,12 @@ static int do_mprotect_ext(unsigned long start, size_t len,
 				goto out;
 		}
 	}
+
+	if (keyid > 0 && !mem_supports_encryption(vma, end)) {
+		error = -EINVAL;
+		goto out;
+	}
+
 	if (start > vma->vm_start)
 		prev = vma;
 
-- 
2.20.1

