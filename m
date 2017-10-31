Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id E5D316B0033
	for <linux-mm@kvack.org>; Tue, 31 Oct 2017 07:28:47 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id n14so14559176pfh.15
        for <linux-mm@kvack.org>; Tue, 31 Oct 2017 04:28:47 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 15si1414159pld.802.2017.10.31.04.28.46
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 31 Oct 2017 04:28:46 -0700 (PDT)
Subject: Re: [PATCH RFC v2 3/4] mm/mempolicy: fix the check of nodemask from
 user
References: <1509099265-30868-1-git-send-email-xieyisheng1@huawei.com>
 <1509099265-30868-4-git-send-email-xieyisheng1@huawei.com>
 <56c4cdbf-c228-6203-285c-15f19a841538@suse.cz>
 <65c0e6cb-28b4-f202-1d7f-278b5dfc3440@huawei.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <1e0f1e50-4900-78d2-6586-bd68f5849337@suse.cz>
Date: Tue, 31 Oct 2017 12:28:41 +0100
MIME-Version: 1.0
In-Reply-To: <65c0e6cb-28b4-f202-1d7f-278b5dfc3440@huawei.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yisheng Xie <xieyisheng1@huawei.com>, akpm@linux-foundation.org, mhocko@suse.com, mingo@kernel.org, rientjes@google.com, n-horiguchi@ah.jp.nec.com, salls@cs.ucsb.edu
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, tanxiaojun@huawei.com, linux-api@vger.kernel.org

On 10/31/2017 12:01 PM, Yisheng Xie wrote:
> 
> 
> On 2017/10/31 17:30, Vlastimil Babka wrote:
>> On 10/27/2017 12:14 PM, Yisheng Xie wrote:
>>> +	/*
>>> +	 * When the user specified more nodes than supported just check
>>> +	 * if the non supported part is all zero.
>>> +	 *
>>> +	 * If maxnode have more longs than MAX_NUMNODES, check
>>> +	 * the bits in that area first. And then go through to
>>> +	 * check the rest bits which equal or bigger than MAX_NUMNODES.
>>> +	 * Otherwise, just check bits [MAX_NUMNODES, maxnode).
>>> +	 */
>>>  	if (nlongs > BITS_TO_LONGS(MAX_NUMNODES)) {
>>>  		for (k = BITS_TO_LONGS(MAX_NUMNODES); k < nlongs; k++) {
>>> -			unsigned long t;
>>>  			if (get_user(t, nmask + k))
>>>  				return -EFAULT;
>>>  			if (k == nlongs - 1) {
>>> @@ -1294,6 +1301,16 @@ static int get_nodes(nodemask_t *nodes, const unsigned long __user *nmask,
>>>  		endmask = ~0UL;
>>>  	}
>>>  
>>> +	if (maxnode > MAX_NUMNODES && MAX_NUMNODES % BITS_PER_LONG != 0) {
>>> +		unsigned long valid_mask = endmask;
>>> +
>>> +		valid_mask &= ~((1UL << (MAX_NUMNODES % BITS_PER_LONG)) - 1);
>>
>> I'm not sure if the combination with endmask works in this case:
>>
>> 0      BITS_PER_LONG  2xBITS_PER_LONG
>> |____________|____________|
>>        |             |
>>   MAX_NUMNODES      maxnode
>>
>> endmask will contain bits between 0 and maxnode
> 
> In the case, BITS_TO_LONGS(maxnode) > BITS_TO_LONGS(MAX_NUMNODES), right?
> And after checking BITS_PER_LONG to 2xBITS_PER_LONGi 1/4 ?endmask will set to
> "~0UL". e.g. endmask will be 0xffff ffff ffff ffff if
> unsigned long is 64bit.
> 
> Then the valid_mask will just contain bits MAX_NUMNODES to BITS_PER_LONG.

Ugh, right. I missed that. This code is not simple...

> Thanks
> Yisheng Xie
> 
>> but here we want to check bits between MAX_NUMNODES and BITS_PER_LONG
>> and endmask should not be mixed up with that?
>>
>>
>> Vlastimil
>>
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-api" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
