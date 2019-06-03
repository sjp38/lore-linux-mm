Return-Path: <SRS0=ZkFZ=UC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-14.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,T_DKIMWL_WL_MED,URIBL_BLOCKED,
	USER_IN_DEF_DKIM_WL autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E2F16C28CC6
	for <linux-mm@archiver.kernel.org>; Mon,  3 Jun 2019 17:06:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9E8CB274D2
	for <linux-mm@archiver.kernel.org>; Mon,  3 Jun 2019 17:06:28 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="XymoGc7J"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9E8CB274D2
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4901B6B028C; Mon,  3 Jun 2019 13:06:28 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4672E6B028E; Mon,  3 Jun 2019 13:06:28 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 37EEB6B028F; Mon,  3 Jun 2019 13:06:28 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id F23406B028C
	for <linux-mm@kvack.org>; Mon,  3 Jun 2019 13:06:27 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id 91so12161728pla.7
        for <linux-mm@kvack.org>; Mon, 03 Jun 2019 10:06:27 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=HYJoR/zfyv70Em+OIILglCe3XWuiH6p+K727C24pDAs=;
        b=Dc7ywGnik1kifcs1JbPB/ryUP0MzqJ93Hz/euOSl1L8FSTsLajFabFWKwYCU01VAc6
         qJFgrUWGg/Xv0i3E7lSZ1Qao0y+vDz4Hq0+LondWcLZqGH5pialE0/nUP4FSt6rsM0y7
         drZXQOLaCkvfSxaZoonvlx1YOGDtG0DqhcwAsmDR/NF2u/zyPuAW1nVmxpYeJaqzJTRn
         eF4OGtwflhp4QDzXpuocvlHLNXcZNjtjvFubra20T8c+lsrfIfFHsNGe1kv5Nsz23ITg
         2IzoUIEuy9dC+FsYnRtMfECBYj82tOVJcDMyQxopmbhGGdM7SGLH4DeCvfjhgFejFTmS
         SZ8Q==
X-Gm-Message-State: APjAAAVAyW2HPF9dmHoujmTX7p0vw0R+5PdWk77MPorublx3201oq8Rt
	kHsOxPS99CibMaPQoOd3Ujo9kHItzT97Ch/DrswBBO0efUe/zt9NUu2mGwrf73dXICFpip+eCAL
	MRUQFUvtxfJKmlaXcdNzqViJzBxcBSGaGWRMZBy+9nEQkkoTii3M9+lmdovf9gWxMng==
X-Received: by 2002:a63:6cc5:: with SMTP id h188mr30018653pgc.105.1559581587454;
        Mon, 03 Jun 2019 10:06:27 -0700 (PDT)
X-Received: by 2002:a63:6cc5:: with SMTP id h188mr30018545pgc.105.1559581586606;
        Mon, 03 Jun 2019 10:06:26 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559581586; cv=none;
        d=google.com; s=arc-20160816;
        b=Flid8czXnC4Getvs/JPtEcsPJCwnaPTdiEqEw4DJIeXTovk88JvJpLfRQhLLc+4DgP
         uGsYXmqyOUvpgfYI4Z16LXB3Iq1USRa/UE1McdN3smhl0vXjCbdjshYdsIBklfDbtoZ7
         yU6H3a+nKZVoJ9ryPQEQXMYWPjk6+UtrsG4GwNKW2vlJRZ7avG+0kw6I+vGsrpw5J33b
         iwlAca+fj8mfWBtTBHH+9N59RnbZeRgP2AF9SsksippojiM50TRZ/M8x+D33GRiH/vNM
         1wnxhZ8sGkyuHTkTTIKONVtSh01t/2lHJI/m48j9Ddru3AzvHdDS0Do4lOrX/9Qf8mrT
         2WEA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=HYJoR/zfyv70Em+OIILglCe3XWuiH6p+K727C24pDAs=;
        b=OVogEYqc8EmBY8lTOMKD6JMfyi/TX6sgWydbN8yrW+ayb6b27047IPlMGmgVBmKKlV
         XTIBSA+z52kOMLe51Op+fvnUtCGkTfIsuxnNUopaWHp2AupHPXLH0ebJ8Wt4X4osnZOO
         cT2iPaYJUiDU3HK8j6YPdokHWp1//3fm++8w3nimLwwDwrNY84OZcmMvg8S02e1JdqsD
         3TZMmHoS5mbIjSkwO4P9vcaGX/FlyhGYptdIWl6Ga714wXiH/F8iiBQsIPvfMnL/UKr0
         QBpcUvXdleQzzWEgjWhkcq+fpBMuWtB3FnxGICqumKGq/tF466kY4gNgQLEMSaELRRvm
         w/5A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=XymoGc7J;
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k75sor18012918pje.6.2019.06.03.10.06.26
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 03 Jun 2019 10:06:26 -0700 (PDT)
Received-SPF: pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=XymoGc7J;
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=HYJoR/zfyv70Em+OIILglCe3XWuiH6p+K727C24pDAs=;
        b=XymoGc7JWCRKHtM+wd/9hGi9VWGsUM72Lwa90KnvQJ358uEmtUgcHoKdtU9g/YH4UJ
         5u34zZdjU4FRJazo1vFuW3Ni1y1DNZVh/alS1ECRtC3BF7TZUH+GUyZUoEV1ZTcu35tt
         nObul5i9lrx30r8a/e6JYyssLeymB2ctqES0N7//YxV4uMKqEsaUeN3+PzxtLJVdrwsh
         Z/k985v/01dgnrGjVh59cUp9Nom/0K7l3TgAT4n5WZQPD1vgp3vkfuUimZ+Xh+PsD+fW
         QdzcgoJaWOtWSqcWc9IK1QohrHJZ7wW5wsfUIytyUhIb0Cs9PUborvrLgVelRcAz9JGB
         usaQ==
X-Google-Smtp-Source: APXvYqzVD08oLbUBv5TB7pQev79oUx9XvjbFqir2kEseCZEnF7+ERZIlVyBSOpSgKKJ3rEYpDIEwDIElz1nyAoYLJGY=
X-Received: by 2002:a17:90a:2488:: with SMTP id i8mr23649149pje.123.1559581585869;
 Mon, 03 Jun 2019 10:06:25 -0700 (PDT)
MIME-Version: 1.0
References: <cover.1559580831.git.andreyknvl@google.com> <097bc300a5c6554ca6fd1886421bb2e0adb03420.1559580831.git.andreyknvl@google.com>
 <8ff5b0ff-849a-1e0b-18da-ccb5be85dd2b@oracle.com>
In-Reply-To: <8ff5b0ff-849a-1e0b-18da-ccb5be85dd2b@oracle.com>
From: Andrey Konovalov <andreyknvl@google.com>
Date: Mon, 3 Jun 2019 19:06:14 +0200
Message-ID: <CAAeHK+xX2538e674Pz25unkdFPCO_SH0pFwFu=8+DS7RzfYnLQ@mail.gmail.com>
Subject: Re: [PATCH v16 01/16] uaccess: add untagged_addr definition for other arches
To: Khalid Aziz <khalid.aziz@oracle.com>
Cc: Linux ARM <linux-arm-kernel@lists.infradead.org>, 
	Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, 
	amd-gfx@lists.freedesktop.org, dri-devel@lists.freedesktop.org, 
	linux-rdma@vger.kernel.org, linux-media@vger.kernel.org, kvm@vger.kernel.org, 
	"open list:KERNEL SELFTEST FRAMEWORK" <linux-kselftest@vger.kernel.org>, Catalin Marinas <catalin.marinas@arm.com>, 
	Vincenzo Frascino <vincenzo.frascino@arm.com>, Will Deacon <will.deacon@arm.com>, 
	Mark Rutland <mark.rutland@arm.com>, Andrew Morton <akpm@linux-foundation.org>, 
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Kees Cook <keescook@chromium.org>, 
	Yishai Hadas <yishaih@mellanox.com>, Felix Kuehling <Felix.Kuehling@amd.com>, 
	Alexander Deucher <Alexander.Deucher@amd.com>, Christian Koenig <Christian.Koenig@amd.com>, 
	Mauro Carvalho Chehab <mchehab@kernel.org>, Jens Wiklander <jens.wiklander@linaro.org>, 
	Alex Williamson <alex.williamson@redhat.com>, Leon Romanovsky <leon@kernel.org>, 
	Luc Van Oostenryck <luc.vanoostenryck@gmail.com>, Dave Martin <Dave.Martin@arm.com>, enh <enh@google.com>, 
	Jason Gunthorpe <jgg@ziepe.ca>, Christoph Hellwig <hch@infradead.org>, Dmitry Vyukov <dvyukov@google.com>, 
	Kostya Serebryany <kcc@google.com>, Evgeniy Stepanov <eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>, 
	Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Jacob Bramley <Jacob.Bramley@arm.com>, 
	Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Robin Murphy <robin.murphy@arm.com>, 
	Kevin Brodsky <kevin.brodsky@arm.com>, Szabolcs Nagy <Szabolcs.Nagy@arm.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jun 3, 2019 at 7:04 PM Khalid Aziz <khalid.aziz@oracle.com> wrote:
>
> On 6/3/19 10:55 AM, Andrey Konovalov wrote:
> > To allow arm64 syscalls to accept tagged pointers from userspace, we must
> > untag them when they are passed to the kernel. Since untagging is done in
> > generic parts of the kernel, the untagged_addr macro needs to be defined
> > for all architectures.
> >
> > Define it as a noop for architectures other than arm64.
> >
> > Acked-by: Catalin Marinas <catalin.marinas@arm.com>
> > Reviewed-by: Khalid Aziz <khalid.aziz@oracle.com>
> > Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
> > ---
> >  include/linux/mm.h | 4 ++++
> >  1 file changed, 4 insertions(+)
> >
> > diff --git a/include/linux/mm.h b/include/linux/mm.h
> > index 0e8834ac32b7..949d43e9c0b6 100644
> > --- a/include/linux/mm.h
> > +++ b/include/linux/mm.h
> > @@ -99,6 +99,10 @@ extern int mmap_rnd_compat_bits __read_mostly;
> >  #include <asm/pgtable.h>
> >  #include <asm/processor.h>
> >
> > +#ifndef untagged_addr
> > +#define untagged_addr(addr) (addr)
> > +#endif
> > +
> >  #ifndef __pa_symbol
> >  #define __pa_symbol(x)  __pa(RELOC_HIDE((unsigned long)(x), 0))
> >  #endif
> >
>
> Andrey,
>
> This patch has now become part of the other patch series Chris Hellwig
> has sent out -
> <https://lore.kernel.org/lkml/20190601074959.14036-1-hch@lst.de/>. Can
> you coordinate with that patch series?

Hi!

Yes, I've seen it. How should I coordinate? Rebase this series on top
of that one?

Thanks!

>
> --
> Khalid
>

