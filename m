Return-Path: <SRS0=sydr=SZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS,
	URIBL_BLOCKED autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B89E0C10F03
	for <linux-mm@archiver.kernel.org>; Tue, 23 Apr 2019 16:07:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6B6C920693
	for <linux-mm@archiver.kernel.org>; Tue, 23 Apr 2019 16:07:07 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=amacapital-net.20150623.gappssmtp.com header.i=@amacapital-net.20150623.gappssmtp.com header.b="UiRr4bOd"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6B6C920693
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=amacapital.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1C8816B0003; Tue, 23 Apr 2019 12:07:07 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 177B96B0005; Tue, 23 Apr 2019 12:07:07 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 067846B0007; Tue, 23 Apr 2019 12:07:07 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id BFC406B0003
	for <linux-mm@kvack.org>; Tue, 23 Apr 2019 12:07:06 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id b7so8937668plb.17
        for <linux-mm@kvack.org>; Tue, 23 Apr 2019 09:07:06 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:subject:from
         :in-reply-to:date:cc:content-transfer-encoding:message-id:references
         :to;
        bh=/6yGNw+GddeG+JGK7yWuf2Vdt5FOQ0zTBy3ljzfqBg4=;
        b=Vjuy2ShYD7jKa9oKrnlCITAjIBtBMX/oSIHp53g6mg3asG5BzawaC2ROti8Q+055+q
         f6NSPt8jp5ixQHIXh4fV7cFbYmXMIoX34JyO+r6VmXsw0Mznk7TJo/w2SwWI3x5TUcSR
         rB/F9fFd6qlMDM9uEQhynNYgVptQFQUe1htwm3NtQX0EZ7wDBZtrybSyGQfvKDXTsV61
         7G3EHA5/VU0SadYPWGzmWG/4M3MuwD5Rj6WoV3QgqZaL/ieri+B606+LrXURRlNNauDv
         Ky0I4h/2rmqpEY8NEJ6uFb5AjIGseRyq7QyuUnlnAFPTwcx9lfChbbcTPB4DFpoGjL7a
         X1kg==
X-Gm-Message-State: APjAAAXJsEHMSIub9xsyO2KF1GaX9yEmdd12a48sBTdfD3W79rhHviTD
	tLWEERFOIAX0To7zvkL2+FwejAFD1B0K8yvpmhGBhq8NAqKhG7dR3BE1bf09J/oN8lewIYbLSco
	HoonBM18UrHr6y7yKTCLNtpkIPbh34sAhd06kc3BN0x/m4w3XR0UVa6E0WYWTCQfGtQ==
X-Received: by 2002:a63:6849:: with SMTP id d70mr24658037pgc.21.1556035626365;
        Tue, 23 Apr 2019 09:07:06 -0700 (PDT)
X-Received: by 2002:a63:6849:: with SMTP id d70mr24657952pgc.21.1556035625336;
        Tue, 23 Apr 2019 09:07:05 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556035625; cv=none;
        d=google.com; s=arc-20160816;
        b=Jy6EqBxOWJhCdECP8224zRqFIrafnZZdeqCmH90Hg1e55IMFrtKA0GgXr6SUJ97c2y
         C0UwB3AwOoV2V7WYYGcFAoNpEnfWBgTyrufzgfUgsCIEOUVJl34xwfhi1JRWSZH/St0d
         vgZQnqY2TIwB5Bw1EoF9sifiuROvHuJFW/jUoZH/KsNwgB8TxzM+v5gxwh03Y10H1IpC
         L5Y7ej2Et07lFGQclWtxNcvSEq8Brr/QmUVsaeBWwiXO17oF3rkiqZHUdW6B1R9pTexl
         xrH43J07ryTkd5dqJQEjmO49VoZu6CoLhVE+dqIzHBos4ETPpF7XI/eFSSaUYICiokJn
         u1TA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=to:references:message-id:content-transfer-encoding:cc:date
         :in-reply-to:from:subject:mime-version:dkim-signature;
        bh=/6yGNw+GddeG+JGK7yWuf2Vdt5FOQ0zTBy3ljzfqBg4=;
        b=TV7siIuldY1oLBxI6TmVE9u6ZkT7+JReh1JBppuBb4REmibJpHsyKNxNO8kMw+csvN
         JEZdql7OH7SvN1a+Fjic4vSGAzqxNBd/rLn+gchU+Oo1dr9ZCd3OIQsYBiPBBRMf138w
         YsNY9+Qh5unQYEThhrBanlp3XhdPkwA+mjom3rknN5vS2bJSPdZbE3KHY2yhcXuaVI98
         FvDUZS+UOUwVZSdUx/UR4i3aHUey1rWV+6F68KlFPA1xO+vgbiJkFwCQqLN/NM2/PGIx
         6hpT8q7LPEBKPcxDYYuELYUZg5U4NP0uxs/tF45qAB37bDNUZlqiPNKJXzEhWxXTCp9p
         uHeQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@amacapital-net.20150623.gappssmtp.com header.s=20150623 header.b=UiRr4bOd;
       spf=pass (google.com: domain of luto@amacapital.net designates 209.85.220.65 as permitted sender) smtp.mailfrom=luto@amacapital.net
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a37sor17125504pgl.72.2019.04.23.09.07.05
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 23 Apr 2019 09:07:05 -0700 (PDT)
Received-SPF: pass (google.com: domain of luto@amacapital.net designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@amacapital-net.20150623.gappssmtp.com header.s=20150623 header.b=UiRr4bOd;
       spf=pass (google.com: domain of luto@amacapital.net designates 209.85.220.65 as permitted sender) smtp.mailfrom=luto@amacapital.net
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=amacapital-net.20150623.gappssmtp.com; s=20150623;
        h=mime-version:subject:from:in-reply-to:date:cc
         :content-transfer-encoding:message-id:references:to;
        bh=/6yGNw+GddeG+JGK7yWuf2Vdt5FOQ0zTBy3ljzfqBg4=;
        b=UiRr4bOdWC4Yr+hy2WKLYg1BrqWUtayOk+O7ylBgu9sQi/yt6to0sRGuvM6SYS7Gjm
         r+P5niyvJmJOu+dS/BksvvPjfKTgilVxI2m7QtOI+tnJUmW2xwUC7+r9UbBJRpqulPyp
         Fi9f3f7NmMbBnJFAKGlZbj80GO3zgHVY6J5l5TvqFoLUp8nvvdadqAIbmAbhRzf3Z6dO
         F1g55E6U4+wBVXdHqch+opg+7veDYRcoGJcn+IO1qQAeZvAnqk/F1Uw7YAu0EQi7lqqt
         x0grR+mE0e2HBZIEr5nHm3DTb7oyYuUxOLF9Oi26hN5VimZipHmmgwIraFHMIo5kPlQk
         sSbA==
X-Google-Smtp-Source: APXvYqy8AC4d+BvWkifWyma+BkNGRsgxkP0k610zpgUd8DVOzWg/wETNM/CHFKJ/jnSscWDGu1JqZA==
X-Received: by 2002:a63:c54d:: with SMTP id g13mr22435956pgd.376.1556035624380;
        Tue, 23 Apr 2019 09:07:04 -0700 (PDT)
Received: from ?IPv6:2601:646:c200:1ef2:909f:2a1b:c449:c291? ([2601:646:c200:1ef2:909f:2a1b:c449:c291])
        by smtp.gmail.com with ESMTPSA id o66sm4176929pfb.184.2019.04.23.09.07.03
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Apr 2019 09:07:03 -0700 (PDT)
Content-Type: text/plain;
	charset=utf-8
Mime-Version: 1.0 (1.0)
Subject: Re: mmotm 2019-04-19-14-53 uploaded (objtool)
From: Andy Lutomirski <luto@amacapital.net>
X-Mailer: iPhone Mail (16E227)
In-Reply-To: <20190423082448.GY11158@hirez.programming.kicks-ass.net>
Date: Tue, 23 Apr 2019 09:07:01 -0700
Cc: Randy Dunlap <rdunlap@infradead.org>, akpm@linux-foundation.org,
 broonie@kernel.org, linux-fsdevel@vger.kernel.org,
 linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-next@vger.kernel.org,
 mhocko@suse.cz, mm-commits@vger.kernel.org, sfr@canb.auug.org.au,
 Josh Poimboeuf <jpoimboe@redhat.com>,
 Linus Torvalds <torvalds@linux-foundation.org>,
 Andy Lutomirski <luto@kernel.org>
Content-Transfer-Encoding: quoted-printable
Message-Id: <D7626BC0-FCE9-4424-A6F5-D4AAB6727ED4@amacapital.net>
References: <20190419215358.WMVFXV3bT%akpm@linux-foundation.org> <af3819b4-008f-171e-e721-a9a20f85d8d1@infradead.org> <20190423082448.GY11158@hirez.programming.kicks-ass.net>
To: Peter Zijlstra <peterz@infradead.org>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



> On Apr 23, 2019, at 1:24 AM, Peter Zijlstra <peterz@infradead.org> wrote:
>=20
>> On Fri, Apr 19, 2019 at 09:36:46PM -0700, Randy Dunlap wrote:
>>> On 4/19/19 2:53 PM, akpm@linux-foundation.org wrote:
>>> The mm-of-the-moment snapshot 2019-04-19-14-53 has been uploaded to
>>>=20
>>>   http://www.ozlabs.org/~akpm/mmotm/
>>>=20
>>> mmotm-readme.txt says
>>>=20
>>> README for mm-of-the-moment:
>>>=20
>>> http://www.ozlabs.org/~akpm/mmotm/
>>>=20
>>> This is a snapshot of my -mm patch queue.  Uploaded at random hopefully
>>> more than once a week.
>>=20
>> on x86_64:
>>=20
>>  CC      lib/strncpy_from_user.o
>> lib/strncpy_from_user.o: warning: objtool: strncpy_from_user()+0x315: cal=
l to __ubsan_handle_add_overflow() with UACCESS enabled
>>  CC      lib/strnlen_user.o
>> lib/strnlen_user.o: warning: objtool: strnlen_user()+0x337: call to __ubs=
an_handle_sub_overflow() with UACCESS enabled
>=20
> Lemme guess, you're using GCC < 8 ? That had a bug where UBSAN
> considered signed overflow UB when using -fno-strict-overflow or
> -fwrapv.
>=20
> Now, we could of course allow this symbol, but I found only the below
> was required to make allyesconfig build without issue.
>=20
> Andy, Linus?
>=20
> (note: the __put_user thing is from this one:
>=20
>  drivers/gpu/drm/i915/i915_gem_execbuffer.c:    if (unlikely(__put_user(of=
fset, &urelocs[r-stack].presumed_offset))) {
>=20
> where (ptr) ends up non-trivial due to UBSAN)
>=20
> ---
>=20
> diff --git a/arch/x86/include/asm/uaccess.h b/arch/x86/include/asm/uaccess=
.h
> index 22ba683afdc2..c82abd6e4ca3 100644
> --- a/arch/x86/include/asm/uaccess.h
> +++ b/arch/x86/include/asm/uaccess.h
> @@ -427,10 +427,11 @@ do {                                    \
> ({                                \
>    __label__ __pu_label;                    \
>    int __pu_err =3D -EFAULT;                    \
> -    __typeof__(*(ptr)) __pu_val;                \
> -    __pu_val =3D x;                        \
> +    __typeof__(*(ptr)) __pu_val =3D (x);            \
> +    __typeof__(ptr) __pu_ptr =3D (ptr);            \

Hmm.  I wonder if this forces the address calculation to be done before STAC=
, which means that gcc can=E2=80=99t use mov ..., %gs:(fancy stuff).  It pro=
bably depends on how clever the optimizer is. Have you looked at the generat=
ed code?

Other than that, it seems reasonable to me.

> +    __typeof__(size) __pu_size =3D (size);            \
>    __uaccess_begin();                    \
> -    __put_user_size(__pu_val, (ptr), (size), __pu_label);    \
> +    __put_user_size(__pu_val, __pu_ptr, __pu_size, __pu_label);    \
>    __pu_err =3D 0;                        \
> __pu_label:                            \
>    __uaccess_end();                    \
> diff --git a/lib/strncpy_from_user.c b/lib/strncpy_from_user.c
> index 58eacd41526c..07045bc4872e 100644
> --- a/lib/strncpy_from_user.c
> +++ b/lib/strncpy_from_user.c
> @@ -26,7 +26,7 @@
> static inline long do_strncpy_from_user(char *dst, const char __user *src,=
 long count, unsigned long max)
> {
>    const struct word_at_a_time constants =3D WORD_AT_A_TIME_CONSTANTS;
> -    long res =3D 0;
> +    unsigned long res =3D 0;
>=20
>    /*
>     * Truncate 'max' to the user-specified limit, so that
> diff --git a/lib/strnlen_user.c b/lib/strnlen_user.c
> index 1c1a1b0e38a5..0729378ad3e9 100644
> --- a/lib/strnlen_user.c
> +++ b/lib/strnlen_user.c
> @@ -28,7 +28,7 @@
> static inline long do_strnlen_user(const char __user *src, unsigned long c=
ount, unsigned long max)
> {
>    const struct word_at_a_time constants =3D WORD_AT_A_TIME_CONSTANTS;
> -    long align, res =3D 0;
> +    unsigned long align, res =3D 0;
>    unsigned long c;
>=20
>    /*
>=20

