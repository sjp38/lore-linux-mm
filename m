Return-Path: <SRS0=Ax9E=UL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D01EAC31E46
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 14:28:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A35502082C
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 14:28:29 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A35502082C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3AD406B0010; Wed, 12 Jun 2019 10:28:29 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 35E1C6B0266; Wed, 12 Jun 2019 10:28:29 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 273BA6B0269; Wed, 12 Jun 2019 10:28:29 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id CE6546B0010
	for <linux-mm@kvack.org>; Wed, 12 Jun 2019 10:28:28 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id b12so18854939eds.14
        for <linux-mm@kvack.org>; Wed, 12 Jun 2019 07:28:28 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version:content-transfer-encoding;
        bh=wMikMlBNKS1Ut1DebH98gB1mwWJIVawaIVnza7rvA2U=;
        b=JGceTmTYn/iAWySV4s2aIroeucILd3+IW2jRXZogMcS4r6JkoARxHqV7mQN0cfR5ex
         I4+DadrjG51ANjUxdr7DgwxE2tAOBS/xsYihnmoKYyXR+6XorBTKKa3j3ijF3ZSsO8k5
         c+Kdv96QqQ0f9gbHLhBHmH67N4yY8g/3yUQFC53M5ABQmxI/0/eWZcP92hMGaAY7q9la
         5tRW/fU45Mdrlu1Jf90e7lWTI9SFGbygfNieXN2ckvzgk3izU+LsX9UxHVTZSw0f/0vr
         E2bNMjSPBKjWEEuBsbsjgGujBBxg3WlgO+ofDcqO7kfMbMSJTO0b5MhqEmqHz7B4iEpx
         YqfA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mkoutny@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=mkoutny@suse.com
X-Gm-Message-State: APjAAAVyKdH3GQOK7iFNLHmU8o/RCQuplQv4YguieBblk2Pp4iE+fovk
	pjFJJ0VNIbC/tyZZ0Uv3aXGcy4j0z81VdnumjFyv8QQ7y3OLCP3jz/WvD9decuRrRWqWn6ckuwh
	vqpzV7uGWS9rbINELaxjk+d9tGZA2Lq+ghZD4Cv4TLdXztnR7+mTBwjYm1krOef5qRg==
X-Received: by 2002:aa7:c559:: with SMTP id s25mr16134363edr.117.1560349708280;
        Wed, 12 Jun 2019 07:28:28 -0700 (PDT)
X-Google-Smtp-Source: APXvYqygaCnnet5CU+8fzssJZg4GSubH15ng1QdRISIFvXP3Z7azBY4SdujsqdpmQGbx3FEzLGKz
X-Received: by 2002:aa7:c559:: with SMTP id s25mr16134243edr.117.1560349706980;
        Wed, 12 Jun 2019 07:28:26 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560349706; cv=none;
        d=google.com; s=arc-20160816;
        b=Xu8rItsO44VkSIn3IAYwcitmOrVw/GGoonzIT9MMR7x0XZrt0NT8ct3E6A5Qcd5ezn
         aw6zIrQYTxKdb2olBuCRTMx33DoS1B+Rb/ytvWtedKxeHeEGZXiaWMR5OW63dG8cStSS
         1Gn5d1m8mj4dxHDveSR53KHYcuhe7DTSLaF8miqwYfvImAt79Wc20cHf6UyMG5jaZjP7
         JS5RP3Xiy4kqGeP/DTp5m5oP/s+u3dv6iZV159RMro7nj4ibt8LWyx2Uv/IDz8T4GiIl
         q/N53geYMZxMqLGnvUFj9XlaVi6VkUhvp82iy3UEXSE+p6xy/4Tl2VU/0Es2/f5SdLGM
         rgZQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from;
        bh=wMikMlBNKS1Ut1DebH98gB1mwWJIVawaIVnza7rvA2U=;
        b=jeMgJOIISc0F25GlfykVxkHEUgRXgQkSoodO6H13pQB11RL17cdiXNfC4jed32AuAh
         atHA5PPeieLHprvSmjIYjv2McedDdBzKhBCTz+qRfA45+/AEV3S8409x5ryLrai5E9Mm
         vJc3yJjZ+OqQA/RjmLK/qurwzA7D8YNNSZ/M20O5TtjR0RTwdVlAaAkc9tC/EGVwcd0W
         K+dQm/TTXmbIAXRloqLVGNTHJmbO/6oj+7dwbl7S80JMuLBYjt2brQNscXcxvoruEZL9
         FMAAruD/f0WvSHsst/FQK3K0Mwv4ofGgVW9u5WT5JxBHWjynds74wu/60dzrnx2htZzT
         QtnA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mkoutny@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=mkoutny@suse.com
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f54si3326431edb.311.2019.06.12.07.28.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Jun 2019 07:28:26 -0700 (PDT)
Received-SPF: pass (google.com: domain of mkoutny@suse.com designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mkoutny@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=mkoutny@suse.com
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 4D542B026;
	Wed, 12 Jun 2019 14:28:26 +0000 (UTC)
From: =?UTF-8?q?Michal=20Koutn=C3=BD?= <mkoutny@suse.com>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org,
	gorcunov@gmail.com,
	Laurent Dufour <ldufour@linux.ibm.com>,
	Kirill Tkhai <ktkhai@virtuozzo.com>
Subject: [RFC PATCH] binfmt_elf: Protect mm_struct access with mmap_sem
Date: Wed, 12 Jun 2019 16:28:11 +0200
Message-Id: <20190612142811.24894-1-mkoutny@suse.com>
X-Mailer: git-send-email 2.21.0
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

find_extend_vma assumes the caller holds mmap_sem as a reader (explained
in expand_downwards()). The path when we are extending the stack VMA to
accomodate argv[] pointers happens without the lock.

I was not able to cause an mm_struct corruption but
BUG_ON(!rwsem_is_locked(&mm->mmap_sem)) in find_extend_vma could be
triggered as

    # <bigfile xargs echo
    xargs: echo: terminated by signal 11

(bigfile needs to have more than RLIMIT_STACK / sizeof(char *) rows)

Other accesses to mm_struct in exec path are protected by mmap_sem, so
conservatively, protect also this one. Besides that, explain why we omit
mm_struct.arg_lock in the exec(2) path.

Cc: Cyrill Gorcunov <gorcunov@gmail.com>
Signed-off-by: Michal Koutný <mkoutny@suse.com>
---

When I was attempting to reduce usage of mmap_sem I came across this
unprotected access and increased number of its holders :-/

I'm not sure whether there is a real concurrent writer at this early
stages (I considered khugepaged especially as setup_arg_pages invokes
khugepaged_enter_vma_merge but we're lucky because khugepaged skips it
because of VM_STACK_INCOMPLETE_SETUP).

A nicer approach would perhaps be to do all this exec setup when the
mm_struct is still not exposed via current->mm (and hence no need to
synchronize via mmap_sem). But I didn't look enough into binfmt specific
whether it is even doable and worth it.

So I'm sending this for a discussion.

 fs/binfmt_elf.c | 10 +++++++++-
 fs/exec.c       |  3 ++-
 2 files changed, 11 insertions(+), 2 deletions(-)

diff --git a/fs/binfmt_elf.c b/fs/binfmt_elf.c
index 8264b468f283..48e169760a9c 100644
--- a/fs/binfmt_elf.c
+++ b/fs/binfmt_elf.c
@@ -299,7 +299,11 @@ create_elf_tables(struct linux_binprm *bprm, struct elfhdr *exec,
 	 * Grow the stack manually; some architectures have a limit on how
 	 * far ahead a user-space access may be in order to grow the stack.
 	 */
+	if (down_read_killable(&current->mm->mmap_sem))
+		return -EINTR;
 	vma = find_extend_vma(current->mm, bprm->p);
+	up_read(&current->mm->mmap_sem);
+
 	if (!vma)
 		return -EFAULT;
 
@@ -1123,11 +1127,15 @@ static int load_elf_binary(struct linux_binprm *bprm)
 		goto out;
 #endif /* ARCH_HAS_SETUP_ADDITIONAL_PAGES */
 
+	/*
+	 * Don't take mm->arg_lock. The concurrent change might happen only
+	 * from prctl_set_mm but after de_thread we are certainly alone here.
+	 */
 	retval = create_elf_tables(bprm, &loc->elf_ex,
 			  load_addr, interp_load_addr);
 	if (retval < 0)
 		goto out;
-	/* N.B. passed_fileno might not be initialized? */
+
 	current->mm->end_code = end_code;
 	current->mm->start_code = start_code;
 	current->mm->start_data = start_data;
diff --git a/fs/exec.c b/fs/exec.c
index 89a500bb897a..d5b55c92019a 100644
--- a/fs/exec.c
+++ b/fs/exec.c
@@ -212,7 +212,8 @@ static struct page *get_arg_page(struct linux_binprm *bprm, unsigned long pos,
 
 	/*
 	 * We are doing an exec().  'current' is the process
-	 * doing the exec and bprm->mm is the new process's mm.
+	 * doing the exec and bprm->mm is the new process's mm that is not
+	 * shared yet, so no synchronization on mmap_sem.
 	 */
 	ret = get_user_pages_remote(current, bprm->mm, pos, 1, gup_flags,
 			&page, NULL, NULL);
-- 
2.21.0

