Return-Path: <SRS0=SemS=S7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DF322C04AA6
	for <linux-mm@archiver.kernel.org>; Mon, 29 Apr 2019 18:46:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 90CB92067D
	for <linux-mm@archiver.kernel.org>; Mon, 29 Apr 2019 18:46:44 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="qZhWW23M"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 90CB92067D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 264456B0003; Mon, 29 Apr 2019 14:46:44 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1EC516B0005; Mon, 29 Apr 2019 14:46:44 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 08F816B0007; Mon, 29 Apr 2019 14:46:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id C0D9D6B0003
	for <linux-mm@kvack.org>; Mon, 29 Apr 2019 14:46:43 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id o1so7664512pgv.15
        for <linux-mm@kvack.org>; Mon, 29 Apr 2019 11:46:43 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc
         :content-transfer-encoding;
        bh=1ru3TU3hV7O6QI0KEdTCu1He3w17tDE27Luu9bBISac=;
        b=T3My1pFX5uGJdCpDbUoGcaOwnrBa07e7q8ItW8/eDUionRts9wE5Lk1pd9phh+RNc4
         M545EemvId0PP4pbwi4S6RiCBOV88W3iemoeyL7eg3inj5y/ubU1s8TxVUQNrZkF5z5l
         BTWOG61zGpisJ/a0Q1qaN7nIAcrXn/9VTspgdih0mDuEQBAbZH1nnAhJ/ABk74IiQCPt
         BRiyZJbncIw2nV6/FVZsF4lggN/cMAcp5SuBW3lN3TuamXLabuNCdenj3B77AOOZcwQd
         5qa/lj8xKEpoI0G4MjowIq6vHyPkM9XUn96YDLgztHs2aNTFNqeD5gSeA6BVG+cS+O/R
         R0jg==
X-Gm-Message-State: APjAAAUJ5Mj2newSny2fGQ0HGwiSFl+vCJ1sUEVpKdbMrOl1zw3mupAO
	5lvYKznIgarocwf+ZZTbboE/xpCENuflQiWMFVr8TxthM99x0PPehW2BHzR8TAYC711TH5caXkg
	KHtSIvh6w7uNdSc6HOg6akcOUZ5xGqeUAhnsbi8nb9nmcFjC89VU2PWWJGKMwT5T7EA==
X-Received: by 2002:aa7:81d0:: with SMTP id c16mr63773816pfn.132.1556563603410;
        Mon, 29 Apr 2019 11:46:43 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzIejXvNAe6L7f2szSebYJhnfaL6A6sLCmkxJhYS0fzFhxzzyPKPnvYwhSFfnVTKi7RQsur
X-Received: by 2002:aa7:81d0:: with SMTP id c16mr63773739pfn.132.1556563602619;
        Mon, 29 Apr 2019 11:46:42 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556563602; cv=none;
        d=google.com; s=arc-20160816;
        b=A4uCfiSRwMASUsm+6TeMMt/tDk4qrx24wJ0KD/Aviw9pSFXG1fnWmEN5BuTWOBfD16
         n57Jj10WLUg35d/O9lGL0HZ7aYmDFfBIbvjKSzbKjnOc6oERMBvnMmvLoVpjEoT7JFuS
         Rs/9c0xNbZfBPNgSXDKuYTLQG+Rr6UO4PQdtr1KeAVNYwCU+X3N/qH024eTNm8pph9JE
         2DL2NpAwHLYqEWAgqJxjUt0z5bh3fiJn40Qj/ByOZNG3Rnu8/0d+DALeuxS5jjvSGuBb
         yTHdxIEV3eRKrwYtbvhYYcGuQ/4ZJHSAQKjVa+c9AVj7bPpcnCq/4o2WMizuFQx4Xasq
         io0Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=1ru3TU3hV7O6QI0KEdTCu1He3w17tDE27Luu9bBISac=;
        b=TDKouiQz8Tc1KaxBNfUPli2piXWGNsWkM/gGGqr62pENv17M089TIZmfqNJuqViglC
         mo3wh2LLjXywFy+AfKieDemAJQQskGSm2YPFtSvLhF1Q/PEDuCIK2aUHw7uucqjWQMVt
         IMffjKblfpXweqNb1ILRuwr8Rsdsgdh6J727EdK+FfhZrQzHW+pAekJ0JRocEnJaRJnR
         CK/cHuU2VaE1IejPO0rsjU31BJzXFtjjok6tvRdxZ5WYuckWURNsbF1VN7Kdy9oWzVdL
         WmBpnPcjGBbTP6JtHJ+ZIq9SBAgJ4SiVEWxYnfgjT2DyoZwXz5wrSUj/9w81s4udupNy
         6OSQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=qZhWW23M;
       spf=pass (google.com: domain of luto@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=luto@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id r2si17775906pfg.93.2019.04.29.11.46.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Apr 2019 11:46:42 -0700 (PDT)
Received-SPF: pass (google.com: domain of luto@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=qZhWW23M;
       spf=pass (google.com: domain of luto@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=luto@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-wr1-f54.google.com (mail-wr1-f54.google.com [209.85.221.54])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id F2427217D9
	for <linux-mm@kvack.org>; Mon, 29 Apr 2019 18:46:41 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1556563602;
	bh=5j9NYksW1sFn4p0aXlHqBk4ZUKpOJxf0zYGvnIwtNvc=;
	h=References:In-Reply-To:From:Date:Subject:To:Cc:From;
	b=qZhWW23MUGLTV1xDSbhGdYBi6Ok9eRCtMr6n1nCokzoNuWw+9JeXnf0EsGO5F7NPs
	 X/PCZ9IWwRrVbLTkCL6BKXV1vMIK6WcURuaT7A0Eytq62xoVYAimqpRqwRhoVV6Fhb
	 IpNjeuR9wz20QmsqdP9Eh/9sJy8bSiXE5p2BlFOU=
Received: by mail-wr1-f54.google.com with SMTP id c12so17513539wrt.8
        for <linux-mm@kvack.org>; Mon, 29 Apr 2019 11:46:41 -0700 (PDT)
X-Received: by 2002:a5d:424e:: with SMTP id s14mr18705438wrr.77.1556563600428;
 Mon, 29 Apr 2019 11:46:40 -0700 (PDT)
MIME-Version: 1.0
References: <1556228754-12996-1-git-send-email-rppt@linux.ibm.com>
 <1556228754-12996-3-git-send-email-rppt@linux.ibm.com> <20190426083144.GA126896@gmail.com>
 <20190426095802.GA35515@gmail.com> <CALCETrV3xZdaMn_MQ5V5nORJbcAeMmpc=gq1=M9cmC_=tKVL3A@mail.gmail.com>
 <20190427084752.GA99668@gmail.com> <20190427104615.GA55518@gmail.com>
In-Reply-To: <20190427104615.GA55518@gmail.com>
From: Andy Lutomirski <luto@kernel.org>
Date: Mon, 29 Apr 2019 11:46:28 -0700
X-Gmail-Original-Message-ID: <CALCETrUn_86VAd8FGacJ169xcWE6XQngAMMhvgd1Aa6ZxhGhtA@mail.gmail.com>
Message-ID: <CALCETrUn_86VAd8FGacJ169xcWE6XQngAMMhvgd1Aa6ZxhGhtA@mail.gmail.com>
Subject: Re: [RFC PATCH 2/7] x86/sci: add core implementation for system call isolation
To: Ingo Molnar <mingo@kernel.org>
Cc: Andy Lutomirski <luto@kernel.org>, Mike Rapoport <rppt@linux.ibm.com>, 
	LKML <linux-kernel@vger.kernel.org>, 
	Alexandre Chartre <alexandre.chartre@oracle.com>, Borislav Petkov <bp@alien8.de>, 
	Dave Hansen <dave.hansen@linux.intel.com>, "H. Peter Anvin" <hpa@zytor.com>, 
	Ingo Molnar <mingo@redhat.com>, James Bottomley <James.Bottomley@hansenpartnership.com>, 
	Jonathan Adams <jwadams@google.com>, Kees Cook <keescook@chromium.org>, Paul Turner <pjt@google.com>, 
	Peter Zijlstra <peterz@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, Linux-MM <linux-mm@kvack.org>, 
	LSM List <linux-security-module@vger.kernel.org>, X86 ML <x86@kernel.org>, 
	Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, 
	Andrew Morton <akpm@linux-foundation.org>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, Apr 27, 2019 at 3:46 AM Ingo Molnar <mingo@kernel.org> wrote:
>
>
> * Ingo Molnar <mingo@kernel.org> wrote:
>
> > * Andy Lutomirski <luto@kernel.org> wrote:
> >
> > > > And no, I'm not arguing for Java or C#, but I am arguing for a sane=
r
> > > > version of C.
> > >
> > > IMO three are three credible choices:
> > >
> > > 1. C with fairly strong CFI protection. Grsecurity has this (supposed=
ly
> > > =E2=80=94 there=E2=80=99s a distinct lack of source code available), =
and clang is
> > > gradually working on it.
> > >
> > > 2. A safe language for parts of the kernel, e.g. drivers and maybe
> > > eventually filesystems.  Rust is probably the only credible candidate=
.
> > > Actually creating a decent Rust wrapper around the core kernel
> > > facilities would be quite a bit of work.  Things like sysfs would be
> > > interesting in Rust, since AFAIK few or even no drivers actually get
> > > the locking fully correct.  This means that naive users of the API
> > > cannot port directly to safe Rust, because all the races won't compil=
e
> > > :)
> > >
> > > 3. A sandbox for parts of the kernel, e.g. drivers.  The obvious
> > > candidates are eBPF and WASM.
> > >
> > > #2 will give very good performance.  #3 gives potentially stronger
> > > protection against a sandboxed component corrupting the kernel overal=
l,
> > > but it gives much weaker protection against a sandboxed component
> > > corrupting itself.
> > >
> > > In an ideal world, we could do #2 *and* #3.  Drivers could, for
> > > example, be written in a language like Rust, compiled to WASM, and ru=
n
> > > in the kernel.
> >
> > So why not go for #1, which would still outperform #2/#3, right? Do we
> > know what it would take, roughly, and how the runtime overhead looks
> > like?
>
> BTW., CFI protection is in essence a compiler (or hardware) technique to
> detect stack frame or function pointer corruption after the fact.
>
> So I'm wondering whether there's a 4th choice as well, which avoids
> control flow corruption *before* it happens:
>
>  - A C language runtime that is a subset of current C syntax and
>    semantics used in the kernel, and which doesn't allow access outside
>    of existing objects and thus creates a strictly enforced separation
>    between memory used for data, and memory used for code and control
>    flow.
>
>  - This would involve, at minimum:
>
>     - tracking every type and object and its inherent length and valid
>       access patterns, and never losing track of its type.
>
>     - being a lot more organized about initialization, i.e. no
>       uninitialized variables/fields.
>
>     - being a lot more strict about type conversions and pointers in
>       general.

You're not the only one to suggest this.  There are at least a few
things that make this extremely difficult if not impossible.  For
example, consider this code:

void maybe_buggy(void)
{
  int a, b;
  int *p =3D &a;
  int *q =3D (int *)some_function((unsigned long)p);
  *q =3D 1;
}

If some_function(&a) returns &a, then all is well.  But if
some_function(&a) returns &b or even a valid address of some unrelated
kernel object, then the code might be entirely valid and correct C,
but I don't see how the runtime checks are supposed to tell whether
the resulting address is valid or is a bug.  This type of code is, I
think, quite common in the kernel -- it happens in every data
structure where we have unions of pointers and integers or where we
steal some known-zero bits of a pointer to store something else.

--Andy

