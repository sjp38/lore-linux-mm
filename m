Return-Path: <SRS0=L2Uh=RS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT,USER_IN_DEF_DKIM_WL
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C8DC4C10F00
	for <linux-mm@archiver.kernel.org>; Fri, 15 Mar 2019 19:52:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 70127218D0
	for <linux-mm@archiver.kernel.org>; Fri, 15 Mar 2019 19:52:20 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="FNIVGISA"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 70127218D0
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 214D76B02BA; Fri, 15 Mar 2019 15:52:20 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1C4386B02BB; Fri, 15 Mar 2019 15:52:20 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0DB4D6B02BC; Fri, 15 Mar 2019 15:52:20 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id E5C3A6B02BA
	for <linux-mm@kvack.org>; Fri, 15 Mar 2019 15:52:19 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id s87so4701881qks.23
        for <linux-mm@kvack.org>; Fri, 15 Mar 2019 12:52:19 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:in-reply-to:message-id
         :mime-version:references:subject:from:to:cc;
        bh=REP9LhKq3azFcE3epBwHjl0z4e4u8qSodB2K6JOUUqY=;
        b=K4T7gHqAzkGs+lUPB3oF4ZJFU7hhkYqUMvwrJRk+RgmgW+YDPFkKoqXlwIL/LM2NU2
         JISL+8TaAw3m9FdhzRKtZfVyE3KHyi0Zg27jrNqbcfR0x8UfBnEQggcTBEs34ydzW2nz
         jiYBrFer/4J8x+xXOuRIKVjR7W30C9VRw9tVUvYARAp/6wAljuHXEIqj0zx+2oHvRg3s
         GPlhN/Qszai+b/Ad0vmojjL/pfa2uIVQ1h731uSrGt9dm3OlB5Jxst5B4wt9x3680viL
         CYgF/ytA/cEi1G/pPvC4Dz/9bm8kMjFjhdZxT0BfFgqEm7pDAej9Jw4JBys0L++OuvkT
         XAlw==
X-Gm-Message-State: APjAAAXCC+eFOWmAzjv/brEn2owFGI0TinnLHDD7UVHcyZuxM4fn0JXb
	ufMo/KYEgZRRMBPgU31U5UKetf4+z6/XJkjp+FcUukEA/WaKz8H0prJzFwQ6iD/wW+/W3Dovu48
	6b09rg8RRcZc7au1vnsq9+az6tVLZF2e4EpPmnAODii2xxdjfwyPK012XR50Tl2XqmQ==
X-Received: by 2002:a0c:b049:: with SMTP id l9mr3986468qvc.16.1552679539686;
        Fri, 15 Mar 2019 12:52:19 -0700 (PDT)
X-Received: by 2002:a0c:b049:: with SMTP id l9mr3986432qvc.16.1552679539016;
        Fri, 15 Mar 2019 12:52:19 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552679539; cv=none;
        d=google.com; s=arc-20160816;
        b=M4qyzZjlRiuqbS4C92YaqGS3Jl83/HnKxT0k8WFqa4GAtSpF+s1kW20ywPY1EVhp+q
         VPq4SY4Zvi/u8/R3RcJt0nfDizpqt0Z7CydIIrWCviJWRsJKUJR0D6p4XuO/7fyNFwhf
         2SUBD2nslRSffE3Xh142uxoglQ//gHvtjKKEcvtx6NcgS7DWJa+IUG26QFG9J5PQUgmx
         JFhSEj/7fJpUzfyfiW6zwEkGn2KMF/BVeniUUxyX8nLkykRxOVPRYMyF2d9jhQkjuL8P
         h9a+65iHdQzUMOBKmecYGfbp7awBCNdsdAhSf7dDqMDHtWnUttfzpkyt91jsOcudvzY5
         SfyA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:references:mime-version:message-id:in-reply-to
         :date:dkim-signature;
        bh=REP9LhKq3azFcE3epBwHjl0z4e4u8qSodB2K6JOUUqY=;
        b=Ob8PHV8noEp4QK2UfeSEI6tI8V1ca5ywuLg+E9Xi9DLXJARQSZ2HXtcsH64I/IMY63
         ollsBUnQllYURBE0ZGXWcPjw+hVU8ZboaolFu+/vFMBZTZpMQJlt2GQj0SM3gh5K1Io0
         874qS5JxUTP3sK52hKnj9UEsqwlMm0w4Yx5Tw/Sy1wxsLVslR6XSF1onMoH89c+AFOC9
         8kpQzrrc9Ur1S0uAD/wbrOGBhuLCy23E0As9t2vLDyCzd36UlJ915oQ7++wpAxF/jmCG
         RNxxLozl0OFePayl0cniOWbeKreM5HWYHvn1LGOBp1dfLOFCBqhErePYEdpdkbBRxg/S
         GDiA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=FNIVGISA;
       spf=pass (google.com: domain of 3cgkmxaokcjev8yczj58g619916z.x97638fi-775gvx5.9c1@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3cgKMXAoKCJEv8yCzJ58G619916z.x97638FI-775Gvx5.9C1@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id f49sor3741804qtf.14.2019.03.15.12.52.18
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 15 Mar 2019 12:52:19 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3cgkmxaokcjev8yczj58g619916z.x97638fi-775gvx5.9c1@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=FNIVGISA;
       spf=pass (google.com: domain of 3cgkmxaokcjev8yczj58g619916z.x97638fi-775gvx5.9c1@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3cgKMXAoKCJEv8yCzJ58G619916z.x97638FI-775Gvx5.9C1@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:in-reply-to:message-id:mime-version:references:subject:from:to
         :cc;
        bh=REP9LhKq3azFcE3epBwHjl0z4e4u8qSodB2K6JOUUqY=;
        b=FNIVGISAdAEFbreSsDDijAXV7iz7bJ+nqAbnQIHGv5JyzeZ7lcBCJx59d3veVulKlh
         7jE3udTRD8ZB4FsTnM9RGbtkCH/mbxzWvFL0H4sXjQx4qi2m5t5ro7oy5rhM45nSVVBP
         5ClTpMIvyiu2q1I0rCYKPmV2nRUW01xZpnfJIxUQMHQ44ykxwcrzRx307eckpZorbuN3
         6VEq4E+w7Q2yQVpjsHzE5SdEEFgZlQL/gXacFSIer7uFwLUhfH2E6+fmsaTjr28zvsU3
         LxduxWE/YJsel6dur8r7Ne5zecAEIXKRCQ6ztsVh51aCO/ECwJBztr37RmWaHcFGyfRo
         FPEA==
X-Google-Smtp-Source: APXvYqwJcWbE90DsufpIchU1RWZDjZYiH/OdYEaqepbyMZK8dYdaYAIDqIiN21SA2dhnlvcWp5RKO708a/U1e0LV
X-Received: by 2002:ac8:2d7c:: with SMTP id o57mr3149114qta.39.1552679538830;
 Fri, 15 Mar 2019 12:52:18 -0700 (PDT)
Date: Fri, 15 Mar 2019 20:51:35 +0100
In-Reply-To: <cover.1552679409.git.andreyknvl@google.com>
Message-Id: <a5fff68a32941ebce02dbe48f554a76a9c7a36ce.1552679409.git.andreyknvl@google.com>
Mime-Version: 1.0
References: <cover.1552679409.git.andreyknvl@google.com>
X-Mailer: git-send-email 2.21.0.360.g471c308f928-goog
Subject: [PATCH v11 11/14] uprobes, arm64: untag user pointers in find_active_uprobe
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
2.21.0.360.g471c308f928-goog

