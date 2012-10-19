Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx193.postini.com [74.125.245.193])
	by kanga.kvack.org (Postfix) with SMTP id 81B0C6B005A
	for <linux-mm@kvack.org>; Fri, 19 Oct 2012 13:13:50 -0400 (EDT)
Message-ID: <50818A41.7030909@redhat.com>
Date: Fri, 19 Oct 2012 13:13:37 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: question on NUMA page migration
References: <5081777A.8050104@redhat.com> <1350664742.2768.40.camel@twins>
In-Reply-To: <1350664742.2768.40.camel@twins>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Ingo Molnar <mingo@kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, Mel Gorman <mel@csn.ul.ie>, Linux kernel Mailing List <linux-kernel@vger.kernel.org>

On 10/19/2012 12:39 PM, Peter Zijlstra wrote:
> On Fri, 2012-10-19 at 11:53 -0400, Rik van Riel wrote:
>>
>> If we do need the extra refcount, why is normal
>> page migration safe? :)
>
> Its mostly a matter of how convoluted you make the code, regular page
> migration is about as bad as you can get
>
> Normal does:
>
>    follow_page(FOLL_GET) +1
>
>    isolate_lru_page() +1
>
>    put_page() -1
>
> ending up with a page with a single reference (for anon, or one extra
> each for the mapping and buffer).

Would it make sense to have the normal page migration code always
work with the extra refcount, so we do not have to introduce a new
MIGRATE_FAULT migration mode?

On the other hand, compaction does not take the extra reference...

Another alternative might be to do the put_page inside
do_prot_none_numa().  That would be analogous to do_wp_page
disposing of the old page for the caller.

I am not real happy about NUMA migration introducing its own
migration mode...

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
