Return-Path: <SRS0=HICI=RB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 62674C43381
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 14:41:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1E41C21848
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 14:41:40 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="Jk4s/BkF"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1E41C21848
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B0E798E0003; Tue, 26 Feb 2019 09:41:39 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id ABCB18E0001; Tue, 26 Feb 2019 09:41:39 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9D3D98E0003; Tue, 26 Feb 2019 09:41:39 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5E9548E0001
	for <linux-mm@kvack.org>; Tue, 26 Feb 2019 09:41:39 -0500 (EST)
Received: by mail-pl1-f200.google.com with SMTP id b4so9945214plb.9
        for <linux-mm@kvack.org>; Tue, 26 Feb 2019 06:41:39 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=ORID1v1ozYXyKv1mw/ofFm5kiuOuJ/TBoHbnGpDrQY0=;
        b=YkI5dIEvGT1c7vo0QhF0f01gL5Tt8deBDpyLx6kJ74DgCaoFrWX92uZ/uZvvxTqHe8
         o2O85uek6zTvgQXSKHaXJVzIcmINFhx/wW9eeGNX0ljVi4w1qqKdApxkk1j7uzJBnitG
         f3wTrZXatNs4Kz0SE5Kxwp6uOtidCqp5Vt5M2ivgRzVliz51pTponBYUxAr3ax3Lo6n6
         emusYC3b9rBNUvfzK8n4fCtgOzwTqACIBUG1GHAzxt7LQPNvVcOC64MHWaC+KC2bwsmM
         p+oNRzXbbEA28GsY3etmTcIrIximygzci2MlUbu9Ur9ydIRZCANFNVcL+JjZ8/eBf+JS
         aboA==
X-Gm-Message-State: AHQUAuafybScFxpGHhcWVTj9cubAMRWdsVQY5UgpG/mbqniMIzb38TIv
	Udvblsz0mbk5b8O2fQ4UgLm0yDw1WzEHl1eCA1ub1U+Kmh44dLJa3OpyBFvv+n6mu7WqKeFR6s9
	UWSayD472b4zeF89L3YQvJIO792dyySKEljyMFfFGn71/BRkuuSyC5je6opBy5Kv3ZwKIDWx6pv
	7Jg4zBWD/AW1n18IV9vJzccZhAf+My6ARtjBuTiQFy5V6HfoN5SD8FCgW6axxIo+syiay4oFf95
	Dnr+oq81sBZONZKhdcCIUdB0zZ5c/fpnaR6U3JGowsnFEMOX1iPJ/ApCp4QUPieVNyUOaU18egL
	HIu22QQCnO59RH91dn0q+TsOn5UmdMwEYIfz/2wbjBGEgLvLHHhw8R+NnlIm/QPHc+GCvWJPU6o
	o
X-Received: by 2002:a17:902:8690:: with SMTP id g16mr26211356plo.284.1551192099058;
        Tue, 26 Feb 2019 06:41:39 -0800 (PST)
X-Received: by 2002:a17:902:8690:: with SMTP id g16mr26211285plo.284.1551192098272;
        Tue, 26 Feb 2019 06:41:38 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551192098; cv=none;
        d=google.com; s=arc-20160816;
        b=UJ9cL/t5O7fsT0DidkexchvpQ9axSS68oiK1vqG1PCf/tWwkvJQe6IqYFSW6HeUgR/
         /iLeUYLWuqR4iAKHxUnB4lcXziGwPkr3gTvrdnQQ3iSjDXFKXpkHtat9xNe+0Lukl6/o
         opjErpEUpDdWO3Wrc/1Qk3BCStcBcaK0fk26M6H7JK34npvTpkFl6imKYd0M/Et6OLVl
         tZoHtBXKuvaaBGpu0+I+q0o0DbRS4ynOCmYBoajxE+b6WgfUpwIUwXnjNvt+qidcp+VD
         bsPaizuUwpCpSndr1QjAfERkHjH6PMLMzhw8vglLes9GBle+V6+HvJi6e6UcLZDF0ZeI
         MJog==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=ORID1v1ozYXyKv1mw/ofFm5kiuOuJ/TBoHbnGpDrQY0=;
        b=DdJfRSiVSPgLdowuktSqbJtBCrl/IS2yvQimI4waQ2CrEB7UFvM0Xyt1MaFexhfpIN
         GR8Sc06+gyUOqIKH7QldorDha7aeebZuoeA0c7r175IIXCV3B9DSgxhnwXITjTEW75My
         b7QzMjV/rFH1IQdNkjvdjKjOKXhxu6yHPOtOZVjdmQ9Cfpq7tnihUr2DN+iQdFP0M05f
         fDBKQuev2uNeMXZL2VW8ExIOL0RI6QZTFx+7HZZHVLsOW2R8v8yrzLV4mbrY/6IOKbKb
         rFzGKjJyMxmXj0cjESlQLVSTswEVVxdEH6eavheRx7fQU6Tul0gc1e0xofO5Y+s26Uxm
         hn/g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b="Jk4s/BkF";
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q16sor20623324pfi.33.2019.02.26.06.41.38
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 26 Feb 2019 06:41:38 -0800 (PST)
Received-SPF: pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b="Jk4s/BkF";
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=ORID1v1ozYXyKv1mw/ofFm5kiuOuJ/TBoHbnGpDrQY0=;
        b=Jk4s/BkFrIcxrk4e9Mx5smnm1MMtapGUCpafH868xdIWYkLK7M78NPFfkO1hXlBR3s
         fHSFCSGQY90XYaDQqb63dSKPREtSbEi2GwRgT00jYvnEy0yQetugEzlFqBmtB3qipsAd
         q/rhOJ6CKsqxpXxBDrJDcb0ls8JRx8hPmbNL5pXQCFMY5+3weHhsnBcu5hbxiUG4WqQl
         pBEq1Wji+wh6z+8emU3AosXH6snGNQBpu8akU3FP96jjwWcneLVMTgn776abphESvY54
         iMhXTsCqkSEIu1VQDJchEorqdn4d1RpFfWm51ZaV3ypfOUhUpwNhpwhi50tHIgnGBRqu
         SjeQ==
X-Google-Smtp-Source: AHgI3IZRaeChYbi2J79TLZ2OQNrL+zd2lHSInwkIpfXgbjWxpzJly0F0LoxycLTV6qaHuDyyWxELKtQh0Gjyn9jKmaE=
X-Received: by 2002:a62:4299:: with SMTP id h25mr26113838pfd.165.1551192097850;
 Tue, 26 Feb 2019 06:41:37 -0800 (PST)
MIME-Version: 1.0
References: <cover.1550839937.git.andreyknvl@google.com> <3875fa863b755d8cb43afa7bb0fe543e5fd05a5d.1550839937.git.andreyknvl@google.com>
 <81ea4e77-90a4-4fd9-2bc8-135e0da30044@intel.com>
In-Reply-To: <81ea4e77-90a4-4fd9-2bc8-135e0da30044@intel.com>
From: Andrey Konovalov <andreyknvl@google.com>
Date: Tue, 26 Feb 2019 15:41:26 +0100
Message-ID: <CAAeHK+z2qw__Kpeih2mEyhVJ-gbor1vYsOZddT5E71JDiSg7pg@mail.gmail.com>
Subject: Re: [PATCH v10 04/12] mm, arm64: untag user pointers passed to memory syscalls
To: Dave Hansen <dave.hansen@intel.com>
Cc: Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, 
	Mark Rutland <mark.rutland@arm.com>, Robin Murphy <robin.murphy@arm.com>, 
	Kees Cook <keescook@chromium.org>, Kate Stewart <kstewart@linuxfoundation.org>, 
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, 
	Ingo Molnar <mingo@kernel.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, 
	Shuah Khan <shuah@kernel.org>, Vincenzo Frascino <vincenzo.frascino@arm.com>, 
	Linux ARM <linux-arm-kernel@lists.infradead.org>, 
	"open list:DOCUMENTATION" <linux-doc@vger.kernel.org>, 
	Linux Memory Management List <linux-mm@kvack.org>, linux-arch <linux-arch@vger.kernel.org>, 
	"open list:KERNEL SELFTEST FRAMEWORK" <linux-kselftest@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, 
	Dmitry Vyukov <dvyukov@google.com>, Kostya Serebryany <kcc@google.com>, 
	Evgeniy Stepanov <eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>, 
	Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Jacob Bramley <Jacob.Bramley@arm.com>, 
	Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Chintan Pandya <cpandya@codeaurora.org>, 
	Luc Van Oostenryck <luc.vanoostenryck@gmail.com>, Dave Martin <Dave.Martin@arm.com>, 
	Kevin Brodsky <kevin.brodsky@arm.com>, Szabolcs Nagy <Szabolcs.Nagy@arm.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, Feb 23, 2019 at 12:07 AM Dave Hansen <dave.hansen@intel.com> wrote:
>
> On 2/22/19 4:53 AM, Andrey Konovalov wrote:
> > --- a/mm/mprotect.c
> > +++ b/mm/mprotect.c
> > @@ -578,6 +578,7 @@ static int do_mprotect_pkey(unsigned long start, size_t len,
> >  SYSCALL_DEFINE3(mprotect, unsigned long, start, size_t, len,
> >               unsigned long, prot)
> >  {
> > +     start = untagged_addr(start);
> >       return do_mprotect_pkey(start, len, prot, -1);
> >  }
> >
> > @@ -586,6 +587,7 @@ SYSCALL_DEFINE3(mprotect, unsigned long, start, size_t, len,
> >  SYSCALL_DEFINE4(pkey_mprotect, unsigned long, start, size_t, len,
> >               unsigned long, prot, int, pkey)
> >  {
> > +     start = untagged_addr(start);
> >       return do_mprotect_pkey(start, len, prot, pkey);
> >  }
>
> This seems to have taken the approach of going as close as possible to
> the syscall boundary and untagging the pointer there.  I guess that's
> OK, but it does lead to more churn than necessary.  For instance, why
> not just do the untagging in do_mprotect_pkey()?

I think that makes more sense, will do in the next version, thanks!

>
> I think that's an overall design question.  I kinda asked the same thing
> about patching call sites vs. VMA lookup functions.

Replied in the other thread.

