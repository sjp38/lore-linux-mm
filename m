Return-Path: <SRS0=5PTg=UG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4C1FDC2BA1D
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 01:55:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D91A920868
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 01:55:02 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=amacapital-net.20150623.gappssmtp.com header.i=@amacapital-net.20150623.gappssmtp.com header.b="S00yQNLR"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D91A920868
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=amacapital.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 48B586B0305; Thu,  6 Jun 2019 21:55:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 415536B0306; Thu,  6 Jun 2019 21:55:02 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2B5BC6B0307; Thu,  6 Jun 2019 21:55:02 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id E1CFE6B0305
	for <linux-mm@kvack.org>; Thu,  6 Jun 2019 21:55:01 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id z1so374671pfb.7
        for <linux-mm@kvack.org>; Thu, 06 Jun 2019 18:55:01 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:subject:from
         :in-reply-to:date:cc:content-transfer-encoding:message-id:references
         :to;
        bh=/XNZ/gn51wIkX7j4GJydFoEsiDY7sJR4sMnUtxZM9Ww=;
        b=SlmHPXiuJquwktLMjqQYVVf8PeCEfc/3itfjl0ncjNO6skhOSghG7LyiTfR70OFhk2
         /CBoFWWAoo3agZpO1sCmlOX6gPUbk/IYtDe+X+iUnAYLd/FMtLHAlzYHY642XHdtE4Bp
         +H0m7e9cRr1C9hGG5Np7efVoNgoqp6EpD/Lonk8vpbymEplxsJgjLojPZMOQp+zRx3iN
         HbSVbRITI3FDlB724PCAAYNsmVeEHWcIkc/PDOrU29wqeLE/LD6ZYshFgTI3VGZS10Ai
         BcqVNpD7tb5+tdzg9pEvNJ3/AfYwyqdgCDpXLJL1sCLuiXm658TPayK8R5Ln2Ws9LEmS
         JDvA==
X-Gm-Message-State: APjAAAV+/trSJwhyrVzUFtFDmA2xpI0MYxuecld6neh5tWvk+bxxToVo
	YEuz4LXfRO73k4FbZa/wAaeO1BXcleM81fYwjH2lRztDWuKedVab9vaW0bEVJ07ewfLML9FFHXk
	YEP/fqB3PM4nSdojEoUeXhSJB8JhPhyo4guSLp4hjRMRszxncyyOdQgUQqmFjgdx4Kg==
X-Received: by 2002:a17:90a:cb12:: with SMTP id z18mr2758473pjt.82.1559872501351;
        Thu, 06 Jun 2019 18:55:01 -0700 (PDT)
X-Received: by 2002:a17:90a:cb12:: with SMTP id z18mr2758419pjt.82.1559872500229;
        Thu, 06 Jun 2019 18:55:00 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559872500; cv=none;
        d=google.com; s=arc-20160816;
        b=GfT0xdkyn3lwLZmPeHpW0yWs1hHnlREk37QPiYp8yN37QYf5z7MAxA7fmpUCneYaNh
         fkdgJ6CzBTThclP3qnLjP5eW3nLDdLxZKLk08q5ZTSfDnnK1eBLTpSYy6TOG+bdpHg5v
         hdDWpDNGEvwD1bvlHzhDOP3diYjEQJq76nglzZZtpVBixk8CZ9589S83FJ1L2xcGrgnL
         8HXwTuvSelzs06MCcJtE6s8KuJoKwIJOaaB73BxKIJ4+t+DpBEUzUxeHngM/OeSxO3GJ
         KKf6LoTKvtUZ+Ftjnsp+s24pj7sWcxuL847hXrjPRqkJt7/HBVzM4AwxJ/yt/OUjy/Kr
         0tWw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=to:references:message-id:content-transfer-encoding:cc:date
         :in-reply-to:from:subject:mime-version:dkim-signature;
        bh=/XNZ/gn51wIkX7j4GJydFoEsiDY7sJR4sMnUtxZM9Ww=;
        b=ZjLwWsWxbDjbI8uWKnNn/RIzxkL7B6jC0oQ25B4hSMOfkyZMPpp1E5kR1g8A0r7gjB
         9I43+O824b+SIfbRwYlJb1lsEAbdPkk9tGZnb9Ap93HCouxtvs8Q2E9eFN9lYWlxQlMD
         HcrgVZuN6yu2YWpf8Vp1GOM3VT/WVBL1YVFyvd5voxf4kkC5mjSfXDST97m3sRg0uIzv
         hkDb3R5Cm8c428beITP8ZZbL2MToVGsnEu+2v+QlVdxZJ+eIMBLV4QRsxQOFfZPIEq58
         BVPx5CGMMUAFzLFjnqxg7tx+iyeqvi5fXZo6VxQvDd+Y4Vf6+QqSBttaq6mvcMy7rfGO
         QzQQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@amacapital-net.20150623.gappssmtp.com header.s=20150623 header.b=S00yQNLR;
       spf=pass (google.com: domain of luto@amacapital.net designates 209.85.220.65 as permitted sender) smtp.mailfrom=luto@amacapital.net
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l10sor446683pgg.80.2019.06.06.18.55.00
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 06 Jun 2019 18:55:00 -0700 (PDT)
Received-SPF: pass (google.com: domain of luto@amacapital.net designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@amacapital-net.20150623.gappssmtp.com header.s=20150623 header.b=S00yQNLR;
       spf=pass (google.com: domain of luto@amacapital.net designates 209.85.220.65 as permitted sender) smtp.mailfrom=luto@amacapital.net
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=amacapital-net.20150623.gappssmtp.com; s=20150623;
        h=mime-version:subject:from:in-reply-to:date:cc
         :content-transfer-encoding:message-id:references:to;
        bh=/XNZ/gn51wIkX7j4GJydFoEsiDY7sJR4sMnUtxZM9Ww=;
        b=S00yQNLRvIJQua4YR2yQ8RVqPpjOLFHnBiFwSeuMasOSY6c6h0vWJcYdiY0Z5PM7YO
         UipjM0ZF3UJgTbpzpruGqkllwmSh27VqFfBLmFFRQi48/y8vwP9lfsfd1fCr5GrWmx5U
         +mrmTnh77qX/LJSmeUNVANIViSYH3SG9JLjQyxwvqhhXs4F5aW2xz3ZH+yMIfMncHUn7
         BZCifuSpPT/N5rehXs3PF3WLzPimeqB/ooyW1/Bai8dhKtLnZ1mXZqIsmM2S1UwixE+q
         zrtDne+gd7Z1LmEC/CuXvREAfd8SGdoCJ9NGUyq3IAdCLPX1ELUdL2u8V6EHYI+JY9jt
         x5FA==
X-Google-Smtp-Source: APXvYqxx9s4fm3uOOHPSgMwgRlcgiy2DYwvEjaAWxVGCEthCLU5MAxClyI51h2SMQiGI5Wkj9aU4lw==
X-Received: by 2002:a65:508b:: with SMTP id r11mr631484pgp.387.1559872499664;
        Thu, 06 Jun 2019 18:54:59 -0700 (PDT)
Received: from ?IPv6:2600:1010:b02c:95e1:658b:ab88:7a44:1879? ([2600:1010:b02c:95e1:658b:ab88:7a44:1879])
        by smtp.gmail.com with ESMTPSA id w190sm391940pgw.51.2019.06.06.18.54.57
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Jun 2019 18:54:58 -0700 (PDT)
Content-Type: text/plain;
	charset=utf-8
Mime-Version: 1.0 (1.0)
Subject: Re: [PATCH v7 04/27] x86/fpu/xstate: Introduce XSAVES system states
From: Andy Lutomirski <luto@amacapital.net>
X-Mailer: iPhone Mail (16F203)
In-Reply-To: <4effb749-0cdc-6a49-6352-7b2d4aa7d866@intel.com>
Date: Thu, 6 Jun 2019 18:54:56 -0700
Cc: Yu-cheng Yu <yu-cheng.yu@intel.com>, x86@kernel.org,
 "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>,
 Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org,
 linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org,
 linux-api@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>,
 Balbir Singh <bsingharora@gmail.com>, Borislav Petkov <bp@alien8.de>,
 Cyrill Gorcunov <gorcunov@gmail.com>,
 Dave Hansen <dave.hansen@linux.intel.com>,
 Eugene Syromiatnikov <esyr@redhat.com>,
 Florian Weimer <fweimer@redhat.com>, "H.J. Lu" <hjl.tools@gmail.com>,
 Jann Horn <jannh@google.com>, Jonathan Corbet <corbet@lwn.net>,
 Kees Cook <keescook@chromium.org>, Mike Kravetz <mike.kravetz@oracle.com>,
 Nadav Amit <nadav.amit@gmail.com>, Oleg Nesterov <oleg@redhat.com>,
 Pavel Machek <pavel@ucw.cz>, Peter Zijlstra <peterz@infradead.org>,
 Randy Dunlap <rdunlap@infradead.org>,
 "Ravi V. Shankar" <ravi.v.shankar@intel.com>,
 Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>,
 Dave Martin <Dave.Martin@arm.com>
Content-Transfer-Encoding: quoted-printable
Message-Id: <2F0417F1-DA1E-4632-AFA2-757C09B3C4B4@amacapital.net>
References: <20190606200646.3951-1-yu-cheng.yu@intel.com> <20190606200646.3951-5-yu-cheng.yu@intel.com> <0a2f8b9b-b96b-06c8-bae0-b78b2ca3b727@intel.com> <5EE146A8-6C8C-4C5D-B7C0-AB8AD1012F1E@amacapital.net> <4effb749-0cdc-6a49-6352-7b2d4aa7d866@intel.com>
To: Dave Hansen <dave.hansen@intel.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



> On Jun 6, 2019, at 3:08 PM, Dave Hansen <dave.hansen@intel.com> wrote:
>=20
>=20
>=20
> On 6/6/19 3:04 PM, Andy Lutomirski wrote:
>>> But, that seems broken.  If we have supervisor state, we can't=20
>>> always defer the load until return to userspace, so we'll never??=20
>>> have TIF_NEED_FPU_LOAD.  That would certainly be true for=20
>>> cet_kernel_state.
>>=20
>> Ugh. I was sort of imagining that we would treat supervisor state
> completely separately from user state.  But can you maybe give
> examples of exactly what you mean?

I was imagining a completely separate area in memory for supervisor states. =
 I guess this might defeat the modified optimization and is probably a bad i=
dea.

>>=20
>>> It seems like we actually need three classes of XSAVE states: 1.=20
>>> User state
>>=20
>> This is FPU, XMM, etc, right?
>=20
> Yep.
>=20
>>> 2. Supervisor state that affects user mode
>>=20
>> User CET?
>=20
> Yep.
>=20
>>> 3. Supervisor state that affects kernel mode
>>=20
>> Like supervisor CET?  If we start doing supervisor shadow stack, the=20
>> context switches will be real fun.  We may need to handle this in=20
>> asm.
>=20
> Yeah, that's what I was thinking.
>=20
> I have the feeling Yu-cheng's patches don't comprehend this since
> Sebastian's patches went in after he started working on shadow stacks.

Do we need to have TIF_LOAD_FPU mean =E2=80=9Cwe need to load *some* of the x=
save state=E2=80=9D?  If so, maybe a bunch of the accessors should have thei=
r interfaces reviewed to make sure they=E2=80=99re sill sensible.

>=20
>> Where does PKRU fit in?  Maybe we can treat it as #3?
>=20
> I thought Sebastian added specific PKRU handling to make it always
> eager.  It's actually user state that affect kernel mode. :)

Indeed.  But, if we document a taxonomy of states, we should make sure it fi=
ts in. I guess it=E2=80=99s like supervisor CET except that user code can ca=
n also read and write it.

We should probably have self tests that make sure that the correct states, a=
nd nothing else, show up in ptrace and signal states, and that trying to wri=
te supervisor CET via ptrace and sigreturn is properly rejected.

Just to double check my mental model: it=E2=80=99s okay to XSAVES twice to t=
he same buffer with disjoint RFBM as long as we do something intelligent wit=
h XSTATE_BV afterwards, right?  Because, unless we split up the buffers, I t=
hink we will have to do this when we context switch while TIF_LOAD_FPU is se=
t.

Are there performance numbers for how the time needed to XRSTORS everything v=
ersus the time to XRSTORS supervisor CET and then separately XRSTORS the FPU=
?  This may affect whether we want context switches to have the new task eag=
erly or lazily restored.

Hmm. I wonder if we need some way for a selftest to reliably trigger TIF_LOA=
D_FPU.

=E2=80=94Andy=

