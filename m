Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id C18A86B01E3
	for <linux-mm@kvack.org>; Tue, 13 Apr 2010 10:28:37 -0400 (EDT)
Received: by pvg11 with SMTP id 11so3818734pvg.14
        for <linux-mm@kvack.org>; Tue, 13 Apr 2010 07:28:35 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20100413083855.GS25756@csn.ul.ie>
References: <1270522777-9216-1-git-send-email-lliubbo@gmail.com>
	 <s2wcf18f8341004130120jc473e334pa6407b8d2e1ccf0a@mail.gmail.com>
	 <20100413083855.GS25756@csn.ul.ie>
Date: Tue, 13 Apr 2010 22:28:35 +0800
Message-ID: <q2ycf18f8341004130728hf560f5cdpa8704b7031a0076d@mail.gmail.com>
Subject: Re: [PATCH] mempolicy:add GFP_THISNODE when allocing new page
From: Bob Liu <lliubbo@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: kamezawa.hiroyu@jp.fujitsu.com, minchan.kim@gmail.com, akpm@linux-foundation.org, linux-mm@kvack.org, andi@firstfloor.org, rientjes@google.com, lee.schermerhorn@hp.com, cl@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Tue, Apr 13, 2010 at 4:38 PM, Mel Gorman <mel@csn.ul.ie> wrote:
> On Tue, Apr 13, 2010 at 04:20:53PM +0800, Bob Liu wrote:
>> On 4/6/10, Bob Liu <lliubbo@gmail.com> wrote:
>> > In funtion migrate_pages(), if the dest node have no
>> > enough free pages,it will fallback to other nodes.
>> > Add GFP_THISNODE to avoid this, the same as what
>> > funtion new_page_node() do in migrate.c.
>> >
>> > Signed-off-by: Bob Liu <lliubbo@gmail.com>
>> > ---
>> > =C2=A0mm/mempolicy.c | =C2=A0 =C2=A03 ++-
>> > =C2=A01 files changed, 2 insertions(+), 1 deletions(-)
>> >
>> > diff --git a/mm/mempolicy.c b/mm/mempolicy.c
>> > index 08f40a2..fc5ddf5 100644
>> > --- a/mm/mempolicy.c
>> > +++ b/mm/mempolicy.c
>> > @@ -842,7 +842,8 @@ static void migrate_page_add(struct page *page, st=
ruct list_head *pagelist,
>> >
>> > =C2=A0static struct page *new_node_page(struct page *page, unsigned lo=
ng node, int **x)
>> > =C2=A0{
>> > - =C2=A0 =C2=A0 =C2=A0 return alloc_pages_exact_node(node, GFP_HIGHUSE=
R_MOVABLE, 0);
>> > + =C2=A0 =C2=A0 =C2=A0 return alloc_pages_exact_node(node,
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 GFP_HIGHUSER_MOVABLE | GFP_THISNODE,=
 0);
>> > =C2=A0}
>> >
>>
>> Hi, Minchan and Kame
>> =C2=A0 =C2=A0 =C2=A0Would you please add ack or review to this thread. I=
t's BUGFIX
>> and not change, so i don't resend one.
>>
>
> Sorry for taking so long to get around to this thread. I talked on this
> patch already but it's in another thread. Here is what I said there
>
> =3D=3D=3D=3D
> This appears to be a valid bug fix. =C2=A0I agree that the way things are=
 structured
> that __GFP_THISNODE should be used in new_node_page(). But maybe a follow=
-on
> patch is also required. The behaviour is now;
>
> o new_node_page will not return NULL if the target node is empty (fine).
> o migrate_pages will translate this into -ENOMEM (fine)
> o do_migrate_pages breaks early if it gets -ENOMEM ?
>
> It's the last part I'd like you to double check. migrate_pages() takes a
> nodemask of allowed nodes to migrate to. Rather than sending this down
> to the allocator, it iterates over the nodes allowed in the mask. If one
> of those nodes is full, it returns -ENOMEM.
>
> If -ENOMEM is returned from migrate_pages, should it not move to the
> next node?
> =3D=3D=3D=3D

Hm.I think early return is ok but not sure about it :)

As Christoph said
"The intended semantic is the preservation of the relative position of the
page to the beginning of the node set."
"F.e. if you use page
migration (or cpuset automigration) to shift an application running on 10
nodes up by two nodes to make a hole that would allow you to run another
application on the lower nodes. Applications place pages intentionally on
certain nodes to be able to manage memory distances."

If move to the next node instead of early return, the relative position of =
the
page to the beginning of the node set will be break;

(BTW:I am still not very clear about the preservation of the relative
position of the
page to the beginning of the node set. I think if the user call
migrate_pages() with
different count of src and dest nodes, the  relative position will also bre=
ak.
eg. if call migrate_pags() from nodes is node(1,2,3) , dest nodes is
just node(3).
the current code logical will move pages in node 1, 2 to node 3. this case =
the
relative position is breaked).

Add Christoph  to cc.

>
> My concern before acking this patch is that the function might be exiting
> too early when given a set of nodes. Granted, because __GFP_THISNODE is n=
ot
> specified, it's perfectly possible that migration is currently moving pag=
es
> to the wrong node which is also very bad.
>
>> =C2=A0 =C2=A0 =C2=A0About code clean, there should be some new CLEANUP p=
atches or
>> just don't make any changes decided after we finish before
>> discussions.
>>
>
> Cleanup patches can be sent separately. I might be biased against a funct=
ion
> rename but the bugfix is more important.
>

Thanks!

--=20
Regards,
--Bob

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
