Return-Path: <SRS0=aa49=T6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 52768C28CC2
	for <linux-mm@archiver.kernel.org>; Thu, 30 May 2019 23:13:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 169D42630B
	for <linux-mm@archiver.kernel.org>; Thu, 30 May 2019 23:13:29 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 169D42630B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9D4E16B0282; Thu, 30 May 2019 19:13:28 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 987616B0283; Thu, 30 May 2019 19:13:28 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 875246B0285; Thu, 30 May 2019 19:13:28 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4FFF16B0282
	for <linux-mm@kvack.org>; Thu, 30 May 2019 19:13:28 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id h7so5702774pfq.22
        for <linux-mm@kvack.org>; Thu, 30 May 2019 16:13:28 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:from
         :to:cc:date:message-id:in-reply-to:references:user-agent
         :mime-version:content-transfer-encoding;
        bh=1to0Jqiq9dVqRgEdJfEpfS5IGUBxKlxG9mS5T8zXRtg=;
        b=WmAWQ4z7qq3nmUxs+1veR7yA6Y8naeZsR+s1Tj4MbTVB/WroOt9LlmR/NOdukFUuyM
         8aLaea5P+D0JEMSuj2N1IK0yDkc2mOXxPQ93sh+k6vUtD7A45/SrNcPZ2GOVDVWVQpEf
         rMYN/IINC8XxHpVa84/DnLFTy8PT5/u1pelGDJKl8kE/HmzxO0UV7kIwO8aZ4Wv907Tt
         RSIGT5ZZQYEikabm+vVYQPxL0bnuNozNqsZgVm1ZzW2spMiYAr/sx+0LOiK+Bmu3qCTy
         h0PJj+qxKwBceoOJFNdSFq+tItcYCMDUEmCRhzqf4Y1GRB2EgjFmMsJ4BDSvfjtJArt4
         zxPg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dan.j.williams@intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAVCERXxupLm3BssfLBZ5YA4hzeuv6T+SsTTyejWq/yJYI8Lz9t7
	7KPPDFdtTShnWSWDk3Q+jQpVuOanFSJ+T29Ep0zTV/STrU16XwYjSEr26WIhuCTo5KDf71RRrhI
	/j/Z6INHsQGEGJppXfWvl323EyAv1+7jEcogamjqF2bcUN3hDxt6poIVTMxNFXcVfAg==
X-Received: by 2002:a63:c006:: with SMTP id h6mr1722339pgg.368.1559258007940;
        Thu, 30 May 2019 16:13:27 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyKX3gKQRJZNx+hbYSWfyUMued2eLxK0z4/SkYG5zUb9YKulHE9ue+jL/u1/wQI3ocMrIE1
X-Received: by 2002:a63:c006:: with SMTP id h6mr1722274pgg.368.1559258006646;
        Thu, 30 May 2019 16:13:26 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559258006; cv=none;
        d=google.com; s=arc-20160816;
        b=ASXHMsA+6xC0RAdx212myzMssUEoEieB8w/0Ty7fVWhrgVCXigSgKBechNPgWw917t
         q+W+8iqVI/eI8vY5vsSeo173AOfCiWey6oi6mevktcHw7CIhFAR6vmLC4q3Rwd7T9N0c
         +QTPROnhaQRUavlCHzn260pFDaD695Ojy47jbCxZfjyCuTvrMkm51XatTCbTyf4q0m+8
         gkJjeC4B2aAYHub+H17aYe+EY7sYUccO3r9jGoQI6DNpecH0IhBL8iTW7DEe4E346QoJ
         HJsttao9rXu2yuoCsvpAtsa6cnNasw96fOU0yOdfbyMl0k77sG+3rC5k+NbV1kVqKcNJ
         5wDg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:message-id:date:cc:to:from:subject;
        bh=1to0Jqiq9dVqRgEdJfEpfS5IGUBxKlxG9mS5T8zXRtg=;
        b=lJmWEiwOotb29MszN8Mqx8QscwK0/CvB9gLduINqmjfBwvTzdkGXG3v2GFvv1eh8DN
         5C9gxfik5E5xSYVjAA2/44Kw483wllCtps6EwG/LnQqFUQVPu2RSzfYdeEfXqz5P7N2L
         gmNXBho9hwnwInzQu0HWIuoHhOjpWOTD1PceCpYY5FY6p79p4vpMSrFrnxABd+F+YXFe
         DNJCWSJf0f7S2mgXRMa7BVlc7S7IN26N7hqykqd0IPX6RHm2JhXCKwLfXn6t7Picq1DZ
         B88iJyEjfFy76FRAEJ6NiI8NK8dIvHUKlT5Lv7TFx0KYdd1ErTwatVPIX5iSYd4u/o+n
         kFVg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id d75si4519548pfm.259.2019.05.30.16.13.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 30 May 2019 16:13:26 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 192.55.52.120 as permitted sender) client-ip=192.55.52.120;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga002.fm.intel.com ([10.253.24.26])
  by fmsmga104.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 30 May 2019 16:13:26 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.60,532,1549958400"; 
   d="scan'208";a="180115547"
Received: from dwillia2-desk3.jf.intel.com (HELO dwillia2-desk3.amr.corp.intel.com) ([10.54.39.16])
  by fmsmga002.fm.intel.com with ESMTP; 30 May 2019 16:13:25 -0700
Subject: [PATCH v2 3/8] efi: Enumerate EFI_MEMORY_SP
From: Dan Williams <dan.j.williams@intel.com>
To: linux-efi@vger.kernel.org
Cc: Ard Biesheuvel <ard.biesheuvel@linaro.org>, vishal.l.verma@intel.com,
 linux-mm@kvack.org, linux-kernel@vger.kernel.org, x86@kernel.org,
 linux-nvdimm@lists.01.org
Date: Thu, 30 May 2019 15:59:38 -0700
Message-ID: <155925717803.3775979.14412010256191901040.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <155925716254.3775979.16716824941364738117.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <155925716254.3775979.16716824941364738117.stgit@dwillia2-desk3.amr.corp.intel.com>
User-Agent: StGit/0.18-2-gc94f
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

UEFI 2.8 defines an EFI_MEMORY_SP attribute bit to augment the
interpretation of the EFI Memory Types as "reserved for a specific
purpose". The intent of this bit is to allow the OS to identify precious
or scarce memory resources and optionally manage it separately from
EfiConventionalMemory. As defined older OSes that do not know about this
attribute are permitted to ignore it and the memory will be handled
according to the OS default policy for the given memory type.

In other words, this "specific purpose" hint is deliberately weaker than
EfiReservedMemoryType in that the system continues to operate if the OS
takes no action on the attribute. The risk of taking no action is
potentially unwanted / unmovable kernel allocations from the designated
resource that prevent the full realization of the "specific purpose".
For example, consider a system with a high-bandwidth memory pool. Older
kernels are permitted to boot and consume that memory as conventional
"System-RAM" newer kernels may arrange for that memory to be set aside
by the system administrator for a dedicated high-bandwidth memory aware
application to consume.

Specifically, this mechanism allows for the elimination of scenarios
where platform firmware tries to game OS policy by lying about ACPI SLIT
values, i.e. claiming that a precious memory resource has a high
distance to trigger the OS to avoid it by default.

Implement simple detection of the bit for EFI memory table dumps and
save the kernel policy for a follow-on change.

Cc: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 drivers/firmware/efi/efi.c |    5 +++--
 include/linux/efi.h        |    1 +
 2 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/firmware/efi/efi.c b/drivers/firmware/efi/efi.c
index 55b77c576c42..81db09485881 100644
--- a/drivers/firmware/efi/efi.c
+++ b/drivers/firmware/efi/efi.c
@@ -848,15 +848,16 @@ char * __init efi_md_typeattr_format(char *buf, size_t size,
 	if (attr & ~(EFI_MEMORY_UC | EFI_MEMORY_WC | EFI_MEMORY_WT |
 		     EFI_MEMORY_WB | EFI_MEMORY_UCE | EFI_MEMORY_RO |
 		     EFI_MEMORY_WP | EFI_MEMORY_RP | EFI_MEMORY_XP |
-		     EFI_MEMORY_NV |
+		     EFI_MEMORY_NV | EFI_MEMORY_SP |
 		     EFI_MEMORY_RUNTIME | EFI_MEMORY_MORE_RELIABLE))
 		snprintf(pos, size, "|attr=0x%016llx]",
 			 (unsigned long long)attr);
 	else
 		snprintf(pos, size,
-			 "|%3s|%2s|%2s|%2s|%2s|%2s|%2s|%3s|%2s|%2s|%2s|%2s]",
+			 "|%3s|%2s|%2s|%2s|%2s|%2s|%2s|%2s|%3s|%2s|%2s|%2s|%2s]",
 			 attr & EFI_MEMORY_RUNTIME ? "RUN" : "",
 			 attr & EFI_MEMORY_MORE_RELIABLE ? "MR" : "",
+			 attr & EFI_MEMORY_SP      ? "SP"  : "",
 			 attr & EFI_MEMORY_NV      ? "NV"  : "",
 			 attr & EFI_MEMORY_XP      ? "XP"  : "",
 			 attr & EFI_MEMORY_RP      ? "RP"  : "",
diff --git a/include/linux/efi.h b/include/linux/efi.h
index 6ebc2098cfe1..91368f5ce114 100644
--- a/include/linux/efi.h
+++ b/include/linux/efi.h
@@ -112,6 +112,7 @@ typedef	struct {
 #define EFI_MEMORY_MORE_RELIABLE \
 				((u64)0x0000000000010000ULL)	/* higher reliability */
 #define EFI_MEMORY_RO		((u64)0x0000000000020000ULL)	/* read-only */
+#define EFI_MEMORY_SP		((u64)0x0000000000040000ULL)	/* special purpose */
 #define EFI_MEMORY_RUNTIME	((u64)0x8000000000000000ULL)	/* range requires runtime mapping */
 #define EFI_MEMORY_DESCRIPTOR_VERSION	1
 

