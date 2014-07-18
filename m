Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vc0-f176.google.com (mail-vc0-f176.google.com [209.85.220.176])
	by kanga.kvack.org (Postfix) with ESMTP id 269D26B0035
	for <linux-mm@kvack.org>; Fri, 18 Jul 2014 13:33:42 -0400 (EDT)
Received: by mail-vc0-f176.google.com with SMTP id id10so3304166vcb.7
        for <linux-mm@kvack.org>; Fri, 18 Jul 2014 10:33:41 -0700 (PDT)
Received: from mail-vc0-x234.google.com (mail-vc0-x234.google.com [2607:f8b0:400c:c03::234])
        by mx.google.com with ESMTPS id py3si6502948vdb.107.2014.07.18.10.33.41
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 18 Jul 2014 10:33:41 -0700 (PDT)
Received: by mail-vc0-f180.google.com with SMTP id ij19so8022251vcb.39
        for <linux-mm@kvack.org>; Fri, 18 Jul 2014 10:33:41 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <53C8D6A8.3040400@cn.fujitsu.com>
References: <20140717230923.GA32660@linux.vnet.ibm.com>
	<20140717230958.GB32660@linux.vnet.ibm.com>
	<53C8D6A8.3040400@cn.fujitsu.com>
Date: Fri, 18 Jul 2014 10:33:41 -0700
Message-ID: <CAOhV88OCqvfo_0yjA3b7uKiuXE6bVwH7WQLj00BES7JzbMimkg@mail.gmail.com>
Subject: Re: [RFC 1/2] workqueue: use the nearest NUMA node, not the local one
From: Nish Aravamudan <nish.aravamudan@gmail.com>
Content-Type: multipart/alternative; boundary=001a11c211fa87675704fe7b280c
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Lai Jiangshan <laijs@cn.fujitsu.com>
Cc: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Jiang Liu <jiang.liu@linux.intel.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>, linuxppc-dev@lists.ozlabs.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Tejun Heo <tj@kernel.org>

--001a11c211fa87675704fe7b280c
Content-Type: text/plain; charset=UTF-8

[ Apologies for replying from a different address, we have a service outage
at work. ]

On Fri, Jul 18, 2014 at 1:11 AM, Lai Jiangshan <laijs@cn.fujitsu.com> wrote:
>
> Hi,

Thank you for your response!

> I'm curious about what will it happen when
alloc_pages_node(memoryless_node).

alloc_pages_node() is only involved in one of the possible paths (maybe
this occurs on x86 with THREAD_INFO > PAGE_SIZE?) On powerpc, though,
that's not the case.

Details:

1. pool->node is used in the invocation of kthread_create_on_node() in
create_worker().
2. kthread_create_on_node sets up a struct kthread_create_info with
create->node = node and wakes up kthreadd.
3. kthreadd calls create_kthread, which sets current->pref_node_fork =
create->node.
4. dup_task_struct() calls node = tsk_fork_get_node() before invoking
alloc_task_struct_node(node) and alloc_thread_info_node(node).
5. tsk_fork_get_node() returns current->pref_node_fork for kthreadd.
6. alloc_task_struct_node() calls kmem_cache_alloc_node(,GFP_KERNEL, node)
7. alloc_thread_info_node() either calls kmem_cache_alloc_node(,GFP_KERNEL,
node) or alloc_kmem_pages_node(node,GFP_KERNEL,), depending on the size of
THREAD_INFO relative to PAGE_SIZE.
8a. alloc_kmem_pages_node() -> alloc_pages_node -> __alloc_pages with a
zonelist built from node_zonelist. This should lead to proper fallback.
8b. kmem_cache_alloc_node() calls slab_alloc_node()
9. For a memoryless node, we will trigger the following:

        if (unlikely(!object || !node_match(page, node))) {
                object = __slab_alloc(s, gfpflags, node, addr, c);
                stat(s, ALLOC_SLOWPATH);
        }

10. __slab_alloc() in turn will:

        if (unlikely(!node_match(page, node))) {
                stat(s, ALLOC_NODE_MISMATCH);
                deactivate_slab(s, page, c->freelist);
                c->page = NULL;
                c->freelist = NULL;
                goto new_slab;
        }

deactivating the slab. Thus, every kthread created with a node
specification leads to a single object on a slab. We see an explosion in
the slab consumption, all of which is unreclaimable.

Anton originally proposed not deactivating slabs when we *know* the
allocation will be remote (i.e., from a memoryless node). Joonsoo and
Christoph disagreed with this and proposed alternative solutions, which
weren't agreed upon at the time.

> If the memory is allocated from the most preferable node for the
@memoryless_node,
> why we need to bother and use cpu_to_mem() in the caller site?

The reason is that the node passed is a hint into the MM subsystem of what
node we want memory to come from. Well, I take that back, I think
semantically there are two ways to interpret the node parameter:

1) The NUMA node we want memory from
2) The NUMA node we expect memory from

The path through the MM above sort of conflates the two, the caller
specified an impossible request (which the MM subsystem technically knows
but which knowledge it isn't using at this point) of memory from a node
that has none.

We could change the core MM to do better in the presence of memoryless
nodes, and should, but this seems far less invasive and does the right
thing. Semantically, I think the workqueue's pool->node is meant to be the
node from which we want memory allocated, which is the node with memory
closest to the CPU.

Thanks,
Nish

> If not, why the memory allocation subsystem refuses to find a preferable
node
> for @memoryless_node in this case? Does it intend on some purpose or
> it can't find in some cases?
>
> Thanks,
> Lai
>
> Added CC to Tejun (workqueue maintainer).
>
> On 07/18/2014 07:09 AM, Nishanth Aravamudan wrote:
> > In the presence of memoryless nodes, the workqueue code incorrectly uses
> > cpu_to_node() to determine what node to prefer memory allocations come
> > from. cpu_to_mem() should be used instead, which will use the nearest
> > NUMA node with memory.
> >
> > Signed-off-by: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>
> >
> > diff --git a/kernel/workqueue.c b/kernel/workqueue.c
> > index 35974ac..0bba022 100644
> > --- a/kernel/workqueue.c
> > +++ b/kernel/workqueue.c
> > @@ -3547,7 +3547,12 @@ static struct worker_pool
*get_unbound_pool(const struct workqueue_attrs *attrs)
> >               for_each_node(node) {
> >                       if (cpumask_subset(pool->attrs->cpumask,
> >
 wq_numa_possible_cpumask[node])) {
> > -                             pool->node = node;
> > +                             /*
> > +                              * We could use local_memory_node(node)
here,
> > +                              * but it is expensive and the following
caches
> > +                              * the same value.
> > +                              */
> > +                             pool->node =
cpu_to_mem(cpumask_first(pool->attrs->cpumask));
> >                               break;
> >                       }
> >               }
> > @@ -4921,7 +4926,7 @@ static int __init init_workqueues(void)
> >                       pool->cpu = cpu;
> >                       cpumask_copy(pool->attrs->cpumask,
cpumask_of(cpu));
> >                       pool->attrs->nice = std_nice[i++];
> > -                     pool->node = cpu_to_node(cpu);
> > +                     pool->node = cpu_to_mem(cpu);
> >
> >                       /* alloc pool ID */
> >                       mutex_lock(&wq_pool_mutex);
> >
> > --
> > To unsubscribe from this list: send the line "unsubscribe linux-kernel"
in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> > Please read the FAQ at  http://www.tux.org/lkml/
> >
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/

--001a11c211fa87675704fe7b280c
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><div><div>[ Apologies for replying from a different addres=
s, we have a service outage at work. ]<br><br>On Fri, Jul 18, 2014 at 1:11 =
AM, Lai Jiangshan &lt;<a href=3D"mailto:laijs@cn.fujitsu.com">laijs@cn.fuji=
tsu.com</a>&gt; wrote:<br>
&gt;<br>&gt; Hi,<br><br></div><div>Thank you for your response!<br></div><d=
iv><br>&gt; I&#39;m curious about what will it happen when alloc_pages_node=
(memoryless_node).<br><br></div><div>alloc_pages_node() is only involved in=
 one of the possible paths (maybe this occurs on x86 with THREAD_INFO &gt; =
PAGE_SIZE?) On powerpc, though, that&#39;s not the case.<br>
</div><div><br></div><div>Details: <br></div><div><br></div>1. pool-&gt;nod=
e is used in the invocation of kthread_create_on_node() in create_worker().=
<br>2. kthread_create_on_node sets up a struct kthread_create_info with cre=
ate-&gt;node =3D node and wakes up kthreadd.<br>
</div>3. kthreadd calls create_kthread, which sets current-&gt;pref_node_fo=
rk =3D create-&gt;node.<br>4. dup_task_struct() calls node =3D tsk_fork_get=
_node() before invoking alloc_task_struct_node(node) and alloc_thread_info_=
node(node).<br>
5. tsk_fork_get_node() returns current-&gt;pref_node_fork for kthreadd.<br>=
<div><div><div>6. alloc_task_struct_node() calls kmem_cache_alloc_node(,GFP=
_KERNEL, node)<br>7. alloc_thread_info_node() either calls kmem_cache_alloc=
_node(,GFP_KERNEL, node) or alloc_kmem_pages_node(node,GFP_KERNEL,), depend=
ing on the size of THREAD_INFO relative to PAGE_SIZE.<br>
8a. alloc_kmem_pages_node() -&gt; alloc_pages_node -&gt; __alloc_pages with=
 a zonelist built from node_zonelist. This should lead to proper fallback.<=
br></div><div>8b. kmem_cache_alloc_node() calls slab_alloc_node()<br></div>
<div>9. For a memoryless node, we will trigger the following:<br><br>=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 if (unlikely(!object || !node_match(pa=
ge, node))) {<br>=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 object =3D __slab_alloc(s, gfpflags, node=
, addr, c);<br>=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 stat(s, ALLOC_SLOWPATH);<br>
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 }<br><br></div><div>10. __slab_a=
lloc() in turn will:<br><br>=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 if (=
unlikely(!node_match(page, node))) {<br>=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 stat(s, ALLOC_NOD=
E_MISMATCH);<br>=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 deactivate_slab(s, page, c-&gt;freelist);=
<br>
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0 c-&gt;page =3D NULL;<br>=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 c-&gt;freelist =
=3D NULL;<br>=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 goto new_slab;<br>=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0 }<br><br></div><div>deactivating the slab. Thus, every k=
thread created with a node specification leads to a single object on a slab=
. We see an explosion in the slab consumption, all of which is unreclaimabl=
e.<br>
<br></div><div>Anton originally proposed not deactivating slabs when we *kn=
ow* the allocation will be remote (i.e., from a memoryless node). Joonsoo a=
nd Christoph disagreed with this and proposed alternative solutions, which =
weren&#39;t agreed upon at the time.<br>
</div><div><br>&gt; If the memory is allocated from the most preferable nod=
e for the @memoryless_node,<br>&gt; why we need to bother and use cpu_to_me=
m() in the caller site?<br><br></div><div>The reason is that the node passe=
d is a hint into the MM subsystem of what node we want memory to come from.=
 Well, I take that back, I think semantically there are two ways to interpr=
et the node parameter:<br>
<br></div><div>1) The NUMA node we want memory from<br></div><div>2) The NU=
MA node we expect memory from<br><br></div><div>The path through the MM abo=
ve sort of conflates the two, the caller specified an impossible request (w=
hich the MM subsystem technically knows but which knowledge it isn&#39;t us=
ing at this point) of memory from a node that has none.<br>
<br></div><div>We could change the core MM to do better in the presence of =
memoryless nodes, and should, but this seems far less invasive and does the=
 right thing. Semantically, I think the workqueue&#39;s pool-&gt;node is me=
ant to be the node from which we want memory allocated, which is the node w=
ith memory closest to the CPU.<br>
<br>Thanks,<br>Nish<br></div><div><br>&gt; If not, why the memory allocatio=
n subsystem refuses to find a preferable node<br>&gt; for @memoryless_node =
in this case? Does it intend on some purpose or<br>&gt; it can&#39;t find i=
n some cases?<br>
&gt;<br>&gt; Thanks,<br>&gt; Lai<br>&gt;<br>&gt; Added CC to Tejun (workque=
ue maintainer).<br>&gt;<br>&gt; On 07/18/2014 07:09 AM, Nishanth Aravamudan=
 wrote:<br>&gt; &gt; In the presence of memoryless nodes, the workqueue cod=
e incorrectly uses<br>
&gt; &gt; cpu_to_node() to determine what node to prefer memory allocations=
 come<br>&gt; &gt; from. cpu_to_mem() should be used instead, which will us=
e the nearest<br>&gt; &gt; NUMA node with memory.<br>&gt; &gt;<br>&gt; &gt;=
 Signed-off-by: Nishanth Aravamudan &lt;<a href=3D"mailto:nacc@linux.vnet.i=
bm.com">nacc@linux.vnet.ibm.com</a>&gt;<br>
&gt; &gt;<br>&gt; &gt; diff --git a/kernel/workqueue.c b/kernel/workqueue.c=
<br>&gt; &gt; index 35974ac..0bba022 100644<br>&gt; &gt; --- a/kernel/workq=
ueue.c<br>&gt; &gt; +++ b/kernel/workqueue.c<br>&gt; &gt; @@ -3547,7 +3547,=
12 @@ static struct worker_pool *get_unbound_pool(const struct workqueue_at=
trs *attrs)<br>
&gt; &gt; =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 for_each_node(no=
de) {<br>&gt; &gt; =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 if (cpumask_subset(pool-&gt;attrs-&gt;cpumask,<br>&gt;=
 &gt; =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0wq_numa_possible_cpumask[node])) {<br>&gt; &gt; - =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 pool-&gt;node =3D node;<br>
&gt; &gt; + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 /*<br>&gt; &gt; + =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0* We could use local_memory_node(node) here,<br>&gt; &gt; + =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0* but it is expensive and the following caches<b=
r>
&gt; &gt; + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* the same value.<br>&gt; &gt; + =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0*/<br>&gt; &gt; + =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 p=
ool-&gt;node =3D cpu_to_mem(cpumask_first(pool-&gt;attrs-&gt;cpumask));<br>
&gt; &gt; =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 break;<br>&gt; &gt; =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 }<br>&gt; &=
gt; =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 }<br>&gt; &gt; @@ -492=
1,7 +4926,7 @@ static int __init init_workqueues(void)<br>&gt; &gt; =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 pool-=
&gt;cpu =3D cpu;<br>
&gt; &gt; =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 cpumask_copy(pool-&gt;attrs-&gt;cpumask, cpumask_of(cpu));<br=
>&gt; &gt; =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 pool-&gt;attrs-&gt;nice =3D std_nice[i++];<br>&gt; &gt; - =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 pool-&gt=
;node =3D cpu_to_node(cpu);<br>
&gt; &gt; + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 pool-&gt;node =3D cpu_to_mem(cpu);<br>&gt; &gt;<br>&gt; &gt; =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 /* al=
loc pool ID */<br>&gt; &gt; =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 mutex_lock(&amp;wq_pool_mutex);<br>&gt; &gt=
;<br>&gt; &gt; --<br>
&gt; &gt; To unsubscribe from this list: send the line &quot;unsubscribe li=
nux-kernel&quot; in<br>&gt; &gt; the body of a message to <a href=3D"mailto=
:majordomo@vger.kernel.org">majordomo@vger.kernel.org</a><br>&gt; &gt; More=
 majordomo info at =C2=A0<a href=3D"http://vger.kernel.org/majordomo-info.h=
tml">http://vger.kernel.org/majordomo-info.html</a><br>
&gt; &gt; Please read the FAQ at =C2=A0<a href=3D"http://www.tux.org/lkml/"=
>http://www.tux.org/lkml/</a><br>&gt; &gt;<br>&gt;<br>&gt; --<br>&gt; To un=
subscribe from this list: send the line &quot;unsubscribe linux-kernel&quot=
; in<br>
&gt; the body of a message to <a href=3D"mailto:majordomo@vger.kernel.org">=
majordomo@vger.kernel.org</a><br>&gt; More majordomo info at =C2=A0<a href=
=3D"http://vger.kernel.org/majordomo-info.html">http://vger.kernel.org/majo=
rdomo-info.html</a><br>
&gt; Please read the FAQ at =C2=A0<a href=3D"http://www.tux.org/lkml/">http=
://www.tux.org/lkml/</a><br><br></div></div></div></div>

--001a11c211fa87675704fe7b280c--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
