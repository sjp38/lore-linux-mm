Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx192.postini.com [74.125.245.192])
	by kanga.kvack.org (Postfix) with SMTP id AF6F06B006C
	for <linux-mm@kvack.org>; Thu, 16 Aug 2012 13:08:24 -0400 (EDT)
Date: Thu, 16 Aug 2012 17:08:23 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] slub: try to get cpu partial slab even if we get enough
 objects for cpu freelist
In-Reply-To: <CAAmzW4MMY5TmjMjG50idZNgRUW3qC0kNMnfbGjGXaoxtba8gGQ@mail.gmail.com>
Message-ID: <00000139306844c8-bb717c88-ca56-48b3-9b8f-9186053359d3-000000@email.amazonses.com>
References: <1345045084-7292-1-git-send-email-js1304@gmail.com> <000001392af5ab4e-41dbbbe4-5808-484b-900a-6f4eba102376-000000@email.amazonses.com> <CAAmzW4M9WMnxVKpR00SqufHadY-=i0Jgf8Ktydrw5YXK8VwJ7A@mail.gmail.com>
 <000001392b579d4f-bb5ccaf5-1a2c-472c-9b76-05ec86297706-000000@email.amazonses.com> <CAAmzW4MMY5TmjMjG50idZNgRUW3qC0kNMnfbGjGXaoxtba8gGQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: JoonSoo Kim <js1304@gmail.com>
Cc: Pekka Enberg <penberg@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, David Rientjes <rientjes@google.com>

On Thu, 16 Aug 2012, JoonSoo Kim wrote:

> But, if you prefer that s->cpu_partial is for both cpu slab and cpu
> partial slab,
> get_partial_node() needs an another minor fix.
> We should add number of objects in cpu slab when we refill cpu partial slab.
> Following is my suggestion.
>
> @@ -1546,7 +1546,7 @@ static void *get_partial_node(struct kmem_cache *s,
>         spin_lock(&n->list_lock);
>         list_for_each_entry_safe(page, page2, &n->partial, lru) {
>                 void *t = acquire_slab(s, n, page, object == NULL);
> -               int available;
> +               int available, nr = 0;
>
>                 if (!t)
>                         break;
> @@ -1557,10 +1557,10 @@ static void *get_partial_node(struct kmem_cache *s,
>                         object = t;
>                         available =  page->objects - page->inuse;
>                 } else {
> -                       available = put_cpu_partial(s, page, 0);
> +                       nr = put_cpu_partial(s, page, 0);
>                         stat(s, CPU_PARTIAL_NODE);
>                 }
> -               if (kmem_cache_debug(s) || available > s->cpu_partial / 2)
> +               if (kmem_cache_debug(s) || (available + nr) >
> s->cpu_partial / 2)
>                         break;
>
>         }
>
> If you agree with this suggestion, I send a patch for this.

What difference does this patch make? At the end of the day you need the
total number of objects available in the partial slabs and the cpu slab
for comparison.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
