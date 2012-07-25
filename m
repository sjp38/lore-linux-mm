Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx196.postini.com [74.125.245.196])
	by kanga.kvack.org (Postfix) with SMTP id 177866B004D
	for <linux-mm@kvack.org>; Wed, 25 Jul 2012 12:12:06 -0400 (EDT)
Message-ID: <50101A77.3070407@redhat.com>
Date: Wed, 25 Jul 2012 12:10:31 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 4/6] rbtree: faster augmented insert
References: <1342787467-5493-1-git-send-email-walken@google.com> <1342787467-5493-5-git-send-email-walken@google.com>
In-Reply-To: <1342787467-5493-5-git-send-email-walken@google.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michel Lespinasse <walken@google.com>
Cc: peterz@infradead.org, daniel.santos@pobox.com, aarcange@redhat.com, dwmw2@infradead.org, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 07/20/2012 08:31 AM, Michel Lespinasse wrote:

> +++ b/lib/rbtree.c
> @@ -88,7 +88,8 @@ __rb_rotate_set_parents(struct rb_node *old, struct rb_node *new,
>   		root->rb_node = new;
>   }
>
> -void rb_insert_color(struct rb_node *node, struct rb_root *root)
> +inline void rb_insert_augmented(struct rb_node *node, struct rb_root *root,
> +				rb_augment_rotate *augment)
>   {
>   	struct rb_node *parent = rb_red_parent(node), *gparent, *tmp;
>
> @@ -152,6 +153,7 @@ void rb_insert_color(struct rb_node *node, struct rb_root *root)
>   					rb_set_parent_color(tmp, parent,
>   							    RB_BLACK);
>   				rb_set_parent_color(parent, node, RB_RED);
> +				augment(parent, node);

> +static inline void dummy(struct rb_node *old, struct rb_node *new) {}
> +
> +void rb_insert_color(struct rb_node *node, struct rb_root *root) {
> +	rb_insert_augmented(node, root, dummy);
> +}
>   EXPORT_SYMBOL(rb_insert_color);

While the above is what I would have done, the
question remains "what if the compiler decides
to not inline the function after all, and does
not remove the call to the dummy function in
rb_insert_color as a result?

Do we have some way to force inlining, so the
compiler is more likely to optimize out the
dummy call?

>   static void __rb_erase_color(struct rb_node *node, struct rb_node *parent,
> diff --git a/lib/rbtree_test.c b/lib/rbtree_test.c
> index 2dfafe4..5ace332 100644
> --- a/lib/rbtree_test.c
> +++ b/lib/rbtree_test.c
> @@ -67,22 +67,37 @@ static void augment_callback(struct rb_node *rb, void *unused)
>   	node->augmented = augment_recompute(node);
>   }
>
> +static void augment_rotate(struct rb_node *rb_old, struct rb_node *rb_new)
> +{
> +	struct test_node *old = rb_entry(rb_old, struct test_node, rb);
> +	struct test_node *new = rb_entry(rb_new, struct test_node, rb);
> +
> +	/* Rotation doesn't change subtree's augmented value */
> +	new->augmented = old->augmented;
> +	old->augmented = augment_recompute(old);
> +}

Is it worth documenting that rb_old is always the
parent of rb_new (at least, it seems to be in this
patch) ?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
