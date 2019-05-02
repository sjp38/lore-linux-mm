Return-Path: <SRS0=Mdb/=TC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E2097C04AA9
	for <linux-mm@archiver.kernel.org>; Thu,  2 May 2019 12:52:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AB5242085A
	for <linux-mm@archiver.kernel.org>; Thu,  2 May 2019 12:52:19 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AB5242085A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9B0886B0006; Thu,  2 May 2019 08:52:17 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 964296B0007; Thu,  2 May 2019 08:52:17 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8772C6B0008; Thu,  2 May 2019 08:52:17 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 3AD176B0007
	for <linux-mm@kvack.org>; Thu,  2 May 2019 08:52:17 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id f41so1023852ede.1
        for <linux-mm@kvack.org>; Thu, 02 May 2019 05:52:17 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=XPpRmWcxh5/v/JlGBq03jgBpgTH8A8imRmqfZ9DgEaA=;
        b=bPNtkZ40v0+sMU0l9D6z8Zh64Vjy9us3iKi1IAQ8A5pH1s29qys6QDLiMLShu7tLTF
         y2nkp52QaQgsg0Zq/sSN/ECj1eaF3aL2qm5uOIXGzRwvJbtx2TMXCqBEcubNiGmzpSyT
         RJQWwBfvlUNlrUd8o0+ydgzVG55wvEmEwEbD35W6/iOuegtqZsw+UVVFwK6ryuW1ZK12
         mLK+/kR0QdvoLpzugtKtuCH7JB7+b7AYDdpEjILBiOUacLCSqR9vPKP1OE5a9xxqVXaU
         knkGok3X1fCrkXbM6xMPWRECls88dvK4aFJkoFamxbg8QUa9bd7zUZ7LEiG7mn4HOtk1
         4+Dw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mkoutny@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=mkoutny@suse.com
X-Gm-Message-State: APjAAAWWKRQLcClhzVUA78A1+WiAEndVsE6ZwulNSzBzhmQ/Bs/7N2r7
	erWIQ3VPT0FYywjT8r4ZpRKPPRCBYpgrRM+IQOic8xKOkr3GTVT/965V80VN4fnAsH4iYMWdaiP
	xpvxPH4SD0mkZ51KufTMvo4ybmhg8nZ/7GchLxzJdQwfmdvHtkLyJspq+QZg2xDnC3Q==
X-Received: by 2002:a50:9d43:: with SMTP id j3mr1283779edk.59.1556801536740;
        Thu, 02 May 2019 05:52:16 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxAAMOs25fpgjXGmKe/DvZ7j3W/qIVQgwyWFo8yvj6TZGjryyiaycI6VDOhSFrQA5/uvBB4
X-Received: by 2002:a50:9d43:: with SMTP id j3mr1283704edk.59.1556801535223;
        Thu, 02 May 2019 05:52:15 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556801535; cv=none;
        d=google.com; s=arc-20160816;
        b=lneKhw1HEp+2B+qVYWTv8fyF+bYzeT2M4VyJ1GFG/xDgAUE7GYuEeNYLI9HoqA6mWK
         WTYKbkg+ugR7vv7AnddIK1kdpm6Klyd27wswLmETgTwH75gYO6UPA+dW8dVkJuJ6g67d
         TjgFhvILN0/wnW3GI4CGj6Ckd//S2EtBXdpnEIzpHGLIG+xK4cdl+VX78JIxS8Z/+7d5
         4olPjoeLt0jEwoQ7YVq9gadeqaTaRbu5FeXHhTg5++3d1vu1B1OSgIOHFt0Ixf5gLUTO
         RiyyI1fWjlBPcY6Zk6Uwbr47ce1wcUJrEDRIr4YFcq+zdD+3Ea2JNpcp7uaixFrryU5e
         ToIQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=XPpRmWcxh5/v/JlGBq03jgBpgTH8A8imRmqfZ9DgEaA=;
        b=AhbwrPTAWDHDj8gCWLcX4jnrSFd6+4Z4nQ8ohunQmwSqXh0Bz5e+pYM8ULpsipzGBb
         EUx5jKTuZNtxUrFx0tjRBF52aJKEkMoD2KNLmDQi6tKX0cHc2UFWs+WJCxlYq/OClnyk
         G7adKm2pgsf8/sQlXtPuFBu13/i5AwpUT8qB+rmyps6LDjL03N9Q46V4k2gmosQhjDZy
         qpYYMWIjNVmknwIqu9gy55KMb2tUnZdChmMfyQgw4MBgUMV3SzZJcuVuerGPmyIcy5vN
         pCXI2GJW3T8hWSMi59BNcfwCdl1ax9xVdmgjwCTdLKe2QbRC/N3URT8w2jK54QvS3W07
         XUww==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mkoutny@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=mkoutny@suse.com
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e18si1898230edb.143.2019.05.02.05.52.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 02 May 2019 05:52:15 -0700 (PDT)
Received-SPF: pass (google.com: domain of mkoutny@suse.com designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mkoutny@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=mkoutny@suse.com
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id BCDC9AE9D;
	Thu,  2 May 2019 12:52:14 +0000 (UTC)
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
Subject: [PATCH v3 1/2] prctl_set_mm: Refactor checks from validate_prctl_map
Date: Thu,  2 May 2019 14:52:02 +0200
Message-Id: <20190502125203.24014-2-mkoutny@suse.com>
X-Mailer: git-send-email 2.16.4
In-Reply-To: <20190502125203.24014-1-mkoutny@suse.com>
References: <0a48e0a2-a282-159e-a56e-201fbc0faa91@virtuozzo.com>
 <20190502125203.24014-1-mkoutny@suse.com>
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

v1, v2: ---
v3: Remove unused mm variable from validate_prctl_map_addr

CC: Kirill Tkhai <ktkhai@virtuozzo.com>
CC: Cyrill Gorcunov <gorcunov@gmail.com>
Signed-off-by: Michal Koutný <mkoutny@suse.com>
Reviewed-by: Kirill Tkhai <ktkhai@virtuozzo.com>
---
 kernel/sys.c | 46 ++++++++++++++++++++--------------------------
 1 file changed, 20 insertions(+), 26 deletions(-)

diff --git a/kernel/sys.c b/kernel/sys.c
index 12df0e5434b8..5e0a5edf47f8 100644
--- a/kernel/sys.c
+++ b/kernel/sys.c
@@ -1882,13 +1882,14 @@ static int prctl_set_mm_exe_file(struct mm_struct *mm, unsigned int fd)
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
-	struct mm_struct *mm = current->mm;
 	int error = -EINVAL, i;
 
 	static const unsigned char offsets[] = {
@@ -1949,24 +1950,6 @@ static int validate_prctl_map(struct prctl_mm_map *prctl_map)
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
@@ -1993,11 +1976,17 @@ static int prctl_set_mm_map(int opt, const void __user *addr, unsigned long data
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
@@ -2010,6 +1999,14 @@ static int prctl_set_mm_map(int opt, const void __user *addr, unsigned long data
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
@@ -2097,7 +2094,7 @@ static int prctl_set_mm(int opt, unsigned long addr,
 			unsigned long arg4, unsigned long arg5)
 {
 	struct mm_struct *mm = current->mm;
-	struct prctl_mm_map prctl_map;
+	struct prctl_mm_map prctl_map = { .auxv = NULL, .auxv_size = 0, .exe_fd = -1 };
 	struct vm_area_struct *vma;
 	int error;
 
@@ -2139,9 +2136,6 @@ static int prctl_set_mm(int opt, unsigned long addr,
 	prctl_map.arg_end	= mm->arg_end;
 	prctl_map.env_start	= mm->env_start;
 	prctl_map.env_end	= mm->env_end;
-	prctl_map.auxv		= NULL;
-	prctl_map.auxv_size	= 0;
-	prctl_map.exe_fd	= -1;
 
 	switch (opt) {
 	case PR_SET_MM_START_CODE:
@@ -2181,7 +2175,7 @@ static int prctl_set_mm(int opt, unsigned long addr,
 		goto out;
 	}
 
-	error = validate_prctl_map(&prctl_map);
+	error = validate_prctl_map_addr(&prctl_map);
 	if (error)
 		goto out;
 
-- 
2.16.4

