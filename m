Return-Path: <SRS0=007R=T7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,T_DKIMWL_WL_MED,USER_IN_DEF_DKIM_WL autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 54B3BC28CC2
	for <linux-mm@archiver.kernel.org>; Fri, 31 May 2019 14:22:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0B81126A5D
	for <linux-mm@archiver.kernel.org>; Fri, 31 May 2019 14:22:02 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="ZKOkIMzc"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0B81126A5D
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8FF136B026F; Fri, 31 May 2019 10:22:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8AFBE6B027A; Fri, 31 May 2019 10:22:02 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 79EE36B027C; Fri, 31 May 2019 10:22:02 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 40C916B026F
	for <linux-mm@kvack.org>; Fri, 31 May 2019 10:22:02 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id e20so4801568pgm.16
        for <linux-mm@kvack.org>; Fri, 31 May 2019 07:22:02 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=lqGZhr1OXDcqw01dRW7YMwNNKArDZmNdR/78N+BPrn4=;
        b=Xmhdj26c6OX3hi7HNma0I+/jf/Eifx8WN3splrMxHVc1fuWqjruc3OypkBhVJAh0Ul
         VAz9g2CCNUWgRVM2T3plZrvfrN64ktOHjfmq4DxQq42a3Ah7yXp5O4YtZtFPeY2ha5iU
         +XCDreNgHpPk2ovLOhjKZOXqwIAlaleH/8K21JXNoRS49e4i0wSjG4Vom0OV4IcV8xBK
         NxFl6lPJeOPUVkDfvII6lHET9TqXJu8e8kRon+K7Xc03a0snEIwoxJeR9tTPXD6juqCZ
         en3HrldZ8oqy1/5gLnv9XhzNBwFwnRBebX+MdqeUbvXqssb0n+LjqNsEMDCBgJbHhUT0
         z9JA==
X-Gm-Message-State: APjAAAW3+xQg4fs0lC1B2kzkCtP4wVfmttOjIVxRwdVSefw1rA4ktWBS
	tOK+rS5O/1Jc3npk08KclULbFGmLHZ7JCQjXJ6f2F4llyWMnNswgpt+3VsrucPU2QWXl5lWAj8N
	U5BVto4ecWjTx6BoZ03hEXBJ1psvuYclv7uyMJwWmKcijY7YdtZl+U6GI8slmwUS6KA==
X-Received: by 2002:a17:90a:c38a:: with SMTP id h10mr9145584pjt.112.1559312521886;
        Fri, 31 May 2019 07:22:01 -0700 (PDT)
X-Received: by 2002:a17:90a:c38a:: with SMTP id h10mr9145436pjt.112.1559312520432;
        Fri, 31 May 2019 07:22:00 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559312520; cv=none;
        d=google.com; s=arc-20160816;
        b=R+idjnKILxBgYE8kCU8GeIqitbI5mSotMWFlXLLyRrcF/S4bno64uezWxGW2rBX5lE
         HlvpsBe6imu4SyV6xFgE63QoXc2BBAaKj5FA6sAk3nLiFJk2sMj06cb9HrVy/5cXMv2s
         CWyxUvDsw1WgfZateTlupOVPxWhJcou0tpPfT9GpJgFVgBoz69psAG2G5euxHMlYSol+
         +uC8pVTkon2ly2F9WI3RMmyQDBAzUpqFZb7rh8jlLIykSa+zM/WIJAmzAwFaKol0TiPe
         2TMBXNWWG2i+EAiUJLxb9m08H+C0lfI1HL8d5wiBgIi2hV2jDodQbZ+Zl/OaOXFs4vSa
         9zAg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=lqGZhr1OXDcqw01dRW7YMwNNKArDZmNdR/78N+BPrn4=;
        b=PSCTEmBE7w6e4bOsY5ltM+pZNCwAETonWxkFVdxbp7ecIFF1DjBE1aJcpm4qLrzA3B
         5f+POUVbi8S07E3x7qkUXVqKsoJMdMR5sZ2MiRuUWktEeSLolW5s8UG6Q9i2I9wG37Wt
         2yDQH7cbqTh2ihyWghjxYh8QDcF2c4+MjPF4tJFeKVTpfjEQfpiITYLVISB7+rDIJ9+a
         1xJrQM0Hs7mPubjETbmzXTOTLWuMHsOMBkuqS/gm6LeDrlWqNFSjDTVHOGKyx4ipU77Y
         IrluisHDobCxKjDknDm04x2tc5UyoKwr32FDiBCBp4uaqj50M+s2SJN+9PRIu5OoNiz/
         6ykw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=ZKOkIMzc;
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s3sor6382208pgp.61.2019.05.31.07.22.00
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 31 May 2019 07:22:00 -0700 (PDT)
Received-SPF: pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=ZKOkIMzc;
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=lqGZhr1OXDcqw01dRW7YMwNNKArDZmNdR/78N+BPrn4=;
        b=ZKOkIMzc1OQGbUNPHq03h99fyCedWbnebo6E2bMji4A+DRTaVEdXjsJpjrPcnu5SSA
         zIZPDWUgCW5bi+5Hm5xJN08EHp1zrtJRB8hJr+lkARmCPVryFs490LA/D4jT6SugJib6
         WuyNVM4Q2N7HAjjpa7DOBEdYU4LyBiJDJK5zMqDY/W6JkYNX16roPrVOH81h+nxoiBDb
         7B2l5NwJlc5O9XzC5yHflmTOv3KCBSLqmkKFOBx9Ekz6rnZxWiAE8V0PArN5B+OlAW0s
         TvC0lLDPHMJfSpKtEQaVcV+QmrjEmlTv3Oh20DkNgRQ4hUDHUKfXsDqAzpdAzgsjCOV+
         IttQ==
X-Google-Smtp-Source: APXvYqyJDYvC63I4W5Lhta3XMIDWbZrlVf994VbGlX5pPuRIANXUx7mxbvFt5+YOh/Wqr0oXVm0H7EASqzCT8eMwsG4=
X-Received: by 2002:a65:64d9:: with SMTP id t25mr9532741pgv.130.1559312519598;
 Fri, 31 May 2019 07:21:59 -0700 (PDT)
MIME-Version: 1.0
References: <cover.1557160186.git.andreyknvl@google.com> <e31d9364eb0c2eba8ce246a558422e811d82d21b.1557160186.git.andreyknvl@google.com>
 <20190522141612.GA28122@arrakis.emea.arm.com>
In-Reply-To: <20190522141612.GA28122@arrakis.emea.arm.com>
From: Andrey Konovalov <andreyknvl@google.com>
Date: Fri, 31 May 2019 16:21:48 +0200
Message-ID: <CAAeHK+wUerHQOV2PuaTwTxcCucZHZodLwg48228SB+ymxEqT2A@mail.gmail.com>
Subject: Re: [PATCH v15 17/17] selftests, arm64: add a selftest for passing
 tagged pointers to kernel
To: Catalin Marinas <catalin.marinas@arm.com>, Vincenzo Frascino <vincenzo.frascino@arm.com>
Cc: Linux ARM <linux-arm-kernel@lists.infradead.org>, 
	Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, 
	amd-gfx@lists.freedesktop.org, dri-devel@lists.freedesktop.org, 
	linux-rdma@vger.kernel.org, linux-media@vger.kernel.org, kvm@vger.kernel.org, 
	"open list:KERNEL SELFTEST FRAMEWORK" <linux-kselftest@vger.kernel.org>, Will Deacon <will.deacon@arm.com>, 
	Mark Rutland <mark.rutland@arm.com>, Andrew Morton <akpm@linux-foundation.org>, 
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Kees Cook <keescook@chromium.org>, 
	Yishai Hadas <yishaih@mellanox.com>, Felix Kuehling <Felix.Kuehling@amd.com>, 
	Alexander Deucher <Alexander.Deucher@amd.com>, Christian Koenig <Christian.Koenig@amd.com>, 
	Mauro Carvalho Chehab <mchehab@kernel.org>, Jens Wiklander <jens.wiklander@linaro.org>, 
	Alex Williamson <alex.williamson@redhat.com>, Leon Romanovsky <leon@kernel.org>, 
	Dmitry Vyukov <dvyukov@google.com>, Kostya Serebryany <kcc@google.com>, 
	Evgeniy Stepanov <eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>, 
	Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Jacob Bramley <Jacob.Bramley@arm.com>, 
	Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Robin Murphy <robin.murphy@arm.com>, 
	Luc Van Oostenryck <luc.vanoostenryck@gmail.com>, Dave Martin <Dave.Martin@arm.com>, 
	Kevin Brodsky <kevin.brodsky@arm.com>, Szabolcs Nagy <Szabolcs.Nagy@arm.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, May 22, 2019 at 4:16 PM Catalin Marinas <catalin.marinas@arm.com> wrote:
>
> On Mon, May 06, 2019 at 06:31:03PM +0200, Andrey Konovalov wrote:
> > This patch is a part of a series that extends arm64 kernel ABI to allow to
> > pass tagged user pointers (with the top byte set to something else other
> > than 0x00) as syscall arguments.
> >
> > This patch adds a simple test, that calls the uname syscall with a
> > tagged user pointer as an argument. Without the kernel accepting tagged
> > user pointers the test fails with EFAULT.
>
> That's probably sufficient for a simple example. Something we could add
> to Documentation maybe is a small library that can be LD_PRELOAD'ed so
> that you can run a lot more tests like LTP.

Should I add this into this series, or should this go into Vincenzo's patchset?

>
> We could add this to selftests but I think it's too glibc specific.
>
> --------------------8<------------------------------------
> #include <stdlib.h>
>
> #define TAG_SHIFT       (56)
> #define TAG_MASK        (0xffUL << TAG_SHIFT)
>
> void *__libc_malloc(size_t size);
> void __libc_free(void *ptr);
> void *__libc_realloc(void *ptr, size_t size);
> void *__libc_calloc(size_t nmemb, size_t size);
>
> static void *tag_ptr(void *ptr)
> {
>         unsigned long tag = rand() & 0xff;
>         if (!ptr)
>                 return ptr;
>         return (void *)((unsigned long)ptr | (tag << TAG_SHIFT));
> }
>
> static void *untag_ptr(void *ptr)
> {
>         return (void *)((unsigned long)ptr & ~TAG_MASK);
> }
>
> void *malloc(size_t size)
> {
>         return tag_ptr(__libc_malloc(size));
> }
>
> void free(void *ptr)
> {
>         __libc_free(untag_ptr(ptr));
> }
>
> void *realloc(void *ptr, size_t size)
> {
>         return tag_ptr(__libc_realloc(untag_ptr(ptr), size));
> }
>
> void *calloc(size_t nmemb, size_t size)
> {
>         return tag_ptr(__libc_calloc(nmemb, size));
> }

