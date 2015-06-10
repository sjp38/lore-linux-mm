Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f172.google.com (mail-ie0-f172.google.com [209.85.223.172])
	by kanga.kvack.org (Postfix) with ESMTP id BA2E76B006C
	for <linux-mm@kvack.org>; Wed, 10 Jun 2015 12:42:35 -0400 (EDT)
Received: by iesa3 with SMTP id a3so38352981ies.2
        for <linux-mm@kvack.org>; Wed, 10 Jun 2015 09:42:35 -0700 (PDT)
Received: from mail-ig0-x22f.google.com (mail-ig0-x22f.google.com. [2607:f8b0:4001:c05::22f])
        by mx.google.com with ESMTPS id b1si9381847ico.3.2015.06.10.09.42.35
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 Jun 2015 09:42:35 -0700 (PDT)
Received: by igbpi8 with SMTP id pi8so40008731igb.1
        for <linux-mm@kvack.org>; Wed, 10 Jun 2015 09:42:35 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CA+55aFwVUkdaf0_rBk7uJHQjWXu+OcLTHc6FKuCn0Cb2Kvg9NA@mail.gmail.com>
References: <1433767854-24408-1-git-send-email-mgorman@suse.de>
	<20150608174551.GA27558@gmail.com>
	<20150609084739.GQ26425@suse.de>
	<20150609103231.GA11026@gmail.com>
	<20150609112055.GS26425@suse.de>
	<20150609124328.GA23066@gmail.com>
	<5577078B.2000503@intel.com>
	<55771909.2020005@intel.com>
	<55775749.3090004@intel.com>
	<CA+55aFz6b5pG9tRNazk8ynTCXS3whzWJ_737dt1xxAHDf1jASQ@mail.gmail.com>
	<20150610131354.GO19417@two.firstfloor.org>
	<CA+55aFwVUkdaf0_rBk7uJHQjWXu+OcLTHc6FKuCn0Cb2Kvg9NA@mail.gmail.com>
Date: Wed, 10 Jun 2015 09:42:34 -0700
Message-ID: <CA+55aFxhfkBDqVo+-rRHgkA4os7GkApvjNXW5SWXH03MW8Vw5A@mail.gmail.com>
Subject: Re: [PATCH 0/3] TLB flush multiple pages per IPI v5
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: Dave Hansen <dave.hansen@intel.com>, Ingo Molnar <mingo@kernel.org>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, H Peter Anvin <hpa@zytor.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Thomas Gleixner <tglx@linutronix.de>

On Wed, Jun 10, 2015 at 9:17 AM, Linus Torvalds
<torvalds@linux-foundation.org> wrote:
>
> So anyway, I like the patch series. I just think that the final patch
> - the one that actually saves the addreses, and limits things to
> BATCH_TLBFLUSH_SIZE, should be limited.

Oh, and another thing:

Mel, can you please make that "struct tlbflush_unmap_batch" be just
part of "struct task_struct" rather than a pointer?

If you are worried about the cpumask size, you could use

      cpumask_var_t cpumask;

and

        alloc_cpumask_var(..)
...
        free_cpumask_var(..)

for that.

That way, sane configurations never have the allocation cost.

(Of course, sad to say, sane configurations are probably few and far
between. At least Fedora seems to ship with a kernel where NR_CPU's is
1024 and thus CONFIG_CPUMASK_OFFSTACK=y. Oh well. What a waste of CPU
cycles that is..)

                  Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
