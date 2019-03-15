Return-Path: <SRS0=L2Uh=RS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT,USER_IN_DEF_DKIM_WL
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1B1D3C43381
	for <linux-mm@archiver.kernel.org>; Fri, 15 Mar 2019 19:52:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CA7EF2063F
	for <linux-mm@archiver.kernel.org>; Fri, 15 Mar 2019 19:52:01 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="b/k7mB6t"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CA7EF2063F
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5BDEC6B02AF; Fri, 15 Mar 2019 15:52:01 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 596496B02B0; Fri, 15 Mar 2019 15:52:01 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4B0736B02B1; Fri, 15 Mar 2019 15:52:01 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f70.google.com (mail-io1-f70.google.com [209.85.166.70])
	by kanga.kvack.org (Postfix) with ESMTP id 1C8E86B02AF
	for <linux-mm@kvack.org>; Fri, 15 Mar 2019 15:52:01 -0400 (EDT)
Received: by mail-io1-f70.google.com with SMTP id l10so7780468iob.22
        for <linux-mm@kvack.org>; Fri, 15 Mar 2019 12:52:01 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:in-reply-to:message-id
         :mime-version:references:subject:from:to:cc;
        bh=5MhKE+xTLHyfvL7IaHp0v3M/t60vex2+i9OGVnQRymk=;
        b=tC9oZjaSjC5+nJq9nVEFiTqxpDLlY14P8jaRKc4PXgcCgp+O0LEisA4G4DIaTG76ln
         hRvoc3TaUaXUhSrqai4ZqRGLWKYtaHDBaDLKrs3Tnv0LGzceiXgoTTjS3LIvI4Xb/JZN
         QpwB2Ckc5C4hsE6z/soqtkzb6Yzl4rwLIHP/b2Amoc0p5vVe4256/rMzbemA0atm++az
         cHSYtQoQhzN8J3zZSJvrBSDtlXC+mmeskncJSUiYsiR03MPbd5ieRWV5o1UhaNA+C1Vb
         rX0gobDNxytXn7FKL7KJcdXJAE28JpDFm9BZomXalhuL2aWXaH+Gh2OdnABBIGTYLwz+
         nOiQ==
X-Gm-Message-State: APjAAAXYN56iH/AKdX4LM447RDlZS4uWoHFkXHAmN8LBM9pLN2BQH4e7
	aFRjSAxnk5c3SCUfS87Ei8Mu9KlTHp2I1QMQeVjJ9JIEqX6GVIJlV7GwObcAX6U1kXO1E4LSxOD
	dXcfyIvEn13BKp4F8Ny9/CO5uA/0XmAOcOjcCUAoZJdUIExKtG+YMHVoygOfevsprZQ==
X-Received: by 2002:a6b:6e0f:: with SMTP id d15mr3679375ioh.111.1552679520883;
        Fri, 15 Mar 2019 12:52:00 -0700 (PDT)
X-Received: by 2002:a6b:6e0f:: with SMTP id d15mr3679339ioh.111.1552679520134;
        Fri, 15 Mar 2019 12:52:00 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552679520; cv=none;
        d=google.com; s=arc-20160816;
        b=njBKrutnc1mYpe9Hn8DO37jssD7zSvM4XnRCBACkZCMMOGSBoJw5C/rdTYMXy9SDnU
         KmV2dwXeW7saIc0asqS29SwZ2/nuv1jnjkOWL31+xfXrHedZp1zt+27GslKPtun+9Wqj
         OrtRhQ3Gk08UTeCIkx8wD0oOhDBPGGYZ1hOW3AoMovJ1AaYgXgRhCs4XgRcL42DJXynL
         SJeXx+UWdmC/q6XzfGDicrOchisS25Zy6v9eEIryn88e3vW7cv+CFBYpXA2Pd4jgTr6O
         xEc4roMbTWmklejy4Nt7nixQEGVm+dtWKBaT0WeU0dVSch5Teu8krvf1VGUdj3UtpZil
         gnNg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:references:mime-version:message-id:in-reply-to
         :date:dkim-signature;
        bh=5MhKE+xTLHyfvL7IaHp0v3M/t60vex2+i9OGVnQRymk=;
        b=WhQTZKavYZNAp2ZCZ17qQvl+dBHs8Br+7OZVSrMOzvaxEYAljVMJN69+I6C3R/cQmz
         leYvLZtJqxhTyPGxBBhI3n8D3b+ZSJUQGU+XWcIHiLj97bzQYTnFNiCvlHXPtLwDVOZF
         Txv/+mHMxkrBxQ6ZcT5pwyVcfMgKvSmLKOha12VOrJNkkKug9Fv0wXqE+lN93cuTldIY
         enxmOlIr5wzn/70E06///HcSQvS5TL7z2YeBZ/o9vdpMvMGUH/g6J8VK62h0FhpLBHaZ
         JgLFDWXsyyJjIPa53v58lRH57jp54decuup3U0jWkBOR7K0bowRKZgaKLAKsQZex1nXi
         CEAw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b="b/k7mB6t";
       spf=pass (google.com: domain of 3xwkmxaokch4cpftg0mpxniqqing.eqonkpwz-oomxcem.qti@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3XwKMXAoKCH4cpftg0mpxniqqing.eqonkpwz-oomxcem.qti@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id n195sor4993395itb.34.2019.03.15.12.52.00
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 15 Mar 2019 12:52:00 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3xwkmxaokch4cpftg0mpxniqqing.eqonkpwz-oomxcem.qti@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b="b/k7mB6t";
       spf=pass (google.com: domain of 3xwkmxaokch4cpftg0mpxniqqing.eqonkpwz-oomxcem.qti@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3XwKMXAoKCH4cpftg0mpxniqqing.eqonkpwz-oomxcem.qti@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:in-reply-to:message-id:mime-version:references:subject:from:to
         :cc;
        bh=5MhKE+xTLHyfvL7IaHp0v3M/t60vex2+i9OGVnQRymk=;
        b=b/k7mB6t8bkl6WhPUgGfnIbuQpfATsU20Yd9KlI8YbMaGUFttdQxCzkvduKa8IOy8C
         +aL+zDQpxDKN5neB5pmosuIHBI0Zw/VkKPjT+OCI05YKof+0rexjDomInULUZSZZwZe4
         sKO4ip/dnicDW0EiUs3RF19JdO3smNNUCHBqnEYyMQcB4Zi3SAnphW12wObXWLr30yaC
         Cg1FmVpaxC5JzsE7dKMZHXXd8+AOb4omgJILGhPI4h92LrbGtWJe5eIqPcfmyYH0djku
         js0qEZrW0JA+T0+gbA+Ly5yXzixdwcg0y/4Mb6pAB6p7EjV2RE2SUw8xVQAbEf7JiHti
         SGaw==
X-Google-Smtp-Source: APXvYqzz8vOD7Qv22AiUEzZPFjEW8sEguH+wb4/ai4clU9WhQEQBq5QCuyJA5WS9vCTzYh7rDvAW6xfNjGINS7Ci
X-Received: by 2002:a24:4503:: with SMTP id y3mr2805802ita.32.1552679519819;
 Fri, 15 Mar 2019 12:51:59 -0700 (PDT)
Date: Fri, 15 Mar 2019 20:51:29 +0100
In-Reply-To: <cover.1552679409.git.andreyknvl@google.com>
Message-Id: <f46caf7bea6bdbb7e50f2abedc83df13d075735c.1552679409.git.andreyknvl@google.com>
Mime-Version: 1.0
References: <cover.1552679409.git.andreyknvl@google.com>
X-Mailer: git-send-email 2.21.0.360.g471c308f928-goog
Subject: [PATCH v11 05/14] mm, arm64: untag user pointers in mm/gup.c
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

mm/gup.c provides a kernel interface that accepts user addresses and
manipulates user pages directly (for example get_user_pages, that is used
by the futex syscall). Since a user can provided tagged addresses, we need
to handle this case.

Add untagging to gup.c functions that use user addresses for vma lookups.

Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
---
 mm/gup.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/mm/gup.c b/mm/gup.c
index f84e22685aaa..3192741e0b3a 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -686,6 +686,8 @@ static long __get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
 	if (!nr_pages)
 		return 0;
 
+	start = untagged_addr(start);
+
 	VM_BUG_ON(!!pages != !!(gup_flags & FOLL_GET));
 
 	/*
@@ -848,6 +850,8 @@ int fixup_user_fault(struct task_struct *tsk, struct mm_struct *mm,
 	struct vm_area_struct *vma;
 	vm_fault_t ret, major = 0;
 
+	address = untagged_addr(address);
+
 	if (unlocked)
 		fault_flags |= FAULT_FLAG_ALLOW_RETRY;
 
-- 
2.21.0.360.g471c308f928-goog

