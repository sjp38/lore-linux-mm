Return-Path: <SRS0=OmxZ=TI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2D123C04A6B
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 14:45:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EB400217D7
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 14:45:28 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EB400217D7
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D80B86B0271; Wed,  8 May 2019 10:44:45 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D311A6B0273; Wed,  8 May 2019 10:44:45 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C47236B0274; Wed,  8 May 2019 10:44:45 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7F6806B0273
	for <linux-mm@kvack.org>; Wed,  8 May 2019 10:44:45 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id c12so12789397pfb.2
        for <linux-mm@kvack.org>; Wed, 08 May 2019 07:44:45 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=aDWClVMg7o0q6W+CS5Ktmi+M2XAVNiQkNlzid5TzL2w=;
        b=Hok3L4IAKIkzww6wmTRR+S6IzL67iL7cITa83PZR0GxA+c4+S6QUVa4hY1RBGN3JGB
         ENZ6GvcaRJ4nvBOc3RaBq6IC9fg7MYdQ/XP4woIhDPQxisTW5aFO8XOA342lORjKPruk
         SKNtUPtGsgCQQJhHhgA8iah+54i5wbT3ueM+N2VSVfVo5G6yE+VlFCRhY8OstS/OtFAp
         fwglgPCMNU7jfcEr8NDHsVTYpBuMVVxDOf6EB5/gqpnj3i7A0voMf/ykLq+MjajQbXLh
         NLJbn0vkKOS9/3RslbHXvym3YjwZpabv+llP4WDKLOP9JMDrX+3xUH/8ct1HFgYHYD53
         +eqw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of kirill.shutemov@linux.intel.com designates 192.55.52.88 as permitted sender) smtp.mailfrom=kirill.shutemov@linux.intel.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAVYkTdmOV0u4BgG5A82XwcRNJOIKhf5DH79uLT9Dbku4EdTD/tr
	Aotl4ThJ1hQOQomh7XUp/VsLadr9NfCboXRXuegKZ0gbn8V1IphSnDUKyEGu9pnbsoIul8tUWJl
	n8nIKsrR9UGiSjQXLafOe7LmSlbmS9fksREvJMlfQ7JuOIWavAEaAIdIgYEJLNr67jw==
X-Received: by 2002:a62:304:: with SMTP id 4mr47689780pfd.99.1557326685201;
        Wed, 08 May 2019 07:44:45 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxJuEgsmxgVa4orqBKQYDEToIZMgx/7vkhUVHTN2NqycH3R11i0nrLR9q9iDTMtCwBkX/Th
X-Received: by 2002:a62:304:: with SMTP id 4mr47689686pfd.99.1557326684264;
        Wed, 08 May 2019 07:44:44 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557326684; cv=none;
        d=google.com; s=arc-20160816;
        b=pnPPI/wgWYRFaGJXmTe9Am6sDBr1pSqSBdMoLPDndOK+pskVlQj+gaK0U7POgIeCwp
         Qushnng1twCM3vA2InO/5Ud9ePupOFj4pyFhuhv1w+hexrg6qglq3NfXtXj1DH2uth1s
         TwLj3FHUnjrQHY0/TPDSrN4x4w7dqDBSz3MCYobz735jwNv1h5S+nGG+s4F7bXxYlGsr
         8p1TsCFYD2/2Hfq2xB4Z6CTJdeKhmgrvvyZWYW9obc9pWmn1siCKclfpWXZT71G7i1pF
         tWkbrYRu6GoUhqhQdIcL9lzYq//msGYZyD6JwrhTPGIsdWDswYVce/V5brv6V3cpovq/
         33nQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=aDWClVMg7o0q6W+CS5Ktmi+M2XAVNiQkNlzid5TzL2w=;
        b=jTzoDvpCI34QTAt74/RZ0Ed3ZQY7wxRT6Q9YyPZWME/7fL4FTTy0BcjTjeTRNKwsOp
         mC8J1LFEK1SQ/hocb0D4nKftGIUb89mS7wYi7k8gbZLZYCvUjVJeIHszS861yI/NEvF2
         zbjG7wBuox/4BPp2xRbhvYTLdRQY1TqDMOjVpEeIUwQJ3gteJRwXmW0MZ41v0xuJSgx/
         j4tL16Qy+Faqt9zKKen5unnkGGAxUn21n8H/SXpWprclib7/47Muk8RRdkccBXafOFAg
         4jqzqiz15wTPAyMiO5HgkNQ53HRxhtp3llCkgcZvAHLsDa8x4ENg2mgq/VWb/uRAPqQv
         YfnQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of kirill.shutemov@linux.intel.com designates 192.55.52.88 as permitted sender) smtp.mailfrom=kirill.shutemov@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id g13si12322802pgs.161.2019.05.08.07.44.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 May 2019 07:44:44 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of kirill.shutemov@linux.intel.com designates 192.55.52.88 as permitted sender) client-ip=192.55.52.88;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of kirill.shutemov@linux.intel.com designates 192.55.52.88 as permitted sender) smtp.mailfrom=kirill.shutemov@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga004.fm.intel.com ([10.253.24.48])
  by fmsmga101.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 08 May 2019 07:44:43 -0700
X-ExtLoop1: 1
Received: from black.fi.intel.com ([10.237.72.28])
  by fmsmga004.fm.intel.com with ESMTP; 08 May 2019 07:44:39 -0700
Received: by black.fi.intel.com (Postfix, from userid 1000)
	id B90ABA50; Wed,  8 May 2019 17:44:29 +0300 (EEST)
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
	"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH, RFC 21/62] mm/rmap: Clear vma->anon_vma on unlink_anon_vmas()
Date: Wed,  8 May 2019 17:43:41 +0300
Message-Id: <20190508144422.13171-22-kirill.shutemov@linux.intel.com>
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

If all pages in the VMA got unmapped there's no reason to link it into
original anon VMA hierarchy: it cannot possibly share any pages with
other VMA.

Set vma->anon_vma to NULL on unlink_anon_vmas(). With the change VMA
can be reused. The new anon VMA will be allocated on the first fault.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 mm/rmap.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/mm/rmap.c b/mm/rmap.c
index b30c7c71d1d9..4ec2aee7baa3 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -400,8 +400,10 @@ void unlink_anon_vmas(struct vm_area_struct *vma)
 		list_del(&avc->same_vma);
 		anon_vma_chain_free(avc);
 	}
-	if (vma->anon_vma)
+	if (vma->anon_vma) {
 		vma->anon_vma->degree--;
+		vma->anon_vma = NULL;
+	}
 	unlock_anon_vma_root(root);
 
 	/*
-- 
2.20.1

