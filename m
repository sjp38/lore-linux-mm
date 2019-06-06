Return-Path: <SRS0=utKX=UF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8F346C04AB5
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 20:16:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 46E8F208C3
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 20:16:25 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 46E8F208C3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 42DF56B02BF; Thu,  6 Jun 2019 16:15:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3B5066B02C1; Thu,  6 Jun 2019 16:15:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 258B26B02C2; Thu,  6 Jun 2019 16:15:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id CED0C6B02BF
	for <linux-mm@kvack.org>; Thu,  6 Jun 2019 16:15:45 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id bc12so2182171plb.0
        for <linux-mm@kvack.org>; Thu, 06 Jun 2019 13:15:45 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=OQ5kV+Ft3hkRBLg3gYwc7poXPXYMd+Ka9Q+KpVCdFWE=;
        b=d3zi1pPwT2xl7ig4a9Cv4Tbt+P/hcGeGhr6wvfa2F+O9o3iFzvJdAKz2NfDzeYhRNF
         MkrtrsWtq2ZH4begfkCvHPB+WbFkhvMHj6LUGN/aAHhmU6f8qGVZvY19fnvxnopQa8Lk
         DluXdINzhDI4JPgDQ47JM0fM8NerEeI3qoOQX6aY/NyzjjdXN3f2Zn2eROuTIXivJU4E
         aJMXiT0wgn864Ma8pqTDXpPkVzJ/1KeTaZhUtjfZLQSD+Ic4Oe6lSEUNvr3ARMeWuSZ2
         8LTsxOy0iGlOsSo/FrxSNm7X5BOwjCfGhekEdkVIfoVeRFnCGC01qmAItehi1J3KxMfh
         Oc0Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yu-cheng.yu@intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=yu-cheng.yu@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAX0C+gzOiLj5yCZL3KXDXs+t3mHYci7nSOQr5Dd2GE0tZomLS+e
	I3ce9pVw53xZUO1s0ZLQBXCkmmlcKBplllqNvQzgpZx8Txz/B7M0h+GjO1F/QHLjxIxDvAnAZck
	6Z8zHMsl9+Idj4Gm8OOcaoFzp63HZLhaZ/fkEsjheFoP7t+yBSCSkVzVoWh9XWdDivQ==
X-Received: by 2002:aa7:825a:: with SMTP id e26mr55750904pfn.255.1559852145485;
        Thu, 06 Jun 2019 13:15:45 -0700 (PDT)
X-Google-Smtp-Source: APXvYqywDnhjwWERP2Qxl78eWfQTqlt9azNRDSqnH+MfOJsI7fm8oSad3iqb53xFKHN/FJtjXohd
X-Received: by 2002:aa7:825a:: with SMTP id e26mr55750827pfn.255.1559852144393;
        Thu, 06 Jun 2019 13:15:44 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559852144; cv=none;
        d=google.com; s=arc-20160816;
        b=zJaHs5jSPRukiP87rNKIJJdw7dkY9vSKXpLzo49DGasSKaZynA4Op6+5CIh5KAwtVg
         AOY6yiBTlcp9hAxNmC6vRPILQV0OcO1OAfxzipLtESaeAaijdziwqD+D2KYS/fR3E2PQ
         PAmPvsmBRUtEr2wXCE8sGSjm//XxeOpX5rFCoUyv1YgCcv35qC8VjVGqrEkAvsPLkeUa
         uOC5RAzNnltdfsbBHWVTTQM9iQy2Qj57Dv48Odu8kZXPMf+J8/2jtl7/px8QBeFwklcf
         Bz0ZiH7QFD2WmpLczzHAX2JHx/iB0/5ncS2gWgz409TctT5oWmWUChPAoQR8BeDBs9+R
         VcRw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=OQ5kV+Ft3hkRBLg3gYwc7poXPXYMd+Ka9Q+KpVCdFWE=;
        b=0rO0Ix3cS0s2YspOCLi61vWmj6rb1+FtZvsX4Eoo8Mu1908vOZNNzql+Hi0OH+q9wJ
         OFWJWvrE/7kYBf6F4p0SCCyVjATxBl8t0hnVZX+7ZdLyuvUHlPJvErwPFN1MDZnWNLge
         yTcRE6OYGZZclXRUG8rklEG+arDG11Z3aMZ0xkLXPrpDvFHeKOHCZ3+xGl7stpGEiRVq
         hJBoy1q6gtgPpAt6r8NVYXPHPg9/UJVJ5MN/1o2ZwrfRfMMdki1y6fK4eQDDC0HXRSog
         euplOc/YprWxjyvxNTH0Y0CyDRY0RrVs9Gn79rKk3Vmdk9cZAi3mjxrK08HrfnvaMMI9
         Ze5g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yu-cheng.yu@intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=yu-cheng.yu@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga12.intel.com (mga12.intel.com. [192.55.52.136])
        by mx.google.com with ESMTPS id r142si2785300pfc.219.2019.06.06.13.15.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Jun 2019 13:15:44 -0700 (PDT)
Received-SPF: pass (google.com: domain of yu-cheng.yu@intel.com designates 192.55.52.136 as permitted sender) client-ip=192.55.52.136;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yu-cheng.yu@intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=yu-cheng.yu@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga002.jf.intel.com ([10.7.209.21])
  by fmsmga106.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 06 Jun 2019 13:15:43 -0700
X-ExtLoop1: 1
Received: from yyu32-desk1.sc.intel.com ([143.183.136.147])
  by orsmga002.jf.intel.com with ESMTP; 06 Jun 2019 13:15:42 -0700
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
Subject: [PATCH v7 27/27] x86/cet/shstk: Add Shadow Stack instructions to opcode map
Date: Thu,  6 Jun 2019 13:06:46 -0700
Message-Id: <20190606200646.3951-28-yu-cheng.yu@intel.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190606200646.3951-1-yu-cheng.yu@intel.com>
References: <20190606200646.3951-1-yu-cheng.yu@intel.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Add the following shadow stack management instructions.

INCSSP:
    Increment shadow stack pointer by the steps specified.

RDSSP:
    Read SSP register into a GPR.

SAVEPREVSSP:
    Use "prev ssp" token at top of current shadow stack to
    create a "restore token" on previous shadow stack.

RSTORSSP:
    Restore from a "restore token" pointed by a GPR to SSP.

WRSS:
    Write to kernel-mode shadow stack (kernel-mode instruction).

WRUSS:
    Write to user-mode shadow stack (kernel-mode instruction).

SETSSBSY:
    Verify the "supervisor token" pointed by IA32_PL0_SSP MSR,
    if valid, set the token to busy, and set SSP to the value
    of IA32_PL0_SSP MSR.

CLRSSBSY:
    Verify the "supervisor token" pointed by a GPR, if valid,
    clear the busy bit from the token.

Signed-off-by: Yu-cheng Yu <yu-cheng.yu@intel.com>
---
 arch/x86/lib/x86-opcode-map.txt               | 26 +++++++++++++------
 tools/objtool/arch/x86/lib/x86-opcode-map.txt | 26 +++++++++++++------
 2 files changed, 36 insertions(+), 16 deletions(-)

diff --git a/arch/x86/lib/x86-opcode-map.txt b/arch/x86/lib/x86-opcode-map.txt
index e0b85930dd77..c5e825d44766 100644
--- a/arch/x86/lib/x86-opcode-map.txt
+++ b/arch/x86/lib/x86-opcode-map.txt
@@ -366,7 +366,7 @@ AVXcode: 1
 1b: BNDCN Gv,Ev (F2) | BNDMOV Ev,Gv (66) | BNDMK Gv,Ev (F3) | BNDSTX Ev,Gv
 1c:
 1d:
-1e:
+1e: RDSSP Rd (F3),REX.W
 1f: NOP Ev
 # 0x0f 0x20-0x2f
 20: MOV Rd,Cd
@@ -610,7 +610,17 @@ fe: paddd Pq,Qq | vpaddd Vx,Hx,Wx (66),(v1)
 ff: UD0
 EndTable
 
-Table: 3-byte opcode 1 (0x0f 0x38)
+Table: 3-byte opcode 1 (0x0f 0x01)
+Referrer:
+AVXcode:
+# Skip 0x00-0xe7
+e8: SETSSBSY (f3)
+e9:
+ea: SAVEPREVSSP (f3)
+# Skip 0xeb-0xff
+EndTable
+
+Table: 3-byte opcode 2 (0x0f 0x38)
 Referrer: 3-byte escape 1
 AVXcode: 2
 # 0x0f 0x38 0x00-0x0f
@@ -789,12 +799,12 @@ f0: MOVBE Gy,My | MOVBE Gw,Mw (66) | CRC32 Gd,Eb (F2) | CRC32 Gd,Eb (66&F2)
 f1: MOVBE My,Gy | MOVBE Mw,Gw (66) | CRC32 Gd,Ey (F2) | CRC32 Gd,Ew (66&F2)
 f2: ANDN Gy,By,Ey (v)
 f3: Grp17 (1A)
-f5: BZHI Gy,Ey,By (v) | PEXT Gy,By,Ey (F3),(v) | PDEP Gy,By,Ey (F2),(v)
-f6: ADCX Gy,Ey (66) | ADOX Gy,Ey (F3) | MULX By,Gy,rDX,Ey (F2),(v)
+f5: BZHI Gy,Ey,By (v) | PEXT Gy,By,Ey (F3),(v) | PDEP Gy,By,Ey (F2),(v) | WRUSS Pq,Qq (66),REX.W
+f6: ADCX Gy,Ey (66) | ADOX Gy,Ey (F3) | MULX By,Gy,rDX,Ey (F2),(v) | WRSS Pq,Qq (66),REX.W
 f7: BEXTR Gy,Ey,By (v) | SHLX Gy,Ey,By (66),(v) | SARX Gy,Ey,By (F3),(v) | SHRX Gy,Ey,By (F2),(v)
 EndTable
 
-Table: 3-byte opcode 2 (0x0f 0x3a)
+Table: 3-byte opcode 3 (0x0f 0x3a)
 Referrer: 3-byte escape 2
 AVXcode: 3
 # 0x0f 0x3a 0x00-0xff
@@ -948,7 +958,7 @@ GrpTable: Grp7
 2: LGDT Ms | XGETBV (000),(11B) | XSETBV (001),(11B) | VMFUNC (100),(11B) | XEND (101)(11B) | XTEST (110)(11B)
 3: LIDT Ms
 4: SMSW Mw/Rv
-5: rdpkru (110),(11B) | wrpkru (111),(11B)
+5: rdpkru (110),(11B) | wrpkru (111),(11B) | RSTORSSP Mq (F3)
 6: LMSW Ew
 7: INVLPG Mb | SWAPGS (o64),(000),(11B) | RDTSCP (001),(11B)
 EndTable
@@ -1019,8 +1029,8 @@ GrpTable: Grp15
 2: vldmxcsr Md (v1) | WRFSBASE Ry (F3),(11B)
 3: vstmxcsr Md (v1) | WRGSBASE Ry (F3),(11B)
 4: XSAVE | ptwrite Ey (F3),(11B)
-5: XRSTOR | lfence (11B)
-6: XSAVEOPT | clwb (66) | mfence (11B)
+5: XRSTOR | lfence (11B) | INCSSP Rd (F3),REX.W
+6: XSAVEOPT | clwb (66) | mfence (11B) | CLRSSBSY Mq (F3)
 7: clflush | clflushopt (66) | sfence (11B)
 EndTable
 
diff --git a/tools/objtool/arch/x86/lib/x86-opcode-map.txt b/tools/objtool/arch/x86/lib/x86-opcode-map.txt
index e0b85930dd77..c5e825d44766 100644
--- a/tools/objtool/arch/x86/lib/x86-opcode-map.txt
+++ b/tools/objtool/arch/x86/lib/x86-opcode-map.txt
@@ -366,7 +366,7 @@ AVXcode: 1
 1b: BNDCN Gv,Ev (F2) | BNDMOV Ev,Gv (66) | BNDMK Gv,Ev (F3) | BNDSTX Ev,Gv
 1c:
 1d:
-1e:
+1e: RDSSP Rd (F3),REX.W
 1f: NOP Ev
 # 0x0f 0x20-0x2f
 20: MOV Rd,Cd
@@ -610,7 +610,17 @@ fe: paddd Pq,Qq | vpaddd Vx,Hx,Wx (66),(v1)
 ff: UD0
 EndTable
 
-Table: 3-byte opcode 1 (0x0f 0x38)
+Table: 3-byte opcode 1 (0x0f 0x01)
+Referrer:
+AVXcode:
+# Skip 0x00-0xe7
+e8: SETSSBSY (f3)
+e9:
+ea: SAVEPREVSSP (f3)
+# Skip 0xeb-0xff
+EndTable
+
+Table: 3-byte opcode 2 (0x0f 0x38)
 Referrer: 3-byte escape 1
 AVXcode: 2
 # 0x0f 0x38 0x00-0x0f
@@ -789,12 +799,12 @@ f0: MOVBE Gy,My | MOVBE Gw,Mw (66) | CRC32 Gd,Eb (F2) | CRC32 Gd,Eb (66&F2)
 f1: MOVBE My,Gy | MOVBE Mw,Gw (66) | CRC32 Gd,Ey (F2) | CRC32 Gd,Ew (66&F2)
 f2: ANDN Gy,By,Ey (v)
 f3: Grp17 (1A)
-f5: BZHI Gy,Ey,By (v) | PEXT Gy,By,Ey (F3),(v) | PDEP Gy,By,Ey (F2),(v)
-f6: ADCX Gy,Ey (66) | ADOX Gy,Ey (F3) | MULX By,Gy,rDX,Ey (F2),(v)
+f5: BZHI Gy,Ey,By (v) | PEXT Gy,By,Ey (F3),(v) | PDEP Gy,By,Ey (F2),(v) | WRUSS Pq,Qq (66),REX.W
+f6: ADCX Gy,Ey (66) | ADOX Gy,Ey (F3) | MULX By,Gy,rDX,Ey (F2),(v) | WRSS Pq,Qq (66),REX.W
 f7: BEXTR Gy,Ey,By (v) | SHLX Gy,Ey,By (66),(v) | SARX Gy,Ey,By (F3),(v) | SHRX Gy,Ey,By (F2),(v)
 EndTable
 
-Table: 3-byte opcode 2 (0x0f 0x3a)
+Table: 3-byte opcode 3 (0x0f 0x3a)
 Referrer: 3-byte escape 2
 AVXcode: 3
 # 0x0f 0x3a 0x00-0xff
@@ -948,7 +958,7 @@ GrpTable: Grp7
 2: LGDT Ms | XGETBV (000),(11B) | XSETBV (001),(11B) | VMFUNC (100),(11B) | XEND (101)(11B) | XTEST (110)(11B)
 3: LIDT Ms
 4: SMSW Mw/Rv
-5: rdpkru (110),(11B) | wrpkru (111),(11B)
+5: rdpkru (110),(11B) | wrpkru (111),(11B) | RSTORSSP Mq (F3)
 6: LMSW Ew
 7: INVLPG Mb | SWAPGS (o64),(000),(11B) | RDTSCP (001),(11B)
 EndTable
@@ -1019,8 +1029,8 @@ GrpTable: Grp15
 2: vldmxcsr Md (v1) | WRFSBASE Ry (F3),(11B)
 3: vstmxcsr Md (v1) | WRGSBASE Ry (F3),(11B)
 4: XSAVE | ptwrite Ey (F3),(11B)
-5: XRSTOR | lfence (11B)
-6: XSAVEOPT | clwb (66) | mfence (11B)
+5: XRSTOR | lfence (11B) | INCSSP Rd (F3),REX.W
+6: XSAVEOPT | clwb (66) | mfence (11B) | CLRSSBSY Mq (F3)
 7: clflush | clflushopt (66) | sfence (11B)
 EndTable
 
-- 
2.17.1

