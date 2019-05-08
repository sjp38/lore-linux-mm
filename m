Return-Path: <SRS0=OmxZ=TI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0DC9EC04AAB
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 14:46:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C8F81216F4
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 14:46:27 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C8F81216F4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BFEA46B02A4; Wed,  8 May 2019 10:44:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B348C6B02A2; Wed,  8 May 2019 10:44:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 939836B02A4; Wed,  8 May 2019 10:44:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 400006B02A2
	for <linux-mm@kvack.org>; Wed,  8 May 2019 10:44:52 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id s26so12730857pfm.18
        for <linux-mm@kvack.org>; Wed, 08 May 2019 07:44:52 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=BHo/eOy6j5v3nHf6Oc55nLYyTszWbv+NzSETY59La88=;
        b=pq+0H3+SDr5Maog8jzrAbihAmzqDOsn4dirCTEUinRGbMTZgy7muiivmJl7rzDlied
         DLUK2C27Qo5yxxmTrCTayuml5uKkQQCqgHFkoyWKJTIog+qA7DDsh79vYd4p6ZwB8PeT
         t3rURqcc8/fIwg42Anbupz+lWK6zrz3oz+3H3a3iLa7L1TidhKwM+2SDoMYmYQFd1iUG
         R4wIGhoAF29sa8bC/XPV5xbwtAodsXIj2/Cc5EwVPkhMFOaIjxmpU7/yv6f6VpDKZyOp
         Pe51MlhxId3Bo3L+Jz131FotYv3o/xqvG1SPWG+jJxbgIVdbDL4Oxu28uWwsPBGOLVXM
         +cWA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of kirill.shutemov@linux.intel.com designates 192.55.52.115 as permitted sender) smtp.mailfrom=kirill.shutemov@linux.intel.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAWAOHLVMF7kD4d5HQ2+/LcXrhR7JU7NYX7ZMhlR4ai13hGqwC3g
	+wEsLpWqo9/Ip2B/WzqocZ693NCpCLm3dZNlWyeZhOiA/pqJTinsqu63NalHLc4vIWtnYGgs815
	fIfkYAge+MIdyBjqv108CRO2ErvEmThImsYtQ8seT+ZZmtoWY/EzqFE8NWoVdBFJXZg==
X-Received: by 2002:a62:5ec2:: with SMTP id s185mr50460135pfb.16.1557326691939;
        Wed, 08 May 2019 07:44:51 -0700 (PDT)
X-Google-Smtp-Source: APXvYqycz4KnoVxDZLEXTLFbY97oXMnlumfb9T5VOXock4iMMlng6l0Ij6LE85SoQyqFKnOqA/bL
X-Received: by 2002:a62:5ec2:: with SMTP id s185mr50460031pfb.16.1557326691045;
        Wed, 08 May 2019 07:44:51 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557326691; cv=none;
        d=google.com; s=arc-20160816;
        b=pmh3TxKAwIaYf4Xs3xlB/SgAz8Rdmyvs3At7dE43ypbi1HHkTaozBj2vBdLO9jpl0i
         BJlJLHrfYEV8q3RoI5aK8yq38WqHP4KGUDYoAtCKtZeBtTElJ/5JA6F5sRPO2EpWVv28
         XZgevs3+O8uu6uq0avLObfgT+beinW+V23eCzCeL/hseNl3/GOkftNUvNYUW02QVQh7A
         QuvCclFAH8Phk7grtjCfRUVD6i8hWqZ6Ppllamw+61OkSJnOwsssIOL6mwSAVsmXIddr
         IInmyZFwTQymeQOU4pRJE3cDM+qfjWwUpoOLrusZojn1ZA9JfRJ2HL6raehp0oUaBoq6
         L1Vg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=BHo/eOy6j5v3nHf6Oc55nLYyTszWbv+NzSETY59La88=;
        b=l4BmFJNi6ujpwVLHd4iP/AudR0PyLBJhgK4dZ94QBgFYt86uH4oqFCrVZqfsAsIXs7
         tCk2rJupb2vupNWyR3VngZg2C++SZHNFFLHNuzblHmoiY3U03vPt41Yb9dl5pasCk3zE
         8Ph+55eU4nXKmInXgHD+7fB1R9vbNU9BISgnTttIDmLCy6356SCFf2fPBx8u+vPdH9O3
         bcF/Ys30JvJFNWLxcceW5swXkFxMwotQXkhv7c6b55i5ldhrAYksLCtQ9QfKeJPMGxt3
         nQ/cL7DCzTXHxHlFbge/2PJdTLMF5rqTJO/ujorSO6thNbTXd2iszpq2JbJrDFFBncVS
         OO0g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of kirill.shutemov@linux.intel.com designates 192.55.52.115 as permitted sender) smtp.mailfrom=kirill.shutemov@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id d3si22507173pfc.278.2019.05.08.07.44.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 May 2019 07:44:51 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of kirill.shutemov@linux.intel.com designates 192.55.52.115 as permitted sender) client-ip=192.55.52.115;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of kirill.shutemov@linux.intel.com designates 192.55.52.115 as permitted sender) smtp.mailfrom=kirill.shutemov@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga001.jf.intel.com ([10.7.209.18])
  by fmsmga103.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 08 May 2019 07:44:50 -0700
X-ExtLoop1: 1
Received: from black.fi.intel.com ([10.237.72.28])
  by orsmga001.jf.intel.com with ESMTP; 08 May 2019 07:44:45 -0700
Received: by black.fi.intel.com (Postfix, from userid 1000)
	id 311E210A5; Wed,  8 May 2019 17:44:31 +0300 (EEST)
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
Subject: [PATCH, RFC 49/62] mm, x86: export several MKTME variables
Date: Wed,  8 May 2019 17:44:09 +0300
Message-Id: <20190508144422.13171-50-kirill.shutemov@linux.intel.com>
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

From: Kai Huang <kai.huang@linux.intel.com>

KVM needs those variables to get/set memory encryption mask.

Signed-off-by: Kai Huang <kai.huang@linux.intel.com>
Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 arch/x86/mm/mktme.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/arch/x86/mm/mktme.c b/arch/x86/mm/mktme.c
index df70651816a1..12f4266cf7ea 100644
--- a/arch/x86/mm/mktme.c
+++ b/arch/x86/mm/mktme.c
@@ -7,13 +7,16 @@
 
 /* Mask to extract KeyID from physical address. */
 phys_addr_t mktme_keyid_mask;
+EXPORT_SYMBOL_GPL(mktme_keyid_mask);
 /*
  * Number of KeyIDs available for MKTME.
  * Excludes KeyID-0 which used by TME. MKTME KeyIDs start from 1.
  */
 int mktme_nr_keyids;
+EXPORT_SYMBOL_GPL(mktme_nr_keyids);
 /* Shift of KeyID within physical address. */
 int mktme_keyid_shift;
+EXPORT_SYMBOL_GPL(mktme_keyid_shift);
 
 DEFINE_STATIC_KEY_FALSE(mktme_enabled_key);
 EXPORT_SYMBOL_GPL(mktme_enabled_key);
-- 
2.20.1

