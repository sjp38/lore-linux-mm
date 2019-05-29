Return-Path: <SRS0=FSMz=T5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_NEOMUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C74C3C04AB3
	for <linux-mm@archiver.kernel.org>; Wed, 29 May 2019 07:25:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 95BAC208CB
	for <linux-mm@archiver.kernel.org>; Wed, 29 May 2019 07:25:50 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 95BAC208CB
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linutronix.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3E0DF6B026D; Wed, 29 May 2019 03:25:50 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 38EC26B026E; Wed, 29 May 2019 03:25:50 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 27F746B0270; Wed, 29 May 2019 03:25:50 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f69.google.com (mail-wm1-f69.google.com [209.85.128.69])
	by kanga.kvack.org (Postfix) with ESMTP id D02856B026D
	for <linux-mm@kvack.org>; Wed, 29 May 2019 03:25:49 -0400 (EDT)
Received: by mail-wm1-f69.google.com with SMTP id 20so653194wma.2
        for <linux-mm@kvack.org>; Wed, 29 May 2019 00:25:49 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=bomsryVb7O/EfEAtrXt07PzTGwnGlwCL33oL4IAcx5I=;
        b=smIfBvEl/7xjqlXg8k1eh9OJP93VTj10ornu3qSz7zJa754a2nM3qgsRt6F6vIvF+y
         rQCwRzDLyBdebtzT2BO+CcPIU5kF9DPrND4LBW5797VCz+F2ID6pbOSQCLLsFmxbiO1x
         6YPIg/L/yg0woVk++0zxmSXV4pe/XeG6ZzBOGvJFI71NAweC7T2XRb/a/r79hG4eG/51
         NRB5zc7SvzeuUvKIGa31k9WM5zFCKOGnEu5MjQRVYV25Q6pQXUIDup6/AMQonqTbz+Sm
         1/otcmv4j+s65n9FKJ5nYf/AbNCcC1xOLLkT318lb2PNIky21L98YvFXzdZeMrsQE+bl
         Chvg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of bigeasy@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=bigeasy@linutronix.de
X-Gm-Message-State: APjAAAX7TNiXLrEuVjz1rlcdZBhgs6SJh7dX+pkKoGCLIaPRBJoCLdUj
	a+y1W7Upoffk0hAhl2Gc3Vszcv3xi4cfjKGZu8CNAAU9wO4HIzQNIwxMRVML+btQKMDdQvvFpvH
	3AVbNabCMDij1FPRSqLuNuEY6q0igx6LWxAyIxfeNRJc38cvtviK+xDZuqk4wVKG1VQ==
X-Received: by 2002:a7b:c344:: with SMTP id l4mr5664747wmj.25.1559114749375;
        Wed, 29 May 2019 00:25:49 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx5Hf9ddfgdVr8UXBOdqZHxGnpVHzont+NThK7hLxYew2LePwn+zJRlrWfE/D4ogxjHFrFA
X-Received: by 2002:a7b:c344:: with SMTP id l4mr5664700wmj.25.1559114748343;
        Wed, 29 May 2019 00:25:48 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559114748; cv=none;
        d=google.com; s=arc-20160816;
        b=zGfJvO87BfbkYXLdz3D5viTU09KfR1SayzknYfhin9x7OkX4qcCMCsdneTJyPgsMwO
         DZFDH/Sofwlsm+8i9z6labLGAzyUh/LBHZonLfWQuyVq27DQUEJWpzNrOYKd5gMMomDn
         A5lLOD0Z24mh9vbYa61SKQX4tU+Y+fII4Si0iCEtZopjVHKSsiWU93ufnm6wZnC1moBP
         pPRna2UpKlc9FMo59cFDOMa+Exy9cICBwbEeVrJu+gQ/883+kPkQWEF8h1SVw7gkeTj1
         cliGO56EkZJhtysA2LmSuTwtpXJEHQZ8CJId3EJoc1ZOh+Dma5TvRJt/+6/kPB3Rfj1p
         6v4w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=bomsryVb7O/EfEAtrXt07PzTGwnGlwCL33oL4IAcx5I=;
        b=uoVxqZCgBwUTJaJgeQfPflyeNJUxjTef6gCAy4XjG5Bc/l8HwZbG+RZCqrnVKNa8Zf
         fvzHoVcqK/jdKDMlWG3BxBJage//H09x2amoZYusWUDRtYWOfkAaSlAlq1W3REPS52se
         m+W/ZB7Tx7cz4xf7yE8YYJTRA86vLLqA2eEr/OvuO5QagTtWHX5VasB69pUGShrRv15i
         +cRdvPy2XKzyMaP3wBhzHa47+gxB1VzHclgWmKUlawHpA51Vci+086S76L2GwFdtvGJ6
         27O6C7YLSlLo7u5WEcvVgEF0U9I+FX2bBEESXVV+FPukNRwJbZ2gfWdAk2DMZQD3f5Vm
         SAWQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of bigeasy@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=bigeasy@linutronix.de
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id x23si2893705wrd.77.2019.05.29.00.25.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Wed, 29 May 2019 00:25:48 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of bigeasy@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) client-ip=2a01:7a0:2:106d:700::1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of bigeasy@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=bigeasy@linutronix.de
Received: from bigeasy by Galois.linutronix.de with local (Exim 4.80)
	(envelope-from <bigeasy@linutronix.de>)
	id 1hVsxw-0002SA-HC; Wed, 29 May 2019 09:25:40 +0200
Date: Wed, 29 May 2019 09:25:40 +0200
From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Hugh Dickins <hughd@google.com>, x86@kernel.org,
	Mike Rapoport <rppt@linux.ibm.com>,
	Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, Borislav Petkov <bp@suse.de>,
	Pavel Machek <pavel@ucw.cz>,
	Dave Hansen <dave.hansen@linux.intel.com>
Subject: [PATCH v2] x86/fpu: Use fault_in_pages_writeable() for pre-faulting
Message-ID: <20190529072540.g46j4kfeae37a3iu@linutronix.de>
References: <20190526173325.lpt5qtg7c6rnbql5@linutronix.de>
 <20190528211826.0fa593de5f2c7480357d3ca5@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable
In-Reply-To: <20190528211826.0fa593de5f2c7480357d3ca5@linux-foundation.org>
User-Agent: NeoMutt/20180716
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

=46rom: Hugh Dickins <hughd@google.com>

Since commit

   d9c9ce34ed5c8 ("x86/fpu: Fault-in user stack if copy_fpstate_to_sigframe=
() fails")

we use get_user_pages_unlocked() to pre-faulting user's memory if a
write generates a pagefault while the handler is disabled.
This works in general and uncovered a bug as reported by Mike Rapoport.
It has been pointed out that this function may be fragile and a
simple pre-fault as in fault_in_pages_writeable() would be a better
solution. Better as in taste and simplicity: That write (as performed by
the alternative function) performs exactly the same faulting of memory
that we had before. This was suggested by Hugh Dickins and Andrew
Morton.

Use fault_in_pages_writeable() for pre-faulting of user's stack.

Fixes: d9c9ce34ed5c8 ("x86/fpu: Fault-in user stack if copy_fpstate_to_sigf=
rame() fails")
Suggested-by: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Hugh Dickins <hughd@google.com>
[bigeasy: patch description]
Signed-off-by: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
---
v1=E2=80=A6v2: Added a Fixes tag.

 arch/x86/kernel/fpu/signal.c | 11 ++---------
 1 file changed, 2 insertions(+), 9 deletions(-)

diff --git a/arch/x86/kernel/fpu/signal.c b/arch/x86/kernel/fpu/signal.c
index 5a8d118bc423e..060d6188b4533 100644
--- a/arch/x86/kernel/fpu/signal.c
+++ b/arch/x86/kernel/fpu/signal.c
@@ -5,6 +5,7 @@
=20
 #include <linux/compat.h>
 #include <linux/cpu.h>
+#include <linux/pagemap.h>
=20
 #include <asm/fpu/internal.h>
 #include <asm/fpu/signal.h>
@@ -189,15 +190,7 @@ int copy_fpstate_to_sigframe(void __user *buf, void __=
user *buf_fx, int size)
 	fpregs_unlock();
=20
 	if (ret) {
-		int aligned_size;
-		int nr_pages;
-
-		aligned_size =3D offset_in_page(buf_fx) + fpu_user_xstate_size;
-		nr_pages =3D DIV_ROUND_UP(aligned_size, PAGE_SIZE);
-
-		ret =3D get_user_pages_unlocked((unsigned long)buf_fx, nr_pages,
-					      NULL, FOLL_WRITE);
-		if (ret =3D=3D nr_pages)
+		if (!fault_in_pages_writeable(buf_fx, fpu_user_xstate_size))
 			goto retry;
 		return -EFAULT;
 	}
--=20
2.20.1

