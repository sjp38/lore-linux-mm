Return-Path: <SRS0=NGLy=QU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 33EF9C282CA
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 08:06:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EF4C7222B5
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 08:06:48 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EF4C7222B5
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8825C8E0004; Wed, 13 Feb 2019 03:06:48 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 832978E0001; Wed, 13 Feb 2019 03:06:48 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6AF0B8E0004; Wed, 13 Feb 2019 03:06:48 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 234BE8E0001
	for <linux-mm@kvack.org>; Wed, 13 Feb 2019 03:06:48 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id x15so665757edd.2
        for <linux-mm@kvack.org>; Wed, 13 Feb 2019 00:06:48 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=urH6OH0gut0tDgnHnlkLf46J8KjXnTjzYyRqRVAC1C0=;
        b=an+GpR3hitDBj+4FGvvlBKFM3/fs6a2JcaVSp98BvJfTJJAM7d+kS1aNp3u1kq7o+Z
         ooGvEM5E3ff7o5x6yROcp28bvowai7zy/Ks+6ve4NMPqgVA2T3fedjkjzeCKIdU3BRQx
         kG3kuk76VvGKB5G7qV5y+bWhbSJx1sYc4OBVMHNYCLW+GLcfFDg3rVVlbDErwiojX4NU
         YcD6hi4pAUmgea86FVwAK0HnWk6O6k+DUPZST/D7WXR4airmf3FHukUiXKOTekU/iLBb
         i1p5WTatCVlRySzScCo7MjsKoKsjRmkjwOVmT3vCe3Ei42A1hM9WcE3uf7gbdBMlFTsa
         11QA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
X-Gm-Message-State: AHQUAuaX/G7yb6l+7tJfFOhrjBMs5iNH13k0JEzMtqgtE99kSqm4ksbl
	tgfRd4l8TJmzOc79E8twXQuE5NFX/HSLa3WFDHnbnlpO6AWJNbEbMpcfSk97vJ21m3eL74Ee2vo
	DonNwPO5X/iDYrANWh1DiuOW+7LlIfECb4e8BpLyFPeiRHqLdUNpRNGDRtIT7c3GbDg==
X-Received: by 2002:a50:8b42:: with SMTP id l60mr6365089edl.61.1550045207634;
        Wed, 13 Feb 2019 00:06:47 -0800 (PST)
X-Google-Smtp-Source: AHgI3IaVEfBorSaR0O7jLJtoj1r2iB4ISGtshFBPJChWA4zopYNF/TpLabh3Y7x3KaBrmluSCmma
X-Received: by 2002:a50:8b42:: with SMTP id l60mr6365028edl.61.1550045206554;
        Wed, 13 Feb 2019 00:06:46 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550045206; cv=none;
        d=google.com; s=arc-20160816;
        b=b9u0+jjV+1iFQZiEz8KNMY4z56PIHhKbJuIfAo0Hy8R8/iNVxrm+FM7W/1/OyNKKjb
         bvf/OCHDKUfMb+jVvo+V1SFvvDuUMn1GDYVN0MZ56d3cwjy2f5/UZLMHKWJZ3e7zdWUN
         +51wlLGz+cENIX3Tq6KRRbugWSqVr3a2kGg4HEB+Ucwqd7T4KUl73z9zYUf9GqjJZQ8S
         cbmy2TJdR6o7EAYvGzN6VNnsfpEiGI1wkekI724GljpU+gypYWiPINnp9dFkajZLUfjg
         W255+BnAUaozxpirN5AFsIXSpGojUb7Ix9tLb9Q4nYagoyBMtP0jeYXJ4nt0bPGjngha
         ZFWg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=urH6OH0gut0tDgnHnlkLf46J8KjXnTjzYyRqRVAC1C0=;
        b=TgjthD35x7TYinJllYE+VchIUc3sI2L3tKxOeuCaiEZCL+xDE0NLJr0jP09Tp7ES4A
         hFB+te8KDgGrEIVmW8h58h/YZF/UZeWWnAL0OU31h9ek5YHIBuPi08oxRAT/q3mxjZZI
         SX8QL1F0leiDHLVCJEwXFB5SpoHsjGovgABS6foQDjmjvK3t9UewL0JuD7C8CPqaSFog
         +YPHRFU08ee1vv2eMURxmyQWUix9yF7K2IRdKbgqOFXvZyndY54m9gK91F9SzV0IBAZk
         KA5y6y0r3xi1gjJe7pPV73r1oMxqWel/XS61NGRK8cvlLkKLPGjEfo06GXvw6UW0J6kf
         u64g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id t23si3044404ejf.99.2019.02.13.00.06.46
        for <linux-mm@kvack.org>;
        Wed, 13 Feb 2019 00:06:46 -0800 (PST)
Received-SPF: pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 8337115BF;
	Wed, 13 Feb 2019 00:06:45 -0800 (PST)
Received: from p8cg001049571a15.blr.arm.com (p8cg001049571a15.blr.arm.com [10.162.43.147])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPA id 22D493F575;
	Wed, 13 Feb 2019 00:06:41 -0800 (PST)
From: Anshuman Khandual <anshuman.khandual@arm.com>
To: linux-mm@kvack.org,
	akpm@linux-foundation.org
Cc: mhocko@kernel.org,
	kirill@shutemov.name,
	kirill.shutemov@linux.intel.com,
	vbabka@suse.cz,
	will.deacon@arm.com,
	catalin.marinas@arm.com,
	dave.hansen@intel.com
Subject: [RFC 2/4] arm64/mm: Identify user level instruction faults
Date: Wed, 13 Feb 2019 13:36:29 +0530
Message-Id: <1550045191-27483-3-git-send-email-anshuman.khandual@arm.com>
X-Mailer: git-send-email 2.7.4
In-Reply-To: <1550045191-27483-1-git-send-email-anshuman.khandual@arm.com>
References: <1550045191-27483-1-git-send-email-anshuman.khandual@arm.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Page fault flags (FAULT_FLAG_XXX) need to be passed down fault handling
path for appropriate action and reporting. Identify user instruction
fetch faults and mark them with FAULT_FLAG_INSTRUCTION.

Signed-off-by: Anshuman Khandual <anshuman.khandual@arm.com>
---
 arch/arm64/mm/fault.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/arch/arm64/mm/fault.c b/arch/arm64/mm/fault.c
index efb7b2c..591670d 100644
--- a/arch/arm64/mm/fault.c
+++ b/arch/arm64/mm/fault.c
@@ -468,6 +468,9 @@ static int __kprobes do_page_fault(unsigned long addr, unsigned int esr,
 		mm_flags |= FAULT_FLAG_WRITE;
 	}
 
+	if (is_el0_instruction_abort(esr))
+		mm_flags |= FAULT_FLAG_INSTRUCTION;
+
 	if (is_ttbr0_addr(addr) && is_el1_permission_fault(addr, esr, regs)) {
 		/* regs->orig_addr_limit may be 0 if we entered from EL0 */
 		if (regs->orig_addr_limit == KERNEL_DS)
-- 
2.7.4

