Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id ADFDD6008F1
	for <linux-mm@kvack.org>; Fri, 21 May 2010 10:44:32 -0400 (EDT)
From: "Shi, Alex" <alex.shi@intel.com>
Date: Fri, 21 May 2010 22:41:45 +0800
Subject: RE: [PATCH] slub: move kmem_cache_node into it's own cacheline
Message-ID: <6E3BC7F7C9A4BF4286DD4C043110F30B0B5969081B@shsmsx502.ccr.corp.intel.com>
References: <20100520234714.6633.75614.stgit@gitlad.jf.intel.com>
 <AANLkTilfJh65QAkb9FPaqI3UEtbgwLuuoqSdaTtIsXWZ@mail.gmail.com>
In-Reply-To: <AANLkTilfJh65QAkb9FPaqI3UEtbgwLuuoqSdaTtIsXWZ@mail.gmail.com>
Content-Language: en-US
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>, "Duyck, Alexander H" <alexander.h.duyck@intel.com>
Cc: "cl@linux.com" <cl@linux.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Zhang Yanmin <yanmin_zhang@linux.intel.com>, "Chen, Tim C" <tim.c.chen@intel.com>
List-ID: <linux-mm.kvack.org>

I have tested this patch based latest Linus' kernel tree. It real works!
About 10% improvement happened for hackbench threads mode and 8%~13% improv=
e for process mode on our 2 sockets Westmere machine and about 7% hackbench=
 improvement on 2 sockets NHM.=20

Alex=20
>-----Original Message-----
>From: penberg@gmail.com [mailto:penberg@gmail.com] On Behalf Of Pekka Enbe=
rg
>Sent: Friday, May 21, 2010 1:00 PM
>To: Duyck, Alexander H
>Cc: cl@linux.com; linux-mm@kvack.org; Shi, Alex; Zhang Yanmin
>Subject: Re: [PATCH] slub: move kmem_cache_node into it's own cacheline
>
>On Fri, May 21, 2010 at 2:47 AM, Alexander Duyck
><alexander.h.duyck@intel.com> wrote:
>> This patch is meant to improve the performance of SLUB by moving the loc=
al
>> kmem_cache_node lock into it's own cacheline separate from kmem_cache.
>> This is accomplished by simply removing the local_node when NUMA is enab=
led.
>>
>> On my system with 2 nodes I saw around a 5% performance increase w/
>> hackbench times dropping from 6.2 seconds to 5.9 seconds on average. =A0=
I
>> suspect the performance gain would increase as the number of nodes
>> increases, but I do not have the data to currently back that up.
>>
>> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
>
>Yanmin, does this fix the hackbench regression for you?
>
>> ---
>>
>> =A0include/linux/slub_def.h | =A0 11 ++++-------
>> =A0mm/slub.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 33 +++++++++++--------=
--------------
>> =A02 files changed, 15 insertions(+), 29 deletions(-)
>>
>> diff --git a/include/linux/slub_def.h b/include/linux/slub_def.h
>> index 0249d41..e6217bb 100644
>> --- a/include/linux/slub_def.h
>> +++ b/include/linux/slub_def.h
>> @@ -52,7 +52,7 @@ struct kmem_cache_node {
>> =A0 =A0 =A0 =A0atomic_long_t total_objects;
>> =A0 =A0 =A0 =A0struct list_head full;
>> =A0#endif
>> -};
>> +} ____cacheline_internodealigned_in_smp;
>>
>> =A0/*
>> =A0* Word size structure that can be atomically updated or read and that
>> @@ -75,12 +75,6 @@ struct kmem_cache {
>> =A0 =A0 =A0 =A0int offset; =A0 =A0 =A0 =A0 =A0 =A0 /* Free pointer offse=
t. */
>> =A0 =A0 =A0 =A0struct kmem_cache_order_objects oo;
>>
>> - =A0 =A0 =A0 /*
>> - =A0 =A0 =A0 =A0* Avoid an extra cache line for UP, SMP and for the nod=
e local to
>> - =A0 =A0 =A0 =A0* struct kmem_cache.
>> - =A0 =A0 =A0 =A0*/
>> - =A0 =A0 =A0 struct kmem_cache_node local_node;
>> -
>> =A0 =A0 =A0 =A0/* Allocation and freeing of slabs */
>> =A0 =A0 =A0 =A0struct kmem_cache_order_objects max;
>> =A0 =A0 =A0 =A0struct kmem_cache_order_objects min;
>> @@ -102,6 +96,9 @@ struct kmem_cache {
>> =A0 =A0 =A0 =A0 */
>> =A0 =A0 =A0 =A0int remote_node_defrag_ratio;
>> =A0 =A0 =A0 =A0struct kmem_cache_node *node[MAX_NUMNODES];
>> +#else
>> + =A0 =A0 =A0 /* Avoid an extra cache line for UP */
>> + =A0 =A0 =A0 struct kmem_cache_node local_node;
>> =A0#endif
>> =A0};
>>
>> diff --git a/mm/slub.c b/mm/slub.c
>> index 461314b..8af03de 100644
>> --- a/mm/slub.c
>> +++ b/mm/slub.c
>> @@ -2141,7 +2141,7 @@ static void free_kmem_cache_nodes(struct kmem_cach=
e *s)
>>
>> =A0 =A0 =A0 =A0for_each_node_state(node, N_NORMAL_MEMORY) {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct kmem_cache_node *n =3D s->node[nod=
e];
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (n && n !=3D &s->local_node)
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (n)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0kmem_cache_free(kmalloc_c=
aches, n);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0s->node[node] =3D NULL;
>> =A0 =A0 =A0 =A0}
>> @@ -2150,33 +2150,22 @@ static void free_kmem_cache_nodes(struct kmem_ca=
che *s)
>> =A0static int init_kmem_cache_nodes(struct kmem_cache *s, gfp_t gfpflags=
)
>> =A0{
>> =A0 =A0 =A0 =A0int node;
>> - =A0 =A0 =A0 int local_node;
>> -
>> - =A0 =A0 =A0 if (slab_state >=3D UP && (s < kmalloc_caches ||
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 s >=3D kmalloc_caches + KM=
ALLOC_CACHES))
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 local_node =3D page_to_nid(virt_to_page(s)=
);
>> - =A0 =A0 =A0 else
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 local_node =3D 0;
>>
>> =A0 =A0 =A0 =A0for_each_node_state(node, N_NORMAL_MEMORY) {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct kmem_cache_node *n;
>>
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (local_node =3D=3D node)
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 n =3D &s->local_node;
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 else {
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (slab_state =3D=3D DOWN=
) {
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 early_kmem=
_cache_node_alloc(gfpflags, node);
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 continue;
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 n =3D kmem_cache_alloc_nod=
e(kmalloc_caches,
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 gfpflags, node);
>> -
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!n) {
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 free_kmem_=
cache_nodes(s);
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return 0;
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (slab_state =3D=3D DOWN) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 early_kmem_cache_node_allo=
c(gfpflags, node);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 continue;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 n =3D kmem_cache_alloc_node(kmalloc_caches=
,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 gfpflags, node);
>>
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!n) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 free_kmem_cache_nodes(s);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return 0;
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
>> +
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0s->node[node] =3D n;
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0init_kmem_cache_node(n, s);
>> =A0 =A0 =A0 =A0}
>>
>> --
>> To unsubscribe, send a message with 'unsubscribe linux-mm' in
>> the body to majordomo@kvack.org. =A0For more info on Linux MM,
>> see: http://www.linux-mm.org/ .
>> Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>
>>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
