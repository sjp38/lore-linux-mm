Return-Path: <SRS0=Ax9E=UL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id ECE7FC31E46
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 17:11:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A092921019
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 17:11:47 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=amazon.de header.i=@amazon.de header.b="ZpUE5n3n"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A092921019
Authentication-Results: mail.kernel.org; dmarc=fail (p=quarantine dis=none) header.from=amazon.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 555416B026D; Wed, 12 Jun 2019 13:11:47 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5062D6B026E; Wed, 12 Jun 2019 13:11:47 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3F4786B026F; Wed, 12 Jun 2019 13:11:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1FA366B026D
	for <linux-mm@kvack.org>; Wed, 12 Jun 2019 13:11:47 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id d62so3772914qke.21
        for <linux-mm@kvack.org>; Wed, 12 Jun 2019 10:11:47 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=BCwbtGWRrYM8rpdyPautZ9rurvQMH3lCItd7cCuySww=;
        b=b3t2riqvDkvuwcsL7tQHhiyxs73ZcSp9oPPGSKshKNIlwMp9d411UbGMy088cYjPq/
         Q98fcUHSUs00cvVFSmXwV5yVDLg9JMaN3WFI/cNeLeuItyYidDqvETUnVeLs72SHjBxf
         bsrEUYR21533qtQ8CN02tZnZQRnfMJMHGyCyad+FqhIFfP0WppZpeOdj4WH6kIHBg5sp
         hZTm97sM9dL3Fcxm1yifWM6TkRuyT7j3F3zOpVwJ2po4IM3PjN03NBdO8co2qdeS/nI2
         lC2201nrtqoEFm6ihRNUlP7gphcngHM/ADrdIMTZHMlmRpvkQ2BiU0ntJgf1+OUYM6iY
         IeyA==
X-Gm-Message-State: APjAAAUEZ/YJAlO4hvYNW1RtPDOmMADZW26Okr6bPKsVqqCYYkGW1E9/
	s3rQxz5efPAh3h21acxaR86t8LcQCm7pNRPpfFNT0WEKDO1AVT+H3PidrTcb10h7QfMFZwzrUpf
	CfKjXS4pxvYpiOp2EFViPRBtbnyawIS3/uKa6TzSauyU1NDHpQ7JWyaW7XKP//T7+qg==
X-Received: by 2002:a05:620a:5ad:: with SMTP id q13mr13239917qkq.154.1560359506831;
        Wed, 12 Jun 2019 10:11:46 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx0vIDFB6jbIQpWEQeo78wXKshLUJKzXVi+td69ulq2HLWvCjBmP/YN5oJgoWe3xY3XIL67
X-Received: by 2002:a05:620a:5ad:: with SMTP id q13mr13239880qkq.154.1560359506198;
        Wed, 12 Jun 2019 10:11:46 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560359506; cv=none;
        d=google.com; s=arc-20160816;
        b=UgnYunk3R0lj5+SkJ6qSCoWjydLqd2VTpSEFUUIxtfvJhkamjioYDeJzOKQXK+enYG
         PgACjDJPqVRSadMV26KdIUeUN52uNrHPs7ZDQCjPyMuDyWA7/7hwt1EsBhT0TkSOR/Zm
         Av14SWWmmwOV9iNmRYvs+n/2UqR8xmN7GW7uvafRrxPxqeODeWTHgzLF7R3JmmM0x54h
         RDbyRbTlQjYKs+iDoS3FjTfk7tEoWInC/8W+kGbLebtC06ibQgqVafVixf9fzsKkCIFq
         7R98D5AX1BKN/t3gFEKfrSnUaduSRqNVADt2c15SFNhFffLan83PUMUIj8ztBazycD/U
         ZnoA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=BCwbtGWRrYM8rpdyPautZ9rurvQMH3lCItd7cCuySww=;
        b=0FQvWq4OI93NSrchkOVNBpjX3c6i9yA9XSVByOeHLt+Zwe+u0Wqq3tkvUFEwKUvq2R
         jHRNbkL25FJsw69UDeRytBg/YsNeMWm4/oYC6f72hS2FUXU05bGwatKBkalJhFHoA5Au
         jY7XVni7jNP9QZBx+shdqrjSJPPRDoHnxwOjb3IwcYjghSXW7+YQZ6QPYtUEkrvdUYCp
         S2KD8xxZQvFdR6rc9w+t2IHnGluz1SMumIczAG68pVZSCiw5IgaZYSIlgiAzve4hVjy0
         J62fRpp8Zsoz2B843RNrZGhC/YWUBxE5P+Q6Zfenk6SeS0qqIVLPSzGi8RjQGChIovLg
         NROg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@amazon.de header.s=amazon201209 header.b=ZpUE5n3n;
       spf=pass (google.com: domain of prvs=059bff19d=mhillenb@amazon.com designates 72.21.198.25 as permitted sender) smtp.mailfrom="prvs=059bff19d=mhillenb@amazon.com";
       dmarc=pass (p=QUARANTINE sp=QUARANTINE dis=NONE) header.from=amazon.de
Received: from smtp-fw-4101.amazon.com (smtp-fw-4101.amazon.com. [72.21.198.25])
        by mx.google.com with ESMTPS id n13si314695qtn.125.2019.06.12.10.11.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Jun 2019 10:11:46 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=059bff19d=mhillenb@amazon.com designates 72.21.198.25 as permitted sender) client-ip=72.21.198.25;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@amazon.de header.s=amazon201209 header.b=ZpUE5n3n;
       spf=pass (google.com: domain of prvs=059bff19d=mhillenb@amazon.com designates 72.21.198.25 as permitted sender) smtp.mailfrom="prvs=059bff19d=mhillenb@amazon.com";
       dmarc=pass (p=QUARANTINE sp=QUARANTINE dis=NONE) header.from=amazon.de
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
  d=amazon.de; i=@amazon.de; q=dns/txt; s=amazon201209;
  t=1560359506; x=1591895506;
  h=from:to:cc:subject:date:message-id:in-reply-to:
   references:mime-version:content-transfer-encoding;
  bh=BCwbtGWRrYM8rpdyPautZ9rurvQMH3lCItd7cCuySww=;
  b=ZpUE5n3n9rssRyVx4xgubcPZn8v32YgoRu+51EvPH4HMG/TYGqvq6Pr8
   8jPSQz+j5cL8ty6MRVHWKMz8E424fqQv9jyZh95q18xhw7hkLlyjGeLaJ
   e1LuCmIga9v0FUFhcdmBNNWMegxATh6bEw8gbENE6zYQUHF6hwsyi7n8G
   8=;
X-IronPort-AV: E=Sophos;i="5.62,366,1554768000"; 
   d="scan'208";a="770066910"
Received: from iad6-co-svc-p1-lb1-vlan3.amazon.com (HELO email-inbound-relay-2c-87a10be6.us-west-2.amazon.com) ([10.124.125.6])
  by smtp-border-fw-out-4101.iad4.amazon.com with ESMTP; 12 Jun 2019 17:11:44 +0000
Received: from ua08cfdeba6fe59dc80a8.ant.amazon.com (pdx2-ws-svc-lb17-vlan3.amazon.com [10.247.140.70])
	by email-inbound-relay-2c-87a10be6.us-west-2.amazon.com (Postfix) with ESMTPS id 4A3B9A2424;
	Wed, 12 Jun 2019 17:11:43 +0000 (UTC)
Received: from ua08cfdeba6fe59dc80a8.ant.amazon.com (ua08cfdeba6fe59dc80a8.ant.amazon.com [127.0.0.1])
	by ua08cfdeba6fe59dc80a8.ant.amazon.com (8.15.2/8.15.2/Debian-3) with ESMTP id x5CHBftS018553;
	Wed, 12 Jun 2019 19:11:41 +0200
Received: (from mhillenb@localhost)
	by ua08cfdeba6fe59dc80a8.ant.amazon.com (8.15.2/8.15.2/Submit) id x5CHBexi018552;
	Wed, 12 Jun 2019 19:11:40 +0200
From: Marius Hillenbrand <mhillenb@amazon.de>
To: kvm@vger.kernel.org
Cc: Marius Hillenbrand <mhillenb@amazon.de>, linux-kernel@vger.kernel.org,
        kernel-hardening@lists.openwall.com, linux-mm@kvack.org,
        Alexander Graf <graf@amazon.de>, David Woodhouse <dwmw@amazon.co.uk>,
        Julian Stecklina <jsteckli@amazon.de>
Subject: [RFC 07/10] kvm, vmx: move CR2 context switch out of assembly path
Date: Wed, 12 Jun 2019 19:08:38 +0200
Message-Id: <20190612170834.14855-8-mhillenb@amazon.de>
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

The VM entry/exit path is a giant inline assembly statement. Simplify it
by doing CR2 context switching in plain C. Move CR2 restore behind IBRS
clearing, so we reduce the amount of code we execute with IBRS on.

Using {read,write}_cr2() means KVM will use pv_mmu_ops instead of open
coding native_{read,write}_cr2(). The CR2 code has been done in
assembly since KVM's genesis[1], which predates the addition of the
paravirt ops[2], i.e. KVM isn't deliberately avoiding the paravirt
ops.

[1] Commit 6aa8b732ca01 ("[PATCH] kvm: userspace interface")
[2] Commit d3561b7fa0fb ("[PATCH] paravirt: header and stubs for paravirtualisation")

Signed-off-by: Julian Stecklina <jsteckli@amazon.de>
[rebased; note that this patch mainly improves the readability of
subsequent patches; we will drop it when rebasing to 5.x, since major
refactoring of KVM makes this patch redundant.]
Signed-off-by: Marius Hillenbrand <mhillenb@amazon.de>
Cc: Alexander Graf <graf@amazon.de>
Cc: David Woodhouse <dwmw@amazon.co.uk>
---
 arch/x86/kvm/vmx.c | 15 +++++----------
 1 file changed, 5 insertions(+), 10 deletions(-)

diff --git a/arch/x86/kvm/vmx.c b/arch/x86/kvm/vmx.c
index 6f59a6ad7835..16a383635b59 100644
--- a/arch/x86/kvm/vmx.c
+++ b/arch/x86/kvm/vmx.c
@@ -11513,6 +11513,9 @@ static void __noclone vmx_vcpu_run(struct kvm_vcpu *vcpu)
 	evmcs_rsp = static_branch_unlikely(&enable_evmcs) ?
 		(unsigned long)&current_evmcs->host_rsp : 0;
 
+	if (read_cr2() != vcpu->arch.cr2)
+		write_cr2(vcpu->arch.cr2);
+
 	if (static_branch_unlikely(&vmx_l1d_should_flush))
 		vmx_l1d_flush(vcpu);
 
@@ -11532,13 +11535,6 @@ static void __noclone vmx_vcpu_run(struct kvm_vcpu *vcpu)
 		"2: \n\t"
 		__ex("vmwrite %%" _ASM_SP ", %%" _ASM_DX) "\n\t"
 		"1: \n\t"
-		/* Reload cr2 if changed */
-		"mov %c[cr2](%0), %%" _ASM_AX " \n\t"
-		"mov %%cr2, %%" _ASM_DX " \n\t"
-		"cmp %%" _ASM_AX ", %%" _ASM_DX " \n\t"
-		"je 3f \n\t"
-		"mov %%" _ASM_AX", %%cr2 \n\t"
-		"3: \n\t"
 		/* Check if vmlaunch of vmresume is needed */
 		"cmpl $0, %c[launched](%0) \n\t"
 		/* Load guest registers.  Don't clobber flags. */
@@ -11599,8 +11595,6 @@ static void __noclone vmx_vcpu_run(struct kvm_vcpu *vcpu)
 		"xor %%r14d, %%r14d \n\t"
 		"xor %%r15d, %%r15d \n\t"
 #endif
-		"mov %%cr2, %%" _ASM_AX "   \n\t"
-		"mov %%" _ASM_AX ", %c[cr2](%0) \n\t"
 
 		"xor %%eax, %%eax \n\t"
 		"xor %%ebx, %%ebx \n\t"
@@ -11632,7 +11626,6 @@ static void __noclone vmx_vcpu_run(struct kvm_vcpu *vcpu)
 		[r14]"i"(offsetof(struct vcpu_vmx, vcpu.arch.regs[VCPU_REGS_R14])),
 		[r15]"i"(offsetof(struct vcpu_vmx, vcpu.arch.regs[VCPU_REGS_R15])),
 #endif
-		[cr2]"i"(offsetof(struct vcpu_vmx, vcpu.arch.cr2)),
 		[wordsize]"i"(sizeof(ulong))
 	      : "cc", "memory"
 #ifdef CONFIG_X86_64
@@ -11666,6 +11659,8 @@ static void __noclone vmx_vcpu_run(struct kvm_vcpu *vcpu)
 	/* Eliminate branch target predictions from guest mode */
 	vmexit_fill_RSB();
 
+	vcpu->arch.cr2 = read_cr2();
+
 	/* All fields are clean at this point */
 	if (static_branch_unlikely(&enable_evmcs))
 		current_evmcs->hv_clean_fields |=
-- 
2.21.0

