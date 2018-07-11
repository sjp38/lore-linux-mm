Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id D773D6B0007
	for <linux-mm@kvack.org>; Wed, 11 Jul 2018 12:47:33 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id c27-v6so29832930qkj.3
        for <linux-mm@kvack.org>; Wed, 11 Jul 2018 09:47:33 -0700 (PDT)
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id x9-v6si1567244qka.303.2018.07.11.09.47.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 Jul 2018 09:47:32 -0700 (PDT)
Subject: Re: [PATCH] mm: hugetlb: don't zero 1GiB bootmem pages.
References: <20180710184903.68239-1-cannonmatthews@google.com>
 <20180711124711.GA20172@dhcp22.suse.cz>
 <20180711124801.GO20050@dhcp22.suse.cz>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <3f639e81-f8d2-5010-4a4b-331d198b1ce9@oracle.com>
Date: Wed, 11 Jul 2018 09:47:25 -0700
MIME-Version: 1.0
In-Reply-To: <20180711124801.GO20050@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Cannon Matthews <cannonmatthews@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Nadia Yvette Chambers <nyc@holomorphy.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, andreslc@google.com, pfeiner@google.com, dmatlack@google.com, gthelen@google.com

On 07/11/2018 05:48 AM, Michal Hocko wrote:
> On Wed 11-07-18 14:47:11, Michal Hocko wrote:
>> On Tue 10-07-18 11:49:03, Cannon Matthews wrote:
>>> When using 1GiB pages during early boot, use the new
>>> memblock_virt_alloc_try_nid_raw() function to allocate memory without
>>> zeroing it.  Zeroing out hundreds or thousands of GiB in a single core
>>> memset() call is very slow, and can make early boot last upwards of
>>> 20-30 minutes on multi TiB machines.
>>>
>>> To be safe, still zero the first sizeof(struct boomem_huge_page) bytes
>>> since this is used a temporary storage place for this info until
>>> gather_bootmem_prealloc() processes them later.
>>>
>>> The rest of the memory does not need to be zero'd as the hugetlb pages
>>> are always zero'd on page fault.
>>>
>>> Tested: Booted with ~3800 1G pages, and it booted successfully in
>>> roughly the same amount of time as with 0, as opposed to the 25+
>>> minutes it would take before.
>>
>> The patch makes perfect sense to me. I wasn't even aware that it
>> zeroying memblock allocation. Thanks for spotting this and fixing it.
>>
>>> Signed-off-by: Cannon Matthews <cannonmatthews@google.com>
>>
>> I just do not think we need to to zero huge_bootmem_page portion of it.
>> It should be sufficient to INIT_LIST_HEAD before list_add. We do
>> initialize the rest explicitly already.
> 
> Forgot to mention that after that is addressed you can add
> Acked-by: Michal Hocko <mhocko@suse.com>

Cannon,

How about if you make this change suggested by Michal, and I will submit
a separate patch to revert the patch which added the phys field to
huge_bootmem_page structure.

FWIW,
Reviewed-by: Mike Kravetz <mike.kravetz@oracle.com>

-- 
Mike Kravetz
