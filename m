Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f175.google.com (mail-lb0-f175.google.com [209.85.217.175])
	by kanga.kvack.org (Postfix) with ESMTP id 9F9EA6B0253
	for <linux-mm@kvack.org>; Thu,  8 Oct 2015 19:03:33 -0400 (EDT)
Received: by lbos8 with SMTP id s8so62607990lbo.0
        for <linux-mm@kvack.org>; Thu, 08 Oct 2015 16:03:32 -0700 (PDT)
Received: from mail-lb0-f170.google.com (mail-lb0-f170.google.com. [209.85.217.170])
        by mx.google.com with ESMTPS id qv2si31544854lbb.0.2015.10.08.16.03.31
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Oct 2015 16:03:31 -0700 (PDT)
Received: by lbos8 with SMTP id s8so62607633lbo.0
        for <linux-mm@kvack.org>; Thu, 08 Oct 2015 16:03:31 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <FB2084BE-D591-415F-BA39-DFE82FE6FC30@nicira.com>
References: <20151002101822.12499.27658.stgit@buzz> <56128238.8010305@suse.cz>
 <5612DCC8.4040605@gmail.com> <CAEP_g=9JB2GptbZn9ayTPRGPbuOvVujCQ1Hui7fOijUX10HURg@mail.gmail.com>
 <FB2084BE-D591-415F-BA39-DFE82FE6FC30@nicira.com>
From: Jesse Gross <jesse@nicira.com>
Date: Thu, 8 Oct 2015 16:03:07 -0700
Message-ID: <CAEP_g=9bqj_CKMTvd4dHTS+J82u7idtqa_PFA9=-CmO2ZcUMow@mail.gmail.com>
Subject: Re: [ovs-dev] [PATCH] ovs: do not allocate memory from offline numa node
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jarno Rajahalme <jrajahalme@nicira.com>
Cc: Alexander Duyck <alexander.duyck@gmail.com>, Vlastimil Babka <vbabka@suse.cz>, Konstantin Khlebnikov <khlebnikov@yandex-team.ru>, "dev@openvswitch.org" <dev@openvswitch.org>, Pravin Shelar <pshelar@nicira.com>, "David S. Miller" <davem@davemloft.net>, netdev <netdev@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On Wed, Oct 7, 2015 at 10:47 AM, Jarno Rajahalme <jrajahalme@nicira.com> wr=
ote:
>
>> On Oct 6, 2015, at 6:01 PM, Jesse Gross <jesse@nicira.com> wrote:
>>
>> On Mon, Oct 5, 2015 at 1:25 PM, Alexander Duyck
>> <alexander.duyck@gmail.com> wrote:
>>> On 10/05/2015 06:59 AM, Vlastimil Babka wrote:
>>>>
>>>> On 10/02/2015 12:18 PM, Konstantin Khlebnikov wrote:
>>>>>
>>>>> When openvswitch tries allocate memory from offline numa node 0:
>>>>> stats =3D kmem_cache_alloc_node(flow_stats_cache, GFP_KERNEL | __GFP_=
ZERO,
>>>>> 0)
>>>>> It catches VM_BUG_ON(nid < 0 || nid >=3D MAX_NUMNODES || !node_online=
(nid))
>>>>> [ replaced with VM_WARN_ON(!node_online(nid)) recently ] in linux/gfp=
.h
>>>>> This patch disables numa affinity in this case.
>>>>>
>>>>> Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
>>>>
>>>>
>>>> ...
>>>>
>>>>> diff --git a/net/openvswitch/flow_table.c b/net/openvswitch/flow_tabl=
e.c
>>>>> index f2ea83ba4763..c7f74aab34b9 100644
>>>>> --- a/net/openvswitch/flow_table.c
>>>>> +++ b/net/openvswitch/flow_table.c
>>>>> @@ -93,7 +93,8 @@ struct sw_flow *ovs_flow_alloc(void)
>>>>>
>>>>>      /* Initialize the default stat node. */
>>>>>      stats =3D kmem_cache_alloc_node(flow_stats_cache,
>>>>> -                      GFP_KERNEL | __GFP_ZERO, 0);
>>>>> +                      GFP_KERNEL | __GFP_ZERO,
>>>>> +                      node_online(0) ? 0 : NUMA_NO_NODE);
>>>>
>>>>
>>>> Stupid question: can node 0 become offline between this check, and the
>>>> VM_WARN_ON? :) BTW what kind of system has node 0 offline?
>>>
>>>
>>> Another question to ask would be is it possible for node 0 to be online=
, but
>>> be a memoryless node?
>>>
>>> I would say you are better off just making this call kmem_cache_alloc. =
 I
>>> don't see anything that indicates the memory has to come from node 0, s=
o
>>> adding the extra overhead doesn't provide any value.
>>
>> I agree that this at least makes me wonder, though I actually have
>> concerns in the opposite direction - I see assumptions about this
>> being on node 0 in net/openvswitch/flow.c.
>>
>> Jarno, since you original wrote this code, can you take a look to see
>> if everything still makes sense?
>
> We keep the pre-allocated stats node at array index 0, which is initially=
 used by all CPUs, but if CPUs from multiple numa nodes start updating the =
stats, we allocate additional stats nodes (up to one per numa node), and th=
e CPUs on node 0 keep using the preallocated entry. If stats cannot be allo=
cated from CPUs local node, then those CPUs keep using the entry at index 0=
. Currently the code in net/openvswitch/flow.c will try to allocate the loc=
al memory repeatedly, which may not be optimal when there is no memory at t=
he local node.
>
> Allocating the memory for the index 0 from other than node 0, as discusse=
d here, just means that the CPUs on node 0 will keep on using non-local mem=
ory for stats. In a scenario where there are CPUs on two nodes (0, 1), but =
only the node 1 has memory, a shared flow entry will still end up having se=
parate memory allocated for both nodes, but both of the nodes would be at n=
ode 1. However, there is still a high likelihood that the memory allocation=
s would not share a cache line, which should prevent the nodes from invalid=
ating each other=E2=80=99s caches. Based on this I do not see a problem rel=
axing the memory allocation for the default stats node. If node 0 has memor=
y, however, it would be better to allocate the memory from node 0.

Thanks for going through all of that.

It seems like the question that is being raised is whether it actually
makes sense to try to get the initial memory on node 0, especially
since it seems to introduce some corner cases? Is there any reason why
the flow is more likely to hit node 0 than a randomly chosen one?
(Assuming that this is a multinode system, otherwise it's kind of a
moot point.) We could have a separate pointer to the default allocated
memory, so it wouldn't conflict with memory that was intentionally
allocated for node 0.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
