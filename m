Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx166.postini.com [74.125.245.166])
	by kanga.kvack.org (Postfix) with SMTP id 7C1466B0075
	for <linux-mm@kvack.org>; Wed, 11 Jul 2012 01:57:12 -0400 (EDT)
Message-ID: <4FFD15B2.6020001@kernel.org>
Date: Wed, 11 Jul 2012 14:57:06 +0900
From: Minchan Kim <minchan@kernel.org>
MIME-Version: 1.0
Subject: Re: [PATCH v2] mm: Warn about costly page allocation
References: <1341878153-10757-1-git-send-email-minchan@kernel.org> <20120709170856.ca67655a.akpm@linux-foundation.org> <20120710002510.GB5935@bbox> <alpine.DEB.2.00.1207101756070.684@chino.kir.corp.google.com> <20120711022304.GA17425@bbox> <alpine.DEB.2.00.1207102223000.26591@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.00.1207102223000.26591@chino.kir.corp.google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

On 07/11/2012 02:33 PM, David Rientjes wrote:
> On Wed, 11 Jul 2012, Minchan Kim wrote:
> 
>>> Should we consider enabling CONFIG_COMPACTION in defconfig?  If not, would 
>>
>> I hope so but Mel didn't like it because some users want to have a smallest
>> kernel if they don't care of high-order allocation.
>>
> 
> CONFIG_COMPACTION adds 0.1% to my kernel image using x86_64 defconfig, 

barrios@bbox:~/linux-next$ size mm/compaction.o mm/migrate.o
   text	   data	    bss	    dec	    hex	filename
   8550	   1114	      4	   9668	   25c4	mm/compaction.o
  10891	    520	      0	  11411	   2c93	mm/migrate.o

It couldn't be a trivial on small system.

> that's the only reason we don't enable it by default?

AFAIK, that's all. Mel. Do you think others?

> 
>>> it be possible with a different extfrag_threshold (and more aggressive 
>>> when things like THP are enabled)?
>>
>> Anyway, we should enable compaction for it although the system doesn't 
>> care about high-order allocation and it ends up make bloting kernel unnecessary.
>>
> 
> The problem with this approach (and the appended patch) is that we can't 
> define a system that "doesn't care about high-order allocations."  Even if 
> you discount thp, an admin has no way of knowing how many high-order 
> allocations his or her kernel will be doing and it will change between 

Of course.

> kernel versions.  Almost 50% of slab caches on my desktop machine running 
> with slub have a default order greater than 0.
> 
> So I don't believe that adding this warning will be helpful and will 
> simply lead to confusion.
> 
>> I tend to agree Andrew and your concern but I don't have a good idea but
>> alert vague warning message. Anyway, we need *alert* this fact which removed
>> lumpy reclaim for being able to disabling CONFIG_COMPACTION.
> 
> Can we ignore the fact that lumpy reclaim was removed and look at 
> individual issues as they arise and address them by fixing the VM or by 
> making a case for enabling CONFIG_COMPACTION by default?

I agree it's an ideal but the problem is that it's too late.
Once product is released, we have to recall all products in the worst case.
The fact is that lumpy have helped high order allocation implicitly but we removed it
without any notification or information. It's a sort of regression and we can't say
them "Please report us if it happens". It's irresponsible, too.
IMHO, at least, what we can do is to warn about it before it's too late.


> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 


-- 
Kind regards,
Minchan Kim


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
