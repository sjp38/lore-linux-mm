Return-Path: <SRS0=L2Uh=RS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT,USER_IN_DEF_DKIM_WL
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0E3F7C43381
	for <linux-mm@archiver.kernel.org>; Fri, 15 Mar 2019 19:52:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B1E032063F
	for <linux-mm@archiver.kernel.org>; Fri, 15 Mar 2019 19:52:14 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="RV+qphgR"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B1E032063F
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 632AB6B02B7; Fri, 15 Mar 2019 15:52:14 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 60ED26B02B8; Fri, 15 Mar 2019 15:52:14 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4F8636B02B9; Fri, 15 Mar 2019 15:52:14 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f71.google.com (mail-io1-f71.google.com [209.85.166.71])
	by kanga.kvack.org (Postfix) with ESMTP id 2AB556B02B7
	for <linux-mm@kvack.org>; Fri, 15 Mar 2019 15:52:14 -0400 (EDT)
Received: by mail-io1-f71.google.com with SMTP id p17so7804791ios.8
        for <linux-mm@kvack.org>; Fri, 15 Mar 2019 12:52:14 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:in-reply-to:message-id
         :mime-version:references:subject:from:to:cc;
        bh=qCZblj86ukutCUgaNEezPPnSo6jFx7c0S/27D3+g5SQ=;
        b=piESSDh+R/WP+h/D0brrqnL3yx5WykDSupILKnFtYVsF0865UfLS4dTUstB7YNgYRC
         vZqtXlvylyH0W5EIXEkhQlWLcettajMqEsDuemeAfcbiWsveb/HDBmEJE1ue4ybz7f4F
         q6thJ7wKzT4veRgNa+cK8iarvMpc46Nr7lHeeIEPp0n9ICRjio6qjTIjLNAeg0ZhXdSx
         Egr/ldiQMLJ1cBxdZfDvU1I4u4zAU4MRanon7V3fWgFls+VkOPC/2fxHzeX5o7CrmlfS
         LLLXtRM/3FbYhq9U6jKv+q+oXseIG4jwfc8t6COi+tkNXVdP6Ep2kP9XvmtMnlcvhPUx
         ddJA==
X-Gm-Message-State: APjAAAVVMTS9biWiCutGm6AH8elTIq6nm1MEYeBAVmJM53dwtoqcqwes
	fPzR6XBDqVupPtojJGBh276GGfmd80EXJzKnv0qc7Y/AiK5Bopu1Vtc+iZuRwWaPF8NrkyIeBiu
	kTU4v4sUoK9HCeIb/RuAHmj68koUw1AlJ7WJ/tR2n5JXTcPTK3vKJ3Xp2SEBhZxzTdg==
X-Received: by 2002:a24:62c2:: with SMTP id d185mr3259622itc.45.1552679533935;
        Fri, 15 Mar 2019 12:52:13 -0700 (PDT)
X-Received: by 2002:a24:62c2:: with SMTP id d185mr3259580itc.45.1552679533045;
        Fri, 15 Mar 2019 12:52:13 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552679533; cv=none;
        d=google.com; s=arc-20160816;
        b=qUa6CRi7k4W8gBVsQ9cT2V5bYFf4OiJ/oyajBVgiuoilu+30VUxG4Bb8v4teG4CX8I
         mqg/jqPCohIRugMS+IKyVjt5ebFtO3jyL/dM0IkwDdu7+hdXIpYHrdSIc4aAn8raWdtf
         8SZcfWWEkOKpYfLr0x3/8ObgDpgsE7MYytCucuT6+48MYD2MopEIvFAsH74wCI3yhPDp
         zhnXNstiPQQtn+9o2JwGMsV4BIskZNLlaEMXl1/mRGVP7/yXYLh5KJVaL9u/brCRlePB
         x6s2GOZs8iBwRj6I17A9ey2Tbvl+caQN6wmZsN3lk36CuUwBdUDUxsjncSCRkD+gan+i
         SGWA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:references:mime-version:message-id:in-reply-to
         :date:dkim-signature;
        bh=qCZblj86ukutCUgaNEezPPnSo6jFx7c0S/27D3+g5SQ=;
        b=huQZlewdsJ0sDCJioQjVSl+HgTRGjUlhjzqRhmgMGpAKIQCwK3eOsXOUWoOf6aFiT0
         lvqhBS1t/rjbJEbeHBugWlSsI4DX+c79nsPZomgMNGWYePQK2xQVNG+wpL5lFHljpoNj
         FGnee6GLey4PXLK77eMx095TBESR3OsusI1ybYWNNhA7df+uzE+0RFOD7o5VT3t/ztCz
         coT1d0pnuZdZdZrwpp++lH/m+qScyj2HBFxox333E8xGvj/PUkPIDcYbYVQ8WWjGN7ek
         DWZx++8gjbpJi7E1h/XKf6ZeOded9v+Ez+J2VERuvV5kgaHN+fuAEichuyZAHORbvXwF
         t7Dw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=RV+qphgR;
       spf=pass (google.com: domain of 3bakmxaokcisp2s6tdz2a0v33v0t.r310x29c-11zaprz.36v@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3bAKMXAoKCIsp2s6tDz2A0v33v0t.r310x29C-11zAprz.36v@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id t17sor5408728itb.14.2019.03.15.12.52.12
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 15 Mar 2019 12:52:13 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3bakmxaokcisp2s6tdz2a0v33v0t.r310x29c-11zaprz.36v@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=RV+qphgR;
       spf=pass (google.com: domain of 3bakmxaokcisp2s6tdz2a0v33v0t.r310x29c-11zaprz.36v@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3bAKMXAoKCIsp2s6tDz2A0v33v0t.r310x29C-11zAprz.36v@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:in-reply-to:message-id:mime-version:references:subject:from:to
         :cc;
        bh=qCZblj86ukutCUgaNEezPPnSo6jFx7c0S/27D3+g5SQ=;
        b=RV+qphgRwIM0BlYxCZg0JlfEjDx5G2b5L8ZyFpBg6xhggSYfsl1Fqr2nkYw/1uo2gs
         3X2mnJn0InykZb95Oc3LklEnd5abQO0mxyfCWv4ktefYvvvkA3igSCrt3kfSvFnDcJd2
         yiTPCyZxoNT8Y3VZrTwxne1jWphT3yMFgfIrreIXZfWc85uza+QqmGRI+KRoFp3SruIJ
         AoO+ZWZNEwD/TFL+4c5NovYe7UTZj9KfYqP4IK256g8ihlekEEHLF6pJB9120lvwCNGI
         YKyN4okwCGSEeBvRd5Hm2UUrZHroN4fPZmCKFLzy7try938Sv18vPjuWwinYuq9JIjNh
         YyTA==
X-Google-Smtp-Source: APXvYqzF9kP75AZrtaf7n0FWkgnfxl6FIrePx6iNETztWTIe/Q/kL5cqZ/6EOdqOX8uD9nyrlgZxURKjMjdTQ+yZ
X-Received: by 2002:a24:508e:: with SMTP id m136mr2945070itb.34.1552679532548;
 Fri, 15 Mar 2019 12:52:12 -0700 (PDT)
Date: Fri, 15 Mar 2019 20:51:33 +0100
In-Reply-To: <cover.1552679409.git.andreyknvl@google.com>
Message-Id: <c4d65de9867cb3349af6800242da0de751260c6c.1552679409.git.andreyknvl@google.com>
Mime-Version: 1.0
References: <cover.1552679409.git.andreyknvl@google.com>
X-Mailer: git-send-email 2.21.0.360.g471c308f928-goog
Subject: [PATCH v11 09/14] kernel, arm64: untag user pointers in prctl_set_mm*
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
	linux-arm-kernel@lists.infradead.org, linux-doc@vger.kernel.org, 
	linux-mm@kvack.org, linux-arch@vger.kernel.org, netdev@vger.kernel.org, 
	bpf@vger.kernel.org, linux-kselftest@vger.kernel.org, 
	linux-kernel@vger.kernel.org
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
lookups, which can only by done with untagged pointers.

Untag user pointers in these functions.

Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
---
 kernel/sys.c | 14 ++++++++++++++
 1 file changed, 14 insertions(+)

diff --git a/kernel/sys.c b/kernel/sys.c
index 12df0e5434b8..8e56d87cc6db 100644
--- a/kernel/sys.c
+++ b/kernel/sys.c
@@ -1993,6 +1993,18 @@ static int prctl_set_mm_map(int opt, const void __user *addr, unsigned long data
 	if (copy_from_user(&prctl_map, addr, sizeof(prctl_map)))
 		return -EFAULT;
 
+	prctl_map->start_code	= untagged_addr(prctl_map.start_code);
+	prctl_map->end_code	= untagged_addr(prctl_map.end_code);
+	prctl_map->start_data	= untagged_addr(prctl_map.start_data);
+	prctl_map->end_data	= untagged_addr(prctl_map.end_data);
+	prctl_map->start_brk	= untagged_addr(prctl_map.start_brk);
+	prctl_map->brk		= untagged_addr(prctl_map.brk);
+	prctl_map->start_stack	= untagged_addr(prctl_map.start_stack);
+	prctl_map->arg_start	= untagged_addr(prctl_map.arg_start);
+	prctl_map->arg_end	= untagged_addr(prctl_map.arg_end);
+	prctl_map->env_start	= untagged_addr(prctl_map.env_start);
+	prctl_map->env_end	= untagged_addr(prctl_map.env_end);
+
 	error = validate_prctl_map(&prctl_map);
 	if (error)
 		return error;
@@ -2106,6 +2118,8 @@ static int prctl_set_mm(int opt, unsigned long addr,
 			      opt != PR_SET_MM_MAP_SIZE)))
 		return -EINVAL;
 
+	addr = untagged_addr(addr);
+
 #ifdef CONFIG_CHECKPOINT_RESTORE
 	if (opt == PR_SET_MM_MAP || opt == PR_SET_MM_MAP_SIZE)
 		return prctl_set_mm_map(opt, (const void __user *)addr, arg4);
-- 
2.21.0.360.g471c308f928-goog

