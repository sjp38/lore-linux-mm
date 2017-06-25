Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 3BB106B0292
	for <linux-mm@kvack.org>; Sun, 25 Jun 2017 15:56:23 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id p138so78741756ioe.13
        for <linux-mm@kvack.org>; Sun, 25 Jun 2017 12:56:23 -0700 (PDT)
Received: from mail-it0-x234.google.com (mail-it0-x234.google.com. [2607:f8b0:4001:c0b::234])
        by mx.google.com with ESMTPS id b189si9904748ith.26.2017.06.25.12.56.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 25 Jun 2017 12:56:22 -0700 (PDT)
Received: by mail-it0-x234.google.com with SMTP id m84so14402815ita.0
        for <linux-mm@kvack.org>; Sun, 25 Jun 2017 12:56:22 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170623015010.GA137429@beast>
References: <20170623015010.GA137429@beast>
From: Kees Cook <keescook@chromium.org>
Date: Sun, 25 Jun 2017 12:56:21 -0700
Message-ID: <CAGXu5jJEi_CS-CB=-4369TFRyeN4oQdmGS+HV-zoi4rSPpq3Jw@mail.gmail.com>
Subject: Re: [PATCH v2] mm: Add SLUB free list pointer obfuscation
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Laura Abbott <labbott@redhat.com>, Daniel Micay <danielmicay@gmail.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Josh Triplett <josh@joshtriplett.org>, Andy Lutomirski <luto@kernel.org>, Nicolas Pitre <nicolas.pitre@linaro.org>, Tejun Heo <tj@kernel.org>, Daniel Mack <daniel@zonque.org>, Sebastian Andrzej Siewior <bigeasy@linutronix.de>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Helge Deller <deller@gmx.de>, Rik van Riel <riel@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>

On Thu, Jun 22, 2017 at 6:50 PM, Kees Cook <keescook@chromium.org> wrote:
> This SLUB free list pointer obfuscation code is modified from Brad
> Spengler/PaX Team's code in the last public patch of grsecurity/PaX based
> on my understanding of the code. Changes or omissions from the original
> code are mine and don't reflect the original grsecurity/PaX code.
>
> This adds a per-cache random value to SLUB caches that is XORed with
> their freelist pointers. This adds nearly zero overhead and frustrates the
> very common heap overflow exploitation method of overwriting freelist
> pointers. A recent example of the attack is written up here:
> http://cyseclabs.com/blog/cve-2016-6187-heap-off-by-one-exploit

BTW, to quantify "nearly zero overhead", I ran multiple 200-run cycles
of "hackbench -g 20 -l 1000", and saw:

before:
mean 10.11882499999999999995
variance .03320378329145728642
stdev .18221905304181911048

after:
mean 10.12654000000000000014
variance .04700556623115577889
stdev .21680767106160192064

The difference gets lost in the noise, but if the above is sensible,
it's 0.07% slower. ;)

-Kees

-- 
Kees Cook
Pixel Security

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
