Return-Path: <SRS0=dvGr=TS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_IN_DEF_DKIM_WL autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 97182C04AAF
	for <linux-mm@archiver.kernel.org>; Sat, 18 May 2019 07:11:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 43BE220848
	for <linux-mm@archiver.kernel.org>; Sat, 18 May 2019 07:11:13 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="rabKNPw+"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 43BE220848
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D62D46B0007; Sat, 18 May 2019 03:11:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D11B86B0008; Sat, 18 May 2019 03:11:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BD96C6B000A; Sat, 18 May 2019 03:11:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f72.google.com (mail-io1-f72.google.com [209.85.166.72])
	by kanga.kvack.org (Postfix) with ESMTP id A07CC6B0007
	for <linux-mm@kvack.org>; Sat, 18 May 2019 03:11:12 -0400 (EDT)
Received: by mail-io1-f72.google.com with SMTP id d24so7192687iob.7
        for <linux-mm@kvack.org>; Sat, 18 May 2019 00:11:12 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=RiOVb0r2XtDlST73GK6EKcP9xzfFFxYpIe1ze82bR2Q=;
        b=gjfLZMA/mS1wbb3m0kqz5n/IL3TjCfNVCBUbeREDkqBiOrXqUeJMCGcNXKTT11eO/Z
         U9P9/go38a2H8KiSOd+8c2tPwtzrca/xOt1c1vTk1qCxodnPX1TPM93m2fuBd81R/B1D
         QaUUCi7b3J+gjQfGb7w/GWEPmw2kM0Zl1FpidJaDd8tfW9gawMd2e/Lsnx+AyW7EBj7/
         6eBY/G8vwXI3xxunXb94xEDyHSCTmgzU1y1C7di7K4uSYr3hq3yAg/71rjmFrbi1/jKo
         ZQ/QCyw7U1AWC2nSyCAlzk0RrMBQJBm4fozi/Fhi+Rysy2Op7l0BtUEzKD58b3QJVuGP
         unqA==
X-Gm-Message-State: APjAAAXF56bCUNjj6Vyfcen3jIwSQSqSz6orD8JHm4g0q5+WMcMQehdr
	+1+hUVAA8b/I8ch+pYzhobYzZWX2f8pCwdYAVcig1qWnJ2JouAlGWyixjeky6j3EYQZqj8WPMhw
	2OhziCKRXXnutfjCjoabzqCPg/iadqFP3A38hojZ0QtmX+3D6ZtK/u87n6QC2KR9tYw==
X-Received: by 2002:a24:684b:: with SMTP id v72mr5471949itb.174.1558163472315;
        Sat, 18 May 2019 00:11:12 -0700 (PDT)
X-Received: by 2002:a24:684b:: with SMTP id v72mr5471917itb.174.1558163471533;
        Sat, 18 May 2019 00:11:11 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558163471; cv=none;
        d=google.com; s=arc-20160816;
        b=Jz3Vrw4H2k0dtG5TJ6o+v95R7Wtr7edZvtUmNJC/Az3g8ctFsv5oPsSXot1ZYzoO8b
         KUqTfSWQ/PvQHT6A3eiLa6tKzZgfcKP2mLBm7Qt5hTYTRqob4m6X0K2v4MFiOUvS0wjm
         Is8r7mckJtwIjLbn+EuCaeMCZQoBWTot+YIGEsjaVOKLfU+Gi/j71skaRKaAghAn9YjM
         SzhXghdoQWmdEpKlrRziQiA3SEMqgXFCR0WEymt2cJnERQ0cUzTtaP3F69LIrW8KhaHS
         MgzRJDYTDdSiCBYq+IBZ7RtqS2Pd4nrKmdn0RvvlNPruEsegONYfGQ1oVkUccg9WdUEx
         IDSg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=RiOVb0r2XtDlST73GK6EKcP9xzfFFxYpIe1ze82bR2Q=;
        b=AZNkxUTJiyeJ44xlfCA+4/44unlZF/Ci2xFWow1Fl2S5fU6XXpKhunlTBPywdef4FE
         REUVjAGbK2oI/CTd/lhudvG43vM+dqpppa1jbLUz4OPLNna40QpJ7cgq+RinYrXrADPq
         k/HArsXJK2DQ/GGczHz+NzhYVWMYcbOfIBSbOmhc9HmKPwNZ0HpR8yhK2RWhEePGAvV9
         XcmMzhcxK25q/K7bwhY3R0iuZE/k7erdpI5oderfxhydN3hNSquhACjPy7Etf0pe+Wl3
         AoTnoZCvoc/rx2sEaNhHj2belntorQS8WITVJWgDhfeLSiyvXzzF07IgBMZwm/v2Zi2f
         +5rw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=rabKNPw+;
       spf=pass (google.com: domain of dvyukov@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dvyukov@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r67sor9438819ita.21.2019.05.18.00.11.11
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 18 May 2019 00:11:11 -0700 (PDT)
Received-SPF: pass (google.com: domain of dvyukov@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=rabKNPw+;
       spf=pass (google.com: domain of dvyukov@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dvyukov@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=RiOVb0r2XtDlST73GK6EKcP9xzfFFxYpIe1ze82bR2Q=;
        b=rabKNPw+eYC9kmx+8CDGM7I/PCMu8buwuC3OVQ22mOV/QwgFrLf1MgLbENPaK9Se90
         a7fmyYILc74wzHEGZz9aGU0ZNQ08T8Gt/NNztt+jsaSnETR6dan690a5cQhg6xpHBavG
         gaic3JMrP51pMKiDkt0yA+Wi8eWInyDrMXMk9uZo0b4WwDG3mfZpNOMsy5Twog2sWXrf
         bNpVK6qheOHkwXR7u+wLf6Q5UnrML5rAqsK5ywzb3R3Y8/62rCQracLGlKyDGXsqfWWK
         jGgnDEaCmw3u7OpyUUOTn+03g7GpgERf90DXAA9s88EhcU2dEqt5XuwtxQ5ZpnjIzjV8
         NxJg==
X-Google-Smtp-Source: APXvYqzQ5tmIhQCBoyFPy/MoyrkRC8/116cN+KJoXVBjPead1xsLW52BD5mkme39a12aeV4+k6Q9m4IDEKJWxCmNQrM=
X-Received: by 2002:a24:4c08:: with SMTP id a8mr5931148itb.76.1558163470937;
 Sat, 18 May 2019 00:11:10 -0700 (PDT)
MIME-Version: 1.0
References: <20190517171507.96046-1-dvyukov@gmail.com> <20190517143746.2157a759f65b4cbc73321124@linux-foundation.org>
In-Reply-To: <20190517143746.2157a759f65b4cbc73321124@linux-foundation.org>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Sat, 18 May 2019 09:10:59 +0200
Message-ID: <CACT4Y+aee_Kvezo8zeD77RwBi2-Csd9cE8vtGCmaTGYxr=iK5A@mail.gmail.com>
Subject: Re: [PATCH] kmemleak: fix check for softirq context
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Dmitry Vyukov <dvyukov@gmail.com>, Catalin Marinas <catalin.marinas@arm.com>, 
	Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, May 17, 2019 at 11:37 PM Andrew Morton
<akpm@linux-foundation.org> wrote:
>
> On Fri, 17 May 2019 19:15:07 +0200 Dmitry Vyukov <dvyukov@gmail.com> wrote:
>
> > From: Dmitry Vyukov <dvyukov@google.com>
> >
> > in_softirq() is a wrong predicate to check if we are in a softirq context.
> > It also returns true if we have BH disabled, so objects are falsely
> > stamped with "softirq" comm. The correct predicate is in_serving_softirq().
> >
> > ...
> >
> > --- a/mm/kmemleak.c
> > +++ b/mm/kmemleak.c
> > @@ -588,7 +588,7 @@ static struct kmemleak_object *create_object(unsigned long ptr, size_t size,
> >       if (in_irq()) {
> >               object->pid = 0;
> >               strncpy(object->comm, "hardirq", sizeof(object->comm));
> > -     } else if (in_softirq()) {
> > +     } else if (in_serving_softirq()) {
> >               object->pid = 0;
> >               strncpy(object->comm, "softirq", sizeof(object->comm));
> >       } else {
>
> What are the user-visible runtime effects of this change?


If user does cat from /sys/kernel/debug/kmemleak previously they would
see this, which is clearly wrong, this is system call context (see the
comm):

unreferenced object 0xffff88805bd661c0 (size 64):
  comm "softirq", pid 0, jiffies 4294942959 (age 12.400s)
  hex dump (first 32 bytes):
    00 00 00 00 00 00 00 00 ff ff ff ff 00 00 00 00  ................
    00 00 00 00 00 00 00 00 01 00 00 00 00 00 00 00  ................
  backtrace:
    [<0000000007dcb30c>] kmemleak_alloc_recursive
include/linux/kmemleak.h:55 [inline]
    [<0000000007dcb30c>] slab_post_alloc_hook mm/slab.h:439 [inline]
    [<0000000007dcb30c>] slab_alloc mm/slab.c:3326 [inline]
    [<0000000007dcb30c>] kmem_cache_alloc_trace+0x13d/0x280 mm/slab.c:3553
    [<00000000969722b7>] kmalloc include/linux/slab.h:547 [inline]
    [<00000000969722b7>] kzalloc include/linux/slab.h:742 [inline]
    [<00000000969722b7>] ip_mc_add1_src net/ipv4/igmp.c:1961 [inline]
    [<00000000969722b7>] ip_mc_add_src+0x36b/0x400 net/ipv4/igmp.c:2085
    [<00000000a4134b5f>] ip_mc_msfilter+0x22d/0x310 net/ipv4/igmp.c:2475
    [<00000000d20248ad>] do_ip_setsockopt.isra.0+0x19fe/0x1c00
net/ipv4/ip_sockglue.c:957
    [<000000003d367be7>] ip_setsockopt+0x3b/0xb0 net/ipv4/ip_sockglue.c:1246
    [<000000003c7c76af>] udp_setsockopt+0x4e/0x90 net/ipv4/udp.c:2616
    [<000000000c1aeb23>] sock_common_setsockopt+0x3e/0x50 net/core/sock.c:3130
    [<000000000157b92b>] __sys_setsockopt+0x9e/0x120 net/socket.c:2078
    [<00000000a9f3d058>] __do_sys_setsockopt net/socket.c:2089 [inline]
    [<00000000a9f3d058>] __se_sys_setsockopt net/socket.c:2086 [inline]
    [<00000000a9f3d058>] __x64_sys_setsockopt+0x26/0x30 net/socket.c:2086
    [<000000001b8da885>] do_syscall_64+0x7c/0x1a0 arch/x86/entry/common.c:301
    [<00000000ba770c62>] entry_SYSCALL_64_after_hwframe+0x44/0xa9

now they will see this:

unreferenced object 0xffff88805413c800 (size 64):
  comm "syz-executor.4", pid 8960, jiffies 4294994003 (age 14.350s)
  hex dump (first 32 bytes):
    00 7a 8a 57 80 88 ff ff e0 00 00 01 00 00 00 00  .z.W............
    00 00 00 00 00 00 00 00 01 00 00 00 00 00 00 00  ................
  backtrace:
    [<00000000c5d3be64>] kmemleak_alloc_recursive
include/linux/kmemleak.h:55 [inline]
    [<00000000c5d3be64>] slab_post_alloc_hook mm/slab.h:439 [inline]
    [<00000000c5d3be64>] slab_alloc mm/slab.c:3326 [inline]
    [<00000000c5d3be64>] kmem_cache_alloc_trace+0x13d/0x280 mm/slab.c:3553
    [<0000000023865be2>] kmalloc include/linux/slab.h:547 [inline]
    [<0000000023865be2>] kzalloc include/linux/slab.h:742 [inline]
    [<0000000023865be2>] ip_mc_add1_src net/ipv4/igmp.c:1961 [inline]
    [<0000000023865be2>] ip_mc_add_src+0x36b/0x400 net/ipv4/igmp.c:2085
    [<000000003029a9d4>] ip_mc_msfilter+0x22d/0x310 net/ipv4/igmp.c:2475
    [<00000000ccd0a87c>] do_ip_setsockopt.isra.0+0x19fe/0x1c00
net/ipv4/ip_sockglue.c:957
    [<00000000a85a3785>] ip_setsockopt+0x3b/0xb0 net/ipv4/ip_sockglue.c:1246
    [<00000000ec13c18d>] udp_setsockopt+0x4e/0x90 net/ipv4/udp.c:2616
    [<0000000052d748e3>] sock_common_setsockopt+0x3e/0x50 net/core/sock.c:3130
    [<00000000512f1014>] __sys_setsockopt+0x9e/0x120 net/socket.c:2078
    [<00000000181758bc>] __do_sys_setsockopt net/socket.c:2089 [inline]
    [<00000000181758bc>] __se_sys_setsockopt net/socket.c:2086 [inline]
    [<00000000181758bc>] __x64_sys_setsockopt+0x26/0x30 net/socket.c:2086
    [<00000000d4b73623>] do_syscall_64+0x7c/0x1a0 arch/x86/entry/common.c:301
    [<00000000c1098bec>] entry_SYSCALL_64_after_hwframe+0x44/0xa9

