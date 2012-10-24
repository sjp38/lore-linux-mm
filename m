Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx126.postini.com [74.125.245.126])
	by kanga.kvack.org (Postfix) with SMTP id 246BB6B006E
	for <linux-mm@kvack.org>; Wed, 24 Oct 2012 03:04:19 -0400 (EDT)
Message-ID: <50879380.2080703@cn.fujitsu.com>
Date: Wed, 24 Oct 2012 15:06:40 +0800
From: Lai Jiangshan <laijs@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/3] slub, hotplug: ignore unrelated node's hot-adding
 and hot-removing
References: <1348728470-5580-1-git-send-email-laijs@cn.fujitsu.com> <1348728470-5580-3-git-send-email-laijs@cn.fujitsu.com> <5064CD7F.1040507@gmail.com> <0000013a09dec004-497e7afa-8c0f-46ff-bf8e-056f7df1ed0b-000000@email.amazonses.com> <50654F6E.7090000@cn.fujitsu.com> <CAHGf_=pUMDm2M2wGvnsqrDgnhj0oHUO4JVuG=u3Qcn3TLvGRgg@mail.gmail.com>
In-Reply-To: <CAHGf_=pUMDm2M2wGvnsqrDgnhj0oHUO4JVuG=u3Qcn3TLvGRgg@mail.gmail.com>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Cc: Christoph <cl@linux.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On 09/29/2012 06:26 AM, KOSAKI Motohiro wrote:
> On Fri, Sep 28, 2012 at 3:19 AM, Lai Jiangshan <laijs@cn.fujitsu.com> wrote:
>> HI, Christoph, KOSAKI
>>
>> SLAB always allocates kmem_list3 for all nodes(N_HIGH_MEMORY), also node bug/bad things happens.
>> SLUB always requires kmem_cache_node on the correct node, so these fix is needed.
>>
>> SLAB uses for_each_online_node() to travel nodes and do maintain,
>> and it tolerates kmem_list3 on alien nodes.
>> SLUB uses for_each_node_state(node, N_NORMAL_MEMORY) to travel nodes and do maintain,
>> and it does not tolerate kmem_cache_node on alien nodes.
>>
>> Maybe we need to change SLAB future and let it use
>> for_each_node_state(node, N_NORMAL_MEMORY), But I don't want to change SLAB
>> until I find something bad in SLAB.
> 
> SLAB can't use highmem. then traverse zones which don't have normal
> memory is silly IMHO.

SLAB tolerates dummy kmem_list3 on alien nodes.

> If this is not bug, current slub behavior is also not bug. Is there
> any difference?

SLUB can't tolerates dummy kmem_cache_node on alien nodes, otherwise
n->nr_slabs will be corrupted when we online a node which don't have normal memory,
and trigger a WARN_ON(). And it will trigger BUG_ON() when we remove the node.

Since SLUB always use for_each_node_state(node, N_NORMAL_MEMORY), we should make
all the other code in slub.c be compatible with it. otherwise we will break the
design of SLUB.

Since SLAB always use for_each_online_node(), it means it accept some silly behavior
in the design, we don't need to change it before we decide to remove the whole
silly things at together. there is not waring and buggy in SLAB in this view.

> 
> If I understand correctly, current code may waste some additional
> memory on corner case. but it doesn't make memory leak both when slab
> and slub.
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
