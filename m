Return-Path: <SRS0=5PTg=UG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1253FC468BD
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 22:27:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BCB4D205ED
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 22:27:21 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=amacapital-net.20150623.gappssmtp.com header.i=@amacapital-net.20150623.gappssmtp.com header.b="fAQwIxWx"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BCB4D205ED
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=amacapital.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4713B6B0274; Fri,  7 Jun 2019 18:27:21 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 420796B0275; Fri,  7 Jun 2019 18:27:21 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2E8516B0276; Fri,  7 Jun 2019 18:27:21 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id E3FD56B0274
	for <linux-mm@kvack.org>; Fri,  7 Jun 2019 18:27:20 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id f25so2431564pfk.14
        for <linux-mm@kvack.org>; Fri, 07 Jun 2019 15:27:20 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:subject:from
         :in-reply-to:date:cc:content-transfer-encoding:message-id:references
         :to;
        bh=hraLxNELwM1NZ3lrrobGX779u9y1WVgm2X9KZ6MnzVU=;
        b=UHBTAWGqeQ84FzJH5Y8NvxAJaknxVp3MgPSPIsCzeEXCdi1TTRATFVskhrnCYDl0Gv
         CxzfMFUZmXSnrT2pPSO1ars6KbQuzkuwlkMbt+Sk1w3R6GnIxyzDdPaeXSbNkSN6k+sj
         9gITQ2Igj2v6YuSdp+du3JAhYEXd/ViJlUAiBxawDGrAUM+XDTKZ8+3Scjbix01RG8aA
         GwrOwbgRzHlkBLW2xrNzF/24hFkPb3CIUYj6b2JhnnBukrdN2VeWcqNwXOsR8H5Ed8NG
         VjQ5IJTY+Q/jzA6bX9FGV60x9WZQS4oi0uDQISpRwCcc333NfREXdQKhNEZYbVov6BPH
         z4KA==
X-Gm-Message-State: APjAAAXCYCHWW3A3mMWuRLDgR3Z0SgRCcX3VCg85qyeND3C0++7jNiGW
	XcTDId4dHzNEhuojqBESabflpcQb3Qu0W+WiaVnf2Od6ypqcEvX7R6/ZiTNRw5D+QsCjEuJvB76
	/opcrP54gnX498kTuuta81rfr4MnjLwYfk31OuSNitdQHo1QkmoZcQ2WYdAHkZyPtjA==
X-Received: by 2002:a17:902:6bc8:: with SMTP id m8mr57111130plt.227.1559946440401;
        Fri, 07 Jun 2019 15:27:20 -0700 (PDT)
X-Received: by 2002:a17:902:6bc8:: with SMTP id m8mr57111109plt.227.1559946439796;
        Fri, 07 Jun 2019 15:27:19 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559946439; cv=none;
        d=google.com; s=arc-20160816;
        b=SINNdcC2F+UqA8rFjuNoQPq1fU5Q3ukDjbzo5VXrnGQIDw5kw90zRnfYSJ5QJiPw+H
         0HMND4KY22ajx88uFVmWSqVMQc91ZpNIMbbO2PobkF9ZLemdpVSiXKBDSKoSspyXru7g
         d4i/VjbjAcHl0NuvJzSnjxQrXpu+d2sDvy+xESspExcSoBGt7GHKVjYPGQjtDmf8OxGf
         JkQt6nYl3KzbEUx7pNld5m/pf0TeQa+pRHWgH3LwUrZix4B/VOW+wn1jqLhY/cvYjSmD
         vzjLZcG1OapU4zMA1/LG5emUV6csg68rfnTAlrnSPgbb4YOp3zsRNhbfhxGZDeW5/Mm5
         wrCA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=to:references:message-id:content-transfer-encoding:cc:date
         :in-reply-to:from:subject:mime-version:dkim-signature;
        bh=hraLxNELwM1NZ3lrrobGX779u9y1WVgm2X9KZ6MnzVU=;
        b=sVuhR+ZkpHvqzF/Sd3WhfaiohRYU5h+L4Lsg1UO0yya7WjhNXW49e3/BpYpseaH+q5
         LvApqpKn6MGZCrP56f3Aq6dIULBDuxSN9eci14SZdI8hZPDPd0JQohm33Jj3Vee+zfob
         slO2YE+BiTZerV4os031Gyo2jfOXR5gXGK/XUsVfr37bHpFC7qoJI+WcfhFP2AVqYFEX
         obUX2gd2uxbNljoucDu+HYQbxgrOiWQehjoBDsZWhYvMpAa68gUqJQdf5ZDMr/wgTe4J
         YYCXyz8To7gyig7yEQ0axOk+4mJaXoMS/YY1v0a84e7G/nc+wJJJS+0lNUhBTP0/vdEv
         RE6w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@amacapital-net.20150623.gappssmtp.com header.s=20150623 header.b=fAQwIxWx;
       spf=pass (google.com: domain of luto@amacapital.net designates 209.85.220.65 as permitted sender) smtp.mailfrom=luto@amacapital.net
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x189sor3485833pfx.37.2019.06.07.15.27.19
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 07 Jun 2019 15:27:19 -0700 (PDT)
Received-SPF: pass (google.com: domain of luto@amacapital.net designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@amacapital-net.20150623.gappssmtp.com header.s=20150623 header.b=fAQwIxWx;
       spf=pass (google.com: domain of luto@amacapital.net designates 209.85.220.65 as permitted sender) smtp.mailfrom=luto@amacapital.net
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=amacapital-net.20150623.gappssmtp.com; s=20150623;
        h=mime-version:subject:from:in-reply-to:date:cc
         :content-transfer-encoding:message-id:references:to;
        bh=hraLxNELwM1NZ3lrrobGX779u9y1WVgm2X9KZ6MnzVU=;
        b=fAQwIxWx36GcX9oIEt7f+jVMHginM+LONwFdfMNqwIhko+8c0QHYbEF8bNlyIqbI9j
         NQNEvOKC/rk/tH80WaLOxYfIeLrNuLs39w+NLcIj3q54Q271veY67rrkNFKpfdqfZfj7
         zJroDKjRWmVDQ90XGnNScGmFaTzL9du1I7zDspqbrM6NsrWdM1i+JbmO4PVz/elLIgeu
         6BrmpgiXUF9dz/S6HaFuV5ThOeSRhvAkGNBoMZMOPzaVaIgbNw2niqpkC+G9ce07EdDH
         qP3J8OITji6PPDgyiEOb7pbi42mIE/z0MQOvU/LZER5Na/CvkkoUFll6uwuMASm3splg
         LFTQ==
X-Google-Smtp-Source: APXvYqwFO3Q0DLnvBTYrA6mi0dVS8BZ1iVqUNQ4tJLNaZqwnxT+p/ehoHtcdu1qHh/Y6c+cHQmyQLA==
X-Received: by 2002:a62:3287:: with SMTP id y129mr55579697pfy.101.1559946439420;
        Fri, 07 Jun 2019 15:27:19 -0700 (PDT)
Received: from ?IPv6:2600:1012:b018:c314:403f:c95d:60d3:b732? ([2600:1012:b018:c314:403f:c95d:60d3:b732])
        by smtp.gmail.com with ESMTPSA id 2sm3147331pfo.41.2019.06.07.15.27.18
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 07 Jun 2019 15:27:18 -0700 (PDT)
Content-Type: text/plain;
	charset=utf-8
Mime-Version: 1.0 (1.0)
Subject: Re: [PATCH v7 03/14] x86/cet/ibt: Add IBT legacy code bitmap setup function
From: Andy Lutomirski <luto@amacapital.net>
X-Mailer: iPhone Mail (16F203)
In-Reply-To: <f6de9073-9939-a20d-2196-25fa223cf3fc@intel.com>
Date: Fri, 7 Jun 2019 15:27:16 -0700
Cc: Yu-cheng Yu <yu-cheng.yu@intel.com>,
 Peter Zijlstra <peterz@infradead.org>, x86@kernel.org,
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
 Pavel Machek <pavel@ucw.cz>, Randy Dunlap <rdunlap@infradead.org>,
 "Ravi V. Shankar" <ravi.v.shankar@intel.com>,
 Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>,
 Dave Martin <Dave.Martin@arm.com>
Content-Transfer-Encoding: quoted-printable
Message-Id: <4F7D0C3C-F239-4B67-BB05-31350F809293@amacapital.net>
References: <20190606200926.4029-1-yu-cheng.yu@intel.com> <20190606200926.4029-4-yu-cheng.yu@intel.com> <20190607080832.GT3419@hirez.programming.kicks-ass.net> <aa8a92ef231d512b5c9855ef416db050b5ab59a6.camel@intel.com> <20190607174336.GM3436@hirez.programming.kicks-ass.net> <b3de4110-5366-fdc7-a960-71dea543a42f@intel.com> <34E0D316-552A-401C-ABAA-5584B5BC98C5@amacapital.net> <7e0b97bf1fbe6ff20653a8e4e147c6285cc5552d.camel@intel.com> <4b448cde-ee4e-1c95-0f7f-4fe694be7db6@intel.com> <0e505563f7dae3849b57fb327f578f41b760b6f7.camel@intel.com> <f6de9073-9939-a20d-2196-25fa223cf3fc@intel.com>
To: Dave Hansen <dave.hansen@intel.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


> On Jun 7, 2019, at 2:09 PM, Dave Hansen <dave.hansen@intel.com> wrote:
>=20
> On 6/7/19 1:06 PM, Yu-cheng Yu wrote:
>>> Huh, how does glibc know about all possible past and future legacy code
>>> in the application?
>> When dlopen() gets a legacy binary and the policy allows that, it will ma=
nage
>> the bitmap:
>>=20
>>  If a bitmap has not been created, create one.
>>  Set bits for the legacy code being loaded.
>=20
> I was thinking about code that doesn't go through GLIBC like JITs.

CRIU is another consideration: it would be rather annoying if CET programs c=
an=E2=80=99t migrate between LA57 and normal machines.=

