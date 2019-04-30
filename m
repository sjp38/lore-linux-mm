Return-Path: <SRS0=8Dof=TA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C7141C43219
	for <linux-mm@archiver.kernel.org>; Tue, 30 Apr 2019 08:19:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8D3B4216FD
	for <linux-mm@archiver.kernel.org>; Tue, 30 Apr 2019 08:19:33 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8D3B4216FD
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2F0796B000A; Tue, 30 Apr 2019 04:19:33 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 251366B000C; Tue, 30 Apr 2019 04:19:33 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0525B6B000D; Tue, 30 Apr 2019 04:19:33 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id A89FA6B000A
	for <linux-mm@kvack.org>; Tue, 30 Apr 2019 04:19:32 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id m57so6018689edc.7
        for <linux-mm@kvack.org>; Tue, 30 Apr 2019 01:19:32 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=INByUq3lVa3EFEeFkF0GCwcbXF+CEthavbsWjHwZITo=;
        b=jPvI0/vRH4BY7xkKuCHh1CEJ4sfqtb4QnOxhXhhfrE/E6DKzXmMdd277RaJlVg/afY
         9QFuKmAK3QC+Kj42SNYKQKE5THR60FaFGQ8CR39I658uuMfF+K/dDixhdyNCIgpVFjhy
         y5CjDa8Ueu0YuhrUlj9U7nYA7Uy78EfctWF/51Fazc6MrJoHEz0uHudcpyxjBG6mfCgg
         /qtBiEcDBlFVfQCLNTjBOSHXsoxF7CMNq87xvCMsDYhiKQi38kE+ayQxcDiygbylXZL2
         vlVLyCv1Ygrt8/4jbXTo/sl8+OtH5D6W1RnS2WJ/OWj1jW7mANT0ucT1HRsEvqKTb1jA
         9JDw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mkoutny@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=mkoutny@suse.com
X-Gm-Message-State: APjAAAUMi+fxckhYgmkwHr3lcZC82Q72Sk47e72R/fapEqozVrF6fxgj
	51dQNu61w1q/WFTc75v1Cwlm/PG+v5Gp5nlbt8EDQ/LoAM46rv6QqZlUyiddlIwFyZZbiBkuqAR
	c3X1V1l1IyIDZQTLP3EdbTMTbipJsXbtMUfY1lIXeStEcYF61kbQHn8g9Oqpx0N5oaw==
X-Received: by 2002:a17:906:4988:: with SMTP id p8mr6562564eju.220.1556612372148;
        Tue, 30 Apr 2019 01:19:32 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyQH4iozUr1MfRRGqxJv8FWF50u1G6R5YGQjPveu/5UcnmOFKMV1bG/Zu00ZF53/cRNiKMP
X-Received: by 2002:a17:906:4988:: with SMTP id p8mr6562521eju.220.1556612370601;
        Tue, 30 Apr 2019 01:19:30 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556612370; cv=none;
        d=google.com; s=arc-20160816;
        b=RVOzcqqrspetmahYLNy3/DMtBLJAikKNNcnaHqqMjWVPj+1kw9Gh701cn7LyDB5UDr
         aHF4dum0KA/3wSyypqcArkExE6hxGuHL3Ghh86e+57TrjNLVT0eeDk3dFrUkQNNDi8Dv
         MOTZ/o5l0q+fCR53VsEROyzQspeNmADEjSNI+wmVL4v8ksfwUGAexdEzdheI47niLY/5
         g8c57qY497bMf2nQPFuaGoRXnzz0o55mM5Z7CJU3FDc89B/LK/5x7hYq6eVDO0ePu/Qr
         5wOTsoYpEXNsysAwq6NCLAXwEuvTmI1TLs3LJ5G7E6Q2ia5Ccm/sGbhYbC7Ujojdd2uP
         wVrg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=INByUq3lVa3EFEeFkF0GCwcbXF+CEthavbsWjHwZITo=;
        b=LPYhq8PkKnyzU924fycFbhuxFZIaOyyym5J2oCvFz2ndk+FNsnwvpiBtyt3Qhz+mRI
         gAmmpZ8uYI3TlcgKjyEb4j974zPno4RsCAhwMKaHC6mqDdKjAeHpPnaqs84xrJHuf/12
         xxhzIr79beYZlgN8sKZZljsxo/Ll/RHY9QjHYF0V+g5DKTawgJlUxo6Nk9nIzp0ylw08
         JI0hJPO0y7G7b3us6Uons2FbhbCNM+kSl3g0qBxEg+fRXHyngkeWAn/uBKUAr3wb4Bqd
         zgGjhsb1/ZW6jOznLv9eoDiPY5AKSd2b3R1eEvdO3gnUtXTQ9GvsLtEl7N64h7I45L0o
         rNQQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mkoutny@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=mkoutny@suse.com
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y55si3555460edc.206.2019.04.30.01.19.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 30 Apr 2019 01:19:30 -0700 (PDT)
Received-SPF: pass (google.com: domain of mkoutny@suse.com designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mkoutny@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=mkoutny@suse.com
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 19136AE3F;
	Tue, 30 Apr 2019 08:19:30 +0000 (UTC)
From: =?UTF-8?q?Michal=20Koutn=C3=BD?= <mkoutny@suse.com>
To: gorcunov@gmail.com
Cc: akpm@linux-foundation.org,
	arunks@codeaurora.org,
	brgl@bgdev.pl,
	geert+renesas@glider.be,
	ldufour@linux.ibm.com,
	linux-kernel@vger.kernel.org,
	linux-mm@kvack.org,
	mguzik@redhat.com,
	mhocko@kernel.org,
	mkoutny@suse.com,
	rppt@linux.ibm.com,
	vbabka@suse.cz,
	ktkhai@virtuozzo.com
Subject: [PATCH 2/3] prctl_set_mm: Refactor checks from validate_prctl_map
Date: Tue, 30 Apr 2019 10:18:43 +0200
Message-Id: <20190430081844.22597-3-mkoutny@suse.com>
X-Mailer: git-send-email 2.16.4
In-Reply-To: <20190430081844.22597-1-mkoutny@suse.com>
References: <20190418182321.GJ3040@uranus.lan>
 <20190430081844.22597-1-mkoutny@suse.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Despite comment of validate_prctl_map claims there are no capability
checks, it is not completely true since commit 4d28df6152aa ("prctl:
Allow local CAP_SYS_ADMIN changing exe_file"). Extract the check out of
the function and make the function perform purely arithmetic checks.

This patch should not change any behavior, it is mere refactoring for
following patch.

CC: Kirill Tkhai <ktkhai@virtuozzo.com>
CC: Cyrill Gorcunov <gorcunov@gmail.com>
Signed-off-by: Michal Koutný <mkoutny@suse.com>
---
 kernel/sys.c | 45 ++++++++++++++++++++-------------------------
 1 file changed, 20 insertions(+), 25 deletions(-)

diff --git a/kernel/sys.c b/kernel/sys.c
index 12df0e5434b8..e1acb444d7b0 100644
--- a/kernel/sys.c
+++ b/kernel/sys.c
@@ -1882,10 +1882,12 @@ static int prctl_set_mm_exe_file(struct mm_struct *mm, unsigned int fd)
 }
 
 /*
+ * Check arithmetic relations of passed addresses.
+ *
  * WARNING: we don't require any capability here so be very careful
  * in what is allowed for modification from userspace.
  */
-static int validate_prctl_map(struct prctl_mm_map *prctl_map)
+static int validate_prctl_map_addr(struct prctl_mm_map *prctl_map)
 {
 	unsigned long mmap_max_addr = TASK_SIZE;
 	struct mm_struct *mm = current->mm;
@@ -1949,24 +1951,6 @@ static int validate_prctl_map(struct prctl_mm_map *prctl_map)
 			      prctl_map->start_data))
 			goto out;
 
-	/*
-	 * Someone is trying to cheat the auxv vector.
-	 */
-	if (prctl_map->auxv_size) {
-		if (!prctl_map->auxv || prctl_map->auxv_size > sizeof(mm->saved_auxv))
-			goto out;
-	}
-
-	/*
-	 * Finally, make sure the caller has the rights to
-	 * change /proc/pid/exe link: only local sys admin should
-	 * be allowed to.
-	 */
-	if (prctl_map->exe_fd != (u32)-1) {
-		if (!ns_capable(current_user_ns(), CAP_SYS_ADMIN))
-			goto out;
-	}
-
 	error = 0;
 out:
 	return error;
@@ -1993,11 +1977,17 @@ static int prctl_set_mm_map(int opt, const void __user *addr, unsigned long data
 	if (copy_from_user(&prctl_map, addr, sizeof(prctl_map)))
 		return -EFAULT;
 
-	error = validate_prctl_map(&prctl_map);
+	error = validate_prctl_map_addr(&prctl_map);
 	if (error)
 		return error;
 
 	if (prctl_map.auxv_size) {
+		/*
+		 * Someone is trying to cheat the auxv vector.
+		 */
+		if (!prctl_map.auxv || prctl_map.auxv_size > sizeof(mm->saved_auxv))
+			return -EINVAL;
+
 		memset(user_auxv, 0, sizeof(user_auxv));
 		if (copy_from_user(user_auxv,
 				   (const void __user *)prctl_map.auxv,
@@ -2010,6 +2000,14 @@ static int prctl_set_mm_map(int opt, const void __user *addr, unsigned long data
 	}
 
 	if (prctl_map.exe_fd != (u32)-1) {
+		/*
+		 * Make sure the caller has the rights to
+		 * change /proc/pid/exe link: only local sys admin should
+		 * be allowed to.
+		 */
+		if (!ns_capable(current_user_ns(), CAP_SYS_ADMIN))
+			return -EINVAL;
+
 		error = prctl_set_mm_exe_file(mm, prctl_map.exe_fd);
 		if (error)
 			return error;
@@ -2097,7 +2095,7 @@ static int prctl_set_mm(int opt, unsigned long addr,
 			unsigned long arg4, unsigned long arg5)
 {
 	struct mm_struct *mm = current->mm;
-	struct prctl_mm_map prctl_map;
+	struct prctl_mm_map prctl_map = { .auxv = NULL, .auxv_size = 0, .exe_fd = -1 };
 	struct vm_area_struct *vma;
 	int error;
 
@@ -2139,9 +2137,6 @@ static int prctl_set_mm(int opt, unsigned long addr,
 	prctl_map.arg_end	= mm->arg_end;
 	prctl_map.env_start	= mm->env_start;
 	prctl_map.env_end	= mm->env_end;
-	prctl_map.auxv		= NULL;
-	prctl_map.auxv_size	= 0;
-	prctl_map.exe_fd	= -1;
 
 	switch (opt) {
 	case PR_SET_MM_START_CODE:
@@ -2181,7 +2176,7 @@ static int prctl_set_mm(int opt, unsigned long addr,
 		goto out;
 	}
 
-	error = validate_prctl_map(&prctl_map);
+	error = validate_prctl_map_addr(&prctl_map);
 	if (error)
 		goto out;
 
-- 
2.16.4

