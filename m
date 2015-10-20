Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f181.google.com (mail-io0-f181.google.com [209.85.223.181])
	by kanga.kvack.org (Postfix) with ESMTP id D1B1A82F64
	for <linux-mm@kvack.org>; Tue, 20 Oct 2015 13:58:38 -0400 (EDT)
Received: by iodv82 with SMTP id v82so30935420iod.0
        for <linux-mm@kvack.org>; Tue, 20 Oct 2015 10:58:38 -0700 (PDT)
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com. [209.85.220.49])
        by mx.google.com with ESMTPS id l128si4115726ioe.145.2015.10.20.10.58.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Oct 2015 10:58:37 -0700 (PDT)
Received: by pabrc13 with SMTP id rc13so27866923pab.0
        for <linux-mm@kvack.org>; Tue, 20 Oct 2015 10:58:37 -0700 (PDT)
Content-Type: multipart/alternative; boundary="Apple-Mail=_BB35E7E7-EB72-44AF-9EB7-532F232A6917"
Mime-Version: 1.0 (Mac OS X Mail 8.2 \(2104\))
Subject: Re: [ovs-dev] [PATCH] ovs: do not allocate memory from offline numa node
From: Jarno Rajahalme <jrajahalme@nicira.com>
In-Reply-To: <3C0B7B0E-FDF9-45F5-9CA4-6A8D3CBB2E5C@nicira.com>
Date: Tue, 20 Oct 2015 10:58:33 -0700
Message-Id: <EDC4CBA7-1E5A-47B6-9F45-8365840F4E53@nicira.com>
References: <20151002101822.12499.27658.stgit@buzz> <56128238.8010305@suse.cz> <5612DCC8.4040605@gmail.com> <CAEP_g=9JB2GptbZn9ayTPRGPbuOvVujCQ1Hui7fOijUX10HURg@mail.gmail.com> <FB2084BE-D591-415F-BA39-DFE82FE6FC30@nicira.com> <CAEP_g=9bqj_CKMTvd4dHTS+J82u7idtqa_PFA9=-CmO2ZcUMow@mail.gmail.com> <ECF39603-F56D-483A-A398-480C28C93F97@nicira.com> <CAEP_g=8TTh7pQL_DadBPdhfat+gd_XizGJqWK2wvHvo7oy6WaQ@mail.gmail.com> <3C0B7B0E-FDF9-45F5-9CA4-6A8D3CBB2E5C@nicira.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jesse Gross <jesse@nicira.com>
Cc: Alexander Duyck <alexander.duyck@gmail.com>, Vlastimil Babka <vbabka@suse.cz>, Konstantin Khlebnikov <khlebnikov@yandex-team.ru>, "dev@openvswitch.org" <dev@openvswitch.org>, Pravin Shelar <pshelar@nicira.com>, "David S. Miller" <davem@davemloft.net>, netdev <netdev@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org


--Apple-Mail=_BB35E7E7-EB72-44AF-9EB7-532F232A6917
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=utf-8


> On Oct 9, 2015, at 5:02 PM, Jarno Rajahalme <jrajahalme@nicira.com> =
wrote:
>=20
>=20
>> On Oct 9, 2015, at 3:11 PM, Jesse Gross <jesse@nicira.com =
<mailto:jesse@nicira.com>> wrote:
>>=20
>> On Fri, Oct 9, 2015 at 8:54 AM, Jarno Rajahalme =
<jrajahalme@nicira.com <mailto:jrajahalme@nicira.com>> wrote:
>>>=20
>>> On Oct 8, 2015, at 4:03 PM, Jesse Gross <jesse@nicira.com =
<mailto:jesse@nicira.com>> wrote:
>>>=20
>>> On Wed, Oct 7, 2015 at 10:47 AM, Jarno Rajahalme =
<jrajahalme@nicira.com <mailto:jrajahalme@nicira.com>>
>>> wrote:
>>>=20
>>>=20
>>> On Oct 6, 2015, at 6:01 PM, Jesse Gross <jesse@nicira.com =
<mailto:jesse@nicira.com>> wrote:
>>>=20
>>> On Mon, Oct 5, 2015 at 1:25 PM, Alexander Duyck
>>> <alexander.duyck@gmail.com <mailto:alexander.duyck@gmail.com>> =
wrote:
>>>=20
>>> On 10/05/2015 06:59 AM, Vlastimil Babka wrote:
>>>=20
>>>=20
>>> On 10/02/2015 12:18 PM, Konstantin Khlebnikov wrote:
>>>=20
>>>=20
>>> When openvswitch tries allocate memory from offline numa node 0:
>>> stats =3D kmem_cache_alloc_node(flow_stats_cache, GFP_KERNEL | =
__GFP_ZERO,
>>> 0)
>>> It catches VM_BUG_ON(nid < 0 || nid >=3D MAX_NUMNODES || =
!node_online(nid))
>>> [ replaced with VM_WARN_ON(!node_online(nid)) recently ] in =
linux/gfp.h
>>> This patch disables numa affinity in this case.
>>>=20
>>> Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru =
<mailto:khlebnikov@yandex-team.ru>>
>>>=20
>>>=20
>>>=20
>>> ...
>>>=20
>>> diff --git a/net/openvswitch/flow_table.c =
b/net/openvswitch/flow_table.c
>>> index f2ea83ba4763..c7f74aab34b9 100644
>>> --- a/net/openvswitch/flow_table.c
>>> +++ b/net/openvswitch/flow_table.c
>>> @@ -93,7 +93,8 @@ struct sw_flow *ovs_flow_alloc(void)
>>>=20
>>>    /* Initialize the default stat node. */
>>>    stats =3D kmem_cache_alloc_node(flow_stats_cache,
>>> -                      GFP_KERNEL | __GFP_ZERO, 0);
>>> +                      GFP_KERNEL | __GFP_ZERO,
>>> +                      node_online(0) ? 0 : NUMA_NO_NODE);
>>>=20
>>>=20
>>>=20
>>> Stupid question: can node 0 become offline between this check, and =
the
>>> VM_WARN_ON? :) BTW what kind of system has node 0 offline?
>>>=20
>>>=20
>>>=20
>>> Another question to ask would be is it possible for node 0 to be =
online, but
>>> be a memoryless node?
>>>=20
>>> I would say you are better off just making this call =
kmem_cache_alloc.  I
>>> don't see anything that indicates the memory has to come from node =
0, so
>>> adding the extra overhead doesn't provide any value.
>>>=20
>>>=20
>>> I agree that this at least makes me wonder, though I actually have
>>> concerns in the opposite direction - I see assumptions about this
>>> being on node 0 in net/openvswitch/flow.c.
>>>=20
>>> Jarno, since you original wrote this code, can you take a look to =
see
>>> if everything still makes sense?
>>>=20
>>>=20
>>> We keep the pre-allocated stats node at array index 0, which is =
initially
>>> used by all CPUs, but if CPUs from multiple numa nodes start =
updating the
>>> stats, we allocate additional stats nodes (up to one per numa node), =
and the
>>> CPUs on node 0 keep using the preallocated entry. If stats cannot be
>>> allocated from CPUs local node, then those CPUs keep using the entry =
at
>>> index 0. Currently the code in net/openvswitch/flow.c will try to =
allocate
>>> the local memory repeatedly, which may not be optimal when there is =
no
>>> memory at the local node.
>>>=20
>>> Allocating the memory for the index 0 from other than node 0, as =
discussed
>>> here, just means that the CPUs on node 0 will keep on using =
non-local memory
>>> for stats. In a scenario where there are CPUs on two nodes (0, 1), =
but only
>>> the node 1 has memory, a shared flow entry will still end up having =
separate
>>> memory allocated for both nodes, but both of the nodes would be at =
node 1.
>>> However, there is still a high likelihood that the memory =
allocations would
>>> not share a cache line, which should prevent the nodes from =
invalidating
>>> each other=E2=80=99s caches. Based on this I do not see a problem =
relaxing the
>>> memory allocation for the default stats node. If node 0 has memory, =
however,
>>> it would be better to allocate the memory from node 0.
>>>=20
>>>=20
>>> Thanks for going through all of that.
>>>=20
>>> It seems like the question that is being raised is whether it =
actually
>>> makes sense to try to get the initial memory on node 0, especially
>>> since it seems to introduce some corner cases? Is there any reason =
why
>>> the flow is more likely to hit node 0 than a randomly chosen one?
>>> (Assuming that this is a multinode system, otherwise it's kind of a
>>> moot point.) We could have a separate pointer to the default =
allocated
>>> memory, so it wouldn't conflict with memory that was intentionally
>>> allocated for node 0.
>>>=20
>>>=20
>>> It would still be preferable to know from which node the default =
stats node
>>> was allocated, and store it in the appropriate pointer in the array. =
We
>>> could then add a new =E2=80=9Cdefault stats node index=E2=80=9D that =
would be used to locate
>>> the node in the array of pointers we already have. That way we would =
avoid
>>> extra allocation and processing of the default stats node.
>>=20
>> I agree, that sounds reasonable to me. Will you make that change?
>>=20
>> Besides eliminating corner cases, it might help performance in some
>> cases too by avoiding stressing memory bandwidth on node 0.
>=20

According to the comment above kmem_cache_alloc_node(), =
kmem_cache_alloc_node() should not BUG_ON/WARN_ON in this case:
> /**
>  * kmem_cache_alloc_node - Allocate an object on the specified node
>  * @cachep: The cache to allocate from.
>  * @flags: See kmalloc().
>  * @nodeid: node number of the target node.
>  *
>  * Identical to kmem_cache_alloc but it will allocate memory on the =
given
>  * node, which can improve the performance for cpu bound structures.
>  *
>  * Fallback to other node is possible if __GFP_THISNODE is not set.
>  */
See also this from cpuset.c:

> /**
>  * cpuset_mem_spread_node() - On which node to begin search for a file =
page
>  * cpuset_slab_spread_node() - On which node to begin search for a =
slab page
>  *
>  * If a task is marked PF_SPREAD_PAGE or PF_SPREAD_SLAB (as for
>  * tasks in a cpuset with is_spread_page or is_spread_slab set),
>  * and if the memory allocation used cpuset_mem_spread_node()
>  * to determine on which node to start looking, as it will for
>  * certain page cache or slab cache pages such as used for file
>  * system buffers and inode caches, then instead of starting on the
>  * local node to look for a free page, rather spread the starting
>  * node around the tasks mems_allowed nodes.
>  *
>  * We don't have to worry about the returned node being offline
>  * because "it can't happen", and even if it did, it would be ok.
>  *
>  * The routines calling guarantee_online_mems() are careful to
>  * only set nodes in task->mems_allowed that are online.  So it
>  * should not be possible for the following code to return an
>  * offline node.  But if it did, that would be ok, as this routine
>  * is not returning the node where the allocation must be, only
>  * the node where the search should start.  The zonelist passed to
>  * __alloc_pages() will include all nodes.  If the slab allocator
>  * is passed an offline node, it will fall back to the local node.
>  * See kmem_cache_alloc_node().
>  */


Based on this it seems this is a bug in the memory allocator, it =
probably should not be calling alloc_pages_exact_node() when =
__GFP_THISNODE is not set?

  Jarno


--Apple-Mail=_BB35E7E7-EB72-44AF-9EB7-532F232A6917
Content-Transfer-Encoding: quoted-printable
Content-Type: text/html;
	charset=utf-8

<html><head><meta http-equiv=3D"Content-Type" content=3D"text/html =
charset=3Dutf-8"></head><body style=3D"word-wrap: break-word; =
-webkit-nbsp-mode: space; -webkit-line-break: after-white-space;" =
class=3D""><br class=3D""><div><blockquote type=3D"cite" class=3D""><div =
class=3D"">On Oct 9, 2015, at 5:02 PM, Jarno Rajahalme &lt;<a =
href=3D"mailto:jrajahalme@nicira.com" =
class=3D"">jrajahalme@nicira.com</a>&gt; wrote:</div><br =
class=3D"Apple-interchange-newline"><div class=3D""><meta =
http-equiv=3D"Content-Type" content=3D"text/html charset=3Dutf-8" =
class=3D""><div style=3D"word-wrap: break-word; -webkit-nbsp-mode: =
space; -webkit-line-break: after-white-space;" class=3D""><br =
class=3D""><div class=3D""><blockquote type=3D"cite" class=3D""><div =
class=3D"">On Oct 9, 2015, at 3:11 PM, Jesse Gross &lt;<a =
href=3D"mailto:jesse@nicira.com" class=3D"">jesse@nicira.com</a>&gt; =
wrote:</div><br class=3D"Apple-interchange-newline"><div class=3D""><span =
style=3D"font-family: Helvetica; font-size: 12px; font-style: normal; =
font-variant: normal; font-weight: normal; letter-spacing: normal; =
line-height: normal; orphans: auto; text-align: start; text-indent: 0px; =
text-transform: none; white-space: normal; widows: auto; word-spacing: =
0px; -webkit-text-stroke-width: 0px; float: none; display: inline =
!important;" class=3D"">On Fri, Oct 9, 2015 at 8:54 AM, Jarno Rajahalme =
&lt;</span><a href=3D"mailto:jrajahalme@nicira.com" style=3D"font-family: =
Helvetica; font-size: 12px; font-style: normal; font-variant: normal; =
font-weight: normal; letter-spacing: normal; line-height: normal; =
orphans: auto; text-align: start; text-indent: 0px; text-transform: =
none; white-space: normal; widows: auto; word-spacing: 0px; =
-webkit-text-stroke-width: 0px;" class=3D"">jrajahalme@nicira.com</a><span=
 style=3D"font-family: Helvetica; font-size: 12px; font-style: normal; =
font-variant: normal; font-weight: normal; letter-spacing: normal; =
line-height: normal; orphans: auto; text-align: start; text-indent: 0px; =
text-transform: none; white-space: normal; widows: auto; word-spacing: =
0px; -webkit-text-stroke-width: 0px; float: none; display: inline =
!important;" class=3D"">&gt; wrote:</span><br style=3D"font-family: =
Helvetica; font-size: 12px; font-style: normal; font-variant: normal; =
font-weight: normal; letter-spacing: normal; line-height: normal; =
orphans: auto; text-align: start; text-indent: 0px; text-transform: =
none; white-space: normal; widows: auto; word-spacing: 0px; =
-webkit-text-stroke-width: 0px;" class=3D""><blockquote type=3D"cite" =
style=3D"font-family: Helvetica; font-size: 12px; font-style: normal; =
font-variant: normal; font-weight: normal; letter-spacing: normal; =
line-height: normal; orphans: auto; text-align: start; text-indent: 0px; =
text-transform: none; white-space: normal; widows: auto; word-spacing: =
0px; -webkit-text-stroke-width: 0px;" class=3D""><br class=3D"">On Oct =
8, 2015, at 4:03 PM, Jesse Gross &lt;<a href=3D"mailto:jesse@nicira.com" =
class=3D"">jesse@nicira.com</a>&gt; wrote:<br class=3D""><br class=3D"">On=
 Wed, Oct 7, 2015 at 10:47 AM, Jarno Rajahalme &lt;<a =
href=3D"mailto:jrajahalme@nicira.com" =
class=3D"">jrajahalme@nicira.com</a>&gt;<br class=3D"">wrote:<br =
class=3D""><br class=3D""><br class=3D"">On Oct 6, 2015, at 6:01 PM, =
Jesse Gross &lt;<a href=3D"mailto:jesse@nicira.com" =
class=3D"">jesse@nicira.com</a>&gt; wrote:<br class=3D""><br class=3D"">On=
 Mon, Oct 5, 2015 at 1:25 PM, Alexander Duyck<br class=3D"">&lt;<a =
href=3D"mailto:alexander.duyck@gmail.com" =
class=3D"">alexander.duyck@gmail.com</a>&gt; wrote:<br class=3D""><br =
class=3D"">On 10/05/2015 06:59 AM, Vlastimil Babka wrote:<br =
class=3D""><br class=3D""><br class=3D"">On 10/02/2015 12:18 PM, =
Konstantin Khlebnikov wrote:<br class=3D""><br class=3D""><br =
class=3D"">When openvswitch tries allocate memory from offline numa node =
0:<br class=3D"">stats =3D kmem_cache_alloc_node(flow_stats_cache, =
GFP_KERNEL | __GFP_ZERO,<br class=3D"">0)<br class=3D"">It catches =
VM_BUG_ON(nid &lt; 0 || nid &gt;=3D MAX_NUMNODES || =
!node_online(nid))<br class=3D"">[ replaced with =
VM_WARN_ON(!node_online(nid)) recently ] in linux/gfp.h<br class=3D"">This=
 patch disables numa affinity in this case.<br class=3D""><br =
class=3D"">Signed-off-by: Konstantin Khlebnikov &lt;<a =
href=3D"mailto:khlebnikov@yandex-team.ru" =
class=3D"">khlebnikov@yandex-team.ru</a>&gt;<br class=3D""><br =
class=3D""><br class=3D""><br class=3D"">...<br class=3D""><br =
class=3D"">diff --git a/net/openvswitch/flow_table.c =
b/net/openvswitch/flow_table.c<br class=3D"">index =
f2ea83ba4763..c7f74aab34b9 100644<br class=3D"">--- =
a/net/openvswitch/flow_table.c<br class=3D"">+++ =
b/net/openvswitch/flow_table.c<br class=3D"">@@ -93,7 +93,8 @@ struct =
sw_flow *ovs_flow_alloc(void)<br class=3D""><br =
class=3D"">&nbsp;&nbsp;&nbsp;/* Initialize the default stat node. */<br =
class=3D"">&nbsp;&nbsp;&nbsp;stats =3D =
kmem_cache_alloc_node(flow_stats_cache,<br class=3D"">- =
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&n=
bsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;GFP_KERNEL | =
__GFP_ZERO, 0);<br class=3D"">+ =
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&n=
bsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;GFP_KERNEL | =
__GFP_ZERO,<br class=3D"">+ =
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&n=
bsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;node_online(0) ? 0 : =
NUMA_NO_NODE);<br class=3D""><br class=3D""><br class=3D""><br =
class=3D"">Stupid question: can node 0 become offline between this =
check, and the<br class=3D"">VM_WARN_ON? :) BTW what kind of system has =
node 0 offline?<br class=3D""><br class=3D""><br class=3D""><br =
class=3D"">Another question to ask would be is it possible for node 0 to =
be online, but<br class=3D"">be a memoryless node?<br class=3D""><br =
class=3D"">I would say you are better off just making this call =
kmem_cache_alloc. &nbsp;I<br class=3D"">don't see anything that =
indicates the memory has to come from node 0, so<br class=3D"">adding =
the extra overhead doesn't provide any value.<br class=3D""><br =
class=3D""><br class=3D"">I agree that this at least makes me wonder, =
though I actually have<br class=3D"">concerns in the opposite direction =
- I see assumptions about this<br class=3D"">being on node 0 in =
net/openvswitch/flow.c.<br class=3D""><br class=3D"">Jarno, since you =
original wrote this code, can you take a look to see<br class=3D"">if =
everything still makes sense?<br class=3D""><br class=3D""><br =
class=3D"">We keep the pre-allocated stats node at array index 0, which =
is initially<br class=3D"">used by all CPUs, but if CPUs from multiple =
numa nodes start updating the<br class=3D"">stats, we allocate =
additional stats nodes (up to one per numa node), and the<br =
class=3D"">CPUs on node 0 keep using the preallocated entry. If stats =
cannot be<br class=3D"">allocated from CPUs local node, then those CPUs =
keep using the entry at<br class=3D"">index 0. Currently the code in =
net/openvswitch/flow.c will try to allocate<br class=3D"">the local =
memory repeatedly, which may not be optimal when there is no<br =
class=3D"">memory at the local node.<br class=3D""><br =
class=3D"">Allocating the memory for the index 0 from other than node 0, =
as discussed<br class=3D"">here, just means that the CPUs on node 0 will =
keep on using non-local memory<br class=3D"">for stats. In a scenario =
where there are CPUs on two nodes (0, 1), but only<br class=3D"">the =
node 1 has memory, a shared flow entry will still end up having =
separate<br class=3D"">memory allocated for both nodes, but both of the =
nodes would be at node 1.<br class=3D"">However, there is still a high =
likelihood that the memory allocations would<br class=3D"">not share a =
cache line, which should prevent the nodes from invalidating<br =
class=3D"">each other=E2=80=99s caches. Based on this I do not see a =
problem relaxing the<br class=3D"">memory allocation for the default =
stats node. If node 0 has memory, however,<br class=3D"">it would be =
better to allocate the memory from node 0.<br class=3D""><br =
class=3D""><br class=3D"">Thanks for going through all of that.<br =
class=3D""><br class=3D"">It seems like the question that is being =
raised is whether it actually<br class=3D"">makes sense to try to get =
the initial memory on node 0, especially<br class=3D"">since it seems to =
introduce some corner cases? Is there any reason why<br class=3D"">the =
flow is more likely to hit node 0 than a randomly chosen one?<br =
class=3D"">(Assuming that this is a multinode system, otherwise it's =
kind of a<br class=3D"">moot point.) We could have a separate pointer to =
the default allocated<br class=3D"">memory, so it wouldn't conflict with =
memory that was intentionally<br class=3D"">allocated for node 0.<br =
class=3D""><br class=3D""><br class=3D"">It would still be preferable to =
know from which node the default stats node<br class=3D"">was allocated, =
and store it in the appropriate pointer in the array. We<br =
class=3D"">could then add a new =E2=80=9Cdefault stats node index=E2=80=9D=
 that would be used to locate<br class=3D"">the node in the array of =
pointers we already have. That way we would avoid<br class=3D"">extra =
allocation and processing of the default stats node.<br =
class=3D""></blockquote><br style=3D"font-family: Helvetica; font-size: =
12px; font-style: normal; font-variant: normal; font-weight: normal; =
letter-spacing: normal; line-height: normal; orphans: auto; text-align: =
start; text-indent: 0px; text-transform: none; white-space: normal; =
widows: auto; word-spacing: 0px; -webkit-text-stroke-width: 0px;" =
class=3D""><span style=3D"font-family: Helvetica; font-size: 12px; =
font-style: normal; font-variant: normal; font-weight: normal; =
letter-spacing: normal; line-height: normal; orphans: auto; text-align: =
start; text-indent: 0px; text-transform: none; white-space: normal; =
widows: auto; word-spacing: 0px; -webkit-text-stroke-width: 0px; float: =
none; display: inline !important;" class=3D"">I agree, that sounds =
reasonable to me. Will you make that change?</span><br =
style=3D"font-family: Helvetica; font-size: 12px; font-style: normal; =
font-variant: normal; font-weight: normal; letter-spacing: normal; =
line-height: normal; orphans: auto; text-align: start; text-indent: 0px; =
text-transform: none; white-space: normal; widows: auto; word-spacing: =
0px; -webkit-text-stroke-width: 0px;" class=3D""><br style=3D"font-family:=
 Helvetica; font-size: 12px; font-style: normal; font-variant: normal; =
font-weight: normal; letter-spacing: normal; line-height: normal; =
orphans: auto; text-align: start; text-indent: 0px; text-transform: =
none; white-space: normal; widows: auto; word-spacing: 0px; =
-webkit-text-stroke-width: 0px;" class=3D""><span style=3D"font-family: =
Helvetica; font-size: 12px; font-style: normal; font-variant: normal; =
font-weight: normal; letter-spacing: normal; line-height: normal; =
orphans: auto; text-align: start; text-indent: 0px; text-transform: =
none; white-space: normal; widows: auto; word-spacing: 0px; =
-webkit-text-stroke-width: 0px; float: none; display: inline =
!important;" class=3D"">Besides eliminating corner cases, it might help =
performance in some</span><br style=3D"font-family: Helvetica; =
font-size: 12px; font-style: normal; font-variant: normal; font-weight: =
normal; letter-spacing: normal; line-height: normal; orphans: auto; =
text-align: start; text-indent: 0px; text-transform: none; white-space: =
normal; widows: auto; word-spacing: 0px; -webkit-text-stroke-width: =
0px;" class=3D""><span style=3D"font-family: Helvetica; font-size: 12px; =
font-style: normal; font-variant: normal; font-weight: normal; =
letter-spacing: normal; line-height: normal; orphans: auto; text-align: =
start; text-indent: 0px; text-transform: none; white-space: normal; =
widows: auto; word-spacing: 0px; -webkit-text-stroke-width: 0px; float: =
none; display: inline !important;" class=3D"">cases too by avoiding =
stressing memory bandwidth on node 0.</span></div></blockquote></div><br =
class=3D""></div></div></blockquote><div><br =
class=3D""></div><div>According to the comment above =
kmem_cache_alloc_node(), kmem_cache_alloc_node() should not =
BUG_ON/WARN_ON in this case:</div><div><blockquote type=3D"cite" =
class=3D""><pre class=3D""><b class=3D""><i class=3D"">/**</i></b>
<b class=3D""><i class=3D""> * kmem_cache_alloc_node - Allocate an =
object on the specified node</i></b>
<b class=3D""><i class=3D""> * @cachep: The cache to allocate =
from.</i></b>
<b class=3D""><i class=3D""> * @flags: See kmalloc().</i></b>
<b class=3D""><i class=3D""> * @nodeid: node number of the target =
node.</i></b>
<b class=3D""><i class=3D""> *</i></b>
<b class=3D""><i class=3D""> * Identical to kmem_cache_alloc but it will =
allocate memory on the given</i></b>
<b class=3D""><i class=3D""> * node, which can improve the performance =
for cpu bound structures.</i></b>
<b class=3D""><i class=3D""> *</i></b>
<b class=3D""><i class=3D""> * Fallback to other node is possible if =
__GFP_THISNODE is not set.</i></b>
<b class=3D""><i class=3D""> */</i></b></pre></blockquote><div =
class=3D"">See also this from cpuset.c:</div><div class=3D""><br =
class=3D""></div><div class=3D""><blockquote type=3D"cite" class=3D""><div=
 class=3D"">/**</div><div class=3D"">&nbsp;* cpuset_mem_spread_node() - =
On which node to begin search for a file page</div><div class=3D"">&nbsp;*=
 cpuset_slab_spread_node() - On which node to begin search for a slab =
page</div><div class=3D"">&nbsp;*</div><div class=3D"">&nbsp;* If a task =
is marked PF_SPREAD_PAGE or PF_SPREAD_SLAB (as for</div><div =
class=3D"">&nbsp;* tasks in a cpuset with is_spread_page or =
is_spread_slab set),</div><div class=3D"">&nbsp;* and if the memory =
allocation used cpuset_mem_spread_node()</div><div class=3D"">&nbsp;* to =
determine on which node to start looking, as it will for</div><div =
class=3D"">&nbsp;* certain page cache or slab cache pages such as used =
for file</div><div class=3D"">&nbsp;* system buffers and inode caches, =
then instead of starting on the</div><div class=3D"">&nbsp;* local node =
to look for a free page, rather spread the starting</div><div =
class=3D"">&nbsp;* node around the tasks mems_allowed nodes.</div><div =
class=3D"">&nbsp;*</div><div class=3D"">&nbsp;* We don't have to worry =
about the returned node being offline</div><div class=3D"">&nbsp;* =
because "it can't happen", and even if it did, it would be ok.</div><div =
class=3D"">&nbsp;*</div><div class=3D"">&nbsp;* The routines calling =
guarantee_online_mems() are careful to</div><div class=3D"">&nbsp;* only =
set nodes in task-&gt;mems_allowed that are online. &nbsp;So =
it</div><div class=3D"">&nbsp;* should not be possible for the following =
code to return an</div><div class=3D"">&nbsp;* offline node. &nbsp;But =
if it did, that would be ok, as this routine</div><div class=3D"">&nbsp;* =
is not returning the node where the allocation must be, only</div><div =
class=3D"">&nbsp;* the node where the search should start. &nbsp;The =
zonelist passed to</div><div class=3D"">&nbsp;* __alloc_pages() will =
include all nodes. &nbsp;If the slab allocator</div><div =
class=3D"">&nbsp;* is passed an offline node, it will fall back to the =
local node.</div><div class=3D"">&nbsp;* See =
kmem_cache_alloc_node().</div><div =
class=3D"">&nbsp;*/</div></blockquote></div><div class=3D""><br =
class=3D""></div><div class=3D"">Based on this it seems this is a bug in =
the memory allocator, it probably should not be calling =
alloc_pages_exact_node() when&nbsp;__GFP_THISNODE is not set?</div><div =
class=3D""><br class=3D""></div><div class=3D"">&nbsp; Jarno</div><div =
class=3D""><br class=3D""></div></div></div></body></html>=

--Apple-Mail=_BB35E7E7-EB72-44AF-9EB7-532F232A6917--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
