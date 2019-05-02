Return-Path: <SRS0=Mdb/=TC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_NEOMUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B571DC43219
	for <linux-mm@archiver.kernel.org>; Thu,  2 May 2019 17:11:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 71A7A20675
	for <linux-mm@archiver.kernel.org>; Thu,  2 May 2019 17:11:50 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 71A7A20675
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linutronix.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F30376B0003; Thu,  2 May 2019 13:11:49 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EE17E6B0006; Thu,  2 May 2019 13:11:49 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D80AD6B000A; Thu,  2 May 2019 13:11:49 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id 8A2AF6B0003
	for <linux-mm@kvack.org>; Thu,  2 May 2019 13:11:49 -0400 (EDT)
Received: by mail-wr1-f69.google.com with SMTP id v5so3043926wrn.6
        for <linux-mm@kvack.org>; Thu, 02 May 2019 10:11:49 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=rAk5cBq/QAsdFPry30AYrJc0JoiMu33+oLDmyvDOIGU=;
        b=pDBPOaJl3VcVo24AIzB669cjqIlbW10FVEHvAEkI72sMTV67lQGqqtJW30jgcNHt61
         fmlN27QYyR7pYC9ctibJyTH92qX1/YwcIgeba3JEEVF1ajsr+h4nRzy9HOJ5AUouSAoo
         byTIS9LYaRYfsDda6tETUU7h8tnq2NGddWG4mWKQEwnd38vNKz5kFoepehtdefUe0SMi
         Nq35r0UCIm9PjZjY6ZMS9aC6OGk+C+ND4xvQJHEPLU0qLBGYN2sEMzhGQY5xE9MoInG0
         tjxjGNrGepJjffC3XH2vl1kcdp7EOPgX+TC7Oae6nNz1JZ51DZ05yL9PkFwp80K0jbL8
         J/zA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of bigeasy@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=bigeasy@linutronix.de
X-Gm-Message-State: APjAAAU/8FcUpDc/SYwNv46ZMFqQWcGuHiL0e32XM04hhOOd1qMJoEjJ
	4o5lvfmGD/F9w47HRtBtRme1wc7+5vPiefD5QbYfK2lauoqzyIxxtrCSJCVp6HsiQDyCPLhDfuM
	ZL06TNW7uaaUTLC2HmDcIWzhIk6gmD/uxtUWTFoQIa8U76+FcPtrpMeF33zKn3txgMA==
X-Received: by 2002:a1c:eb07:: with SMTP id j7mr3095999wmh.138.1556817108920;
        Thu, 02 May 2019 10:11:48 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwkf9EEo3l9n9A/ZR+iYVns/4r/P6FQjyvoJCLMmBpu7MKCdQ8DO8M2KAr4nHHRRbFr8RWo
X-Received: by 2002:a1c:eb07:: with SMTP id j7mr3095942wmh.138.1556817107778;
        Thu, 02 May 2019 10:11:47 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556817107; cv=none;
        d=google.com; s=arc-20160816;
        b=ygp0sMMEfHfAeaL5iFAYo9ICX1gwWOb8MRZ7ww7gocFjGNNUFRhXBZGoQ6drGmAVEO
         b+H1YE2G4aqq4YzjX18Jx6fNBD+0VRvW6qWkCA18clT6zZ8O8Da+fH/PXhn0vhNE1RpJ
         wbkbiyP43m5PTG+d6865ivwKPwMkIPTKgUtFV/k+Of49RKs6EkkADd7uwYVOxFGApQy5
         62b4vfAy+S2FtcWgm8yRfqGuuTZSxZIoaPw0yIMzAlY8Tnir4IioCSGbDv/V0GTvkFoA
         fYvO/zAaNN501RMjVKQjL2BMtEDtMQgH4ddod/qsHPpbmFQgsdU6XW8fzF5Vb/LxBbW4
         VQmA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=rAk5cBq/QAsdFPry30AYrJc0JoiMu33+oLDmyvDOIGU=;
        b=0pvyD/t6c3sYbQEQtATvxNMa+A2qSuT2a/vRlTUVOG7IgV+Z2aiWCnX9wYoMEv2++s
         msqyeQdjB1JIgH96IdML2S7+RV3+04OqIu0egQjdQM1HBq+HXbB+Wj0y23p8IagmbxFa
         4oaFh4gINeSEiEQQFLaVEeyal2nxPhx99wKthHIICAZamDLbUcGYPIn5tOOjWz4ob/Gv
         daZkGih6DjFPQcrouWMsUFTFG+FWclqtnNCOuakSC7EdNTEZWcwjGY/ZST6RQrTMzxjy
         0v07gAjN+j7tebIMLgRk7Zw5LkaSrVot93R1Mpb3/pX6KM2CGieuGHuku+zJvlJ2+t1H
         C89A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of bigeasy@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=bigeasy@linutronix.de
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id n184si4625958wma.141.2019.05.02.10.11.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Thu, 02 May 2019 10:11:47 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of bigeasy@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) client-ip=2a01:7a0:2:106d:700::1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of bigeasy@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=bigeasy@linutronix.de
Received: from bigeasy by Galois.linutronix.de with local (Exim 4.80)
	(envelope-from <bigeasy@linutronix.de>)
	id 1hMFFD-0005XZ-Os; Thu, 02 May 2019 19:11:39 +0200
Date: Thu, 2 May 2019 19:11:39 +0200
From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
To: Borislav Petkov <bp@alien8.de>
Cc: Qian Cai <cai@lca.pw>, dave.hansen@intel.com, tglx@linutronix.de,
	x86@kernel.org, "linux-mm@kvack.org" <linux-mm@kvack.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	luto@amacapital.net, hpa@zytor.com, mingo@kernel.org
Subject: [PATCH v2] x86/fpu: Fault-in user stack if
 copy_fpstate_to_sigframe() fails
Message-ID: <20190502171139.mqtegctsg35cir2e@linutronix.de>
References: <1556657902.6132.13.camel@lca.pw>
 <20190501082312.GA3908@zn.tnic>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable
In-Reply-To: <20190501082312.GA3908@zn.tnic>
User-Agent: NeoMutt/20180716
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

In the compacted form, XSAVES may save only the XMM+SSE state but skip
FP (x87 state).

This is denoted by header->xfeatures =3D 6. The fastpath
(copy_fpregs_to_sigframe()) does that but _also_ initialises the FP
state (cwd to 0x37f, mxcsr as we do, remaining fields to 0).

The slowpath (copy_xstate_to_user()) leaves most of the FP
state untouched. Only mxcsr and mxcsr_flags are set due to
xfeatures_mxcsr_quirk(). Now that XFEATURE_MASK_FP is set
unconditionally, see

  04944b793e18 ("x86: xsave: set FP, SSE bits in the xsave header in the us=
er sigcontext"),

on return from the signal, random garbage is loaded as the FP state.

Instead of utilizing copy_xstate_to_user(), fault-in the user memory
and retry the fast path. Ideally, the fast path succeeds on the second
attempt but may be retried again if the memory is swapped out due
to memory pressure. If the user memory can not be faulted-in then
get_user_pages() returns an error so we don't loop forever.

Fault in memory via get_user_pages_unlocked() so
copy_fpregs_to_sigframe() succeeds without a fault.

Fixes: 69277c98f5eef ("x86/fpu: Always store the registers in copy_fpstate_=
to_sigframe()")
Reported-by: Kurt Kanzenbach <kurt.kanzenbach@linutronix.de>
Suggested-by: Dave Hansen <dave.hansen@intel.com>
Signed-off-by: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
---
v1=E2=80=A6v2:
   - s/get_user_pages()/get_user_pages_unlocked()/
   - merge cleanups

I'm posting this all-in-one fix up replacing the original patch so we
don't have a merge window with known bugs (that is the one that the
patch was going the fix and the KASAN fallout that it introduced).

 arch/x86/kernel/fpu/signal.c | 31 +++++++++++++++----------------
 1 file changed, 15 insertions(+), 16 deletions(-)

diff --git a/arch/x86/kernel/fpu/signal.c b/arch/x86/kernel/fpu/signal.c
index 7026f1c4e5e30..5a8d118bc423e 100644
--- a/arch/x86/kernel/fpu/signal.c
+++ b/arch/x86/kernel/fpu/signal.c
@@ -157,11 +157,9 @@ static inline int copy_fpregs_to_sigframe(struct xregs=
_state __user *buf)
  */
 int copy_fpstate_to_sigframe(void __user *buf, void __user *buf_fx, int si=
ze)
 {
-	struct fpu *fpu =3D &current->thread.fpu;
-	struct xregs_state *xsave =3D &fpu->state.xsave;
 	struct task_struct *tsk =3D current;
 	int ia32_fxstate =3D (buf !=3D buf_fx);
-	int ret =3D -EFAULT;
+	int ret;
=20
 	ia32_fxstate &=3D (IS_ENABLED(CONFIG_X86_32) ||
 			 IS_ENABLED(CONFIG_IA32_EMULATION));
@@ -174,11 +172,12 @@ int copy_fpstate_to_sigframe(void __user *buf, void _=
_user *buf_fx, int size)
 			sizeof(struct user_i387_ia32_struct), NULL,
 			(struct _fpstate_32 __user *) buf) ? -1 : 1;
=20
+retry:
 	/*
 	 * Load the FPU registers if they are not valid for the current task.
 	 * With a valid FPU state we can attempt to save the state directly to
-	 * userland's stack frame which will likely succeed. If it does not, do
-	 * the slowpath.
+	 * userland's stack frame which will likely succeed. If it does not,
+	 * resolve the fault in the user memory and try again.
 	 */
 	fpregs_lock();
 	if (test_thread_flag(TIF_NEED_FPU_LOAD))
@@ -187,20 +186,20 @@ int copy_fpstate_to_sigframe(void __user *buf, void _=
_user *buf_fx, int size)
 	pagefault_disable();
 	ret =3D copy_fpregs_to_sigframe(buf_fx);
 	pagefault_enable();
-	if (ret && !test_thread_flag(TIF_NEED_FPU_LOAD))
-		copy_fpregs_to_fpstate(fpu);
-	set_thread_flag(TIF_NEED_FPU_LOAD);
 	fpregs_unlock();
=20
 	if (ret) {
-		if (using_compacted_format()) {
-			if (copy_xstate_to_user(buf_fx, xsave, 0, size))
-				return -1;
-		} else {
-			fpstate_sanitize_xstate(fpu);
-			if (__copy_to_user(buf_fx, xsave, fpu_user_xstate_size))
-				return -1;
-		}
+		int aligned_size;
+		int nr_pages;
+
+		aligned_size =3D offset_in_page(buf_fx) + fpu_user_xstate_size;
+		nr_pages =3D DIV_ROUND_UP(aligned_size, PAGE_SIZE);
+
+		ret =3D get_user_pages_unlocked((unsigned long)buf_fx, nr_pages,
+					      NULL, FOLL_WRITE);
+		if (ret =3D=3D nr_pages)
+			goto retry;
+		return -EFAULT;
 	}
=20
 	/* Save the fsave header for the 32-bit frames. */
--=20
2.20.1

