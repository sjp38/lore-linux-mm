Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f175.google.com (mail-ie0-f175.google.com [209.85.223.175])
	by kanga.kvack.org (Postfix) with ESMTP id 4FE4A6B006C
	for <linux-mm@kvack.org>; Wed, 10 Jun 2015 14:08:15 -0400 (EDT)
Received: by iebmu5 with SMTP id mu5so39899607ieb.1
        for <linux-mm@kvack.org>; Wed, 10 Jun 2015 11:08:15 -0700 (PDT)
Received: from mail-ig0-x231.google.com (mail-ig0-x231.google.com. [2607:f8b0:4001:c05::231])
        by mx.google.com with ESMTPS id e7si4451277igl.62.2015.06.10.11.08.14
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 Jun 2015 11:08:14 -0700 (PDT)
Received: by igbpi8 with SMTP id pi8so41495185igb.0
        for <linux-mm@kvack.org>; Wed, 10 Jun 2015 11:08:14 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CA+55aFxhfkBDqVo+-rRHgkA4os7GkApvjNXW5SWXH03MW8Vw5A@mail.gmail.com>
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
	<CA+55aFxhfkBDqVo+-rRHgkA4os7GkApvjNXW5SWXH03MW8Vw5A@mail.gmail.com>
Date: Wed, 10 Jun 2015 14:08:14 -0400
Message-ID: <CA+5PVA6Vf9kSiswfnnR-OL-RtRPS=ZXttMyPe8Kur=tXKBeqQg@mail.gmail.com>
Subject: Re: [PATCH 0/3] TLB flush multiple pages per IPI v5
From: Josh Boyer <jwboyer@fedoraproject.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andi Kleen <andi@firstfloor.org>, Dave Hansen <dave.hansen@intel.com>, Ingo Molnar <mingo@kernel.org>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, H Peter Anvin <hpa@zytor.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Thomas Gleixner <tglx@linutronix.de>

On Wed, Jun 10, 2015 at 12:42 PM, Linus Torvalds
<torvalds@linux-foundation.org> wrote:
> On Wed, Jun 10, 2015 at 9:17 AM, Linus Torvalds
> <torvalds@linux-foundation.org> wrote:
>>
>> So anyway, I like the patch series. I just think that the final patch
>> - the one that actually saves the addreses, and limits things to
>> BATCH_TLBFLUSH_SIZE, should be limited.
>
> Oh, and another thing:
>
> Mel, can you please make that "struct tlbflush_unmap_batch" be just
> part of "struct task_struct" rather than a pointer?
>
> If you are worried about the cpumask size, you could use
>
>       cpumask_var_t cpumask;
>
> and
>
>         alloc_cpumask_var(..)
> ...
>         free_cpumask_var(..)
>
> for that.
>
> That way, sane configurations never have the allocation cost.
>
> (Of course, sad to say, sane configurations are probably few and far
> between. At least Fedora seems to ship with a kernel where NR_CPU's is
> 1024 and thus CONFIG_CPUMASK_OFFSTACK=y. Oh well. What a waste of CPU
> cycles that is..)

The insane part being NR_CPUS = 1024?  Or that to have said number
requires cpumask being dynamically allocated to avoid stack overflow?
(Or both I guess).

josh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
