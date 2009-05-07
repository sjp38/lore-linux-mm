Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 756606B004D
	for <linux-mm@kvack.org>; Thu,  7 May 2009 11:21:34 -0400 (EDT)
Message-ID: <4A02FC78.8070401@redhat.com>
Date: Thu, 07 May 2009 11:21:28 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH -mm] vmscan: make mapped executable pages the first class
 citizen
References: <20090430174536.d0f438dd.akpm@linux-foundation.org>	 <20090430205936.0f8b29fc@riellaptop.surriel.com>	 <20090430181340.6f07421d.akpm@linux-foundation.org>	 <20090430215034.4748e615@riellaptop.surriel.com>	 <20090430195439.e02edc26.akpm@linux-foundation.org>	 <49FB01C1.6050204@redhat.com>	 <20090501123541.7983a8ae.akpm@linux-foundation.org>	 <20090503031539.GC5702@localhost> <1241432635.7620.4732.camel@twins>	 <20090507121101.GB20934@localhost>  <20090507151039.GA2413@cmpxchg.org> <1241709466.11251.164.camel@twins>
In-Reply-To: <1241709466.11251.164.camel@twins>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Peter Zijlstra <peterz@infradead.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Wu Fengguang <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "tytso@mit.edu" <tytso@mit.edu>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Elladan <elladan@eskimo.com>, Nick Piggin <npiggin@suse.de>, Christoph Lameter <cl@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Peter Zijlstra wrote:
> On Thu, 2009-05-07 at 17:10 +0200, Johannes Weiner wrote:
> 
>>> @@ -1269,8 +1270,15 @@ static void shrink_active_list(unsigned 
>>>  
>>>  		/* page_referenced clears PageReferenced */
>>>  		if (page_mapping_inuse(page) &&
>>> -		    page_referenced(page, 0, sc->mem_cgroup))
>>> +		    page_referenced(page, 0, sc->mem_cgroup)) {
>>> +			struct address_space *mapping = page_mapping(page);
>>> +
>>>  			pgmoved++;
>>> +			if (mapping && test_bit(AS_EXEC, &mapping->flags)) {
>>> +				list_add(&page->lru, &l_active);
>>> +				continue;
>>> +			}
>>> +		}
>> Since we walk the VMAs in page_referenced anyway, wouldn't it be
>> better to check if one of them is executable?  This would even work
>> for executable anon pages.  After all, there are applications that cow
>> executable mappings (sbcl and other language environments that use an
>> executable, run-time modified core image come to mind).
> 
> Hmm, like provide a vm_flags mask along to page_referenced() to only
> account matching vmas... seems like a sensible idea.

Not for anon pages, though, because JVMs could have way too many
executable anonymous segments, which would make us run into the
scalability problems again.

Lets leave this just to the file side of the LRUs, because that
is where we have the streaming IO problem.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
