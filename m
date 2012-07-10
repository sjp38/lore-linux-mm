Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx121.postini.com [74.125.245.121])
	by kanga.kvack.org (Postfix) with SMTP id BA0FB6B006C
	for <linux-mm@kvack.org>; Tue, 10 Jul 2012 08:19:25 -0400 (EDT)
Received: by eaan1 with SMTP id n1so5553081eaa.14
        for <linux-mm@kvack.org>; Tue, 10 Jul 2012 05:19:24 -0700 (PDT)
Content-Type: text/plain; charset=utf-8; format=flowed; delsp=yes
Subject: Re: [PATCH 04/13] rbtree: move some implementation details from
 rbtree.h to rbtree.c
References: <1341876923-12469-1-git-send-email-walken@google.com>
 <1341876923-12469-5-git-send-email-walken@google.com>
Date: Tue, 10 Jul 2012 14:19:20 +0200
MIME-Version: 1.0
Content-Transfer-Encoding: Quoted-Printable
From: "Michal Nazarewicz" <mina86@mina86.com>
Message-ID: <op.wg8ciikk3l0zgt@mpn-glaptop>
In-Reply-To: <1341876923-12469-5-git-send-email-walken@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: aarcange@redhat.com, dwmw2@infradead.org, riel@redhat.com, peterz@infradead.org, daniel.santos@pobox.com, axboe@kernel.dk, ebiederm@xmission.com, Michel Lespinasse <walken@google.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, torvalds@linux-foundation.org

On Tue, 10 Jul 2012 01:35:14 +0200, Michel Lespinasse <walken@google.com=
> wrote:

> rbtree users must use the documented APIs to manipulate the tree
> structure.  Low-level helpers to manipulate node colors and parenthood=

> are not part of that API, so move them to lib/rbtree.c
>
> Signed-off-by: Michel Lespinasse <walken@google.com>
> ---
>  include/linux/rbtree.h |   16 ----------------
>  lib/rbtree.c           |   18 ++++++++++++++++++
>  2 files changed, 18 insertions(+), 16 deletions(-)
>
> diff --git a/include/linux/rbtree.h b/include/linux/rbtree.h
> index 2049087..a06c044 100644
> --- a/include/linux/rbtree.h
> +++ b/include/linux/rbtree.h
> @@ -35,8 +35,6 @@
>  struct rb_node
>  {
>  	unsigned long  rb_parent_color;
> -#define	RB_RED		0
> -#define	RB_BLACK	1
>  	struct rb_node *rb_right;
>  	struct rb_node *rb_left;
>  } __attribute__((aligned(sizeof(long))));
> @@ -49,20 +47,6 @@ struct rb_root
> #define rb_parent(r)   ((struct rb_node *)((r)->rb_parent_color & ~3))=

> -#define rb_color(r)   ((r)->rb_parent_color & 1)
> -#define rb_is_red(r)   (!rb_color(r))
> -#define rb_is_black(r) rb_color(r)
> -#define rb_set_red(r)  do { (r)->rb_parent_color &=3D ~1; } while (0)=

> -#define rb_set_black(r)  do { (r)->rb_parent_color |=3D 1; } while (0=
)
> -
> -static inline void rb_set_parent(struct rb_node *rb, struct rb_node *=
p)
> -{
> -	rb->rb_parent_color =3D (rb->rb_parent_color & 3) | (unsigned long)p=
;
> -}
> -static inline void rb_set_color(struct rb_node *rb, int color)
> -{
> -	rb->rb_parent_color =3D (rb->rb_parent_color & ~1) | color;
> -}
> #define RB_ROOT	(struct rb_root) { NULL, }
>  #define	rb_entry(ptr, type, member) container_of(ptr, type, member)
> diff --git a/lib/rbtree.c b/lib/rbtree.c
> index fe43c8c..d0ec339 100644
> --- a/lib/rbtree.c
> +++ b/lib/rbtree.c
> @@ -23,6 +23,24 @@
>  #include <linux/rbtree.h>
>  #include <linux/export.h>
>+#define	RB_RED		0
> +#define	RB_BLACK	1

Interestingly, those are almost never used. RB_BLACK is used only once.
Should we get rid of those instead?  Or change the code (like rb_is_red(=
))
to use them?

> +
> +#define rb_color(r)   ((r)->rb_parent_color & 1)
> +#define rb_is_red(r)   (!rb_color(r))
> +#define rb_is_black(r) rb_color(r)
> +#define rb_set_red(r)  do { (r)->rb_parent_color &=3D ~1; } while (0)=

> +#define rb_set_black(r)  do { (r)->rb_parent_color |=3D 1; } while (0=
)
> +
> +static inline void rb_set_parent(struct rb_node *rb, struct rb_node *=
p)
> +{
> +	rb->rb_parent_color =3D (rb->rb_parent_color & 3) | (unsigned long)p=
;
> +}
> +static inline void rb_set_color(struct rb_node *rb, int color)
> +{
> +	rb->rb_parent_color =3D (rb->rb_parent_color & ~1) | color;
> +}
> +
>  static void __rb_rotate_left(struct rb_node *node, struct rb_root *ro=
ot)
>  {
>  	struct rb_node *right =3D node->rb_right;


-- =

Best regards,                                         _     _
.o. | Liege of Serenely Enlightened Majesty of      o' \,=3D./ `o
..o | Computer Science,  Micha=C5=82 =E2=80=9Cmina86=E2=80=9D Nazarewicz=
    (o o)
ooo +----<email/xmpp: mpn@google.com>--------------ooO--(_)--Ooo--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
