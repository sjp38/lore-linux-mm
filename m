Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f174.google.com (mail-ig0-f174.google.com [209.85.213.174])
	by kanga.kvack.org (Postfix) with ESMTP id A32966B0069
	for <linux-mm@kvack.org>; Wed,  5 Nov 2014 16:48:45 -0500 (EST)
Received: by mail-ig0-f174.google.com with SMTP id hn18so9610290igb.7
        for <linux-mm@kvack.org>; Wed, 05 Nov 2014 13:48:45 -0800 (PST)
Received: from mail-ie0-x230.google.com (mail-ie0-x230.google.com. [2607:f8b0:4001:c03::230])
        by mx.google.com with ESMTPS id p21si7004538ioi.36.2014.11.05.13.48.44
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 05 Nov 2014 13:48:44 -0800 (PST)
Received: by mail-ie0-f176.google.com with SMTP id rd18so1625254iec.7
        for <linux-mm@kvack.org>; Wed, 05 Nov 2014 13:48:44 -0800 (PST)
Date: Wed, 5 Nov 2014 13:48:42 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm: slub: fix format mismatches in slab_err() callers
In-Reply-To: <1415200341-9619-1-git-send-email-a.ryabinin@samsung.com>
Message-ID: <alpine.DEB.2.10.1411051344490.31575@chino.kir.corp.google.com>
References: <1415200341-9619-1-git-send-email-a.ryabinin@samsung.com>
MIME-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="531381512-382633830-1415224123=:31575"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <a.ryabinin@samsung.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--531381512-382633830-1415224123=:31575
Content-Type: TEXT/PLAIN; charset=UTF-8
Content-Transfer-Encoding: 8BIT

On Wed, 5 Nov 2014, Andrey Ryabinin wrote:

> Adding __printf(3, 4) to slab_err exposed following:
> 
> mm/slub.c: In function a??check_slaba??:
> mm/slub.c:852:4: warning: format a??%ua?? expects argument of type a??unsigned inta??, but argument 4 has type a??const char *a?? [-Wformat=]
>     s->name, page->objects, maxobj);
>     ^
> mm/slub.c:852:4: warning: too many arguments for format [-Wformat-extra-args]
> mm/slub.c:857:4: warning: format a??%ua?? expects argument of type a??unsigned inta??, but argument 4 has type a??const char *a?? [-Wformat=]
>     s->name, page->inuse, page->objects);
>     ^
> mm/slub.c:857:4: warning: too many arguments for format [-Wformat-extra-args]
> 

Wow, that's an ancient issue, thanks for finding it.

> mm/slub.c: In function a??on_freelista??:
> mm/slub.c:905:4: warning: format a??%da?? expects argument of type a??inta??, but argument 5 has type a??long unsigned inta?? [-Wformat=]
>     "should be %d", page->objects, max_objects);
> 
> Signed-off-by: Andrey Ryabinin <a.ryabinin@samsung.com>
> Cc: Christoph Lameter <cl@linux.com>
> Cc: Pekka Enberg <penberg@kernel.org>
> Cc: David Rientjes <rientjes@google.com>
> Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> ---
>  mm/slub.c | 6 +++---
>  1 file changed, 3 insertions(+), 3 deletions(-)
> 
> diff --git a/mm/slub.c b/mm/slub.c
> index 80c170e..850a94a 100644
> --- a/mm/slub.c
> +++ b/mm/slub.c
> @@ -849,12 +849,12 @@ static int check_slab(struct kmem_cache *s, struct page *page)
>  	maxobj = order_objects(compound_order(page), s->size, s->reserved);
>  	if (page->objects > maxobj) {
>  		slab_err(s, page, "objects %u > max %u",
> -			s->name, page->objects, maxobj);
> +			page->objects, maxobj);
>  		return 0;
>  	}
>  	if (page->inuse > page->objects) {
>  		slab_err(s, page, "inuse %u > max %u",
> -			s->name, page->inuse, page->objects);
> +			page->inuse, page->objects);
>  		return 0;
>  	}
>  	/* Slab_pad_check fixes things up after itself */
> @@ -902,7 +902,7 @@ static int on_freelist(struct kmem_cache *s, struct page *page, void *search)
>  
>  	if (page->objects != max_objects) {
>  		slab_err(s, page, "Wrong number of objects. Found %d but "
> -			"should be %d", page->objects, max_objects);
> +			"should be %ld", page->objects, max_objects);
>  		page->objects = max_objects;
>  		slab_fix(s, "Number of objects adjusted.");
>  	}

Instead of this hunk, I think that max_objects should be declared as int 
rather than unsigned long since that's what order_objects() returns and it 
is being compared to page->objects which is also int.
--531381512-382633830-1415224123=:31575--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
