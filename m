Return-Path: <SRS0=Ax9E=UL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BDDBAC46477
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 17:11:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 79F2621019
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 17:11:59 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=amazon.de header.i=@amazon.de header.b="T1+M/fEJ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 79F2621019
Authentication-Results: mail.kernel.org; dmarc=fail (p=quarantine dis=none) header.from=amazon.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2BE056B026E; Wed, 12 Jun 2019 13:11:59 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 26D796B026F; Wed, 12 Jun 2019 13:11:59 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1838C6B0270; Wed, 12 Jun 2019 13:11:59 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vs1-f70.google.com (mail-vs1-f70.google.com [209.85.217.70])
	by kanga.kvack.org (Postfix) with ESMTP id E8DD36B026E
	for <linux-mm@kvack.org>; Wed, 12 Jun 2019 13:11:58 -0400 (EDT)
Received: by mail-vs1-f70.google.com with SMTP id w76so5601050vsw.10
        for <linux-mm@kvack.org>; Wed, 12 Jun 2019 10:11:58 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=y0y2fCtE+zaOH2XT3643VHxhFHXbECws0ZTrhMzBQQU=;
        b=IrT4Y6YfJIKU9LcY2lgMgu46pscnM5vdvmtBLlQc+tB1K7AjBOvnjnJiFVwi/E2dxf
         Ojzwjs54x6C9T2TRFMGX3L+p9ys7eHaoTTdsehuCeuRv4bAp1RVv6CwPc4a0jidBh0hK
         bYjIf3C8VXuOYFi66VTP30UQ3dGgKpDCMJUwBlQ0xBT6PCLXeju0bg15hCE4Y5ZlmQCJ
         jNr6j5b6DEmGBgxPPfGkLgeOVk+KPMFWCU7XTCtfQSJRl1hXFZy7sNWiueJdKe2jk0+r
         OxCNdw2Pa93IcRqfivS98yif0tnhRvNHT11w+RqMxeEzC8PnfrpejF+uEtodrt3QQwse
         gMRg==
X-Gm-Message-State: APjAAAV5znxvXooURs4AOGMakKa23sa0/UAKOHasugzPaYzzt60AEkHJ
	9A9Lw2talbZ9lL0MDhVzXjKcRyZV4p8ilTcHD/eMu34/cMcX0aMRgN2Da9sCfhW1e7tYdmheO2/
	5K6oTCzRdzYDSPNNPwI5279bnQanDmByp2zEMUMM4YWU3ZLEP9lFkBMIiLR11OR3k2Q==
X-Received: by 2002:ab0:4307:: with SMTP id k7mr23734894uak.45.1560359518677;
        Wed, 12 Jun 2019 10:11:58 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxjwmNKAk7XF8Be95HFGX2v6OT4RV3ImObeSB3l/9Ux53bX7WK02WR3Pj4Y7YqJK7zVQ+3+
X-Received: by 2002:ab0:4307:: with SMTP id k7mr23734826uak.45.1560359518023;
        Wed, 12 Jun 2019 10:11:58 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560359518; cv=none;
        d=google.com; s=arc-20160816;
        b=UfdmCpPi4iEbTDhwocQWiGYDMrMOEfPp5PeUHPgze4WZaqBH+TuVDAV+Abn1dWylP9
         owFws4rULwScFepiw9SLey0NneFqE2ilNJaroxhOJDfGqI7MoSXTidaZ4FBFZlD328Z3
         u8NMQge5pJqfb3T56/VY4mO4cV7qBk8WNPF+PcFNq0Y/gOqLDFqWbTHX7PEUGDWZ617o
         IWE4Om3roPHzy+5mqYZSqQef3y3SL4Qi5QQMy7LZm9s5/qPtOS1+Mwc8ZUejAF/AueUO
         wfsgyu/6SD0T72jDrN7tOg826J7cUzoAECJDpBaWL9Mh1yVS/R0RyjQN+h5UqNmXDBsv
         aYow==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=y0y2fCtE+zaOH2XT3643VHxhFHXbECws0ZTrhMzBQQU=;
        b=DiG7prOfwBLI5BrmhELaxHqXWRskP2jlcf1IfZzGQq07CYesJHMAwaSMHcwpZAL0zE
         GUsa8FtcBSW0PWn/4bjfgI/pT6bO7kVIlPg3E9sNQaYo+6F+I6RMzncOMqBafZFG6Kwe
         i/04WhjykoglT/n4VAIlcxXVfsQqBs9pbOZNfUB8/6wXCz/ijXjZwbFsZ5wFz8QPxbgE
         ysfzhFZriYrqQ5yGQnUiWYnKiH/fVKUtU+Sr+85fnEDiOBvmzuSm+VZUdIPWGkjKUEV6
         vGM2Jaq3OWk6BHlg3970s0R97fvrHu/5pEBFGYItmdWdMPT2ap7N+RX068KJYJBlOFbX
         BEFw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@amazon.de header.s=amazon201209 header.b="T1+M/fEJ";
       spf=pass (google.com: domain of prvs=059bff19d=mhillenb@amazon.com designates 207.171.190.10 as permitted sender) smtp.mailfrom="prvs=059bff19d=mhillenb@amazon.com";
       dmarc=pass (p=QUARANTINE sp=QUARANTINE dis=NONE) header.from=amazon.de
Received: from smtp-fw-33001.amazon.com (smtp-fw-33001.amazon.com. [207.171.190.10])
        by mx.google.com with ESMTPS id s188si112206vkg.15.2019.06.12.10.11.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Jun 2019 10:11:58 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=059bff19d=mhillenb@amazon.com designates 207.171.190.10 as permitted sender) client-ip=207.171.190.10;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@amazon.de header.s=amazon201209 header.b="T1+M/fEJ";
       spf=pass (google.com: domain of prvs=059bff19d=mhillenb@amazon.com designates 207.171.190.10 as permitted sender) smtp.mailfrom="prvs=059bff19d=mhillenb@amazon.com";
       dmarc=pass (p=QUARANTINE sp=QUARANTINE dis=NONE) header.from=amazon.de
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
  d=amazon.de; i=@amazon.de; q=dns/txt; s=amazon201209;
  t=1560359517; x=1591895517;
  h=from:to:cc:subject:date:message-id:in-reply-to:
   references:mime-version:content-transfer-encoding;
  bh=y0y2fCtE+zaOH2XT3643VHxhFHXbECws0ZTrhMzBQQU=;
  b=T1+M/fEJAofcbX7d4d2xJiXxoxc2bfBBTqATNmcJiX0+868WyIzqcaFX
   vfkzJ3/fHzIrF9ZBoa+N2KCJZ6rG9MEFonNJLfkEFYFwXWUC1ikCWar+T
   etfw52zh5mRgCh42rihGWFPb9bAMeEN0jVCT9J3ohqw6tVMTKb5hcZ7Mh
   w=;
X-IronPort-AV: E=Sophos;i="5.62,366,1554768000"; 
   d="scan'208";a="805048839"
Received: from sea3-co-svc-lb6-vlan2.sea.amazon.com (HELO email-inbound-relay-2b-c7131dcf.us-west-2.amazon.com) ([10.47.22.34])
  by smtp-border-fw-out-33001.sea14.amazon.com with ESMTP; 12 Jun 2019 17:11:56 +0000
Received: from ua08cfdeba6fe59dc80a8.ant.amazon.com (pdx2-ws-svc-lb17-vlan3.amazon.com [10.247.140.70])
	by email-inbound-relay-2b-c7131dcf.us-west-2.amazon.com (Postfix) with ESMTPS id 45AE6A256D;
	Wed, 12 Jun 2019 17:11:56 +0000 (UTC)
Received: from ua08cfdeba6fe59dc80a8.ant.amazon.com (ua08cfdeba6fe59dc80a8.ant.amazon.com [127.0.0.1])
	by ua08cfdeba6fe59dc80a8.ant.amazon.com (8.15.2/8.15.2/Debian-3) with ESMTP id x5CHBsGK018632;
	Wed, 12 Jun 2019 19:11:54 +0200
Received: (from mhillenb@localhost)
	by ua08cfdeba6fe59dc80a8.ant.amazon.com (8.15.2/8.15.2/Submit) id x5CHBr1J018630;
	Wed, 12 Jun 2019 19:11:53 +0200
From: Marius Hillenbrand <mhillenb@amazon.de>
To: kvm@vger.kernel.org
Cc: Marius Hillenbrand <mhillenb@amazon.de>, linux-kernel@vger.kernel.org,
        kernel-hardening@lists.openwall.com, linux-mm@kvack.org,
        Alexander Graf <graf@amazon.de>, David Woodhouse <dwmw@amazon.co.uk>,
        Julian Stecklina <jsteckli@amazon.de>
Subject: [RFC 08/10] kvm, vmx: move register clearing out of assembly path
Date: Wed, 12 Jun 2019 19:08:40 +0200
Message-Id: <20190612170834.14855-9-mhillenb@amazon.de>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190612170834.14855-1-mhillenb@amazon.de>
References: <20190612170834.14855-1-mhillenb@amazon.de>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Julian Stecklina <jsteckli@amazon.de>

Split the security related register clearing out of the large inline
assembly VM entry path. This results in two slightly less complicated
inline assembly statements, where it is clearer what each one does.

Signed-off-by: Julian Stecklina <jsteckli@amazon.de>
[rebased to 4.20; note that the purpose of this patch is to make the
changes in the next commit more readable. we will drop this patch when
rebasing to 5.x, since major refactoring of KVM makes it redundant.]
Signed-off-by: Marius Hillenbrand <mhillenb@amazon.de>
Cc: Alexander Graf <graf@amazon.de>
Cc: David Woodhouse <dwmw@amazon.co.uk>
---
 arch/x86/kvm/vmx.c | 46 +++++++++++++++++++++++++++++-----------------
 1 file changed, 29 insertions(+), 17 deletions(-)

diff --git a/arch/x86/kvm/vmx.c b/arch/x86/kvm/vmx.c
index 16a383635b59..0fe9a4ab8268 100644
--- a/arch/x86/kvm/vmx.c
+++ b/arch/x86/kvm/vmx.c
@@ -11582,24 +11582,7 @@ static void __noclone vmx_vcpu_run(struct kvm_vcpu *vcpu)
 		"mov %%r13, %c[r13](%0) \n\t"
 		"mov %%r14, %c[r14](%0) \n\t"
 		"mov %%r15, %c[r15](%0) \n\t"
-		/*
-		* Clear host registers marked as clobbered to prevent
-		* speculative use.
-		*/
-		"xor %%r8d,  %%r8d \n\t"
-		"xor %%r9d,  %%r9d \n\t"
-		"xor %%r10d, %%r10d \n\t"
-		"xor %%r11d, %%r11d \n\t"
-		"xor %%r12d, %%r12d \n\t"
-		"xor %%r13d, %%r13d \n\t"
-		"xor %%r14d, %%r14d \n\t"
-		"xor %%r15d, %%r15d \n\t"
 #endif
-
-		"xor %%eax, %%eax \n\t"
-		"xor %%ebx, %%ebx \n\t"
-		"xor %%esi, %%esi \n\t"
-		"xor %%edi, %%edi \n\t"
 		"pop  %%" _ASM_BP "; pop  %%" _ASM_DX " \n\t"
 		".pushsection .rodata \n\t"
 		".global vmx_return \n\t"
@@ -11636,6 +11619,35 @@ static void __noclone vmx_vcpu_run(struct kvm_vcpu *vcpu)
 #endif
 	      );
 
+	/*
+         * Explicitly clear (in addition to marking them as clobbered) all GPRs
+         * that have not been loaded with host state to prevent speculatively
+         * using the guest's values.
+         */
+	asm volatile (
+		"xor %%eax, %%eax \n\t"
+		"xor %%ebx, %%ebx \n\t"
+		"xor %%esi, %%esi \n\t"
+		"xor %%edi, %%edi \n\t"
+#ifdef CONFIG_X86_64
+		"xor %%r8d,  %%r8d \n\t"
+		"xor %%r9d,  %%r9d \n\t"
+		"xor %%r10d, %%r10d \n\t"
+		"xor %%r11d, %%r11d \n\t"
+		"xor %%r12d, %%r12d \n\t"
+		"xor %%r13d, %%r13d \n\t"
+		"xor %%r14d, %%r14d \n\t"
+		"xor %%r15d, %%r15d \n\t"
+#endif
+		::: "cc"
+#ifdef CONFIG_X86_64
+		 , "rax", "rbx", "rsi", "rdi"
+		 , "r8", "r9", "r10", "r11", "r12", "r13", "r14", "r15"
+#else
+		 , "eax", "ebx", "esi", "edi"
+#endif
+		);
+
 	/*
 	 * We do not use IBRS in the kernel. If this vCPU has used the
 	 * SPEC_CTRL MSR it may have left it on; save the value and
-- 
2.21.0

