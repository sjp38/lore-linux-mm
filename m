Return-Path: <SRS0=4tVm=QS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 97974C282CE
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 22:47:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 51A832184E
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 22:47:57 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="2qTB9vzR"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 51A832184E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DE2F68E0183; Mon, 11 Feb 2019 17:47:56 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D6AB48E017F; Mon, 11 Feb 2019 17:47:56 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C0E348E0183; Mon, 11 Feb 2019 17:47:56 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 7C5BB8E017F
	for <linux-mm@kvack.org>; Mon, 11 Feb 2019 17:47:56 -0500 (EST)
Received: by mail-pg1-f199.google.com with SMTP id a2so447108pgt.11
        for <linux-mm@kvack.org>; Mon, 11 Feb 2019 14:47:56 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc
         :content-transfer-encoding;
        bh=VRgylvso3wvLBxYwgnVabpgJiWcttv3vvFjEQ4WQtSk=;
        b=lvAyk66QE3tv2rdFFidPM6IvXl8idyuoGj+MW+Wdu9aA6AzGnuLxn6ApZdqjniAmfJ
         0eVOX7HB8vUqTqd7jA+0cG0w/TTVKZ7yZJ5cTLVoTwTrDxkDaRdRGNU6OH6pSl3sDwi8
         e8tDCW1jghFTvEiUOY5DN57pkmVZM5nOv4cUc1cRJSJfRZtarAZM8w+o389l6NtrYnBk
         2hDAPNoC8kjQea5Q4H0sVtLifSNhjUdHmCU8qou5qt+Nq7J5/bif7MYex5bzgpAFBbTb
         lCzAGH6MXDc6jxEoDfsj6fx19iP3cx+9czjHD1+5YdcAC0fd2RE6v02D820MjqUlUpLm
         emww==
X-Gm-Message-State: AHQUAuYC/IlXC1FBy7YpRA3PyQuAYjabcrJPJIyM1En8r4PgFsihp5yn
	P6mnKPtGgr+c82oHuOD2YJHSUFiggSnGy+VWE925e1z9AQS7m/OA4apmKtZk0ohSxOk2byJdb6J
	03+R/l0qYKAc3SKYxeBc9m0efc/Dpc9JuMoHbp2ipK8PNt/4VuyVQ4P6HsrQbelns3w==
X-Received: by 2002:a17:902:22f:: with SMTP id 44mr634704plc.137.1549925276111;
        Mon, 11 Feb 2019 14:47:56 -0800 (PST)
X-Google-Smtp-Source: AHgI3IaqieC8FgJNm8hWi3loDsd+hA0A32EhgfzQez6XyOBEUBWELW19KevvlFPQ//mGzHuA+zCw
X-Received: by 2002:a17:902:22f:: with SMTP id 44mr634632plc.137.1549925274925;
        Mon, 11 Feb 2019 14:47:54 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549925274; cv=none;
        d=google.com; s=arc-20160816;
        b=NobIvjAmAgLBR8X9inOtX20apNcm8QOmDkH8Br26Uta+lFslz8Z1paE8QVuH2K/zRV
         GB++oNXdVqb5wd9lXLhsWAQFtBs10gZbDsGfwkL/6hnLWToijKczHRsoZhzAkOJ7Wp5S
         En8LRHtHG1dLWyoTZJ0dSrZnMPcIdxkScajC1h+PG40C52jdfyXQTlZccdDCuCKGJJ9V
         A1s1Dkd6hgiO0aMNJ6ZrjGhe6IhbmmotW5j7maivJLOtp2Oeh4HL4AN6Zcwl291eWZDS
         2QdVTRE+u4JKuv1usMRyb1yXylvkGebWQEXL8epmPxfL77x3L5Lgx1ZqoOCQo/yfjCnz
         YBHA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=VRgylvso3wvLBxYwgnVabpgJiWcttv3vvFjEQ4WQtSk=;
        b=oaC3SmQ2tBAdkoGHbi3AtnDTtl81T4JOuRj1ZFG/dG5QDhr4dsh0B8T/pGCcToRT0p
         gwmMieJ5bmGRDmjc0QUx6fiw4IFpa7TR413k3cC+atOqDtTR/+zIWiQk2UuPacRAv6vJ
         pPKONdw8qxxCeXhMPcB4sKiq/vX6zuK3SJgxcwmTEj5aHg3mwI8EuZ/ir6MhYBgcwO/y
         FfVZyn07C78Xv0xYYgykiZsu3cPJZm6nFwpw+fplUkUfzXB/IjJCtrwbL7sec0FpJU/Z
         YAsMO/IlLRR14w11qLMsQ3kOJG/EBF8wO8cprWSOohVXyQLGDCxueLssGedWPAZwiwcp
         QTwQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=2qTB9vzR;
       spf=pass (google.com: domain of luto@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=luto@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id s136si10173234pgs.277.2019.02.11.14.47.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Feb 2019 14:47:54 -0800 (PST)
Received-SPF: pass (google.com: domain of luto@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=2qTB9vzR;
       spf=pass (google.com: domain of luto@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=luto@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-wm1-f47.google.com (mail-wm1-f47.google.com [209.85.128.47])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 5054A2186A
	for <linux-mm@kvack.org>; Mon, 11 Feb 2019 22:47:54 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1549925274;
	bh=rV440hGDSZ3wXtwBOPW52PZyuO31p4qEHmRDqv7v/C0=;
	h=References:In-Reply-To:From:Date:Subject:To:Cc:From;
	b=2qTB9vzRMdPY0stzJ7/VKb/Y1Z1BstTZsqOtQo7ivCGfDJ8FmzkIxv43/rrWP4x3F
	 yste5X5BVJeQIUceUmQ9K+mMQJ+St7Ye69qYVRSCNvV1Mc1QlgRp/BxHOMZ/iDkSXc
	 xCzKOmorFsxK6wArhlpHajpEWC36AB/b12KduuZk=
Received: by mail-wm1-f47.google.com with SMTP id f16so946109wmh.4
        for <linux-mm@kvack.org>; Mon, 11 Feb 2019 14:47:54 -0800 (PST)
X-Received: by 2002:a7b:cc13:: with SMTP id f19mr353124wmh.83.1549925272767;
 Mon, 11 Feb 2019 14:47:52 -0800 (PST)
MIME-Version: 1.0
References: <20190129003422.9328-1-rick.p.edgecombe@intel.com>
 <20190129003422.9328-6-rick.p.edgecombe@intel.com> <162C6C29-CD81-46FE-9A54-6ED05A93A9CB@gmail.com>
 <00649AE8-69C0-4CD2-A916-B8C8F0F5DAC3@amacapital.net> <6FE10C97-25FF-4E99-A96A-465CBACA935B@gmail.com>
 <CALCETrVaBaorbOA8QE=Pk=C+PfXZAz0-aX_3O8Y=nJV4QKELbw@mail.gmail.com> <3EA322C6-5645-4900-AEC6-97FC05716F75@gmail.com>
In-Reply-To: <3EA322C6-5645-4900-AEC6-97FC05716F75@gmail.com>
From: Andy Lutomirski <luto@kernel.org>
Date: Mon, 11 Feb 2019 14:47:39 -0800
X-Gmail-Original-Message-ID: <CALCETrXE0n4BrkX2ZLDJjdLqD-N_WwSZHt=S2KKBrTV6Zt5Teg@mail.gmail.com>
Message-ID: <CALCETrXE0n4BrkX2ZLDJjdLqD-N_WwSZHt=S2KKBrTV6Zt5Teg@mail.gmail.com>
Subject: Re: [PATCH v2 05/20] x86/alternative: initializing temporary mm for patching
To: Nadav Amit <nadav.amit@gmail.com>
Cc: Andy Lutomirski <luto@kernel.org>, Rick Edgecombe <rick.p.edgecombe@intel.com>, 
	Ingo Molnar <mingo@redhat.com>, LKML <linux-kernel@vger.kernel.org>, X86 ML <x86@kernel.org>, 
	"H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Borislav Petkov <bp@alien8.de>, 
	Dave Hansen <dave.hansen@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, 
	Damian Tometzki <linux_dti@icloud.com>, linux-integrity <linux-integrity@vger.kernel.org>, 
	LSM List <linux-security-module@vger.kernel.org>, 
	Andrew Morton <akpm@linux-foundation.org>, 
	Kernel Hardening <kernel-hardening@lists.openwall.com>, Linux-MM <linux-mm@kvack.org>, 
	Will Deacon <will.deacon@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, 
	Kristen Carlson Accardi <kristen@linux.intel.com>, "Dock, Deneen T" <deneen.t.dock@intel.com>, 
	Kees Cook <keescook@chromium.org>, Dave Hansen <dave.hansen@intel.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Feb 11, 2019 at 11:18 AM Nadav Amit <nadav.amit@gmail.com> wrote:
>
> > On Feb 11, 2019, at 11:07 AM, Andy Lutomirski <luto@kernel.org> wrote:
> >
> > I'm certainly amenable to other solutions, but this one does seem the
> > least messy.  I looked at my old patch, and it doesn't do what you
> > want.  I'd suggest you just add a percpu variable like cpu_dr7 and rig
> > up some accessors so that it stays up to date.  Then you can skip the
> > dr7 writes if there are no watchpoints set.
> >
> > Also, EFI is probably a less interesting example than rare_write.
> > With rare_write, especially the dynamically allocated variants that
> > people keep coming up with, we'll need a swath of address space fully
> > as large as the vmalloc area. and getting *that* right while still
> > using the kernel address range might be more of a mess than we really
> > want to deal with.
>
> As long as you feel comfortable with this solution, I=E2=80=99m fine with=
 it.
>
> Here is what I have (untested). I prefer to save/restore all the DRs,
> because IIRC DR6 indications are updated even if breakpoints are disabled
> (in DR7). And anyhow, that is the standard interface.

Seems reasonable, but:

>
>
> -- >8 --
>
> From: Nadav Amit <namit@vmware.com>
> Date: Mon, 11 Feb 2019 03:07:08 -0800
> Subject: [PATCH] mm: save DRs when loading temporary mm
>
> Signed-off-by: Nadav Amit <namit@vmware.com>
> ---
>  arch/x86/include/asm/mmu_context.h | 18 ++++++++++++++++++
>  1 file changed, 18 insertions(+)
>
> diff --git a/arch/x86/include/asm/mmu_context.h b/arch/x86/include/asm/mm=
u_context.h
> index d684b954f3c0..4f92ec3df149 100644
> --- a/arch/x86/include/asm/mmu_context.h
> +++ b/arch/x86/include/asm/mmu_context.h
> @@ -13,6 +13,7 @@
>  #include <asm/tlbflush.h>
>  #include <asm/paravirt.h>
>  #include <asm/mpx.h>
> +#include <asm/debugreg.h>
>
>  extern atomic64_t last_mm_ctx_id;
>
> @@ -358,6 +359,7 @@ static inline unsigned long __get_current_cr3_fast(vo=
id)
>
>  typedef struct {
>         struct mm_struct *prev;
> +       unsigned short bp_enabled : 1;
>  } temp_mm_state_t;
>
>  /*
> @@ -380,6 +382,15 @@ static inline temp_mm_state_t use_temporary_mm(struc=
t mm_struct *mm)
>         lockdep_assert_irqs_disabled();
>         state.prev =3D this_cpu_read(cpu_tlbstate.loaded_mm);
>         switch_mm_irqs_off(NULL, mm, current);
> +
> +       /*
> +        * If breakpoints are enabled, disable them while the temporary m=
m is
> +        * used - they do not belong and might cause wrong signals or cra=
shes.
> +        */

Maybe clarify this?  Add some mention that the specific problem is
that user code could set a watchpoint on an address that is also used
in the temporary mm.

Arguably we should not disable *kernel* breakpoints a la perf, but
that seems like quite a minor issue, at least as long as
use_temporary_mm() doesn't get wider use.  But a comment that this
also disables perf breakpoints and that this could be undesirable
might be in order as well.

