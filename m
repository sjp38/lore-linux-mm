Date: Mon, 17 Apr 2006 21:53:18 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH] alloc uid cleanup
Message-Id: <20060417215318.29f0f7e0.akpm@osdl.org>
In-Reply-To: <E1FVZH8-0004f1-8s@blr-eng3.blr.corp.google.com>
References: <E1FVZH8-0004f1-8s@blr-eng3.blr.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Prasanna Meda <mlp@google.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Prasanna Meda <mlp@google.com> wrote:
>
> Cleanup: Release the lock before key_put methods. They call 
>  schedule_work etc. They block interrupts now, so it is not bug fix.
> 
>  Signed-off-by: Prasanna Meda
> 
>  --- a/kernel/user.c	2006-04-17 23:02:54.000000000 +0530
>  +++ b/kernel/user.c	2006-04-17 23:06:01.000000000 +0530
>  @@ -160,15 +160,15 @@ struct user_struct * alloc_uid(uid_t uid
>   		spin_lock_irq(&uidhash_lock);
>   		up = uid_hash_find(uid, hashent);
>   		if (up) {
>  +			spin_unlock_irq(&uidhash_lock);
>   			key_put(new->uid_keyring);
>   			key_put(new->session_keyring);
>   			kmem_cache_free(uid_cachep, new);
>   		} else {
>   			uid_hash_insert(new, hashent);
>   			up = new;
>  +			spin_unlock_irq (&uidhash_lock);
>   		}
>  -		spin_unlock_irq(&uidhash_lock);
>  -
>   	}
>   	return up;
>   }

The path you're optimising is the wildly-improbable
we-raced-with-someone-else one.  The benefits from this patch will most
likely be outweighed by the loss of increased text size.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
