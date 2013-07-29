Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx102.postini.com [74.125.245.102])
	by kanga.kvack.org (Postfix) with SMTP id C62126B0039
	for <linux-mm@kvack.org>; Tue, 30 Jul 2013 11:23:53 -0400 (EDT)
Received: from /spool/local
	by e23smtp08.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sjennings@variantweb.net>;
	Wed, 31 Jul 2013 01:20:39 +1000
Received: from d23relay05.au.ibm.com (d23relay05.au.ibm.com [9.190.235.152])
	by d23dlp02.au.ibm.com (Postfix) with ESMTP id 9AFAB2BB0052
	for <linux-mm@kvack.org>; Wed, 31 Jul 2013 01:23:39 +1000 (EST)
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r6UF7wGe64028856
	for <linux-mm@kvack.org>; Wed, 31 Jul 2013 01:07:59 +1000
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r6UFNcCh024254
	for <linux-mm@kvack.org>; Wed, 31 Jul 2013 01:23:38 +1000
Date: Mon, 29 Jul 2013 10:06:24 -0500
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
Subject: Re: [PATCH 2/5] rbtree: add rbtree_postorder_for_each_entry_safe()
 helper
Message-ID: <20130729150624.GB4381@variantweb.net>
References: <1374873223-25557-1-git-send-email-cody@linux.vnet.ibm.com>
 <1374873223-25557-3-git-send-email-cody@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1374873223-25557-3-git-send-email-cody@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cody P Schafer <cody@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, David Woodhouse <David.Woodhouse@intel.com>, Rik van Riel <riel@redhat.com>, Michel Lespinasse <walken@google.com>

On Fri, Jul 26, 2013 at 02:13:40PM -0700, Cody P Schafer wrote:
> Because deletion (of the entire tree) is a relatively common use of the
> rbtree_postorder iteration, and because doing it safely means fiddling
> with temporary storage, provide a helper to simplify postorder rbtree
> iteration.
> 
> Signed-off-by: Cody P Schafer <cody@linux.vnet.ibm.com>
> ---
>  include/linux/rbtree.h | 17 +++++++++++++++++
>  1 file changed, 17 insertions(+)
> 
> diff --git a/include/linux/rbtree.h b/include/linux/rbtree.h
> index 2879e96..64ab98b 100644
> --- a/include/linux/rbtree.h
> +++ b/include/linux/rbtree.h
> @@ -85,4 +85,21 @@ static inline void rb_link_node(struct rb_node * node, struct rb_node * parent,
>  	*rb_link = node;
>  }
> 
> +/**
> + * rbtree_postorder_for_each_entry_safe - iterate over rb_root in post order of
> + * given type safe against removal of rb_node entry
> + *
> + * @pos:	the 'type *' to use as a loop cursor.
> + * @n:		another 'type *' to use as temporary storage
> + * @root:	'rb_root *' of the rbtree.
> + * @field:	the name of the rb_node field within 'type'.
> + */
> +#define rbtree_postorder_for_each_entry_safe(pos, n, root, field) \
> +	for (pos = rb_entry(rb_first_postorder(root), typeof(*pos), field),\
> +	      n = rb_entry(rb_next_postorder(&pos->field), \
> +		      typeof(*pos), field); \
> +	     &pos->field; \
> +	     pos = n, \
> +	      n = rb_entry(rb_next_postorder(&pos->field), typeof(*pos), field))

One too many spaces.  Also mix of tabs and spaces is weird, but
checkpatch doesn't complain so...

Seth

> +
>  #endif	/* _LINUX_RBTREE_H */
> -- 
> 1.8.3.4
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
