Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 0E3AA6B0006
	for <linux-mm@kvack.org>; Tue,  6 Feb 2018 09:34:56 -0500 (EST)
Received: by mail-pl0-f70.google.com with SMTP id f1so1752871plb.7
        for <linux-mm@kvack.org>; Tue, 06 Feb 2018 06:34:56 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id p12si17294pgn.253.2018.02.06.06.34.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Feb 2018 06:34:54 -0800 (PST)
Date: Tue, 6 Feb 2018 09:34:51 -0500
From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH 1/2] rcu: Transform kfree_rcu() into kvfree_rcu()
Message-ID: <20180206093451.0de5ceeb@gandalf.local.home>
In-Reply-To: <151791238553.5994.4933976056810745303.stgit@localhost.localdomain>
References: <151791170164.5994.8253310844733420079.stgit@localhost.localdomain>
	<151791238553.5994.4933976056810745303.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kirill Tkhai <ktkhai@virtuozzo.com>
Cc: paulmck@linux.vnet.ibm.com, josh@joshtriplett.org, mathieu.desnoyers@efficios.com, jiangshanlai@gmail.com, mingo@redhat.com, cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, 06 Feb 2018 13:19:45 +0300
Kirill Tkhai <ktkhai@virtuozzo.com> wrote:

> /**
> - * kfree_rcu() - kfree an object after a grace period.
> - * @ptr:	pointer to kfree
> + * kvfree_rcu() - kvfree an object after a grace period.
> + * @ptr:	pointer to kvfree
>   * @rcu_head:	the name of the struct rcu_head within the type of @ptr.
>   *

You may want to add a big comment here that states this works for both
free vmalloc and kmalloc data. Because if I saw this, I would think it
only works for vmalloc, and start implementing a custom one for kmalloc
data.

-- Steve


> - * Many rcu callbacks functions just call kfree() on the base structure.
> + * Many rcu callbacks functions just call kvfree() on the base structure.
>   * These functions are trivial, but their size adds up, and furthermore
>   * when they are used in a kernel module, that module must invoke the
>   * high-latency rcu_barrier() function at module-unload time.
>   *
> - * The kfree_rcu() function handles this issue.  Rather than encoding a
> - * function address in the embedded rcu_head structure, kfree_rcu() instead
> + * The kvfree_rcu() function handles this issue.  Rather than encoding a
> + * function address in the embedded rcu_head structure, kvfree_rcu() instead
>   * encodes the offset of the rcu_head structure within the base structure.
>   * Because the functions are not allowed in the low-order 4096 bytes of
>   * kernel virtual memory, offsets up to 4095 bytes can be accommodated.
>   * If the offset is larger than 4095 bytes, a compile-time error will
> - * be generated in __kfree_rcu().  If this error is triggered, you can
> + * be generated in __kvfree_rcu().  If this error is triggered, you can
>   * either fall back to use of call_rcu() or rearrange the structure to
>   * position the rcu_head structure into the first 4096 bytes.
>   *
> @@ -871,9 +871,12 @@ static inline notrace void rcu_read_unlock_sched_notrace(void)
>   * The BUILD_BUG_ON check must not involve any function calls, hence the
>   * checks are done in macros here.
>   */
> -#define kfree_rcu(ptr, rcu_head)					\
> -	__kfree_rcu(&((ptr)->rcu_head), offsetof(typeof(*(ptr)), rcu_head))
> +#define kvfree_rcu(ptr, rcu_head)					\
> +	__kvfree_rcu(&((ptr)->rcu_head), offsetof(typeof(*(ptr)), rcu_head))
>  
> +#define kfree_rcu(ptr, rcu_head) kvfree_rcu(ptr, rcu_head)
> +
> +#define vfree_rcu(ptr, rcu_head) kvfree_rcu(ptr, rcu_head)
>  
>  /*
>   * Place this after a lock-acquisition primitive to guarantee that
> diff --git a/include/linux/rcutiny.h b/include/linux/rcutiny.h
> index ce9beec35e34..2e484aaa534f 100644
> --- a/include/linux/rcutiny.h
> +++ b/include/linux/rcutiny.h
> @@ -84,8 +84,8 @@ static inline void synchronize_sched_expedited(void)
>  	synchronize_sched();
>  }
>  
> -static inline void kfree_call_rcu(struct rcu_head *head,
> -				  rcu_callback_t func)
> +static inline void kvfree_call_rcu(struct rcu_head *head,
> +				   rcu_callback_t func)
>  {
>  	call_rcu(head, func);
>  }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
