Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f200.google.com (mail-ot0-f200.google.com [74.125.82.200])
	by kanga.kvack.org (Postfix) with ESMTP id E80586B027C
	for <linux-mm@kvack.org>; Wed, 15 Nov 2017 19:44:20 -0500 (EST)
Received: by mail-ot0-f200.google.com with SMTP id b49so8971360otj.11
        for <linux-mm@kvack.org>; Wed, 15 Nov 2017 16:44:20 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 109sor8059858otc.156.2017.11.15.16.44.19
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 15 Nov 2017 16:44:19 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CAGqmi77HCNiO=5Xc=c4CSHS1OioXX86bHynt560umsPZCu5n2A@mail.gmail.com>
References: <1510715958-9174-1-git-send-email-kyeongdon.kim@lge.com> <CAGqmi77HCNiO=5Xc=c4CSHS1OioXX86bHynt560umsPZCu5n2A@mail.gmail.com>
From: "Figo.zhang" <figo1802@gmail.com>
Date: Thu, 16 Nov 2017 08:44:18 +0800
Message-ID: <CAF7GXvrw3EV_GG5Nr6CC=o1Ei=8a7fHT-WOLzJzPo5t+-wAbVw@mail.gmail.com>
Subject: Re: [PATCH v2] ksm : use checksum and memcmp for rb_tree
Content-Type: multipart/alternative; boundary="001a113d0df0a29afe055e0eeb67"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Timofey Titovets <nefelim4ag@gmail.com>
Cc: Kyeongdon Kim <kyeongdon.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Minchan Kim <minchan@kernel.org>, broonie@kernel.org, Michal Hocko <mhocko@suse.com>, Ingo Molnar <mingo@kernel.org>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, Arvind Yadav <arvind.yadav.cs@gmail.com>, imbrenda@linux.vnet.ibm.com, kirill.shutemov@linux.intel.com, bongkyu.kim@lge.com, Linux MM <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.kernel.org>

--001a113d0df0a29afe055e0eeb67
Content-Type: text/plain; charset="UTF-8"

it seems violate the patent which hold by vmware, the patent is: US
6789156B1
the majority assertion  of this patent is that compare the content of
2 pages with HASH/Checksum  algorithm in operation system.

2017-11-16 5:25 GMT+08:00 Timofey Titovets <nefelim4ag@gmail.com>:

> Reviewed-by: Timofey Titovets <nefelim4ag@gmail.com>
>
> 2017-11-15 6:19 GMT+03:00 Kyeongdon Kim <kyeongdon.kim@lge.com>:
> > The current ksm is using memcmp to insert and search 'rb_tree'.
> > It does cause very expensive computation cost.
> > In order to reduce the time of this operation,
> > we have added a checksum to traverse.
> >
> > Nearly all 'rb_node' in stable_tree_insert() function
> > can be inserted as a checksum, most of it is possible
> > in unstable_tree_search_insert() function.
> > In stable_tree_search() function, the checksum may be an additional.
> > But, checksum check duration is extremely small.
> > Considering the time of the whole cmp_and_merge_page() function,
> > it requires very little cost on average.
> >
> > Using this patch, we compared the time of ksm_do_scan() function
> > by adding kernel trace at the start-end position of operation.
> > (ARM 32bit target android device,
> > over 1000 sample time gap stamps average)
> >
> > On original KSM scan avg duration = 0.0166893 sec
> > 14991.975619 : ksm_do_scan_start: START: ksm_do_scan
> > 14991.990975 : ksm_do_scan_end: END: ksm_do_scan
> > 14992.008989 : ksm_do_scan_start: START: ksm_do_scan
> > 14992.016839 : ksm_do_scan_end: END: ksm_do_scan
> > ...
> >
> > On patch KSM scan avg duration = 0.0041157 sec
> > 41081.46131 : ksm_do_scan_start : START: ksm_do_scan
> > 41081.46636 : ksm_do_scan_end : END: ksm_do_scan
> > 41081.48476 : ksm_do_scan_start : START: ksm_do_scan
> > 41081.48795 : ksm_do_scan_end : END: ksm_do_scan
> > ...
> >
> > We have tested randomly so many times for the stability
> > and couldn't see any abnormal issue until now.
> > Also, we found out this patch can make some good advantage
> > for the power consumption than KSM default enable.
> >
> > v1 -> v2
> > - add comment for oldchecksum value
> > - move the oldchecksum value out of union
> > - remove check code regarding checksum 0 in stable_tree_search()
> >
> > link to v1 : https://lkml.org/lkml/2017/10/30/251
> >
> > Signed-off-by: Kyeongdon Kim <kyeongdon.kim@lge.com>
> > ---
> >  mm/ksm.c | 48 ++++++++++++++++++++++++++++++++++++++++++++----
> >  1 file changed, 44 insertions(+), 4 deletions(-)
> >
> > diff --git a/mm/ksm.c b/mm/ksm.c
> > index be8f457..9280569 100644
> > --- a/mm/ksm.c
> > +++ b/mm/ksm.c
> > @@ -134,6 +134,7 @@ struct ksm_scan {
> >   * @kpfn: page frame number of this ksm page (perhaps temporarily on
> wrong nid)
> >   * @chain_prune_time: time of the last full garbage collection
> >   * @rmap_hlist_len: number of rmap_item entries in hlist or
> STABLE_NODE_CHAIN
> > + * @oldchecksum: previous checksum of the page about a stable_node
> >   * @nid: NUMA node id of stable tree in which linked (may not match
> kpfn)
> >   */
> >  struct stable_node {
> > @@ -159,6 +160,7 @@ struct stable_node {
> >          */
> >  #define STABLE_NODE_CHAIN -1024
> >         int rmap_hlist_len;
> > +       u32 oldchecksum;
> >  #ifdef CONFIG_NUMA
> >         int nid;
> >  #endif
> > @@ -1522,7 +1524,7 @@ static __always_inline struct page *chain(struct
> stable_node **s_n_d,
> >   * This function returns the stable tree node of identical content if
> found,
> >   * NULL otherwise.
> >   */
> > -static struct page *stable_tree_search(struct page *page)
> > +static struct page *stable_tree_search(struct page *page, u32 checksum)
> >  {
> >         int nid;
> >         struct rb_root *root;
> > @@ -1550,6 +1552,18 @@ static struct page *stable_tree_search(struct
> page *page)
> >
> >                 cond_resched();
> >                 stable_node = rb_entry(*new, struct stable_node, node);
> > +
> > +               /* first make rb_tree by checksum */
> > +               if (checksum < stable_node->oldchecksum) {
> > +                       parent = *new;
> > +                       new = &parent->rb_left;
> > +                       continue;
> > +               } else if (checksum > stable_node->oldchecksum) {
> > +                       parent = *new;
> > +                       new = &parent->rb_right;
> > +                       continue;
> > +               }
> > +
> >                 stable_node_any = NULL;
> >                 tree_page = chain_prune(&stable_node_dup, &stable_node,
> root);
> >                 /*
> > @@ -1768,7 +1782,7 @@ static struct page *stable_tree_search(struct page
> *page)
> >   * This function returns the stable tree node just allocated on success,
> >   * NULL otherwise.
> >   */
> > -static struct stable_node *stable_tree_insert(struct page *kpage)
> > +static struct stable_node *stable_tree_insert(struct page *kpage, u32
> checksum)
> >  {
> >         int nid;
> >         unsigned long kpfn;
> > @@ -1792,6 +1806,18 @@ static struct stable_node
> *stable_tree_insert(struct page *kpage)
> >                 cond_resched();
> >                 stable_node = rb_entry(*new, struct stable_node, node);
> >                 stable_node_any = NULL;
> > +
> > +               /* first make rb_tree by checksum */
> > +               if (checksum < stable_node->oldchecksum) {
> > +                       parent = *new;
> > +                       new = &parent->rb_left;
> > +                       continue;
> > +               } else if (checksum > stable_node->oldchecksum) {
> > +                       parent = *new;
> > +                       new = &parent->rb_right;
> > +                       continue;
> > +               }
> > +
> >                 tree_page = chain(&stable_node_dup, stable_node, root);
> >                 if (!stable_node_dup) {
> >                         /*
> > @@ -1850,6 +1876,7 @@ static struct stable_node
> *stable_tree_insert(struct page *kpage)
> >
> >         INIT_HLIST_HEAD(&stable_node_dup->hlist);
> >         stable_node_dup->kpfn = kpfn;
> > +       stable_node_dup->oldchecksum = checksum;
> >         set_page_stable_node(kpage, stable_node_dup);
> >         stable_node_dup->rmap_hlist_len = 0;
> >         DO_NUMA(stable_node_dup->nid = nid);
> > @@ -1907,6 +1934,19 @@ struct rmap_item *unstable_tree_search_insert(struct
> rmap_item *rmap_item,
> >
> >                 cond_resched();
> >                 tree_rmap_item = rb_entry(*new, struct rmap_item, node);
> > +
> > +               /* first make rb_tree by checksum */
> > +               if (rmap_item->oldchecksum <
> tree_rmap_item->oldchecksum) {
> > +                       parent = *new;
> > +                       new = &parent->rb_left;
> > +                       continue;
> > +               } else if (rmap_item->oldchecksum
> > +                                       > tree_rmap_item->oldchecksum) {
> > +                       parent = *new;
> > +                       new = &parent->rb_right;
> > +                       continue;
> > +               }
> > +
> >                 tree_page = get_mergeable_page(tree_rmap_item);
> >                 if (!tree_page)
> >                         return NULL;
> > @@ -2031,7 +2071,7 @@ static void cmp_and_merge_page(struct page *page,
> struct rmap_item *rmap_item)
> >         }
> >
> >         /* We first start with searching the page inside the stable tree
> */
> > -       kpage = stable_tree_search(page);
> > +       kpage = stable_tree_search(page, rmap_item->oldchecksum);
> >         if (kpage == page && rmap_item->head == stable_node) {
> >                 put_page(kpage);
> >                 return;
> > @@ -2098,7 +2138,7 @@ static void cmp_and_merge_page(struct page *page,
> struct rmap_item *rmap_item)
> >                          * node in the stable tree and add both
> rmap_items.
> >                          */
> >                         lock_page(kpage);
> > -                       stable_node = stable_tree_insert(kpage);
> > +                       stable_node = stable_tree_insert(kpage,
> checksum);
> >                         if (stable_node) {
> >                                 stable_tree_append(tree_rmap_item,
> stable_node,
> >                                                    false);
> > --
> > 2.6.2
> >
> > --
> > To unsubscribe, send a message with 'unsubscribe linux-mm' in
> > the body to majordomo@kvack.org.  For more info on Linux MM,
> > see: http://www.linux-mm.org/ .
> > Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>
>
>
> --
> Have a nice day,
> Timofey.
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>

--001a113d0df0a29afe055e0eeb67
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr">it seems=C2=A0violate=C2=A0the=C2=A0patent which hold by=
=C2=A0vmware, the patent is:=C2=A0<span lang=3D"EN-US" style=3D"font-size:1=
0.5pt;font-family:&quot;Times New Roman&quot;,serif">US 6789156B1</span><di=
v><font face=3D"Times New Roman, serif"><span style=3D"font-size:14px">the=
=C2=A0majority=C2=A0assertion=C2=A0 of this patent=C2=A0is that=C2=A0compar=
e the=C2=A0content of 2=C2=A0pages with HASH/Checksum =C2=A0algorithm in op=
eration=C2=A0system.</span></font></div></div><div class=3D"gmail_extra"><b=
r><div class=3D"gmail_quote">2017-11-16 5:25 GMT+08:00 Timofey Titovets <sp=
an dir=3D"ltr">&lt;<a href=3D"mailto:nefelim4ag@gmail.com" target=3D"_blank=
">nefelim4ag@gmail.com</a>&gt;</span>:<br><blockquote class=3D"gmail_quote"=
 style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex">Re=
viewed-by: Timofey Titovets &lt;<a href=3D"mailto:nefelim4ag@gmail.com">nef=
elim4ag@gmail.com</a>&gt;<br>
<div class=3D"HOEnZb"><div class=3D"h5"><br>
2017-11-15 6:19 GMT+03:00 Kyeongdon Kim &lt;<a href=3D"mailto:kyeongdon.kim=
@lge.com">kyeongdon.kim@lge.com</a>&gt;:<br>
&gt; The current ksm is using memcmp to insert and search &#39;rb_tree&#39;=
.<br>
&gt; It does cause very expensive computation cost.<br>
&gt; In order to reduce the time of this operation,<br>
&gt; we have added a checksum to traverse.<br>
&gt;<br>
&gt; Nearly all &#39;rb_node&#39; in stable_tree_insert() function<br>
&gt; can be inserted as a checksum, most of it is possible<br>
&gt; in unstable_tree_search_insert() function.<br>
&gt; In stable_tree_search() function, the checksum may be an additional.<b=
r>
&gt; But, checksum check duration is extremely small.<br>
&gt; Considering the time of the whole cmp_and_merge_page() function,<br>
&gt; it requires very little cost on average.<br>
&gt;<br>
&gt; Using this patch, we compared the time of ksm_do_scan() function<br>
&gt; by adding kernel trace at the start-end position of operation.<br>
&gt; (ARM 32bit target android device,<br>
&gt; over 1000 sample time gap stamps average)<br>
&gt;<br>
&gt; On original KSM scan avg duration =3D 0.0166893 sec<br>
&gt; 14991.975619 : ksm_do_scan_start: START: ksm_do_scan<br>
&gt; 14991.990975 : ksm_do_scan_end: END: ksm_do_scan<br>
&gt; 14992.008989 : ksm_do_scan_start: START: ksm_do_scan<br>
&gt; 14992.016839 : ksm_do_scan_end: END: ksm_do_scan<br>
&gt; ...<br>
&gt;<br>
&gt; On patch KSM scan avg duration =3D 0.0041157 sec<br>
&gt; 41081.46131 : ksm_do_scan_start : START: ksm_do_scan<br>
&gt; 41081.46636 : ksm_do_scan_end : END: ksm_do_scan<br>
&gt; 41081.48476 : ksm_do_scan_start : START: ksm_do_scan<br>
&gt; 41081.48795 : ksm_do_scan_end : END: ksm_do_scan<br>
&gt; ...<br>
&gt;<br>
&gt; We have tested randomly so many times for the stability<br>
&gt; and couldn&#39;t see any abnormal issue until now.<br>
&gt; Also, we found out this patch can make some good advantage<br>
&gt; for the power consumption than KSM default enable.<br>
&gt;<br>
&gt; v1 -&gt; v2<br>
&gt; - add comment for oldchecksum value<br>
&gt; - move the oldchecksum value out of union<br>
&gt; - remove check code regarding checksum 0 in stable_tree_search()<br>
&gt;<br>
&gt; link to v1 : <a href=3D"https://lkml.org/lkml/2017/10/30/251" rel=3D"n=
oreferrer" target=3D"_blank">https://lkml.org/lkml/2017/10/<wbr>30/251</a><=
br>
&gt;<br>
&gt; Signed-off-by: Kyeongdon Kim &lt;<a href=3D"mailto:kyeongdon.kim@lge.c=
om">kyeongdon.kim@lge.com</a>&gt;<br>
&gt; ---<br>
&gt;=C2=A0 mm/ksm.c | 48 ++++++++++++++++++++++++++++++<wbr>++++++++++++++-=
---<br>
&gt;=C2=A0 1 file changed, 44 insertions(+), 4 deletions(-)<br>
&gt;<br>
&gt; diff --git a/mm/ksm.c b/mm/ksm.c<br>
&gt; index be8f457..9280569 100644<br>
&gt; --- a/mm/ksm.c<br>
&gt; +++ b/mm/ksm.c<br>
&gt; @@ -134,6 +134,7 @@ struct ksm_scan {<br>
&gt;=C2=A0 =C2=A0* @kpfn: page frame number of this ksm page (perhaps tempo=
rarily on wrong nid)<br>
&gt;=C2=A0 =C2=A0* @chain_prune_time: time of the last full garbage collect=
ion<br>
&gt;=C2=A0 =C2=A0* @rmap_hlist_len: number of rmap_item entries in hlist or=
 STABLE_NODE_CHAIN<br>
&gt; + * @oldchecksum: previous checksum of the page about a stable_node<br=
>
&gt;=C2=A0 =C2=A0* @nid: NUMA node id of stable tree in which linked (may n=
ot match kpfn)<br>
&gt;=C2=A0 =C2=A0*/<br>
&gt;=C2=A0 struct stable_node {<br>
&gt; @@ -159,6 +160,7 @@ struct stable_node {<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 */<br>
&gt;=C2=A0 #define STABLE_NODE_CHAIN -1024<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0int rmap_hlist_len;<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0u32 oldchecksum;<br>
&gt;=C2=A0 #ifdef CONFIG_NUMA<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0int nid;<br>
&gt;=C2=A0 #endif<br>
&gt; @@ -1522,7 +1524,7 @@ static __always_inline struct page *chain(struct=
 stable_node **s_n_d,<br>
&gt;=C2=A0 =C2=A0* This function returns the stable tree node of identical =
content if found,<br>
&gt;=C2=A0 =C2=A0* NULL otherwise.<br>
&gt;=C2=A0 =C2=A0*/<br>
&gt; -static struct page *stable_tree_search(struct page *page)<br>
&gt; +static struct page *stable_tree_search(struct page *page, u32 checksu=
m)<br>
&gt;=C2=A0 {<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0int nid;<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0struct rb_root *root;<br>
&gt; @@ -1550,6 +1552,18 @@ static struct page *stable_tree_search(struct p=
age *page)<br>
&gt;<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0cond_resc=
hed();<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0stable_no=
de =3D rb_entry(*new, struct stable_node, node);<br>
&gt; +<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0/* first make =
rb_tree by checksum */<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (checksum &=
lt; stable_node-&gt;oldchecksum) {<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0parent =3D *new;<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0new =3D &amp;parent-&gt;rb_left;<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0continue;<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0} else if (che=
cksum &gt; stable_node-&gt;oldchecksum) {<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0parent =3D *new;<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0new =3D &amp;parent-&gt;rb_right;<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0continue;<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0}<br>
&gt; +<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0stable_no=
de_any =3D NULL;<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0tree_page=
 =3D chain_prune(&amp;stable_node_dup, &amp;stable_node, root);<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0/*<br>
&gt; @@ -1768,7 +1782,7 @@ static struct page *stable_tree_search(struct pa=
ge *page)<br>
&gt;=C2=A0 =C2=A0* This function returns the stable tree node just allocate=
d on success,<br>
&gt;=C2=A0 =C2=A0* NULL otherwise.<br>
&gt;=C2=A0 =C2=A0*/<br>
&gt; -static struct stable_node *stable_tree_insert(struct page *kpage)<br>
&gt; +static struct stable_node *stable_tree_insert(struct page *kpage, u32=
 checksum)<br>
&gt;=C2=A0 {<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0int nid;<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0unsigned long kpfn;<br>
&gt; @@ -1792,6 +1806,18 @@ static struct stable_node *stable_tree_insert(s=
truct page *kpage)<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0cond_resc=
hed();<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0stable_no=
de =3D rb_entry(*new, struct stable_node, node);<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0stable_no=
de_any =3D NULL;<br>
&gt; +<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0/* first make =
rb_tree by checksum */<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (checksum &=
lt; stable_node-&gt;oldchecksum) {<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0parent =3D *new;<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0new =3D &amp;parent-&gt;rb_left;<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0continue;<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0} else if (che=
cksum &gt; stable_node-&gt;oldchecksum) {<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0parent =3D *new;<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0new =3D &amp;parent-&gt;rb_right;<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0continue;<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0}<br>
&gt; +<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0tree_page=
 =3D chain(&amp;stable_node_dup, stable_node, root);<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (!stab=
le_node_dup) {<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0/*<br>
&gt; @@ -1850,6 +1876,7 @@ static struct stable_node *stable_tree_insert(st=
ruct page *kpage)<br>
&gt;<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0INIT_HLIST_HEAD(&amp;stable_node_<wbr=
>dup-&gt;hlist);<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0stable_node_dup-&gt;kpfn =3D kpfn;<br=
>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0stable_node_dup-&gt;oldchecksum =3D checks=
um;<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0set_page_stable_node(kpage, stable_no=
de_dup);<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0stable_node_dup-&gt;rmap_hlist_<wbr>l=
en =3D 0;<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0DO_NUMA(stable_node_dup-&gt;nid =3D n=
id);<br>
&gt; @@ -1907,6 +1934,19 @@ struct rmap_item *unstable_tree_search_insert(<=
wbr>struct rmap_item *rmap_item,<br>
&gt;<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0cond_resc=
hed();<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0tree_rmap=
_item =3D rb_entry(*new, struct rmap_item, node);<br>
&gt; +<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0/* first make =
rb_tree by checksum */<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (rmap_item-=
&gt;oldchecksum &lt; tree_rmap_item-&gt;oldchecksum) {<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0parent =3D *new;<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0new =3D &amp;parent-&gt;rb_left;<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0continue;<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0} else if (rma=
p_item-&gt;oldchecksum<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0&gt; =
tree_rmap_item-&gt;oldchecksum) {<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0parent =3D *new;<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0new =3D &amp;parent-&gt;rb_right;<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0continue;<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0}<br>
&gt; +<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0tree_page=
 =3D get_mergeable_page(tree_rmap_<wbr>item);<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (!tree=
_page)<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0return NULL;<br>
&gt; @@ -2031,7 +2071,7 @@ static void cmp_and_merge_page(struct page *page=
, struct rmap_item *rmap_item)<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0}<br>
&gt;<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0/* We first start with searching the =
page inside the stable tree */<br>
&gt; -=C2=A0 =C2=A0 =C2=A0 =C2=A0kpage =3D stable_tree_search(page);<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0kpage =3D stable_tree_search(page, rmap_it=
em-&gt;oldchecksum);<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (kpage =3D=3D page &amp;&amp; rmap=
_item-&gt;head =3D=3D stable_node) {<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0put_page(=
kpage);<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0return;<b=
r>
&gt; @@ -2098,7 +2138,7 @@ static void cmp_and_merge_page(struct page *page=
, struct rmap_item *rmap_item)<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 * node in the stable tree and add both rmap_items.<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 */<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0lock_page(kpage);<br>
&gt; -=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0stable_node =3D stable_tree_insert(kpage);<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0stable_node =3D stable_tree_insert(kpage, checksum);<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0if (stable_node) {<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0stable_tree_append(tree_rma=
p_<wbr>item, stable_node,<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 false);<br>
&gt; --<br>
&gt; 2.6.2<br>
&gt;<br>
&gt; --<br>
&gt; To unsubscribe, send a message with &#39;unsubscribe linux-mm&#39; in<=
br>
&gt; the body to <a href=3D"mailto:majordomo@kvack.org">majordomo@kvack.org=
</a>.=C2=A0 For more info on Linux MM,<br>
&gt; see: <a href=3D"http://www.linux-mm.org/" rel=3D"noreferrer" target=3D=
"_blank">http://www.linux-mm.org/</a> .<br>
&gt; Don&#39;t email: &lt;a href=3Dmailto:&quot;<a href=3D"mailto:dont@kvac=
k.org">dont@kvack.org</a>&quot;&gt; <a href=3D"mailto:email@kvack.org">emai=
l@kvack.org</a> &lt;/a&gt;<br>
<br>
<br>
<br>
</div></div><span class=3D"HOEnZb"><font color=3D"#888888">--<br>
Have a nice day,<br>
Timofey.<br>
</font></span><div class=3D"HOEnZb"><div class=3D"h5"><br>
--<br>
To unsubscribe, send a message with &#39;unsubscribe linux-mm&#39; in<br>
the body to <a href=3D"mailto:majordomo@kvack.org">majordomo@kvack.org</a>.=
=C2=A0 For more info on Linux MM,<br>
see: <a href=3D"http://www.linux-mm.org/" rel=3D"noreferrer" target=3D"_bla=
nk">http://www.linux-mm.org/</a> .<br>
Don&#39;t email: &lt;a href=3Dmailto:&quot;<a href=3D"mailto:dont@kvack.org=
">dont@kvack.org</a>&quot;&gt; <a href=3D"mailto:email@kvack.org">email@kva=
ck.org</a> &lt;/a&gt;<br>
</div></div></blockquote></div><br></div>

--001a113d0df0a29afe055e0eeb67--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
