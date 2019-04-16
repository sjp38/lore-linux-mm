Return-Path: <SRS0=AiS9=SS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6D63FC10F13
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 19:25:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 15FC6206B6
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 19:25:14 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=efficios.com header.i=@efficios.com header.b="QUJABhXu"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 15FC6206B6
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=efficios.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9624D6B0003; Tue, 16 Apr 2019 15:25:14 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 90FB36B0006; Tue, 16 Apr 2019 15:25:14 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7B0236B0007; Tue, 16 Apr 2019 15:25:14 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 56E436B0003
	for <linux-mm@kvack.org>; Tue, 16 Apr 2019 15:25:14 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id n13so20300454qtn.6
        for <linux-mm@kvack.org>; Tue, 16 Apr 2019 12:25:14 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-filter:dkim-signature:date:from:to:cc
         :message-id:in-reply-to:references:subject:mime-version
         :content-transfer-encoding:thread-topic:thread-index;
        bh=dBAHxV+5AMeW0yIbrFxTc9ZyYkcIIhy/PrmkHPHr6wE=;
        b=foaUvsXn24DgnXo9XCBbEjKY/c6FHTaNqs6ao2O+KTYrJyihWIKWtvKGP5Adw/amds
         6VSSqtcWawG7AZ9qg3yzppUpZKMexUmOw6dY/ecgiqBIoxTTSnVIGMRu+mJi9OOAAr2v
         +Q0GcUZKcJU77w2ExjgaqhV9TBPVZnu1Piw736iAzPvkKvSnFfEfGxZRbFotQs9V/8rZ
         CgZBkLKxCr8E4veoHpmOIjNbxCacGSTY98XmT2b9DiIPxg9hFr8ZJJJeSI4h5n7tFVt2
         P0neiy3sJAyiBG2YvPjyzSfPPCtQOCYJqQ7ujoib3TGY4sagrNHy44wfZCKDtx6rYamm
         m/FQ==
X-Gm-Message-State: APjAAAV87n8UZIfi61UmjnoOGPOnqVuidh+UqLraZKFb1hS9qfVNX1Ho
	tPFUFNHGj/KOFp4RRSGz3RqEosVGNiThfwN0FUn6tC8Sefn8qeNa7Xfo8wVsfNgedzTIE5Cex6y
	lz94w8dOpFVo2o6Xheoncx32eRdEOqcNglWduskW0etHpZjGGUZQZqWI4rGwShqn32w==
X-Received: by 2002:a05:620a:1008:: with SMTP id z8mr63256692qkj.264.1555442714004;
        Tue, 16 Apr 2019 12:25:14 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzr2phsxXnVal4LeynULaROeHbZXrtKC/VWYlHo+LYx7bS7GdsusSk/L2/8zBfM6p3EV27k
X-Received: by 2002:a05:620a:1008:: with SMTP id z8mr63256625qkj.264.1555442713195;
        Tue, 16 Apr 2019 12:25:13 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555442713; cv=none;
        d=google.com; s=arc-20160816;
        b=M6NyWQHXzZcfr/Umzj663R5ji5P9N4aM4obUGK2l8eqc2v46hKCd6jZhjW20PeU+tK
         xV00BiuN1LE1vwLobVbaz8w0gtCIIovGFsyny/856v/NFFlY0BBa3GEjn6o+KjSs5p2P
         1A030s65WeHjbTTwrEAASYw4PB+6bE3oqINag1AS6jOk0sJ7d6CsrAmqGydzU5klxQhM
         gsU41kXZHUO0iSVnA8UuwanWPEZo4YMAvxr0VhTvqteY1Z/NEtX0q4QJEPr8DLwoVbAQ
         M+dRl31iJyDvlTqLp4fcGyw7KLWnq0Fy9pr5wSeu+8bOIn4qOfdU9AE6XvHN4ll8IY1t
         EEzw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=thread-index:thread-topic:content-transfer-encoding:mime-version
         :subject:references:in-reply-to:message-id:cc:to:from:date
         :dkim-signature:dkim-filter;
        bh=dBAHxV+5AMeW0yIbrFxTc9ZyYkcIIhy/PrmkHPHr6wE=;
        b=dWCpkaIeqdMyYS+Ctbwdq/iAiHsPlmk0cY41ELeouD6HrVaU8k+1XJ3+yvhAmRtUhX
         HYhkwlUZOTdp9vzGvmMVhL5lMfZGiT6c4jSaX1/gez2/GI1UYg62+Pn0/7Hy+/D6VKKs
         mVE45E/zmEIpJLlz6xiXjvNh/kCm1F99b9/dXTeYrFWxzCVFVxOjJSXZ+D7UbxJfm4A3
         Csy6eLLcyOaOw01MRbov1EupmrY9l0tTjR4yVGbieTx4jMTAJ0+0mxcRbLOUdHOVLBKZ
         uL2Wb+4vcFMD7x+diBhXP9bmLmUgR0kWn1z73qNyT+toQwhrWMvYu2b2HWu/YlYAFVkA
         YTRg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@efficios.com header.s=default header.b=QUJABhXu;
       spf=pass (google.com: domain of compudj@efficios.com designates 2607:5300:60:7898::beef as permitted sender) smtp.mailfrom=compudj@efficios.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=efficios.com
Received: from mail.efficios.com (mail.efficios.com. [2607:5300:60:7898::beef])
        by mx.google.com with ESMTPS id g189si1302144qkd.235.2019.04.16.12.25.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Apr 2019 12:25:13 -0700 (PDT)
Received-SPF: pass (google.com: domain of compudj@efficios.com designates 2607:5300:60:7898::beef as permitted sender) client-ip=2607:5300:60:7898::beef;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@efficios.com header.s=default header.b=QUJABhXu;
       spf=pass (google.com: domain of compudj@efficios.com designates 2607:5300:60:7898::beef as permitted sender) smtp.mailfrom=compudj@efficios.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=efficios.com
Received: from localhost (ip6-localhost [IPv6:::1])
	by mail.efficios.com (Postfix) with ESMTP id 9D68A1D645E;
	Tue, 16 Apr 2019 15:25:12 -0400 (EDT)
Received: from mail.efficios.com ([IPv6:::1])
	by localhost (mail02.efficios.com [IPv6:::1]) (amavisd-new, port 10032)
	with ESMTP id mx16-Xo3oWEX; Tue, 16 Apr 2019 15:25:12 -0400 (EDT)
Received: from localhost (ip6-localhost [IPv6:::1])
	by mail.efficios.com (Postfix) with ESMTP id 037CE1D6454;
	Tue, 16 Apr 2019 15:25:12 -0400 (EDT)
DKIM-Filter: OpenDKIM Filter v2.10.3 mail.efficios.com 037CE1D6454
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=efficios.com;
	s=default; t=1555442712;
	bh=dBAHxV+5AMeW0yIbrFxTc9ZyYkcIIhy/PrmkHPHr6wE=;
	h=Date:From:To:Message-ID:MIME-Version;
	b=QUJABhXu/WNVZ7zNbafJdZ7I78dLNA53TOuoh05mrHWGIFzEAxzioMOGQSGLnvUU8
	 VVz+4Y8GHSkXGAiG205Hp5mdM0OlQk0f4mkP4q1FdkWiD8bqED3ffXQ71Ueo9lbnVe
	 Vfn3BxKwAsaNV5mEDCWli7PpI1lmZ+q71tVuJs24yAHrPrRr8/WyNw2Mls/AyWnIxT
	 uS0dU9VFKZOag3fkYtRml29JIiQb2rs951nodm4mAEzHlXkL3CIWf0VPHaszf6GpQ9
	 wizmnVmiFXTYenblJJ1JCmn5gHzeBdwmuHIwKeO3KVrTNHbYL0J5gpmoZM1lFmFS1j
	 oHqy41bvVmK+A==
X-Virus-Scanned: amavisd-new at efficios.com
Received: from mail.efficios.com ([IPv6:::1])
	by localhost (mail02.efficios.com [IPv6:::1]) (amavisd-new, port 10026)
	with ESMTP id VWNPj0DABGiH; Tue, 16 Apr 2019 15:25:11 -0400 (EDT)
Received: from mail02.efficios.com (mail02.efficios.com [167.114.142.138])
	by mail.efficios.com (Postfix) with ESMTP id C6EBE1D644A;
	Tue, 16 Apr 2019 15:25:11 -0400 (EDT)
Date: Tue, 16 Apr 2019 15:25:11 -0400 (EDT)
From: Mathieu Desnoyers <mathieu.desnoyers@efficios.com>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Guenter Roeck <groeck@google.com>, Kees Cook <keescook@chromium.org>, 
	kernelci <kernelci@groups.io>, 
	Guillaume Tucker <guillaume.tucker@collabora.com>, 
	Mike Rapoport <rppt@linux.ibm.com>, 
	Andrew Morton <akpm@linux-foundation.org>, 
	Michal Hocko <mhocko@suse.com>, Mark Brown <broonie@kernel.org>, 
	Tomeu Vizoso <tomeu.vizoso@collabora.com>, 
	Matt Hart <matthew.hart@linaro.org>, 
	Stephen Rothwell <sfr@canb.auug.org.au>, 
	Kevin Hilman <khilman@baylibre.com>, 
	Enric Balletbo i Serra <enric.balletbo@collabora.com>, 
	Nicholas Piggin <npiggin@gmail.com>, 
	linux <linux@dominikbrodowski.net>, 
	Masahiro Yamada <yamada.masahiro@socionext.com>, 
	Adrian Reber <adrian@lisas.de>, 
	linux-kernel <linux-kernel@vger.kernel.org>, 
	Johannes Weiner <hannes@cmpxchg.org>, linux-mm <linux-mm@kvack.org>, 
	Richard Guy Briggs <rgb@redhat.com>, 
	Peter Zijlstra <peterz@infradead.org>, info <info@kernelci.org>, 
	rostedt <rostedt@goodmis.org>, Jason Baron <jbaron@redhat.com>, 
	Rabin Vincent <rabin@rab.in>, 
	Russell King <rmk+kernel@arm.linux.org.uk>
Message-ID: <2030770457.2767.1555442711654.JavaMail.zimbra@efficios.com>
In-Reply-To: <1444448267.2739.1555442221738.JavaMail.zimbra@efficios.com>
References: <20190215185151.GG7897@sirena.org.uk> <CABXOdTdVvFn=Nbd_Anhz7zR1H-9QeGByF3HFg4ZFt58R8=H6zA@mail.gmail.com> <CAGXu5j+Sw2FyMc8L+8hTpEKbOsySFGrCmFtVP5gt9y2pJhYVUw@mail.gmail.com> <CABXOdTcXWf9iReoocaj9rZ7z17zt-62iPDuvQQSrQRtMeeZNiA@mail.gmail.com> <CAPcyv4i8xhA6B5e=YBq2Z5kooyUpYZ8Bv9qov-mvqm4Uz=KLWQ@mail.gmail.com> <CABXOdTc5=J7ZFgbiwahVind-SNt7+G_-TVO=v-Y5SBVPLdUFog@mail.gmail.com> <CAPcyv4gxk9xbsP3YSKzxu5Yp9FTefyxHc6xC33GwZ3Zf9_eeKA@mail.gmail.com> <1444448267.2739.1555442221738.JavaMail.zimbra@efficios.com>
Subject: Re: next/master boot bisection: next-20190215 on beaglebone-black
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
X-Originating-IP: [167.114.142.138]
X-Mailer: Zimbra 8.8.12_GA_3794 (ZimbraWebClient - FF66 (Linux)/8.8.12_GA_3794)
Thread-Topic: next/master boot bisection: next-20190215 on beaglebone-black
Thread-Index: o2XfqTzgA9kPUT1d7tzJPHm/yG+fqP8/3aj6
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

----- On Apr 16, 2019, at 3:17 PM, Mathieu Desnoyers mathieu.desnoyers@efficios.com wrote:

> ----- On Apr 16, 2019, at 2:54 PM, Dan Williams dan.j.williams@intel.com wrote:
> 
>> On Thu, Apr 11, 2019 at 1:54 PM Guenter Roeck <groeck@google.com> wrote:
>> [..]
>>> > > Boot tests report
>>> > >
>>> > > Qemu test results:
>>> > >     total: 345 pass: 345 fail: 0
>>> > >
>>> > > This is on top of next-20190410 with CONFIG_SHUFFLE_PAGE_ALLOCATOR=y
>>> > > and the known crashes fixed.
>>> >
>>> > In addition to CONFIG_SHUFFLE_PAGE_ALLOCATOR=y you also need the
>>> > kernel command line option "page_alloc.shuffle=1"
>>> >
>>> > ...so I doubt you are running with shuffling enabled. Another way to
>>> > double check is:
>>> >
>>> >    cat /sys/module/page_alloc/parameters/shuffle
>>>
>>> Yes, you are right. Because, with it enabled, I see:
>>>
>>> Kernel command line: rdinit=/sbin/init page_alloc.shuffle=1 panic=-1
>>> console=ttyAMA0,115200 page_alloc.shuffle=1
>>> ------------[ cut here ]------------
>>> WARNING: CPU: 0 PID: 0 at ./include/linux/jump_label.h:303
>>> page_alloc_shuffle+0x12c/0x1ac
>>> static_key_enable(): static key 'page_alloc_shuffle_key+0x0/0x4' used
>>> before call to jump_label_init()
>> 
>> This looks to be specific to ARM never having had to deal with
>> DEFINE_STATIC_KEY_TRUE in the past.
>> 
>> I am able to avoid this warning by simply not enabling JUMP_LABEL
>> support in my build.
> 
> How large is your kernel image in memory ? Is it larger than 32MB
> by any chance ?
> 
> On arm, the arch_static_branch() uses a "nop" instruction, which seems
> fine. However, I have a concern wrt arch_static_branch_jump():
> 
> arch/arm/include/asm/jump_label.h defines:
> 
> static __always_inline bool arch_static_branch_jump(struct static_key *key, bool
> branch)
> {
>        asm_volatile_goto("1:\n\t"
>                 WASM(b) " %l[l_yes]\n\t"
>                 ".pushsection __jump_table,  \"aw\"\n\t"
>                 ".word 1b, %l[l_yes], %c0\n\t"
>                 ".popsection\n\t"
>                 : :  "i" (&((char *)key)[branch]) :  : l_yes);
> 
>        return false;
> l_yes:
>        return true;
> }
> 
> Which should work fine as long as the branch target is within +/-32MB range of
> the branch instruction. However, based on
> http://infocenter.arm.com/help/index.jsp?topic=/com.arm.doc.dui0489e/Cihfddaf.html
> :
> 
> "Extending branch ranges
> 
> Machine-level B and BL instructions have restricted ranges from the address of
> the current instruction. However, you can use these instructions even if label
> is out of range. Often you do not know where the linker places label. When
> necessary, the linker adds code to enable longer branches. The added code is
> called a veneer."
> 
> So if by an odd chance this branch is turned into a longer branch by the linker,
> then
> the code pattern would be completely unexpected by arch/arm/kernel/jump_label.c.
> 
> Can you try with the following (untested) patch ?

The logic in my previous patch was bogus. Here is an updated version (untested):

diff --git a/arch/arm/include/asm/jump_label.h b/arch/arm/include/asm/jump_label.h
index e12d7d096fc0..7c35f57b72c5 100644
--- a/arch/arm/include/asm/jump_label.h
+++ b/arch/arm/include/asm/jump_label.h
@@ -23,12 +23,21 @@ static __always_inline bool arch_static_branch(struct static_key *key, bool bran
        return true;
 }
 
+/*
+ * The linker adds veneer code if target of the branch is beyond +/-32MB
+ * range, so ensure we never patch a branch instruction which target is
+ * outside of the inline asm.
+ */
 static __always_inline bool arch_static_branch_jump(struct static_key *key, bool branch)
 {
        asm_volatile_goto("1:\n\t"
+                WASM(nop) "\n\t"
+                WASM(b) "2f\n\t"
+               "3:\n\t"
                 WASM(b) " %l[l_yes]\n\t"
+               "2:\n\t"
                 ".pushsection __jump_table,  \"aw\"\n\t"
-                ".word 1b, %l[l_yes], %c0\n\t"
+                ".word 1b, 3b, %c0\n\t"
                 ".popsection\n\t"
                 : :  "i" (&((char *)key)[branch]) :  : l_yes);

Thanks,

Mathieu

-- 
Mathieu Desnoyers
EfficiOS Inc.
http://www.efficios.com

