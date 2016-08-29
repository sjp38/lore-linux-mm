Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 2907C83102
	for <linux-mm@kvack.org>; Mon, 29 Aug 2016 13:28:21 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id c189so239064217oia.0
        for <linux-mm@kvack.org>; Mon, 29 Aug 2016 10:28:21 -0700 (PDT)
Received: from mail-oi0-x233.google.com (mail-oi0-x233.google.com. [2607:f8b0:4003:c06::233])
        by mx.google.com with ESMTPS id v16si25092556otd.195.2016.08.29.10.28.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Aug 2016 10:28:11 -0700 (PDT)
Received: by mail-oi0-x233.google.com with SMTP id f189so205591666oig.3
        for <linux-mm@kvack.org>; Mon, 29 Aug 2016 10:28:11 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20160829145203.GA30660@aepfle.de>
References: <20160822093249.GA14916@dhcp22.suse.cz> <20160822093707.GG13596@dhcp22.suse.cz>
 <20160822100528.GB11890@kroah.com> <20160822105441.GH13596@dhcp22.suse.cz>
 <20160822133114.GA15302@kroah.com> <20160822134227.GM13596@dhcp22.suse.cz>
 <20160822150517.62dc7cce74f1af6c1f204549@linux-foundation.org>
 <20160823074339.GB23577@dhcp22.suse.cz> <20160825071103.GC4230@dhcp22.suse.cz>
 <20160825071728.GA3169@aepfle.de> <20160829145203.GA30660@aepfle.de>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Mon, 29 Aug 2016 10:28:10 -0700
Message-ID: <CA+55aFxbBszp+O9=9MrwXxp_fNw6xzNjQ0Kktm-8ipgqbido8w@mail.gmail.com>
Subject: Re: OOM detection regressions since 4.7
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Olaf Hering <olaf@aepfle.de>, Bruce Fields <bfields@fieldses.org>, Jeff Layton <jlayton@poochiereds.net>
Cc: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Markus Trippelsdorf <markus@trippelsdorf.de>, Arkadiusz Miskiewicz <a.miskiewicz@gmail.com>, Ralf-Peter Rohbeck <Ralf-Peter.Rohbeck@quantum.com>, Jiri Slaby <jslaby@suse.com>, Greg KH <gregkh@linuxfoundation.org>, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <js1304@gmail.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Linux NFS Mailing List <linux-nfs@vger.kernel.org>

On Mon, Aug 29, 2016 at 7:52 AM, Olaf Hering <olaf@aepfle.de> wrote:
>
> Today I noticed the nfsserver was disabled, probably since months already.
> Starting it gives a OOM, not sure if this is new with 4.7+.

That's not an oom, that's just an allocation failure.

And with order-4, that's actually pretty normal. Nobody should use
order-4 (that's 16 contiguous pages, fragmentation can easily make
that hard - *much* harder than the small order-2 or order-2 cases that
we should largely be able to rely on).

In fact, people who do multi-order allocations should always have a
fallback, and use __GFP_NOWARN.

> [93348.306406] Call Trace:
> [93348.306490]  [<ffffffff81198cef>] __alloc_pages_slowpath+0x1af/0xa10
> [93348.306501]  [<ffffffff811997a0>] __alloc_pages_nodemask+0x250/0x290
> [93348.306511]  [<ffffffff811f1c3d>] cache_grow_begin+0x8d/0x540
> [93348.306520]  [<ffffffff811f23d1>] fallback_alloc+0x161/0x200
> [93348.306530]  [<ffffffff811f43f2>] __kmalloc+0x1d2/0x570
> [93348.306589]  [<ffffffffa08f025a>] nfsd_reply_cache_init+0xaa/0x110 [nfsd]

Hmm. That's kmalloc itself falling back after already failing to grow
the slab cache earlier (the earlier allocations *were* done with
NOWARN afaik).

It does look like nfsdstarts out by allocating the hash table with one
single fairly big allocation, and has no fallback position.

I suspect the code expects to be started at boot time, when this just
isn't an issue. The fact that you loaded the nfsd kernel module with
memory already fragmented after heavy use is likely why nobody else
has seen this.

Adding the nfsd people to the cc, because just from a robustness
standpoint I suspect it would be better if the code did something like

 (a) shrink the hash table if the allocation fails (we've got some
examples of that elsewhere)

or

 (b) fall back on a vmalloc allocation (that's certainly the simpler model)

We do have a "kvfree()" helper function for the "free either a kmalloc
or vmalloc allocation" but we don't actually have a good helper
pattern for the allocation side. People just do it by hand, at least
partly because we have so many different ways to allocate things -
zeroing, non-zeroing, node-specific or not, atomic or not (atomic
cannot fall back to vmalloc, obviously) etc etc.

Bruce, Jeff, comments?

             Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
