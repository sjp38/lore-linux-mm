Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx196.postini.com [74.125.245.196])
	by kanga.kvack.org (Postfix) with SMTP id 73ED36B0002
	for <linux-mm@kvack.org>; Wed, 13 Feb 2013 23:02:00 -0500 (EST)
Received: by mail-ia0-f169.google.com with SMTP id j5so1956414iaf.0
        for <linux-mm@kvack.org>; Wed, 13 Feb 2013 20:01:59 -0800 (PST)
Message-ID: <511C61AD.2010702@gmail.com>
Date: Thu, 14 Feb 2013 12:01:49 +0800
From: Jiang Liu <liuj97@gmail.com>
MIME-Version: 1.0
Subject: Re: [Bug 53501] New: Duplicated MemTotal with different values
References: <bug-53501-27@https.bugzilla.kernel.org/> <20130212165107.32be0c33.akpm@linux-foundation.org> <alpine.DEB.2.02.1302121742370.5404@chino.kir.corp.google.com> <20130212195929.7cd2e597.akpm@linux-foundation.org> <alpine.DEB.2.02.1302131915170.8584@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.02.1302131915170.8584@chino.kir.corp.google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, sworddragon2@aol.com, bugzilla-daemon@bugzilla.kernel.org, linux-mm@kvack.org

On 02/14/2013 11:19 AM, David Rientjes wrote:
> On Tue, 12 Feb 2013, Andrew Morton wrote:
> 
>>>>> The installed memory on my system is 16 GiB. /proc/meminfo is showing me
>>>>> "MemTotal:       16435048 kB" but /sys/devices/system/node/node0/meminfo is
>>>>> showing me "Node 0 MemTotal:       16776380 kB".
>>>>>
>>>>> My suggestion: MemTotal in /proc/meminfo should be 16776380 kB too. The old
>>>>> value of 16435048 kB could have its own key "MemAvailable".
>>>>
>>>> hm, mine does that too.  A discrepancy between `totalram_pages' and
>>>> NODE_DATA(0)->node_present_pages.
>>>>
>>>> I don't know what the reasons are for that but yes, one would expect
>>>> the per-node MemTotals to sum up to the global one.
>>>>
>>>
>>> I'd suspect it has something to do with 9feedc9d831e ("mm: introduce new 
>>> field "managed_pages" to struct zone") and 3.8 would be the first kernel 
>>> release with this change.  Is it possible to try 3.7 or, better yet, with 
>>> this patch reverted?
>>
>> My desktop machine at google in inconsistent, as is the 2.6.32-based
>> machine, so it obviously predates 9feedc9d831e.
>>
> 
> Hmm, ok.  The question is which one is right: the per-node MemTotal is the 
> amount of present RAM, the spanned range minus holes, and the system 
> MemTotal is the amount of pages released to the buddy allocator by 
> bootmem and discounts not only the memory holes but also reserved pages.  
> Should they both be the amount of RAM present or the amount of unreserved 
> RAM present?
> 
Hi David,
	We have worked out a patch set to address this issue. The first two
patches have been merged into v3.8, and another two patches are queued in
Andrew's mm tree for v3.9.
	The patch set introduces a new field named managed_pages into struct
zone to distinguish between pages present in a zone and pages managed by the
buddy system. So
zone->present_pages = zone->spanned_pages - pages_in_hole;
zone->managed_pages = pages_managed_by_buddy_system_in_the_zone;
	We have also added a field named "managed" into /proc/zoneinfo, but
haven't touch /proc/meminfo and /sys/devices/system/node/nodex/meminfo yet.
If preferred, we could work out another patch to enhance these two files
as suggested above.
	Regards!
	Gerry
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
