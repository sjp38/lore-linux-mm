Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f178.google.com (mail-ig0-f178.google.com [209.85.213.178])
	by kanga.kvack.org (Postfix) with ESMTP id 259DE6B0038
	for <linux-mm@kvack.org>; Wed,  7 Oct 2015 13:47:22 -0400 (EDT)
Received: by igcrk20 with SMTP id rk20so114841334igc.1
        for <linux-mm@kvack.org>; Wed, 07 Oct 2015 10:47:22 -0700 (PDT)
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com. [209.85.220.44])
        by mx.google.com with ESMTPS id qh9si3419201igb.88.2015.10.07.10.47.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Oct 2015 10:47:21 -0700 (PDT)
Received: by pacex6 with SMTP id ex6so27615533pac.0
        for <linux-mm@kvack.org>; Wed, 07 Oct 2015 10:47:21 -0700 (PDT)
Content-Type: text/plain; charset=utf-8
Mime-Version: 1.0 (Mac OS X Mail 8.2 \(2104\))
Subject: Re: [ovs-dev] [PATCH] ovs: do not allocate memory from offline numa node
From: Jarno Rajahalme <jrajahalme@nicira.com>
In-Reply-To: <CAEP_g=9JB2GptbZn9ayTPRGPbuOvVujCQ1Hui7fOijUX10HURg@mail.gmail.com>
Date: Wed, 7 Oct 2015 10:47:17 -0700
Content-Transfer-Encoding: quoted-printable
Message-Id: <FB2084BE-D591-415F-BA39-DFE82FE6FC30@nicira.com>
References: <20151002101822.12499.27658.stgit@buzz> <56128238.8010305@suse.cz> <5612DCC8.4040605@gmail.com> <CAEP_g=9JB2GptbZn9ayTPRGPbuOvVujCQ1Hui7fOijUX10HURg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jesse Gross <jesse@nicira.com>
Cc: Alexander Duyck <alexander.duyck@gmail.com>, Vlastimil Babka <vbabka@suse.cz>, Konstantin Khlebnikov <khlebnikov@yandex-team.ru>, "dev@openvswitch.org" <dev@openvswitch.org>, Pravin Shelar <pshelar@nicira.com>, "David S. Miller" <davem@davemloft.net>, netdev <netdev@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org


> On Oct 6, 2015, at 6:01 PM, Jesse Gross <jesse@nicira.com> wrote:
>=20
> On Mon, Oct 5, 2015 at 1:25 PM, Alexander Duyck
> <alexander.duyck@gmail.com> wrote:
>> On 10/05/2015 06:59 AM, Vlastimil Babka wrote:
>>>=20
>>> On 10/02/2015 12:18 PM, Konstantin Khlebnikov wrote:
>>>>=20
>>>> When openvswitch tries allocate memory from offline numa node 0:
>>>> stats =3D kmem_cache_alloc_node(flow_stats_cache, GFP_KERNEL | =
__GFP_ZERO,
>>>> 0)
>>>> It catches VM_BUG_ON(nid < 0 || nid >=3D MAX_NUMNODES || =
!node_online(nid))
>>>> [ replaced with VM_WARN_ON(!node_online(nid)) recently ] in =
linux/gfp.h
>>>> This patch disables numa affinity in this case.
>>>>=20
>>>> Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
>>>=20
>>>=20
>>> ...
>>>=20
>>>> diff --git a/net/openvswitch/flow_table.c =
b/net/openvswitch/flow_table.c
>>>> index f2ea83ba4763..c7f74aab34b9 100644
>>>> --- a/net/openvswitch/flow_table.c
>>>> +++ b/net/openvswitch/flow_table.c
>>>> @@ -93,7 +93,8 @@ struct sw_flow *ovs_flow_alloc(void)
>>>>=20
>>>>      /* Initialize the default stat node. */
>>>>      stats =3D kmem_cache_alloc_node(flow_stats_cache,
>>>> -                      GFP_KERNEL | __GFP_ZERO, 0);
>>>> +                      GFP_KERNEL | __GFP_ZERO,
>>>> +                      node_online(0) ? 0 : NUMA_NO_NODE);
>>>=20
>>>=20
>>> Stupid question: can node 0 become offline between this check, and =
the
>>> VM_WARN_ON? :) BTW what kind of system has node 0 offline?
>>=20
>>=20
>> Another question to ask would be is it possible for node 0 to be =
online, but
>> be a memoryless node?
>>=20
>> I would say you are better off just making this call =
kmem_cache_alloc.  I
>> don't see anything that indicates the memory has to come from node 0, =
so
>> adding the extra overhead doesn't provide any value.
>=20
> I agree that this at least makes me wonder, though I actually have
> concerns in the opposite direction - I see assumptions about this
> being on node 0 in net/openvswitch/flow.c.
>=20
> Jarno, since you original wrote this code, can you take a look to see
> if everything still makes sense?

We keep the pre-allocated stats node at array index 0, which is =
initially used by all CPUs, but if CPUs from multiple numa nodes start =
updating the stats, we allocate additional stats nodes (up to one per =
numa node), and the CPUs on node 0 keep using the preallocated entry. If =
stats cannot be allocated from CPUs local node, then those CPUs keep =
using the entry at index 0. Currently the code in net/openvswitch/flow.c =
will try to allocate the local memory repeatedly, which may not be =
optimal when there is no memory at the local node.

Allocating the memory for the index 0 from other than node 0, as =
discussed here, just means that the CPUs on node 0 will keep on using =
non-local memory for stats. In a scenario where there are CPUs on two =
nodes (0, 1), but only the node 1 has memory, a shared flow entry will =
still end up having separate memory allocated for both nodes, but both =
of the nodes would be at node 1. However, there is still a high =
likelihood that the memory allocations would not share a cache line, =
which should prevent the nodes from invalidating each other=E2=80=99s =
caches. Based on this I do not see a problem relaxing the memory =
allocation for the default stats node. If node 0 has memory, however, it =
would be better to allocate the memory from node 0.

  Jarno

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
