Return-Path: <SRS0=h9qD=RX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT,USER_IN_DEF_DKIM_WL
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 820A4C43381
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 14:52:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2B1AA206BA
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 14:52:27 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="VBRIEAm7"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2B1AA206BA
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CE1096B026B; Wed, 20 Mar 2019 10:52:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C3D396B026C; Wed, 20 Mar 2019 10:52:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A90866B026D; Wed, 20 Mar 2019 10:52:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 672946B026B
	for <linux-mm@kvack.org>; Wed, 20 Mar 2019 10:52:25 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id m10so2768396pfj.4
        for <linux-mm@kvack.org>; Wed, 20 Mar 2019 07:52:25 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:in-reply-to:message-id
         :mime-version:references:subject:from:to:cc;
        bh=TypqXDoyNXONz2oDo7T8C+4NlePqKxo9jFd/dN9OnUY=;
        b=KJPFUpdyLhG3jN+U2nA1vmUWXLA9u5DFhlRA4E7bfC0z5zHZfyqT/5pl34Jwrn6MQo
         gSobsJdWxksItN1nUdAbkwKzmu+vKGkfGD0UewDpriTtouddUlQL5/f3yvZ5aBftXlWm
         UY2sgmR2wZWVvibBMHsBaa7hNy3MztsrDVO0OXh/nGZsAgS2XNIV0xO1LLs7Rtu0VmQI
         NRo/cbvAjHKyXFnRu9S2QIZEtpjnuhtloiREYZ93ASy0SKIk9L12fjwJJqC1EG2TeE+n
         vOTnODa7Kkvjb99zFY22RrBEZW5Nx8gdVfbBwdcH+83JZnM38o43xYEUQNXR3viW+fGK
         17cA==
X-Gm-Message-State: APjAAAVfny/BCrwamBW0UmijXCEhx0YC3DnrBzZTCqre3DDGTIvwXLSH
	3Ombr/Y0YdO6Pz7ITBSNB6mx1UeXIo1jjtM5eDYZtn2gg5dJtgbutAfKE0ftkiCoHUDRtPfARN/
	dc84xIWT5lNNWZVSL+HCc/ISEmQVYash7hf/h4BldrCY6zqVbIiMxY/57VdJe1jMXDg==
X-Received: by 2002:a62:12d0:: with SMTP id 77mr8140155pfs.15.1553093544947;
        Wed, 20 Mar 2019 07:52:24 -0700 (PDT)
X-Received: by 2002:a62:12d0:: with SMTP id 77mr8140098pfs.15.1553093544022;
        Wed, 20 Mar 2019 07:52:24 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553093544; cv=none;
        d=google.com; s=arc-20160816;
        b=BIODG2RnP0rvyE/X0WxbfpMd/DGJYptmCL5+Zbs3hespGpRhrFZSkNS4JTqoYy8RCK
         5lZpPBeENFEnWKe5fMJjE5wAvy/gqRfgqhHaDth5YvnNrSY7yLCmmL8fH4BrhLIJclcY
         2h2Sg9MlkO59gcsaODNvrkkDzMZcfa6Q5jOlRZOavAsrrGzHeypSAMucCdJgm2ZD2f27
         /WTHdcw/pz13wKP6bXKTvYaIANNUnxXk5rrxEtrE4X29RxVA2Xfn1M9CPlWBPTmjDywb
         FjVS99Yjr2fqwEAeDsh0OSVBi/QstN4vEq47OSyjC5USq11OabzIhuSu+O1dNF+BN9vX
         17Ow==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:references:mime-version:message-id:in-reply-to
         :date:dkim-signature;
        bh=TypqXDoyNXONz2oDo7T8C+4NlePqKxo9jFd/dN9OnUY=;
        b=YB+JKwqxZbx0BOnJUN970tSxxoG+x/fqOtVS9cU/luNUvzK6kddGwmc0viV1dXOBb8
         oeTJVZL2IGMseKMhdSj7ftazd6JQBPZlRTv+k5LU4MeqMjT31z8PhFR4PM6Ll3wS+JtA
         xj0FmKUtSsSMxlgQBoju2tz4mWGEe+H+16uKjVc27sLimE6RIN3wAZzb96CT25hpotZR
         z69SQ8qIqWP2c5pzzwBmih5Dpd25QgMo/NtD0spSWmVxB8lLyTNJJgB+xvfQe18ZP6fM
         Ow221LzbaRHkbbrmCi3A0nUZLUF0IyxEtQgsMvMMs3UeysA3FRAK9RgIXX9B7m2ZJzL5
         CG3Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=VBRIEAm7;
       spf=pass (google.com: domain of 3p1osxaokciigtjxk4qt1rmuumrk.iusrot03-ssq1giq.uxm@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3p1OSXAoKCIIgtjxk4qt1rmuumrk.iusrot03-ssq1giq.uxm@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id m7sor3295573pll.71.2019.03.20.07.52.23
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 20 Mar 2019 07:52:24 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3p1osxaokciigtjxk4qt1rmuumrk.iusrot03-ssq1giq.uxm@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=VBRIEAm7;
       spf=pass (google.com: domain of 3p1osxaokciigtjxk4qt1rmuumrk.iusrot03-ssq1giq.uxm@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3p1OSXAoKCIIgtjxk4qt1rmuumrk.iusrot03-ssq1giq.uxm@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:in-reply-to:message-id:mime-version:references:subject:from:to
         :cc;
        bh=TypqXDoyNXONz2oDo7T8C+4NlePqKxo9jFd/dN9OnUY=;
        b=VBRIEAm79eYl13DjJG/iyvfKJYZY4JaqF0G4F5Q9Tdc02tcv3SWnQ7Xrt3SjBFfGvg
         PcwgciJDQT6onqfPRyqhMrslyXsxz10zdr5FgA2LGaoQc9yos1AyT8UyusDzxef8QaZN
         z/f2pc6v7A54U9tLiW8lNWS179RcuvzfHFAZzepf2J72aR6ktogxURSeTjnVYurpdTa1
         B6f7t3ef6UHMUiBVLuaDIwpdpl0FL6sYq3LH523DSKALKUVOqO0tPAJ4+aeT4zaZmhz+
         IrRrf0UOiKCQsyUUh28eTbRMIsy4aBjzHA3qkBs+V7Ol2Fi+w51237VJCFLw3aI3tuE3
         QzOw==
X-Google-Smtp-Source: APXvYqzAZyZyGva2EuPoJScM6UyEVyBDQ8rao6oUZ0kApC3+FesuzwO5WKxPmyM+dQi9tBAx2Re+64THdUBgYOfQ
X-Received: by 2002:a17:902:8a98:: with SMTP id p24mr7507223plo.18.1553093543416;
 Wed, 20 Mar 2019 07:52:23 -0700 (PDT)
Date: Wed, 20 Mar 2019 15:51:26 +0100
In-Reply-To: <cover.1553093420.git.andreyknvl@google.com>
Message-Id: <88d5255400fc6536d6a6895dd2a3aef0f0ecc899.1553093421.git.andreyknvl@google.com>
Mime-Version: 1.0
References: <cover.1553093420.git.andreyknvl@google.com>
X-Mailer: git-send-email 2.21.0.225.g810b269d1ac-goog
Subject: [PATCH v13 12/20] uprobes, arm64: untag user pointers in find_active_uprobe
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

find_active_uprobe() uses user pointers (obtained via
instruction_pointer(regs)) for vma lookups, which can only by done with
untagged pointers.

Untag user pointers in this function.

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

