Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id DFD946B0038
	for <linux-mm@kvack.org>; Wed,  1 Mar 2017 11:34:31 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id u62so53658095pfk.1
        for <linux-mm@kvack.org>; Wed, 01 Mar 2017 08:34:31 -0800 (PST)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id w21si5005301pgf.318.2017.03.01.08.34.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 Mar 2017 08:34:30 -0800 (PST)
Subject: Re: [PATCH v2 1/3] sparc64: NG4 memset 32 bits overflow
References: <1488327283-177710-1-git-send-email-pasha.tatashin@oracle.com>
 <1488327283-177710-2-git-send-email-pasha.tatashin@oracle.com>
 <87h93dhmir.fsf@firstfloor.org>
 <70b638b0-8171-ffce-c0c5-bdcbae3c7c46@oracle.com>
 <20170301151910.GH26852@two.firstfloor.org>
From: Pasha Tatashin <pasha.tatashin@oracle.com>
Message-ID: <6a26815d-0ec2-7922-7202-b1e17d58aa00@oracle.com>
Date: Wed, 1 Mar 2017 11:34:10 -0500
MIME-Version: 1.0
In-Reply-To: <20170301151910.GH26852@two.firstfloor.org>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: linux-mm@kvack.org, sparclinux@vger.kernel.org

Hi Andi,

Thank you for your comment, I am thinking to limit the default maximum 
hash tables sizes to 512M.

If it is bigger than 512M, we would still need my patch to improve the 
performance. This is because it would mean that initialization of hash 
tables would still take over 1s out of 6s in bootload to smp_init() 
interval on larger machines.

I am not sure HASH_ZERO is a hack because if you look at the way 
pv_lock_hash is allocated, it assumes that the memory is already zeroed 
since it provides HASH_EARLY flag. It quietly assumes that the memblock 
boot allocator zeroes the memory for us. On the other hand, in other 
places where HASH_EARLY is specified we still explicitly zero the 
hashes. At least with HASH_ZERO flag this becomes a defined interface, 
and in the future if memblock allocator is changed to zero memory only 
on demand (as it really should), the HASH_ZERO flag can be passed there 
the same way it is passed to vmalloc() in my patch.

Does something like this look OK to you? If yes, I will send out a new 
patch.


  index 1b0f7a4..5ddf741 100644
  --- a/mm/page_alloc.c
  +++ b/mm/page_alloc.c
  @@ -79,6 +79,12 @@
   EXPORT_PER_CPU_SYMBOL(numa_node);
   #endif

  +/*
  + * This is the default maximum number of entries system hashes can 
have, the
  + * value can be overwritten by setting hash table sizes via kernel 
parameters.
  + */
  +#define SYSTEM_HASH_MAX_ENTRIES                (1 << 26)
  +
   #ifdef CONFIG_HAVE_MEMORYLESS_NODES
   /*
    * N.B., Do NOT reference the '_numa_mem_' per cpu variable directly.
  @@ -7154,6 +7160,11 @@ static unsigned long __init 
arch_reserved_kernel_pages(void)
                  if (PAGE_SHIFT < 20)
                          numentries = round_up(numentries, 
(1<<20)/PAGE_SIZE);

  +               /* Limit default maximum number of entries */
  +               if (numentries > SYSTEM_HASH_MAX_ENTRIES) {
  +                       numentries = SYSTEM_HASH_MAX_ENTRIES;
  +               }
  +
                  /* limit to 1 bucket per 2^scale bytes of low memory */
                  if (scale > PAGE_SHIFT)
                          numentries >>= (scale - PAGE_SHIFT);

Thank you
Pasha

On 2017-03-01 10:19, Andi Kleen wrote:
>> - Even if the default maximum size is reduced the size of these
>> tables should still be tunable, as it really depends on the way
>> machine is used, and in it is possible that for some use patterns
>> large hash tables are necessary.
>
> I consider it very unlikely that a 8G dentry hash table ever makes
> sense. I cannot even imagine a workload where you would have that
> many active files. It's just a bad configuration that should be avoided.
>
> And when the tables are small enough you don't need these hacks.
>
> -Andi
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
