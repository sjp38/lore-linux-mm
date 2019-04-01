Return-Path: <SRS0=sWz3=SD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-14.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,USER_IN_DEF_DKIM_WL
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A7AB5C43381
	for <linux-mm@archiver.kernel.org>; Mon,  1 Apr 2019 16:05:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5B939208E4
	for <linux-mm@archiver.kernel.org>; Mon,  1 Apr 2019 16:05:04 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="Wiac3r+A"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5B939208E4
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 097FB6B000A; Mon,  1 Apr 2019 12:05:04 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 020356B000C; Mon,  1 Apr 2019 12:05:03 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E03926B000D; Mon,  1 Apr 2019 12:05:03 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id A41066B000A
	for <linux-mm@kvack.org>; Mon,  1 Apr 2019 12:05:03 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id f67so7556682pfh.9
        for <linux-mm@kvack.org>; Mon, 01 Apr 2019 09:05:03 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=LBH0UFdr1G0TFY5RWwm4Ys2pzrC+F6X1ZFx+vMAYO5U=;
        b=VOvyptMT55WoCg6u97bhEOnq1l7JezxzIxBrpyib4IPTgaWAQLxijuVZGCtdlzkZVl
         XjzD/ydybnDF6anoYOWEZxIYS7v5SiukHqP3jqMSOzmjDoS2zH3gJNyRb66EJeSMnJHU
         JUpHp6tPqS/Wmcy2Cw1pQ9Nkxb7D38eyGhvjPC/grHjzniz/TRUTRzT3t6pIEnNHuBzP
         UTxMTq3HEO65CVB6ksUjU6oywk0PiGZ2cOSVcyUps600ZyU5E7BhRf4EXOcf6bNfr3R9
         KXuflrUzq7Op6jiWdY8jw635zgt3j7tOrFovejyQLYrpbzu1BzZHevuvCzl+c2Bue9IS
         XBlQ==
X-Gm-Message-State: APjAAAXhNtZ5iYZxEDs1RILSgQyllvmjupeuTLZDAWuQLVhqAkEFKY+I
	J5QHez1OzjVRXDIrtS0KIyZ2EKFNUCn+UUPiU1PkrPqWz0m6KZOctwW3CFej5ICqKy6sDkdMACi
	I9ubDJLOpTk4Q/YoyE4yQub+vdcIC1LW4QgH+nFnj6KaRRVIGJNJt9xiVCIsiK8F1+g==
X-Received: by 2002:a63:4f52:: with SMTP id p18mr22016519pgl.333.1554134703268;
        Mon, 01 Apr 2019 09:05:03 -0700 (PDT)
X-Received: by 2002:a63:4f52:: with SMTP id p18mr22016415pgl.333.1554134702248;
        Mon, 01 Apr 2019 09:05:02 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554134702; cv=none;
        d=google.com; s=arc-20160816;
        b=v29rudmFdONSM1htynJuvNJrxdFISfmQWuu8csv69xttyJYWSGywSnybh4fr+R4h/N
         cRwqxbt7kNZDjeuuvAxr0pV8+r5oUUHEmBTx36m9pzwDj86/WKn8UF3MvTXLQsfL9MI+
         Xi8vj+hWEjqJy/NuZL12i70yCdHXv/X5zTW2DY2/g4KU3XZP5awuC916EZxy8nmGWOwM
         KT0IEbSUF4DEPqSDpa//WVKfbkt/SAjKHtkFrMjYgjKFhiikFcplLoLfOjzJBEsvDDgG
         uky1AHG5NV4e0sVvbjEiIWqu4OCTv1GZIdjLtpGlSNYbL38cwCg7mqcBDE4d6PKKkVm9
         bNUQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=LBH0UFdr1G0TFY5RWwm4Ys2pzrC+F6X1ZFx+vMAYO5U=;
        b=gr8bOQr7LVibZVryBbtufa+I2p0UHBTQy2rzgD3jDpo3U/d/+mjqO1fzthpCEtN3Iy
         YevwP7Mh6SDgxYXXyIiV9C86saPWwiHLlj+sx2rTUV4GOgml3xwbl6NHqsg4yIfh4Pex
         egC9fwTGD1P+PiM1a5kENQkRi7iV1spm4tmdUXunOMJ+riAgnP4Qx3zsiTynGVS4O0sB
         S6Oj0MZEpBKFQ/jJhlVQCtKHQAyX5ROyEaxTSZMoHKynY3at2oqdSRep1/tM1xxsy0x4
         qb/L/b8JNVkatLsBR0RxOp4y5mSsMmLmPNj4wVTvPHg/bqe9KGNyot7rNAhMzhivJYrS
         DNaw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=Wiac3r+A;
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o9sor11243746pgv.33.2019.04.01.09.05.02
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 01 Apr 2019 09:05:02 -0700 (PDT)
Received-SPF: pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=Wiac3r+A;
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=LBH0UFdr1G0TFY5RWwm4Ys2pzrC+F6X1ZFx+vMAYO5U=;
        b=Wiac3r+ALQiP5hRLiFpFfNVQivXgrfv4TMKkQPmMbSHzjlhVzItXRCbrTEKJuI1VjN
         s0MgQzU5+Qoppw1+RUix1XPz0+BR6zUFiQavwlY3pCjSv3p5oTSh7C21sNRrkcLwoVii
         E6qYdQZ/ILOMHDlAX3hvPz5LKX8XhDisRnGVJcc7GzBG8mNjsjDuLnDfVGUgM90E0X5S
         HzG8DgysBZdMpESegwv9cPMZg/HQyktCeIGgj1DOs4ldaWq1RZPA/u6i7USRvPEoMpql
         6E9+TiicLKRnTU63Hwp3v9CjvvkhQSCftl2A/I48b7hiHCdIrCtizZvFgsEdMJ+ocqBG
         73eA==
X-Google-Smtp-Source: APXvYqyLseS+mUC5w0QaVtnLgSzLk0ge1hOeF6fc30VkKh2qR+OIgQEFLhyguAEdVZXVxknKXm92fbIwJNhY4gjXJZE=
X-Received: by 2002:a63:c944:: with SMTP id y4mr14537047pgg.257.1554134701531;
 Mon, 01 Apr 2019 09:05:01 -0700 (PDT)
MIME-Version: 1.0
References: <cover.1553093420.git.andreyknvl@google.com> <2280b62096ce1fa5c9e9429d18f08f82f4be1b0b.1553093421.git.andreyknvl@google.com>
 <20190322120434.GD13384@arrakis.emea.arm.com> <e5ed4fff-acf6-7b85-bf8f-df558a9cd33f@arm.com>
In-Reply-To: <e5ed4fff-acf6-7b85-bf8f-df558a9cd33f@arm.com>
From: Andrey Konovalov <andreyknvl@google.com>
Date: Mon, 1 Apr 2019 18:04:50 +0200
Message-ID: <CAAeHK+ypBSv54fgFmNNnpi+1_efZbPgmTZ1rFacHxcVMYHm39A@mail.gmail.com>
Subject: Re: [PATCH v13 09/20] net, arm64: untag user pointers in tcp_zerocopy_receive
To: Kevin Brodsky <kevin.brodsky@arm.com>
Cc: Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, 
	Mark Rutland <mark.rutland@arm.com>, Robin Murphy <robin.murphy@arm.com>, 
	Kees Cook <keescook@chromium.org>, Kate Stewart <kstewart@linuxfoundation.org>, 
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
	Szabolcs Nagy <Szabolcs.Nagy@arm.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Mar 25, 2019 at 2:54 PM Kevin Brodsky <kevin.brodsky@arm.com> wrote:
>
> On 22/03/2019 12:04, Catalin Marinas wrote:
> > On Wed, Mar 20, 2019 at 03:51:23PM +0100, Andrey Konovalov wrote:
> >> This patch is a part of a series that extends arm64 kernel ABI to allow to
> >> pass tagged user pointers (with the top byte set to something else other
> >> than 0x00) as syscall arguments.
> >>
> >> tcp_zerocopy_receive() uses provided user pointers for vma lookups, which
> >> can only by done with untagged pointers.
> >>
> >> Untag user pointers in this function.
> >>
> >> Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
> >> ---
> >>   net/ipv4/tcp.c | 2 ++
> >>   1 file changed, 2 insertions(+)
> >>
> >> diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
> >> index 6baa6dc1b13b..855a1f68c1ea 100644
> >> --- a/net/ipv4/tcp.c
> >> +++ b/net/ipv4/tcp.c
> >> @@ -1761,6 +1761,8 @@ static int tcp_zerocopy_receive(struct sock *sk,
> >>      if (address & (PAGE_SIZE - 1) || address != zc->address)
> >>              return -EINVAL;
> >>
> >> +    address = untagged_addr(address);
> >> +
> >>      if (sk->sk_state == TCP_LISTEN)
> >>              return -ENOTCONN;
> > I don't think we need this patch if we stick to Vincenzo's ABI
> > restrictions. Can zc->address be an anonymous mmap()? My understanding
> > of TCP_ZEROCOPY_RECEIVE is that this is an mmap() on a socket, so user
> > should not tag such pointer.
>
> Good point, I hadn't looked into the interface properly. The `vma->vm_ops !=
> &tcp_vm_ops` check just below makes sure that the mapping is specifically tied to a
> TCP socket, so definitely not included in the ABI relaxation.
>
> > We want to allow tagged pointers to work transparently only for heap and
> > stack, hence the restriction to anonymous mmap() and those addresses
> > below sbrk(0).

Right, I'll drop this patch, thanks for noticing!

>
> That's not quite true: in the ABI relaxation v2, all private mappings that are either
> anonymous or backed by a regular file are included. The scope is quite a bit larger
> than heap and stack, even though this is what we're primarily interested in for now.
>
> Kevin

