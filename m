Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id B262A6B039F
	for <linux-mm@kvack.org>; Fri, 31 Mar 2017 17:33:19 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id t68so30693835iof.16
        for <linux-mm@kvack.org>; Fri, 31 Mar 2017 14:33:19 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id l186si3912126ite.74.2017.03.31.14.33.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 31 Mar 2017 14:33:18 -0700 (PDT)
Date: Fri, 31 Mar 2017 14:33:17 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: Add additional consistency check
Message-Id: <20170331143317.3865149a6b6112f0d1a63499@linux-foundation.org>
In-Reply-To: <20170331164028.GA118828@beast>
References: <20170331164028.GA118828@beast>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, 31 Mar 2017 09:40:28 -0700 Kees Cook <keescook@chromium.org> wrote:

> As found in PaX, this adds a cheap check on heap consistency, just to
> notice if things have gotten corrupted in the page lookup.

"As found in PaX" isn't a very illuminating justification for such a
change.  Was there a real kernel bug which this would have exposed, or
what?

> --- a/mm/slab.h
> +++ b/mm/slab.h
> @@ -384,6 +384,7 @@ static inline struct kmem_cache *cache_from_obj(struct kmem_cache *s, void *x)
>  		return s;
>  
>  	page = virt_to_head_page(x);
> +	BUG_ON(!PageSlab(page));
>  	cachep = page->slab_cache;
>  	if (slab_equal_or_root(cachep, s))
>  		return cachep;

BUG_ON might be too severe.  I expect the kindest VM_WARN_ON_ONCE()
would suffice here, but without more details it is hard to say.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
