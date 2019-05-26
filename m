Return-Path: <SRS0=xW7F=T2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_NEOMUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B841AC282E3
	for <linux-mm@archiver.kernel.org>; Sun, 26 May 2019 17:33:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8157520815
	for <linux-mm@archiver.kernel.org>; Sun, 26 May 2019 17:33:38 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8157520815
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linutronix.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0D8B36B0010; Sun, 26 May 2019 13:33:38 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 089C96B0266; Sun, 26 May 2019 13:33:38 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EBB5E6B0269; Sun, 26 May 2019 13:33:37 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id A18E96B0010
	for <linux-mm@kvack.org>; Sun, 26 May 2019 13:33:37 -0400 (EDT)
Received: by mail-wr1-f71.google.com with SMTP id q7so7766402wrw.9
        for <linux-mm@kvack.org>; Sun, 26 May 2019 10:33:37 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:mime-version:content-disposition:user-agent;
        bh=cNwt8jxrbWcE5noyG1OUv2kNpkiSO+S3XqdYDpukk7o=;
        b=Y8s0coZkpbT5buL/XugjDxyv9d8hsj19pOMYGP8Pr3qmpGbDEP1x22AzbUWndqNIRz
         m/+9pWDjwhZAxPl66Owjvok1m70WtnU1qwI2gDvh5484PrQz2TuQQiMkCr6yjEAEQN8z
         MqQpRVQFz2vJTN6QVcuEahrwbBWWfYNUrqZOW11gl3nnbTEVjGurAZUQDXumixItc7jf
         hbkUTOEKWdJ7w6oqvquQ5bnk37BC7hY1r9UjymQ/CuOQ+HlV5eL0TdQdqhUvkSJdqlmh
         qlaKfuo9YYA6U7+89pnumxzquFMnr/SL7oOEgMJ3Yo9mKdxFvGM2hOmE5esOVns87dLt
         su9A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of bigeasy@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=bigeasy@linutronix.de
X-Gm-Message-State: APjAAAU1qkpNiisGbSPanWLL8kNrfcBNmz1BkLBMsBJ/W27QpSy3PGDx
	6O8baGjZqyhsNqaEHP5xshMd9wQkCZ9B+Z8GnJO61yIJrFhHz04KKwRpN0Cm7guP7VR24NN4Khv
	dOU/aVmsH9meYVUNhiQgjBZAbtv+7hc1dJE3BMxpEr1ckZ7PgLUiv9YSR6fX81VR1HA==
X-Received: by 2002:adf:afdf:: with SMTP id y31mr67470226wrd.315.1558892017186;
        Sun, 26 May 2019 10:33:37 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz8Nrxp24MkBfr7uofufb5krUgf21LyE3moG//UGiQiNG3gF8CoK17yl/2v//5rj9KvxuXl
X-Received: by 2002:adf:afdf:: with SMTP id y31mr67470196wrd.315.1558892016247;
        Sun, 26 May 2019 10:33:36 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558892016; cv=none;
        d=google.com; s=arc-20160816;
        b=jb1y6ecfe/sKxw3Aaao0rIrOOAVwwBX+ngrVpc8Zb3y1ybpgvZ0T7qddqmQ/FRzXAp
         Xr0jlybbSoBykSxN9Mvem226pfRLCjDE2MdNY7MdQAmyrIPzZ3lGMFe/88m18ZJbOgNM
         82szx5XvcxawvhhDL3mcz8/tVXLj6vFRZPeuqr2iWIiUHMXo3k2CqAaIE69sfYkZX6xW
         OnFCd7WNuDnZ7qABAdIw0BQPn9ZrULEalbNUk7jGtlUIJWFHHAXgu5yTNmWoaucMfioJ
         sxblpk/nCbCGkuJBI6kTEQ3xXz7cYh6w4b1A9nBCgCn0nT3WTcfXygg69bpiwTR7741Q
         9Zcg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:content-disposition:mime-version:message-id:subject:cc
         :to:from:date;
        bh=cNwt8jxrbWcE5noyG1OUv2kNpkiSO+S3XqdYDpukk7o=;
        b=JDLihM9Q7tpFSERYaWNlG0Q5SRi653Dm1FL9lcEk5LjilzWi6Fd54x+Esbpl+w5Xrf
         Am+IS2RiVAq8RKE4PIsSUyh+IF35EeUFv7t/yZL5FdDv9MH7wVioC2wT0BZ7GjrrFVKn
         VcfyzWKiUJspQV4oureolTw5oPNbdN8W0OsdUfDtviBowXMBMI0RajGsrGaFkZP2myRI
         +7XNfr7PkZZO9lKNLbAf2YxRF1nv/RagetZ+iqFXGhyXvfXdSng9vvT08YjorYUo9pyu
         vAswhApBg/n9WXwcXwS4BW37q9RSQdXpAciG/GIyGZKs/GYM5gxD2DjCX6AVdFDb43hu
         fizQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of bigeasy@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=bigeasy@linutronix.de
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id u11si7639998wrm.317.2019.05.26.10.33.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Sun, 26 May 2019 10:33:36 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of bigeasy@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) client-ip=2a01:7a0:2:106d:700::1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of bigeasy@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=bigeasy@linutronix.de
Received: from bigeasy by Galois.linutronix.de with local (Exim 4.80)
	(envelope-from <bigeasy@linutronix.de>)
	id 1hUx1S-00024Z-LB; Sun, 26 May 2019 19:33:26 +0200
Date: Sun, 26 May 2019 19:33:25 +0200
From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
To: Hugh Dickins <hughd@google.com>, x86@kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Mike Rapoport <rppt@linux.ibm.com>,
	Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, Borislav Petkov <bp@suse.de>,
	Pavel Machek <pavel@ucw.cz>,
	Dave Hansen <dave.hansen@linux.intel.com>
Subject: [PATCH] x86/fpu: Use fault_in_pages_writeable() for pre-faulting
Message-ID: <20190526173325.lpt5qtg7c6rnbql5@linutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
User-Agent: NeoMutt/20180716
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Hugh Dickins <hughd@google.com>

Since commit

   d9c9ce34ed5c8 ("x86/fpu: Fault-in user stack if copy_fpstate_to_sigframe() fails")

we use get_user_pages_unlocked() to pre-faulting user's memory if a
write generates a page fault while the handler is disabled.
This works in general and uncovered a bug as reported by Mike Rapoport.

It has been pointed out that this function may be fragile and a
simple pre-fault as in fault_in_pages_writeable() would be a better
solution. Better as in taste and simplicity: That write (as performed by
the alternative function) performs exactly the same faulting of memory
that we had before. This was suggested by Hugh Dickins and Andrew
Morton.

Use fault_in_pages_writeable() for pre-faulting of user's stack.

Suggested-by: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Hugh Dickins <hughd@google.com>
Link: https://lkml.kernel.org/r/alpine.LSU.2.11.1905251033230.1112@eggly.anvils
[bigeasy: patch description]
Signed-off-by: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
---
 arch/x86/kernel/fpu/signal.c | 11 ++---------
 1 file changed, 2 insertions(+), 9 deletions(-)

diff --git a/arch/x86/kernel/fpu/signal.c b/arch/x86/kernel/fpu/signal.c
index 5a8d118bc423e..060d6188b4533 100644
--- a/arch/x86/kernel/fpu/signal.c
+++ b/arch/x86/kernel/fpu/signal.c
@@ -5,6 +5,7 @@
 
 #include <linux/compat.h>
 #include <linux/cpu.h>
+#include <linux/pagemap.h>
 
 #include <asm/fpu/internal.h>
 #include <asm/fpu/signal.h>
@@ -189,15 +190,7 @@ int copy_fpstate_to_sigframe(void __user *buf, void __user *buf_fx, int size)
 	fpregs_unlock();
 
 	if (ret) {
-		int aligned_size;
-		int nr_pages;
-
-		aligned_size = offset_in_page(buf_fx) + fpu_user_xstate_size;
-		nr_pages = DIV_ROUND_UP(aligned_size, PAGE_SIZE);
-
-		ret = get_user_pages_unlocked((unsigned long)buf_fx, nr_pages,
-					      NULL, FOLL_WRITE);
-		if (ret == nr_pages)
+		if (!fault_in_pages_writeable(buf_fx, fpu_user_xstate_size))
 			goto retry;
 		return -EFAULT;
 	}
-- 
2.20.1

