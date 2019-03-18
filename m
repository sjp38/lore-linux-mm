Return-Path: <SRS0=xdO8=RV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT,USER_IN_DEF_DKIM_WL
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 94F35C4360F
	for <linux-mm@archiver.kernel.org>; Mon, 18 Mar 2019 17:18:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 478332175B
	for <linux-mm@archiver.kernel.org>; Mon, 18 Mar 2019 17:18:12 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="ZmesG1+v"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 478332175B
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B91896B000D; Mon, 18 Mar 2019 13:18:08 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B45476B000E; Mon, 18 Mar 2019 13:18:08 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A09C96B0010; Mon, 18 Mar 2019 13:18:08 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 8389D6B000D
	for <linux-mm@kvack.org>; Mon, 18 Mar 2019 13:18:08 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id x18so15139082qkf.8
        for <linux-mm@kvack.org>; Mon, 18 Mar 2019 10:18:08 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:in-reply-to:message-id
         :mime-version:references:subject:from:to:cc;
        bh=/AfMcWXUpr8qOV9jNlH+KOvJdLIB2O2rWZvj+eGhaHk=;
        b=cewqUtOMDvOhpAcz1FrwStBxgMx+oKaCg0iIBDBjBNsLXI7CKBIEpRWu7/MNDmAMip
         pYuvh3rCclNKzSdQR7jQuk6nOudmUa+PeLOwvsDTEpP4eNmpejxtKoR2GUi8nQfCV3LT
         bzLfKpUEZ5PnWadCgYrHzoPrJxQXNPpwYDJPNpUAJJvI0aM1b/JLF1JcHqi8scL3B0Yj
         uCiTuoEl6SDewnGxsRzroaHlEM5QigyD69qotcRxCL6cN+NovxDx5eRls6aTaJAPKDhO
         EQqFszXwnvYnDCdr1g7qSxQjbK7tuQq9e0fS8+RrJBX0xCzdyit5NizWyhwxFq+0J4ny
         o4zg==
X-Gm-Message-State: APjAAAVthw+g7qqTP12NMGH2S7sbOY/IOdxpiWWaaHBFKVR4Jto0dATT
	j3aK3rzjot5xTPlsSQjO07rQ7I/+jKHf3skMVwhWpxAASeJBAjeraputCjjwA5vLvoPmNhl1r6r
	N7ZO9xZIXpAWOD29Zn87Yx4LQ114dL7ZlCuw7bPB112GvFerN9U6ipdCNaC9ULuCf2A==
X-Received: by 2002:ac8:1005:: with SMTP id z5mr14270853qti.205.1552929488259;
        Mon, 18 Mar 2019 10:18:08 -0700 (PDT)
X-Received: by 2002:ac8:1005:: with SMTP id z5mr14270818qti.205.1552929487615;
        Mon, 18 Mar 2019 10:18:07 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552929487; cv=none;
        d=google.com; s=arc-20160816;
        b=Lyg1FmoJoYdd3BVCxJFH0uJgwJZo6dEHQvg7PVDjGGzal5MIOoYlaAjzeSYsxtbiRp
         bfmB1WnCy7s5Evx4ZuZnymO+dhkq4RRSZUnPdHUbqejhZs+LKRlK5HVF7W3gTb9SpEoj
         k7JCC0JF4arL5vMwCertYB/VYnHQ31MSn0TCC1ikE0kPztPWhbRISk23fwhUIJRGNuKj
         gTkyK+5fZQcMUpM8t6e/vg6ZSyOmXqno4//VgnumLVUZHQlZyG3TBYw9MdbHPOCpYNau
         K+TkJ4mLqU+AEwvD8da6DWRGQgrb/yZPnbcDM4ECGSPR2NsBY7KN+fRSSnK7sptKWd8+
         jmiA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:references:mime-version:message-id:in-reply-to
         :date:dkim-signature;
        bh=/AfMcWXUpr8qOV9jNlH+KOvJdLIB2O2rWZvj+eGhaHk=;
        b=woutI0jdOF+fq4pa3G+ax90PApvmyf9h2LACvVkp775jV5aGN+58MBcWi5nP+M23I3
         Uu0bwWoWawCwaSFS5/e3s50MLdB+jK/jwcZ9l5vi1/b9/JEioCgan7W6rsw13HxhDH2F
         4hQ/JZAbCGK7usnszQNt4SOe4ix4Hy5oQuaHrmncPcp/7YhdIUxXNmdOr1cfOrIFLGS6
         eKCkYWyvRXKlwVIQLPzxCCSFbVT16XLIj/JcifWHv8ydfFyvZHOL3rQg0PS+CZtO2/GA
         4+HEQ4aKm/Lmd9aTJ8Q7cGqOdNQRIY82qzPcoKiSL3L+TdvTt9ZuIEBu2qIp+ukDNqR5
         XsBA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=ZmesG1+v;
       spf=pass (google.com: domain of 3z9kpxaokcj48lbpcwiltjemmejc.amkjglsv-kkit8ai.mpe@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3z9KPXAoKCJ48LBPCWILTJEMMEJC.AMKJGLSV-KKIT8AI.MPE@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id 34sor12593959qte.45.2019.03.18.10.18.07
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 18 Mar 2019 10:18:07 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3z9kpxaokcj48lbpcwiltjemmejc.amkjglsv-kkit8ai.mpe@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=ZmesG1+v;
       spf=pass (google.com: domain of 3z9kpxaokcj48lbpcwiltjemmejc.amkjglsv-kkit8ai.mpe@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3z9KPXAoKCJ48LBPCWILTJEMMEJC.AMKJGLSV-KKIT8AI.MPE@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:in-reply-to:message-id:mime-version:references:subject:from:to
         :cc;
        bh=/AfMcWXUpr8qOV9jNlH+KOvJdLIB2O2rWZvj+eGhaHk=;
        b=ZmesG1+vdfvVJVysloZ/DvNyAHwl1NeoVDeZqmznyOpJWfePQRGjlMOaVKfDpQrgzs
         J2EQbjkMYChUC5zNqacIMsL4hIDlSJ8LlP4Fmv1sBUKWq1gONhy9n6WlIdgh6miGrDT+
         kxO+pObNRxAVLj1qO6umMp4FBt4KoE0pcjnUi2zV7lJYuNIAUHoun/OybTmy1PNaA5yQ
         p3eG+Dhv94MxYowpcID5/Yi84v5cik+7L0zhfsc+N+0vCh3BkkQf0oPyRfu2qOWqEfLW
         2tCSF4/OHp/EYgkB0s7TOad99Oui2rlmLjv/5KNArBSNE7FFiFH/+uNURIDaDJj0/jzV
         BjkQ==
X-Google-Smtp-Source: APXvYqzQcEeEWS2cRarzaICPGg9P+n5KYCEBV6zZ1LX2+H91hhlcnbntbKdJigMJk6uOOiOh4IgPE1iT+lDz1l6o
X-Received: by 2002:ac8:2733:: with SMTP id g48mr11081110qtg.0.1552929487390;
 Mon, 18 Mar 2019 10:18:07 -0700 (PDT)
Date: Mon, 18 Mar 2019 18:17:38 +0100
In-Reply-To: <cover.1552929301.git.andreyknvl@google.com>
Message-Id: <e12d6b5008f63b530d25ad73b2e3491939005c22.1552929301.git.andreyknvl@google.com>
Mime-Version: 1.0
References: <cover.1552929301.git.andreyknvl@google.com>
X-Mailer: git-send-email 2.21.0.225.g810b269d1ac-goog
Subject: [PATCH v12 06/13] fs, arm64: untag user pointers in copy_mount_options
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

In copy_mount_options a user address is being subtracted from TASK_SIZE.
If the address is lower than TASK_SIZE, the size is calculated to not
allow the exact_copy_from_user() call to cross TASK_SIZE boundary.
However if the address is tagged, then the size will be calculated
incorrectly.

Untag the address before subtracting.

Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
---
 fs/namespace.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/namespace.c b/fs/namespace.c
index c9cab307fa77..c27e5713bf04 100644
--- a/fs/namespace.c
+++ b/fs/namespace.c
@@ -2825,7 +2825,7 @@ void *copy_mount_options(const void __user * data)
 	 * the remainder of the page.
 	 */
 	/* copy_from_user cannot cross TASK_SIZE ! */
-	size = TASK_SIZE - (unsigned long)data;
+	size = TASK_SIZE - (unsigned long)untagged_addr(data);
 	if (size > PAGE_SIZE)
 		size = PAGE_SIZE;
 
-- 
2.21.0.225.g810b269d1ac-goog

