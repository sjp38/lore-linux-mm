Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 3A0F46B0259
	for <linux-mm@kvack.org>; Tue, 15 Dec 2015 18:41:11 -0500 (EST)
Received: by mail-pa0-f48.google.com with SMTP id ur14so13150562pab.0
        for <linux-mm@kvack.org>; Tue, 15 Dec 2015 15:41:11 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id p18si780249pfi.243.2015.12.15.15.41.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 Dec 2015 15:41:10 -0800 (PST)
Date: Tue, 15 Dec 2015 15:41:09 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [-mm PATCH v2 19/25] list: introduce list_del_poison()
Message-Id: <20151215154109.54f3cb025944ac7166bf6f64@linux-foundation.org>
In-Reply-To: <20151210023855.30368.37457.stgit@dwillia2-desk3.jf.intel.com>
References: <20151210023708.30368.92962.stgit@dwillia2-desk3.jf.intel.com>
	<20151210023855.30368.37457.stgit@dwillia2-desk3.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: linux-mm@kvack.org, linux-nvdimm@ml01.01.org

On Wed, 09 Dec 2015 18:38:55 -0800 Dan Williams <dan.j.williams@intel.com> wrote:

> ZONE_DEVICE pages always have an elevated count and will never be on an
> lru reclaim list.  That space in 'struct page' can be redirected for
> other uses, but for safety introduce a poison value that will always
> trip __list_add() to assert.  This allows half of the struct list_head
> storage to be reclaimed with some assurance to back up the assumption
> that the page count never goes to zero and a list_add() is never
> attempted.
> 
> ...
>
> --- a/include/linux/list.h
> +++ b/include/linux/list.h
> @@ -108,9 +108,26 @@ static inline void list_del(struct list_head *entry)
>  	entry->next = LIST_POISON1;
>  	entry->prev = LIST_POISON2;
>  }
> +
> +#define list_del_poison list_del
>  #else
>  extern void __list_del_entry(struct list_head *entry);
>  extern void list_del(struct list_head *entry);
> +extern struct list_head list_force_poison;
> +
> +/**
> + * list_del_poison - poison an entry to always assert on list_add
> + * @entry: the element to delete and poison
> + *
> + * Note: the assertion on list_add() only occurs when CONFIG_DEBUG_LIST=y,
> + * otherwise this is identical to list_del()
> + */
> +static inline void list_del_poison(struct list_head *entry)
> +{
> +	__list_del(entry->prev, entry->next);
> +	entry->next = &list_force_poison;
> +	entry->prev = &list_force_poison;
> +}
>  #endif

list_del() already poisons the list_head.  Does this really add anything?

>  /**
> diff --git a/lib/list_debug.c b/lib/list_debug.c
> index 3859bf63561c..d730c064a4df 100644
> --- a/lib/list_debug.c
> +++ b/lib/list_debug.c
> @@ -12,6 +12,8 @@
>  #include <linux/kernel.h>
>  #include <linux/rculist.h>
>  
> +struct list_head list_force_poison;
> +
>  /*
>   * Insert a new entry between two known consecutive entries.
>   *
> @@ -23,6 +25,8 @@ void __list_add(struct list_head *new,
>  			      struct list_head *prev,
>  			      struct list_head *next)
>  {
> +	WARN(new->next == &list_force_poison || new->prev == &list_force_poison,
> +		"list_add attempted on force-poisoned entry\n");

I suppose that list_replace() should poison as well, and perhaps other
places were missed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
