Return-Path: <SRS0=U3FQ=WP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-14.4 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_IN_DEF_DKIM_WL
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E9B00C3A5A0
	for <linux-mm@archiver.kernel.org>; Mon, 19 Aug 2019 13:16:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A34D42086C
	for <linux-mm@archiver.kernel.org>; Mon, 19 Aug 2019 13:16:57 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="M2vK+xZV"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A34D42086C
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4C97E6B0008; Mon, 19 Aug 2019 09:16:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4A0EA6B000A; Mon, 19 Aug 2019 09:16:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3B75B6B000C; Mon, 19 Aug 2019 09:16:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0142.hostedemail.com [216.40.44.142])
	by kanga.kvack.org (Postfix) with ESMTP id 1C79C6B0008
	for <linux-mm@kvack.org>; Mon, 19 Aug 2019 09:16:57 -0400 (EDT)
Received: from smtpin13.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id C2653180AD7C3
	for <linux-mm@kvack.org>; Mon, 19 Aug 2019 13:16:56 +0000 (UTC)
X-FDA: 75839227632.13.judge75_59b10e03dc74c
X-HE-Tag: judge75_59b10e03dc74c
X-Filterd-Recvd-Size: 5718
Received: from mail-pg1-f195.google.com (mail-pg1-f195.google.com [209.85.215.195])
	by imf20.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon, 19 Aug 2019 13:16:56 +0000 (UTC)
Received: by mail-pg1-f195.google.com with SMTP id n190so1228646pgn.0
        for <linux-mm@kvack.org>; Mon, 19 Aug 2019 06:16:56 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=G3QrTp7p7joYbJCkRsXIJddWfOp/eioksMTpigV+wkM=;
        b=M2vK+xZVjtXBYjUxUUk1iMNbxYwjUd+W6togCQiYPc7Vu+BGQx7l3hXcn4ECMLvDWt
         DlIAvUe8ekFSnxnofy3VvCNWLct8LZOpiNSM+v1WhYFyPJDwu5gZzaBjspAETr+32sje
         Xh1peTR5yYmEcUyhpwKV8rR/zI3wE7krkn5mWhAZXsBdSmKIExx6Aai/02AtaqBWuiMJ
         rwdLtwVmt2z/BiSdji1RT9OqjhuC+NoRsQcrlELRw7LuJbnkQsJhQDfS2T7BkdRszDtd
         SsGJHm5kXWMKbJ6caWbq9raXqyHYkwoMk/qLwvz6vTD2dWWbREUV34BsqN2ExAzlW+sj
         Ywjg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=G3QrTp7p7joYbJCkRsXIJddWfOp/eioksMTpigV+wkM=;
        b=JTtOQbXo7dPCT+ifemLsL1m0Cl3aVkKzsTahxwECWYkdTzYYaNWUijnWlAHS7uISTv
         c+2yM3QY03Ct5jkitBl5uq8ZR8iDcFQaYnX+3wqwIMZ6ogGoPinL65Yu7W15J9/oDQa5
         tBdvId1+dP3UgG0UFhkkdZFQcs6pEYhqbAQ4a/e/Bk8eTpax2RL4zMzkJV8OYHv3zqMZ
         PD8uM/5+1B5UtHsu16R12iiisTvoNtmHpYd6a/MX61hII217Valn2xZLaKQ1owLudJ7a
         uhhqdVaVeokBoW9tbWX9qlymW+Hsn+g6ICu6Beol7Om+AQj93adW/PDTxxVAACNbK8QR
         c09g==
X-Gm-Message-State: APjAAAXDM2VC4vaApCWFYZkb6qFrBSY83H2dZTISXAconz6WBMV73yvl
	5HFKlOzUlf74UmgNr9xmnaQvRXkwAH+L0wPuw7RL+g==
X-Google-Smtp-Source: APXvYqyVpOFailHQYDN6SGrqGiLu77ISHhF0UzRLkKGS0q9bNLzKJCagc2Nkkti9u80AQyBrYjiyPqa9PxLeXB9+mf8=
X-Received: by 2002:aa7:9e0a:: with SMTP id y10mr23727599pfq.93.1566220614754;
 Mon, 19 Aug 2019 06:16:54 -0700 (PDT)
MIME-Version: 1.0
References: <00eb8ba84205c59cac01b1b47615116a461c302c.1566220355.git.andreyknvl@google.com>
In-Reply-To: <00eb8ba84205c59cac01b1b47615116a461c302c.1566220355.git.andreyknvl@google.com>
From: Andrey Konovalov <andreyknvl@google.com>
Date: Mon, 19 Aug 2019 15:16:43 +0200
Message-ID: <CAAeHK+xBKrS0LZX+d3psaynznU4tQGfz4wQ9oFanxjjPv1ytVQ@mail.gmail.com>
Subject: Re: [PATCH ARM] selftests, arm64: fix uninitialized symbol in tags_test.c
To: Will Deacon <will.deacon@arm.com>
Cc: Catalin Marinas <catalin.marinas@arm.com>, Vincenzo Frascino <vincenzo.frascino@arm.com>, 
	Mark Rutland <mark.rutland@arm.com>, Andrew Morton <akpm@linux-foundation.org>, 
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Kees Cook <keescook@chromium.org>, 
	Yishai Hadas <yishaih@mellanox.com>, Felix Kuehling <Felix.Kuehling@amd.com>, 
	Alexander Deucher <Alexander.Deucher@amd.com>, Christian Koenig <Christian.Koenig@amd.com>, 
	Mauro Carvalho Chehab <mchehab@kernel.org>, Jens Wiklander <jens.wiklander@linaro.org>, 
	Alex Williamson <alex.williamson@redhat.com>, Leon Romanovsky <leon@kernel.org>, 
	Luc Van Oostenryck <luc.vanoostenryck@gmail.com>, Dave Martin <Dave.Martin@arm.com>, 
	Khalid Aziz <khalid.aziz@oracle.com>, enh <enh@google.com>, Jason Gunthorpe <jgg@ziepe.ca>, 
	Christoph Hellwig <hch@infradead.org>, Dmitry Vyukov <dvyukov@google.com>, 
	Kostya Serebryany <kcc@google.com>, Evgeniy Stepanov <eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>, 
	Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Jacob Bramley <Jacob.Bramley@arm.com>, 
	Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Robin Murphy <robin.murphy@arm.com>, 
	Kevin Brodsky <kevin.brodsky@arm.com>, Szabolcs Nagy <Szabolcs.Nagy@arm.com>, 
	Dan Carpenter <dan.carpenter@oracle.com>, Linux ARM <linux-arm-kernel@lists.infradead.org>, 
	Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, 
	amd-gfx@lists.freedesktop.org, dri-devel@lists.freedesktop.org, 
	linux-rdma@vger.kernel.org, linux-media@vger.kernel.org, kvm@vger.kernel.org, 
	"open list:KERNEL SELFTEST FRAMEWORK" <linux-kselftest@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Aug 19, 2019 at 3:14 PM Andrey Konovalov <andreyknvl@google.com> wrote:
>
> Fix tagged_ptr not being initialized when TBI is not enabled.
>
> Dan Carpenter <dan.carpenter@oracle.com>
> Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
> ---
>  tools/testing/selftests/arm64/tags_test.c | 8 +++++---
>  1 file changed, 5 insertions(+), 3 deletions(-)
>
> diff --git a/tools/testing/selftests/arm64/tags_test.c b/tools/testing/selftests/arm64/tags_test.c
> index 22a1b266e373..5701163460ef 100644
> --- a/tools/testing/selftests/arm64/tags_test.c
> +++ b/tools/testing/selftests/arm64/tags_test.c
> @@ -14,15 +14,17 @@
>  int main(void)
>  {
>         static int tbi_enabled = 0;
> -       struct utsname *ptr, *tagged_ptr;
> +       unsigned long tag = 0;
> +       struct utsname *ptr;
>         int err;
>
>         if (prctl(PR_SET_TAGGED_ADDR_CTRL, PR_TAGGED_ADDR_ENABLE, 0, 0, 0) == 0)
>                 tbi_enabled = 1;
>         ptr = (struct utsname *)malloc(sizeof(*ptr));
>         if (tbi_enabled)
> -               tagged_ptr = (struct utsname *)SET_TAG(ptr, 0x42);
> -       err = uname(tagged_ptr);
> +               tag = 0x42;
> +       ptr = (struct utsname *)SET_TAG(ptr, tag);
> +       err = uname(ptr);
>         free(ptr);
>
>         return err;
> --
> 2.23.0.rc1.153.gdeed80330f-goog
>

Hi Will,

This is supposed to go on top of the TBI related patches that you have
added to the arm tree.

Thanks!

