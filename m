Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id DB8DD6B0038
	for <linux-mm@kvack.org>; Fri,  6 Jan 2017 12:18:17 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id s63so4480537wms.7
        for <linux-mm@kvack.org>; Fri, 06 Jan 2017 09:18:17 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 60si705096wre.208.2017.01.06.09.18.16
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 06 Jan 2017 09:18:16 -0800 (PST)
Subject: Re: __GFP_REPEAT usage in fq_alloc_node
References: <20170106152052.GS5556@dhcp22.suse.cz>
 <CANn89i+QZs0cSPK21qMe6LXw+AeAMZ_tKEDUEnCsJ_cd+q0t-g@mail.gmail.com>
 <20901069-5eb7-f5ff-0641-078635544531@suse.cz>
 <CANn89iLy2KMUu80KekhvO31G4uXr4B0K8zvGjhfyBBp9d_ncBg@mail.gmail.com>
 <97be60da-72df-ad8f-db03-03f01c392823@suse.cz>
 <CANn89i+pRwa3KES1ane4ZfBpw4Y7Ne5OLZmkt=K8n5E6qF9xvA@mail.gmail.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <e37eda74-e796-ff45-4c26-0c56bdf74967@suse.cz>
Date: Fri, 6 Jan 2017 18:18:15 +0100
MIME-Version: 1.0
In-Reply-To: <CANn89i+pRwa3KES1ane4ZfBpw4Y7Ne5OLZmkt=K8n5E6qF9xvA@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric Dumazet <edumazet@google.com>
Cc: Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On 01/06/2017 06:08 PM, Eric Dumazet wrote:
> On Fri, Jan 6, 2017 at 8:55 AM, Vlastimil Babka <vbabka@suse.cz> wrote:
>> On 01/06/2017 05:48 PM, Eric Dumazet wrote:
>>> On Fri, Jan 6, 2017 at 8:31 AM, Vlastimil Babka <vbabka@suse.cz> wrote:
>>>
>>>>
>>>> I wonder what's that cause of the penalty (when accessing the vmapped
>>>> area I suppose?) Is it higher risk of collisions cache misses within the
>>>> area, compared to consecutive physical adresses?
>>>
>>> I believe tests were done with 48 fq qdisc, each having 2^16 slots.
>>> So I had 48 blocs,of 524288 bytes.
>>>
>>> Trying a bit harder at setup time to get 128 consecutive pages got
>>> less TLB pressure.
>>
>> Hmm that's rather surprising to me. TLB caches the page table lookups
>> and the PFN's of the physical pages it translates to shouldn't matter -
>> the page tables will look the same. With 128 consecutive pages could
>> manifest the reduced collision cache miss effect though.
>>
> 
> To be clear, the difference came from :
> 
> Using kmalloc() to allocate 48 x 524288 bytes
> 
> Or using vmalloc()
> 
> Are you telling me HugePages are not in play there ?

Oh that's certainly a difference, as kmalloc() will give you the kernel
mapping which can use 1GB Hugepages. But if you just combine these
kmalloc chunks into vmalloc mapping (IIUC that's what your RFC was
doing?), you lose that benefit AFAIK. On the other hand I recall reading
that AMD Zen will have PTE Coalescing [1] which, if true and I
understand that correctly, would indeed result in better TLB usage with
adjacent page table entries pointing to consecutive pages. But perhaps
the starting pte's position will also have to be aligned to make this
work, dunno.

[1]
http://www.anandtech.com/show/10591/amd-zen-microarchiture-part-2-extracting-instructionlevel-parallelism/6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
