Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx122.postini.com [74.125.245.122])
	by kanga.kvack.org (Postfix) with SMTP id 3FFDA6B004D
	for <linux-mm@kvack.org>; Fri, 27 Jul 2012 15:26:21 -0400 (EDT)
Message-ID: <1343417168.32120.38.camel@twins>
Subject: Re: [PATCH 4/6] rbtree: faster augmented insert
From: Peter Zijlstra <peterz@infradead.org>
Date: Fri, 27 Jul 2012 21:26:08 +0200
In-Reply-To: <1342787467-5493-5-git-send-email-walken@google.com>
References: <1342787467-5493-1-git-send-email-walken@google.com>
	 <1342787467-5493-5-git-send-email-walken@google.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: quoted-printable
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michel Lespinasse <walken@google.com>
Cc: riel@redhat.com, daniel.santos@pobox.com, aarcange@redhat.com, dwmw2@infradead.org, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, 2012-07-20 at 05:31 -0700, Michel Lespinasse wrote:
> --- a/lib/rbtree.c
> +++ b/lib/rbtree.c
> @@ -88,7 +88,8 @@ __rb_rotate_set_parents(struct rb_node *old, struct rb_=
node *new,
>                 root->rb_node =3D new;
>  }
> =20
> -void rb_insert_color(struct rb_node *node, struct rb_root *root)
> +inline void rb_insert_augmented(struct rb_node *node, struct rb_root *ro=
ot,
> +                               rb_augment_rotate *augment)

Daniel probably knows best, but I would have expected something like:

__always_inline void=20
__rb_insert(struct rb_node *node, struct rb_root *root,
	    const rb_augment_rotate *augment)

Where you force inline and use a const function pointer since GCC is
better with inlining them -- iirc, Daniel?

>  {
>         struct rb_node *parent =3D rb_red_parent(node), *gparent, *tmp;
> =20
> @@ -152,6 +153,7 @@ void rb_insert_color(struct rb_node *node, struct rb_=
root *root)
>                                         rb_set_parent_color(tmp, parent,
>                                                             RB_BLACK);
>                                 rb_set_parent_color(parent, node, RB_RED)=
;
> +                               augment(parent, node);

And possibly:
		if (augment)
			augment(parent, node);

>                                 parent =3D node;
>                                 tmp =3D node->rb_right;
>                         }


> +static inline void dummy(struct rb_node *old, struct rb_node *new) {}

That would obviate the need for the dummy..

> +void rb_insert_color(struct rb_node *node, struct rb_root *root) {

placed your { wrong..

> +       rb_insert_augmented(node, root, dummy);
> +}
>  EXPORT_SYMBOL(rb_insert_color);=20

And use Daniel's __flatten here, like:

void rb_insert_color(struct rb_node *node, struct rb_root *root)
__flatten
{
	__rb_insert(node, root, NULL);
}
EXPORT_SYMBOL(rb_insert_color);

void rb_insert_augmented(struct rb_node *node, struct rb_root *root,
			 const rb_augment_rotate *augment) __flatten
{
	__rb_insert(node, root, augment);
}
EXPORT_SYMBOL(rb_insert_augmented);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
