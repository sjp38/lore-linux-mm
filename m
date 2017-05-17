Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 372986B02C4
	for <linux-mm@kvack.org>; Wed, 17 May 2017 11:51:16 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id k74so5900428qke.4
        for <linux-mm@kvack.org>; Wed, 17 May 2017 08:51:16 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id e23si2554128qte.304.2017.05.17.08.51.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 May 2017 08:51:15 -0700 (PDT)
Subject: Re: [PATCH v3 4/4] mm: Adaptive hash table scaling
References: <1488432825-92126-1-git-send-email-pasha.tatashin@oracle.com>
 <1488432825-92126-5-git-send-email-pasha.tatashin@oracle.com>
 <20170303153247.f16a31c95404c02a8f3e2c5f@linux-foundation.org>
From: Pasha Tatashin <pasha.tatashin@oracle.com>
Message-ID: <d81f09ec-ec1e-4ac5-3d06-3a18bfa75e32@oracle.com>
Date: Wed, 17 May 2017 11:51:06 -0400
MIME-Version: 1.0
In-Reply-To: <20170303153247.f16a31c95404c02a8f3e2c5f@linux-foundation.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, sparclinux@vger.kernel.org, linux-fsdevel@vger.kernel.org, Al Viro <viro@zeniv.linux.org.uk>



On 03/03/2017 06:32 PM, Andrew Morton wrote:
> On Thu,  2 Mar 2017 00:33:45 -0500 Pavel Tatashin <pasha.tatashin@oracle.com> wrote:
> 
>> Allow hash tables to scale with memory but at slower pace, when HASH_ADAPT
>> is provided every time memory quadruples the sizes of hash tables will only
>> double instead of quadrupling as well. This algorithm starts working only
>> when memory size reaches a certain point, currently set to 64G.
>>
>> This is example of dentry hash table size, before and after four various
>> memory configurations:
>>
>> MEMORY	   SCALE	 HASH_SIZE
>> 	old	new	old	new
>>      8G	 13	 13      8M      8M
>>     16G	 13	 13     16M     16M
>>     32G	 13	 13     32M     32M
>>     64G	 13	 13     64M     64M
>>    128G	 13	 14    128M     64M
>>    256G	 13	 14    256M    128M
>>    512G	 13	 15    512M    128M
>>   1024G	 13	 15   1024M    256M
>>   2048G	 13	 16   2048M    256M
>>   4096G	 13	 16   4096M    512M
>>   8192G	 13	 17   8192M    512M
>> 16384G	 13	 17  16384M   1024M
>> 32768G	 13	 18  32768M   1024M
>> 65536G	 13	 18  65536M   2048M
> 
> OK, but what are the runtime effects?  Presumably some workloads will
> slow down a bit.  How much? How do we know that this is a worthwhile
> tradeoff?
> 
> If the effect of this change is "undetectable" then those hash tables
> are simply too large, and additional tuning is needed, yes?
> 
Hi Andrew,

The effect of this change on runtime is undetectable as filesystem 
growth is not proportional to machine memory size as what is currently 
assumed. The change effects only large memory machine. Additional tuning 
might be needed, but that can be done by the clients of the 
kmem_cache_create interface, not the generic cache allocator itself.

Thank you,
Pasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
