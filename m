Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 2409D6B0282
	for <linux-mm@kvack.org>; Thu, 12 Oct 2017 05:14:05 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id 136so5338235wmu.3
        for <linux-mm@kvack.org>; Thu, 12 Oct 2017 02:14:05 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a18si1635699wrh.259.2017.10.12.02.14.03
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 12 Oct 2017 02:14:03 -0700 (PDT)
Subject: Re: [PATCH v1] mm/mempolicy.c: Fix get_nodes() off-by-one error.
References: <1507296994-175620-1-git-send-email-luis.felipe.sandoval.castro@intel.com>
 <1507296994-175620-2-git-send-email-luis.felipe.sandoval.castro@intel.com>
 <20171012084633.ipr5cfxsrs3lyb5n@dhcp22.suse.cz>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <63ccc890-fd57-118b-5997-e0259f507d28@suse.cz>
Date: Thu, 12 Oct 2017 11:14:02 +0200
MIME-Version: 1.0
In-Reply-To: <20171012084633.ipr5cfxsrs3lyb5n@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Luis Felipe Sandoval Castro <luis.felipe.sandoval.castro@intel.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, mingo@kernel.org, rientjes@google.com, n-horiguchi@ah.jp.nec.com, salls@cs.ucsb.edu, Cristopher Lameter <cl@linux.com>, Andi Kleen <ak@linux.intel.com>

On 10/12/2017 10:46 AM, Michal Hocko wrote:
> [CC Christoph who seems to be the author of the code]
> 
> I would also note that a single patch rarely requires a separate cover
> letter. If there is an information which is not suitable for the
> changelog then you can place it in the diffstate area.
> 
> On Fri 06-10-17 08:36:34, Luis Felipe Sandoval Castro wrote:
>> set_mempolicy() and mbind() take as argument a pointer to a bit mask
>> (nodemask) and the number of bits in the mask the kernel will use
>> (maxnode), among others.  For instace on a system with 2 NUMA nodes valid
>> masks are: 0b00, 0b01, 0b10 and 0b11 it's clear maxnode=2, however an
>> off-by-one error in get_nodes() the function that copies the node mask from
>> user space requires users to pass maxnode = 3 in this example and maxnode =
>> actual_maxnode + 1 in the general case. This patch fixes such error.
> 
> man page of mbind says this
> : nodemask points to a bit mask of nodes containing up to maxnode bits.
> : The bit mask size is rounded to the next multiple of sizeof(unsigned
> : long), but the kernel will use bits only up to maxnode.
> 
> The definition is rather unfortunate. My understanding is that maxnode==1
> will result in copying only bit 0, maxnode==2 will result bits 0 and 1
> being copied. This would be consistent with

But that's not what really happens, it seems? The commit log says you
need to pass maxnode == 3 to get bits 0 and 1. Actually, the unfortunate
"bits only up to maxnode" description would suggest an off-by-one error
in the opposite direction, i.e. maxnode == 3 copying bits 0 up to 3,
thus 4 bits.

> : A NULL value of nodemask or a maxnode value of zero specifies the
> : empty set of nodes.  If the value of maxnode is zero, the nodemask
> : argument is ignored.
> 
> where maxnode==0 means an empty mask. While maxnode==0 will return
> EINVAL AFAICS so it clearly breaks the above wording.
> 
> mbind(0x7ff990b83000, 4096, MPOL_BIND, {}, 0, MPOL_MF_MOVE) = -1 EINVAL (Invalid argument)
> 
> This has been broken for ages and I suspect that tools have found their
> way around that. E.g.
> $ strace -e set_mempolicy numactl --membind=0,1 sleep 1s
> set_mempolicy(MPOL_BIND, 0x21753b0, 1025) = 0

And this is I think the reason why we can't change this now. I assume
numactl allocates 1024 bits (0 to 1023) and passes 1025 to make sure all
1024 bits are processed. If we change it now, kernel will process 1025
bits (0 to 1024) and overflow the allocated bitmask. If it happens to be
at the border of mmaped vma, it's a segfault...

> I assume that the existing userspace simply does the same thing. Pre
> zeros the whole mask with the maxnode being set to the maximum possible
> NUMA nodes.
> 
> Your patch seems broken in the similar way AFAICS. maxnode==1 shouldn't
> be any special.
> 
> Andi has voiced a concern about backward compatibility but I am not sure
> the risk is very high. The current behavior is simply broken unless you
> use a large maxnode anyway. What kind of breakage would you envision
> Andi?
> 
>> Signed-off-by: Luis Felipe Sandoval Castro <luis.felipe.sandoval.castro@intel.com>
>> ---
>>  mm/mempolicy.c | 5 ++---
>>  1 file changed, 2 insertions(+), 3 deletions(-)
>>
>> diff --git a/mm/mempolicy.c b/mm/mempolicy.c
>> index 006ba62..0c2e3cd 100644
>> --- a/mm/mempolicy.c
>> +++ b/mm/mempolicy.c
>> @@ -1265,11 +1265,10 @@ static int get_nodes(nodemask_t *nodes, const unsigned long __user *nmask,
>>  	unsigned long nlongs;
>>  	unsigned long endmask;
>>  
>> -	--maxnode;
>>  	nodes_clear(*nodes);
>> -	if (maxnode == 0 || !nmask)
>> +	if (maxnode == 1 || !nmask)
>>  		return 0;
>> -	if (maxnode > PAGE_SIZE*BITS_PER_BYTE)
>> +	if (maxnode - 1 > PAGE_SIZE * BITS_PER_BYTE)
>>  		return -EINVAL;
>>  
>>  	nlongs = BITS_TO_LONGS(maxnode);
>> -- 
>> 1.8.3.1
>>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
