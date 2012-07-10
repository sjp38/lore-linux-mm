Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx190.postini.com [74.125.245.190])
	by kanga.kvack.org (Postfix) with SMTP id 2CEAB6B006C
	for <linux-mm@kvack.org>; Tue, 10 Jul 2012 08:27:36 -0400 (EDT)
Received: by eaan1 with SMTP id n1so5556702eaa.14
        for <linux-mm@kvack.org>; Tue, 10 Jul 2012 05:27:34 -0700 (PDT)
Content-Type: text/plain; charset=utf-8; format=flowed; delsp=yes
Subject: Re: [PATCH 05/13] rbtree: performance and correctness test
References: <1341876923-12469-1-git-send-email-walken@google.com>
 <1341876923-12469-6-git-send-email-walken@google.com>
Date: Tue, 10 Jul 2012 14:27:32 +0200
MIME-Version: 1.0
Content-Transfer-Encoding: Quoted-Printable
From: "Michal Nazarewicz" <mina86@mina86.com>
Message-ID: <op.wg8cv6x53l0zgt@mpn-glaptop>
In-Reply-To: <1341876923-12469-6-git-send-email-walken@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: aarcange@redhat.com, dwmw2@infradead.org, riel@redhat.com, peterz@infradead.org, daniel.santos@pobox.com, axboe@kernel.dk, ebiederm@xmission.com, Michel Lespinasse <walken@google.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, torvalds@linux-foundation.org

On Tue, 10 Jul 2012 01:35:15 +0200, Michel Lespinasse <walken@google.com=
> wrote:

> This small module helps measure the performance of rbtree insert and e=
rase.
>
> Additionally, we run a few correctness tests to check that the rbtrees=
 have
> all desired properties:
> - contains the right number of nodes in the order desired,
> - never two consecutive red nodes on any path,
> - all paths to leaf nodes have the same number of black nodes,
> - root node is black
>
> Signed-off-by: Michel Lespinasse <walken@google.com>
> ---
>  tests/rbtree_test.c |  135 ++++++++++++++++++++++++++++++++++++++++++=
+++++++++
>  1 files changed, 135 insertions(+), 0 deletions(-)
>  create mode 100644 tests/rbtree_test.c
>
> diff --git a/tests/rbtree_test.c b/tests/rbtree_test.c
> new file mode 100644
> index 0000000..2e3944d
> --- /dev/null
> +++ b/tests/rbtree_test.c
> @@ -0,0 +1,135 @@
> +#include <linux/module.h>
> +#include <linux/rbtree.h>
> +#include <linux/random.h>
> +#include <asm/timex.h>
> +
> +#define NODES       100
> +#define PERF_LOOPS  100000
> +#define CHECK_LOOPS 100
> +
> +struct test_node {
> +	struct rb_node rb;
> +	u32 key;
> +};
> +
> +static struct rb_root root =3D RB_ROOT;
> +static struct test_node nodes[NODES];
> +
> +static struct rnd_state rnd;
> +
> +static void insert(struct test_node *node, struct rb_root *root)
> +{
> +	struct rb_node **new =3D &root->rb_node, *parent =3D NULL;
> +
> +	while (*new) {
> +		parent =3D *new;
> +		if (node->key < rb_entry(parent, struct test_node, rb)->key)
> +			new =3D &parent->rb_left;
> +		else
> +			new =3D &parent->rb_right;
> +	}
> +
> +	rb_link_node(&node->rb, parent, new);
> +	rb_insert_color(&node->rb, root);
> +}
> +
> +static inline void erase(struct test_node *node, struct rb_root *root=
)
> +{
> +	rb_erase(&node->rb, root);
> +}
> +
> +static void init(void)
> +{
> +	int i;
> +	for (i =3D 0; i < NODES; i++)

s/NODES/ARRAY_SIZE(nodes)/ perhaps?  Same goes for the rest of the code.=


> +		nodes[i].key =3D prandom32(&rnd);
> +}
> +
> +static bool is_red(struct rb_node *rb)
> +{
> +	return rb->rb_parent_color =3D=3D (unsigned long)rb_parent(rb);

Why not !(rb->rb_parent_color & 1) which to me seems more intuitive.

> +}
> +
> +static int black_path_count(struct rb_node *rb)
> +{
> +	int count;
> +	for (count =3D 0; rb; rb =3D rb_parent(rb))
> +		count +=3D !is_red(rb);
> +	return count;
> +}
> +
> +static void check(int nr_nodes)
> +{
> +	struct rb_node *rb;
> +	int count =3D 0;
> +	int blacks;
> +	u32 prev_key =3D 0;
> +
> +	for (rb =3D rb_first(&root); rb; rb =3D rb_next(rb)) {
> +		struct test_node *node =3D rb_entry(rb, struct test_node, rb);
> +		WARN_ON_ONCE(node->key < prev_key);

What if for some reason we generate node with key equal zero or two keys=

with the same value?  It may not be the case for current code, but someo=
ne
might change it in the future.  I think <=3D is safer here.

> +		WARN_ON_ONCE(is_red(rb) &&
> +			     (!rb_parent(rb) || is_red(rb_parent(rb))));
> +		if (!count)
> +			blacks =3D black_path_count(rb);
> +		else
> +			WARN_ON_ONCE((!rb->rb_left || !rb->rb_right) &&
> +				     blacks !=3D black_path_count(rb));
> +		prev_key =3D node->key;
> +		count++;
> +	}
> +	WARN_ON_ONCE(count !=3D nr_nodes);
> +}
> +
> +static int rbtree_test_init(void)
> +{
> +	int i, j;
> +	cycles_t time1, time2, time;
> +
> +	printk(KERN_ALERT "rbtree testing");
> +
> +	prandom32_seed(&rnd, 3141592653589793238);
> +	init();
> +
> +	time1 =3D get_cycles();
> +
> +	for (i =3D 0; i < PERF_LOOPS; i++) {
> +		for (j =3D 0; j < NODES; j++)
> +			insert(nodes + j, &root);
> +		for (j =3D 0; j < NODES; j++)
> +			erase(nodes + j, &root);
> +	}
> +
> +	time2 =3D get_cycles();
> +	time =3D time2 - time1;
> +
> +	time =3D div_u64(time, PERF_LOOPS);
> +	printk(" -> %llu cycles\n", time);
> +
> +	for (i =3D 0; i < CHECK_LOOPS; i++) {
> +		init();

Is this init() needed?

> +		for (j =3D 0; j < NODES; j++) {
> +			check(j);
> +			insert(nodes + j, &root);
> +		}
> +		for (j =3D 0; j < NODES; j++) {
> +			check(NODES - j);
> +			erase(nodes + j, &root);
> +		}
> +		check(0);
> +	}
> +
> +	return -EAGAIN; /* Fail will directly unload the module */
> +}

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
