Return-Path: <SRS0=sWz3=SD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,URIBL_BLOCKED,USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0DFE2C4360F
	for <linux-mm@archiver.kernel.org>; Mon,  1 Apr 2019 16:44:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B3E23208E4
	for <linux-mm@archiver.kernel.org>; Mon,  1 Apr 2019 16:44:48 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="vslBuYvy"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B3E23208E4
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 312AD6B0005; Mon,  1 Apr 2019 12:44:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2C1E06B0008; Mon,  1 Apr 2019 12:44:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 18A606B000A; Mon,  1 Apr 2019 12:44:48 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id D3B616B0005
	for <linux-mm@kvack.org>; Mon,  1 Apr 2019 12:44:47 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id i23so7655113pfa.0
        for <linux-mm@kvack.org>; Mon, 01 Apr 2019 09:44:47 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=jcvAo90iEgrnlBze/0hMSJPNi22jiy7MfsIMeTHCzlE=;
        b=tUJjai/q+K8PAXp8h56BwMtV1CHtUhN5XdLgnPZwYmBpFBB9TlyqOPoRyNAinAb+70
         gppXoPqpbq6ex3llfDQ7kjLF3A3xDozEoVRoQ07VsH9si6EdoCVJu5ZjgaioJ7FA9wSM
         GR4aUOs2tjY9eBIBcZ6m3Sn1RYI64z2AWJ3sbXyMEtq1n6XUILrKsuPF8ItLlL9dF7xj
         mcq/xG1jWnthE0imQXkUeRxE3EKSUvO76Bsq+otVixWvQ8V396InSnFfPgFAgX7uXqNA
         0yXe34w8flmVAQ/p+M4XqupIcXsPxjpDd4enPmQaHLO7dh/tIIB40hoXktX0cI7HmqDI
         oV9Q==
X-Gm-Message-State: APjAAAU7E0ser9BZDosaMy9gyCI1OLNwWC5++DpM0EWPgaNsZ7NlOr49
	2qsl4x+UQ9VgqLI7A0gJpxFMTU//sCyaQ8iy4/zZB9Je7HOPS+FBaaiiPltlGO6xp6Np+qzacTv
	O2Kxa5jW1ivvYhbEOXK3v6Zs5UgBuMjSx0KjC7onDkw5FPn6vrr3DdFEe68QFnHU8PQ==
X-Received: by 2002:a17:902:f08a:: with SMTP id go10mr51173076plb.121.1554137087357;
        Mon, 01 Apr 2019 09:44:47 -0700 (PDT)
X-Received: by 2002:a17:902:f08a:: with SMTP id go10mr51172989plb.121.1554137086377;
        Mon, 01 Apr 2019 09:44:46 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554137086; cv=none;
        d=google.com; s=arc-20160816;
        b=a2xmn8CQW3XcdefIy5zCzACJ1EgpAxDr7TR7sJZxv/5oHGmi3rHqLi2CO7VkESfAim
         1fzwhjHCIc7eOKJq5xdtmmrfbIl2OUQdjwi9KZx07NmT+pg4+FlQi1wQXVkMX11MzgBs
         V8uz0EuYmv7Z0pjFdWRaJwY0rIlApDyPRCDlzvsqF0GlEPlJ58nNj9oBzGLH8y8D8I/Z
         5fY+uERt9fYEZhFx9K8A3xau5FTsHmuTsGUvwUY+As84EtjcutdKdI7NxfhXDXdCY2o4
         Zrwh9DZtB7dxmaCuuWCDgNSt3JS/P07yF9Eu8H6wB2CPYM4g0G3lJ3Q2xLVKatjtsU1r
         1kAw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=jcvAo90iEgrnlBze/0hMSJPNi22jiy7MfsIMeTHCzlE=;
        b=Kh7rlgXnQA3ofOwPxfdIALOxf2LFRMkVchtmYiqyttGuT6Tc/E525TTKxIxrovSuW6
         BEaWS7nVbCIXyMhxzqqqekNMMLQqKV2hrDxqv3ebbAvykSJXYL5VGQz4eLJKK7MN53HG
         zUNdQXg/illeDptCUXd5/DqdZ6XG8OlSqFkrpGdfe+vJoL6owJo7LMwyUUc7lnYQfB5C
         zjcb3RppK4TUfNjns0S52e8aVPwEuoK1iO6yFVMB2xovcAEJb4OSWMhTNfMVP+5YMhsL
         hiKWPKVHrfNoTGy+3sP0heRkmvz6argqjoDilQg7Kctyz+y0+Kc3w84hsx8G1PHaEm6r
         p1zg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=vslBuYvy;
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g1sor1764428plp.57.2019.04.01.09.44.46
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 01 Apr 2019 09:44:46 -0700 (PDT)
Received-SPF: pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=vslBuYvy;
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=jcvAo90iEgrnlBze/0hMSJPNi22jiy7MfsIMeTHCzlE=;
        b=vslBuYvyVACTtd9R5+codicCDT1kankQTx9ynqhgVyffds1dzXxjpldeqxWmBmfHsC
         /1SlqNwfj8MKh+hKq6rQiBl2wu9AiF7/sl91aJ+XWVvy/fPWd0KB/mkqTbCjyTk0n544
         FrH+QO3vjOvGFFIdMc+UPhP10aS3P9Ra+66OD51kzN1nk8mAgZmqn5j7YfQz4za8dq3p
         Bb0/i/5T+S8fy2fQrS8Qa+vxkZokUeBrQHWlf4dlxYyrtfxlyWG0GRCEDRoiLnuDwZIe
         KKKj+jqvVOG+hUPOAqZXafRhe3CNvh+AmzYBiQ5jMbBGQn/fzMDivTGkBZQLUQfet6gy
         APMg==
X-Google-Smtp-Source: APXvYqxoEv7uRsHZ4Mjlc/vszzpnGNQmzJMZE9SWqgzz6pDDFBr2573vmZ5LPK49GUB2H17kk4Ibik9LHbBOBFyKLeg=
X-Received: by 2002:a17:902:586:: with SMTP id f6mr63903459plf.68.1554137085707;
 Mon, 01 Apr 2019 09:44:45 -0700 (PDT)
MIME-Version: 1.0
References: <cover.1553093420.git.andreyknvl@google.com> <76f96eb9162b3a7fa5949d71af38bf8fdf6924c4.1553093421.git.andreyknvl@google.com>
 <20190322154136.GP13384@arrakis.emea.arm.com>
In-Reply-To: <20190322154136.GP13384@arrakis.emea.arm.com>
From: Andrey Konovalov <andreyknvl@google.com>
Date: Mon, 1 Apr 2019 18:44:34 +0200
Message-ID: <CAAeHK+yHp27eT+wTE3Uy4DkN8XN3ZjHATE+=HgjgRjrHjiXs3Q@mail.gmail.com>
Subject: Re: [PATCH v13 10/20] kernel, arm64: untag user pointers in prctl_set_mm*
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: Will Deacon <will.deacon@arm.com>, Mark Rutland <mark.rutland@arm.com>, 
	Robin Murphy <robin.murphy@arm.com>, Kees Cook <keescook@chromium.org>, 
	Kate Stewart <kstewart@linuxfoundation.org>, 
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, 
	Ingo Molnar <mingo@kernel.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, 
	Shuah Khan <shuah@kernel.org>, Vincenzo Frascino <vincenzo.frascino@arm.com>, 
	Eric Dumazet <edumazet@google.com>, "David S. Miller" <davem@davemloft.net>, 
	Alexei Starovoitov <ast@kernel.org>, Daniel Borkmann <daniel@iogearbox.net>, 
	Steven Rostedt <rostedt@goodmis.org>, Ingo Molnar <mingo@redhat.com>, 
	Peter Zijlstra <peterz@infradead.org>, Arnaldo Carvalho de Melo <acme@kernel.org>, 
	Alex Deucher <alexander.deucher@amd.com>, =?UTF-8?Q?Christian_K=C3=B6nig?= <christian.koenig@amd.com>, 
	"David (ChunMing) Zhou" <David1.Zhou@amd.com>, Yishai Hadas <yishaih@mellanox.com>, 
	Mauro Carvalho Chehab <mchehab@kernel.org>, Jens Wiklander <jens.wiklander@linaro.org>, 
	Alex Williamson <alex.williamson@redhat.com>, 
	Linux ARM <linux-arm-kernel@lists.infradead.org>, 
	Linux Memory Management List <linux-mm@kvack.org>, linux-arch <linux-arch@vger.kernel.org>, 
	netdev <netdev@vger.kernel.org>, bpf <bpf@vger.kernel.org>, 
	amd-gfx@lists.freedesktop.org, dri-devel@lists.freedesktop.org, 
	linux-rdma@vger.kernel.org, linux-media@vger.kernel.org, kvm@vger.kernel.org, 
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

On Fri, Mar 22, 2019 at 4:41 PM Catalin Marinas <catalin.marinas@arm.com> wrote:
>
> On Wed, Mar 20, 2019 at 03:51:24PM +0100, Andrey Konovalov wrote:
> > @@ -2120,13 +2135,14 @@ static int prctl_set_mm(int opt, unsigned long addr,
> >       if (opt == PR_SET_MM_AUXV)
> >               return prctl_set_auxv(mm, addr, arg4);
> >
> > -     if (addr >= TASK_SIZE || addr < mmap_min_addr)
> > +     if (untagged_addr(addr) >= TASK_SIZE ||
> > +                     untagged_addr(addr) < mmap_min_addr)
> >               return -EINVAL;
> >
> >       error = -EINVAL;
> >
> >       down_write(&mm->mmap_sem);
> > -     vma = find_vma(mm, addr);
> > +     vma = find_vma(mm, untagged_addr(addr));
> >
> >       prctl_map.start_code    = mm->start_code;
> >       prctl_map.end_code      = mm->end_code;
>
> Does this mean that we are left with tagged addresses for the
> mm->start_code etc. values? I really don't think we should allow this,
> I'm not sure what the implications are in other parts of the kernel.
>
> Arguably, these are not even pointer values but some address ranges. I
> know we decided to relax this notion for mmap/mprotect/madvise() since
> the user function prototypes take pointer as arguments but it feels like
> we are overdoing it here (struct prctl_mm_map doesn't even have
> pointers).
>
> What is the use-case for allowing tagged addresses here? Can user space
> handle untagging?

I don't know any use cases for this. I did it because it seems to be
covered by the relaxed ABI. I'm not entirely sure what to do here,
should I just drop this patch?

>
> --
> Catalin

