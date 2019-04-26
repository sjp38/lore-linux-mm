Return-Path: <SRS0=i6a/=S4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 92B9BC43218
	for <linux-mm@archiver.kernel.org>; Fri, 26 Apr 2019 21:26:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 41514206A3
	for <linux-mm@archiver.kernel.org>; Fri, 26 Apr 2019 21:26:42 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="KFqBx7lJ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 41514206A3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BFD636B0003; Fri, 26 Apr 2019 17:26:41 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BAA736B0005; Fri, 26 Apr 2019 17:26:41 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AC2416B0006; Fri, 26 Apr 2019 17:26:41 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 6F5C26B0003
	for <linux-mm@kvack.org>; Fri, 26 Apr 2019 17:26:41 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id f7so2836761pgi.20
        for <linux-mm@kvack.org>; Fri, 26 Apr 2019 14:26:41 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc
         :content-transfer-encoding;
        bh=VEK4EQKY+lHbgrInTqADydnKPftbhoL1fL3jVGMPkWw=;
        b=GugBtXOH/MPTjcWGHyrfCQQhB1GpJFQmNwVtePMLJiR5dNTM2TluDFA6X7h8ZNmYo1
         deNTqXCmkCMMl+z5O26P+C2bmumDUvJ/HjM9md3aVwHd+DR357R5UV4GzcT3ts3CFU7X
         o6HYz0kVOlx6YtBcaO28ova85JppxJDbbD8qQnSK+wUzkuKEtBZf37UYnAD03bl1pJJD
         /u/otu7gtpELpFfLFz+I2t5tiZlS4iZ3buxu8gE1d/fAsIVA4VLtD/gCKK+jLseWbzCy
         3KjfrjHdYl/rUeKX6IP4sclOJQFBW3Oc2VgaqIvL2qYyIxxDiBIqTTk9ZK5hm/79gTZ/
         DQ8w==
X-Gm-Message-State: APjAAAX+mOn5lGZhuwAVtja2q555YT3VxTg18CHZk8YoreBud5bddIdV
	ubx/ptrTf9ch/N70K4mmS03xcgnIpuaRalObtAJOEkiM9K/M8PAtT2naewfuUsBi5Yztkt6t3se
	DMJWF+S3gQ9jzs4P4GYpym/jEsTMvJ6kPJGids+nX+AsYNhMcL53pfC6uzhRHJHFm+Q==
X-Received: by 2002:a17:902:a5cb:: with SMTP id t11mr19155234plq.268.1556314001025;
        Fri, 26 Apr 2019 14:26:41 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy0xclf6sN+8Lb7AoqrClUXYGzmYwWSMSHOFaAHzoVkUUo/x8vKveJtdRnQSVdNA4nTzrQi
X-Received: by 2002:a17:902:a5cb:: with SMTP id t11mr19155190plq.268.1556314000102;
        Fri, 26 Apr 2019 14:26:40 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556314000; cv=none;
        d=google.com; s=arc-20160816;
        b=KlRFzhF4r5l71q+hBC9vyw2enGZSM7wKwvDH3zGh0ycLpCMizvZcX2JpqmJXVTg89F
         Az176z+CyRHijYML5wh6oGACLXDWi1ZOScuX+frUs5Zr/eLY5mCy22iCqty1WVaCKtLv
         tX7v4FDkIYXFvb6pMavMdukvbrePpaVEEm0DQRavQMGBqUyD7hFL+4HpmIst6qxBYMWF
         B+yf/HJ+vh02/hLYzlOTI4jrm0pqsXsjOIyPR1z+PoTo7IAGLNw4rCVH/5E40B1OB2+B
         dzt9m/PTP/pQBZwdUsiRY9zd9aBOuuuR7VweklRu0uwwfE4LJ6KuMFJNOPIbNDRBluuY
         0vtA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=VEK4EQKY+lHbgrInTqADydnKPftbhoL1fL3jVGMPkWw=;
        b=mdK3clhgM+k6Ra/KaFIa5ky8cJ+fjtnrzcVX95yy1a2jAueaiuUCGVQZP+oeuwu1EW
         6M1k7sO1j+JTfv8iOBMi1u0TtN9dJvB4iyj4QlP2RVp1HOp6XkanKWmb/MEE4sgY2MvL
         Z2SPATpOjXiD6iFKZclxSaBlAMtGVCJ+HJjq9KSwkSOS4pCNzefotlNI2sKE5BfJ4wOW
         AzJ5mqRDuGZrR+89VmuI/vrF+N9fHTn3h6StcDOt9lPtfEXss0MOD7mVAMZwXzAEM7AB
         8Ti0/Xl9+nItMY+1no5AVERoPM0u6IRYiN/QQ0U96A+Pngq4B0ZJccuRBz4KqK6HspAM
         hOqg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=KFqBx7lJ;
       spf=pass (google.com: domain of luto@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=luto@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id y15si26370332plp.357.2019.04.26.14.26.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 26 Apr 2019 14:26:40 -0700 (PDT)
Received-SPF: pass (google.com: domain of luto@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=KFqBx7lJ;
       spf=pass (google.com: domain of luto@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=luto@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-wm1-f43.google.com (mail-wm1-f43.google.com [209.85.128.43])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 80B542077B
	for <linux-mm@kvack.org>; Fri, 26 Apr 2019 21:26:39 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1556313999;
	bh=D0t+02sSwcut5ajzNNivlJU0Ro11fXksLOee2pRrCfg=;
	h=References:In-Reply-To:From:Date:Subject:To:Cc:From;
	b=KFqBx7lJ2xW/ZYaXv2tmORF55+e/veZZXqQxhZIbRAnePpvb1GCT5XYj1AD/huJEH
	 iI1AgObnyI+W19QqZRYgfw/E6RYOX1P5dY0hC8gkxHhdUxRWBGcXxbO5JlStPsGXIr
	 OWZIvKE14i9KB8xnl8JGYbKLum/88xqqSVfwjhAE=
Received: by mail-wm1-f43.google.com with SMTP id c1so5435191wml.4
        for <linux-mm@kvack.org>; Fri, 26 Apr 2019 14:26:39 -0700 (PDT)
X-Received: by 2002:a05:600c:211a:: with SMTP id u26mr9839645wml.74.1556313998090;
 Fri, 26 Apr 2019 14:26:38 -0700 (PDT)
MIME-Version: 1.0
References: <1556228754-12996-1-git-send-email-rppt@linux.ibm.com>
 <1556228754-12996-3-git-send-email-rppt@linux.ibm.com> <20190426083144.GA126896@gmail.com>
 <20190426095802.GA35515@gmail.com>
In-Reply-To: <20190426095802.GA35515@gmail.com>
From: Andy Lutomirski <luto@kernel.org>
Date: Fri, 26 Apr 2019 14:26:26 -0700
X-Gmail-Original-Message-ID: <CALCETrV3xZdaMn_MQ5V5nORJbcAeMmpc=gq1=M9cmC_=tKVL3A@mail.gmail.com>
Message-ID: <CALCETrV3xZdaMn_MQ5V5nORJbcAeMmpc=gq1=M9cmC_=tKVL3A@mail.gmail.com>
Subject: Re: [RFC PATCH 2/7] x86/sci: add core implementation for system call isolation
To: Ingo Molnar <mingo@kernel.org>
Cc: Mike Rapoport <rppt@linux.ibm.com>, LKML <linux-kernel@vger.kernel.org>, 
	Alexandre Chartre <alexandre.chartre@oracle.com>, Andy Lutomirski <luto@kernel.org>, 
	Borislav Petkov <bp@alien8.de>, Dave Hansen <dave.hansen@linux.intel.com>, 
	"H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@redhat.com>, 
	James Bottomley <James.Bottomley@hansenpartnership.com>, Jonathan Adams <jwadams@google.com>, 
	Kees Cook <keescook@chromium.org>, Paul Turner <pjt@google.com>, 
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

> On Apr 26, 2019, at 2:58 AM, Ingo Molnar <mingo@kernel.org> wrote:
>
>
> * Ingo Molnar <mingo@kernel.org> wrote:
>
>> I really don't like it where this is going. In a couple of years I
>> really want to be able to think of PTI as a bad dream that is mostly
>> over fortunately.
>>
>> I have the feeling that compiler level protection that avoids
>> corrupting the stack in the first place is going to be lower overhead,
>> and would work in a much broader range of environments. Do we have
>> analysis of what the compiler would have to do to prevent most ROP
>> attacks, and what the runtime cost of that is?
>>
>> I mean, C# and Java programs aren't able to corrupt the stack as long
>> as the language runtime is corect. Has to be possible, right?
>
> So if such security feature is offered then I'm afraid distros would be
> strongly inclined to enable it - saying 'yes' to a kernel feature that
> can keep your product off CVE advisories is a strong force.
>
> To phrase the argument in a bit more controversial form:
>
>   If the price of Linux using an insecure C runtime is to slow down
>   system calls with immense PTI-alike runtime costs, then wouldn't it be
>   the right technical decision to write the kernel in a language runtime
>   that doesn't allow stack overflows and such?
>
> I.e. if having Linux in C ends up being slower than having it in Java,
> then what's the performance argument in favor of using C to begin with?
> ;-)
>
> And no, I'm not arguing for Java or C#, but I am arguing for a saner
> version of C.
>
>

IMO three are three credible choices:

1. C with fairly strong CFI protection. Grsecurity has his (supposedly
=E2=80=94 there=E2=80=99s a distinct lack of source code available), and cl=
ang is
gradually working on it.

2. A safe language for parts of the kernel, e.g. drivers and maybe
eventually filesystems.  Rust is probably the only credible candidate.
Actually creating a decent Rust wrapper around the core kernel
facilities would be quite a bit of work.  Things like sysfs would be
interesting in Rust, since AFAIK few or even no drivers actually get
the locking fully correct.  This means that naive users of the API
cannot port directly to safe Rust, because all the races won't compile
:)

3. A sandbox for parts of the kernel, e.g. drivers.  The obvious
candidates are eBPF and WASM.

#2 will give very good performance.  #3 gives potentially stronger
protection against a sandboxed component corrupting the kernel
overall, but it gives much weaker protection against a sandboxed
component corrupting itself.

In an ideal world, we could do #2 *and* #3.  Drivers could, for
example, be written in a language like Rust, compiled to WASM, and run
in the kernel.

