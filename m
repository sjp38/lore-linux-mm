From: Christopher Lameter <cl@linux.com>
Subject: Re: [PATCH v3 02/31] usercopy: Enforce slab cache usercopy region
 boundaries
Date: Thu, 21 Sep 2017 10:23:45 -0500 (CDT)
Message-ID: <alpine.DEB.2.20.1709211022550.14427@nuc-kabylake>
References: <1505940337-79069-1-git-send-email-keescook@chromium.org> <1505940337-79069-3-git-send-email-keescook@chromium.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1505940337-79069-3-git-send-email-keescook@chromium.org>
Sender: linux-kernel-owner@vger.kernel.org
To: Kees Cook <keescook@chromium.org>
Cc: linux-kernel@vger.kernel.org, David Windsor <dave@nullcore.net>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Laura Abbott <labbott@redhat.com>, Ingo Molnar <mingo@kernel.org>, Mark Rutland <mark.rutland@arm.com>, linux-mm@kvack.org, linux-xfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, netdev@vger.kernel.org, kernel-hardening@lists.openwall.com
List-Id: linux-mm.kvack.org

On Wed, 20 Sep 2017, Kees Cook wrote:

> diff --git a/mm/slab.c b/mm/slab.c
> index 87b6e5e0cdaf..df268999cf02 100644
> --- a/mm/slab.c
> +++ b/mm/slab.c
> @@ -4408,7 +4408,9 @@ module_init(slab_proc_init);
>
>  #ifdef CONFIG_HARDENED_USERCOPY
>  /*
> - * Rejects objects that are incorrectly sized.
> + * Rejects incorrectly sized objects and objects that are to be copied
> + * to/from userspace but do not fall entirely within the containing slab
> + * cache's usercopy region.
>   *
>   * Returns NULL if check passes, otherwise const char * to name of cache
>   * to indicate an error.
> @@ -4428,11 +4430,15 @@ const char *__check_heap_object(const void *ptr, unsigned long n,
>  	/* Find offset within object. */
>  	offset = ptr - index_to_obj(cachep, page, objnr) - obj_offset(cachep);
>
> -	/* Allow address range falling entirely within object size. */
> -	if (offset <= cachep->object_size && n <= cachep->object_size - offset)
> -		return NULL;
> +	/* Make sure object falls entirely within cache's usercopy region. */
> +	if (offset < cachep->useroffset)
> +		return cachep->name;
> +	if (offset - cachep->useroffset > cachep->usersize)
> +		return cachep->name;
> +	if (n > cachep->useroffset - offset + cachep->usersize)
> +		return cachep->name;
>
> -	return cachep->name;
> +	return NULL;
>  }
>  #endif /* CONFIG_HARDENED_USERCOPY */

Looks like this is almost the same for all allocators. Can we put this
into mm/slab_common.c?
