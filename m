Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f54.google.com (mail-la0-f54.google.com [209.85.215.54])
	by kanga.kvack.org (Postfix) with ESMTP id 4FF349003C7
	for <linux-mm@kvack.org>; Mon, 20 Jul 2015 15:30:09 -0400 (EDT)
Received: by laem6 with SMTP id m6so103350191lae.0
        for <linux-mm@kvack.org>; Mon, 20 Jul 2015 12:30:08 -0700 (PDT)
Received: from plane.gmane.org (plane.gmane.org. [80.91.229.3])
        by mx.google.com with ESMTPS id n5si18706182laf.168.2015.07.20.12.30.06
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 20 Jul 2015 12:30:07 -0700 (PDT)
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <glkm-linux-mm-2@m.gmane.org>)
	id 1ZHGlI-0007uy-58
	for linux-mm@kvack.org; Mon, 20 Jul 2015 21:30:04 +0200
Received: from sp4.qualcomm.com ([199.106.103.54])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-mm@kvack.org>; Mon, 20 Jul 2015 21:30:04 +0200
Received: from pdaly by sp4.qualcomm.com with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-mm@kvack.org>; Mon, 20 Jul 2015 21:30:04 +0200
From: Patrick Daly <pdaly@codeaurora.org>
Subject: Re: [PATCH v2 5/5] arm64: add KASan support
Date: Sat, 18 Jul 2015 02:44:41 +0000 (UTC)
Message-ID: <loom.20150718T043633-109@post.gmane.org>
References: <1431698344-28054-1-git-send-email-a.ryabinin@samsung.com> <1431698344-28054-6-git-send-email-a.ryabinin@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

Andrey Ryabinin <a.ryabinin <at> samsung.com> writes:

> +#if defined(CONFIG_KASAN) && !defined(__SANITIZE_ADDRESS__)
> +
> +/*
> + * For files that not instrumented (e.g. mm/slub.c) we
> + * should use not instrumented version of mem* functions.
> + */
> +
> +#define memcpy(dst, src, len) __memcpy(dst, src, len)
> +#define memmove(dst, src, len) __memmove(dst, src, len)
> +#define memset(s, c, n) __memset(s, c, n)
> +#endif


In arch/arm64/kernel/arm64ksyms.c, the memcpy, memmove, and memset functions
are exported via EXPORT_SYMBOL().
In this patch you add __memcpy etc, which will be used directly by modules
if the above #if condition is met.
I believe that EXPORT_SYMBOL() is necessary for __memcpy etc as well.

One test for this would be compiling test_kasan.c as a module with
KASAN_SANITIZE_test_kasan.o := n
CONFIG_KASAN = y

Patrick Daly

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
