Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f176.google.com (mail-ig0-f176.google.com [209.85.213.176])
	by kanga.kvack.org (Postfix) with ESMTP id 2F6216B0255
	for <linux-mm@kvack.org>; Thu,  3 Dec 2015 09:54:00 -0500 (EST)
Received: by igcph11 with SMTP id ph11so12338626igc.1
        for <linux-mm@kvack.org>; Thu, 03 Dec 2015 06:54:00 -0800 (PST)
Received: from resqmta-ch2-05v.sys.comcast.net (resqmta-ch2-05v.sys.comcast.net. [2001:558:fe21:29:69:252:207:37])
        by mx.google.com with ESMTPS id r99si11919554ioi.63.2015.12.03.06.53.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Thu, 03 Dec 2015 06:53:22 -0800 (PST)
Date: Thu, 3 Dec 2015 08:53:21 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH v2] mm/slab.c: use list_{empty_careful,last_entry} in
 drain_freelist
In-Reply-To: <3ea815dc52bf1a2bb5e324d7398315597900be84.1449151365.git.geliangtang@163.com>
Message-ID: <alpine.DEB.2.20.1512030850390.7483@east.gentwo.org>
References: <3ea815dc52bf1a2bb5e324d7398315597900be84.1449151365.git.geliangtang@163.com>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Geliang Tang <geliangtang@163.com>
Cc: Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, 3 Dec 2015, Geliang Tang wrote:

>  	while (nr_freed < tofree && !list_empty(&n->slabs_free)) {
>
>  		spin_lock_irq(&n->list_lock);
> -		p = n->slabs_free.prev;
> -		if (p == &n->slabs_free) {
> +		if (list_empty_careful(&n->slabs_free)) {

We have taken the lock. Why do we need to be "careful"? list_empty()
shoudl work right?

>  			spin_unlock_irq(&n->list_lock);
>  			goto out;
>  		}
>
> -		page = list_entry(p, struct page, lru);
> +		page = list_last_entry(&n->slabs_free, struct page, lru);

last???

Would the the other new function that returns NULL on the empty list or
the pointer not be useful here too and save some code?

This patch seems to make it difficult to understand the code.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
