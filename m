Return-Path: <SRS0=2Grs=V4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EF16DC433FF
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 15:08:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AF986208C3
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 15:08:55 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=shutemov-name.20150623.gappssmtp.com header.i=@shutemov-name.20150623.gappssmtp.com header.b="CKwTGfqf"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AF986208C3
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=shutemov.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9DD7E8E0011; Wed, 31 Jul 2019 11:08:28 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8EF118E0013; Wed, 31 Jul 2019 11:08:28 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 76B048E0011; Wed, 31 Jul 2019 11:08:28 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 15F608E0013
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 11:08:28 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id i9so42581491edr.13
        for <linux-mm@kvack.org>; Wed, 31 Jul 2019 08:08:28 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=xZeKfM6T8HTy5YM9YTF4CgvrEAh9gYOHMqOdjRE0jKs=;
        b=uLAS1+krQpqmiVsB+BfAcFftpVLAiC8wKvk5IYkH3opWr5j0iYgGdkRSgJ384EpS04
         S03yQC/KIIXyJ5J8cSRNHsFIhA3p7FWd7eIQjQMIJ/czfYUTKvtpLNwQg5WX+KY+NCAR
         +NBUdflLKy+P4r0ZAWYJfWRebzl5jsvNowdK2RRPJJFreCjfjq/sYVYs7u0fR+BfliL6
         87CO1xUlOhMios3jg9Soc+WDozH2rShV8eP4oEMih40fzKvD5/vp3DeY6h1jmbcnxOH9
         4NJ2Zu7XZai6aAbg9A7MIETDcp6jT1wN01aa1DExCj/XkwP9UVgaZFScf/TDkvNyf0AL
         VZvQ==
X-Gm-Message-State: APjAAAXgA9RmRLz/pbwh8tL7i9VZ7ltGRmR4T2SOR50W38bl1e377z3U
	oTHZkcyCAr1bGdz//ebj6+RR3B8Wp7NAimNaQ4amv0TvQbd5/hTKr+N3jhgl2AGaE8HysVwwUkN
	rUQ1M1No+5OAQ/eT6Ee/8Bd/4hp+U1W5uSC0KPyScFIBWor3+o/EDjS3ZIwQjPeo=
X-Received: by 2002:a17:906:11d6:: with SMTP id o22mr95661164eja.60.1564585707664;
        Wed, 31 Jul 2019 08:08:27 -0700 (PDT)
X-Received: by 2002:a17:906:11d6:: with SMTP id o22mr95661066eja.60.1564585706666;
        Wed, 31 Jul 2019 08:08:26 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564585706; cv=none;
        d=google.com; s=arc-20160816;
        b=f+dM8hCxjRoto8O9g3IY+2nZcFa8OTQcekOmcTqeoMOT+uWfRwMdzoSS4gk4ALarlB
         6lILt8hyxsfAQt+QhLYpAy5uw36qLmyk2oGq2K3kMENdmGHKX16CFAK5IUWeSAdoooEj
         6GpK6eRmNpssG8ErDFkrW2dxqIZqKQ8x4drKbzVlNiLHjQeXYGjADlSWHqP+7QtNCnpZ
         0+QLwPVxO/0hCl8vsIZS3nWM23H+jLtZ9Fdo/5rd6z6JPzekW7I0yBRw22ZblLRdatVM
         CTND22OfPZblMLM0YYUcub1HS8v4KVQ7vh/1Qd2BZ2Xc5AZ/ciBsR/2dC70478A0P7bb
         C6cA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=xZeKfM6T8HTy5YM9YTF4CgvrEAh9gYOHMqOdjRE0jKs=;
        b=FxZbmsqtfFa3Ma/mFN4SqnM95zNagz3irYOWbv3EatPDitk1JTLaBy2OvQt/gwzluF
         bNnDzSGJiIuhYCJ2ONn10j6FNmNCYEZbeJNQEkva4cViJtt7FE1YkjJH0Osf5fuppB/A
         RkshUnA94LvdQpI+Itv0/f8TrgXT3pneBr9rt/0+tiO4wafZcBwV1/rwMuLLS64mfW03
         dsaeb0rUQB0GtLf/dzB26GDolzv6cmyYemiFLSAUgbbM+HRzCWVZ+l928NzjDNEnXOf4
         mk5vmLjEru9CzU59SND5okZEAPfkfStBAFb/hsjBzNF0aSSuXLtvNWda+n8kNDw4eGek
         1jqQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=CKwTGfqf;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m20sor22690931ejk.32.2019.07.31.08.08.26
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 31 Jul 2019 08:08:26 -0700 (PDT)
Received-SPF: neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=CKwTGfqf;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=shutemov-name.20150623.gappssmtp.com; s=20150623;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=xZeKfM6T8HTy5YM9YTF4CgvrEAh9gYOHMqOdjRE0jKs=;
        b=CKwTGfqftPDIaRPn/xve4w1+BQofkrfeJaRVwasir0N2gaI86NFwFxg8DcKYfpIb/T
         zdNo86h2blPndRDZ0oHF3nNNsbgPZ9ud4MhkHLJUh9aosb3WLdon2l9jywmf1XS3jazD
         g+s2wGJDplnGgg9Qx97RNw21ATe0b/cZO3XgAZrx09sWV5aW3VlaqaOo2g4JU5CT9iwW
         yz2yB+EFutNa/7GS4L0SAD0v5gg+PKoI8gwxEIyl2R8ZLpFFN6/9CPEQuZXLnwQfKbfG
         RkPDW9JM4nmysiqjOl3J1FDnQRNyj344DXF7M/ds/1YTDGBt9yWaHdPd+cmulzWlE01x
         654g==
X-Google-Smtp-Source: APXvYqwyxRQn953dpG335++68BakS/voatLNiC782RPJuiyRVUELnhQKN8Sxlq6UNG5ozqtqFSTkKg==
X-Received: by 2002:a17:906:7013:: with SMTP id n19mr94845741ejj.65.1564585706382;
        Wed, 31 Jul 2019 08:08:26 -0700 (PDT)
Received: from box.localdomain ([86.57.175.117])
        by smtp.gmail.com with ESMTPSA id p15sm10516388ejr.1.2019.07.31.08.08.22
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Jul 2019 08:08:26 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill@shutemov.name>
X-Google-Original-From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Received: by box.localdomain (Postfix, from userid 1000)
	id 80E941030BC; Wed, 31 Jul 2019 18:08:16 +0300 (+03)
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
	"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv2 21/59] mm/page_ext: Export lookup_page_ext() symbol
Date: Wed, 31 Jul 2019 18:07:35 +0300
Message-Id: <20190731150813.26289-22-kirill.shutemov@linux.intel.com>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190731150813.26289-1-kirill.shutemov@linux.intel.com>
References: <20190731150813.26289-1-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

page_keyid() is inline funcation that uses lookup_page_ext(). KVM is
going to use page_keyid() and since KVM can be built as a module
lookup_page_ext() has to be exported.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 mm/page_ext.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/mm/page_ext.c b/mm/page_ext.c
index c52b77c13cd9..eeca218891e7 100644
--- a/mm/page_ext.c
+++ b/mm/page_ext.c
@@ -139,6 +139,7 @@ struct page_ext *lookup_page_ext(const struct page *page)
 					MAX_ORDER_NR_PAGES);
 	return get_entry(base, index);
 }
+EXPORT_SYMBOL_GPL(lookup_page_ext);
 
 static int __init alloc_node_page_ext(int nid)
 {
@@ -209,6 +210,7 @@ struct page_ext *lookup_page_ext(const struct page *page)
 		return NULL;
 	return get_entry(section->page_ext, pfn);
 }
+EXPORT_SYMBOL_GPL(lookup_page_ext);
 
 static void *__meminit alloc_page_ext(size_t size, int nid)
 {
-- 
2.21.0

