Return-Path: <SRS0=h9qD=RX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT,USER_IN_DEF_DKIM_WL
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3267DC43381
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 14:52:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CA57F2146E
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 14:52:19 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="Cf79xB1h"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CA57F2146E
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 75C6F6B0269; Wed, 20 Mar 2019 10:52:19 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 70C566B026A; Wed, 20 Mar 2019 10:52:19 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5D5796B026B; Wed, 20 Mar 2019 10:52:19 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 1D32A6B0269
	for <linux-mm@kvack.org>; Wed, 20 Mar 2019 10:52:19 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id 73so2895012pga.18
        for <linux-mm@kvack.org>; Wed, 20 Mar 2019 07:52:19 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:in-reply-to:message-id
         :mime-version:references:subject:from:to:cc;
        bh=MbZWy7wAoKF2UH6KYiAHojRGCKZALRbT18PDS+70hHM=;
        b=o4uJMTyrXdjmRI+DUXDPy4Lfq5DXVEsRGj4rk5KX7u5uCrcEzh++cHNhkTmoLlvz4i
         63pnm2yenQXr3bi1QsJU8l+EMv3c/P++dt57693OGQBrdtTIAQo3Uvp+1NATmJyMacAx
         ZEdJvdCpxqxT67Kl3VpfrqUam5dMbaen6H8BfF7hr6ds7vrk1j3mGYUNd3rE605TkvBb
         Hdpz3IwpACjxQn7+2T/gVdpKz31a3WfSDHScn+IXEu2eio8RLMG76Eqk+BHa7zUONAMu
         dntHuXrXSahWYbsB2Ly4M3FcmGiCDKjSl5K11tpDIDKTazEBehGc8Bez7GN1mmmNc7zj
         fp0A==
X-Gm-Message-State: APjAAAWnIYMXOx96JOdCOmj/al3tzVzXGHKvv5sHsW0BUKX08o1qLVxn
	x36NprgbdCPEMHlmnGvK6GR138ZaCa1dnDGHTqd1rx6flepL/EdaHM9IJiJDWojfp/PlFyKNusy
	pMoBzF39YndWSiYmnte68toWWaikd7lvwo7EH34kCURJg2uGxa2jMmEGShiShevr5wA==
X-Received: by 2002:a17:902:f089:: with SMTP id go9mr8628612plb.335.1553093538626;
        Wed, 20 Mar 2019 07:52:18 -0700 (PDT)
X-Received: by 2002:a17:902:f089:: with SMTP id go9mr8628512plb.335.1553093537363;
        Wed, 20 Mar 2019 07:52:17 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553093537; cv=none;
        d=google.com; s=arc-20160816;
        b=N8tP7LE/bvSPDKmTGFBMS9Fx2T7uTHXvgckdrFGAl/Bz56qvGEwPSlhLluDoSAFyzL
         a98x+Il9g8VldVKz9fCMlo081gaWmyY5PgPs8aCEnqyBCMADVYZbon6AvZ6zgM3dRfhF
         j0Li/PnU8pkTLhU98BWCviZn420pgiWQKeLL4B2bEss1W2+SNRmTGBNSoMAaJniUWOHw
         5sQJ2JgWSC+XsoBT1Zprwamt3onfDe9OgYMdpOcD4tiZXJtciBbtDT8j1421aQu6wPzm
         noJnhBjWpwOLT0iYCjn3Q1lU5XTtr8NMpWRHvLC7vndllWDEieJgz697ftviJzzqxuQe
         hRXQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:references:mime-version:message-id:in-reply-to
         :date:dkim-signature;
        bh=MbZWy7wAoKF2UH6KYiAHojRGCKZALRbT18PDS+70hHM=;
        b=KyMVaof4Mfu7g/6JByWaYnmDVgBiOSRJx8D2+LI1qjTxjqmdiDPLIHmy5jxxVNaoDg
         JTJxWz1yaqlBtzH/6lnnmyXfM0QgYqOAaogyX9IQMY5IAlFGHCi/AsuYfYD9Y1+mnuhr
         d/xhap7bXltKvYl5LB5C/FUT52b61eOQPAzXTUIPxDvclom2oLNw/LDAJBj1jBC+5tRf
         QEfILPEWYDRsASTFh63tJT7pB5HQ+RXEg8qnMpxFFXFpkXAk4bjMXHo+Ccf1+eRyaYfj
         3H/d1QJRrJxhiPI1wrJZ41aRUDMZ0NvD0g1YNUsrMvsFRtoqBbZbVvr5B+eWw/vFxwkR
         KLkQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=Cf79xB1h;
       spf=pass (google.com: domain of 3ofosxaokchszmcqdxjmukfnnfkd.bnlkhmtw-lljuzbj.nqf@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3oFOSXAoKCHsZmcqdxjmukfnnfkd.bnlkhmtw-lljuZbj.nqf@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id 31sor3283796plz.49.2019.03.20.07.52.17
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 20 Mar 2019 07:52:17 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3ofosxaokchszmcqdxjmukfnnfkd.bnlkhmtw-lljuzbj.nqf@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=Cf79xB1h;
       spf=pass (google.com: domain of 3ofosxaokchszmcqdxjmukfnnfkd.bnlkhmtw-lljuzbj.nqf@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3oFOSXAoKCHsZmcqdxjmukfnnfkd.bnlkhmtw-lljuZbj.nqf@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:in-reply-to:message-id:mime-version:references:subject:from:to
         :cc;
        bh=MbZWy7wAoKF2UH6KYiAHojRGCKZALRbT18PDS+70hHM=;
        b=Cf79xB1hEehdzh5EdQvB0DqUp1Hi1Ba1ZG4ykqAk40DB3x+eMaWrm7sWIWkJNEquhF
         FVl7gQufjFvFNgmRChNl29sEoSXbZbjX50ZfmHbUgFVy9BBOQ2P3XPdFp0ynrrY/k/AF
         9Fd3AuSLRwBOeiZN2kGSzlynrJ1LxfGiyFJDOhBAZfJzEpG1mNR/DpTDh/D1EJ1W8GgH
         +Vi7IZFmuQSS2kMFc24VaCjHt3uoL+I60vu4Q4CcdKyTLJqv4dM27wQE05rs7AvBrWNo
         08k+krkdHzvBR07nst5bOr1EUNXB/0pbWIkNdS5RSvc7RMdINRBsuOOZ4LD8cqB0GLIB
         KXBA==
X-Google-Smtp-Source: APXvYqxkHmitS8lxUpT4EOuZJCwERqSRPkPPirufF7mQse0PfJCN+CPgkz0bcAlc7DH+nCKwSTfgmoSYbxlj2eug
X-Received: by 2002:a17:902:f30e:: with SMTP id gb14mr3654364plb.16.1553093536799;
 Wed, 20 Mar 2019 07:52:16 -0700 (PDT)
Date: Wed, 20 Mar 2019 15:51:24 +0100
In-Reply-To: <cover.1553093420.git.andreyknvl@google.com>
Message-Id: <76f96eb9162b3a7fa5949d71af38bf8fdf6924c4.1553093421.git.andreyknvl@google.com>
Mime-Version: 1.0
References: <cover.1553093420.git.andreyknvl@google.com>
X-Mailer: git-send-email 2.21.0.225.g810b269d1ac-goog
Subject: [PATCH v13 10/20] kernel, arm64: untag user pointers in prctl_set_mm*
From: Andrey Konovalov <andreyknvl@google.com>
To: Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, 
	Mark Rutland <mark.rutland@arm.com>, Robin Murphy <robin.murphy@arm.com>, 
	Kees Cook <keescook@chromium.org>, Kate Stewart <kstewart@linuxfoundation.org>, 
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, 
	Ingo Molnar <mingo@kernel.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, 
	Shuah Khan <shuah@kernel.org>, Vincenzo Frascino <vincenzo.frascino@arm.com>, 
	Eric Dumazet <edumazet@google.com>, "David S. Miller" <davem@davemloft.net>, 
	Alexei Starovoitov <ast@kernel.org>, Daniel Borkmann <daniel@iogearbox.net>, 
	Steven Rostedt <rostedt@goodmis.org>, Ingo Molnar <mingo@redhat.com>, 
	Peter Zijlstra <peterz@infradead.org>, Arnaldo Carvalho de Melo <acme@kernel.org>, 
	Alex Deucher <alexander.deucher@amd.com>, 
	"=?UTF-8?q?Christian=20K=C3=B6nig?=" <christian.koenig@amd.com>, "David (ChunMing) Zhou" <David1.Zhou@amd.com>, 
	Yishai Hadas <yishaih@mellanox.com>, Mauro Carvalho Chehab <mchehab@kernel.org>, 
	Jens Wiklander <jens.wiklander@linaro.org>, Alex Williamson <alex.williamson@redhat.com>, 
	linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, 
	linux-arch@vger.kernel.org, netdev@vger.kernel.org, bpf@vger.kernel.org, 
	amd-gfx@lists.freedesktop.org, dri-devel@lists.freedesktop.org, 
	linux-rdma@vger.kernel.org, linux-media@vger.kernel.org, kvm@vger.kernel.org, 
	linux-kselftest@vger.kernel.org, linux-kernel@vger.kernel.org
Cc: Dmitry Vyukov <dvyukov@google.com>, Kostya Serebryany <kcc@google.com>, 
	Evgeniy Stepanov <eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>, 
	Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Jacob Bramley <Jacob.Bramley@arm.com>, 
	Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Chintan Pandya <cpandya@codeaurora.org>, 
	Luc Van Oostenryck <luc.vanoostenryck@gmail.com>, Dave Martin <Dave.Martin@arm.com>, 
	Kevin Brodsky <kevin.brodsky@arm.com>, Szabolcs Nagy <Szabolcs.Nagy@arm.com>, 
	Andrey Konovalov <andreyknvl@google.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This patch is a part of a series that extends arm64 kernel ABI to allow to
pass tagged user pointers (with the top byte set to something else other
than 0x00) as syscall arguments.

prctl_set_mm() and prctl_set_mm_map() use provided user pointers for vma
lookups and do some pointer comparisons to perform validation, which can
only by done with untagged pointers.

Untag user pointers in these functions for vma lookup and validity checks.

Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
---
 kernel/sys.c | 44 ++++++++++++++++++++++++++++++--------------
 1 file changed, 30 insertions(+), 14 deletions(-)

diff --git a/kernel/sys.c b/kernel/sys.c
index 12df0e5434b8..fe26ccf3c9e6 100644
--- a/kernel/sys.c
+++ b/kernel/sys.c
@@ -1885,11 +1885,12 @@ static int prctl_set_mm_exe_file(struct mm_struct *mm, unsigned int fd)
  * WARNING: we don't require any capability here so be very careful
  * in what is allowed for modification from userspace.
  */
-static int validate_prctl_map(struct prctl_mm_map *prctl_map)
+static int validate_prctl_map(struct prctl_mm_map *tagged_prctl_map)
 {
 	unsigned long mmap_max_addr = TASK_SIZE;
 	struct mm_struct *mm = current->mm;
 	int error = -EINVAL, i;
+	struct prctl_mm_map prctl_map;
 
 	static const unsigned char offsets[] = {
 		offsetof(struct prctl_mm_map, start_code),
@@ -1905,12 +1906,25 @@ static int validate_prctl_map(struct prctl_mm_map *prctl_map)
 		offsetof(struct prctl_mm_map, env_end),
 	};
 
+	memcpy(&prctl_map, tagged_prctl_map, sizeof(prctl_map));
+	prctl_map.start_code	= untagged_addr(prctl_map.start_code);
+	prctl_map.end_code	= untagged_addr(prctl_map.end_code);
+	prctl_map.start_data	= untagged_addr(prctl_map.start_data);
+	prctl_map.end_data	= untagged_addr(prctl_map.end_data);
+	prctl_map.start_brk	= untagged_addr(prctl_map.start_brk);
+	prctl_map.brk		= untagged_addr(prctl_map.brk);
+	prctl_map.start_stack	= untagged_addr(prctl_map.start_stack);
+	prctl_map.arg_start	= untagged_addr(prctl_map.arg_start);
+	prctl_map.arg_end	= untagged_addr(prctl_map.arg_end);
+	prctl_map.env_start	= untagged_addr(prctl_map.env_start);
+	prctl_map.env_end	= untagged_addr(prctl_map.env_end);
+
 	/*
 	 * Make sure the members are not somewhere outside
 	 * of allowed address space.
 	 */
 	for (i = 0; i < ARRAY_SIZE(offsets); i++) {
-		u64 val = *(u64 *)((char *)prctl_map + offsets[i]);
+		u64 val = *(u64 *)((char *)&prctl_map + offsets[i]);
 
 		if ((unsigned long)val >= mmap_max_addr ||
 		    (unsigned long)val < mmap_min_addr)
@@ -1921,8 +1935,8 @@ static int validate_prctl_map(struct prctl_mm_map *prctl_map)
 	 * Make sure the pairs are ordered.
 	 */
 #define __prctl_check_order(__m1, __op, __m2)				\
-	((unsigned long)prctl_map->__m1 __op				\
-	 (unsigned long)prctl_map->__m2) ? 0 : -EINVAL
+	((unsigned long)prctl_map.__m1 __op				\
+	 (unsigned long)prctl_map.__m2) ? 0 : -EINVAL
 	error  = __prctl_check_order(start_code, <, end_code);
 	error |= __prctl_check_order(start_data, <, end_data);
 	error |= __prctl_check_order(start_brk, <=, brk);
@@ -1937,23 +1951,24 @@ static int validate_prctl_map(struct prctl_mm_map *prctl_map)
 	/*
 	 * @brk should be after @end_data in traditional maps.
 	 */
-	if (prctl_map->start_brk <= prctl_map->end_data ||
-	    prctl_map->brk <= prctl_map->end_data)
+	if (prctl_map.start_brk <= prctl_map.end_data ||
+	    prctl_map.brk <= prctl_map.end_data)
 		goto out;
 
 	/*
 	 * Neither we should allow to override limits if they set.
 	 */
-	if (check_data_rlimit(rlimit(RLIMIT_DATA), prctl_map->brk,
-			      prctl_map->start_brk, prctl_map->end_data,
-			      prctl_map->start_data))
+	if (check_data_rlimit(rlimit(RLIMIT_DATA), prctl_map.brk,
+			      prctl_map.start_brk, prctl_map.end_data,
+			      prctl_map.start_data))
 			goto out;
 
 	/*
 	 * Someone is trying to cheat the auxv vector.
 	 */
-	if (prctl_map->auxv_size) {
-		if (!prctl_map->auxv || prctl_map->auxv_size > sizeof(mm->saved_auxv))
+	if (prctl_map.auxv_size) {
+		if (!prctl_map.auxv || prctl_map.auxv_size >
+						sizeof(mm->saved_auxv))
 			goto out;
 	}
 
@@ -1962,7 +1977,7 @@ static int validate_prctl_map(struct prctl_mm_map *prctl_map)
 	 * change /proc/pid/exe link: only local sys admin should
 	 * be allowed to.
 	 */
-	if (prctl_map->exe_fd != (u32)-1) {
+	if (prctl_map.exe_fd != (u32)-1) {
 		if (!ns_capable(current_user_ns(), CAP_SYS_ADMIN))
 			goto out;
 	}
@@ -2120,13 +2135,14 @@ static int prctl_set_mm(int opt, unsigned long addr,
 	if (opt == PR_SET_MM_AUXV)
 		return prctl_set_auxv(mm, addr, arg4);
 
-	if (addr >= TASK_SIZE || addr < mmap_min_addr)
+	if (untagged_addr(addr) >= TASK_SIZE ||
+			untagged_addr(addr) < mmap_min_addr)
 		return -EINVAL;
 
 	error = -EINVAL;
 
 	down_write(&mm->mmap_sem);
-	vma = find_vma(mm, addr);
+	vma = find_vma(mm, untagged_addr(addr));
 
 	prctl_map.start_code	= mm->start_code;
 	prctl_map.end_code	= mm->end_code;
-- 
2.21.0.225.g810b269d1ac-goog

