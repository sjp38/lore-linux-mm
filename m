Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx110.postini.com [74.125.245.110])
	by kanga.kvack.org (Postfix) with SMTP id BD9D76B0331
	for <linux-mm@kvack.org>; Mon, 25 Jun 2012 07:13:39 -0400 (EDT)
Message-ID: <4FE84741.9000703@parallels.com>
Date: Mon, 25 Jun 2012 15:10:57 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH SLUB 1/2] duplicate the cache name in saved_alias list
References: <1340617984.13778.37.camel@ThinkPad-T420>
In-Reply-To: <1340617984.13778.37.camel@ThinkPad-T420>
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Li Zhong <zhong@linux.vnet.ibm.com>
Cc: LKML <linux-kernel@vger.kernel.org>, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul
 Mackerras <paulus@samba.org>, linux-mm <linux-mm@kvack.org>, PowerPC email
 list <linuxppc-dev@lists.ozlabs.org>

On 06/25/2012 01:53 PM, Li Zhong wrote:
> SLUB duplicates the cache name in kmem_cache_create(). However if the
> cache could be merged to others during early booting, the name pointer
> is saved in saved_alias list, and the string needs to be kept valid
> before slab_sysfs_init() is called.
>
> This patch tries to duplicate the cache name in saved_alias list, so
> that the cache name could be safely kfreed after calling
> kmem_cache_create(), if that name is kmalloced.
>
> Signed-off-by: Li Zhong <zhong@linux.vnet.ibm.com>
> ---
>   mm/slub.c |    6 ++++++
>   1 files changed, 6 insertions(+), 0 deletions(-)
>
> diff --git a/mm/slub.c b/mm/slub.c
> index 8c691fa..3dc8ed5 100644
> --- a/mm/slub.c
> +++ b/mm/slub.c
> @@ -5373,6 +5373,11 @@ static int sysfs_slab_alias(struct kmem_cache *s,
> const char *name)
>
>   	al->s = s;
>   	al->name = name;
> +	al->name = kstrdup(name, GFP_KERNEL);
> +	if (!al->name) {
> +		kfree(al);
> +		return -ENOMEM;
> +	}
>   	al->next = alias_list;
>   	alias_list = al;
>   	return 0;
> @@ -5409,6 +5414,7 @@ static int __init slab_sysfs_init(void)
>   		if (err)
>   			printk(KERN_ERR "SLUB: Unable to add boot slab alias"
>   					" %s to sysfs\n", s->name);
> +		kfree(al->name);
>   		kfree(al);
>   	}
>
>

What's unsafe about the current state of affairs ?
Whenever we alias, we'll increase the reference counter.
kmem_cache_destroy will only actually destroy the structure whenever 
that refcnt reaches zero.

This means that kfree shouldn't happen until then. So what is exactly 
that you are seeing?

Now, if you ask me, keeping the name around in user-visible files like 
/proc/slabinfo for caches that are removed already can be a bit 
confusing (that is because we don't add aliases to the slab_cache list)

If you want to touch this, one thing you can do is to keep a list of 
names bundled in an alias. If an alias is removed, you free that name. 
If that name is the representative name of the bundle, you move to the 
next one.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
