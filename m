Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx107.postini.com [74.125.245.107])
	by kanga.kvack.org (Postfix) with SMTP id 092076B006C
	for <linux-mm@kvack.org>; Wed, 15 Aug 2012 13:32:07 -0400 (EDT)
Date: Wed, 15 Aug 2012 17:32:06 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] slub: try to get cpu partial slab even if we get enough
 objects for cpu freelist
In-Reply-To: <CAAmzW4M9WMnxVKpR00SqufHadY-=i0Jgf8Ktydrw5YXK8VwJ7A@mail.gmail.com>
Message-ID: <000001392b579d4f-bb5ccaf5-1a2c-472c-9b76-05ec86297706-000000@email.amazonses.com>
References: <1345045084-7292-1-git-send-email-js1304@gmail.com> <000001392af5ab4e-41dbbbe4-5808-484b-900a-6f4eba102376-000000@email.amazonses.com> <CAAmzW4M9WMnxVKpR00SqufHadY-=i0Jgf8Ktydrw5YXK8VwJ7A@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: JoonSoo Kim <js1304@gmail.com>
Cc: Pekka Enberg <penberg@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, David Rientjes <rientjes@google.com>

On Thu, 16 Aug 2012, JoonSoo Kim wrote:

> > Maybe I do not understand you correctly. Could you explain this in some
> > more detail?
>
> I assume that cpu slab and cpu partial slab are not same thing.
>
> In my definition,
> cpu slab is in c->page,
> cpu partial slab is in c->partial

Correct.

> When we have no free objects in cpu slab and cpu partial slab, we try
> to get slab via get_partial_node().
> In that function, we call acquire_slab(). Then we hit "!object" case
> (for cpu slab).
> In that case, we test available with s->cpu_partial.

> I think that s->cpu_partial is for cpu partial slab, not cpu slab.

Ummm... Not entirely. s->cpu_partial is the mininum number of objects to
"cache" per processor. This includes the objects available in the per cpu
slab and the other slabs on the per cpu partial list.

> So this test is not proper.

Ok so this tests occurs in get_partial_node() not in acquire_slab().

If object == NULL then we have so far nothing allocated an c->page ==
NULL. The first allocation refills the cpu_slab (by freezing a slab) so
that we can allocate again. If we go through the loop again then we refill
the per cpu partial lists with more frozen slabs until we have a
sufficient number of objects that we can allocate without obtaining any
locks.

> This patch is for correcting this.

There is nothing wrong with this. The name c->cpu_partial is a bit
awkward. Maybe rename that to c->min_per_cpu_objects or so?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
