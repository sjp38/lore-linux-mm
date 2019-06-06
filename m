Return-Path: <SRS0=utKX=UF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3C1D2C04AB5
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 20:16:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0ED67208CA
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 20:16:02 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0ED67208CA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 00EFD6B02AC; Thu,  6 Jun 2019 16:15:34 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EB2026B02AF; Thu,  6 Jun 2019 16:15:33 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D2CCD6B02B0; Thu,  6 Jun 2019 16:15:33 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 95EEB6B02AC
	for <linux-mm@kvack.org>; Thu,  6 Jun 2019 16:15:33 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id z10so2292142pgf.15
        for <linux-mm@kvack.org>; Thu, 06 Jun 2019 13:15:33 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=KLfohGHa7rnp76foE5b4WcKhRrYi/Mci9oJK7pw/J20=;
        b=Dibui5PF7YbpeK/2XlOP/5ahRPeVMKdDI128EOek0ad3Ili85SSOnGiwquG1InMIXZ
         YiLQ8TpYYYU5fuDaXdrCIPBevkqT2WQ+hAZMdEAoT+YgwnjWKja3XaezVT/h6m7qyiKd
         rf7Sc1g0TTEqBLNR3SFAF+jjNtLAnv7T3pyp2uBWtF7K690PUmMe/wq4oeeNYVHbiL4I
         WKpFPrA1MqlYrYj2BizEApIe3WAu8I934rfbnLVhLjeez9eFmLc2CfdTyYX1AXfCDphg
         Lpdiw5HpSh6ndORdopgQs1cBdF70BhWIgW/oIZqu5Er5kw82RtmuinNzm4pLw4zxJbBx
         UeNg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yu-cheng.yu@intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=yu-cheng.yu@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAU9QHTCIboevGLQ2cg8S4F6Aia+VPbyOkSF+tVZgdNH6t+R367h
	pAHW/dAH+5mG+Az3fzoPvhhhSPWEJu9G7vG84pGcvdah2LCFe9Jo3ud5WzE4vTz/rnwuJA2OIeT
	N/430AI1B1DA5cEfRpXDsYtgXTeIiT/4HuIQOHBCoj/IT78WocSVOkx1p5LF71zg/ew==
X-Received: by 2002:a17:90a:7147:: with SMTP id g7mr1696306pjs.42.1559852133301;
        Thu, 06 Jun 2019 13:15:33 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw2fXFZk+w1oCq6OT4wjnzjrfEySTymv0RAe2pzHrzultVi17cF+Ih68C6hxfdHkpqM8DMv
X-Received: by 2002:a17:90a:7147:: with SMTP id g7mr1696247pjs.42.1559852132609;
        Thu, 06 Jun 2019 13:15:32 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559852132; cv=none;
        d=google.com; s=arc-20160816;
        b=k5K8lXMgnyz8cnreMpvRWRIt8y44RCIwlajlT6UkcKnKK3ushcETZ3/HpexJd3pesg
         JuwAO4kWv0QCZUFPjimtJtAQF7Sd+yoLibziFUeNL2xsoaHyma030oghAAbo+2JdDd2U
         2AtIF7CUwhdIeo/HZTp4ngiZz7jFefca5xipopS3ZeN14mLHzNZYHOn+VtcYTwW5SBLI
         ZeVpAGL8T99LsQsUMlD3QoJfj1ADqoKMOcTWX9pFjwXXpefGmuGvFXyuF8MSHp5DpztN
         F0c9If1s11dc8tiRBDi9oPVNWJnc33mXX7Y5ekU2OEtR/tzs1cqaFlJ9F4MgjzQtUhns
         KmwQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=KLfohGHa7rnp76foE5b4WcKhRrYi/Mci9oJK7pw/J20=;
        b=inyfoIGmJfSxYrzD6+5aK7AT+V0uGVV08jHRbTe+TrmiBgNT/5xcOn9pJP62c2fmtP
         WFVpXtxbxqPb2MVKwQxZHtJntwRk6+uaU7ht4mX2a/HVm3AGipiLLUxK9Oc6LDD8Xnjq
         GqEwv7JW4rcNgInS9iGrK9PTE8UsJcm3mwKnNzS3vnPPoM4TuSNg/p+EFn5NB++LPqhN
         Z6/qrTfHHN5ybWreGTRctNYAdy6DxsTDTK7n5JNwfTVJrlCmUIqKbHOnvsACC+MFJ/8f
         ewmKPvSkEmjaTw9dVpe7fv66qRcHzpIFXhmLITdBmiCV/905/K08YEUUsFUu82KGAvgO
         GJSw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yu-cheng.yu@intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=yu-cheng.yu@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga12.intel.com (mga12.intel.com. [192.55.52.136])
        by mx.google.com with ESMTPS id r142si2785300pfc.219.2019.06.06.13.15.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Jun 2019 13:15:32 -0700 (PDT)
Received-SPF: pass (google.com: domain of yu-cheng.yu@intel.com designates 192.55.52.136 as permitted sender) client-ip=192.55.52.136;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yu-cheng.yu@intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=yu-cheng.yu@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga002.jf.intel.com ([10.7.209.21])
  by fmsmga106.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 06 Jun 2019 13:15:32 -0700
X-ExtLoop1: 1
Received: from yyu32-desk1.sc.intel.com ([143.183.136.147])
  by orsmga002.jf.intel.com with ESMTP; 06 Jun 2019 13:15:30 -0700
From: Yu-cheng Yu <yu-cheng.yu@intel.com>
To: x86@kernel.org,
	"H. Peter Anvin" <hpa@zytor.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>,
	linux-kernel@vger.kernel.org,
	linux-doc@vger.kernel.org,
	linux-mm@kvack.org,
	linux-arch@vger.kernel.org,
	linux-api@vger.kernel.org,
	Arnd Bergmann <arnd@arndb.de>,
	Andy Lutomirski <luto@amacapital.net>,
	Balbir Singh <bsingharora@gmail.com>,
	Borislav Petkov <bp@alien8.de>,
	Cyrill Gorcunov <gorcunov@gmail.com>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Eugene Syromiatnikov <esyr@redhat.com>,
	Florian Weimer <fweimer@redhat.com>,
	"H.J. Lu" <hjl.tools@gmail.com>,
	Jann Horn <jannh@google.com>,
	Jonathan Corbet <corbet@lwn.net>,
	Kees Cook <keescook@chromium.org>,
	Mike Kravetz <mike.kravetz@oracle.com>,
	Nadav Amit <nadav.amit@gmail.com>,
	Oleg Nesterov <oleg@redhat.com>,
	Pavel Machek <pavel@ucw.cz>,
	Peter Zijlstra <peterz@infradead.org>,
	Randy Dunlap <rdunlap@infradead.org>,
	"Ravi V. Shankar" <ravi.v.shankar@intel.com>,
	Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>,
	Dave Martin <Dave.Martin@arm.com>
Cc: Yu-cheng Yu <yu-cheng.yu@intel.com>
Subject: [PATCH v7 18/27] mm: Introduce do_mmap_locked()
Date: Thu,  6 Jun 2019 13:06:37 -0700
Message-Id: <20190606200646.3951-19-yu-cheng.yu@intel.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190606200646.3951-1-yu-cheng.yu@intel.com>
References: <20190606200646.3951-1-yu-cheng.yu@intel.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

There are a few places that need do_mmap() with mm->mmap_sem held.
Create an in-line function for that.

Signed-off-by: Yu-cheng Yu <yu-cheng.yu@intel.com>
---
 include/linux/mm.h | 18 ++++++++++++++++++
 1 file changed, 18 insertions(+)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 398f1e1c35e5..7cf014604848 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -2411,6 +2411,24 @@ static inline void mm_populate(unsigned long addr, unsigned long len)
 static inline void mm_populate(unsigned long addr, unsigned long len) {}
 #endif
 
+static inline unsigned long do_mmap_locked(unsigned long addr,
+	unsigned long len, unsigned long prot, unsigned long flags,
+	vm_flags_t vm_flags)
+{
+	struct mm_struct *mm = current->mm;
+	unsigned long populate;
+
+	down_write(&mm->mmap_sem);
+	addr = do_mmap(NULL, addr, len, prot, flags, vm_flags, 0,
+		       &populate, NULL);
+	up_write(&mm->mmap_sem);
+
+	if (populate)
+		mm_populate(addr, populate);
+
+	return addr;
+}
+
 /* These take the mm semaphore themselves */
 extern int __must_check vm_brk(unsigned long, unsigned long);
 extern int __must_check vm_brk_flags(unsigned long, unsigned long, unsigned long);
-- 
2.17.1

