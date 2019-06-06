Return-Path: <SRS0=utKX=UF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6802FC04AB5
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 20:18:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 28D962083E
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 20:18:11 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 28D962083E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 978036B02D5; Thu,  6 Jun 2019 16:17:36 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1BB9A6B02D4; Thu,  6 Jun 2019 16:17:36 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DED2B6B02D2; Thu,  6 Jun 2019 16:17:35 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 42DBC6B02DA
	for <linux-mm@kvack.org>; Thu,  6 Jun 2019 16:17:35 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id k23so2308469pgh.10
        for <linux-mm@kvack.org>; Thu, 06 Jun 2019 13:17:35 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to
         :subject:date:message-id:in-reply-to:references;
        bh=ac1NjIrOfI9u6KZaE2BsaLSoNPaau6R6WCIYehau9Jc=;
        b=ivBStedFqW/3WMLGGroYMB4VQfkEYTID7SFHLKQOLZGoSikcU79CINbM4bV+PZYlFx
         YDOG8cV9CUNk9RF49jP6K20iMahM1AthHr+dOLfJ3DxI5EXDth0dwrN2odJsyZz6hCt3
         MJwrpLcj3IRzDA2mI6aI/HFhQJ33iR+fMORCPstUV+47yFeDGnpHj93h2dYrA3mGyNZ2
         EI6J1ft8Ba8P+ZzvWmjY/HhTo6S2iHb/hmUaJW273md5CxqrFolxmTiLTO9UFKELp6aI
         l5hn9NwHlK1ZIM+xxY/DWjmeg0bXztSawTgePMZPJmQXHFtfRh78ow1V6/tGhaFeEi44
         xhPw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yu-cheng.yu@intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=yu-cheng.yu@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAUMFOtZX+7XPWrJxNv1uHZuPAiOnUYZq/MXib2xgf6FO3CbVkCZ
	k3J480oa/7q5512SBQ7rdSigswpQquacRm1AH/+lVoGGVQJ7GvyuiPu2HsOVNKvi0nHnECGM5lb
	T3j5YIZe7dqybEVf8Z/nknTOlMYs83VJQuYR56RQJymT40R6PrOpGlBjcGeGZJZVDyg==
X-Received: by 2002:a17:90a:d58d:: with SMTP id v13mr1668852pju.1.1559852254943;
        Thu, 06 Jun 2019 13:17:34 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxojzvmT20K+xD8d3MCdjN+pHZigxBCBFeQEeajkgU2YDB8w0aOKZlOUDrn45+KPOqyge26
X-Received: by 2002:a17:90a:d58d:: with SMTP id v13mr1668771pju.1.1559852253930;
        Thu, 06 Jun 2019 13:17:33 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559852253; cv=none;
        d=google.com; s=arc-20160816;
        b=pXLQTgwJVflTGLlLIOsR/2u1dV0hfn+l+08mljKw5uggf9SfdmUP3CC3CPyknbE+lA
         BZd4xJnytVkilRLekQV9hg60hhRAaFqY49WgS5SNI26I2+aVnJhW8zNN0NKfxG2eWK2n
         jLJAWHZ7ZAijfBYkzHjeRUJSOsJMXIu3Dvp9NMaZreHJZOe7pGKBI2UvB3H8ER0DR3Ii
         rH8341nbtvsrjP+3LLi564naDlfyKz1LUdQsUgmcKqC2r9cpOdXE81iHqoLc5P0QsNSX
         jMCx+C8afBTPN9xhNXGqzisA3rsy9pMdmDcjRbQbhUpSm13rDLJt/nJDGnyoTIcbvZsj
         jtxg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:to:from;
        bh=ac1NjIrOfI9u6KZaE2BsaLSoNPaau6R6WCIYehau9Jc=;
        b=JgXl+FjwYwtaWbPXnf4z2ZAQn5saCO2kCvdETsoYbXO0bn6fiFYUh5lbKCaYVnmgDv
         4UxwVZI5m4nYdW8bOnA0WcJ83rxemAvt57YAI8hBbqpGr5mknmqJ8c4/DkKAhIti+Z18
         X3UVR5jF7ryJkv2//JiyywVg+jneVVRwNe8avZWzqCVCawqf8b4ISDjdVLoy9khLVw3d
         3j0dbo4dEC5pgaEZ53bZ9oP/GmmCaig0a9M+2bQ5T/iYh9hmjhbE8YiLEY4zteYSE4Rx
         UO9AksxpJZP2qfxtSmaCMzNourN01kbWxaJHrRcUwohqgs9N67A/6DNsH+XU8P2SAS9W
         uxUg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yu-cheng.yu@intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=yu-cheng.yu@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id p21si39566plq.328.2019.06.06.13.17.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Jun 2019 13:17:33 -0700 (PDT)
Received-SPF: pass (google.com: domain of yu-cheng.yu@intel.com designates 192.55.52.43 as permitted sender) client-ip=192.55.52.43;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yu-cheng.yu@intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=yu-cheng.yu@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga001.fm.intel.com ([10.253.24.23])
  by fmsmga105.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 06 Jun 2019 13:17:33 -0700
X-ExtLoop1: 1
Received: from yyu32-desk1.sc.intel.com ([143.183.136.147])
  by fmsmga001.fm.intel.com with ESMTP; 06 Jun 2019 13:17:33 -0700
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
Subject: [PATCH v7 14/14] x86: Discard .note.gnu.property sections
Date: Thu,  6 Jun 2019 13:09:26 -0700
Message-Id: <20190606200926.4029-15-yu-cheng.yu@intel.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190606200926.4029-1-yu-cheng.yu@intel.com>
References: <20190606200926.4029-1-yu-cheng.yu@intel.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: "H.J. Lu" <hjl.tools@gmail.com>

With the command-line option, -mx86-used-note=yes, the x86 assembler
in binutils 2.32 and above generates a program property note in a note
section, .note.gnu.property, to encode used x86 ISAs and features.
To exclude .note.gnu.property sections from NOTE segment in x86 kernel
linker script:

PHDRS {
 text PT_LOAD FLAGS(5);
 data PT_LOAD FLAGS(6);
 percpu PT_LOAD FLAGS(6);
 init PT_LOAD FLAGS(7);
 note PT_NOTE FLAGS(0);
}
SECTIONS
{
...
 .notes : AT(ADDR(.notes) - 0xffffffff80000000) { __start_notes = .; KEEP(*(.not
e.*)) __stop_notes = .; } :text :note
...
}

this patch discards .note.gnu.property sections in kernel linker script
by adding

 /DISCARD/ : {
  *(.note.gnu.property)
 }

before .notes sections.  Since .exit.text and .exit.data sections are
discarded at runtime, it undefines EXIT_TEXT and EXIT_DATA to exclude
.exit.text and .exit.data sections from default discarded sections.

Signed-off-by: H.J. Lu <hjl.tools@gmail.com>
---
 arch/x86/kernel/vmlinux.lds.S | 11 ++++++++++-
 1 file changed, 10 insertions(+), 1 deletion(-)

diff --git a/arch/x86/kernel/vmlinux.lds.S b/arch/x86/kernel/vmlinux.lds.S
index 0850b5149345..d2594b482c09 100644
--- a/arch/x86/kernel/vmlinux.lds.S
+++ b/arch/x86/kernel/vmlinux.lds.S
@@ -146,6 +146,10 @@ SECTIONS
 	/* End of text section */
 	_etext = .;
 
+	/* .note.gnu.property sections should be discarded */
+	/DISCARD/ : {
+		*(.note.gnu.property)
+	}
 	NOTES :text :note
 
 	EXCEPTION_TABLE(16) :text = 0x9090
@@ -382,7 +386,12 @@ SECTIONS
 	STABS_DEBUG
 	DWARF_DEBUG
 
-	/* Sections to be discarded */
+	/* Sections to be discarded.  EXIT_TEXT and EXIT_DATA discard at runtime.
+	 * not link time.  */
+#undef EXIT_TEXT
+#define EXIT_TEXT
+#undef EXIT_DATA
+#define EXIT_DATA
 	DISCARDS
 	/DISCARD/ : {
 		*(.eh_frame)
-- 
2.17.1

