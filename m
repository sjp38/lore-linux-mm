Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f199.google.com (mail-ot0-f199.google.com [74.125.82.199])
	by kanga.kvack.org (Postfix) with ESMTP id 133E46B0279
	for <linux-mm@kvack.org>; Thu, 22 Jun 2017 01:19:54 -0400 (EDT)
Received: by mail-ot0-f199.google.com with SMTP id 37so4385797otu.13
        for <linux-mm@kvack.org>; Wed, 21 Jun 2017 22:19:54 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id u4si171190otf.87.2017.06.21.22.19.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Jun 2017 22:19:53 -0700 (PDT)
Received: from mail-ua0-f182.google.com (mail-ua0-f182.google.com [209.85.217.182])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 6F18822B67
	for <linux-mm@kvack.org>; Thu, 22 Jun 2017 05:19:52 +0000 (UTC)
Received: by mail-ua0-f182.google.com with SMTP id z22so5722570uah.1
        for <linux-mm@kvack.org>; Wed, 21 Jun 2017 22:19:52 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CA+55aFy14-DjPqiNhYBug_kK7zWAfvkRS9E5v5vuCgO+OBAJrg@mail.gmail.com>
References: <cover.1498022414.git.luto@kernel.org> <CA+55aFy14-DjPqiNhYBug_kK7zWAfvkRS9E5v5vuCgO+OBAJrg@mail.gmail.com>
From: Andy Lutomirski <luto@kernel.org>
Date: Wed, 21 Jun 2017 22:19:30 -0700
Message-ID: <CALCETrVrkBBYA+z6ecm6CuOGszsi=WyX6K1oVBCX6age9LUTrQ@mail.gmail.com>
Subject: Re: [PATCH v3 00/11] PCID and improved laziness
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andy Lutomirski <luto@kernel.org>, the arch/x86 maintainers <x86@kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Borislav Petkov <bp@alien8.de>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Nadav Amit <nadav.amit@gmail.com>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Arjan van de Ven <arjan@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>

On Wed, Jun 21, 2017 at 11:23 AM, Linus Torvalds
<torvalds@linux-foundation.org> wrote:
> On Tue, Jun 20, 2017 at 10:22 PM, Andy Lutomirski <luto@kernel.org> wrote:
>> There are three performance benefits here:
>
> Side note: can you post the actual performance numbers, even if only
> from some silly test program on just one platform? Things like lmbench
> pipe benchmark or something?
>
> Or maybe you did, and I just missed it. But when talking about
> performance, I'd really like to always see some actual numbers.

Here are some timings using KVM:

pingpong between two processes using eventfd:
patched: 883ns
unpatched: 1046ns (with considerably higher variance)

madvise(MADV_DONTNEED); write to the page; switch CPUs:
patched: ~12.5us
unpatched: 19us

The latter test is a somewhat contrived example to show off the
improved laziness.  Current kernels send an IPI on each iteration if
the system is otherwise idle.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
