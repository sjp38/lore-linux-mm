Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 6410F6B0253
	for <linux-mm@kvack.org>; Mon,  8 Aug 2016 13:48:47 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id n69so792071532ion.0
        for <linux-mm@kvack.org>; Mon, 08 Aug 2016 10:48:47 -0700 (PDT)
Received: from mail-oi0-x241.google.com (mail-oi0-x241.google.com. [2607:f8b0:4003:c06::241])
        by mx.google.com with ESMTPS id r47si6589521otc.190.2016.08.08.10.48.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 08 Aug 2016 10:48:46 -0700 (PDT)
Received: by mail-oi0-x241.google.com with SMTP id t127so2520053oie.1
        for <linux-mm@kvack.org>; Mon, 08 Aug 2016 10:48:46 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1470417220.13693.55.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1470417220.13693.55.camel@edumazet-glaptop3.roam.corp.google.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Mon, 8 Aug 2016 10:48:45 -0700
Message-ID: <CA+55aFzYnpS-kc+=R0HvTuFquV2qH6cqBXF0-0Q2rSCk=6nUUA@mail.gmail.com>
Subject: Re: [BUG] Bad page states
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric Dumazet <eric.dumazet@gmail.com>, linux-mm <linux-mm@kvack.org>, Vladimir Davydov <vdavydov@virtuozzo.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel <linux-kernel@vger.kernel.org>, Minchan Kim <minchan@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>

Adding more people, and linux-mm.

On Fri, Aug 5, 2016 at 10:13 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>
> Bisected to nowhere :(
>
> Anyone has an idea ?

How easy is it for you to reproduce? It must be *fairly* easy since
you tried bisecting it, and presumably all the ones you marked "bad"
really are reliably bad.

Which means that I would expect that since the bisect failed, some of
the "good" ones (particularly at the end) might really be bad, just
didn't have the time/load to reproduce.

So maybe you could re-test the good ones for a bit longer? Trust all
the ones you've marked bad (and presumably trust v4.7 itself as good),
and re-try the bisection.

That said, it looks pretty bleak. If you don't trust any of the good
ones, you'd start out with

  git bisect start
  git bisect bad 5bbea66bf8d9ba898abbe5499f06998a993364f6
  git bisect good v4.7

and that's still almost 6000 commits.

So let's narrow it down by looking at the details:

> [   32.666450] BUG: Bad page state in process swapper/0  pfn:1fd945c
> [   32.672542] page:ffffea007f651700 count:0 mapcount:-511 mapping:          (null) index:0x0
> [   32.680823] flags: 0x1000000000000000()
> [   32.684655] page dumped because: nonzero mapcount
> ...
> [   43.477693] BUG: Bad page state in process S05containers  pfn:1ff02a3
> [   43.484417] page:ffffea007fc0a8c0 count:0 mapcount:-511 mapping:          (null) index:0x0
> [   43.492737] flags: 0x1000000000000000()
> [   43.496602] page dumped because: nonzero mapcount

Hmm. The _mapcount field is a union with other fields, but that number
doesn't make sense for any of the other fields.

So it's almost certainly related to "PAGE_KMEMCG_MAPCOUNT_VALUE". So
something presumably mapped such a page into an address space, and
incremented the number. That should never have happened, of course.

Oh. Actually, I guess it *is* PAGE_KMEMCG_MAPCOUNT_VALUE, and what
happens is that __page_mapcount() returns "_mapcount+1", so no other
increment needed.

The fact that one of the trces comes from tlb_flush_mmu_free() still
does mean that it has been mapped into a VM, though.

Unrelated to that, the "flags" field has bit 60 set, which is
presumably just part of the zone/node/section number. Maybe the
page_debug() code should print out that information too, not just the
flag bit names?

Anyway, the PAGE_KMEMCG_MAPCOUNT_VALUE connection makes me blame
Vladimir Davydov and commit 4949148ad433. Maybe you could center your
testing around that one (ie rather than bisection, try the immediate
parent, and then that commit).

And maybe the page mapping code could have some debug code for "am I
mapping a page that has a mapcount < -1", and alert people to that? To
more easily find the path that triggers this?

Vladimir?

                      Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
