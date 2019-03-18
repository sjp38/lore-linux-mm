Return-Path: <SRS0=xdO8=RV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-14.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E3D41C43381
	for <linux-mm@archiver.kernel.org>; Mon, 18 Mar 2019 17:35:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 93C4D20854
	for <linux-mm@archiver.kernel.org>; Mon, 18 Mar 2019 17:35:29 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="uyrIqaY7"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 93C4D20854
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 25AB96B0003; Mon, 18 Mar 2019 13:35:29 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1E48D6B0006; Mon, 18 Mar 2019 13:35:29 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 089846B0007; Mon, 18 Mar 2019 13:35:29 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f200.google.com (mail-it1-f200.google.com [209.85.166.200])
	by kanga.kvack.org (Postfix) with ESMTP id D281D6B0003
	for <linux-mm@kvack.org>; Mon, 18 Mar 2019 13:35:28 -0400 (EDT)
Received: by mail-it1-f200.google.com with SMTP id r136so15189149ith.3
        for <linux-mm@kvack.org>; Mon, 18 Mar 2019 10:35:28 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=PrCO2lU0ZipPiiy31J0umfmtEn4o5iLh0G0tXGxKdqM=;
        b=V6hH4xb9igaeREu4XdJry8frPGCUytIIPp86u2/44/cMEvqOWhY5lgT/ZCUqp+h4YI
         T//eGp2m4iW/mvnESgU7neRUa6iNi8TZmx8bYWK2iEb/+z2M8kjJndhNtLnxPRYB/Ur6
         bzRLriCsmZSzjzgHcg8NZzsMWmR2j9x1RLpDTKX5PsiJyGuPfTPwrGOD/Cd5AH6MFr8y
         YfrCzEGAtUGaqfPTVcBi1vcWFxzNLDGPSVDb48cqW/5fg2cHDt4m2w3wLL1bAbI5j0s7
         PLJUjE90x8mA8Nn1QXJu9RhTqeNAZqNQPGnah8kHVv+TNk5n79H/8uyjpdxb2cZWuM2M
         FNxQ==
X-Gm-Message-State: APjAAAX6mY8lWUN1pZ3fAnsxT2lbgXQNl8qlVWAu1ogNbuXzyXfEdWFY
	i87a+w2sHh6jvSp1CTY4/tek8Cu0kPB5Vcodyqr2gUI9DUU5SHapbRAHwpQBy7E6iVfWLstqRT+
	XPB4j6VAy2kEarBienM8j5Bq/JikgvKrjSKqRJf01wkeMlR1r1TDSxuUS/+Mkllfk9Q==
X-Received: by 2002:a24:39d8:: with SMTP id l207mr9244ita.59.1552930528580;
        Mon, 18 Mar 2019 10:35:28 -0700 (PDT)
X-Received: by 2002:a24:39d8:: with SMTP id l207mr9210ita.59.1552930527643;
        Mon, 18 Mar 2019 10:35:27 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552930527; cv=none;
        d=google.com; s=arc-20160816;
        b=BywBb1c3g6oObBqgyE32pun4RauZ/L6J9wl2Z1oeaS+Rg6f3njoVqjTIDOPNRUAww9
         Ssnt3ncYQ1XXG43LA4h8gI7krqqg7TmOkIC/+fuP5hG5Ht5wJsNBtpFN6LShLHRFnW/2
         KB9hHaZtWHkfprUWWh61TEsKR2UbGMY+xm1ytq5y1u3h6+NtZBWJqNQT9tWCoitqW3g7
         OyC5n7e24M4kfEQxN2VSI+4LaAX+4OTzOBzfSyxpyL9/cMgvJ3BqTELBiO2kQFUWmo3p
         EZwTIC4HnCxTFccQDRv0+BMqHFLPxuriku/uUSI/4YteSyUnzVul9sctey87P1GSb1+N
         cz9A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=PrCO2lU0ZipPiiy31J0umfmtEn4o5iLh0G0tXGxKdqM=;
        b=am75+R0B52VWZlm3mqs7trSXm+T+G53He4BcOvrEWHHyUABRQS7m4VaBZ0iz2GtcpE
         BmBOvuYxO/yqwfxFnWXXm1aInQCX0clgn3vM3ZJvM+5wvb/F8m6D3bNo6Jp2jTNYu5rf
         3P2BZzBGhmBI5jpiLfJ0X1LMU9qCwNNRhnoDRbMfz4wptCLHFmeKzAfSd2SJHI7m7MvR
         lEQQNSR/WsCFD8y1eAuRdsDQ5as/6Js8wzgUECO48sj5rI8aXjL7JpzUPaPRFMwNAUd6
         physnYqi0geRWQjvviuNw8Ysq4WBDO9w6nVh3SylDoWsK5kfZyc34tMwD69bSL43fNnJ
         4RTQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=uyrIqaY7;
       spf=pass (google.com: domain of edumazet@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=edumazet@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i5sor16852900iti.30.2019.03.18.10.35.27
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 18 Mar 2019 10:35:27 -0700 (PDT)
Received-SPF: pass (google.com: domain of edumazet@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=uyrIqaY7;
       spf=pass (google.com: domain of edumazet@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=edumazet@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=PrCO2lU0ZipPiiy31J0umfmtEn4o5iLh0G0tXGxKdqM=;
        b=uyrIqaY7oC9B9nG/UxXrp2razNOLtRgLgzTki3DkPSo3hKZBihhOVs5XMPl0tSTbG9
         8BkxMAekwOpEr5c18J94vX/PHkd/cR8S37JaGiHv2rHoQtCm8VN0JQT4bVDxL4DnFuaf
         TBpB7mtD1xZMSM6CEOwzN6ylMmjBtpj/81knOnGPRXtUhR49sy3r7rujNqeJpemmcNe/
         yahcAmwycILMB5vkZoN8PLSOFNCEEoAnrHt4dlbEmOy7anc6ZJcANenVW5WZHg63bVhQ
         EDhXKW0Z+zXP/J6GAQ7GCYiiP+UrBe+V732dR9WdPtz9JuQLQBUDqkDSRPo5Tqt0+iTo
         c1OQ==
X-Google-Smtp-Source: APXvYqw7xww6FQki8SuPZw8IxP5jWoWikBVhp58R4A7DMUEMPaLunFv8UC7JQGZkd4Yza/sj1u2HgqSyKYRRdWhydLY=
X-Received: by 2002:a05:660c:842:: with SMTP id f2mr25940itl.142.1552930526937;
 Mon, 18 Mar 2019 10:35:26 -0700 (PDT)
MIME-Version: 1.0
References: <cover.1552929301.git.andreyknvl@google.com> <80e79c47dc7c5ee3572034a1d69bb724fbed2ecb.1552929301.git.andreyknvl@google.com>
In-Reply-To: <80e79c47dc7c5ee3572034a1d69bb724fbed2ecb.1552929301.git.andreyknvl@google.com>
From: Eric Dumazet <edumazet@google.com>
Date: Mon, 18 Mar 2019 10:35:14 -0700
Message-ID: <CANn89iJ4SeccE79gKiv5RFqaouFV8shFA+0dCS8+2D_1aRq_Kw@mail.gmail.com>
Subject: Re: [PATCH v12 08/13] net, arm64: untag user pointers in tcp_zerocopy_receive
To: Andrey Konovalov <andreyknvl@google.com>
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

On Mon, Mar 18, 2019 at 10:18 AM Andrey Konovalov <andreyknvl@google.com> wrote:
>
> This patch is a part of a series that extends arm64 kernel ABI to allow to
> pass tagged user pointers (with the top byte set to something else other
> than 0x00) as syscall arguments.
>
> tcp_zerocopy_receive() uses provided user pointers for vma lookups, which
> can only by done with untagged pointers.
>
> Untag user pointers in this function.
>
> Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
> ---
>  net/ipv4/tcp.c | 9 +++++++--
>  1 file changed, 7 insertions(+), 2 deletions(-)
>
> diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
> index 6baa6dc1b13b..e76beb5ff1ff 100644
> --- a/net/ipv4/tcp.c
> +++ b/net/ipv4/tcp.c
> @@ -1749,7 +1749,7 @@ EXPORT_SYMBOL(tcp_mmap);
>  static int tcp_zerocopy_receive(struct sock *sk,
>                                 struct tcp_zerocopy_receive *zc)
>  {
> -       unsigned long address = (unsigned long)zc->address;
> +       unsigned long address;
>         const skb_frag_t *frags = NULL;
>         u32 length = 0, seq, offset;
>         struct vm_area_struct *vma;
> @@ -1758,7 +1758,12 @@ static int tcp_zerocopy_receive(struct sock *sk,
>         int inq;
>         int ret;
>
> -       if (address & (PAGE_SIZE - 1) || address != zc->address)
> +       address = (unsigned long)untagged_addr(zc->address);
> +
> +       /* The second test in this if detects if the u64->unsigned long
> +        * conversion had any truncated bits.
> +        */
> +       if (address & (PAGE_SIZE - 1) || address != untagged_addr(zc->address))
>                 return -EINVAL;
>
>         if (sk->sk_state == TCP_LISTEN)


This is quite ugly, the comment does not really help nor belong to this patch.

What about using  untagged_addr()  only once ?

diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 6baa6dc1b13b0b94b1da238668b93e167cf444fe..855a1f68c1ea9b0d07a92bd7f5e7c24840a99d3d
100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -1761,6 +1761,8 @@ static int tcp_zerocopy_receive(struct sock *sk,
        if (address & (PAGE_SIZE - 1) || address != zc->address)
                return -EINVAL;

+       address = untagged_addr(address);
+
        if (sk->sk_state == TCP_LISTEN)
                return -ENOTCONN;

