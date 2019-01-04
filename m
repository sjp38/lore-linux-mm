Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 19A848E00F9
	for <linux-mm@kvack.org>; Fri,  4 Jan 2019 13:37:22 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id f17so35380951edm.20
        for <linux-mm@kvack.org>; Fri, 04 Jan 2019 10:37:22 -0800 (PST)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id r7-v6si3097634ejl.155.2019.01.04.10.37.20
        for <linux-mm@kvack.org>;
        Fri, 04 Jan 2019 10:37:20 -0800 (PST)
Date: Fri, 4 Jan 2019 18:37:16 +0000
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [PATCH] mm: kmemleak: Turn kmemleak_lock to spin lock and RCU
 primitives
Message-ID: <20190104183715.GC187360@arrakis.emea.arm.com>
References: <1546612153-451172-1-git-send-email-zhe.he@windriver.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1546612153-451172-1-git-send-email-zhe.he@windriver.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: zhe.he@windriver.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Jan 04, 2019 at 10:29:13PM +0800, zhe.he@windriver.com wrote:
> It's not necessary to keep consistency between readers and writers of
> kmemleak_lock. RCU is more proper for this case. And in order to gain better
> performance, we turn the reader locks to RCU read locks and writer locks to
> normal spin locks.

This won't work.

> @@ -515,9 +515,7 @@ static struct kmemleak_object *find_and_get_object(unsigned long ptr, int alias)
>  	struct kmemleak_object *object;
>  
>  	rcu_read_lock();
> -	read_lock_irqsave(&kmemleak_lock, flags);
>  	object = lookup_object(ptr, alias);
> -	read_unlock_irqrestore(&kmemleak_lock, flags);

The comment on lookup_object() states that the kmemleak_lock must be
held. That's because we don't have an RCU-like mechanism for removing
removing objects from the object_tree_root:

>  
>  	/* check whether the object is still available */
>  	if (object && !get_object(object))
> @@ -537,13 +535,13 @@ static struct kmemleak_object *find_and_remove_object(unsigned long ptr, int ali
>  	unsigned long flags;
>  	struct kmemleak_object *object;
>  
> -	write_lock_irqsave(&kmemleak_lock, flags);
> +	spin_lock_irqsave(&kmemleak_lock, flags);
>  	object = lookup_object(ptr, alias);
>  	if (object) {
>  		rb_erase(&object->rb_node, &object_tree_root);
>  		list_del_rcu(&object->object_list);
>  	}
> -	write_unlock_irqrestore(&kmemleak_lock, flags);
> +	spin_unlock_irqrestore(&kmemleak_lock, flags);

So here, while list removal is RCU-safe, rb_erase() is not.

If you have time to implement an rb_erase_rcu(), than we could reduce
the locking in kmemleak.

-- 
Catalin
