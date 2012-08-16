Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx143.postini.com [74.125.245.143])
	by kanga.kvack.org (Postfix) with SMTP id 023DC6B005D
	for <linux-mm@kvack.org>; Thu, 16 Aug 2012 09:47:05 -0400 (EDT)
Received: by yhr47 with SMTP id 47so3584626yhr.14
        for <linux-mm@kvack.org>; Thu, 16 Aug 2012 06:47:05 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <000001392b579d4f-bb5ccaf5-1a2c-472c-9b76-05ec86297706-000000@email.amazonses.com>
References: <1345045084-7292-1-git-send-email-js1304@gmail.com>
	<000001392af5ab4e-41dbbbe4-5808-484b-900a-6f4eba102376-000000@email.amazonses.com>
	<CAAmzW4M9WMnxVKpR00SqufHadY-=i0Jgf8Ktydrw5YXK8VwJ7A@mail.gmail.com>
	<000001392b579d4f-bb5ccaf5-1a2c-472c-9b76-05ec86297706-000000@email.amazonses.com>
Date: Thu, 16 Aug 2012 22:47:04 +0900
Message-ID: <CAAmzW4MMY5TmjMjG50idZNgRUW3qC0kNMnfbGjGXaoxtba8gGQ@mail.gmail.com>
Subject: Re: [PATCH] slub: try to get cpu partial slab even if we get enough
 objects for cpu freelist
From: JoonSoo Kim <js1304@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, David Rientjes <rientjes@google.com>

>> I think that s->cpu_partial is for cpu partial slab, not cpu slab.
>
> Ummm... Not entirely. s->cpu_partial is the mininum number of objects to
> "cache" per processor. This includes the objects available in the per cpu
> slab and the other slabs on the per cpu partial list.

Hmm..
When we do test for unfreezing in put_cpu_partial(), we only compare
how many objects is in "cpu partial slab" with s->cpu_partial,
although it is just approximation of number of objects kept in cpu partial slab.
We do not consider number of objects kept in cpu slab in that time.
This makes me "s->cpu_partial is only for cpu partial slab, not cpu slab".

We can't count number of objects kept in in cpu slab easily.
Therefore, it it more consistent that s->cpu_partial is always for cpu
partial slab.

But, if you prefer that s->cpu_partial is for both cpu slab and cpu
partial slab,
get_partial_node() needs an another minor fix.
We should add number of objects in cpu slab when we refill cpu partial slab.
Following is my suggestion.

@@ -1546,7 +1546,7 @@ static void *get_partial_node(struct kmem_cache *s,
        spin_lock(&n->list_lock);
        list_for_each_entry_safe(page, page2, &n->partial, lru) {
                void *t = acquire_slab(s, n, page, object == NULL);
-               int available;
+               int available, nr = 0;

                if (!t)
                        break;
@@ -1557,10 +1557,10 @@ static void *get_partial_node(struct kmem_cache *s,
                        object = t;
                        available =  page->objects - page->inuse;
                } else {
-                       available = put_cpu_partial(s, page, 0);
+                       nr = put_cpu_partial(s, page, 0);
                        stat(s, CPU_PARTIAL_NODE);
                }
-               if (kmem_cache_debug(s) || available > s->cpu_partial / 2)
+               if (kmem_cache_debug(s) || (available + nr) >
s->cpu_partial / 2)
                        break;

        }

If you agree with this suggestion, I send a patch for this.


> If object == NULL then we have so far nothing allocated an c->page ==
> NULL. The first allocation refills the cpu_slab (by freezing a slab) so
> that we can allocate again. If we go through the loop again then we refill
> the per cpu partial lists with more frozen slabs until we have a
> sufficient number of objects that we can allocate without obtaining any
> locks.
>
>> This patch is for correcting this.
>
> There is nothing wrong with this. The name c->cpu_partial is a bit
> awkward. Maybe rename that to c->min_per_cpu_objects or so?

Okay.
It look better.

Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
