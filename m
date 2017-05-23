Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id B8AE46B0279
	for <linux-mm@kvack.org>; Tue, 23 May 2017 16:37:02 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id 139so32915824wmf.5
        for <linux-mm@kvack.org>; Tue, 23 May 2017 13:37:02 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d15si19223608edb.202.2017.05.23.13.37.01
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 23 May 2017 13:37:01 -0700 (PDT)
Date: Tue, 23 May 2017 22:37:00 +0200
From: "Luis R. Rodriguez" <mcgrof@kernel.org>
Subject: Re: [PATCH] mm: kmemleak: Treat vm_struct as alternative reference
 to vmalloc'ed objects
Message-ID: <20170523203700.GW8951@wotan.suse.de>
References: <1495474514-24425-1-git-send-email-catalin.marinas@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1495474514-24425-1-git-send-email-catalin.marinas@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Michal Hocko <mhocko@kernel.org>, Andy Lutomirski <luto@amacapital.net>, "Luis R. Rodriguez" <mcgrof@kernel.org>

On Mon, May 22, 2017 at 06:35:14PM +0100, Catalin Marinas wrote:
> Kmemleak requires that vmalloc'ed objects have a minimum reference count
> of 2: one in the corresponding vm_struct object and the other owned by
> the vmalloc() caller. There are cases, however, where the original
> vmalloc() returned pointer is lost and, instead, a pointer to vm_struct
> is stored (see free_thread_stack()). Kmemleak currently reports such
> objects as leaks.
> 
> This patch adds support for treating any surplus references to an object
> as additional references to a specified object. It introduces the
> kmemleak_vmalloc() API function which takes a vm_struct pointer and sets
> its surplus reference passing to the actual vmalloc() returned pointer.
> The __vmalloc_node_range() calling site has been modified accordingly.
> 
> An unrelated minor change is included in this patch to change the type
> of kmemleak_object.flags to unsigned int (previously unsigned long).
> 
> Reported-by: "Luis R. Rodriguez" <mcgrof@kernel.org>

Tested-by: Luis R. Rodriguez <mcgrof@kernel.org>

> diff --git a/mm/kmemleak.c b/mm/kmemleak.c
> index 20036d4f9f13..11ab654502fd 100644
> --- a/mm/kmemleak.c
> +++ b/mm/kmemleak.c
> @@ -1188,6 +1249,30 @@ static bool update_checksum(struct kmemleak_object *object)
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

This an initial use of it seems to be very possible and likely without the
vmalloc special case, ie, can this be added as a separate patch to make the
actual functional change easier to read ?

  Luis

>   * Memory scanning is a long process and it needs to be interruptable. This
>   * function checks whether such interrupt condition occurred.
>   */
> @@ -1224,6 +1309,7 @@ static void scan_block(void *_start, void *_end,
>  	for (ptr = start; ptr < end; ptr++) {
>  		struct kmemleak_object *object;
>  		unsigned long pointer;
> +		unsigned long excess_ref;
>  
>  		if (scan_should_stop())
>  			break;
> @@ -1259,25 +1345,25 @@ static void scan_block(void *_start, void *_end,
>  		 * enclosed by scan_mutex.
>  		 */
>  		spin_lock_nested(&object->lock, SINGLE_DEPTH_NESTING);
> -		if (!color_white(object)) {
> -			/* non-orphan, ignored or new */
> -			spin_unlock(&object->lock);
> -			continue;
> -		}
> +		/* only pass surplus references (object already gray) */
> +		if (color_gray(object))
> +			excess_ref = object->excess_ref;
> +		else
> +			excess_ref = 0;
> +		update_refs(object);
> +		spin_unlock(&object->lock);
>  
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
> +		if (excess_ref) {
> +			object = lookup_object(excess_ref, 0);
> +			if (!object)
> +				continue;
> +			if (object == scanned)
> +				/* circular reference, ignore */
> +				continue;
> +			spin_lock_nested(&object->lock, SINGLE_DEPTH_NESTING);
> +			update_refs(object);
> +			spin_unlock(&object->lock);
>  		}
> -		spin_unlock(&object->lock);
>  	}
>  	read_unlock_irqrestore(&kmemleak_lock, flags);
>  }
> @@ -1980,6 +2066,10 @@ void __init kmemleak_init(void)
>  		case KMEMLEAK_NO_SCAN:
>  			kmemleak_no_scan(log->ptr);
>  			break;
> +		case KMEMLEAK_SET_EXCESS_REF:
> +			object_set_excess_ref((unsigned long)log->ptr,
> +					      log->excess_ref);
> +			break;
>  		default:
>  			kmemleak_warn("Unknown early log operation: %d\n",
>  				      log->op_type);
> diff --git a/mm/vmalloc.c b/mm/vmalloc.c
> index 34a1c3e46ed7..b805cc5ecca0 100644
> --- a/mm/vmalloc.c
> +++ b/mm/vmalloc.c
> @@ -1759,12 +1759,7 @@ void *__vmalloc_node_range(unsigned long size, unsigned long align,
>  	 */
>  	clear_vm_uninitialized_flag(area);
>  
> -	/*
> -	 * A ref_count = 2 is needed because vm_struct allocated in
> -	 * __get_vm_area_node() contains a reference to the virtual address of
> -	 * the vmalloc'ed block.
> -	 */
> -	kmemleak_alloc(addr, real_size, 2, gfp_mask);
> +	kmemleak_vmalloc(area, size, gfp_mask);
>  
>  	return addr;
>  
> 

-- 
Luis Rodriguez, SUSE LINUX GmbH
Maxfeldstrasse 5; D-90409 Nuernberg

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
