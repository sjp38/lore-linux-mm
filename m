Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id C9C0E6B01EF
	for <linux-mm@kvack.org>; Sat, 17 Apr 2010 09:54:33 -0400 (EDT)
Received: by pvg11 with SMTP id 11so2215427pvg.14
        for <linux-mm@kvack.org>; Sat, 17 Apr 2010 06:54:32 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.00.1004161049130.7710@router.home>
References: <1270522777-9216-1-git-send-email-lliubbo@gmail.com>
	 <s2wcf18f8341004130120jc473e334pa6407b8d2e1ccf0a@mail.gmail.com>
	 <20100413083855.GS25756@csn.ul.ie>
	 <q2ycf18f8341004130728hf560f5cdpa8704b7031a0076d@mail.gmail.com>
	 <20100416111539.GC19264@csn.ul.ie>
	 <o2kcf18f8341004160803v9663d602g8813b639024b5eca@mail.gmail.com>
	 <alpine.DEB.2.00.1004161049130.7710@router.home>
Date: Sat, 17 Apr 2010 21:54:31 +0800
Message-ID: <m2vcf18f8341004170654tc743e4b0s73a0e234cfdcda93@mail.gmail.com>
Subject: Re: [PATCH] mempolicy:add GFP_THISNODE when allocing new page
From: Bob Liu <lliubbo@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Mel Gorman <mel@csn.ul.ie>, kamezawa.hiroyu@jp.fujitsu.com, minchan.kim@gmail.com, akpm@linux-foundation.org, linux-mm@kvack.org, andi@firstfloor.org, rientjes@google.com, lee.schermerhorn@hp.com
List-ID: <linux-mm.kvack.org>

On Fri, Apr 16, 2010 at 11:55 PM, Christoph Lameter
<cl@linux-foundation.org> wrote:
> On Fri, 16 Apr 2010, Bob Liu wrote:
>
>> Hmm.
>> What about this change? If the from_nodes and to_nodes' weight is differ=
ent,
>> then we can don't preserv of the relative position of the page to the be=
ginning
>> of the node set. This case if a page allocation from the dest node
>> failed, it will
>> be allocated from the next node instead of early return.
>
> Understand what you are doing first. The fallback is already there.
>
>> diff --git a/mm/mempolicy.c b/mm/mempolicy.c
>> index 08f40a2..094d092 100644
>> --- a/mm/mempolicy.c
>> +++ b/mm/mempolicy.c
>> @@ -842,7 +842,8 @@ static void migrate_page_add(struct page *page,
>> struct list_head *pagelist,
>>
>> =C2=A0static struct page *new_node_page(struct page *page, unsigned long
>> node, int **x)
>> =C2=A0{
>> - =C2=A0 =C2=A0 =C2=A0 return alloc_pages_exact_node(node, GFP_HIGHUSER_=
MOVABLE, 0);
>> + =C2=A0 =C2=A0 =C2=A0 return alloc_pages_exact_node(node,
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 GFP_HIGHUSER_MOVABLE | GFP_THISNODE, 0);
>
> You eliminate falling back to the next node?
>
> GFP_THISNODE forces allocation from the node. Without it we will fallback=
.
>

Yeah, but I think we shouldn't fallback at this case, what we want is
alloc a page
from exactly the dest node during migrate_to_node(dest).So I added
GFP_THISNODE.

And mel concerned that
=3D=3D=3D=3D
This appears to be a valid bug fix.  I agree that the way things are struct=
ured
that __GFP_THISNODE should be used in new_node_page(). But maybe a follow-o=
n
patch is also required. The behaviour is now;

o new_node_page will not return NULL if the target node is empty (fine).
o migrate_pages will translate this into -ENOMEM (fine)
o do_migrate_pages breaks early if it gets -ENOMEM ?

It's the last part I'd like you to double check. migrate_pages() takes a
nodemask of allowed nodes to migrate to. Rather than sending this down
to the allocator, it iterates over the nodes allowed in the mask. If one
of those nodes is full, it returns -ENOMEM.

If -ENOMEM is returned from migrate_pages, should it not move to the
next node?
=3D=3D=3D=3D

In my opinion, when we want to preserve the relative position of the page t=
o
the beginning of the node set, early return is ok. Else should try to alloc=
 the
new page from the next node(to_nodes).

So I added retry path to allocate new page from next node only when
from_nodes' weight is different from to_nodes', this case the user should
konw the relative position of the page to the beginning of the node set
can be changed.

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

Thanks!
--=20
Regards,
--Bob

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
