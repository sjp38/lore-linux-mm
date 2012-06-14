Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx191.postini.com [74.125.245.191])
	by kanga.kvack.org (Postfix) with SMTP id 4B49C6B0070
	for <linux-mm@kvack.org>; Thu, 14 Jun 2012 04:21:40 -0400 (EDT)
Message-ID: <4FD99E7E.9040001@parallels.com>
Date: Thu, 14 Jun 2012 12:19:10 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: Common [17/20] Move duping of slab name to slab_common.c
References: <20120613152451.465596612@linux.com> <20120613152524.444246406@linux.com>
In-Reply-To: <20120613152524.444246406@linux.com>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Matt Mackall <mpm@selenic.com>, Joonsoo Kim <js1304@gmail.com>

On 06/13/2012 07:25 PM, Christoph Lameter wrote:
>   	mutex_unlock(&slab_mutex);
> @@ -128,6 +137,7 @@ void kmem_cache_destroy(struct kmem_cach
>   		if (s->flags&  SLAB_DESTROY_BY_RCU)
>   			rcu_barrier();
>
> +		kfree(s->name);
>   		kmem_cache_free(kmem_cache, s);
>   	} else {
>   		list_add(&s->list,&slab_caches);

You forgot to remove the freeing of name in kmem_cache_release. This 
kfree here then leads to a double free.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
