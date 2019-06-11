Return-Path: <SRS0=/KmR=UK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-11.4 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,T_DKIMWL_WL_MED,USER_IN_DEF_DKIM_WL
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9E1BCC0650E
	for <linux-mm@archiver.kernel.org>; Tue, 11 Jun 2019 17:18:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5C2C52086D
	for <linux-mm@archiver.kernel.org>; Tue, 11 Jun 2019 17:18:18 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="b9zA6Ql8"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5C2C52086D
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0B1646B0008; Tue, 11 Jun 2019 13:18:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 060866B000D; Tue, 11 Jun 2019 13:18:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E6AAB6B0010; Tue, 11 Jun 2019 13:18:17 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id AC7C36B0008
	for <linux-mm@kvack.org>; Tue, 11 Jun 2019 13:18:17 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id b10so5273204pgb.22
        for <linux-mm@kvack.org>; Tue, 11 Jun 2019 10:18:17 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=cRK7dSJ9ozXpkMag7XMLUlUKlJp+YVQsFuMywlLYIIY=;
        b=ngLcesrOk9W63WfBqPzAS7T+OLhyvI15KRWR+MeO6SzLjSNil7uAsAU1vLBfTnT6xW
         prUzG4N8AWl/7ZlD+LIJr0TWHHajMaQ7nUbro294CLD0ntgpbBb9W7Skx7JUwWgKcCc2
         osV78kFjj5ALqzLsx/KUijkun/YsesvW8gJ0Z3gm9/Jqgha5ZvkJLbv/FULHpN1FANAv
         gVm0v4Df2MBeIwdY4fXPA8doU/EFUZ1hNmnvVtWO1uJGEtSZekl7PzKLTI2ffsZYHMBS
         HUQpAlOo/4Kq27pMa76TVrAOi6UgkggKKy/eo8OUfI8bZcVcgXnpFSzHTY/sIXZhqK0S
         QmdA==
X-Gm-Message-State: APjAAAW4x/CQNUDtVU84jJgaZPUZRgeDn9z50F+cyQC3jKU4kuMgAUGD
	XNIWsYi1R22c1z/IuQDwPKsmU0KVwCwH9i7VZn6M4+waAdI61ZfVGIDIpK1MGtU/NY2WA8au/NT
	osBZ/2oXkS0Z1bSvRuGl9K+ULRjzqD1F6bLdlfDhj4G7PIrd7iZE8ND4DhGodW1cXmA==
X-Received: by 2002:a65:4283:: with SMTP id j3mr20683244pgp.88.1560273497307;
        Tue, 11 Jun 2019 10:18:17 -0700 (PDT)
X-Received: by 2002:a65:4283:: with SMTP id j3mr20683192pgp.88.1560273496559;
        Tue, 11 Jun 2019 10:18:16 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560273496; cv=none;
        d=google.com; s=arc-20160816;
        b=va0unUgswqhW9Jg+CxjvmA2qhHorR6ohYCnBUSmXAwuOdBDrxpxCR6d9uty74F9rjd
         Ja9viHYJpmWE4Izhys/AdRmZteetFjo2TtYWg7Z+US4EH7tgGbWnR0p5qOJOUbOU0tpA
         cJZ8CwELs3WS4j3wfgXmS0SNKJXrRGr/8XC+L7AJs7i5eALqRKv4Fr9emxq1LNDXT/vm
         rH6ErJiYKi/nG6Unxw/U+YKmHsDnZYoP4tyq216gS+Wr3bXIT5qgT7BpN19kXp3Rq+tU
         NMewADqlQG0nHPDcWd7V1tqG1RT/n9iZfpOjdXxa9PVWITXSEqufGAH7Fjj3HdFi3EHl
         3/7Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=cRK7dSJ9ozXpkMag7XMLUlUKlJp+YVQsFuMywlLYIIY=;
        b=VpJ9EOHhzehrSvgPrcSogasI/GBSzpO7/BxPBuVdey2nZTEHFWTg0Ki8Q8juT8+WSQ
         MIP0Jm4JfapPJYNoX9NAAHPP5O84f+gf0EOenu6AGVJJcR7J/sQrb8gvl+KEjC8mov7c
         PjJgJMcoyT6J+ABuLX2LtqRS/11JBBtwpmfsEYtjDZ/FngGJSz2eM20guIC3FUaVMGle
         0OC5wpSiVmxWiVBaE0slTDgUNef1aQSfoLMQkVCM3Srno+wcsIIUYweZPw36jQDNiVKU
         9672ib4b7QJPuvXSXncAoHgYWwhBWArOMl6itBC63IRR6zFQV2ewE6tBuMn9UIK5lhTL
         TzCw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=b9zA6Ql8;
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r96sor3734416pjb.6.2019.06.11.10.18.16
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 11 Jun 2019 10:18:16 -0700 (PDT)
Received-SPF: pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=b9zA6Ql8;
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=cRK7dSJ9ozXpkMag7XMLUlUKlJp+YVQsFuMywlLYIIY=;
        b=b9zA6Ql86DPqQkTp5i0i6v7MtDOq0tAACNbJiToG/gsWM88lOHPNTLEE2A75D2FKoO
         SaTGSkkdbkFjBHB6V7dNy3yNl8DW1iE0pnw0WmGXH9zKr6DLv5bE7mRA4LdyIllbpD/D
         KcrOvJfjpWiyccNOyNMsy4lUx+9EWF4+Rz1owvnwBXs022X3zquKp/rp+skYCj68ppuI
         s9oCX7Or8ik9oAg9pTuxoIFV/Q0kJ7gPx7GPxqYH4vPwX3SSd1Ma3tHuV9GC8yXrZkiY
         8Msdnuz2aqf5gojfEQ2ZtoCfHhj+2CsKFVVs7asqO5iLhZbFI9QDBNBmCP2d56v0+z1i
         p9EA==
X-Google-Smtp-Source: APXvYqwTIY2/OtCAe2ytKIYqGY3omJlioSYHG1JrmGnaMaDG0e9TwsYGQisqOCiIuCpfggd2Tzz2lgNj29c+F+rHVNg=
X-Received: by 2002:a17:90a:2488:: with SMTP id i8mr27381746pje.123.1560273495783;
 Tue, 11 Jun 2019 10:18:15 -0700 (PDT)
MIME-Version: 1.0
References: <cover.1559580831.git.andreyknvl@google.com> <9e1b5998a28f82b16076fc85ab4f88af5381cf74.1559580831.git.andreyknvl@google.com>
 <20190611150122.GB63588@arrakis.emea.arm.com>
In-Reply-To: <20190611150122.GB63588@arrakis.emea.arm.com>
From: Andrey Konovalov <andreyknvl@google.com>
Date: Tue, 11 Jun 2019 19:18:04 +0200
Message-ID: <CAAeHK+wZrVXxAnDXBjoUy8JK9iG553G2Bp8uPWQ0u1u5gts0vQ@mail.gmail.com>
Subject: Re: [PATCH v16 16/16] selftests, arm64: add a selftest for passing
 tagged pointers to kernel
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: Linux ARM <linux-arm-kernel@lists.infradead.org>, 
	Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, 
	amd-gfx@lists.freedesktop.org, dri-devel@lists.freedesktop.org, 
	linux-rdma@vger.kernel.org, linux-media@vger.kernel.org, kvm@vger.kernel.org, 
	"open list:KERNEL SELFTEST FRAMEWORK" <linux-kselftest@vger.kernel.org>, 
	Vincenzo Frascino <vincenzo.frascino@arm.com>, Will Deacon <will.deacon@arm.com>, 
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
	Kevin Brodsky <kevin.brodsky@arm.com>, Szabolcs Nagy <Szabolcs.Nagy@arm.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jun 11, 2019 at 5:01 PM Catalin Marinas <catalin.marinas@arm.com> wrote:
>
> On Mon, Jun 03, 2019 at 06:55:18PM +0200, Andrey Konovalov wrote:
> > This patch is a part of a series that extends arm64 kernel ABI to allow to
> > pass tagged user pointers (with the top byte set to something else other
> > than 0x00) as syscall arguments.
> >
> > This patch adds a simple test, that calls the uname syscall with a
> > tagged user pointer as an argument. Without the kernel accepting tagged
> > user pointers the test fails with EFAULT.
> >
> > Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
>
> BTW, you could add
>
> Co-developed-by: Catalin Marinas <catalin.marinas@arm.com>
>
> since I wrote the malloc() etc. hooks.

Sure!

>
>
> > +static void *tag_ptr(void *ptr)
> > +{
> > +     unsigned long tag = rand() & 0xff;
> > +     if (!ptr)
> > +             return ptr;
> > +     return (void *)((unsigned long)ptr | (tag << TAG_SHIFT));
> > +}
>
> With the prctl() option, this function becomes (if you have a better
> idea, fine by me):
>
> ----------8<---------------
> #include <stdlib.h>
> #include <sys/prctl.h>
>
> #define TAG_SHIFT       (56)
> #define TAG_MASK        (0xffUL << TAG_SHIFT)
>
> #define PR_SET_TAGGED_ADDR_CTRL         55
> #define PR_GET_TAGGED_ADDR_CTRL         56
> # define PR_TAGGED_ADDR_ENABLE          (1UL << 0)
>
> void *__libc_malloc(size_t size);
> void __libc_free(void *ptr);
> void *__libc_realloc(void *ptr, size_t size);
> void *__libc_calloc(size_t nmemb, size_t size);
>
> static void *tag_ptr(void *ptr)
> {
>         static int tagged_addr_err = 1;
>         unsigned long tag = 0;
>
>         if (tagged_addr_err == 1)
>                 tagged_addr_err = prctl(PR_SET_TAGGED_ADDR_CTRL,
>                                         PR_TAGGED_ADDR_ENABLE, 0, 0, 0);

I think this requires atomics. malloc() can be called from multiple threads.

>
>         if (!ptr)
>                 return ptr;
>         if (!tagged_addr_err)
>                 tag = rand() & 0xff;
>
>         return (void *)((unsigned long)ptr | (tag << TAG_SHIFT));
> }
>
> --
> Catalin

