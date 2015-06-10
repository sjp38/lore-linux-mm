Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f175.google.com (mail-ig0-f175.google.com [209.85.213.175])
	by kanga.kvack.org (Postfix) with ESMTP id 716BD6B0032
	for <linux-mm@kvack.org>; Wed, 10 Jun 2015 13:31:02 -0400 (EDT)
Received: by igblz2 with SMTP id lz2so38773872igb.1
        for <linux-mm@kvack.org>; Wed, 10 Jun 2015 10:31:02 -0700 (PDT)
Received: from mail-ie0-x231.google.com (mail-ie0-x231.google.com. [2607:f8b0:4001:c03::231])
        by mx.google.com with ESMTPS id cy5si4379799igc.53.2015.06.10.10.31.01
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 Jun 2015 10:31:01 -0700 (PDT)
Received: by iebgx4 with SMTP id gx4so39237984ieb.0
        for <linux-mm@kvack.org>; Wed, 10 Jun 2015 10:31:01 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150610172457.GH26425@suse.de>
References: <20150609103231.GA11026@gmail.com>
	<20150609112055.GS26425@suse.de>
	<20150609124328.GA23066@gmail.com>
	<5577078B.2000503@intel.com>
	<55771909.2020005@intel.com>
	<55775749.3090004@intel.com>
	<CA+55aFz6b5pG9tRNazk8ynTCXS3whzWJ_737dt1xxAHDf1jASQ@mail.gmail.com>
	<20150610131354.GO19417@two.firstfloor.org>
	<CA+55aFwVUkdaf0_rBk7uJHQjWXu+OcLTHc6FKuCn0Cb2Kvg9NA@mail.gmail.com>
	<CA+55aFxhfkBDqVo+-rRHgkA4os7GkApvjNXW5SWXH03MW8Vw5A@mail.gmail.com>
	<20150610172457.GH26425@suse.de>
Date: Wed, 10 Jun 2015 10:31:01 -0700
Message-ID: <CA+55aFzw-Yn6vOB1BvdoxH3tid14=uS1u3bgFWdtbAuO4r-zCQ@mail.gmail.com>
Subject: Re: [PATCH 0/3] TLB flush multiple pages per IPI v5
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andi Kleen <andi@firstfloor.org>, Dave Hansen <dave.hansen@intel.com>, Ingo Molnar <mingo@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, H Peter Anvin <hpa@zytor.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Thomas Gleixner <tglx@linutronix.de>

On Wed, Jun 10, 2015 at 10:24 AM, Mel Gorman <mgorman@suse.de> wrote:
>
> Yes, that was done earlier today based on Ingo's review so that the
> allocation could be dealt with as a separate path at the end of the series.

Ahh, ok, never mind then.

> Ok, good point.  Patch 3 in my git tree ("mm: Dynamically allocate TLB
> batch unmap control structure") does not do this but I'll look into doing
> it before the release based on 4.2-rc1.

I'm not sure how size-sensitive this is. The 'struct task_struct' is
pretty big already, and if somebody builds a MAXSMP kernel, I really
don't think they worry too much about wasting a few bytes for each
process. Clearly they either are insane, or they actually *have* a big
machine, in which point the allocation is not going to be wasteful and
they'll likely trigger this code all the time anyway, so trying to be
any more dynamic about it is probably not worth it.

So my "maybe you could use 'cpumask_var_t' here" suggestion isn't
necessarily even worth it. Just statically allocating it is probably
perfectly fine.

Of course, again the counter-example for that may well be how distros
seem to make thousand-cpu configurations the default. That does seem
insane to me. But I guess the pain of multiple kernel configs is just
too much.

                Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
