Return-Path: <SRS0=zC3H=RW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-14.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_IN_DEF_DKIM_WL
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B37B2C43381
	for <linux-mm@archiver.kernel.org>; Tue, 19 Mar 2019 16:15:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 54A6E20857
	for <linux-mm@archiver.kernel.org>; Tue, 19 Mar 2019 16:15:03 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="qxq7DiID"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 54A6E20857
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 82D066B0003; Tue, 19 Mar 2019 12:15:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7DB556B0006; Tue, 19 Mar 2019 12:15:02 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6A7156B0007; Tue, 19 Mar 2019 12:15:02 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 1FA616B0003
	for <linux-mm@kvack.org>; Tue, 19 Mar 2019 12:15:02 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id 73so22728826pga.18
        for <linux-mm@kvack.org>; Tue, 19 Mar 2019 09:15:02 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=PQgiC0kZ9u3Fy9QCp4MSDtSraYleFQhb/2xaBu2ZSrg=;
        b=KwR1mb6SQzarU5U25f2RMiw2tfQ38I2Y/Irs29lPFUhL3ZkamnpRfUqpLnoiOc6GTd
         GSz8an1hNScuRDXKuzs2B0eUMUDR5b6214BZ/FRnHHUEB+PFO5iGWNkAcZooNilUgWX+
         iNogunHsV4rqWUJ80RdmqJRyvRPFcPIFko27rQCNkHWzi2ADxz8uUMvlVFYyBZDhCc5o
         PZ95c+XhF774DVusYDtLyy2Lh/UDp6N45UlaPQCMzroxHJyaUxmQimdV6eCTg2zksaHb
         XJVikbMhv8alyjRi6vAyLf8JqzzuOKXr2JdC+JQAq9+QOLvM8UxyvX0VRrMxx9P5b4Fr
         w7ww==
X-Gm-Message-State: APjAAAXDMKUjPWcNU/NgaZ8268MAidkQw4a7RCPE1lj8kR+1JBjTF/h4
	6bwhOOZXf8YT82cEiFB2YBRaRo7hKYub/8vNb6wwmRq1kpchV/bJLUg/UnSU/nZ9Bq9wvlBuRQw
	qEDp7UQXgELPFNpzn2DGpDUt7JodawzmSdXLTtlkbQGLfK3ejVKagW/d2UsWJ5KmO2A==
X-Received: by 2002:a63:6c43:: with SMTP id h64mr2467372pgc.22.1553012101625;
        Tue, 19 Mar 2019 09:15:01 -0700 (PDT)
X-Received: by 2002:a63:6c43:: with SMTP id h64mr2467195pgc.22.1553012099435;
        Tue, 19 Mar 2019 09:14:59 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553012099; cv=none;
        d=google.com; s=arc-20160816;
        b=aA6JyBy1N11+18ygKQlCs33RpdtNFbyrCtNgV+cc0yvj6l2iGPpVpuaV3jktlY/KnK
         tSnaqILSeCYVMhrwz5cFgREmJP1dPLaUhg0+KUoVtHELRXicDU62UxAub2Iu0H0lspye
         H5of7e9C3mVrMJnYl/qamEdsQsVLLZtaPxJLw/XvT2SIbjfUnar83IUtFZuoPb4z1w0h
         z1WsE2kYtLFjv4gIg3d62Cc3k+ABYTEXAorryEL/JADk/ZNn0kVCOQFI7iEwGHi/6Ios
         5LTJxnWZ5m1xhzvqkeDiqcLfr5u7BkAyZYnGiE01EbRs2uMJUH8UfHK6QSlfl5RCtuxF
         +SJg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=PQgiC0kZ9u3Fy9QCp4MSDtSraYleFQhb/2xaBu2ZSrg=;
        b=leCS30sYv5vrjd3LmXI4v7qTK40vlYFmN7cmtV9sJpE4DTwcwGfbrM2fNuX5VEED4k
         +Spb9zudvNRPfcEFC8Tl6UqOm+H6NkTVYCtwSreMUjpjnfr4J2ot/FxPnNY12LO1JJpD
         Zzn+Rjvt4xh3OzwtwD3SHfFgBvQVnfpW2rFbpWg7cLksX7wXddqJrFLZSt2YRkQmQW2f
         fnTC5H8BGvSbr1G9IWy2FBtmalBy8yawCVcJoIkt1c/5C8+MnFu/5KrZBIf2LpLq0pxE
         RzEAPSRVHhxVVtz+5HpDB7eNw5QmiRgpJ4tpLFJNdzc5tSHw5gKLqdZBZqXhZ74kstLL
         v1Ag==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=qxq7DiID;
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l75sor20555171pfj.31.2019.03.19.09.14.59
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 19 Mar 2019 09:14:59 -0700 (PDT)
Received-SPF: pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=qxq7DiID;
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=PQgiC0kZ9u3Fy9QCp4MSDtSraYleFQhb/2xaBu2ZSrg=;
        b=qxq7DiIDvuLMVQ34GJzbbwphhe3KaybKNLLIgWZcGxMMwPerSCP8RL7QKUW6OtyBKf
         93s0/L1vzqFcVzh/gw7Cxoq5tPb1/WaJXpXJp3yNxXHHX+7WMTlqOagmGKRDtUxEMSKg
         5DS0enSD5PzEjo4jy+UcwIsjiJOFl6BnvOboDUvPFYRjHX6Bkquppw7J1+eqRrui0XyJ
         5KwS2/Yj9IcZSKFd33h7Wg5DbPnCVWpSh5pGJ75s8D7bMH8YcmfdqR842AAg13swxCOv
         Kk2MxlHMbY3GoTWt8xmPsHQ5oVfatT1NEXrOp0w5gHtoFSTLFLhBqpyqHShIAnZJ8YpW
         APtQ==
X-Google-Smtp-Source: APXvYqx361ALMb6OFk9w1BYTE4ilOTi6pgHPRxfVkFU9fEbW6rIBYMGJVoPW0XyRhBBEcWy7HAhjNpDB7rRiY+mc1bo=
X-Received: by 2002:aa7:8b12:: with SMTP id f18mr3253945pfd.240.1553012098901;
 Tue, 19 Mar 2019 09:14:58 -0700 (PDT)
MIME-Version: 1.0
References: <cover.1552929301.git.andreyknvl@google.com> <80e79c47dc7c5ee3572034a1d69bb724fbed2ecb.1552929301.git.andreyknvl@google.com>
 <CANn89iJ4SeccE79gKiv5RFqaouFV8shFA+0dCS8+2D_1aRq_Kw@mail.gmail.com>
In-Reply-To: <CANn89iJ4SeccE79gKiv5RFqaouFV8shFA+0dCS8+2D_1aRq_Kw@mail.gmail.com>
From: Andrey Konovalov <andreyknvl@google.com>
Date: Tue, 19 Mar 2019 17:14:47 +0100
Message-ID: <CAAeHK+xi4-6pgDYG8ypM8NsbhgncpsxgJeEXL1-BpkARXONvEQ@mail.gmail.com>
Subject: Re: [PATCH v12 08/13] net, arm64: untag user pointers in tcp_zerocopy_receive
To: Eric Dumazet <edumazet@google.com>
Cc: Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, 
	Mark Rutland <mark.rutland@arm.com>, Robin Murphy <robin.murphy@arm.com>, 
	Kees Cook <keescook@chromium.org>, Kate Stewart <kstewart@linuxfoundation.org>, 
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, 
	Ingo Molnar <mingo@kernel.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, 
	Shuah Khan <shuah@kernel.org>, Vincenzo Frascino <vincenzo.frascino@arm.com>, 
	"David S. Miller" <davem@davemloft.net>, Alexei Starovoitov <ast@kernel.org>, 
	Daniel Borkmann <daniel@iogearbox.net>, Steven Rostedt <rostedt@goodmis.org>, 
	Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, 
	Arnaldo Carvalho de Melo <acme@kernel.org>, Linux ARM <linux-arm-kernel@lists.infradead.org>, 
	"open list:DOCUMENTATION" <linux-doc@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, 
	linux-arch <linux-arch@vger.kernel.org>, netdev <netdev@vger.kernel.org>, 
	bpf <bpf@vger.kernel.org>, 
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

On Mon, Mar 18, 2019 at 6:35 PM Eric Dumazet <edumazet@google.com> wrote:
>
> On Mon, Mar 18, 2019 at 10:18 AM Andrey Konovalov <andreyknvl@google.com> wrote:
> >
> > This patch is a part of a series that extends arm64 kernel ABI to allow to
> > pass tagged user pointers (with the top byte set to something else other
> > than 0x00) as syscall arguments.
> >
> > tcp_zerocopy_receive() uses provided user pointers for vma lookups, which
> > can only by done with untagged pointers.
> >
> > Untag user pointers in this function.
> >
> > Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
> > ---
> >  net/ipv4/tcp.c | 9 +++++++--
> >  1 file changed, 7 insertions(+), 2 deletions(-)
> >
> > diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
> > index 6baa6dc1b13b..e76beb5ff1ff 100644
> > --- a/net/ipv4/tcp.c
> > +++ b/net/ipv4/tcp.c
> > @@ -1749,7 +1749,7 @@ EXPORT_SYMBOL(tcp_mmap);
> >  static int tcp_zerocopy_receive(struct sock *sk,
> >                                 struct tcp_zerocopy_receive *zc)
> >  {
> > -       unsigned long address = (unsigned long)zc->address;
> > +       unsigned long address;
> >         const skb_frag_t *frags = NULL;
> >         u32 length = 0, seq, offset;
> >         struct vm_area_struct *vma;
> > @@ -1758,7 +1758,12 @@ static int tcp_zerocopy_receive(struct sock *sk,
> >         int inq;
> >         int ret;
> >
> > -       if (address & (PAGE_SIZE - 1) || address != zc->address)
> > +       address = (unsigned long)untagged_addr(zc->address);
> > +
> > +       /* The second test in this if detects if the u64->unsigned long
> > +        * conversion had any truncated bits.
> > +        */
> > +       if (address & (PAGE_SIZE - 1) || address != untagged_addr(zc->address))
> >                 return -EINVAL;
> >
> >         if (sk->sk_state == TCP_LISTEN)
>
>
> This is quite ugly, the comment does not really help nor belong to this patch.
>
> What about using  untagged_addr()  only once ?
>
> diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
> index 6baa6dc1b13b0b94b1da238668b93e167cf444fe..855a1f68c1ea9b0d07a92bd7f5e7c24840a99d3d
> 100644
> --- a/net/ipv4/tcp.c
> +++ b/net/ipv4/tcp.c
> @@ -1761,6 +1761,8 @@ static int tcp_zerocopy_receive(struct sock *sk,
>         if (address & (PAGE_SIZE - 1) || address != zc->address)
>                 return -EINVAL;
>
> +       address = untagged_addr(address);
> +
>         if (sk->sk_state == TCP_LISTEN)
>                 return -ENOTCONN;

Looks good, will do it like this in the next version. Thanks!

