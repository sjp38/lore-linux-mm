Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 35A866B2696
	for <linux-mm@kvack.org>; Wed, 21 Nov 2018 11:49:59 -0500 (EST)
Received: by mail-qk1-f198.google.com with SMTP id f22so6905018qkm.11
        for <linux-mm@kvack.org>; Wed, 21 Nov 2018 08:49:59 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 13si105965qtu.390.2018.11.21.08.49.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Nov 2018 08:49:58 -0800 (PST)
Subject: Re: [PATCH v2 07/17] debugobjects: Move printk out of db lock
 critical sections
References: <1542653726-5655-1-git-send-email-longman@redhat.com>
 <1542653726-5655-8-git-send-email-longman@redhat.com>
From: Waiman Long <longman@redhat.com>
Message-ID: <2ddd9e3d-951e-1892-c941-54be80f7e6aa@redhat.com>
Date: Wed, 21 Nov 2018 11:49:54 -0500
MIME-Version: 1.0
In-Reply-To: <1542653726-5655-8-git-send-email-longman@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, Will Deacon <will.deacon@arm.com>, Thomas Gleixner <tglx@linutronix.de>
Cc: linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org, Petr Mladek <pmladek@suse.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>

On 11/19/2018 01:55 PM, Waiman Long wrote:
> The db->lock is a raw spinlock and so the lock hold time is supposed
> to be short. This will not be the case when printk() is being involved
> in some of the critical sections. In order to avoid the long hold time,
> in case some messages need to be printed, the debug_object_is_on_stack()
> and debug_print_object() calls are now moved out of those critical
> sections.
>
> Signed-off-by: Waiman Long <longman@redhat.com>
> ---
>  lib/debugobjects.c | 61 +++++++++++++++++++++++++++++++++++++-----------------
>  1 file changed, 42 insertions(+), 19 deletions(-)
>
> diff --git a/lib/debugobjects.c b/lib/debugobjects.c
> index 403dd95..4216d3d 100644
> --- a/lib/debugobjects.c
> +++ b/lib/debugobjects.c
> @@ -376,6 +376,8 @@ static void debug_object_is_on_stack(void *addr, int onstack)
>  	struct debug_bucket *db;
>  	struct debug_obj *obj;
>  	unsigned long flags;
> +	bool debug_printobj = false;
> +	bool debug_chkstack = false;
>  
>  	fill_pool();
>  
> @@ -392,7 +394,7 @@ static void debug_object_is_on_stack(void *addr, int onstack)
>  			debug_objects_oom();
>  			return;
>  		}
> -		debug_object_is_on_stack(addr, onstack);
> +		debug_chkstack = true;
>  	}
>  
>  	switch (obj->state) {
> @@ -403,20 +405,25 @@ static void debug_object_is_on_stack(void *addr, int onstack)
>  		break;
>  
>  	case ODEBUG_STATE_ACTIVE:
> -		debug_print_object(obj, "init");
>  		state = obj->state;
>  		raw_spin_unlock_irqrestore(&db->lock, flags);
> +		debug_print_object(obj, "init");
>  		debug_object_fixup(descr->fixup_init, addr, state);
>  		return;
>  
>  	case ODEBUG_STATE_DESTROYED:
> -		debug_print_object(obj, "init");
> +		debug_printobj = true;
>  		break;
>  	default:
>  		break;
>  	}
>  
>  	raw_spin_unlock_irqrestore(&db->lock, flags);
> +	if (debug_chkstack)
> +		debug_object_is_on_stack(addr, onstack);
> +	if (debug_printobj)
> +		debug_print_object(obj, "init");
> +
>  }
>  
>  /**
> @@ -474,6 +481,8 @@ int debug_object_activate(void *addr, struct debug_obj_descr *descr)
>  
>  	obj = lookup_object(addr, db);
>  	if (obj) {
> +		bool debug_printobj = false;
> +
>  		switch (obj->state) {
>  		case ODEBUG_STATE_INIT:
>  		case ODEBUG_STATE_INACTIVE:
> @@ -482,14 +491,14 @@ int debug_object_activate(void *addr, struct debug_obj_descr *descr)
>  			break;
>  
>  		case ODEBUG_STATE_ACTIVE:
> -			debug_print_object(obj, "activate");
>  			state = obj->state;
>  			raw_spin_unlock_irqrestore(&db->lock, flags);
> +			debug_print_object(obj, "activate");
>  			ret = debug_object_fixup(descr->fixup_activate, addr, state);
>  			return ret ? 0 : -EINVAL;
>  
>  		case ODEBUG_STATE_DESTROYED:
> -			debug_print_object(obj, "activate");
> +			debug_printobj = true;
>  			ret = -EINVAL;
>  			break;
>  		default:
> @@ -497,10 +506,13 @@ int debug_object_activate(void *addr, struct debug_obj_descr *descr)
>  			break;
>  		}
>  		raw_spin_unlock_irqrestore(&db->lock, flags);
> +		if (debug_printobj)
> +			debug_print_object(obj, "activate");
>  		return ret;
>  	}
>  
>  	raw_spin_unlock_irqrestore(&db->lock, flags);
> +
>  	/*
>  	 * We are here when a static object is activated. We
>  	 * let the type specific code confirm whether this is
> @@ -532,6 +544,7 @@ void debug_object_deactivate(void *addr, struct debug_obj_descr *descr)
>  	struct debug_bucket *db;
>  	struct debug_obj *obj;
>  	unsigned long flags;
> +	bool debug_printobj = false;
>  
>  	if (!debug_objects_enabled)
>  		return;
> @@ -549,24 +562,27 @@ void debug_object_deactivate(void *addr, struct debug_obj_descr *descr)
>  			if (!obj->astate)
>  				obj->state = ODEBUG_STATE_INACTIVE;
>  			else
> -				debug_print_object(obj, "deactivate");
> +				debug_printobj = true;
>  			break;
>  
>  		case ODEBUG_STATE_DESTROYED:
> -			debug_print_object(obj, "deactivate");
> +			debug_printobj = true;
>  			break;
>  		default:
>  			break;
>  		}
> -	} else {
> +	}
> +
> +	raw_spin_unlock_irqrestore(&db->lock, flags);
> +	if (!obj) {
>  		struct debug_obj o = { .object = addr,
>  				       .state = ODEBUG_STATE_NOTAVAILABLE,
>  				       .descr = descr };
>  
>  		debug_print_object(&o, "deactivate");
> +	} else if (debug_printobj) {
> +		debug_print_object(obj, "deactivate");
>  	}
> -
> -	raw_spin_unlock_irqrestore(&db->lock, flags);
>  }
>  EXPORT_SYMBOL_GPL(debug_object_deactivate);
>  
> @@ -581,6 +597,7 @@ void debug_object_destroy(void *addr, struct debug_obj_descr *descr)
>  	struct debug_bucket *db;
>  	struct debug_obj *obj;
>  	unsigned long flags;
> +	bool debug_printobj = false;
>  
>  	if (!debug_objects_enabled)
>  		return;
> @@ -600,20 +617,22 @@ void debug_object_destroy(void *addr, struct debug_obj_descr *descr)
>  		obj->state = ODEBUG_STATE_DESTROYED;
>  		break;
>  	case ODEBUG_STATE_ACTIVE:
> -		debug_print_object(obj, "destroy");
>  		state = obj->state;
>  		raw_spin_unlock_irqrestore(&db->lock, flags);
> +		debug_print_object(obj, "destroy");
>  		debug_object_fixup(descr->fixup_destroy, addr, state);
>  		return;
>  
>  	case ODEBUG_STATE_DESTROYED:
> -		debug_print_object(obj, "destroy");
> +		debug_printobj = true;
>  		break;
>  	default:
>  		break;
>  	}
>  out_unlock:
>  	raw_spin_unlock_irqrestore(&db->lock, flags);
> +	if (debug_printobj)
> +		debug_print_object(obj, "destroy");
>  }
>  EXPORT_SYMBOL_GPL(debug_object_destroy);
>  
> @@ -642,9 +661,9 @@ void debug_object_free(void *addr, struct debug_obj_descr *descr)
>  
>  	switch (obj->state) {
>  	case ODEBUG_STATE_ACTIVE:
> -		debug_print_object(obj, "free");
>  		state = obj->state;
>  		raw_spin_unlock_irqrestore(&db->lock, flags);
> +		debug_print_object(obj, "free");
>  		debug_object_fixup(descr->fixup_free, addr, state);
>  		return;
>  	default:
> @@ -717,6 +736,7 @@ void debug_object_assert_init(void *addr, struct debug_obj_descr *descr)
>  	struct debug_bucket *db;
>  	struct debug_obj *obj;
>  	unsigned long flags;
> +	bool debug_printobj = false;
>  
>  	if (!debug_objects_enabled)
>  		return;
> @@ -732,22 +752,25 @@ void debug_object_assert_init(void *addr, struct debug_obj_descr *descr)
>  			if (obj->astate == expect)
>  				obj->astate = next;
>  			else
> -				debug_print_object(obj, "active_state");
> +				debug_printobj = true;
>  			break;
>  
>  		default:
> -			debug_print_object(obj, "active_state");
> +			debug_printobj = true;
>  			break;
>  		}
> -	} else {
> +	}
> +
> +	raw_spin_unlock_irqrestore(&db->lock, flags);
> +	if (!obj) {
>  		struct debug_obj o = { .object = addr,
>  				       .state = ODEBUG_STATE_NOTAVAILABLE,
>  				       .descr = descr };
>  
>  		debug_print_object(&o, "active_state");
> +	} else if (debug_printobj) {
> +		debug_print_object(obj, "active_state");
>  	}
> -
> -	raw_spin_unlock_irqrestore(&db->lock, flags);
>  }
>  EXPORT_SYMBOL_GPL(debug_object_active_state);
>  
> @@ -783,10 +806,10 @@ static void __debug_check_no_obj_freed(const void *address, unsigned long size)
>  
>  			switch (obj->state) {
>  			case ODEBUG_STATE_ACTIVE:
> -				debug_print_object(obj, "free");
>  				descr = obj->descr;
>  				state = obj->state;
>  				raw_spin_unlock_irqrestore(&db->lock, flags);
> +				debug_print_object(obj, "free");
>  				debug_object_fixup(descr->fixup_free,
>  						   (void *) oaddr, state);
>  				goto repeat;

As a side note, one of the test systems that I used generated a
debugobjects splat in the bootup process and the system hanged
afterward. Applying this patch alone fix the hanging problem and the
system booted up successfully. So it is not really a good idea to call
printk() while holding a raw spinlock.

Cheers,
Longman
