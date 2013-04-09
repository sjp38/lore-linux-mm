Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx165.postini.com [74.125.245.165])
	by kanga.kvack.org (Postfix) with SMTP id AA2B96B0027
	for <linux-mm@kvack.org>; Tue,  9 Apr 2013 10:52:18 -0400 (EDT)
Message-ID: <51642B1A.9000203@parallels.com>
Date: Tue, 09 Apr 2013 18:52:10 +0400
From: Pavel Emelyanov <xemul@parallels.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH 1/1] mm: Another attempt to monitor task's memory
 changes
References: <515F0484.1010703@parallels.com> <51634E58.4080104@gmail.com>
In-Reply-To: <51634E58.4080104@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Cc: Linux MM <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Matt Mackall <mpm@selenic.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Glauber Costa <glommer@parallels.com>, Matthew Wilcox <willy@linux.intel.com>

On 04/09/2013 03:10 AM, KOSAKI Motohiro wrote:
>> This approach works on any task via it's proc, and can be used on different
>> tasks in parallel.
>>
>> Also, Andrew was asking for some performance numbers related to the change.
>> Now I can say, that as long as soft dirty bits are not cleared, no performance
>> penalty occur, since the soft dirty bit and the regular dirty bit are set at 
>> the same time within the same instruction. When soft dirty is cleared via 
>> clear_refs, the task in question might slow down, but it will depend on how
>> actively it uses the memory.
>>
>>
>> What do you think, does it make sense to develop this approach further?
> 
> When touching mmaped page, cpu turns on dirty bit but doesn't turn on soft dirty.

Yes. BTW, I've just thought that "soft" in soft dirty should be read as softWARE,
i.e. this bit is managed by kernel, rather than CPU.

> So, I'm not convinced how to use this flag. Please show us your userland algorithm
> how to detect diff.

It's like this:

1. First do "echo 4 > /proc/$pid/clear_refs".
   At that point kernel clears the soft dirty _and_ the writable bits from all ptes
   of process $pid. From now on every write to any page will result in #pf and the
   subsequent call to pte_mkdirty/pmd_mkdirty, which in turn will set the soft dirty
   flag.

2. Then read the /proc/$pid/pagemap (well, /proc/$pid/pagemap2 when it will appear)
   and check the soft-dirty bit reported there (in this RFC patch it's the
   PM_SOFT_DIRTY one). If set, the respective pte was written to since last call
   to clear refs. 

Thanks,
Pavel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
