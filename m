Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx179.postini.com [74.125.245.179])
	by kanga.kvack.org (Postfix) with SMTP id 588926B0044
	for <linux-mm@kvack.org>; Mon,  6 Aug 2012 10:18:00 -0400 (EDT)
Message-ID: <1344262669.27828.55.camel@twins>
Subject: Re: [PATCH v2 8/9] rbtree: faster augmented rbtree manipulation
From: Peter Zijlstra <peterz@infradead.org>
Date: Mon, 06 Aug 2012 16:17:49 +0200
In-Reply-To: <1343946858-8170-9-git-send-email-walken@google.com>
References: <1343946858-8170-1-git-send-email-walken@google.com>
	 <1343946858-8170-9-git-send-email-walken@google.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: quoted-printable
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michel Lespinasse <walken@google.com>
Cc: riel@redhat.com, daniel.santos@pobox.com, aarcange@redhat.com, dwmw2@infradead.org, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, torvalds@linux-foundation.org

On Thu, 2012-08-02 at 15:34 -0700, Michel Lespinasse wrote:
> +static void augment_propagate(struct rb_node *rb, struct rb_node *stop)
> +{
> +       while (rb !=3D stop) {
> +               struct interval_tree_node *node =3D
> +                       rb_entry(rb, struct interval_tree_node, rb);
> +               unsigned long subtree_last =3D compute_subtree_last(node)=
;
> +               if (node->__subtree_last =3D=3D subtree_last)
> +                       break;
> +               node->__subtree_last =3D subtree_last;
> +               rb =3D rb_parent(&node->rb);
> +       }
> +}
> +
> +static void augment_copy(struct rb_node *rb_old, struct rb_node *rb_new)
> +{
> +       struct interval_tree_node *old =3D
> +               rb_entry(rb_old, struct interval_tree_node, rb);
> +       struct interval_tree_node *new =3D
> +               rb_entry(rb_new, struct interval_tree_node, rb);
> +
> +       new->__subtree_last =3D old->__subtree_last;
> +}
> +
> +static void augment_rotate(struct rb_node *rb_old, struct rb_node *rb_ne=
w)
> +{
> +       struct interval_tree_node *old =3D
> +               rb_entry(rb_old, struct interval_tree_node, rb);
> +       struct interval_tree_node *new =3D
> +               rb_entry(rb_new, struct interval_tree_node, rb);
> +
> +       new->__subtree_last =3D old->__subtree_last;
> +       old->__subtree_last =3D compute_subtree_last(old);
> +}=20

I still don't get why we need the 3 callbacks when both propagate and
rotate are simple variants of the original callback
(compute_subtree_last, in this instance).

Why would every user need to replicate the propagate and rotate
boilerplate?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
