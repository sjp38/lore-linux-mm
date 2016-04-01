Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f44.google.com (mail-wm0-f44.google.com [74.125.82.44])
	by kanga.kvack.org (Postfix) with ESMTP id DFBD66B007E
	for <linux-mm@kvack.org>; Fri,  1 Apr 2016 04:42:58 -0400 (EDT)
Received: by mail-wm0-f44.google.com with SMTP id f198so16264812wme.0
        for <linux-mm@kvack.org>; Fri, 01 Apr 2016 01:42:58 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 189si33833699wmi.4.2016.04.01.01.42.57
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 01 Apr 2016 01:42:57 -0700 (PDT)
Subject: Re: [PATCH] mm: fix invalid node in alloc_migrate_target()
References: <56F4E104.9090505@huawei.com>
 <20160325122237.4ca4e0dbca215ccbf4f49922@linux-foundation.org>
 <56FA7DC8.4000902@suse.cz> <56FD2285.4080600@suse.cz>
 <20160331140124.481acb67ef8f7356778cc4a0@linux-foundation.org>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <56FE348C.2010404@suse.cz>
Date: Fri, 1 Apr 2016 10:42:52 +0200
MIME-Version: 1.0
In-Reply-To: <20160331140124.481acb67ef8f7356778cc4a0@linux-foundation.org>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Xishi Qiu <qiuxishi@huawei.com>, Joonsoo Kim <js1304@gmail.com>, David Rientjes <rientjes@google.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Laura Abbott <lauraa@codeaurora.org>, zhuhui@xiaomi.com, wangxq10@lzu.edu.cn, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 03/31/2016 11:01 PM, Andrew Morton wrote:
> On Thu, 31 Mar 2016 15:13:41 +0200 Vlastimil Babka <vbabka@suse.cz> wrote:
>
>> On 03/29/2016 03:06 PM, Vlastimil Babka wrote:
>> > On 03/25/2016 08:22 PM, Andrew Morton wrote:
>> >> Also, mm/mempolicy.c:offset_il_node() worries me:
>> >>
>> >> 	do {
>> >> 		nid = next_node(nid, pol->v.nodes);
>> >> 		c++;
>> >> 	} while (c <= target);
>> >>
>> >> Can't `nid' hit MAX_NUMNODES?
>> >
>> > AFAICS it can. interleave_nid() uses this and the nid is then used e.g.
>> > in node_zonelist() where it's used for NODE_DATA(nid). That's quite
>> > scary. It also predates git. Why don't we see crashes or KASAN finding this?
>>
>> Ah, I see. In offset_il_node(), nid is initialized to -1, and the number
>> of do-while iterations calling next_node() is up to the number of bits
>> set in the pol->v.nodes bitmap, so it can't reach past the last set bit
>> and return MAX_NUMNODES.
>
> Gack.  offset_il_node() should be dragged out, strangled, shot then burnt.

Ah, but you went with the much less amusing alternative of just fixing it.

> static unsigned offset_il_node(struct mempolicy *pol,
> 		struct vm_area_struct *vma, unsigned long off)
> {
> 	unsigned nnodes = nodes_weight(pol->v.nodes);
> 	unsigned target;
> 	int c;
> 	int nid = NUMA_NO_NODE;
>
> 	if (!nnodes)
> 		return numa_node_id();
> 	target = (unsigned int)off % nnodes;
> 	c = 0;
> 	do {
> 		nid = next_node(nid, pol->v.nodes);
> 		c++;
> 	} while (c <= target);
> 	return nid;
> }
>
> For starters it is relying upon next_node(-1, ...) behaving like
> first_node().  Fair enough I guess, but that isn't very clear.
>
> static inline int __next_node(int n, const nodemask_t *srcp)
> {
> 	return min_t(int,MAX_NUMNODES,find_next_bit(srcp->bits, MAX_NUMNODES, n+1));
> }
>
> will start from node 0 when it does the n+1.
>
> Also it is relying upon NUMA_NO_NODE having a value of -1.  That's just
> grubby - this code shouldn't "know" that NUMA_NO_NODE==-1.  It would have
> been better to use plain old "-1" here.

Yeah looks like a blind change of all "-1" to "NUMA_NO_NODE" happened at some point.

>
> Does this look clearer and correct?

Definitely.

> /*
>   * Do static interleaving for a VMA with known offset @n.  Returns the n'th
>   * node in pol->v.nodes (starting from n=0), wrapping around if n exceeds the
>   * number of present nodes.
>   */
> static unsigned offset_il_node(struct mempolicy *pol,
> 			       struct vm_area_struct *vma, unsigned long n)
> {
> 	unsigned nnodes = nodes_weight(pol->v.nodes);
> 	unsigned target;
> 	int i;
> 	int nid;
>
> 	if (!nnodes)
> 		return numa_node_id();
> 	target = (unsigned int)n % nnodes;
> 	nid = first_node(pol->v.nodes);
> 	for (i = 0; i < target; i++)
> 		nid = next_node(nid, pol->v.nodes);
> 	return nid;
> }
>
>
> From: Andrew Morton <akpm@linux-foundation.org>
> Subject: mm/mempolicy.c:offset_il_node() document and clarify
>
> This code was pretty obscure and was relying upon obscure side-effects of
> next_node(-1, ...) and was relying upon NUMA_NO_NODE being equal to -1.
>
> Clean that all up and document the function's intent.
>
> Cc: Vlastimil Babka <vbabka@suse.cz>
> Cc: Xishi Qiu <qiuxishi@huawei.com>
> Cc: Joonsoo Kim <js1304@gmail.com>
> Cc: David Rientjes <rientjes@google.com>
> Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Cc: Laura Abbott <lauraa@codeaurora.org>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

Acked-by: Vlastimil Babka <vbabka@suse.cz>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
