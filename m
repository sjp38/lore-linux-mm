Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6B8F96B0007
	for <linux-mm@kvack.org>; Sat,  3 Mar 2018 08:57:51 -0500 (EST)
Received: by mail-qt0-f197.google.com with SMTP id u9so10113853qtk.0
        for <linux-mm@kvack.org>; Sat, 03 Mar 2018 05:57:51 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v22sor5946675qkl.103.2018.03.03.05.57.50
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 03 Mar 2018 05:57:50 -0800 (PST)
Message-ID: <1520085468.4280.22.camel@redhat.com>
Subject: Re: [PATCH v7 07/61] fscache: Use appropriate radix tree accessors
From: Jeff Layton <jlayton@redhat.com>
Date: Sat, 03 Mar 2018 08:57:48 -0500
In-Reply-To: <20180219194556.6575-8-willy@infradead.org>
References: <20180219194556.6575-1-willy@infradead.org>
	 <20180219194556.6575-8-willy@infradead.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: Matthew Wilcox <mawilcox@microsoft.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org

On Mon, 2018-02-19 at 11:45 -0800, Matthew Wilcox wrote:
> From: Matthew Wilcox <mawilcox@microsoft.com>
> 
> Don't open-code accesses to data structure internals.
> 
> Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
> ---
>  fs/fscache/cookie.c | 2 +-
>  fs/fscache/object.c | 2 +-
>  2 files changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/fs/fscache/cookie.c b/fs/fscache/cookie.c
> index ff84258132bb..e9054e0c1a49 100644
> --- a/fs/fscache/cookie.c
> +++ b/fs/fscache/cookie.c
> @@ -608,7 +608,7 @@ void __fscache_relinquish_cookie(struct fscache_cookie *cookie, bool retire)
>  	/* Clear pointers back to the netfs */
>  	cookie->netfs_data	= NULL;
>  	cookie->def		= NULL;
> -	BUG_ON(cookie->stores.rnode);
> +	BUG_ON(!radix_tree_empty(&cookie->stores));
>  
>  	if (cookie->parent) {
>  		ASSERTCMP(atomic_read(&cookie->parent->usage), >, 0);
> diff --git a/fs/fscache/object.c b/fs/fscache/object.c
> index 7a182c87f378..aa0e71f02c33 100644
> --- a/fs/fscache/object.c
> +++ b/fs/fscache/object.c
> @@ -956,7 +956,7 @@ static const struct fscache_state *_fscache_invalidate_object(struct fscache_obj
>  	 * retire the object instead.
>  	 */
>  	if (!fscache_use_cookie(object)) {
> -		ASSERT(object->cookie->stores.rnode == NULL);
> +		ASSERT(radix_tree_empty(&object->cookie->stores));
>  		set_bit(FSCACHE_OBJECT_RETIRED, &object->flags);
>  		_leave(" [no cookie]");
>  		return transit_to(KILL_OBJECT);

Reviewed-by: Jeff Layton <jlayton@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
