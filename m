Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 0A60E6B03B1
	for <linux-mm@kvack.org>; Fri, 18 Nov 2016 02:46:41 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id a20so7866228wme.5
        for <linux-mm@kvack.org>; Thu, 17 Nov 2016 23:46:40 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id u13si6377992wjw.235.2016.11.17.23.46.39
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 17 Nov 2016 23:46:39 -0800 (PST)
Date: Fri, 18 Nov 2016 08:46:38 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 5/9] lib: radix-tree: check accounting of existing slot
 replacement users
Message-ID: <20161118074638.GE18676@quack2.suse.cz>
References: <20161117191138.22769-1-hannes@cmpxchg.org>
 <20161117193021.GB23430@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161117193021.GB23430@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, "Kirill A. Shutemov" <kirill@shutemov.name>, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Thu 17-11-16 14:30:21, Johannes Weiner wrote:
> The bug in khugepaged fixed earlier in this series shows that radix
> tree slot replacement is fragile; and it will become more so when not
> only NULL<->!NULL transitions need to be caught but transitions from
> and to exceptional entries as well. We need checks.
> 
> Re-implement radix_tree_replace_slot() on top of the sanity-checked
> __radix_tree_replace(). This requires existing callers to also pass
> the radix tree root, but it'll warn us when somebody replaces slots
> with contents that need proper accounting (transitions between NULL
> entries, real entries, exceptional entries) and where a replacement
> through the slot pointer would corrupt the radix tree node counts.
> 
> Suggested-by: Jan Kara <jack@suse.cz>
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

Looks good. You can add:

Reviewed-by: Jan Kara <jack@suse.cz>

One nit below:

> @@ -785,6 +776,50 @@ void __radix_tree_replace(struct radix_tree_root *root,
>  }
>  
>  /**
> + * __radix_tree_replace		- replace item in a slot
> + * @root:	radix tree root
> + * @node:	pointer to tree node
> + * @slot:	pointer to slot in @node
> + * @item:	new item to store in the slot.
> + *
> + * For use with __radix_tree_lookup().  Caller must hold tree write locked
> + * across slot lookup and replacement.
> + */

I'd comment here that even this function cannot be used for NULL <->
non-NULL replacements. For that are radix_tree_delete() and
radix_tree_insert().

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
