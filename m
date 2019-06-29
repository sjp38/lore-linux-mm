Return-Path: <SRS0=BwCX=U4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0C3D1C5B57B
	for <linux-mm@archiver.kernel.org>; Sat, 29 Jun 2019 23:43:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9894F21743
	for <linux-mm@archiver.kernel.org>; Sat, 29 Jun 2019 23:43:33 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="ItDaQR+Y"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9894F21743
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 16E8B6B0003; Sat, 29 Jun 2019 19:43:33 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1215B8E0003; Sat, 29 Jun 2019 19:43:33 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F14408E0002; Sat, 29 Jun 2019 19:43:32 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f205.google.com (mail-pl1-f205.google.com [209.85.214.205])
	by kanga.kvack.org (Postfix) with ESMTP id B7E926B0003
	for <linux-mm@kvack.org>; Sat, 29 Jun 2019 19:43:32 -0400 (EDT)
Received: by mail-pl1-f205.google.com with SMTP id s22so5447063plp.5
        for <linux-mm@kvack.org>; Sat, 29 Jun 2019 16:43:32 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc
         :content-transfer-encoding;
        bh=VAARnf+ld9rSypzzmofbrDiQ8YylawljbiFpDwvvcoo=;
        b=h4m1EnJN/yibVI0wxiI+GKpA5DSf2QFZJnBqwPu/oGFEPVjyywVA2USBD65w9m3/zN
         4uYPqZyX6nyAdmOhfkac/4+c+Q+SHQjD/fmmXzYCwxe/mSxjfmx/zZJl/uSdXrs43zzp
         524OJB3TL1LQIQ/Jl8FmWajvv0C+br1u4h25Z7E7L7xJ48gaHVpOb8ovyRNQbqQ80NTb
         jWqwdbW+FBT3qmDNRVurT/m4g8uCy1PMeSe8CfrK0EqUn87h2HmSocOTLYFTKhtmq8rd
         Ckys5PTCZKWrnJKds3S2C5HUa/HU4cbxP+7zPtXRV8JAjPDbaIVZ/iiKNleRs3sWuQRC
         UX+w==
X-Gm-Message-State: APjAAAWqa9houG7sBCq6EPgk7RKG3J8HGZoTKSNx/PH3buHSITJZ1J/X
	GmtALhbRfZbfyLGxjvAUW6OCeq+1KGEMa1J5+uYTZdEvg9fwiA/BOfIUEEqd4m7Xp6sbVu4QGIh
	aiBO7Dx80yRTh2wS6gV+oCLuGYlv4V1jvlrHrDUh/mb09RmbIi2a5TRRiH8AD7XZDlw==
X-Received: by 2002:a17:90a:35e6:: with SMTP id r93mr22178061pjb.20.1561851812218;
        Sat, 29 Jun 2019 16:43:32 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz/NeFYBI8CwM22iswAznFoO8uvbEjPWc9BzPJnUkqpv6E3kBWCws68/gJdiLTs3nd4Ybea
X-Received: by 2002:a17:90a:35e6:: with SMTP id r93mr22178015pjb.20.1561851811442;
        Sat, 29 Jun 2019 16:43:31 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561851811; cv=none;
        d=google.com; s=arc-20160816;
        b=iWizt3mX3G2SGLldXFj9FOlRC1Qd5byuaDI3hUrfkxwyRADhn/69kPso5P6nCpE9b1
         4Dja3cLTowBGArPXbMxrfSDdgQOOjbw21W6FxXgCH62S6ooobEbFXIutzBtBlKSJWIJQ
         6pTG9TFxX+v2iE7btsyuh0RYGq4+h3G4pibZajZ9dIokGJygYQuRZs99o69nicWWsiZD
         WGgRE59gPb7tdilzY4hDMHiNwx2DcNLsJcLU8zVFicShHNLlSZ5i1GO7MgD9rBIFdSSe
         EJ+B0td7+1ZFsfuVkzMEjf5nKp0AslgbRrltk2iIKEoSdQSSWbn3GostllOTCqZe1Pg9
         ut+A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=VAARnf+ld9rSypzzmofbrDiQ8YylawljbiFpDwvvcoo=;
        b=fLWABygiKq95oCVRJC+1By+Nmi0EHY6W/M4QUJnWZ/uuoDyRgw7alMYM6LPOfrPLBa
         yMKcXoLmk47eXDhhIK5Ps7sJ+wy1Fb49/0PBGuA9WcBng5v5oIwgTSKhmazRnWROg8OS
         5O3ew7vt7q4FYce7GpO6aOkAyN7S986jWb9ioNB4C0rbc6Oq7UveP8LtSN+7HZSx7/Hc
         /49PB6cDMKeXsJ8L3eYkYz+kg1f4mJ2Hr2qdqS6iIMz+2mmNPm6ho9J0MMTkx2VlIXvd
         FsZ0uixvu8zpSP65o45nM/IBkYVhr26uM18cQ3vzJWYtlVRzGp3Elu8lYitAIOtAcIrE
         6Svw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=ItDaQR+Y;
       spf=pass (google.com: domain of luto@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=luto@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id o39si6470031pje.28.2019.06.29.16.43.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 29 Jun 2019 16:43:31 -0700 (PDT)
Received-SPF: pass (google.com: domain of luto@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=ItDaQR+Y;
       spf=pass (google.com: domain of luto@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=luto@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-wr1-f47.google.com (mail-wr1-f47.google.com [209.85.221.47])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 99C13217D7
	for <linux-mm@kvack.org>; Sat, 29 Jun 2019 23:43:30 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1561851810;
	bh=6Ls1mmfTCbzFx4Rzb3UhYmFEV6me19aFFOMlTGuTuMY=;
	h=References:In-Reply-To:From:Date:Subject:To:Cc:From;
	b=ItDaQR+YFwM+zUWyq0SEZyW3Pn6dapJHuivHM4jw8jYIYATlvNCFgUOVSyHA15NNw
	 AEZK10pv6CFtIGXjIbUG7AXyDMsOmLHnHbBJ/EnoIw6y8yuhITck+ydss7eXTQlmm2
	 HPBufIxfXjHuzQKQSM+5jkAcCFZ77DOpPDDnzdOY=
Received: by mail-wr1-f47.google.com with SMTP id x4so9909379wrt.6
        for <linux-mm@kvack.org>; Sat, 29 Jun 2019 16:43:30 -0700 (PDT)
X-Received: by 2002:adf:dd0f:: with SMTP id a15mr10561378wrm.265.1561851809106;
 Sat, 29 Jun 2019 16:43:29 -0700 (PDT)
MIME-Version: 1.0
References: <20190628194158.2431-1-yu-cheng.yu@intel.com> <20190628194158.2431-2-yu-cheng.yu@intel.com>
In-Reply-To: <20190628194158.2431-2-yu-cheng.yu@intel.com>
From: Andy Lutomirski <luto@kernel.org>
Date: Sat, 29 Jun 2019 16:43:18 -0700
X-Gmail-Original-Message-ID: <CALCETrVvbbCWMPo7v5eYgTocaxRQPHerJ=CRjWscGxgb6QjOFA@mail.gmail.com>
Message-ID: <CALCETrVvbbCWMPo7v5eYgTocaxRQPHerJ=CRjWscGxgb6QjOFA@mail.gmail.com>
Subject: Re: [RFC PATCH 2/3] Introduce arch_prctl(ARCH_X86_CET_MARK_LEGACY_CODE)
To: Yu-cheng Yu <yu-cheng.yu@intel.com>
Cc: X86 ML <x86@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, 
	Ingo Molnar <mingo@redhat.com>, LKML <linux-kernel@vger.kernel.org>, 
	"open list:DOCUMENTATION" <linux-doc@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, 
	linux-arch <linux-arch@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>, 
	Arnd Bergmann <arnd@arndb.de>, Balbir Singh <bsingharora@gmail.com>, Borislav Petkov <bp@alien8.de>, 
	Cyrill Gorcunov <gorcunov@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, 
	Eugene Syromiatnikov <esyr@redhat.com>, Florian Weimer <fweimer@redhat.com>, "H.J. Lu" <hjl.tools@gmail.com>, 
	Jann Horn <jannh@google.com>, Jonathan Corbet <corbet@lwn.net>, Kees Cook <keescook@chromium.org>, 
	Mike Kravetz <mike.kravetz@oracle.com>, Nadav Amit <nadav.amit@gmail.com>, 
	Oleg Nesterov <oleg@redhat.com>, Pavel Machek <pavel@ucw.cz>, Peter Zijlstra <peterz@infradead.org>, 
	Randy Dunlap <rdunlap@infradead.org>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, 
	Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>, Dave Martin <Dave.Martin@arm.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

> On Jun 28, 2019, at 12:41 PM, Yu-cheng Yu <yu-cheng.yu@intel.com> wrote:
>
> The CET legacy code bitmap covers the whole user-mode address space and i=
s
> located at the top of the user-mode address space.  It is allocated only
> when the first time arch_prctl(ARCH_X86_MARK_LEGACY_CODE) is called from
> an application.
>
> Introduce:
>
> arch_prctl(ARCH_X86_MARK_LEGACY_CODE, unsigned long *buf)
>    Mark an address range as IBT legacy code.

How about defining a struct for this?

The change log should discuss where the bitmap goes and how it=E2=80=99s al=
located.

> +static int alloc_bitmap(void)
> +{
> +    unsigned long addr;
> +    u64 msr_ia32_u_cet;
> +
> +    addr =3D do_mmap_locked(NULL, IBT_BITMAP_ADDR, IBT_BITMAP_SIZE,
> +                  PROT_READ | PROT_WRITE,
> +                  MAP_ANONYMOUS | MAP_PRIVATE | MAP_FIXED_NOREPLACE,
> +                  VM_IBT | VM_NORESERVE, NULL);
> +
> +    if (IS_ERR((void *)addr))
> +        return addr;
> +
> +    current->thread.cet.ibt_bitmap_addr =3D addr;

addr is a constant. Why are you storing it?  If it ends up not being
constant, you should wire up mremap like the vDSO does.


> +static int set_user_bits(unsigned long __user *buf, unsigned long buf_si=
ze,
> +             unsigned long start_bit, unsigned long end_bit, unsigned lo=
ng set)
> +{
> +    unsigned long start_ul, end_ul, total_ul;
> +    int i, j, r;
> +
> +    if (round_up(end_bit, BITS_PER_BYTE) / BITS_PER_BYTE > buf_size)
> +        end_bit =3D buf_size * BITS_PER_BYTE - 1;
> +
> +    start_ul =3D start_bit / BITS_PER_LONG;
> +    end_ul =3D end_bit / BITS_PER_LONG;
> +    total_ul =3D (end_ul - start_ul + 1);
> +
> +    i =3D start_bit % BITS_PER_LONG;
> +    j =3D end_bit % BITS_PER_LONG;
> +
> +    r =3D 0;
> +    put_user_try {

put_user_try is obsolete.  Just use get_user(), etc.

Also, I must be missing something fundamental, because this series
claims that user code can't write directly to the bitmap.  This means
that this entire function shouldn't work at all.

