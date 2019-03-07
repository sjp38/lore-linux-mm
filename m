Return-Path: <SRS0=NBIx=RK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 780A0C43381
	for <linux-mm@archiver.kernel.org>; Thu,  7 Mar 2019 16:44:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2DB4A20840
	for <linux-mm@archiver.kernel.org>; Thu,  7 Mar 2019 16:44:28 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2DB4A20840
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=zytor.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BDBC58E0006; Thu,  7 Mar 2019 11:44:27 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B94178E0002; Thu,  7 Mar 2019 11:44:27 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A54198E0006; Thu,  7 Mar 2019 11:44:27 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f199.google.com (mail-it1-f199.google.com [209.85.166.199])
	by kanga.kvack.org (Postfix) with ESMTP id 7AE0A8E0002
	for <linux-mm@kvack.org>; Thu,  7 Mar 2019 11:44:27 -0500 (EST)
Received: by mail-it1-f199.google.com with SMTP id 190so9228864itv.3
        for <linux-mm@kvack.org>; Thu, 07 Mar 2019 08:44:27 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date
         :user-agent:in-reply-to:references:mime-version
         :content-transfer-encoding:subject:to:cc:from:message-id;
        bh=5lUIASWOPPLo0ZLO5Ni9PHbpPy1m/vI/jQgxWuGHDLE=;
        b=HX8v4jJIgYpUqNroYmJmLZgn/RJR5ahe+Vn0dbcTlPGCDybTfoQ9k6/7J4iFVpW14Z
         zvErt9TnJagmc808u3S0PXVghLZVQfABqcfju30y3dxRdoEcJhIn5y5yey41FdiV+BEA
         4UYuVnkPui5MUpSpgNznD7BfXXK3/LWN/FRQIQ7MoOQWIrrPUNcRrWKDDBiAU6JgaBS0
         8/pYk01ha7c5XKYkisjFGHW+bacQwBsIwMrovUFDXWhxoiEkqSwXkg3he8nxhFJiqH40
         miRU2I9coMN9xPK+P0+OTRFcg9bEuuQy52RA5dzyP9TLjmh+IZg4TfKcRURjNgUUdNWi
         l3ow==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of hpa@zytor.com designates 198.137.202.136 as permitted sender) smtp.mailfrom=hpa@zytor.com
X-Gm-Message-State: APjAAAXyDBphSlVeN8KEmlcP1dVBSemR9Q+EKiywBHUrq0CnB/+GE4eO
	vZEB5ZwVdJ4lg+Nd8OtNwP+UXEeU4ig+dlYqGxTYGpqE9cxF+WhfS/XH1f66TQqd1zyUb6gW7lL
	R64PjOWkj8Poyh9/L29O4w8d2vvK0R8T+lXodgOs1c2putmhR7TcbWID1EuQ6/tw6eg==
X-Received: by 2002:a5d:8185:: with SMTP id u5mr7145746ion.216.1551977067278;
        Thu, 07 Mar 2019 08:44:27 -0800 (PST)
X-Google-Smtp-Source: APXvYqzNTmZvOZ/l1lyIoyi0ywcfbqwyvtZsbMwZA7fuz3eGXNsGPh3/RPWgenHk1vMtzCI6fN6L
X-Received: by 2002:a5d:8185:: with SMTP id u5mr7145685ion.216.1551977066347;
        Thu, 07 Mar 2019 08:44:26 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551977066; cv=none;
        d=google.com; s=arc-20160816;
        b=bzJE+EnDLXFSAzs/bQt+8kEUrf949kUkwfMjO+i2UwmC2JUm5JhQecIEw99LdtD6JV
         LFzXpq3tuBznIfhKBHJ+CbcZPuwhvxIIOLrKb26fLj7Aa2Zgk+DVxH6qrnwgK8BaAZcn
         3ncOM7CuZhzlYMGolvHo3GGzjgBDLj9Nis2kP+/l4rxUWKGL86z5Bpc18EowRvYqpwcE
         miyBkbjUI09GOVjUz5PXhMVGK64T7CRqQRv2Ql2kGzEQhw7Eb33oG9N3dmHAlYScOa5S
         Pu1wznHIJHACaY9b+998affbC1W/bwclqYtWtkdz6ZitS5i1QNj5+GnPoonFiu3PSTjy
         jI8w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:from:cc:to:subject:content-transfer-encoding
         :mime-version:references:in-reply-to:user-agent:date;
        bh=5lUIASWOPPLo0ZLO5Ni9PHbpPy1m/vI/jQgxWuGHDLE=;
        b=E+phlZFqMKqodPawFQIr2jP/ZwhEQNBHSJWpAEImC0T/dVDi1JHk8ceLreb92P5cYj
         E4+5NShTwhvUV+DJ6HngUJPKDFyGzLHOpQrJZIRVsyvD9biT6ud9fMukwNpNp3P/pY/i
         pmVwaaqLK5GGnur9saVnNafwn9NxwkUDrCWvD9f9mHEtmK2pOfhHlbbIQ3+mSk0X66Ns
         1dt3pUFFODdX/HpnNFjEXUQKZk90bNv5xYEtoEzZPnrz2eqMWWiaJTJnWz3iKycBw4x7
         1lucUGX7iUc8V7MDJ2O7CHEf1ch2JiivQvh0xeD98iyd5jhpDHwbp484XTEIo883Eq0q
         1raw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of hpa@zytor.com designates 198.137.202.136 as permitted sender) smtp.mailfrom=hpa@zytor.com
Received: from mail.zytor.com (terminus.zytor.com. [198.137.202.136])
        by mx.google.com with ESMTPS id p131si2718027itb.139.2019.03.07.08.44.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 07 Mar 2019 08:44:26 -0800 (PST)
Received-SPF: pass (google.com: domain of hpa@zytor.com designates 198.137.202.136 as permitted sender) client-ip=198.137.202.136;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of hpa@zytor.com designates 198.137.202.136 as permitted sender) smtp.mailfrom=hpa@zytor.com
Received: from [IPv6:2607:fb90:363c:d311:852d:262d:594c:4506] ([IPv6:2607:fb90:363c:d311:852d:262d:594c:4506])
	(authenticated bits=0)
	by mail.zytor.com (8.15.2/8.15.2) with ESMTPSA id x27Ghstd2258097
	(version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128 verify=NO);
	Thu, 7 Mar 2019 08:43:55 -0800
Date: Thu, 07 Mar 2019 08:43:50 -0800
User-Agent: K-9 Mail for Android
In-Reply-To: <20190307151036.GD26566@zn.tnic>
References: <20190129003422.9328-1-rick.p.edgecombe@intel.com> <20190129003422.9328-11-rick.p.edgecombe@intel.com> <20190211182956.GN19618@zn.tnic> <1533F2BB-2284-499B-9912-6D74D0B87BC1@gmail.com> <20190211190108.GP19618@zn.tnic> <A671F14F-3E03-4A97-9F54-426533077E0C@gmail.com> <20190211191059.GR19618@zn.tnic> <3996E3F9-92D2-4561-84E9-68B43AC60F43@gmail.com> <20190211194251.GS19618@zn.tnic> <A55214F3-CDC0-44C4-AFB6-7E8E23CC6F85@gmail.com> <20190307151036.GD26566@zn.tnic>
MIME-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: quoted-printable
Subject: Re: [PATCH] x86/cpufeature: Remove __pure attribute to _static_cpu_has()
To: Borislav Petkov <bp@alien8.de>, Nadav Amit <nadav.amit@gmail.com>
CC: Rick Edgecombe <rick.p.edgecombe@intel.com>,
        Andy Lutomirski <luto@kernel.org>, Ingo Molnar <mingo@redhat.com>,
        LKML <linux-kernel@vger.kernel.org>, X86 ML <x86@kernel.org>,
        Thomas Gleixner <tglx@linutronix.de>,
        Dave Hansen <dave.hansen@linux.intel.com>,
        Peter Zijlstra <peterz@infradead.org>,
        Damian Tometzki <linux_dti@icloud.com>,
        linux-integrity <linux-integrity@vger.kernel.org>,
        LSM List <linux-security-module@vger.kernel.org>,
        Andrew Morton <akpm@linux-foundation.org>,
        Kernel Hardening <kernel-hardening@lists.openwall.com>,
        Linux-MM <linux-mm@kvack.org>, Will Deacon <will.deacon@arm.com>,
        Ard Biesheuvel <ard.biesheuvel@linaro.org>,
        Kristen Carlson Accardi <kristen@linux.intel.com>,
        "Dock, Deneen T" <deneen.t.dock@intel.com>,
        Kees Cook <keescook@chromium.org>, Dave Hansen <dave.hansen@intel.com>,
        Masami Hiramatsu <mhiramat@kernel.org>
From: hpa@zytor.com
Message-ID: <D683E00D-845E-4970-80DE-AD1DED3AE609@zytor.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On March 7, 2019 7:10:36 AM PST, Borislav Petkov <bp@alien8=2Ede> wrote:
>On Mon, Feb 11, 2019 at 12:32:41PM -0800, Nadav Amit wrote:
>> BTW: the =E2=80=9C__pure=E2=80=9D attribute is useless when =E2=80=9C__=
always_inline=E2=80=9D is
>used=2E
>> Unless it is intended to be some sort of comment, of course=2E
>
>---
>From: Borislav Petkov <bp@suse=2Ede>
>Date: Thu, 7 Mar 2019 15:54:51 +0100
>
>__pure is used to make gcc do Common Subexpression Elimination (CSE)
>and thus save subsequent invocations of a function which does a complex
>computation (without side effects)=2E As a simple example:
>
>  bool a =3D _static_cpu_has(x);
>  bool b =3D _static_cpu_has(x);
>
>gets turned into
>
>  bool a =3D _static_cpu_has(x);
>  bool b =3D a;
>
>However, gcc doesn't do CSE with asm()s when those get inlined - like
>it
>is done with _static_cpu_has() - because, for example, the t_yes/t_no
>labels are different for each inlined function body and thus cannot be
>detected as equivalent anymore for the CSE heuristic to hit=2E
>
>However, this all is beside the point because best it should be avoided
>to have more than one call to _static_cpu_has(X) in the same function
>due to the fact that each such call is an alternatives patch site and
>it
>is simply pointless=2E
>
>Therefore, drop the __pure attribute as it is not doing anything=2E
>
>Reported-by: Nadav Amit <nadav=2Eamit@gmail=2Ecom>
>Signed-off-by: Borislav Petkov <bp@suse=2Ede>
>Cc: Peter Zijlstra <peterz@infradead=2Eorg>
>Cc: x86@kernel=2Eorg
>---
> arch/x86/include/asm/cpufeature=2Eh | 2 +-
> 1 file changed, 1 insertion(+), 1 deletion(-)
>
>diff --git a/arch/x86/include/asm/cpufeature=2Eh
>b/arch/x86/include/asm/cpufeature=2Eh
>index e25d11ad7a88=2E=2E6d6d5cc4302b 100644
>--- a/arch/x86/include/asm/cpufeature=2Eh
>+++ b/arch/x86/include/asm/cpufeature=2Eh
>@@ -162,7 +162,7 @@ extern void clear_cpu_cap(struct cpuinfo_x86 *c,
>unsigned int bit);
>* majority of cases and you should stick to using it as it is generally
>  * only two instructions: a RIP-relative MOV and a TEST=2E
>  */
>-static __always_inline __pure bool _static_cpu_has(u16 bit)
>+static __always_inline bool _static_cpu_has(u16 bit)
> {
> 	asm_volatile_goto("1: jmp 6f\n"
> 		 "2:\n"

Uhm=2E=2E=2E (a) it is correct, even if the compiler doesn't use it now, i=
t allows the compiler to CSE it in the future; (b) it is documentation; (c)=
 there is an actual bug here: the "volatile" implies a side effect, which i=
n reality is not present, inhibiting CSE=2E

So the correct fix is to remove "volatile", not remove "__pure"=2E
--=20
Sent from my Android device with K-9 Mail=2E Please excuse my brevity=2E

