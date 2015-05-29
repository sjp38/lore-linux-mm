Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id 41AF06B00A9
	for <linux-mm@kvack.org>; Fri, 29 May 2015 18:07:08 -0400 (EDT)
Received: by padj3 with SMTP id j3so2005539pad.0
        for <linux-mm@kvack.org>; Fri, 29 May 2015 15:07:08 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id ku2si10151702pbc.235.2015.05.29.15.07.06
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 29 May 2015 15:07:07 -0700 (PDT)
Date: Fri, 29 May 2015 15:07:05 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] frontswap: allow multiple backends
Message-Id: <20150529150705.5fd6b7c1545ef5829f7ace93@linux-foundation.org>
In-Reply-To: <1432844917-27531-1-git-send-email-ddstreet@ieee.org>
References: <1432844917-27531-1-git-send-email-ddstreet@ieee.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Streetman <ddstreet@ieee.org>
Cc: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, David Vrabel <david.vrabel@citrix.com>, xen-devel@lists.xenproject.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, 28 May 2015 16:28:37 -0400 Dan Streetman <ddstreet@ieee.org> wrote:

> Change frontswap single pointer to a singly linked list of frontswap
> implementations.  Update Xen tmem implementation as register no longer
> returns anything.
> 
> Frontswap only keeps track of a single implementation; any implementation
> that registers second (or later) will replace the previously registered
> implementation, and gets a pointer to the previous implementation that
> the new implementation is expected to pass all frontswap functions to
> if it can't handle the function itself.  However that method doesn't
> really make much sense, as passing that work on to every implementation
> adds unnecessary work to implementations; instead, frontswap should
> simply keep a list of all registered implementations and try each
> implementation for any function.  Most importantly, neither of the
> two currently existing frontswap implementations in the kernel actually
> do anything with any previous frontswap implementation that they
> replace when registering.
> 
> This allows frontswap to successfully manage multiple implementations
> by keeping a list of them all.

Looks OK to me.  The "you can never deregister" thing makes life
simpler.

But we need to have a fight over style issues.  Just because you *can*
do something doesn't mean you should.  Don't make you poor readers sit
there going crosseyed at elaborate `for' statements.  Try to keep the
code as simple and straightforward as possible.

> ...
>
>  /*
> - * Register operations for frontswap, returning previous thus allowing
> - * detection of multiple backends and possible nesting.
> + * Register operations for frontswap
>   */
> -struct frontswap_ops *frontswap_register_ops(struct frontswap_ops *ops)
> +void frontswap_register_ops(struct frontswap_ops *ops)
>  {
> -	struct frontswap_ops *old = frontswap_ops;
> -	int i;
> -
> -	for (i = 0; i < MAX_SWAPFILES; i++) {
> -		if (test_and_clear_bit(i, need_init)) {
> -			struct swap_info_struct *sis = swap_info[i];
> -			/* __frontswap_init _should_ have set it! */
> -			if (!sis->frontswap_map)
> -				return ERR_PTR(-EINVAL);
> -			ops->init(i);
> +	DECLARE_BITMAP(a, MAX_SWAPFILES);
> +	DECLARE_BITMAP(b, MAX_SWAPFILES);
> +	struct swap_info_struct *si;
> +	unsigned int i;
> +
> +	spin_lock(&swap_lock);
> +	plist_for_each_entry(si, &swap_active_head, list) {
> +		if (!WARN_ON(!si->frontswap_map))
> +			set_bit(si->type, a);
> +	}
> +	spin_unlock(&swap_lock);
> +
> +	for (i = find_first_bit(a, MAX_SWAPFILES);
> +	     i < MAX_SWAPFILES;
> +	     i = find_next_bit(a, MAX_SWAPFILES, i + 1))
> +		ops->init(i);

	i = find_first_bit(a, MAX_SWAPFILES);
	while (i < MAX_SWAPFILES) {
		ops->init(i);
		i = find_next_bit(a, MAX_SWAPFILES, i + 1);
	}

> +	do {
> +		ops->next = frontswap_ops;
> +	} while (cmpxchg(&frontswap_ops, ops->next, ops) != ops->next);
> +
> +	spin_lock(&swap_lock);
> +	plist_for_each_entry(si, &swap_active_head, list) {
> +		if (si->frontswap_map)
> +			set_bit(si->type, b);
> +	}
> +	spin_unlock(&swap_lock);
> +
> +	if (!bitmap_equal(a, b, MAX_SWAPFILES)) {
> +		for (i = 0; i < MAX_SWAPFILES; i++) {
> +			if (!test_bit(i, a) && test_bit(i, b))
> +				ops->init(i);
> +			else if (test_bit(i, a) && !test_bit(i, b))
> +				ops->invalidate_area(i);
>  		}
> ...
>
> @@ -215,24 +216,25 @@ static inline void __frontswap_clear(struct swap_info_struct *sis,
>   */
>  int __frontswap_store(struct page *page)
>  {
> -	int ret = -1, dup = 0;
> +	int ret, dup;
>  	swp_entry_t entry = { .val = page_private(page), };
>  	int type = swp_type(entry);
>  	struct swap_info_struct *sis = swap_info[type];
>  	pgoff_t offset = swp_offset(entry);
> +	struct frontswap_ops *ops;
>  
>  	/*
>  	 * Return if no backend registed.
>  	 * Don't need to inc frontswap_failed_stores here.
>  	 */
>  	if (!frontswap_ops)
> -		return ret;
> +		return -1;
>  
>  	BUG_ON(!PageLocked(page));
>  	BUG_ON(sis == NULL);
> -	if (__frontswap_test(sis, offset))
> -		dup = 1;
> -	ret = frontswap_ops->store(type, offset, page);
> +	dup = __frontswap_test(sis, offset);
> +	for (ops = frontswap_ops, ret = -1; ops && ret; ops = ops->next)
> +		ret = ops->store(type, offset, page);

	ret = -1;
	for (ops = frontswap_ops; ops; ops = ops->next) {
		ret = ops->store(type, offset, page);
		if (!ret)
			break;
	}

One advantage of doing it this way is that it leaves room for comments.
And this code would benefit from a comment above the "if (!ret)". 
What's going on here?  What could cause ->store to return zero and is
this an error?  We should explain this somewhere;  `struct
frontswap_ops' is cheerily undocumented, so where?


Is the `ret = -1' really needed?  Can this function ever be called if
there aren't any registered frontswap_ops?


Also, __frontswap_store() disturbs me:

: int __frontswap_store(struct page *page)
: {
: 	int ret, dup;
: 	swp_entry_t entry = { .val = page_private(page), };
: 	int type = swp_type(entry);
: 	struct swap_info_struct *sis = swap_info[type];
: 	pgoff_t offset = swp_offset(entry);
: 	struct frontswap_ops *ops;
: 
: 	/*
: 	 * Return if no backend registed.
: 	 * Don't need to inc frontswap_failed_stores here.
: 	 */
: 	if (!frontswap_ops)
: 		return -1;
: 
: 	BUG_ON(!PageLocked(page));
: 	BUG_ON(sis == NULL);
: 	dup = __frontswap_test(sis, offset);
: 	ret = -1;
: 	for (ops = frontswap_ops; ops; ops = ops->next) {
: 		ret = ops->store(type, offset, page);
: 		if (!ret)
: 			break;
: 	}

Here we've just iterated through all the registered operations.

: 	if (ret == 0) {
: 		set_bit(offset, sis->frontswap_map);
: 		inc_frontswap_succ_stores();
: 		if (!dup)
: 			atomic_inc(&sis->frontswap_pages);
: 	} else {
: 		/*
: 		  failed dup always results in automatic invalidate of
: 		  the (older) page from frontswap
: 		 */
: 		inc_frontswap_failed_stores();
: 		if (dup) {
: 			__frontswap_clear(sis, offset);
: 			frontswap_ops->invalidate_page(type, offset);

But here we call ->invalidate_page on just one of teh registered
operations.  Seems wrong.

Maybe some careful code commentary would clear this up.

: 		}
: 	}
: 	if (frontswap_writethrough_enabled)
: 		/* report failure so swap also writes to swap device */
: 		ret = -1;
: 	return ret;
: }

Please review:

--- a/mm/frontswap.c~frontswap-allow-multiple-backends-fix
+++ a/mm/frontswap.c
@@ -97,7 +97,7 @@ static inline void inc_frontswap_invalid
  *
  * Obviously the opposite (unloading the backend) must be done after all
  * the frontswap_[store|load|invalidate_area|invalidate_page] start
- * ignorning or failing the requests.  However, there is currently no way
+ * ignoring or failing the requests.  However, there is currently no way
  * to unload a backend once it is registered.
  */
 
@@ -118,10 +118,11 @@ void frontswap_register_ops(struct front
 	}
 	spin_unlock(&swap_lock);
 
-	for (i = find_first_bit(a, MAX_SWAPFILES);
-	     i < MAX_SWAPFILES;
-	     i = find_next_bit(a, MAX_SWAPFILES, i + 1))
+	i = find_first_bit(a, MAX_SWAPFILES);
+	while (i < MAX_SWAPFILES) {
 		ops->init(i);
+		i = find_next_bit(a, MAX_SWAPFILES, i + 1);
+	}
 
 	do {
 		ops->next = frontswap_ops;
@@ -233,8 +234,12 @@ int __frontswap_store(struct page *page)
 	BUG_ON(!PageLocked(page));
 	BUG_ON(sis == NULL);
 	dup = __frontswap_test(sis, offset);
-	for (ops = frontswap_ops, ret = -1; ops && ret; ops = ops->next)
+	ret = -1;
+	for (ops = frontswap_ops; ops; ops = ops->next) {
 		ret = ops->store(type, offset, page);
+		if (!ret)
+			break;
+	}
 	if (ret == 0) {
 		set_bit(offset, sis->frontswap_map);
 		inc_frontswap_succ_stores();
@@ -279,8 +284,12 @@ int __frontswap_load(struct page *page)
 	BUG_ON(sis == NULL);
 	if (!__frontswap_test(sis, offset))
 		return -1;
-	for (ops = frontswap_ops, ret = -1; ops && ret; ops = ops->next)
+	ret = -1;
+	for (ops = frontswap_ops; ops; ops = ops->next) {
 		ret = ops->load(type, offset, page);
+		if (!ret)
+			break;
+	}
 	if (ret == 0) {
 		inc_frontswap_loads();
 		if (frontswap_tmem_exclusive_gets_enabled) {
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
