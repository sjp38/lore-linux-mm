Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f176.google.com (mail-qc0-f176.google.com [209.85.216.176])
	by kanga.kvack.org (Postfix) with ESMTP id 35C636B0031
	for <linux-mm@kvack.org>; Wed,  9 Jul 2014 10:29:27 -0400 (EDT)
Received: by mail-qc0-f176.google.com with SMTP id w7so6897547qcr.35
        for <linux-mm@kvack.org>; Wed, 09 Jul 2014 07:29:26 -0700 (PDT)
Received: from qmta15.emeryville.ca.mail.comcast.net (qmta15.emeryville.ca.mail.comcast.net. [2001:558:fe2d:44:76:96:27:228])
        by mx.google.com with ESMTP id i53si47836959qge.31.2014.07.09.07.29.25
        for <linux-mm@kvack.org>;
        Wed, 09 Jul 2014 07:29:26 -0700 (PDT)
Date: Wed, 9 Jul 2014 09:29:22 -0500 (CDT)
From: Christoph Lameter <cl@gentwo.org>
Subject: Re: [RFC/PATCH RESEND -next 11/21] mm: slub: share slab_err and
 object_err functions
In-Reply-To: <1404905415-9046-12-git-send-email-a.ryabinin@samsung.com>
Message-ID: <alpine.DEB.2.11.1407090928530.1384@gentwo.org>
References: <1404905415-9046-1-git-send-email-a.ryabinin@samsung.com> <1404905415-9046-12-git-send-email-a.ryabinin@samsung.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <a.ryabinin@samsung.com>
Cc: linux-kernel@vger.kernel.org, Dmitry Vyukov <dvyukov@google.com>, Konstantin Serebryany <kcc@google.com>, Alexey Preobrazhensky <preobr@google.com>, Andrey Konovalov <adech.fo@gmail.com>, Yuri Gribov <tetra2005@gmail.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Sasha Levin <sasha.levin@oracle.com>, Michal Marek <mmarek@suse.cz>, Russell King <linux@arm.linux.org.uk>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kbuild@vger.kernel.org, linux-arm-kernel@lists.infradead.org, x86@kernel.org, linux-mm@kvack.org

On Wed, 9 Jul 2014, Andrey Ryabinin wrote:

> Remove static and add function declarations to mm/slab.h so they
> could be used by kernel address sanitizer.

Hmmm... This is allocator specific. At some future point it would be good
to move error reporting to slab_common.c and use those from all
allocators.

> Signed-off-by: Andrey Ryabinin <a.ryabinin@samsung.com>
> ---
>  mm/slab.h | 5 +++++
>  mm/slub.c | 4 ++--
>  2 files changed, 7 insertions(+), 2 deletions(-)
>
> diff --git a/mm/slab.h b/mm/slab.h
> index 1257ade..912af7f 100644
> --- a/mm/slab.h
> +++ b/mm/slab.h
> @@ -339,5 +339,10 @@ static inline struct kmem_cache_node *get_node(struct kmem_cache *s, int node)
>
>  void *slab_next(struct seq_file *m, void *p, loff_t *pos);
>  void slab_stop(struct seq_file *m, void *p);
> +void slab_err(struct kmem_cache *s, struct page *page,
> +		const char *fmt, ...);
> +void object_err(struct kmem_cache *s, struct page *page,
> +		u8 *object, char *reason);
> +
>
>  #endif /* MM_SLAB_H */
> diff --git a/mm/slub.c b/mm/slub.c
> index 6641a8f..3bdd9ac 100644
> --- a/mm/slub.c
> +++ b/mm/slub.c
> @@ -635,14 +635,14 @@ static void print_trailer(struct kmem_cache *s, struct page *page, u8 *p)
>  	dump_stack();
>  }
>
> -static void object_err(struct kmem_cache *s, struct page *page,
> +void object_err(struct kmem_cache *s, struct page *page,
>  			u8 *object, char *reason)
>  {
>  	slab_bug(s, "%s", reason);
>  	print_trailer(s, page, object);
>  }
>
> -static void slab_err(struct kmem_cache *s, struct page *page,
> +void slab_err(struct kmem_cache *s, struct page *page,
>  			const char *fmt, ...)
>  {
>  	va_list args;
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
