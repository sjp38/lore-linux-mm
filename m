Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id D903F6B01B2
	for <linux-mm@kvack.org>; Mon, 28 Jun 2010 09:55:29 -0400 (EDT)
Subject: Re: [PATCH] avoid return NULL on root rb_node in rb_next/rb_prev
 in lib/rbtree.c
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <AANLkTilJDrpoFGyTSrKg3Hg59u9TvBLbxk4HAVKBvjxQ@mail.gmail.com>
References: <AANLkTilJDrpoFGyTSrKg3Hg59u9TvBLbxk4HAVKBvjxQ@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Date: Mon, 28 Jun 2010 15:55:20 +0200
Message-ID: <1277733320.3561.50.camel@laptop>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
To: shenghui <crosslonelyover@gmail.com>
Cc: kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org, Greg KH <greg@kroah.com>, linux-mm@kvack.org, mingo@elte.hu
List-ID: <linux-mm.kvack.org>

On Mon, 2010-06-28 at 21:17 +0800, shenghui wrote:
> Hi,
>=20
>        I'm reading cfs code, and get the following potential bug.
>=20
> In kernel/sched_fair.c, we can get the following call thread:
>=20
> 1778static struct task_struct *pick_next_task_fair(struct rq *rq)
> 1779{
> ...
> 1787        do {
> 1788                se =3D pick_next_entity(cfs_rq);
> 1789                set_next_entity(cfs_rq, se);
> 1790                cfs_rq =3D group_cfs_rq(se);
> 1791        } while (cfs_rq);
> ...
> 1797}
>=20
>  925static struct sched_entity *pick_next_entity(struct cfs_rq *cfs_rq)
>  926{
>  927        struct sched_entity *se =3D __pick_next_entity(cfs_rq);
> ...
>  941        return se;
>  942}
>=20
>  377static struct sched_entity *__pick_next_entity(struct cfs_rq *cfs_rq)
>  378{
>  379        struct rb_node *left =3D cfs_rq->rb_leftmost;
>  380
>  381        if (!left)
>  382                return NULL;
>  ...
>  385}
>=20
> To manipulate cfs_rq->rb_leftmost, __dequeue_entity does the following:
>=20
>  365static void __dequeue_entity(struct cfs_rq *cfs_rq, struct sched_enti=
ty *se)
>  366{
>  367        if (cfs_rq->rb_leftmost =3D=3D &se->run_node) {
>  368                struct rb_node *next_node;
>  369
>  370                next_node =3D rb_next(&se->run_node);
>  371                cfs_rq->rb_leftmost =3D next_node;
>  372        }
>  373
>  374        rb_erase(&se->run_node, &cfs_rq->tasks_timeline);
>  375}
>=20
> Here, if se->run_node is the root rb_node, next_node will be set NULL
> by rb_next.
> Then __pick_next_entity may get NULL on some call, and set_next_entity
> may deference
> NULL value.

So if ->rb_leftmost is NULL, then the if (!left) check in
__pick_next_entity() would return null.

As to the NULL deref in in pick_next_task_fair()->set_next_entity() that
should never happen because pick_next_task_fair() will bail
on !->nr_running.

Furthermore, you've failed to mention what kernel version you're looking
at.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
