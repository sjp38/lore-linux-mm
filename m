Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 2021F6B01FC
	for <linux-mm@kvack.org>; Fri, 16 Apr 2010 11:03:04 -0400 (EDT)
Received: by pvg11 with SMTP id 11so1670879pvg.14
        for <linux-mm@kvack.org>; Fri, 16 Apr 2010 08:03:02 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20100416111539.GC19264@csn.ul.ie>
References: <1270522777-9216-1-git-send-email-lliubbo@gmail.com>
	 <s2wcf18f8341004130120jc473e334pa6407b8d2e1ccf0a@mail.gmail.com>
	 <20100413083855.GS25756@csn.ul.ie>
	 <q2ycf18f8341004130728hf560f5cdpa8704b7031a0076d@mail.gmail.com>
	 <20100416111539.GC19264@csn.ul.ie>
Date: Fri, 16 Apr 2010 23:03:02 +0800
Message-ID: <o2kcf18f8341004160803v9663d602g8813b639024b5eca@mail.gmail.com>
Subject: Re: [PATCH] mempolicy:add GFP_THISNODE when allocing new page
From: Bob Liu <lliubbo@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: kamezawa.hiroyu@jp.fujitsu.com, minchan.kim@gmail.com, akpm@linux-foundation.org, linux-mm@kvack.org, andi@firstfloor.org, rientjes@google.com, lee.schermerhorn@hp.com, cl@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Fri, Apr 16, 2010 at 7:15 PM, Mel Gorman <mel@csn.ul.ie> wrote:
> On Tue, Apr 13, 2010 at 10:28:35PM +0800, Bob Liu wrote:
>> On Tue, Apr 13, 2010 at 4:38 PM, Mel Gorman <mel@csn.ul.ie> wrote:
>> > On Tue, Apr 13, 2010 at 04:20:53PM +0800, Bob Liu wrote:
>> >> On 4/6/10, Bob Liu <lliubbo@gmail.com> wrote:
>> >> > In funtion migrate_pages(), if the dest node have no
>> >> > enough free pages,it will fallback to other nodes.
>> >> > Add GFP_THISNODE to avoid this, the same as what
>> >> > funtion new_page_node() do in migrate.c.
>> >> >
>> >> > Signed-off-by: Bob Liu <lliubbo@gmail.com>
>> >> > ---
>> >> > =C2=A0mm/mempolicy.c | =C2=A0 =C2=A03 ++-
>> >> > =C2=A01 files changed, 2 insertions(+), 1 deletions(-)
>> >> >
>> >> > diff --git a/mm/mempolicy.c b/mm/mempolicy.c
>> >> > index 08f40a2..fc5ddf5 100644
>> >> > --- a/mm/mempolicy.c
>> >> > +++ b/mm/mempolicy.c
>> >> > @@ -842,7 +842,8 @@ static void migrate_page_add(struct page *page,=
 struct list_head *pagelist,
>> >> >
>> >> > =C2=A0static struct page *new_node_page(struct page *page, unsigned=
 long node, int **x)
>> >> > =C2=A0{
>> >> > - =C2=A0 =C2=A0 =C2=A0 return alloc_pages_exact_node(node, GFP_HIGH=
USER_MOVABLE, 0);
>> >> > + =C2=A0 =C2=A0 =C2=A0 return alloc_pages_exact_node(node,
>> >> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 GFP_HIGHUSER_MOVABLE | GFP_THISNO=
DE, 0);
>> >> > =C2=A0}
>> >> >
>> >>
>> >> Hi, Minchan and Kame
>> >> =C2=A0 =C2=A0 =C2=A0Would you please add ack or review to this thread=
. It's BUGFIX
>> >> and not change, so i don't resend one.
>> >>
>> >
>> > Sorry for taking so long to get around to this thread. I talked on thi=
s
>> > patch already but it's in another thread. Here is what I said there
>> >
>> > =3D=3D=3D=3D
>> > This appears to be a valid bug fix. =C2=A0I agree that the way things =
are structured
>> > that __GFP_THISNODE should be used in new_node_page(). But maybe a fol=
low-on
>> > patch is also required. The behaviour is now;
>> >
>> > o new_node_page will not return NULL if the target node is empty (fine=
).
>> > o migrate_pages will translate this into -ENOMEM (fine)
>> > o do_migrate_pages breaks early if it gets -ENOMEM ?
>> >
>> > It's the last part I'd like you to double check. migrate_pages() takes=
 a
>> > nodemask of allowed nodes to migrate to. Rather than sending this down
>> > to the allocator, it iterates over the nodes allowed in the mask. If o=
ne
>> > of those nodes is full, it returns -ENOMEM.
>> >
>> > If -ENOMEM is returned from migrate_pages, should it not move to the
>> > next node?
>> > =3D=3D=3D=3D
>>
>> Hm.I think early return is ok but not sure about it :)
>>
>> As Christoph said
>> "The intended semantic is the preservation of the relative position of t=
he
>> page to the beginning of the node set."
>> "F.e. if you use page
>> migration (or cpuset automigration) to shift an application running on 1=
0
>> nodes up by two nodes to make a hole that would allow you to run another
>> application on the lower nodes. Applications place pages intentionally o=
n
>> certain nodes to be able to manage memory distances."
>>
>> If move to the next node instead of early return, the relative position =
of the
>> page to the beginning of the node set will be break;
>>
>
> Yeah, but the user requested that a number of nodes to be used. Sure, if =
the
> first node is not free, a page will be allocated on the second node inste=
ad
> but is that not what was requested? If the user wanted one and only one
> node to be used, they wouldn't have specified multiple nodes. I'm not
> convinced an early return is what was intended here.
>

Hmm.
What about this change? If the from_nodes and to_nodes' weight is different=
,
then we can don't preserv of the relative position of the page to the begin=
ning
of the node set. This case if a page allocation from the dest node
failed, it will
be allocated from the next node instead of early return.

diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 08f40a2..094d092 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -842,7 +842,8 @@ static void migrate_page_add(struct page *page,
struct list_head *pagelist,

 static struct page *new_node_page(struct page *page, unsigned long
node, int **x)
 {
-       return alloc_pages_exact_node(node, GFP_HIGHUSER_MOVABLE, 0);
+       return alloc_pages_exact_node(node,
+                       GFP_HIGHUSER_MOVABLE | GFP_THISNODE, 0);
 }

 /*
@@ -945,10 +946,26 @@ int do_migrate_pages(struct mm_struct *mm,

                node_clear(source, tmp);
                err =3D migrate_to_node(mm, source, dest, flags);
+retry:
                if (err > 0)
                        busy +=3D err;
-               if (err < 0)
+               if (err < 0) {
+                       /*
+                        * If the dest node have no enough memory, and
from_nodes
+                        * to_nodes have no equal weight(don't need
protect offset.)
+                        * try to migrate to next node.
+                        */
+                       if((nodes_weight(*from_nodes) !=3D
nodes_weight(*to_nodes))
+                               && (err =3D=3D -ENOMEM)) {
+                               for_each_node_mask(s, *to_nodes) {
+                                       if(s !=3D dest) {
+                                               err =3D
migrate_to_node(mm, source, s, flags);
+                                               goto retry;
+                                       }
+                               }
+                       }
                        break;
+               }

Thanks !
--=20
Regards,
--Bob

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
