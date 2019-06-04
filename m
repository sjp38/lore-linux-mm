Return-Path: <SRS0=7ZCb=UD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-14.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,T_DKIMWL_WL_MED,USER_IN_DEF_DKIM_WL
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5037AC28CC6
	for <linux-mm@archiver.kernel.org>; Tue,  4 Jun 2019 12:05:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 08120249DA
	for <linux-mm@archiver.kernel.org>; Tue,  4 Jun 2019 12:05:29 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="Q1qaT6gu"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 08120249DA
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 928DE6B026B; Tue,  4 Jun 2019 08:05:29 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8B1E56B0277; Tue,  4 Jun 2019 08:05:29 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 753876B0278; Tue,  4 Jun 2019 08:05:29 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 38ACD6B026B
	for <linux-mm@kvack.org>; Tue,  4 Jun 2019 08:05:29 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id d7so12262287pgc.8
        for <linux-mm@kvack.org>; Tue, 04 Jun 2019 05:05:29 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=j34LYUoJM4InkQPNFKh7Ow4BYIjL6/oVFRsfu7DIJqw=;
        b=CGFAPdeDtjSv2ET1xs7tPpigqjpch9VZ+AxhUo/dbcYuFxskgPOuQDXXucBjb7WIZl
         Oet3bYaOxs1sn1f6hcnhzXKTay3QP3T10qootzacvJnNam3JyHhN8uGEvDnK73rBENKp
         pipJ6KglDrNdPmM0Z+tdjQee+DZPBahAsSWbyZZ+z9O2GMNVyLUKTKBdoWyc8xOYixGL
         YpZXuW/DQOLxO/qs62tSdHfaJZhDkFPyBcgEzll0Q4niIRolpSj2r8aYnIgHe6nqCr1g
         7r6C/6e3MRJROEzVxjrbyzrVp3+33FZHC1GDy7QgQoOri0v7gTYkeXneyA5NIRvaLe1q
         b99Q==
X-Gm-Message-State: APjAAAWy0u9l4P1SuBVy3rHy8dOi58m78Ka+8nIPZkY0PjaJXu0ehINg
	WV7NEj1p0eH0SOwMfv6cVdpPNoV7JKQhwClpepO8DfViGCFnmPLcnVk19GdKhvwl3EDPPZgeU3A
	7IO64eI2QdBHVDrR6VpYIJPA3Q1mzqeVOHQJ+LeDTni0Gdk1YE2VQU0v38cS7DeCibQ==
X-Received: by 2002:a63:ff0c:: with SMTP id k12mr35028872pgi.32.1559649928891;
        Tue, 04 Jun 2019 05:05:28 -0700 (PDT)
X-Received: by 2002:a63:ff0c:: with SMTP id k12mr35028783pgi.32.1559649928167;
        Tue, 04 Jun 2019 05:05:28 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559649928; cv=none;
        d=google.com; s=arc-20160816;
        b=kd3uH1Affg9k0RKdeSfm/TfeeqxwpE5b+nYmxfmkSVJMskMyAiKogDPpO++CxZyGLJ
         EU8OmMrkMPmaiBRJDbQnC0eQtCXCK3mk847eA5rKrswRPFN/wBFJk5fdR0LfEYjlqfQ7
         tL/mI5DjjxURqx6pEJQqP++7j/5yqPnR6uPec/2U5GFV2eZbhxUJ0HggBzOa8JLFBVZo
         BAdj6p7tmAePRxlrJvEf2NkNT9Obf3lprOPv2m9aDnqeZEbUM1V0wV6fvm8XZHyWlh7d
         mGl4pj5L5G3kIp5u4Fkoi4hWcENambE6tZnZmVUWQDa1VQb0cSyvfzVS2Bh1udGoqqpJ
         Lb7w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=j34LYUoJM4InkQPNFKh7Ow4BYIjL6/oVFRsfu7DIJqw=;
        b=i3KoQ26U6EdwAVEBuzEV5BpeG+Mhg0SYPNL6zrdNkoAw6PbcOSulZERvuXsn8IsM/i
         04eDr/dc8PXol2PtXHkENrV1VA2vAJNxYXdfVgjTk8mMDZg69HUhHR8IGnKJpZQ3stAA
         HTq85u20h5QEsk5Eqw1QV23RXTft7Lm0VaCJGSjUuYacMsfWGJivh73wAnvvZBW5s7I5
         pPCSj/NbRiwchrb6wT0lxukw7u0dNzR9zA5R6XdDoZ69XS3uHBh5UpqwcHv1IQ7P8eva
         Tpu643hC0mrdXYTcQpsi7rCo/IonoJqQGpdAYtukfnLLEf2W7MTxQPoen6m1kzKSCX0Q
         bb9w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=Q1qaT6gu;
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v16sor20382917pjr.23.2019.06.04.05.05.28
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 04 Jun 2019 05:05:28 -0700 (PDT)
Received-SPF: pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=Q1qaT6gu;
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=j34LYUoJM4InkQPNFKh7Ow4BYIjL6/oVFRsfu7DIJqw=;
        b=Q1qaT6guKN0cVPZ3I7m80z+l8td98w2uqIqeYi7AFZlLfwx0G3uMrYBq/J+BmnmOkM
         atOxQZO2OZRPqsjN3jqBQv44CvwjPmxvlTBcPKmMi6XjoZEmV/fygK5lB45wakW1x509
         lWKLza5Yda4CAzzaQyvI+9jrqysNJKJVvTJhllwO+UsWDQVgevJunQ8PW4WiDuXWRUXU
         7jLII5xQ27xFuA+YQ/J9v/BCfFu0O+m0Eo51qSbf6BhnxxvgwoGoytsvTWBHtF3OYNCG
         5xAYIJ3eDxoQdAcL8X0Di1QghLFbw2D39YI3GMMqxvSPlDl32yI9DfA4EynC+NBnx3BM
         Md2A==
X-Google-Smtp-Source: APXvYqwvrt39xcYJfCMZYMz7iLhPbel6HsvYFhEAa8PCAaMa5qdXOZSee+ccpu58h4UkbZo4zcE90xOl7nDE7Qf6Y+o=
X-Received: by 2002:a17:90a:2488:: with SMTP id i8mr28700584pje.123.1559649927361;
 Tue, 04 Jun 2019 05:05:27 -0700 (PDT)
MIME-Version: 1.0
References: <8ab5cd1813b0890f8780018e9784838456ace49e.1559648669.git.andreyknvl@google.com>
 <d74b1621-70a2-94a0-e24b-dae32adc457d@amd.com> <CAAeHK+w0_9QdxCJXEf=6nMgZpsb8NyrAaMO010Hh86TW75jJvw@mail.gmail.com>
 <ff73058a-f57b-526b-af53-c0e30b7b1bc1@amd.com>
In-Reply-To: <ff73058a-f57b-526b-af53-c0e30b7b1bc1@amd.com>
From: Andrey Konovalov <andreyknvl@google.com>
Date: Tue, 4 Jun 2019 14:05:16 +0200
Message-ID: <CAAeHK+wfNbNz_AP8c4PqcpWXuLxx23D1coY0SS5ORM_tUewNFA@mail.gmail.com>
Subject: Re: [PATCH] uaccess: add noop untagged_addr definition
To: "Koenig, Christian" <Christian.Koenig@amd.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, 
	"linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, 
	"sparclinux@vger.kernel.org" <sparclinux@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, 
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Catalin Marinas <catalin.marinas@arm.com>, 
	Vincenzo Frascino <vincenzo.frascino@arm.com>, Will Deacon <will.deacon@arm.com>, 
	Mark Rutland <mark.rutland@arm.com>, Andrew Morton <akpm@linux-foundation.org>, 
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Kees Cook <keescook@chromium.org>, 
	Yishai Hadas <yishaih@mellanox.com>, "Kuehling, Felix" <Felix.Kuehling@amd.com>, 
	"Deucher, Alexander" <Alexander.Deucher@amd.com>, Mauro Carvalho Chehab <mchehab@kernel.org>, 
	Jens Wiklander <jens.wiklander@linaro.org>, Alex Williamson <alex.williamson@redhat.com>, 
	Leon Romanovsky <leon@kernel.org>, Luc Van Oostenryck <luc.vanoostenryck@gmail.com>, 
	Dave Martin <Dave.Martin@arm.com>, Khalid Aziz <khalid.aziz@oracle.com>, enh <enh@google.com>, 
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

On Tue, Jun 4, 2019 at 1:49 PM Koenig, Christian
<Christian.Koenig@amd.com> wrote:
>
> Am 04.06.19 um 13:48 schrieb Andrey Konovalov:
> > On Tue, Jun 4, 2019 at 1:46 PM Koenig, Christian
> > <Christian.Koenig@amd.com> wrote:
> >> Am 04.06.19 um 13:44 schrieb Andrey Konovalov:
> >>> Architectures that support memory tagging have a need to perform untagging
> >>> (stripping the tag) in various parts of the kernel. This patch adds an
> >>> untagged_addr() macro, which is defined as noop for architectures that do
> >>> not support memory tagging. The oncoming patch series will define it at
> >>> least for sparc64 and arm64.
> >>>
> >>> Acked-by: Catalin Marinas <catalin.marinas@arm.com>
> >>> Reviewed-by: Khalid Aziz <khalid.aziz@oracle.com>
> >>> Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
> >>> ---
> >>>    include/linux/mm.h | 4 ++++
> >>>    1 file changed, 4 insertions(+)
> >>>
> >>> diff --git a/include/linux/mm.h b/include/linux/mm.h
> >>> index 0e8834ac32b7..949d43e9c0b6 100644
> >>> --- a/include/linux/mm.h
> >>> +++ b/include/linux/mm.h
> >>> @@ -99,6 +99,10 @@ extern int mmap_rnd_compat_bits __read_mostly;
> >>>    #include <asm/pgtable.h>
> >>>    #include <asm/processor.h>
> >>>
> >>> +#ifndef untagged_addr
> >>> +#define untagged_addr(addr) (addr)
> >>> +#endif
> >>> +
> >> Maybe add a comment what tagging actually is? Cause that is not really
> >> obvious from the context.
> > Hi,
> >
> > Do you mean a comment in the code or an explanation in the patch description?
>
> The code, the patch description actually sounds good to me.

Sent v2, thanks!

>
> Christian.
>
> >
> > Thanks!
> >
> >> Christian.
> >>
> >>>    #ifndef __pa_symbol
> >>>    #define __pa_symbol(x)  __pa(RELOC_HIDE((unsigned long)(x), 0))
> >>>    #endif
>

