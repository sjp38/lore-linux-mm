Return-Path: <SRS0=qZKM=S2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT,USER_IN_DEF_DKIM_WL
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0F6C5C10F11
	for <linux-mm@archiver.kernel.org>; Wed, 24 Apr 2019 21:10:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B2789217D7
	for <linux-mm@archiver.kernel.org>; Wed, 24 Apr 2019 21:10:51 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="R4yWrQJj"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B2789217D7
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 538C46B0005; Wed, 24 Apr 2019 17:10:51 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4E6BD6B0006; Wed, 24 Apr 2019 17:10:51 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3AF886B0007; Wed, 24 Apr 2019 17:10:51 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vk1-f198.google.com (mail-vk1-f198.google.com [209.85.221.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1846E6B0005
	for <linux-mm@kvack.org>; Wed, 24 Apr 2019 17:10:51 -0400 (EDT)
Received: by mail-vk1-f198.google.com with SMTP id v22so9036203vkv.12
        for <linux-mm@kvack.org>; Wed, 24 Apr 2019 14:10:51 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:in-reply-to:message-id
         :mime-version:references:subject:from:to:cc;
        bh=EEx6KKB2U0RJZ21EFlDN1R7C1ruUVShWYlcQvFlcO3Y=;
        b=LOfSbEDW6KBU0iEc06Y4tAq+bVjlHjfmKxGax9EiuzTWyKNH1XyZO1sp4CtkgLL3ye
         Enxl2Dsk5cn8ddIizpMnfjAii8AMgNFx36lp/TyOSs+TtWbP4wSNGC4cICnmHL1t6Fk5
         FHVYJ3YzIjsGvoZWHRJ++RwYgfuj0AhdyB2ezco1AaEZnW7oT0LwXmICMwrMTY3w23t7
         38/FLEqXu2U/ZqiKbQWudsE3/bUifAjp4U9uEeZLeiJZjlmKbn0d3ATXFPNLw8Adx1La
         g7mU7/Azn3b3dc56ct96j5yiUU0m97j8Mcp4N5C7CUz5xHfgJvcyv3JpAHOegzJH8DBJ
         6DqQ==
X-Gm-Message-State: APjAAAUM5LgPiqsY7d18gULjBm4AdAPn8Efzvzt8v0kq8+78oda4asth
	7MVNuNAFVoasyCaVXIewWE4vEEStqlUCQ6UE2YTYQPA+klgpcoTos9130gsdBhXtwP3v8cBhgnz
	l6/LLnXD5tw8FiSxR8taV1yOpmYELiZRUSbRy9OyTjge5AfjQvAZAX5H91YDu6uYgbkzpU4PjjB
	uW8l/VAMA94CFM0vdLNDmyi+P4wo0gqSWTd3AnKHo9MX9fFmx/EZ/VVk8oL0nZY0BBtSlBvd/8m
	H4FUvnwPk9+w4stsWDQSRCiT6j0zQ==
X-Received: by 2002:a05:6102:38e:: with SMTP id m14mr6677277vsq.129.1556140250785;
        Wed, 24 Apr 2019 14:10:50 -0700 (PDT)
X-Received: by 2002:a05:6102:38e:: with SMTP id m14mr6677236vsq.129.1556140250003;
        Wed, 24 Apr 2019 14:10:50 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556140250; cv=none;
        d=google.com; s=arc-20160816;
        b=WM5AF2kbxKl9s1TjkJe50WXKeF92kmZQG64dzH5j+u7GGd7D/VKpvrMfk7Tp5/gmJX
         QMA/YuJB5O1Qlll2ZrQHgU1B5tW02m1KNmi4eIOL78qJozitMYHrPYhU6aiZEUHrM8Kr
         mtsESMtBK6G3w7a4ncCGTFZzw4Zt2yT2JrkkZU9p1ChwC6JurwSqgzpTvTm5Lh0ntWHK
         Lx/DOYuVCq2scqHkFVfFEQHKQRAcLgZ8q5ysoKhl9yR04auqJWFhyJ72Hi3BdBH3XnBT
         Ua7t9LU1wdDo9CENEnBZwwEXnq71Ja5C+8j+wLfQ362Zh9zTukfVNK6DAAx2EbgMriba
         ecRQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:references:mime-version:message-id:in-reply-to
         :date:dkim-signature;
        bh=EEx6KKB2U0RJZ21EFlDN1R7C1ruUVShWYlcQvFlcO3Y=;
        b=eJpb+qIqJ+GbxaR8F3ZJTLOsIcW6+5eBG/IhFOV7G8YfGGPLgJSR02v96hjWsTOJWi
         wA9fbeutvsiFxqBeHLwFcM/TJEfGVIcAtAwr40u93alAzGdeuH+3LGijNnic2/QNI4lC
         hMCOFVQxZ4BBGvO3iOCJJ8AX/oTS4qpmFWJ2Ydbf+8v2a25eAw5mWviUss9c1o+6YHCb
         9FeRFvPaCBClFAUynPwEW0QzzI4IdMt5bXAl1QNthnoqhDePumVoaA8ZR+F8Sdk6z6iU
         NtwqLQ6om7yI0XfpPnHqLXrhoJ/hu3wfPTZ+hNfms3cgJWfUSIT1zmhUiR7NqFlDnKet
         cMEg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=R4yWrQJj;
       spf=pass (google.com: domain of 32ddaxa4kcgouibbpmeoizzmbbowwotm.kwutqvcf-uusdiks.wzo@flex--matthewgarrett.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=32dDAXA4KCGoUIbbPMeOIZZMbbOWWOTM.KWUTQVcf-UUSdIKS.WZO@flex--matthewgarrett.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id i3sor10790257vsm.120.2019.04.24.14.10.49
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 24 Apr 2019 14:10:49 -0700 (PDT)
Received-SPF: pass (google.com: domain of 32ddaxa4kcgouibbpmeoizzmbbowwotm.kwutqvcf-uusdiks.wzo@flex--matthewgarrett.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=R4yWrQJj;
       spf=pass (google.com: domain of 32ddaxa4kcgouibbpmeoizzmbbowwotm.kwutqvcf-uusdiks.wzo@flex--matthewgarrett.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=32dDAXA4KCGoUIbbPMeOIZZMbbOWWOTM.KWUTQVcf-UUSdIKS.WZO@flex--matthewgarrett.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:in-reply-to:message-id:mime-version:references:subject:from:to
         :cc;
        bh=EEx6KKB2U0RJZ21EFlDN1R7C1ruUVShWYlcQvFlcO3Y=;
        b=R4yWrQJjCJ8Bn88/SOwrmAKIiYFKv2Ld/L1gosT676YETZR3g9s1zjAw+XfRBUFxUt
         yYONprmgp2eEy+5GwASlKDn6gwSGZ0K3BrnVJoIFcb+QwADtHOu+KbAC7dIlloZXv2zF
         InmrO+sJenQD3LDR7GFPk1TMvt2RpsFfAYIYGXpWrLIKvULclDqbRCFRJwtDNItMrOI8
         ImsP/SuHDwn3Z/5R6WU3lbRAI/gTXNTev2yRr3j9qut3+t+F1PFYVIGFC7djLq6dqM3f
         vkIjbcwDmU4DyBgpuufndPDpRyb2Mz6pZ85CKWVlgD6Y6JJtcYNhFX0c8qNlKKRe5Tbs
         sshw==
X-Google-Smtp-Source: APXvYqw3/8N6LovTbNOp1ehALE5NeruleVVSOs7bs/5NswFdHy3I9YUuHyhfGtlNzfboNB550I7lH7TLlEGNraFjTGXpbQ==
X-Received: by 2002:a67:c895:: with SMTP id v21mr855019vsk.5.1556140249661;
 Wed, 24 Apr 2019 14:10:49 -0700 (PDT)
Date: Wed, 24 Apr 2019 14:10:39 -0700
In-Reply-To: <CACdnJuup-y1xAO93wr+nr6ARacxJ9YXgaceQK9TLktE7shab1w@mail.gmail.com>
Message-Id: <20190424211038.204001-1-matthewgarrett@google.com>
Mime-Version: 1.0
References: <CACdnJuup-y1xAO93wr+nr6ARacxJ9YXgaceQK9TLktE7shab1w@mail.gmail.com>
X-Mailer: git-send-email 2.21.0.593.g511ec345e18-goog
Subject: [PATCH V2] mm: Allow userland to request that the kernel clear memory
 on release
From: Matthew Garrett <matthewgarrett@google.com>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Matthew Garrett <mjg59@google.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Matthew Garrett <mjg59@google.com>

Applications that hold secrets and wish to avoid them leaking can use
mlock() to prevent the page from being pushed out to swap and
MADV_DONTDUMP to prevent it from being included in core dumps. Applications
can also use atexit() handlers to overwrite secrets on application exit.
However, if an attacker can reboot the system into another OS, they can
dump the contents of RAM and extract secrets. We can avoid this by setting
CONFIG_RESET_ATTACK_MITIGATION on UEFI systems in order to request that the
firmware wipe the contents of RAM before booting another OS, but this means
rebooting takes a *long* time - the expected behaviour is for a clean
shutdown to remove the request after scrubbing secrets from RAM in order to
avoid this.

Unfortunately, if an application exits uncleanly, its secrets may still be
present in RAM. This can't be easily fixed in userland (eg, if the OOM
killer decides to kill a process holding secrets, we're not going to be able
to avoid that), so this patch adds a new flag to madvise() to allow userland
to request that the kernel clear the covered pages whenever the page
reference count hits zero. Since vm_flags is already full on 32-bit, it
will only work on 64-bit systems.

Signed-off-by: Matthew Garrett <mjg59@google.com>
---

Modified to wipe when the VMA is released rather than on page freeing

 include/linux/mm.h                     |  6 ++++++
 include/uapi/asm-generic/mman-common.h |  2 ++
 mm/madvise.c                           | 21 +++++++++++++++++++++
 mm/memory.c                            |  3 +++
 4 files changed, 32 insertions(+)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 6b10c21630f5..64bdab679275 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -257,6 +257,8 @@ extern unsigned int kobjsize(const void *objp);
 #define VM_HIGH_ARCH_2	BIT(VM_HIGH_ARCH_BIT_2)
 #define VM_HIGH_ARCH_3	BIT(VM_HIGH_ARCH_BIT_3)
 #define VM_HIGH_ARCH_4	BIT(VM_HIGH_ARCH_BIT_4)
+
+#define VM_WIPEONRELEASE BIT(37)       /* Clear pages when releasing them */
 #endif /* CONFIG_ARCH_USES_HIGH_VMA_FLAGS */
 
 #ifdef CONFIG_ARCH_HAS_PKEYS
@@ -298,6 +300,10 @@ extern unsigned int kobjsize(const void *objp);
 # define VM_GROWSUP	VM_NONE
 #endif
 
+#ifndef VM_WIPEONRELEASE
+# define VM_WIPEONRELEASE VM_NONE
+#endif
+
 /* Bits set in the VMA until the stack is in its final location */
 #define VM_STACK_INCOMPLETE_SETUP	(VM_RAND_READ | VM_SEQ_READ)
 
diff --git a/include/uapi/asm-generic/mman-common.h b/include/uapi/asm-generic/mman-common.h
index abd238d0f7a4..82dfff4a8e3d 100644
--- a/include/uapi/asm-generic/mman-common.h
+++ b/include/uapi/asm-generic/mman-common.h
@@ -64,6 +64,8 @@
 #define MADV_WIPEONFORK 18		/* Zero memory on fork, child only */
 #define MADV_KEEPONFORK 19		/* Undo MADV_WIPEONFORK */
 
+#define MADV_WIPEONRELEASE 20
+#define MADV_DONTWIPEONRELEASE 21
 /* compatibility flags */
 #define MAP_FILE	0
 
diff --git a/mm/madvise.c b/mm/madvise.c
index 21a7881a2db4..989c2fde15cf 100644
--- a/mm/madvise.c
+++ b/mm/madvise.c
@@ -92,6 +92,22 @@ static long madvise_behavior(struct vm_area_struct *vma,
 	case MADV_KEEPONFORK:
 		new_flags &= ~VM_WIPEONFORK;
 		break;
+	case MADV_WIPEONRELEASE:
+		/* MADV_WIPEONRELEASE is only supported on anonymous memory. */
+		if (VM_WIPEONRELEASE == 0 || vma->vm_file ||
+		    vma->vm_flags & VM_SHARED) {
+			error = -EINVAL;
+			goto out;
+		}
+		new_flags |= VM_WIPEONRELEASE;
+		break;
+	case MADV_DONTWIPEONRELEASE:
+		if (VM_WIPEONRELEASE == 0) {
+			error = -EINVAL;
+			goto out;
+		}
+		new_flags &= ~VM_WIPEONRELEASE;
+		break;
 	case MADV_DONTDUMP:
 		new_flags |= VM_DONTDUMP;
 		break;
@@ -727,6 +743,8 @@ madvise_behavior_valid(int behavior)
 	case MADV_DODUMP:
 	case MADV_WIPEONFORK:
 	case MADV_KEEPONFORK:
+	case MADV_WIPEONRELEASE:
+	case MADV_DONTWIPEONRELEASE:
 #ifdef CONFIG_MEMORY_FAILURE
 	case MADV_SOFT_OFFLINE:
 	case MADV_HWPOISON:
@@ -785,6 +803,9 @@ madvise_behavior_valid(int behavior)
  *  MADV_DONTDUMP - the application wants to prevent pages in the given range
  *		from being included in its core dump.
  *  MADV_DODUMP - cancel MADV_DONTDUMP: no longer exclude from core dump.
+ *  MADV_WIPEONRELEASE - clear the contents of the memory after the last
+ *		reference to it has been released
+ *  MADV_DONTWIPEONRELEASE - cancel MADV_WIPEONRELEASE
  *
  * return values:
  *  zero    - success
diff --git a/mm/memory.c b/mm/memory.c
index ab650c21bccd..ff78b527660e 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1091,6 +1091,9 @@ static unsigned long zap_pte_range(struct mmu_gather *tlb,
 			page_remove_rmap(page, false);
 			if (unlikely(page_mapcount(page) < 0))
 				print_bad_pte(vma, addr, ptent, page);
+			if (unlikely(vma->vm_flags & VM_WIPEONRELEASE) &&
+			    page_mapcount(page) == 0)
+				clear_highpage(page);
 			if (unlikely(__tlb_remove_page(tlb, page))) {
 				force_flush = 1;
 				addr += PAGE_SIZE;
-- 
2.21.0.593.g511ec345e18-goog

