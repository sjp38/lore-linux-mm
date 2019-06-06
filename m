Return-Path: <SRS0=utKX=UF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-12.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CBBE2C04AB5
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 17:25:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7ABAA2083D
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 17:25:36 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=zytor.com header.i=@zytor.com header.b="lE5PJjM0"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7ABAA2083D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=zytor.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 016F06B027D; Thu,  6 Jun 2019 13:25:36 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F09AB6B027E; Thu,  6 Jun 2019 13:25:35 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DD0916B027F; Thu,  6 Jun 2019 13:25:35 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id A62E76B027D
	for <linux-mm@kvack.org>; Thu,  6 Jun 2019 13:25:35 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id s195so2019878pgs.13
        for <linux-mm@kvack.org>; Thu, 06 Jun 2019 10:25:35 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-filter:dkim-signature:date:sender:from
         :message-id:cc:reply-to:in-reply-to:references:to:subject
         :git-commit-id:robot-id:robot-unsubscribe:mime-version
         :content-transfer-encoding:content-disposition:precedence;
        bh=m4AlyVwXpZA6r6w7UbdCGAzUMcLMnUoq15ImttvhGn8=;
        b=GFUvuLcGiVGV9I2vTSlmowC4HUkMqZEacUUueJ/MXumV1kqViiLPhEWRZf04exWPV3
         952ARLuAx4jlQ79qRGcE7nQFVNxcQkvvF2zej15qNr5fFfGguBbQfHTxCzGrAjieIFVT
         A5t+OcBo8kWRmOFWF2sMSFrHm5h5X/tBYZu0cbRGDmO7YRD5HUR+Gd1pzhOWLirCmlsT
         bEXARCGvwlXGTXuAn3Y43/ysixjWMOidFPOnGIFhTmABJuVgr9q8KOte/oefNuilxcIN
         bHrXnG458ugvAJiHnUBmjIg+CYKMNMfrH6S+f2Qh/ttrNU+FdGRQ98+pkRMRfqV+ikFP
         LNEg==
X-Gm-Message-State: APjAAAU7U/7fruP+iYcivXvpQ2KMqkC1IUGcrjfu+s+asC1ORM3ihVf6
	zdCCXNYBi3McQVd/qAKWshMczHkg9IRneznkHBSlmTB6BncFlVVDSTxLV3aGbLs3MFWVNQ0+lBc
	D4qfwucmoUcd0jwhY40GP/6Ug50XceeQaxvum1OXDhQZnWChdbEH9QNink94hGMj6zw==
X-Received: by 2002:a17:90a:7343:: with SMTP id j3mr911903pjs.84.1559841935282;
        Thu, 06 Jun 2019 10:25:35 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxQ2BCGG9LjPAT42y47jnT9NUTTpiSLa77zOzqDeFG84xNyijBkQvRDKzESizwiStqGbCUl
X-Received: by 2002:a17:90a:7343:: with SMTP id j3mr911810pjs.84.1559841934057;
        Thu, 06 Jun 2019 10:25:34 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559841934; cv=none;
        d=google.com; s=arc-20160816;
        b=dzUxmhNIpkftzIIUTz+08csNpNSSuTKyrW7LVpC46o2cMtBHMCx6Oqq83/In2BEqlF
         QF8thg3OcPc82Sm4BtBv2cKyi8y2PJiPRJj8abVUt/EXdsL91OCLfxLvTSzoloCO/Dk0
         ItcoFooJk1LHEGEM6eR1P23cvWpHaq/qlHbHH2TQsLAeULk5r1FtgzpRu/6HlDEP32lP
         YyXyUpnrt9E9m2zUEMLg9zfr42FXlZ7e/RCr9GH8PXKZgLPNwAlw2rGBF1Rgf4Y6s7jB
         1Uh+65bB88h5JLTWBMThGgY7vQ3UGIMZfm2bP5vOqegadaZ/C+ojQvIR9NW6qNZ/ckqR
         DPrQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=precedence:content-disposition:content-transfer-encoding
         :mime-version:robot-unsubscribe:robot-id:git-commit-id:subject:to
         :references:in-reply-to:reply-to:cc:message-id:from:sender:date
         :dkim-signature:dkim-filter;
        bh=m4AlyVwXpZA6r6w7UbdCGAzUMcLMnUoq15ImttvhGn8=;
        b=C5/AypIrMwgpG2B0WLuAzGNxsfg+p+dku4+IxOPspqDkfUp4nMp/6AL1xctPn2iObi
         vziikQMjwO9lOW3UmB29F9pqRoIjHW26OMN4cOqEwGIldtEYKsVR1tkNVa5SQdi7b7S7
         paxppKKuY59vj2NkX7GzMimJNehiYmIn02rwkuj474/4aGOpR5SZsRmmHR6dbxSx82dW
         NKyxZJz4aTcj3Bg/JheCVkLFOTJzELrsIIavaJYPj7nuzJCsswtkAUY/H11y44GAk+yr
         PQASg+GL7M5K6ed6Q3wQzKES1J+5HiwA5nkowqk0yaHaPHI7d7/ijiLtiFGzCz9Q7wO+
         riPg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@zytor.com header.s=2019051801 header.b=lE5PJjM0;
       spf=pass (google.com: domain of tipbot@zytor.com designates 198.137.202.136 as permitted sender) smtp.mailfrom=tipbot@zytor.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=zytor.com
Received: from terminus.zytor.com (terminus.zytor.com. [198.137.202.136])
        by mx.google.com with ESMTPS id g5si2286706pjt.58.2019.06.06.10.25.33
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Thu, 06 Jun 2019 10:25:34 -0700 (PDT)
Received-SPF: pass (google.com: domain of tipbot@zytor.com designates 198.137.202.136 as permitted sender) client-ip=198.137.202.136;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@zytor.com header.s=2019051801 header.b=lE5PJjM0;
       spf=pass (google.com: domain of tipbot@zytor.com designates 198.137.202.136 as permitted sender) smtp.mailfrom=tipbot@zytor.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=zytor.com
Received: from terminus.zytor.com (localhost [127.0.0.1])
	by terminus.zytor.com (8.15.2/8.15.2) with ESMTPS id x56HPK5g2066843
	(version=TLSv1.3 cipher=TLS_AES_256_GCM_SHA384 bits=256 verify=NO);
	Thu, 6 Jun 2019 10:25:20 -0700
DKIM-Filter: OpenDKIM Filter v2.11.0 terminus.zytor.com x56HPK5g2066843
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=zytor.com;
	s=2019051801; t=1559841921;
	bh=m4AlyVwXpZA6r6w7UbdCGAzUMcLMnUoq15ImttvhGn8=;
	h=Date:From:Cc:Reply-To:In-Reply-To:References:To:Subject:From;
	b=lE5PJjM03xymRMzb4SFs9dmPHVkLeLDwE8aU2fwwzRIRovPRyqCcriJesZ8sJEsPs
	 QLNoteQwH1Oqj3o7hebpAnA3PqZlO3iyvsCiGarHCZx31hdvv59JghyVIYw+OsqHY+
	 dfbtCRm16POpRwZyHLw/nqkxzExkhLZ8/XQnh9k55P/5iqh1g/wwtCgaROYqvk1xQ9
	 wObSupDEoL6bpJfkkOmHCvNF6XObZ3eDm0bMPF5vzB9tX9upaXgS9NhU3K/sdGnn3W
	 sQGMp5dBlDB/QRW59jfQblAdj6HFFFlKniwwqUND12hdAcGViBGVlgJvjfFBVruwQ+
	 3dofqJyVe0kHg==
Received: (from tipbot@localhost)
	by terminus.zytor.com (8.15.2/8.15.2/Submit) id x56HPI5t2066840;
	Thu, 6 Jun 2019 10:25:18 -0700
Date: Thu, 6 Jun 2019 10:25:18 -0700
X-Authentication-Warning: terminus.zytor.com: tipbot set sender to tipbot@zytor.com using -f
From: tip-bot for Hugh Dickins <tipbot@zytor.com>
Message-ID: <tip-b81ff1013eb8eef2934ca7e8cf53d553c1029e84@git.kernel.org>
Cc: akpm@linux-foundation.org, pavel@ucw.cz, jannh@google.com,
        hughd@google.com, dave.hansen@linux.intel.com, x86@kernel.org,
        mingo@redhat.com, rppt@linux.ibm.com, tglx@linutronix.de,
        linux-mm@kvack.org, bp@suse.de, mingo@kernel.org,
        chris@chris-wilson.co.uk, linux-kernel@vger.kernel.org,
        riel@surriel.com, hpa@zytor.com, bigeasy@linutronix.de,
        aarcange@redhat.com
Reply-To: hughd@google.com, jannh@google.com, pavel@ucw.cz,
        akpm@linux-foundation.org, mingo@redhat.com,
        dave.hansen@linux.intel.com, x86@kernel.org, chris@chris-wilson.co.uk,
        mingo@kernel.org, bp@suse.de, tglx@linutronix.de, rppt@linux.ibm.com,
        linux-mm@kvack.org, bigeasy@linutronix.de, aarcange@redhat.com,
        hpa@zytor.com, riel@surriel.com, linux-kernel@vger.kernel.org
In-Reply-To: <1557844195-18882-1-git-send-email-rppt@linux.ibm.com>
References: <20190529072540.g46j4kfeae37a3iu@linutronix.de>
	<1557844195-18882-1-git-send-email-rppt@linux.ibm.com>
To: linux-tip-commits@vger.kernel.org
Subject: [tip:x86/urgent] x86/fpu: Use fault_in_pages_writeable() for
 pre-faulting
Git-Commit-ID: b81ff1013eb8eef2934ca7e8cf53d553c1029e84
X-Mailer: tip-git-log-daemon
Robot-ID: <tip-bot.git.kernel.org>
Robot-Unsubscribe: Contact <mailto:hpa@kernel.org> to get blacklisted from
 these emails
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Content-Type: text/plain; charset=UTF-8
Content-Disposition: inline
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Commit-ID:  b81ff1013eb8eef2934ca7e8cf53d553c1029e84
Gitweb:     https://git.kernel.org/tip/b81ff1013eb8eef2934ca7e8cf53d553c1029e84
Author:     Hugh Dickins <hughd@google.com>
AuthorDate: Wed, 29 May 2019 09:25:40 +0200
Committer:  Borislav Petkov <bp@suse.de>
CommitDate: Thu, 6 Jun 2019 19:15:17 +0200

x86/fpu: Use fault_in_pages_writeable() for pre-faulting

Since commit

   d9c9ce34ed5c8 ("x86/fpu: Fault-in user stack if copy_fpstate_to_sigframe() fails")

get_user_pages_unlocked() pre-faults user's memory if a write generates
a page fault while the handler is disabled.

This works in general and uncovered a bug as reported by Mike
Rapoport¹. It has been pointed out that this function may be fragile
and a simple pre-fault as in fault_in_pages_writeable() would be a
better solution. Better as in taste and simplicity: that write (as
performed by the alternative function) performs exactly the same
faulting of memory as before. This was suggested by Hugh Dickins and
Andrew Morton.

Use fault_in_pages_writeable() for pre-faulting user's stack.

  [ bigeasy: Write commit message. ]
  [ bp: Massage some. ]

¹ https://lkml.kernel.org/r/1557844195-18882-1-git-send-email-rppt@linux.ibm.com

Fixes: d9c9ce34ed5c8 ("x86/fpu: Fault-in user stack if copy_fpstate_to_sigframe() fails")
Suggested-by: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Hugh Dickins <hughd@google.com>
Signed-off-by: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Signed-off-by: Borislav Petkov <bp@suse.de>
Tested-by: Chris Wilson <chris@chris-wilson.co.uk>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Dave Hansen <dave.hansen@linux.intel.com>
Cc: "H. Peter Anvin" <hpa@zytor.com>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: Jann Horn <jannh@google.com>
Cc: linux-mm <linux-mm@kvack.org>
Cc: Mike Rapoport <rppt@linux.ibm.com>
Cc: Pavel Machek <pavel@ucw.cz>
Cc: Rik van Riel <riel@surriel.com>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: x86-ml <x86@kernel.org>
Link: https://lkml.kernel.org/r/20190529072540.g46j4kfeae37a3iu@linutronix.de
Link: https://lkml.kernel.org/r/1557844195-18882-1-git-send-email-rppt@linux.ibm.com
---
 arch/x86/kernel/fpu/signal.c | 11 ++---------
 1 file changed, 2 insertions(+), 9 deletions(-)

diff --git a/arch/x86/kernel/fpu/signal.c b/arch/x86/kernel/fpu/signal.c
index 5a8d118bc423..060d6188b453 100644
--- a/arch/x86/kernel/fpu/signal.c
+++ b/arch/x86/kernel/fpu/signal.c
@@ -5,6 +5,7 @@
 
 #include <linux/compat.h>
 #include <linux/cpu.h>
+#include <linux/pagemap.h>
 
 #include <asm/fpu/internal.h>
 #include <asm/fpu/signal.h>
@@ -189,15 +190,7 @@ retry:
 	fpregs_unlock();
 
 	if (ret) {
-		int aligned_size;
-		int nr_pages;
-
-		aligned_size = offset_in_page(buf_fx) + fpu_user_xstate_size;
-		nr_pages = DIV_ROUND_UP(aligned_size, PAGE_SIZE);
-
-		ret = get_user_pages_unlocked((unsigned long)buf_fx, nr_pages,
-					      NULL, FOLL_WRITE);
-		if (ret == nr_pages)
+		if (!fault_in_pages_writeable(buf_fx, fpu_user_xstate_size))
 			goto retry;
 		return -EFAULT;
 	}

