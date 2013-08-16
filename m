Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx180.postini.com [74.125.245.180])
	by kanga.kvack.org (Postfix) with SMTP id CD0F56B0032
	for <linux-mm@kvack.org>; Thu, 15 Aug 2013 20:08:29 -0400 (EDT)
Received: from /spool/local
	by e23smtp08.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Fri, 16 Aug 2013 10:05:16 +1000
Received: from d23relay04.au.ibm.com (d23relay04.au.ibm.com [9.190.234.120])
	by d23dlp01.au.ibm.com (Postfix) with ESMTP id 33E1D2CE8052
	for <linux-mm@kvack.org>; Fri, 16 Aug 2013 10:08:25 +1000 (EST)
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay04.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r7FNqYvL56688730
	for <linux-mm@kvack.org>; Fri, 16 Aug 2013 09:52:34 +1000
Received: from d23av03.au.ibm.com (localhost [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id r7G08Om6011519
	for <linux-mm@kvack.org>; Fri, 16 Aug 2013 10:08:24 +1000
Date: Fri, 16 Aug 2013 08:08:22 +0800
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH 2/4] mm/sparse: introduce alloc_usemap_and_memmap
Message-ID: <20130816000822.GC9879@hacker.(null)>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
References: <1376526703-2081-1-git-send-email-liwanp@linux.vnet.ibm.com>
 <1376526703-2081-2-git-send-email-liwanp@linux.vnet.ibm.com>
 <520D1806.5040309@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <520D1806.5040309@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@linux.intel.com>, Fengguang Wu <fengguang.wu@intel.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Jiri Kosina <jkosina@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi Dave,
On Thu, Aug 15, 2013 at 11:03:50AM -0700, Dave Hansen wrote:
>On 08/14/2013 05:31 PM, Wanpeng Li wrote:
>> After commit 9bdac91424075("sparsemem: Put mem map for one node together."),
>> vmemmap for one node will be allocated together, its logic is similiar as 
>> memory allocation for pageblock flags. This patch introduce alloc_usemap_and_memmap
>> to extract the same logic of memory alloction for pageblock flags and vmemmap.
>
>Shame on whoever copy-n-pasted that in the first place.
>
>> -
>> -	for (pnum = 0; pnum < NR_MEM_SECTIONS; pnum++) {
>> -		struct mem_section *ms;
>> -
>> -		if (!present_section_nr(pnum))
>> -			continue;
>> -		ms = __nr_to_section(pnum);
>> -		nodeid_begin = sparse_early_nid(ms);
>> -		pnum_begin = pnum;
>> -		break;
>> -	}
>> -	usemap_count = 1;
>> -	for (pnum = pnum_begin + 1; pnum < NR_MEM_SECTIONS; pnum++) {
>> -		struct mem_section *ms;
>> -		int nodeid;
>> -
>> -		if (!present_section_nr(pnum))
>> -			continue;
>> -		ms = __nr_to_section(pnum);
>> -		nodeid = sparse_early_nid(ms);
>> -		if (nodeid == nodeid_begin) {
>> -			usemap_count++;
>> -			continue;
>> -		}
>> -		/* ok, we need to take cake of from pnum_begin to pnum - 1*/
>> -		sparse_early_usemaps_alloc_node(usemap_map, pnum_begin, pnum,
>> -						 usemap_count, nodeid_begin);
>> -		/* new start, update count etc*/
>> -		nodeid_begin = nodeid;
>> -		pnum_begin = pnum;
>> -		usemap_count = 1;
>> -	}
>> -	/* ok, last chunk */
>> -	sparse_early_usemaps_alloc_node(usemap_map, pnum_begin, NR_MEM_SECTIONS,
>> -					 usemap_count, nodeid_begin);
>> +	alloc_usemap_and_memmap(usemap_map, true);
>...
>> +	alloc_usemap_and_memmap((unsigned long **)map_map, false);
>>  #endif
>
>Why does alloc_usemap_and_memmap() take an 'unsigned long **'?
>'unsigned long' is for the usemap and 'struct page' is for the memmap.
>It's misleading to have it take an 'unsigned long **' and then just cast
>it over to a 'struct page **' internally.
>

Indeed.

>Also, what's the point of having a function that returns something in a
>double-pointer, but that doesn't use its return value?
>

So there is still need to cast return value since one is 'unsigned long
**' and the other is 'struct page **', do you have any idea to tackle 
casting in this patch? 

>alloc_usemap_and_memmap() also needs a comment about what it's doing
>with that pointer and its other argument.
>

I will write comment in next version, thanks for your point out. ;-)

Regards,
Wanpeng Li 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
