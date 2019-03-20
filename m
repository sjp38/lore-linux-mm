Return-Path: <SRS0=h9qD=RX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT,USER_IN_DEF_DKIM_WL
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A3529C43381
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 14:52:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5ABA0206BA
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 14:52:23 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="Sefw+LBQ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5ABA0206BA
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B55456B026A; Wed, 20 Mar 2019 10:52:21 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B04886B026B; Wed, 20 Mar 2019 10:52:21 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9A5B96B026C; Wed, 20 Mar 2019 10:52:21 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 764F86B026A
	for <linux-mm@kvack.org>; Wed, 20 Mar 2019 10:52:21 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id f89so2684004qtb.4
        for <linux-mm@kvack.org>; Wed, 20 Mar 2019 07:52:21 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:in-reply-to:message-id
         :mime-version:references:subject:from:to:cc;
        bh=K4asd4oI0/VXu7bks/7ZozR0oEqYxUgnLBJb7yiErTQ=;
        b=avqwNt+r1oNO+Jzb4ms6jJqBYnX7KyvP7tdEMiWxCNCtBGZydBy6acJdWe01AtyQaQ
         Qb2MHyqInce7iLiCBttMj1evp/kUIgTKKMZRdf3QqvG/VZdbZzcr4j38bWbTRQJSuDDn
         sslUy6/UqbWhRvrCPMxIFQHV1o9kVHiSZW3xtAN0+QTCeIqcOK2KIGl3auLqNT8K8NoT
         jw8gvsl92X94/2Z1Y8NNf0xfsu7gbBSfaWHbtLcdC3xPi/wx6OG7N2RPgkRwdOM6ejKe
         z3qEBu6IQC2fJsQsi6ATjg7qbfWpsowPIAnGC9MGtF3Z09961WBw6d85JCTtEtFsuCsw
         aGkg==
X-Gm-Message-State: APjAAAWtMuMzyqaM9dfs/wMIXdjIpCdgKCCXYqre+49ykvo+3jVNueMn
	3wGtquylxS0AwcHAR2Ko3DaQd/6JqZ9WtGKpVYrocKemLK6GO75gPT6YBQd/arm9SmDkawNyHox
	MolvakMeGgo78anUEMnlBY1BjGkaWlWFBFuHpaqfHk8poV4HMftiqQg2og7GSfRwrUA==
X-Received: by 2002:a05:620a:15f5:: with SMTP id p21mr7114061qkm.5.1553093541179;
        Wed, 20 Mar 2019 07:52:21 -0700 (PDT)
X-Received: by 2002:a05:620a:15f5:: with SMTP id p21mr7114008qkm.5.1553093540406;
        Wed, 20 Mar 2019 07:52:20 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553093540; cv=none;
        d=google.com; s=arc-20160816;
        b=DdK9GDGwEcV0uLuwoyLjSCj7uGmIsz7jMzLc/bWypPfsa2bMRl2BpN1I/RCPCxseYk
         bUhgM/b8D6RhUblUlcaqSQt9J1JOLqtwld0ErltIofke0RRBmCIlYVaAAZzoDlBzITnv
         tlKjIWv8s3czdP3iSMPUoneofqz4sB4UvcyJepMghSzKhE3M0i0i/I7zu/Zjf+ZMHm0j
         jS+qc/ElnhepBKQuZsBHxfJsqYEAhOA5uLsmKhNzSthETEcV0yJ7sLTeCNDLnE07OxXX
         aF1XlNvc3YHz/aCG8YSS/3T0+T8v/0FATwlUsUvnHluFIDm6Dtn4puW89VmV1clrhzt6
         SNog==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:references:mime-version:message-id:in-reply-to
         :date:dkim-signature;
        bh=K4asd4oI0/VXu7bks/7ZozR0oEqYxUgnLBJb7yiErTQ=;
        b=Hlg649wE7nwVJyfXh05xy/oKrpB3x/vdxW4nyXpUnAzBhIdFdpG7appkqq0U3zOAv8
         magiE/t0poeNvWRZvfGgHMjw6DJllcM1YNdW8E95P3VJ0fjHHAS83dUIe9Aoe9wEGsd8
         GuuKI9iZgWuVEGEY9cjyFC+LaUG+3PTmFF/E0C2MlAEo7eESes1hy6gDPLk/tkjQEjii
         mpnUmR+9vjCSQ9voEbhWkqpVy75EZ+UvlxGDfPk0P7fT0RoeZ1zQFtqJeBO6fouw4KVp
         edUxQXbUDo/0De3IK/Tm7fVZMUS44BkALJXP/d7hd0XzV1k2m0vqz5Oo8+f+kdoIQQk7
         iQZA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=Sefw+LBQ;
       spf=pass (google.com: domain of 3pfosxaokch8dqguh1nqyojrrjoh.frpolqx0-ppnydfn.ruj@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3pFOSXAoKCH8dqguh1nqyojrrjoh.frpolqx0-ppnydfn.ruj@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id f8sor3967143qtb.16.2019.03.20.07.52.20
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 20 Mar 2019 07:52:20 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3pfosxaokch8dqguh1nqyojrrjoh.frpolqx0-ppnydfn.ruj@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=Sefw+LBQ;
       spf=pass (google.com: domain of 3pfosxaokch8dqguh1nqyojrrjoh.frpolqx0-ppnydfn.ruj@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3pFOSXAoKCH8dqguh1nqyojrrjoh.frpolqx0-ppnydfn.ruj@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:in-reply-to:message-id:mime-version:references:subject:from:to
         :cc;
        bh=K4asd4oI0/VXu7bks/7ZozR0oEqYxUgnLBJb7yiErTQ=;
        b=Sefw+LBQD0bYtQOF7Z3/FF5rWl5fnzlahJItvb5ZICgi8f6u4tK/9F6nfzFXPich3o
         EcUn7JVF7lEJYJneqAC0m7D0m73A5VmH620Qfp8NMW21rRutLGEd2Gtg1ILCNwDmdZNZ
         FjIyPxXe0aqGhTuqozDv4invVSFneb5ZIlySFOfmNfdoGDZG5iv4aiillZPkIZFAoy/1
         Op94lqwLg26NfLmDs8/kDtPAlvGhye76V+rDgwQLh/XO9bfB2FGQp9lBXpf3J2QGTDlH
         XxqI4JERIWdF2z3HZogNyJS65SJ4WuJX9kuolmSrlZO9gRMOVvxcsIln5olphRwer6Xd
         nAYQ==
X-Google-Smtp-Source: APXvYqyQ4NMWwmcD+QNQXwycznUSrQ4ccjdMHmvJTyO2jY+wRoLxkzWub5WBnbxSwYjZ06st+3eMc86w9nXfL0n7
X-Received: by 2002:aed:3b09:: with SMTP id p9mr8634647qte.55.1553093540002;
 Wed, 20 Mar 2019 07:52:20 -0700 (PDT)
Date: Wed, 20 Mar 2019 15:51:25 +0100
In-Reply-To: <cover.1553093420.git.andreyknvl@google.com>
Message-Id: <c9553c3a4850d43c8af0c00e97850d70428b7de7.1553093421.git.andreyknvl@google.com>
Mime-Version: 1.0
References: <cover.1553093420.git.andreyknvl@google.com>
X-Mailer: git-send-email 2.21.0.225.g810b269d1ac-goog
Subject: [PATCH v13 11/20] tracing, arm64: untag user pointers in seq_print_user_ip
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

seq_print_user_ip() uses provided user pointers for vma lookups, which
can only by done with untagged pointers.

Untag user pointers in this function.

Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
---
 kernel/trace/trace_output.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/kernel/trace/trace_output.c b/kernel/trace/trace_output.c
index 54373d93e251..6376bee93c84 100644
--- a/kernel/trace/trace_output.c
+++ b/kernel/trace/trace_output.c
@@ -370,6 +370,7 @@ static int seq_print_user_ip(struct trace_seq *s, struct mm_struct *mm,
 {
 	struct file *file = NULL;
 	unsigned long vmstart = 0;
+	unsigned long untagged_ip = untagged_addr(ip);
 	int ret = 1;
 
 	if (s->full)
@@ -379,7 +380,7 @@ static int seq_print_user_ip(struct trace_seq *s, struct mm_struct *mm,
 		const struct vm_area_struct *vma;
 
 		down_read(&mm->mmap_sem);
-		vma = find_vma(mm, ip);
+		vma = find_vma(mm, untagged_ip);
 		if (vma) {
 			file = vma->vm_file;
 			vmstart = vma->vm_start;
@@ -388,7 +389,7 @@ static int seq_print_user_ip(struct trace_seq *s, struct mm_struct *mm,
 			ret = trace_seq_path(s, &file->f_path);
 			if (ret)
 				trace_seq_printf(s, "[+0x%lx]",
-						 ip - vmstart);
+						 untagged_ip - vmstart);
 		}
 		up_read(&mm->mmap_sem);
 	}
-- 
2.21.0.225.g810b269d1ac-goog

