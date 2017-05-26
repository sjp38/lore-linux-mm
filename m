Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id F0CDD6B0279
	for <linux-mm@kvack.org>; Fri, 26 May 2017 12:09:22 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id g143so4301962wme.13
        for <linux-mm@kvack.org>; Fri, 26 May 2017 09:09:22 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y19si1983666edi.175.2017.05.26.09.09.20
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 26 May 2017 09:09:20 -0700 (PDT)
Date: Fri, 26 May 2017 17:09:17 +0100
From: Luis Henriques <lhenriques@suse.com>
Subject: Re: [PATCH v2 2/3] mm: kmemleak: Factor object reference updating
 out of scan_block()
Message-ID: <20170526160916.ptlc2huao3bn4qwq@hermes.olymp>
References: <1495726937-23557-1-git-send-email-catalin.marinas@arm.com>
 <1495726937-23557-3-git-send-email-catalin.marinas@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <1495726937-23557-3-git-send-email-catalin.marinas@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Michal Hocko <mhocko@kernel.org>, Andy Lutomirski <luto@amacapital.net>, "Luis R. Rodriguez" <mcgrof@kernel.org>, Andrew Morton <akpm@linux-foundation.org>

On Thu, May 25, 2017 at 04:42:16PM +0100, Catalin Marinas wrote:
> The scan_block() function updates the number of references (pointers) to
> objects, adding them to the gray_list when object->min_count is reached.
> The patch factors out this functionality into a separate update_refs()
> function.
> 
> Cc: Michal Hocko <mhocko@kernel.org>
> Cc: Andy Lutomirski <luto@amacapital.net>
> Cc: "Luis R. Rodriguez" <mcgrof@kernel.org>
> Signed-off-by: Catalin Marinas <catalin.marinas@arm.com>
> ---
>  mm/kmemleak.c | 43 +++++++++++++++++++++++++------------------
>  1 file changed, 25 insertions(+), 18 deletions(-)
> 
> diff --git a/mm/kmemleak.c b/mm/kmemleak.c
> index 964b12eba2c1..266482f460c2 100644
> --- a/mm/kmemleak.c
> +++ b/mm/kmemleak.c
> @@ -1188,6 +1188,30 @@ static bool update_checksum(struct kmemleak_object *object)
>  }
>  
>  /*
> + * Update an object's references. object->lock must be held by the caller.
> + */
> +static void update_refs(struct kmemleak_object *object)
> +{
> +	if (!color_white(object)) {
> +		/* non-orphan, ignored or new */
> +		return;
> +	}
> +
> +	/*
> +	 * Increase the object's reference count (number of pointers to the
> +	 * memory block). If this count reaches the required minimum, the
> +	 * object's color will become gray and it will be added to the
> +	 * gray_list.
> +	 */
> +	object->count++;
> +	if (color_gray(object)) {
> +		/* put_object() called when removing from gray_list */
> +		WARN_ON(!get_object(object));
> +		list_add_tail(&object->gray_list, &gray_list);
> +	}
> +}
> +
> +/*
>   * Memory scanning is a long process and it needs to be interruptable. This
>   * function checks whether such interrupt condition occurred.
>   */
> @@ -1259,24 +1283,7 @@ static void scan_block(void *_start, void *_end,
>  		 * enclosed by scan_mutex.
>  		 */
>  		spin_lock_nested(&object->lock, SINGLE_DEPTH_NESTING);
> -		if (!color_white(object)) {
> -			/* non-orphan, ignored or new */
> -			spin_unlock(&object->lock);
> -			continue;
> -		}
> -
> -		/*
> -		 * Increase the object's reference count (number of pointers
> -		 * to the memory block). If this count reaches the required
> -		 * minimum, the object's color will become gray and it will be
> -		 * added to the gray_list.
> -		 */
> -		object->count++;
> -		if (color_gray(object)) {
> -			/* put_object() called when removing from gray_list */
> -			WARN_ON(!get_object(object));
> -			list_add_tail(&object->gray_list, &gray_list);
> -		}
> +		update_refs(object);
>  		spin_unlock(&object->lock);

FWIW, I've tested this patchset and I don't see kmemleak triggering the
false positives anymore.

I've also done a quick review and couldn't find anything obviously
incorrect, just a question: why didn't you moved the spin_lock/unlock into
update_refs() too?  It would save you 2 lines in the next patch :)

Cheers,
--
Luis


>  	}
>  	read_unlock_irqrestore(&kmemleak_lock, flags);
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
