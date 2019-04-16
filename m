Return-Path: <SRS0=AiS9=SS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7EEC7C282DA
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 12:05:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3D3672054F
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 12:05:04 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="m5FJ1dSx"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3D3672054F
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C7DD96B0003; Tue, 16 Apr 2019 08:05:03 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C2DDE6B0006; Tue, 16 Apr 2019 08:05:03 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B1D0E6B0007; Tue, 16 Apr 2019 08:05:03 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vk1-f197.google.com (mail-vk1-f197.google.com [209.85.221.197])
	by kanga.kvack.org (Postfix) with ESMTP id 914256B0003
	for <linux-mm@kvack.org>; Tue, 16 Apr 2019 08:05:03 -0400 (EDT)
Received: by mail-vk1-f197.google.com with SMTP id v4so8994303vka.10
        for <linux-mm@kvack.org>; Tue, 16 Apr 2019 05:05:03 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc
         :content-transfer-encoding;
        bh=x6d0Pvgzrg/FmC5CP2ha7gINMxyg3P7BhpdWAeKewFg=;
        b=R/bqLgKGDbQtHC3QnjA0azCkBLA0NwLYpCdeOaJPTlYFHtacHORiPEi/dyJAXTR2mZ
         54DZUdT19/hiGDYdQ86w/NsscuRG5A2kQb+s6K2ksDqBy/TOXbvv7qAcSa3VWeOeStJj
         fkPC87NfDG5oiUwR9Mw4I9YWtlJzZ6iS6BARWgyh9j4eueUH0/hxBHnMDKVQwOnhV2vi
         mk5+cOB20jUorEhKstwAuY2CtyG+iQVI848ApoOT85HTZ7P+bcZBAT8WV90y3gD9ZuMc
         5SI/TEv7q1/KsYc15VbNdG85IwxzbV41Sq/EVEdKjRg8HXdJGjUnf3zpMVzUhAj6G1iQ
         T0oQ==
X-Gm-Message-State: APjAAAVAQ+clqRD8OzbZEzmX2k1kJx+Sui4AGO21kvc+GnHjf0Hijmfg
	f5ZWUUzib4EwbXW05bKylpS5sXGqyAZR/hKvZGp0xSi0r8goTW8pIAElwI5hreYoSpb49wnfHZ5
	jLG7hB0zPYC4w5sioJR5E7Tr6NSHqRn7NW1WwZIHhqjOPfeyudn4LQl+L/DNStVIrBQ==
X-Received: by 2002:a67:f3c9:: with SMTP id j9mr43724990vsn.21.1555416303257;
        Tue, 16 Apr 2019 05:05:03 -0700 (PDT)
X-Received: by 2002:a67:f3c9:: with SMTP id j9mr43724932vsn.21.1555416302366;
        Tue, 16 Apr 2019 05:05:02 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555416302; cv=none;
        d=google.com; s=arc-20160816;
        b=k4DuxAOPDd2KWBu5CzQh2H8hgjSj23UaE/8wMLg7oto693SIoT6YAg+X6ujQD2nhg2
         JsAlTuzfO+ITscYJllBCsKjowEZ3K5RiylGWBgenwZ3Aq8lZnxnMKwfvs1rc9zfl1hcY
         i+bbeFRd6o7OVRv1b5K+c7c/HlEVnSyR40rY2qEOoW7O1ALREqzP/cpUgIuKKbDviN00
         uQmZcIzgVsdArNQBdei7IQ/Wb5d+4h9SaZ0sNBMK0W3NL57pBBdItNVD9wqP8wJQSyFc
         8SBy76Mv+/xDKNUt0nEDwXL898OqafqOw2JPk7wtZoIwr8AthZsk+94pWoKqfdOPWAzr
         pZJQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=x6d0Pvgzrg/FmC5CP2ha7gINMxyg3P7BhpdWAeKewFg=;
        b=aJywbmgV2JIoTDQtrdf2hJYRD5LRG5AxIbY/tG2t844LtQvUO87TtOpb6MUudC6cOg
         mIPGXDSa+/fSr7b3FaezGY8rY8VwlX3lv41VCngFOJwwflLd7lq1RAjVn+OmeA5LpUm9
         qZKBulBoGdjoIly2/7b6qEwj9dUuvHWPVj7VnMtuijYunZgLI8PFJ9B9EHIoJViP/7Js
         hSBFtGpgi/hv6qlMiQGaktCTCJoSoPXRvx2BUJ/Bps2xt9Cp+Fbg5baZp0D/QtJQKxCR
         viq2YXqBz5QlNQwnYa/GdKy1xsw1nIeQzWi2QCqdPJydDxTzbKpM9kKY98CXO/oIK+WO
         r+Cw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=m5FJ1dSx;
       spf=pass (google.com: domain of glider@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=glider@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e18sor21448457ual.34.2019.04.16.05.05.02
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 16 Apr 2019 05:05:02 -0700 (PDT)
Received-SPF: pass (google.com: domain of glider@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=m5FJ1dSx;
       spf=pass (google.com: domain of glider@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=glider@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc:content-transfer-encoding;
        bh=x6d0Pvgzrg/FmC5CP2ha7gINMxyg3P7BhpdWAeKewFg=;
        b=m5FJ1dSxPq9N1yfTJovgaWYa5NFqG2+ItFUiNA/h5JnVSVkqXiCJfcDhBDgbFV11wS
         Z7Q/W3zS3sB8uFIohFm8BRqcH5yGiTYemqCz0XikfFKnx67EaiziVKyVDP0ncncUWkDn
         MNITMvclkCfB6Bwkt1P6WBWYNkHP4o3JO3gNtYKpA3+tcmF7TxhcUSUxFqvRlLT4ac4P
         xwjz1hKpqJXFvpp2+7esW4d8GAN/M5NtHkGgaNCA8saW5Rd6rEW6nlCD3i6wB5UaKxV3
         A7Lv6I8oTz5pAG7gxbb9rAAhW+DCtaTzAtvfqbL0dO6CuA2wa+ESao0DWE3MQ4sQEVTX
         tjqg==
X-Google-Smtp-Source: APXvYqyWqZeF0fEmsHx1epJQny3J0neTEO0LACZRViyfMSGIG0I4vBO2Rx9YCjnFU8Xj23TYjNlIDDNGyEJCMdPsvc8=
X-Received: by 2002:ab0:60cd:: with SMTP id g13mr2954540uam.85.1555416301693;
 Tue, 16 Apr 2019 05:05:01 -0700 (PDT)
MIME-Version: 1.0
References: <20190412124501.132678-1-glider@google.com> <35935775-1c0d-6016-5bb3-0abee65a7492@suse.cz>
In-Reply-To: <35935775-1c0d-6016-5bb3-0abee65a7492@suse.cz>
From: Alexander Potapenko <glider@google.com>
Date: Tue, 16 Apr 2019 14:04:49 +0200
Message-ID: <CAG_fn=VYa0CtxDeXOV0Mpj3q_i150NJioyJWGLA3OEij3iSH1A@mail.gmail.com>
Subject: Re: [PATCH] mm: security: introduce CONFIG_INIT_HEAP_ALL
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, 
	linux-security-module <linux-security-module@vger.kernel.org>, 
	Linux Memory Management List <linux-mm@kvack.org>, Nick Desaulniers <ndesaulniers@google.com>, 
	Kostya Serebryany <kcc@google.com>, Dmitriy Vyukov <dvyukov@google.com>, Kees Cook <keescook@chromium.org>, 
	Sandeep Patil <sspatil@android.com>, Laura Abbott <labbott@redhat.com>, 
	Kernel Hardening <kernel-hardening@lists.openwall.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Apr 16, 2019 at 10:33 AM Vlastimil Babka <vbabka@suse.cz> wrote:
>
> On 4/12/19 2:45 PM, Alexander Potapenko wrote:
> > +config INIT_HEAP_ALL
> > +     bool "Initialize kernel heap allocations"
>
> Calling slab and page allocations together as "heap" is rather uncommon
> in the kernel I think. But I don't have a better word right now.
We can provide two separate flags for slab and page allocator to avoid this=
.
I cannot think of a situation where this level of control is necessary
though (apart from benchmarking).
> > +     default n
> > +     help
> > +       Enforce initialization of pages allocated from page allocator
> > +       and objects returned by kmalloc and friends.
> > +       Allocated memory is initialized with zeroes, preventing possibl=
e
> > +       information leaks and making the control-flow bugs that depend
> > +       on uninitialized values more deterministic.
> > +
> >  config GCC_PLUGIN_STRUCTLEAK_VERBOSE
> >       bool "Report forcefully initialized variables"
> >       depends on GCC_PLUGIN_STRUCTLEAK
> >
>


--=20
Alexander Potapenko
Software Engineer

Google Germany GmbH
Erika-Mann-Stra=C3=9Fe, 33
80636 M=C3=BCnchen

Gesch=C3=A4ftsf=C3=BChrer: Paul Manicle, Halimah DeLaine Prado
Registergericht und -nummer: Hamburg, HRB 86891
Sitz der Gesellschaft: Hamburg

