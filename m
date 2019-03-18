Return-Path: <SRS0=xdO8=RV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT,USER_IN_DEF_DKIM_WL
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2DA5CC10F00
	for <linux-mm@archiver.kernel.org>; Mon, 18 Mar 2019 17:18:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D58A62175B
	for <linux-mm@archiver.kernel.org>; Mon, 18 Mar 2019 17:18:27 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="n6mK8qGB"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D58A62175B
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6D5AE6B026A; Mon, 18 Mar 2019 13:18:24 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 660B26B026B; Mon, 18 Mar 2019 13:18:24 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4B5C76B026C; Mon, 18 Mar 2019 13:18:24 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 20CC76B026A
	for <linux-mm@kvack.org>; Mon, 18 Mar 2019 13:18:24 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id z34so11973053qtz.14
        for <linux-mm@kvack.org>; Mon, 18 Mar 2019 10:18:24 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:in-reply-to:message-id
         :mime-version:references:subject:from:to:cc;
        bh=y0pmDLbK+7BSAh5x56WEIsXOyLAwrKLQOAsadcipF54=;
        b=Rrd7cPDwoyu0IJVQoOGYanmNFUdpKI0W+aJApSSTMlfFc/zpi6kvu2lSTncztwNQCp
         qAWvN2YBL31U876nfSAZJj5kU87umdNxkhUkfbeRR4XnZeQL3CNa2KMVPFvwuxH0vUJ6
         NTQE5+ZzRaP07hCvNGcxaQFMIVo5CNcJ/NT7kdK8R1C+PYoqnfSQxckD0ju5vCnAQXeS
         8nWjJnh+ZxNTeOZgurPagdORF0Md9GmYUXd5FbRSqiopEKinz37/21LPvFfDUEmo2gT5
         mOM8Pdr6s055kqRI/vGisWrqLRxG1TkAh4IjT1TOiTVCkULknZsWR9tracOWr8fHEqMh
         mong==
X-Gm-Message-State: APjAAAUnNeAM3XKzyOB+GiowD8fNJaH6EghSqyQmwip/1UVUwuR/OHYE
	Iw/pn8F9+idw6tSxB18jDH5hVcpJaWsvLTNEv+RVPfa7iPGFCXIlJppW1ZwsQ6sci4RFAAKCMco
	9T7weW6rkjJGHAzs4fr23nSBe30xYwb8nbEZTdQ4cSEHmFlUNiyFa8HcziigUdO0rig==
X-Received: by 2002:a37:de18:: with SMTP id h24mr13378636qkj.139.1552929503915;
        Mon, 18 Mar 2019 10:18:23 -0700 (PDT)
X-Received: by 2002:a37:de18:: with SMTP id h24mr13378593qkj.139.1552929503108;
        Mon, 18 Mar 2019 10:18:23 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552929503; cv=none;
        d=google.com; s=arc-20160816;
        b=VlhEum6Ns1naGGXMWYKPYGtjUd8zUuuceLSuUix76ryYxJ1YuGmYSKSqce1Azv2Mfi
         sQRSqqUXDMrz+HaVJtkHRwNFdxJt45hwsDKw4EHOod5ugoFe6CDx9ekMIWWNdz4QnrlH
         3HsDGg6xd6Jtj4YNNIOhaBMigadAfI8MU/fpOo8PVeu8pcxVkutT1BwC0qFrq8a5Bdii
         ZMe4wmO4wH8uaYABLymNPjTSpp8pUrBBKG4sw3pozD3j9WC480sCjvdcw13rS42KGWrB
         r3GIDU7qFshNq/WfYnN5d9ehsbVqUfTmaRbT7iPBW6UAiIrQaf9ofzmWni5OFOgTt6jD
         Xg+g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:references:mime-version:message-id:in-reply-to
         :date:dkim-signature;
        bh=y0pmDLbK+7BSAh5x56WEIsXOyLAwrKLQOAsadcipF54=;
        b=eNt5gkiv5hl2crP6FYOnvpcoEH74X3zvv3r/fKnzw3PmKTWLVgB5CWI82qxowjOAQ8
         Ymv4JVJ3BntsKd9VPDLfOHqoBtvk3+4PdZ8OAHRtyA8DdXKo3T7HBef8A2/4Bt8fjQrx
         ct/6f6KX8HkcUq7k2ll7i9K8Byx/tWL8UMPFSYIchw/G+V/oDNmhIBo1KMl/clc8dwF9
         UDBwcNutSdOGAA/V80WEZOZ5AOTZlVCujew/334egSfWktgWQnOfxTnxqWhPtWRdgWaR
         bzNGTsAAKXSflh7/BE2ZNHcPKejNJ3z+KWVUApGTfajeSFeV5HdV5/IuM5ZZHR0nUC8E
         AYPQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=n6mK8qGB;
       spf=pass (google.com: domain of 33tkpxaokck0naqerlxaiytbbtyr.pbzyvahk-zzxinpx.bet@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=33tKPXAoKCK0NaQeRlXaiYTbbTYR.PbZYVahk-ZZXiNPX.beT@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id k33sor12611454qte.66.2019.03.18.10.18.23
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 18 Mar 2019 10:18:23 -0700 (PDT)
Received-SPF: pass (google.com: domain of 33tkpxaokck0naqerlxaiytbbtyr.pbzyvahk-zzxinpx.bet@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=n6mK8qGB;
       spf=pass (google.com: domain of 33tkpxaokck0naqerlxaiytbbtyr.pbzyvahk-zzxinpx.bet@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=33tKPXAoKCK0NaQeRlXaiYTbbTYR.PbZYVahk-ZZXiNPX.beT@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:in-reply-to:message-id:mime-version:references:subject:from:to
         :cc;
        bh=y0pmDLbK+7BSAh5x56WEIsXOyLAwrKLQOAsadcipF54=;
        b=n6mK8qGBi8yC21LmjABra3FF+XTvfgLYZr9bPF1sHZ9sen0usXtJo9r8UWpIWYoDEs
         YEss5ttEDAL6lIbgFyj4X628k4cUup4CCMJ0VLQ4ftrPTG+rRMptHjumdErdUDl9ISYY
         rB+TuyC09kttxpZuExC8/+TH8Y8tVKRukuxPYVczcjDCqo+QtLbM9TmxH0fH4rTQxur3
         7pLUDwD0Z21jyoNe+FO+hi4d+W5N8IZjBamLALgbuY36eoX0Noj2JHkXsAIpP352R88b
         ntHc4rkT8wXoHbCbhE2dgY+nunbgZmc/Jf/sc4zQqGibHR6/JS9I5KqLldKTT6WFAxiu
         sHnA==
X-Google-Smtp-Source: APXvYqycOMQXhB7LunCtJ2mSN8JG36V+ND4YFbv89PhbTN2edqY1ONzRmnxPOCaXOMvcqg83reHV4EVl11OVLG5G
X-Received: by 2002:ac8:2e7a:: with SMTP id s55mr10982902qta.34.1552929502878;
 Mon, 18 Mar 2019 10:18:22 -0700 (PDT)
Date: Mon, 18 Mar 2019 18:17:43 +0100
In-Reply-To: <cover.1552929301.git.andreyknvl@google.com>
Message-Id: <b24adf53a968b50ba84630f86136ee1251e12a9d.1552929301.git.andreyknvl@google.com>
Mime-Version: 1.0
References: <cover.1552929301.git.andreyknvl@google.com>
X-Mailer: git-send-email 2.21.0.225.g810b269d1ac-goog
Subject: [PATCH v12 11/13] uprobes, arm64: untag user pointers in find_active_uprobe
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

find_active_uprobe() uses provided user pointer (obtained via
instruction_pointer(regs)) for vma lookups, which can only by done with
untagged pointers.

Untag the user pointer in this function.

Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
---
 kernel/events/uprobes.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/kernel/events/uprobes.c b/kernel/events/uprobes.c
index c5cde87329c7..d3a2716a813a 100644
--- a/kernel/events/uprobes.c
+++ b/kernel/events/uprobes.c
@@ -1992,6 +1992,8 @@ static struct uprobe *find_active_uprobe(unsigned long bp_vaddr, int *is_swbp)
 	struct uprobe *uprobe = NULL;
 	struct vm_area_struct *vma;
 
+	bp_vaddr = untagged_addr(bp_vaddr);
+
 	down_read(&mm->mmap_sem);
 	vma = find_vma(mm, bp_vaddr);
 	if (vma && vma->vm_start <= bp_vaddr) {
-- 
2.21.0.225.g810b269d1ac-goog

