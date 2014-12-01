Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 16A436B0069
	for <linux-mm@kvack.org>; Sun, 30 Nov 2014 20:18:34 -0500 (EST)
Received: by mail-pa0-f45.google.com with SMTP id lj1so9943838pab.18
        for <linux-mm@kvack.org>; Sun, 30 Nov 2014 17:18:33 -0800 (PST)
Received: from fgwmail5.fujitsu.co.jp (fgwmail5.fujitsu.co.jp. [192.51.44.35])
        by mx.google.com with ESMTPS id wb7si26529976pab.156.2014.11.30.17.18.31
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sun, 30 Nov 2014 17:18:32 -0800 (PST)
Received: from kw-mxoi2.gw.nic.fujitsu.com (unknown [10.0.237.143])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 41BCD3EE13E
	for <linux-mm@kvack.org>; Mon,  1 Dec 2014 10:18:30 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by kw-mxoi2.gw.nic.fujitsu.com (Postfix) with ESMTP id 3A062AC039A
	for <linux-mm@kvack.org>; Mon,  1 Dec 2014 10:18:29 +0900 (JST)
Received: from g01jpfmpwyt01.exch.g01.fujitsu.local (g01jpfmpwyt01.exch.g01.fujitsu.local [10.128.193.38])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id DA291E08002
	for <linux-mm@kvack.org>; Mon,  1 Dec 2014 10:18:28 +0900 (JST)
Message-ID: <547BC199.6070200@jp.fujitsu.com>
Date: Mon, 1 Dec 2014 10:17:13 +0900
From: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH] slab: Fix nodeid bounds check for non-contiguous node
 IDs
References: <20141130221606.GA25929@iris.ozlabs.ibm.com> <547BB2F0.5040708@jp.fujitsu.com> <20141201004210.GA11234@drongo>
In-Reply-To: <20141201004210.GA11234@drongo>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Paul Mackerras <paulus@samba.org>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Pekka Enberg <penberg@kernel.org>, linuxppc-dev@ozlabs.org, David Rientjes <rientjes@google.com>, Christoph Lameter <cl@linux.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

(2014/12/01 9:42), Paul Mackerras wrote:
> On Mon, Dec 01, 2014 at 09:14:40AM +0900, Yasuaki Ishimatsu wrote:
>> (2014/12/01 7:16), Paul Mackerras wrote:
>>> The bounds check for nodeid in ____cache_alloc_node gives false
>>> positives on machines where the node IDs are not contiguous, leading
>>> to a panic at boot time.  For example, on a POWER8 machine the node
>>> IDs are typically 0, 1, 16 and 17.  This means that num_online_nodes()
>>> returns 4, so when ____cache_alloc_node is called with nodeid = 16 the
>>> VM_BUG_ON triggers.
>>
>> Do you have the call trace? If you have it, please add it in the description.
>
> I can get it easily enough.
>
>>> To fix this, we instead compare the nodeid with MAX_NUMNODES, and
>>> additionally make sure it isn't negative (since nodeid is an int).
>>> The check is there mainly to protect the array dereference in the
>>> get_node() call in the next line, and the array being dereferenced is
>>> of size MAX_NUMNODES.  If the nodeid is in range but invalid, the
>>> BUG_ON in the next line will catch that.
>>>
>>> Signed-off-by: Paul Mackerras <paulus@samba.org>
>>
>> Do you need to backport it into -stable kernels?
>
> It does need to go to stable, yes, for 3.10 and later.
>
>>> ---
>>> diff --git a/mm/slab.c b/mm/slab.c
>>> index eb2b2ea..f34e053 100644
>>> --- a/mm/slab.c
>>> +++ b/mm/slab.c
>>> @@ -3076,7 +3076,7 @@ static void *____cache_alloc_node(struct kmem_cache *cachep, gfp_t flags,
>>>   	void *obj;
>>>   	int x;
>>>
>>

>>> -	VM_BUG_ON(nodeid > num_online_nodes());
>>> +	VM_BUG_ON(nodeid < 0 || nodeid >= MAX_NUMNODES);
>>
>> How about use:
>> 	VM_BUG_ON(!node_online(nodeid));
>
> That would not be better, since node_online() doesn't bounds-check its
> argument.
>

Ah. You are right.

>> When allocating the memory, the node of the memory being allocated must be
>> online. But your code cannot check the condition.
>
> The following two lines:
>
>>>   	n = get_node(cachep, nodeid);
>>>   	BUG_ON(!n);
>
> effectively check that condition already, as I tried to explain in the
> commit message.

O.K. I understood.

Thansk,
Yasuaki Ishimatsu

>
> Regards,
> Paul.
>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
