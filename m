Return-Path: <SRS0=h8p8=S5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.8 required=3.0 tests=DATE_IN_PAST_06_12,
	DKIM_SIGNED,DKIM_VALID,DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AFD7DC4321A
	for <linux-mm@archiver.kernel.org>; Sat, 27 Apr 2019 06:43:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 66701208CB
	for <linux-mm@archiver.kernel.org>; Sat, 27 Apr 2019 06:43:15 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="vdYahecr"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 66701208CB
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DE1B06B000A; Sat, 27 Apr 2019 02:43:10 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D6BFD6B000C; Sat, 27 Apr 2019 02:43:10 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BBAEB6B000D; Sat, 27 Apr 2019 02:43:10 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 80AAE6B000A
	for <linux-mm@kvack.org>; Sat, 27 Apr 2019 02:43:10 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id d1so3471562pgk.21
        for <linux-mm@kvack.org>; Fri, 26 Apr 2019 23:43:10 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references;
        bh=wqvLZPneRcLgxY6Wjfk6EEQBPauaGcOxn9fq0yjJ9xE=;
        b=iZd05zzNwB0Qflq7/jXw8BqypFhR2t19rGxqnoEAffhHcUlGvIIVf7PizbiQNfvitY
         RSHoPYmVdjRWh61T39cAOtdSOY9kMgu6L2zln4pvAEWF41JFMThTNAfHA3HuuE+zYy2t
         2Sn8DygHF7K2moorh2gtsECY7IdpA0gfow0fNNt9JrqGOUXDzc+jkWIRypHkrahEjdYL
         vyV83mumOvK5PwFZjfEuAGTQ7SY8SqZeW/0gWS1iIqmJfOdEs9RKC8yPwj58MXM0IAjt
         HzEDFOB8R1LExdHjZvi5LqdWg7TzDFwAvVsYkdQEjkSKq+dkxiJw3TaHoDHZOKTl6Qb+
         y8qA==
X-Gm-Message-State: APjAAAWSe1kYUAuyTWU7AIlyNWegohj9FXegFmlbncE70GCfho3WRtFN
	toKS9ia0bSUN3kZEcBeh+8CAbJeTai7Wtbux9mrxTLoL6nb0P0u0JrRtGdsCigxG86elM4q/kLC
	wtTw5dFuSi5K34lXkLpgVnYafXPdcpd5izcYLDQFpn3Dq+AR6cLi+8pVA5M77RyhKRw==
X-Received: by 2002:a63:e850:: with SMTP id a16mr48266792pgk.195.1556347390210;
        Fri, 26 Apr 2019 23:43:10 -0700 (PDT)
X-Received: by 2002:a63:e850:: with SMTP id a16mr48266736pgk.195.1556347388908;
        Fri, 26 Apr 2019 23:43:08 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556347388; cv=none;
        d=google.com; s=arc-20160816;
        b=lBNV+3IljuuybbAh36WqvAwoLhFjTattTmXJ6zaMvqLdvWTMnQH+SefTYrCWqPfqb8
         JpeEpkMYHvTjYAcB1pCpc1JHLdFdp4Pco0Hk1xVOyE6BHmWMYo4rrtz7yfUoHzIQv7Hp
         3qtTga4J357Hs/6rcQ5yd9t4qnj7bZ4UTK34UP4cGIKD7qZMzTgqXwOpS3q+i3mcunku
         17yIRC4NnGJyhpuD+ENKAMlpVNJCWuB4ZOcrxeC8NFPkGAAC27W+G4OXspiKFzcdAmwY
         Wnj+fqyzLoC6Jz7ME6C6KPhNG7vYGsOYQ0OCMj4iCU+cIAhWICIUb218fheDphMwRT9e
         dwog==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from
         :dkim-signature;
        bh=wqvLZPneRcLgxY6Wjfk6EEQBPauaGcOxn9fq0yjJ9xE=;
        b=BcdyXQ50p8M5+U2zfIVgP09UPFapVK2UXa9+OrjUKBMmhDENuTYnt44qmrLeEjl7I6
         xm2bl/YDRfQBM0Rax3rkoRFnLpLhGdQmVwkj29zG5S1Dmp1C02eR6qNIKjxe2EWgiuG9
         GNQS6hK9y25XlfQ6ReoX+Ujclpa1Sq2iattiIy5mPw1AKhHEidi8zbPjGp3cZnwxDban
         GTctkUnEXBVE3sSzQNtKCKMjFteMNAFeV7FpmgFqeWTMYmTrTteRYGUot7cHphUwerY7
         v43lyWkt6D/CuAZEJEvjI5zySKn6o7Vq/wC3xFfsCdDMeBHEdeQekG1bCNm4KNAeKgBd
         XuHQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=vdYahecr;
       spf=pass (google.com: domain of nadav.amit@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=nadav.amit@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z18sor27018249plo.58.2019.04.26.23.43.08
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 26 Apr 2019 23:43:08 -0700 (PDT)
Received-SPF: pass (google.com: domain of nadav.amit@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=vdYahecr;
       spf=pass (google.com: domain of nadav.amit@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=nadav.amit@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references;
        bh=wqvLZPneRcLgxY6Wjfk6EEQBPauaGcOxn9fq0yjJ9xE=;
        b=vdYahecrwl2Sp5UawSR3og0bnv/oKfDwV/Dqodp6SG75rtt3oI1BxkHqScjMRc/B0U
         ndpm0CSM99X5DI5nXyZ0qilWlZ5y+YmffvE0rzTsPOh9Lg0wVC5gzIbXO3T2rI/43jKw
         dSv/fQEMrgklgF9DfRp0UTkxOOmbTA2q76DVrniyNWh8V594RE3EBRYYfPR9C72DIbVe
         QvUfF6WjCix52aEKKarcvG6J8JGMJ6kiAHPNxAecwgyTiM6P6ST8UlxjffLYXWC/UN5g
         Hhv9thRtl94b6Emad3qIhmqwC571N8N4kkx/zbp3oEc24WAmffQk4ZXiiSSJrBGsI7VY
         gu0w==
X-Google-Smtp-Source: APXvYqyiprnnWU4rXtsHhhC4I5UqVMx78ccNfm1X35wazpAaZSJma1EHcKW1CFUxAhCYo5lEBNcLEA==
X-Received: by 2002:a17:902:aa83:: with SMTP id d3mr8074837plr.108.1556347388411;
        Fri, 26 Apr 2019 23:43:08 -0700 (PDT)
Received: from sc2-haas01-esx0118.eng.vmware.com ([66.170.99.1])
        by smtp.gmail.com with ESMTPSA id j22sm36460145pfn.129.2019.04.26.23.43.07
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 26 Apr 2019 23:43:07 -0700 (PDT)
From: nadav.amit@gmail.com
To: Peter Zijlstra <peterz@infradead.org>,
	Borislav Petkov <bp@alien8.de>,
	Andy Lutomirski <luto@kernel.org>,
	Ingo Molnar <mingo@redhat.com>
Cc: linux-kernel@vger.kernel.org,
	x86@kernel.org,
	hpa@zytor.com,
	Thomas Gleixner <tglx@linutronix.de>,
	Nadav Amit <nadav.amit@gmail.com>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	linux_dti@icloud.com,
	linux-integrity@vger.kernel.org,
	linux-security-module@vger.kernel.org,
	akpm@linux-foundation.org,
	kernel-hardening@lists.openwall.com,
	linux-mm@kvack.org,
	will.deacon@arm.com,
	ard.biesheuvel@linaro.org,
	kristen@linux.intel.com,
	deneen.t.dock@intel.com,
	Rick Edgecombe <rick.p.edgecombe@intel.com>,
	Nadav Amit <namit@vmware.com>
Subject: [PATCH v6 04/24] x86/mm: Save debug registers when loading a temporary mm
Date: Fri, 26 Apr 2019 16:22:43 -0700
Message-Id: <20190426232303.28381-5-nadav.amit@gmail.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190426232303.28381-1-nadav.amit@gmail.com>
References: <20190426232303.28381-1-nadav.amit@gmail.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Nadav Amit <namit@vmware.com>

Prevent user watchpoints from mistakenly firing while the temporary mm
is being used. As the addresses of the temporary mm might overlap those
of the user-process, this is necessary to prevent wrong signals or worse
things from happening.

Cc: Andy Lutomirski <luto@kernel.org>
Acked-by: Peter Zijlstra (Intel) <peterz@infradead.org>
Signed-off-by: Nadav Amit <namit@vmware.com>
Signed-off-by: Rick Edgecombe <rick.p.edgecombe@intel.com>
---
 arch/x86/include/asm/mmu_context.h | 23 +++++++++++++++++++++++
 1 file changed, 23 insertions(+)

diff --git a/arch/x86/include/asm/mmu_context.h b/arch/x86/include/asm/mmu_context.h
index 24dc3b810970..93dff1963337 100644
--- a/arch/x86/include/asm/mmu_context.h
+++ b/arch/x86/include/asm/mmu_context.h
@@ -13,6 +13,7 @@
 #include <asm/tlbflush.h>
 #include <asm/paravirt.h>
 #include <asm/mpx.h>
+#include <asm/debugreg.h>
 
 extern atomic64_t last_mm_ctx_id;
 
@@ -380,6 +381,21 @@ static inline temp_mm_state_t use_temporary_mm(struct mm_struct *mm)
 	lockdep_assert_irqs_disabled();
 	temp_state.mm = this_cpu_read(cpu_tlbstate.loaded_mm);
 	switch_mm_irqs_off(NULL, mm, current);
+
+	/*
+	 * If breakpoints are enabled, disable them while the temporary mm is
+	 * used. Userspace might set up watchpoints on addresses that are used
+	 * in the temporary mm, which would lead to wrong signals being sent or
+	 * crashes.
+	 *
+	 * Note that breakpoints are not disabled selectively, which also causes
+	 * kernel breakpoints (e.g., perf's) to be disabled. This might be
+	 * undesirable, but still seems reasonable as the code that runs in the
+	 * temporary mm should be short.
+	 */
+	if (hw_breakpoint_active())
+		hw_breakpoint_disable();
+
 	return temp_state;
 }
 
@@ -387,6 +403,13 @@ static inline void unuse_temporary_mm(temp_mm_state_t prev_state)
 {
 	lockdep_assert_irqs_disabled();
 	switch_mm_irqs_off(NULL, prev_state.mm, current);
+
+	/*
+	 * Restore the breakpoints if they were disabled before the temporary mm
+	 * was loaded.
+	 */
+	if (hw_breakpoint_active())
+		hw_breakpoint_restore();
 }
 
 #endif /* _ASM_X86_MMU_CONTEXT_H */
-- 
2.17.1

