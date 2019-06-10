Return-Path: <SRS0=/KmR=UK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,MIME_QP_LONG_LINE,
	SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0992CC4321B
	for <linux-mm@archiver.kernel.org>; Tue, 11 Jun 2019 00:02:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C3BCF208E3
	for <linux-mm@archiver.kernel.org>; Tue, 11 Jun 2019 00:02:14 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=amacapital-net.20150623.gappssmtp.com header.i=@amacapital-net.20150623.gappssmtp.com header.b="KUSlqCLf"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C3BCF208E3
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=amacapital.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5DBF36B026B; Mon, 10 Jun 2019 20:02:14 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 58CD16B026C; Mon, 10 Jun 2019 20:02:14 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 454BD6B026D; Mon, 10 Jun 2019 20:02:14 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 0C6376B026B
	for <linux-mm@kvack.org>; Mon, 10 Jun 2019 20:02:14 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id c17so8277479pfb.21
        for <linux-mm@kvack.org>; Mon, 10 Jun 2019 17:02:14 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:content-transfer-encoding:from
         :mime-version:subject:date:message-id:references:cc:in-reply-to:to;
        bh=A82/ddxx3F+ATI2rZx3wBjeD0ledFHTBqnLAZuECLx4=;
        b=FQMPF3re9lbxCeir9bDX0dx7r8j/x82GQzVhGO1oB/UVJgrPcc1WM7wBgjOBbjvbLt
         KJhjTY1g4U1Ssg0VpMFEylNJzoSuK+gDbgBQ3uLWjJAuPgCxs7Hccks8x9s+J+oaLKw/
         XXosTLgLIMkT140fzyUxEau8fayN+cxJgd5geR1XDVmaQCvkKX3C6urYlV6Mmtic0+4u
         Em5+t75LIMGLcpyGFT06OC8/o9AG7JTJ4BqFBilR7cQmVInPUiQAapbEydSGE8MOn0TO
         2rXAYUsjBTf0GRARJ9mIWO36ySBR9mSTnXgZInBuqCeI1Q1+BvEylJOAeUBakEPKikLR
         q0vg==
X-Gm-Message-State: APjAAAWd9ZWTtPunDQd9l9dcPzOQGHzj39HSb+5FXEdyCPwUVmk/MgmD
	lxJ6WFBPqgwiynG2rQFTUWMc58fomdO+1IOZSsJGtu0yzItu0s+5oz+Mw2NVW484uzeRjn2TpMX
	9ZzWgQncdCFOGNNQlseuzFgTb0sXkV+5WVLpOHCStQdH1L9LTUBNSZRFnZftqFwJO6g==
X-Received: by 2002:a62:d44d:: with SMTP id u13mr24354340pfl.16.1560211333648;
        Mon, 10 Jun 2019 17:02:13 -0700 (PDT)
X-Received: by 2002:a62:d44d:: with SMTP id u13mr24354268pfl.16.1560211332646;
        Mon, 10 Jun 2019 17:02:12 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560211332; cv=none;
        d=google.com; s=arc-20160816;
        b=CIfDFIumPWSduNSojDlavAAzzGvNQA6O4Bj7uxJg6eA+kqaPUZmi65V8DcJWsJu1O2
         8gRpILSojcetEBqUavAeLoZF784SEnAYOB8/3r5SLsTTzF7AV0E4+0gcC7NW5x+u3sjF
         Di/O2vOrYdgXg7d6A18a2/Y53eB9R2v5KSky9neNw07n8uoGylsQmaU2Kiku6tT5Swp2
         uKLacbvtvCGl1+YFKJGInEUIqKzVw9Ca6bihvIc14oxcm18rDqW5fhipQy3JB9D3fc//
         xLwxAdj1vtaP9KPHe4qsd72yIkOt92B1UAv99YVSkQbXUo6fGRtrqOjJof47WrKO/Ora
         HrlA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=to:in-reply-to:cc:references:message-id:date:subject:mime-version
         :from:content-transfer-encoding:dkim-signature;
        bh=A82/ddxx3F+ATI2rZx3wBjeD0ledFHTBqnLAZuECLx4=;
        b=pvqVvQKtpaWCSTjUUGZgo7uzRruQJw6okAdB+XsShC78XRAlvTCCeBmbahlYIK+twy
         csM2oleE0suFEgp6XmqY8DS8xms/Hpk90qj72latL7fBVyFiRbi1EqUTiYif8Nfff3OH
         080aSzLEADcHG7lEBH4Gufr4IeyHEQi/eX6AwWVyTMKxVdKrnJlvYMzJGWZNf32kqPQE
         gNZcrK7+LL6Cro49/QPpmD6wtisl8SWOjZzOM4OqewkRMgUZAJ10Jd4KHwMHqqi0ObCC
         ccR8IHr0I7xoJYeE/MUE+mdpSjpEfRIjuErjoIgw1RluCLPrNBP/vKAHHf5TdLtQRVY1
         xP5g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@amacapital-net.20150623.gappssmtp.com header.s=20150623 header.b=KUSlqCLf;
       spf=pass (google.com: domain of luto@amacapital.net designates 209.85.220.65 as permitted sender) smtp.mailfrom=luto@amacapital.net
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v10sor13420515plg.28.2019.06.10.17.02.12
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 10 Jun 2019 17:02:12 -0700 (PDT)
Received-SPF: pass (google.com: domain of luto@amacapital.net designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@amacapital-net.20150623.gappssmtp.com header.s=20150623 header.b=KUSlqCLf;
       spf=pass (google.com: domain of luto@amacapital.net designates 209.85.220.65 as permitted sender) smtp.mailfrom=luto@amacapital.net
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=amacapital-net.20150623.gappssmtp.com; s=20150623;
        h=content-transfer-encoding:from:mime-version:subject:date:message-id
         :references:cc:in-reply-to:to;
        bh=A82/ddxx3F+ATI2rZx3wBjeD0ledFHTBqnLAZuECLx4=;
        b=KUSlqCLfKiAiQnRELAl1ZV0yc0U5pUCd2gUMULJ3+ELMQm4Hla5QTfxrOBk5YUAEyu
         zW+4qpHpO2pgrjwgBMY+GyzEKHtIpxIVIplITWILvwph3AhY3ZYZWBenMnOPLdgHgItc
         NASjKKHiq2Hn0b+lJstWbgAFaxZx+Q19bWrYD0MV/lo569q87MTUIUBTXXTdPUk5YO6X
         xX1aqotPQG/nM1VygMeR6ruhR81K6olk429urDbudQJ8MQFwV4AvFmmENPQSNEANXtPI
         rjLcJiMHLk1wWtRIhQGnKvHy69UpH1crAMAFqgxmbLBgi7aTQybSq/PyiQyATqDXbiNT
         5WVQ==
X-Google-Smtp-Source: APXvYqwMeZAM5HN0tbtrDv+73zByg9xRCVQtCgh3nPGiZ8vukjVY4hHdmPlqsE6Qi2SoTZcEbcYFYw==
X-Received: by 2002:a17:902:4181:: with SMTP id f1mr70400039pld.22.1560211332156;
        Mon, 10 Jun 2019 17:02:12 -0700 (PDT)
Received: from ?IPv6:2600:1010:b04b:ab5e:d9b1:bcf9:898:128e? ([2600:1010:b04b:ab5e:d9b1:bcf9:898:128e])
        by smtp.gmail.com with ESMTPSA id a18sm579563pjq.0.2019.06.10.17.02.05
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Jun 2019 17:02:10 -0700 (PDT)
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
From: Andy Lutomirski <luto@amacapital.net>
Mime-Version: 1.0 (1.0)
Subject: Re: [PATCH v7 03/14] x86/cet/ibt: Add IBT legacy code bitmap setup function
Date: Mon, 10 Jun 2019 16:54:52 -0700
Message-Id: <BBBF82D3-EE21-49E1-92A4-713C7729E6AD@amacapital.net>
References: <20190606200926.4029-1-yu-cheng.yu@intel.com> <20190606200926.4029-4-yu-cheng.yu@intel.com>
 <20190607080832.GT3419@hirez.programming.kicks-ass.net> <aa8a92ef231d512b5c9855ef416db050b5ab59a6.camel@intel.com>
 <20190607174336.GM3436@hirez.programming.kicks-ass.net> <b3de4110-5366-fdc7-a960-71dea543a42f@intel.com>
 <34E0D316-552A-401C-ABAA-5584B5BC98C5@amacapital.net> <7e0b97bf1fbe6ff20653a8e4e147c6285cc5552d.camel@intel.com>
 <25281DB3-FCE4-40C2-BADB-B3B05C5F8DD3@amacapital.net> <e26f7d09376740a5f7e8360fac4805488b2c0a4f.camel@intel.com>
 <3f19582d-78b1-5849-ffd0-53e8ca747c0d@intel.com> <5aa98999b1343f34828414b74261201886ec4591.camel@intel.com>
 <0665416d-9999-b394-df17-f2a5e1408130@intel.com> <5c8727dde9653402eea97bfdd030c479d1e8dd99.camel@intel.com>
 <ac9a20a6-170a-694e-beeb-605a17195034@intel.com> <328275c9b43c06809c9937c83d25126a6e3efcbd.camel@intel.com>
 <92e56b28-0cd4-e3f4-867b-639d9b98b86c@intel.com> <1b961c71d30e31ecb22da2c5401b1a81cb802d86.camel@intel.com>
 <ea5e333f-8cd6-8396-635f-a9dc580d5364@intel.com>
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
In-Reply-To: <ea5e333f-8cd6-8396-635f-a9dc580d5364@intel.com>
To: Dave Hansen <dave.hansen@intel.com>
X-Mailer: iPhone Mail (16F203)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



> On Jun 10, 2019, at 3:59 PM, Dave Hansen <dave.hansen@intel.com> wrote:
>=20
>> On 6/10/19 3:40 PM, Yu-cheng Yu wrote:
>> Ok, we will go back to do_mmap() with MAP_PRIVATE, MAP_NORESERVE and
>> VM_DONTDUMP.  The bitmap will cover only 48-bit address space.
>=20
> Could you make sure to discuss the downsides of only doing a 48-bit
> address space?
>=20
> What are the reasons behind and implications of VM_DONTDUMP?
>=20
>> We then create PR_MARK_CODE_AS_LEGACY.  The kernel will set the bitmap, b=
ut it
>> is going to be slow.
>=20
> Slow compared to what?  We're effectively adding one (quick) system call
> to a path that, today, has at *least* half a dozen syscalls and probably
> a bunch of page faults.  Heck, we can probably avoid the actual page
> fault to populate the bitmap if we're careful.  That alone would put a
> syscall on equal footing with any other approach.  If the bit setting
> crossed a page boundary it would probably win.
>=20
>> Perhaps we still let the app fill the bitmap?
>=20
> I think I'd want to see some performance data on it first.

Trying to summarize:

If we manage the whole thing in user space, we are basically committing to o=
nly covering 48 bits =E2=80=94 otherwise the whole model falls apart in quit=
e a few ways. We gain some simplicity in the kernel.

If we do it in the kernel, we still have to decide how much address space to=
 cover. We get to play games like allocating the bitmap above 2^48, but then=
 we might have CRIU issues if we migrate to a system with fewer BA bits.

I doubt that the performance matters much one way or another. I just don=E2=80=
=99t expect any of this to be a bottleneck.

Another benefit of kernel management: we could plausibly auto-clear the bits=
 corresponding to munmapped regions. Is this worth it?

And a maybe-silly benefit: if we manage it in the kernel, we could optimize t=
he inevitable case where the bitmap contains pages that are all ones :). If i=
t=E2=80=99s in userspace, KSM could do the, but that will be inefficient at b=
est.=

