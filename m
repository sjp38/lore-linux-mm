Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id DF56F6B025E
	for <linux-mm@kvack.org>; Wed, 29 Nov 2017 14:09:34 -0500 (EST)
Received: by mail-it0-f71.google.com with SMTP id w125so3973926itf.0
        for <linux-mm@kvack.org>; Wed, 29 Nov 2017 11:09:34 -0800 (PST)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id l187si2082612itb.54.2017.11.29.11.09.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 29 Nov 2017 11:09:33 -0800 (PST)
Subject: Re: [PATCH RFC 1/2] mm, hugetlb: unify core page allocation
 accounting and initialization
References: <20171128101907.jtjthykeuefxu7gl@dhcp22.suse.cz>
 <20171128141211.11117-1-mhocko@kernel.org>
 <20171128141211.11117-2-mhocko@kernel.org>
 <4c919c6d-2e97-b66d-f572-439bb9f0587b@oracle.com>
 <20171129065732.lm4yucdnaizr2mjb@dhcp22.suse.cz>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <d30e03d2-6d36-1287-092e-91189fa658be@oracle.com>
Date: Wed, 29 Nov 2017 11:09:26 -0800
MIME-Version: 1.0
In-Reply-To: <20171129065732.lm4yucdnaizr2mjb@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, LKML <linux-kernel@vger.kernel.org>

On 11/28/2017 10:57 PM, Michal Hocko wrote:
> On Tue 28-11-17 13:34:53, Mike Kravetz wrote:
>> On 11/28/2017 06:12 AM, Michal Hocko wrote:
> [...]
>>> +/*
>>> + * Allocates a fresh page to the hugetlb allocator pool in the node interleaved
>>> + * manner.
>>> + */
>>>  static int alloc_fresh_huge_page(struct hstate *h, nodemask_t *nodes_allowed)
>>>  {
>>>  	struct page *page;
>>>  	int nr_nodes, node;
>>> -	int ret = 0;
>>> +	gfp_t gfp_mask = htlb_alloc_mask(h) | __GFP_THISNODE;
>>>  
>>>  	for_each_node_mask_to_alloc(h, nr_nodes, node, nodes_allowed) {
>>> -		page = alloc_fresh_huge_page_node(h, node);
>>> -		if (page) {
>>> -			ret = 1;
>>> +		page = __hugetlb_alloc_buddy_huge_page(h, gfp_mask,
>>> +				node, nodes_allowed);
>>
>> I don't have the greatest understanding of node/nodemasks, but ...
>> Since __hugetlb_alloc_buddy_huge_page calls __alloc_pages_nodemask(), do
>> we still need to explicitly iterate over nodes with
>> for_each_node_mask_to_alloc() here?
> 
> Yes we do, because callers depend on the round robin allocation policy
> which is implemented by the ugly for_each_node_mask_to_alloc. I am not
> saying I like the way this is done but this is user visible thing.

Ah, thanks.

I missed the __GFP_THISNODE.  Because of that, the nodes_allowed mask is
not used in the allocation attempts.  So, cycling through the nodes with
the for_each_node_mask_to_alloc makes sense.

> Or maybe I've missunderstood the whole thing...

No, this should preserve the original behavior.

-- 
Mike Kravetz

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
