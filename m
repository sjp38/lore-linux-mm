Return-Path: <SRS0=xdO8=RV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT,USER_IN_DEF_DKIM_WL
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 76174C43381
	for <linux-mm@archiver.kernel.org>; Mon, 18 Mar 2019 17:18:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2CC5D2133F
	for <linux-mm@archiver.kernel.org>; Mon, 18 Mar 2019 17:18:25 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="Z+OUUKNg"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2CC5D2133F
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7E78C6B0269; Mon, 18 Mar 2019 13:18:21 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 79B796B026A; Mon, 18 Mar 2019 13:18:21 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5C6936B026B; Mon, 18 Mar 2019 13:18:21 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 35D5A6B0269
	for <linux-mm@kvack.org>; Mon, 18 Mar 2019 13:18:21 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id l87so15218119qki.10
        for <linux-mm@kvack.org>; Mon, 18 Mar 2019 10:18:21 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:in-reply-to:message-id
         :mime-version:references:subject:from:to:cc;
        bh=K4asd4oI0/VXu7bks/7ZozR0oEqYxUgnLBJb7yiErTQ=;
        b=FueemxA6Okb9rpiYD82Jj/lWnythHswyjJdmUcMPgr6ftTeyMK14Tnb0dVSIrneiNz
         XRsadt2D5Ts7dbgT+/RJzpjT4Fkuzq1w3WHrUG6A3oWAShbkd5yyy8IinBv+kLjX1iV5
         FPujTuBmYmtujl1aO+d21/nOSmLBw9eSed+FnaaYqkufgOLZvuwrb+0DN6MdzKu6RZYo
         xrTk5wsY4QAYsa7rIK/SbqSMrvGj5JWjAwrtnWPVh/mSrjjfLQtKCqXy6G1bBF6egL+5
         uFLPJhEZ1wviaEYGsdHj77MkhOeTzqbk215Atdw1tk9Jgpc7ZrHajPpY+/JKL+1CCJwm
         MJ+Q==
X-Gm-Message-State: APjAAAWyrbOlH98TkZaNzjec+LyVtz3MSWWx4BFpaw1QOAQSdgzcBfhO
	ve63EvCXoM4Vz1BfPXLCpaQ4ArPQzLkpKXQmKhUe2Q0IcIf8tta1I54e4Xq3ZiyLunqiymqHlWG
	p7eGxYpRNwNPRw9aF2+TKzfsyG3dFnp29srHNKs+NqZP+Rxd6YxEDirQX6pYrWqHx1A==
X-Received: by 2002:a37:d150:: with SMTP id s77mr13927045qki.334.1552929500969;
        Mon, 18 Mar 2019 10:18:20 -0700 (PDT)
X-Received: by 2002:a37:d150:: with SMTP id s77mr13926993qki.334.1552929500209;
        Mon, 18 Mar 2019 10:18:20 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552929500; cv=none;
        d=google.com; s=arc-20160816;
        b=wCFCNUE0KwrMJn5J1zFlNG3CrazLSTfUzA57eh4ZXOkcwT6Q0W4zGTQWV2g26+e96I
         qfp/seuyOpsvdW0Z1ALXkQLNj3BbMsS5eosPLMJ0x/sYXeRAqtVuvI/x8fOtxGSVQutH
         VyRzjVjfsMO0GPPXokcU9G1dGki/NBO450FXwUf0Q6UBAC/o9SAisL2a2zckRsq+CEJz
         wRFHAv4a64gqQYsDvGp6lys5Jwvg+MrLMOq4HMobpCnyNjYmAEu9sYzGMABhOJcejCGz
         UZfFxe616Zd/Nxl2Nny91t7YZvCEOYuVgioWHpPoWw5C8T/PofE7K7xpMh4/HOfHilY9
         eHHg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:references:mime-version:message-id:in-reply-to
         :date:dkim-signature;
        bh=K4asd4oI0/VXu7bks/7ZozR0oEqYxUgnLBJb7yiErTQ=;
        b=MRd1kz1spW8fBQeXudn8dj6QQYkGLZcx1UGDaCuJ9iT36q4ubW+ii1zKMbIT8UJyre
         DHJmvlE0CLPaRKUb2Cz3NmHpArwulIz8Tn4SCUPAe1J3WwL5lQhXuv85xG3sJpTigt/4
         EKcc+mtoNJZZfNVgo7RjwHOzD3TuGB56NSitIopQ7oB2gCIr92Woko8zkcqLJj+gloAN
         75OJ4cXvnxeDc+9aFighCbTMH4TxZ/qli/7jViCK8FQLKnKK8/SYCin68vtLNHJ5xG1E
         AV6fNYT7m9dfOGsLdyXMLNBzbJatd+eEhFI7JFVEyoYzEkQdQVUhb0u7jKHkJd5+7zA2
         ovYQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=Z+OUUKNg;
       spf=pass (google.com: domain of 329kpxaokckokxnboiuxfvqyyqvo.mywvsxeh-wwufkmu.ybq@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=329KPXAoKCKoKXNbOiUXfVQYYQVO.MYWVSXeh-WWUfKMU.YbQ@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id n2sor12598903qte.25.2019.03.18.10.18.20
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 18 Mar 2019 10:18:20 -0700 (PDT)
Received-SPF: pass (google.com: domain of 329kpxaokckokxnboiuxfvqyyqvo.mywvsxeh-wwufkmu.ybq@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=Z+OUUKNg;
       spf=pass (google.com: domain of 329kpxaokckokxnboiuxfvqyyqvo.mywvsxeh-wwufkmu.ybq@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=329KPXAoKCKoKXNbOiUXfVQYYQVO.MYWVSXeh-WWUfKMU.YbQ@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:in-reply-to:message-id:mime-version:references:subject:from:to
         :cc;
        bh=K4asd4oI0/VXu7bks/7ZozR0oEqYxUgnLBJb7yiErTQ=;
        b=Z+OUUKNgtK/1jfa4BvhYHhx7IjjNLQEUJY1NJ7A3vWEIk1RX9PbVSKhiX+wNpR0VVK
         rm+RSajsjJHCrhE1N6/tIuVP+q9XdaMCbwZRMPCgTCjx/L9P2gvJmmbwqvWCKBP9MeF4
         Qw6j2LzWa+BeBhtFcRkoFqLNaB2ov3Vsincet7Xt01JgrRy0n0Px8l+DavyyXnsSQINI
         wfOpZ4cpDL384ukM2hnrV7HWIk5LriqFPiuoGB3tjO+kwnvk5ccqGZfvf45ZsEC8+Jc9
         GnSLuoWMdhDxaKuqFTy4AAf17P9nihFjMbB/8eHPp3LiMDt9udnfahJfYpgVE4FXcX3j
         TbFg==
X-Google-Smtp-Source: APXvYqyJhTgZar+ik6UuyzlVr6SmEq6/15j430olxCWRyB477jKqfxZfFi3KkJC1jdRI+TAOqV2mqA21WihG+rqN
X-Received: by 2002:ac8:21f2:: with SMTP id 47mr10994391qtz.9.1552929499883;
 Mon, 18 Mar 2019 10:18:19 -0700 (PDT)
Date: Mon, 18 Mar 2019 18:17:42 +0100
In-Reply-To: <cover.1552929301.git.andreyknvl@google.com>
Message-Id: <9733fd0b723aab6bcf4369fe366104ba795eb5a9.1552929301.git.andreyknvl@google.com>
Mime-Version: 1.0
References: <cover.1552929301.git.andreyknvl@google.com>
X-Mailer: git-send-email 2.21.0.225.g810b269d1ac-goog
Subject: [PATCH v12 10/13] tracing, arm64: untag user pointers in seq_print_user_ip
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

