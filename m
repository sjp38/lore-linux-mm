Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f45.google.com (mail-oi0-f45.google.com [209.85.218.45])
	by kanga.kvack.org (Postfix) with ESMTP id DB6AA6B0254
	for <linux-mm@kvack.org>; Mon, 18 Jan 2016 17:24:26 -0500 (EST)
Received: by mail-oi0-f45.google.com with SMTP id w75so151094470oie.0
        for <linux-mm@kvack.org>; Mon, 18 Jan 2016 14:24:26 -0800 (PST)
Received: from mail-ob0-x234.google.com (mail-ob0-x234.google.com. [2607:f8b0:4003:c01::234])
        by mx.google.com with ESMTPS id cm5si28635227oeb.87.2016.01.18.14.24.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Jan 2016 14:24:26 -0800 (PST)
Received: by mail-ob0-x234.google.com with SMTP id py5so204651110obc.2
        for <linux-mm@kvack.org>; Mon, 18 Jan 2016 14:24:25 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1452516679-32040-2-git-send-email-aryabinin@virtuozzo.com>
References: <20160110185916.GD22896@pd.tnic> <1452516679-32040-1-git-send-email-aryabinin@virtuozzo.com>
 <1452516679-32040-2-git-send-email-aryabinin@virtuozzo.com>
From: Andy Lutomirski <luto@amacapital.net>
Date: Mon, 18 Jan 2016 14:24:06 -0800
Message-ID: <CALCETrUJfc10=gGPYruw8MLvAGm+5VKP2bj8ex1Y=oXaMUA6Jg@mail.gmail.com>
Subject: Re: [PATCH 1/2] x86/kasan: clear kasan_zero_page after TLB flush
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Borislav Petkov <bp@alien8.de>, Andy Lutomirski <luto@kernel.org>, X86 ML <x86@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Brian Gerst <brgerst@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, Linus Torvalds <torvalds@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Mon, Jan 11, 2016 at 4:51 AM, Andrey Ryabinin
<aryabinin@virtuozzo.com> wrote:
> Currently we clear kasan_zero_page before __flush_tlb_all(). This
> works with current implementation of native_flush_tlb[_global]()
> because it doesn't cause do any writes to kasan shadow memory.
> But any subtle change made in native_flush_tlb*() could break this.
> Also current code seems doesn't work for paravirt guests (lguest).
>
> Only after the TLB flush we can be sure that kasan_zero_page is not
> used as early shadow anymore (instrumented code will not write to it).
> So it should cleared it only after the TLB flush.

This seems to fix the issue with my patch set.  Thanks.

Tested-by: Andy Lutomirski <luto@kernel.org>

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
