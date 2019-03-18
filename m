Return-Path: <SRS0=xdO8=RV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT,USER_IN_DEF_DKIM_WL
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E7F91C4360F
	for <linux-mm@archiver.kernel.org>; Mon, 18 Mar 2019 17:18:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8F800217D8
	for <linux-mm@archiver.kernel.org>; Mon, 18 Mar 2019 17:18:15 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="YFFN0pzA"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8F800217D8
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 972A76B000E; Mon, 18 Mar 2019 13:18:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8AF286B0010; Mon, 18 Mar 2019 13:18:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6FD196B0266; Mon, 18 Mar 2019 13:18:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 25B796B000E
	for <linux-mm@kvack.org>; Mon, 18 Mar 2019 13:18:12 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id a72so19765632pfj.19
        for <linux-mm@kvack.org>; Mon, 18 Mar 2019 10:18:12 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:in-reply-to:message-id
         :mime-version:references:subject:from:to:cc;
        bh=MRHHZYm6qbbddi64ikktRuAjn8BoXK8Gf7bv/2tC2r0=;
        b=mipMEP5NyeXusJBg5RWWFyul6bfxd+WHfZ/kRV9PVC/tr2im2lv0NxBQ63iHdeYMdq
         MPl0CMSKFbhB1R14y1BMY+DPEjtNfAcW4sKsRoLA6F6+sjDjqGwXq0Z3yI/CNof27pCM
         YbseLsby6rz/Z2QJKylTaXrwaQazi/Wbgh4cjA3Os2uKU0ohy45Czke8o4KerghNoSOR
         tD97LOAYMMhTpyBvGQNF+EfNvhFjz+fM8RwMQyUWaMrZ5P6CmvCjSlGD775vX2VPct2s
         W7mkhfewLQ0BGU/BEPqX9hmpbyEABHgAODAjZZak09qd/eiosAghrFd2ftiIYlDtCVn/
         fQdA==
X-Gm-Message-State: APjAAAXPclQ3n9pBvdl9+vBazONo1w3UIZLdYm++spJJHzvqZWI1DFzv
	KkjtKKz5jaa28irfP9071ePGs8MkIa3T8QpIJDg62Le3o/rQSJZnnn2kcMqdV5SyK+B1OB6gao7
	IgPsCKrhlbzynYUMyg4DcSX1E4oZ5w7r30Sy7+uRTGi2ChEs6em7e+chgjzmFHqV6jw==
X-Received: by 2002:a17:902:8b82:: with SMTP id ay2mr20653829plb.64.1552929491812;
        Mon, 18 Mar 2019 10:18:11 -0700 (PDT)
X-Received: by 2002:a17:902:8b82:: with SMTP id ay2mr20653770plb.64.1552929490962;
        Mon, 18 Mar 2019 10:18:10 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552929490; cv=none;
        d=google.com; s=arc-20160816;
        b=rXF+htV+2Weujd3qHatNgMiYfRokVB9mBnMLe4fY/EXedIVkorz5qZxyZ+odD8IEmc
         NY6XLz0MT/8jN2RzhuHOlNBwu9BLajVIAkkhqji7M2fgNCKiH6rXBB8n48YraBc1cJnT
         Tn2AZKFamt12xKcYZL+VKcxJ7GEO22aM0BvYgePfP5WADhTemidEvFw7nHPjnhCOsvDH
         bkk0bOD2q/0Hs1d+yGBHRk5OoyWVb9zNdc3Ou4+SBF25ZGMyhIJ17RtpWEHFh/nq/pYB
         FzHKs2ZgR8aJMVb89uTylTtkWjgsydcmANowMrj0NwYLiCbDOnmzPJYPZUk+ivNWve53
         pTYA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:references:mime-version:message-id:in-reply-to
         :date:dkim-signature;
        bh=MRHHZYm6qbbddi64ikktRuAjn8BoXK8Gf7bv/2tC2r0=;
        b=HRL2SQXvrxQRtAOabN++T2oUDa/e4MAuHDXZNg3SjY/1RwIkRLdQvNHjsd4O005rQV
         tpzh5q5PU17NEyOKIIRP3f0mwWZMkJoH8Kq7CQrKEdSzIRdCMZtHFJonLfTleaiR4yid
         9mfiQMOqiRtX5ZmY8u0Lvb97Uhe90mnbmNL4QLgPBYSUZfOrcNUsDX6aX3C4B1PmTocU
         l9Uzu6NUwKoDBGNTnqaJCO7FyUg2LDuFIAFJPi2zZhAEdk85G1YY49Fbyh5jIl8Df42e
         eK+df0huAYYH34mMF0wBYPn0Z/VAZat2IGMOSc1NYUDkAL/hXQsUixOfFleClxlZSVNm
         KhcA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=YFFN0pzA;
       spf=pass (google.com: domain of 30tkpxaokckeboesfzlowmhpphmf.dpnmjovy-nnlwbdl.psh@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=30tKPXAoKCKEBOESFZLOWMHPPHMF.DPNMJOVY-NNLWBDL.PSH@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id k190sor16468590pgc.32.2019.03.18.10.18.10
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 18 Mar 2019 10:18:10 -0700 (PDT)
Received-SPF: pass (google.com: domain of 30tkpxaokckeboesfzlowmhpphmf.dpnmjovy-nnlwbdl.psh@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=YFFN0pzA;
       spf=pass (google.com: domain of 30tkpxaokckeboesfzlowmhpphmf.dpnmjovy-nnlwbdl.psh@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=30tKPXAoKCKEBOESFZLOWMHPPHMF.DPNMJOVY-NNLWBDL.PSH@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:in-reply-to:message-id:mime-version:references:subject:from:to
         :cc;
        bh=MRHHZYm6qbbddi64ikktRuAjn8BoXK8Gf7bv/2tC2r0=;
        b=YFFN0pzAH8aZKTAjwEnRibFpDgHMBLVgE+Y/H6BldyMJfISdxeV4TieTiwWBUf4++h
         5qPE8agzsmBOu94H7aWR8TKMxJHOgpBxp+05T//MmjQV6X0IOo3LoMT6g453xDS32JNL
         uEO1aHTq8Rnk2u7skv3uFK7PlcfyAPVOgEppwAZwtzGwNkP4ro6UBD/uLtdfnq9xy7XW
         XO0COxSTv1Jmnv80OnZ2/0dsLvQrl7sHFJMan50DHp20r8EaWagDzYNNog4tZOIZ3oMY
         w/ooiTzJSI12lW99h0KIupXV6luZppWPt/ReHe66F1061arfZzk+YHF0fBmf1FEO1sRB
         IxuA==
X-Google-Smtp-Source: APXvYqwaXHvEHlP/j2S09wr/+VgOKvwauhGMa/tD/zVNDmmjkYJkKZn9iKzY6FKhtrC83z5lWNUQLgPCNgcfil0L
X-Received: by 2002:a63:4964:: with SMTP id y36mr7052420pgk.60.1552929490581;
 Mon, 18 Mar 2019 10:18:10 -0700 (PDT)
Date: Mon, 18 Mar 2019 18:17:39 +0100
In-Reply-To: <cover.1552929301.git.andreyknvl@google.com>
Message-Id: <4368bfa2a799442392ee9582dd1cccb8c96e524d.1552929301.git.andreyknvl@google.com>
Mime-Version: 1.0
References: <cover.1552929301.git.andreyknvl@google.com>
X-Mailer: git-send-email 2.21.0.225.g810b269d1ac-goog
Subject: [PATCH v12 07/13] fs, arm64: untag user pointers in fs/userfaultfd.c
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

userfaultfd_register() and userfaultfd_unregister() use provided user
pointers for vma lookups, which can only by done with untagged pointers.

Untag user pointers in these functions.

Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
---
 fs/userfaultfd.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/fs/userfaultfd.c b/fs/userfaultfd.c
index 89800fc7dc9d..a3b70e0d9756 100644
--- a/fs/userfaultfd.c
+++ b/fs/userfaultfd.c
@@ -1320,6 +1320,9 @@ static int userfaultfd_register(struct userfaultfd_ctx *ctx,
 		goto out;
 	}
 
+	uffdio_register.range.start =
+		untagged_addr(uffdio_register.range.start);
+
 	ret = validate_range(mm, uffdio_register.range.start,
 			     uffdio_register.range.len);
 	if (ret)
@@ -1507,6 +1510,8 @@ static int userfaultfd_unregister(struct userfaultfd_ctx *ctx,
 	if (copy_from_user(&uffdio_unregister, buf, sizeof(uffdio_unregister)))
 		goto out;
 
+	uffdio_unregister.start = untagged_addr(uffdio_unregister.start);
+
 	ret = validate_range(mm, uffdio_unregister.start,
 			     uffdio_unregister.len);
 	if (ret)
-- 
2.21.0.225.g810b269d1ac-goog

