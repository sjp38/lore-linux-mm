Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 000166B0292
	for <linux-mm@kvack.org>; Thu, 31 Aug 2017 12:39:39 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id u26so189950wma.3
        for <linux-mm@kvack.org>; Thu, 31 Aug 2017 09:39:39 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id k10si492533edl.273.2017.08.31.09.39.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 31 Aug 2017 09:39:38 -0700 (PDT)
Subject: Re: [PATCH v7 9/9] sparc64: Add support for ADI (Application Data
 Integrity)
References: <7b8216b8-e732-0b31-a374-1a817d4fbc80@oracle.com>
 <20170830.153830.2267882580011615008.davem@davemloft.net>
 <b5d9bbb2-a575-ee47-33aa-11994edef702@oracle.com>
 <20170830.170925.386619891775278628.davem@davemloft.net>
From: Khalid Aziz <khalid.aziz@oracle.com>
Message-ID: <3ff76988-43f2-85e4-eaf4-cc0d10b420a3@oracle.com>
Date: Thu, 31 Aug 2017 10:38:30 -0600
MIME-Version: 1.0
In-Reply-To: <20170830.170925.386619891775278628.davem@davemloft.net>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Miller <davem@davemloft.net>
Cc: anthony.yznaga@oracle.com, dave.hansen@linux.intel.com, corbet@lwn.net, bob.picco@oracle.com, steven.sistare@oracle.com, pasha.tatashin@oracle.com, mike.kravetz@oracle.com, mingo@kernel.org, nitin.m.gupta@oracle.com, kirill.shutemov@linux.intel.com, tom.hromatka@oracle.com, eric.saint.etienne@oracle.com, allen.pais@oracle.com, cmetcalf@mellanox.com, akpm@linux-foundation.org, geert@linux-m68k.org, tklauser@distanz.ch, atish.patra@oracle.com, vijay.ac.kumar@oracle.com, peterz@infradead.org, mhocko@suse.com, jack@suse.cz, lstoakes@gmail.com, hughd@google.com, thomas.tai@oracle.com, paul.gortmaker@windriver.com, ross.zwisler@linux.intel.com, dave.jiang@intel.com, willy@infradead.org, ying.huang@intel.com, zhongjiang@huawei.com, minchan@kernel.org, vegard.nossum@oracle.com, imbrenda@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, aarcange@redhat.com, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, sparclinux@vger.kernel.org, linux-mm@kvack.org, khalid@gonehiking.org

On 08/30/2017 06:09 PM, David Miller wrote:
> From: Khalid Aziz <khalid.aziz@oracle.com>
> Date: Wed, 30 Aug 2017 17:23:37 -0600
> 
>> That is an interesting idea. This would enable TSTATE_MCDE on all
>> threads of a process as soon as one thread enables it. If we consider
>> the case where the parent creates a shared memory area and spawns a
>> bunch of threads. These threads access the shared memory without ADI
>> enabled. Now one of the threads decides to enable ADI on the shared
>> memory. As soon as it does that, we enable TSTATE_MCDE across all
>> threads and since threads are all using the same TTE for the shared
>> memory, every thread becomes subject to ADI verification. If one of
>> the other threads was in the middle of accessing the shared memory, it
>> will get a sigsegv. If we did not enable TSTATE_MCDE across all
>> threads, it could have continued execution without fault. In other
>> words, updating TSTATE_MCDE across all threads will eliminate the
>> option of running some threads with ADI enabled and some not while
>> accessing the same shared memory. This could be necessary at least for
>> short periods of time before threads can communicate with each other
>> and all switch to accessing shared memory with ADI enabled using same
>> tag. Does that sound like a valid use case or am I off in the weeds
>> here?
> 
> A threaded application needs to synchronize and properly orchestrate
> access to shared memory.
> 
> When a change is made to a mappping, in this case setting ADI
> attributes, it's being done for the address space not the thread.
> 
> And the address space is shared amongst threads.
> 
> Therefore ADI is not really a per-thread property but rather
> a per-address-space property.
> 

That does make sense.

Thanks,
Khalid

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
