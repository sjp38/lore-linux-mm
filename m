From: Christopher Lameter <cl@linux.com>
Subject: Re: [PATCH 1/1] mm/slub.c: add a naive detection of double free or
 corruption
Date: Mon, 17 Jul 2017 11:57:50 -0500 (CDT)
Message-ID: <alpine.DEB.2.20.1707171156390.10415@nuc-kabylake>
References: <1500309907-9357-1-git-send-email-alex.popov@linux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1500309907-9357-1-git-send-email-alex.popov@linux.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Alexander Popov <alex.popov@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com, keescook@chromium.org
List-Id: linux-mm.kvack.org

On Mon, 17 Jul 2017, Alexander Popov wrote:

> Add an assertion similar to "fasttop" check in GNU C Library allocator:
> an object added to a singly linked freelist should not point to itself.
> That helps to detect some double free errors (e.g. CVE-2017-2636) without
> slub_debug and KASAN. Testing with hackbench doesn't show any noticeable
> performance penalty.

We are adding up "unnoticable performance penalties". This is used
int both the critical allocation and free paths. Could this be
VM_BUG_ON()?

>
> Signed-off-by: Alexander Popov <alex.popov@linux.com>
> ---
>  mm/slub.c | 1 +
>  1 file changed, 1 insertion(+)
>
> diff --git a/mm/slub.c b/mm/slub.c
> index 1d3f983..a106939b 100644
> --- a/mm/slub.c
> +++ b/mm/slub.c
> @@ -261,6 +261,7 @@ static inline void *get_freepointer_safe(struct kmem_cache *s, void *object)
>
>  static inline void set_freepointer(struct kmem_cache *s, void *object, void *fp)
>  {
> +	BUG_ON(object == fp); /* naive detection of double free or corruption */
>  	*(void **)(object + s->offset) = fp;
>  }
>
>
