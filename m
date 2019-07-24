Return-Path: <SRS0=cVar=VV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EF3B2C7618F
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 13:57:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B25AF21BF6
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 13:57:41 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B25AF21BF6
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linutronix.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5B7606B0006; Wed, 24 Jul 2019 09:57:41 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 51A826B0008; Wed, 24 Jul 2019 09:57:41 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3BB498E0002; Wed, 24 Jul 2019 09:57:41 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f70.google.com (mail-wm1-f70.google.com [209.85.128.70])
	by kanga.kvack.org (Postfix) with ESMTP id E22906B0006
	for <linux-mm@kvack.org>; Wed, 24 Jul 2019 09:57:40 -0400 (EDT)
Received: by mail-wm1-f70.google.com with SMTP id y130so10741516wmg.1
        for <linux-mm@kvack.org>; Wed, 24 Jul 2019 06:57:40 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:in-reply-to:message-id:references:user-agent
         :mime-version;
        bh=z8BUo0Xr7tFjXLi/ozCxKIniMVvuea5K8//a9O5aGSI=;
        b=I4Rs+2e+D9YIy1gr09qkI0CK4BTjgbtZrO5blGzmBr14x1lFeI2qNVVyWJWPuQyRD4
         phQ6OXX0MZJ3ie4uxxpphzYzLLIUhyUEKiOFc1HcwOZasa8qrJj463j28/z5a9FlVWMY
         xShWzgHCSExeBe5/gEU31LzUiwZYrMvLJbZZ3A/mtQAfuI+TyvOgX9hkRepbtsJiPlZ1
         ASwPaK9nLb9J/9dEs7cdALKqixpzG3ww+uBnkyA3+XI/umYulcCavtfRMzmPqQRkSv9B
         GDilPiRMppF36etfQ0ghaDqc8SZYMepHkvnXkuGfG0cZJ5/+q0Y+TL2/AAPgCpOUpTGl
         XqWQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a0a:51c0:0:12e:550::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
X-Gm-Message-State: APjAAAU7uwog/MosvROsNjTRk4ncGwgPmIUm2e8jifhZtuYN4OodeffH
	JsfvkhM2kCbQiRarIwZTyU4/CrFI8HxdWT+OmnNtpQB4S7pHFLm0BKxIeDreZig1ffa9tDwWrtE
	elErDtcT8E/OgYVRP1+bgTkE7xnuh3itYy13GxS7fIeoIdNWPeOrx8HMmOPKyGPvRtQ==
X-Received: by 2002:a5d:4ecc:: with SMTP id s12mr90851414wrv.157.1563976660488;
        Wed, 24 Jul 2019 06:57:40 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxYJ3+MOUE/RV4Ozp9p9OZkF9MHFjNazbbwE6GIpd4L6AkR/JkJCaPrwlKEwSCcHqOEzpiP
X-Received: by 2002:a5d:4ecc:: with SMTP id s12mr90851367wrv.157.1563976659735;
        Wed, 24 Jul 2019 06:57:39 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563976659; cv=none;
        d=google.com; s=arc-20160816;
        b=0e6abRt75X2DtP9tW5ADWiTtAXDE2VGXZu8fPNRW4jj5BlxxTxVVXYjPb6HgbSK39k
         DUJqD+YvwfXIDgw4qfsIf8vVsq1rkP9Y0KV8233di8hz5ScMYcvLS7YtkVjlA5AsRhjr
         ISuq3VKLNLRsvYJO9eufCamTCwIBZLv4/+l++hk90Q9xb03edOxNitaM0CUm4yNuzgQh
         LrHWcK1T6e4H9vXgXX9DJHFF1xK3vLYkWk37J61mNMwjhahiAB6h2pnkA/us+UwS+SFp
         K2NTGAw7rCCE2Zztjza6b+0PtXTrFQEW1w7Cl84xdoaVbraTu07/anaJgBAOZE7m7Nfs
         LvZQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:references:message-id:in-reply-to:subject
         :cc:to:from:date;
        bh=z8BUo0Xr7tFjXLi/ozCxKIniMVvuea5K8//a9O5aGSI=;
        b=M1YXTh2k7WhrGIGPKAqlVKZqb5wVwV3B4Q8whIo8bRteDbxjT8ijJFN739wIj0EB8K
         ePnwrj2o9LPVTk0TA09knFsD3da9mskjxNxiWLNjb44wUlYiPtp3AYElBC2ulcRWNuLI
         Cdr3dj15h7WJiciE3MTwvIXl8Eh6J46aL4AXY1UT/cQBjVvbUEOaKu46lPiPD7OuweJb
         pqg6f4B9bmva13WUyJCe1QKMPPbL9txsoKXqqc7/0thpLLnVBlyGBOHOiX4zv0nJUH+n
         NKlF037COz95r9fUM6Mci3VzXEkc/uXVijGLWxkDdCTeGFoGO2L7e1+0Lc574kcdKRO+
         kW3g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a0a:51c0:0:12e:550::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a0a:51c0:0:12e:550::1])
        by mx.google.com with ESMTPS id z13si32683858wrs.40.2019.07.24.06.57.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Wed, 24 Jul 2019 06:57:39 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a0a:51c0:0:12e:550::1 as permitted sender) client-ip=2a0a:51c0:0:12e:550::1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a0a:51c0:0:12e:550::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
Received: from pd9ef1cb8.dip0.t-ipconnect.de ([217.239.28.184] helo=nanos)
	by Galois.linutronix.de with esmtpsa (TLS1.2:DHE_RSA_AES_256_CBC_SHA256:256)
	(Exim 4.80)
	(envelope-from <tglx@linutronix.de>)
	id 1hqHlu-0001CA-H9; Wed, 24 Jul 2019 15:57:34 +0200
Date: Wed, 24 Jul 2019 15:57:33 +0200 (CEST)
From: Thomas Gleixner <tglx@linutronix.de>
To: Steven Price <steven.price@arm.com>
cc: Mark Rutland <mark.rutland@arm.com>, x86@kernel.org, 
    Arnd Bergmann <arnd@arndb.de>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, 
    Peter Zijlstra <peterz@infradead.org>, 
    Catalin Marinas <catalin.marinas@arm.com>, 
    Dave Hansen <dave.hansen@linux.intel.com>, linux-kernel@vger.kernel.org, 
    linux-mm@kvack.org, 
    =?ISO-8859-15?Q?J=E9r=F4me_Glisse?= <jglisse@redhat.com>, 
    Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, 
    Andy Lutomirski <luto@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, 
    James Morse <james.morse@arm.com>, Will Deacon <will@kernel.org>, 
    Andrew Morton <akpm@linux-foundation.org>, 
    linux-arm-kernel@lists.infradead.org, 
    "Liang, Kan" <kan.liang@linux.intel.com>
Subject: Re: [PATCH v9 00/21] Generic page walk and ptdump
In-Reply-To: <e108b8a6-deca-e69c-b338-52a98b14be86@arm.com>
Message-ID: <alpine.DEB.2.21.1907241541570.1791@nanos.tec.linutronix.de>
References: <20190722154210.42799-1-steven.price@arm.com> <20190723101639.GD8085@lakrids.cambridge.arm.com> <e108b8a6-deca-e69c-b338-52a98b14be86@arm.com>
User-Agent: Alpine 2.21 (DEB 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
X-Linutronix-Spam-Score: -1.0
X-Linutronix-Spam-Level: -
X-Linutronix-Spam-Status: No , -1.0 points, 5.0 required,  ALL_TRUSTED=-1,SHORTCIRCUIT=-0.0001
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 24 Jul 2019, Steven Price wrote:
> On 23/07/2019 11:16, Mark Rutland wrote:
> > Are there any visible changes to the arm64 output?
> 
> arm64 output shouldn't change. I've confirmed that "efi_page_tables" is
> identical on a Juno before/after the change. "kernel_page_tables"
> obviously will vary depending on the exact layout of memory, but the
> format isn't changed.
> 
> x86 output does change due to patch 14. In this case the change is
> removing the lines from the output of the form...
> 
> > 0xffffffff84800000-0xffffffffa0000000         440M                               pmd
> 
> ...which are unpopulated areas of the memory map. Populated lines which
> have attributes are unchanged.

Having the hole size and the level in the dump is a very conveniant thing.

Right now we have:

0xffffffffc0427000-0xffffffffc042b000          16K     ro                     NX pte
0xffffffffc042b000-0xffffffffc042e000          12K     RW                     NX pte
0xffffffffc042e000-0xffffffffc042f000           4K                               pte
0xffffffffc042f000-0xffffffffc0430000           4K     ro                     x  pte
0xffffffffc0430000-0xffffffffc0431000           4K     ro                     NX pte
0xffffffffc0431000-0xffffffffc0433000           8K     RW                     NX pte
0xffffffffc0433000-0xffffffffc0434000           4K                               pte
0xffffffffc0434000-0xffffffffc0436000           8K     ro                     x  pte
0xffffffffc0436000-0xffffffffc0438000           8K     ro                     NX pte
0xffffffffc0438000-0xffffffffc043a000           8K     RW                     NX pte
0xffffffffc043a000-0xffffffffc043f000          20K                               pte
0xffffffffc043f000-0xffffffffc0444000          20K     ro                     x  pte
0xffffffffc0444000-0xffffffffc0447000          12K     ro                     NX pte
0xffffffffc0447000-0xffffffffc0449000           8K     RW                     NX pte
0xffffffffc0449000-0xffffffffc044f000          24K                               pte
0xffffffffc044f000-0xffffffffc0450000           4K     ro                     x  pte
0xffffffffc0450000-0xffffffffc0451000           4K     ro                     NX pte
0xffffffffc0451000-0xffffffffc0453000           8K     RW                     NX pte
0xffffffffc0453000-0xffffffffc0458000          20K                               pte
0xffffffffc0458000-0xffffffffc0459000           4K     ro                     x  pte
0xffffffffc0459000-0xffffffffc045b000           8K     ro                     NX pte

with your change this becomes:

0xffffffffc0427000-0xffffffffc042b000          16K     ro                     NX pte
0xffffffffc042b000-0xffffffffc042e000          12K     RW                     NX pte
0xffffffffc042f000-0xffffffffc0430000           4K     ro                     x  pte
0xffffffffc0430000-0xffffffffc0431000           4K     ro                     NX pte
0xffffffffc0431000-0xffffffffc0433000           8K     RW                     NX pte
0xffffffffc0434000-0xffffffffc0436000           8K     ro                     x  pte
0xffffffffc0436000-0xffffffffc0438000           8K     ro                     NX pte
0xffffffffc0438000-0xffffffffc043a000           8K     RW                     NX pte
0xffffffffc043f000-0xffffffffc0444000          20K     ro                     x  pte
0xffffffffc0444000-0xffffffffc0447000          12K     ro                     NX pte
0xffffffffc0447000-0xffffffffc0449000           8K     RW                     NX pte
0xffffffffc044f000-0xffffffffc0450000           4K     ro                     x  pte
0xffffffffc0450000-0xffffffffc0451000           4K     ro                     NX pte
0xffffffffc0451000-0xffffffffc0453000           8K     RW                     NX pte
0xffffffffc0458000-0xffffffffc0459000           4K     ro                     x  pte
0xffffffffc0459000-0xffffffffc045b000           8K     ro                     NX pte

which is 5 lines less, but a pain to figure out the size of the holes. And
it becomes even more painful when the holes go across different mapping
levels.

From your 14/N changelog:

> This keeps the output shorter and will help with a future change

I don't care about shorter at all. It's debug information.

> switching to using the generic page walk code as we no longer care about
> the 'level' that the page table holes are at.

I really do not understand why you think that WE no longer care about the
level (and the size) of the holes. I assume that WE is pluralis majestatis
and not meant to reflect the opinion of you and everyone else.

I have no idea whether you ever had to do serious work with PT dump, but I
surely have at various occasions including the PTI mess and I definitely
found the size and the level information from holes very useful.

Thanks,

	tglx





