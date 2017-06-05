Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f198.google.com (mail-ot0-f198.google.com [74.125.82.198])
	by kanga.kvack.org (Postfix) with ESMTP id 5800D6B02C3
	for <linux-mm@kvack.org>; Mon,  5 Jun 2017 18:44:33 -0400 (EDT)
Received: by mail-ot0-f198.google.com with SMTP id 3so4348511otz.1
        for <linux-mm@kvack.org>; Mon, 05 Jun 2017 15:44:33 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id a202si7810880oib.300.2017.06.05.15.44.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Jun 2017 15:44:32 -0700 (PDT)
Received: from mail-ua0-f175.google.com (mail-ua0-f175.google.com [209.85.217.175])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id C2B392397A
	for <linux-mm@kvack.org>; Mon,  5 Jun 2017 22:44:31 +0000 (UTC)
Received: by mail-ua0-f175.google.com with SMTP id u10so84392403uaf.1
        for <linux-mm@kvack.org>; Mon, 05 Jun 2017 15:44:31 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CA+55aFwrCep+F8zV-fK5ufiDRX+N9yTcHMsyR-JhvFeoD-1LYg@mail.gmail.com>
References: <cover.1496701658.git.luto@kernel.org> <a5eb3dead15bcb36732bb5b655ef4ebe23cf4aa3.1496701658.git.luto@kernel.org>
 <CA+55aFwrCep+F8zV-fK5ufiDRX+N9yTcHMsyR-JhvFeoD-1LYg@mail.gmail.com>
From: Andy Lutomirski <luto@kernel.org>
Date: Mon, 5 Jun 2017 15:44:10 -0700
Message-ID: <CALCETrWUWPUKi2zLESbQiFjYK_90-Cts3fYJh4nSact+g7zb_A@mail.gmail.com>
Subject: Re: [RFC 01/11] x86/ldt: Simplify LDT switching logic
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andy Lutomirski <luto@kernel.org>, X86 ML <x86@kernel.org>, Borislav Petkov <bpetkov@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Nadav Amit <nadav.amit@gmail.com>, Rik van Riel <riel@redhat.com>

On Mon, Jun 5, 2017 at 3:40 PM, Linus Torvalds
<torvalds@linux-foundation.org> wrote:
> On Mon, Jun 5, 2017 at 3:36 PM, Andy Lutomirski <luto@kernel.org> wrote:
>> We used to switch the LDT if the prev and next mms' LDTs didn't
>> match.
>
> I think the "LDT didn't match" was really just a simpler and more
> efficient way to say "they weren't both NULL".

Once we go fully lazy (later in this series), though, I'd start
worrying that the optimization would be wrong:

1  Load ldt 0x1234
2. Become lazy
3. LDT changes twice from a remote cpu and the second change reuses
the pointer 0x1234.
4. We go unlazy, prev == next, but LDTR is wrong.

This isn't a bug in current kernels because step 3 will force a leave_mm().

>
> I think you actually broke that optimization, and it now does *two*
> tests instead of just one.

I haven't looked at the generated code, but shouldn't it be just orq; jnz?

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
