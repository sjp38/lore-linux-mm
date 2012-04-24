Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx141.postini.com [74.125.245.141])
	by kanga.kvack.org (Postfix) with SMTP id 6761E6B0044
	for <linux-mm@kvack.org>; Tue, 24 Apr 2012 01:34:44 -0400 (EDT)
Message-ID: <4F963B8E.9030105@kernel.org>
Date: Tue, 24 Apr 2012 14:35:10 +0900
From: Minchan Kim <minchan@kernel.org>
MIME-Version: 1.0
Subject: Re: [RFC] propagate gfp_t to page table alloc functions
References: <1335171318-4838-1-git-send-email-minchan@kernel.org> <4F963742.2030607@jp.fujitsu.com>
In-Reply-To: <4F963742.2030607@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, kosaki.motohiro@jp.fujitsu.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 04/24/2012 02:16 PM, KAMEZAWA Hiroyuki wrote:

> (2012/04/23 17:55), Minchan Kim wrote:
> 
>> As I test some code, I found a problem about deadlock by lockdep.
>> The reason I saw the message is __vmalloc calls map_vm_area which calls
>> pud/pmd_alloc without gfp_t. so although we call __vmalloc with
>> GFP_ATOMIC or GFP_NOIO, it ends up allocating pages with GFP_KERNEL.
>> The should be a BUG. This patch fixes it by passing gfp_to to low page
>> table allocate functions.
>>
>> Signed-off-by: Minchan Kim <minchan@kernel.org>
> 
> 
> Hmm ? vmalloc should support GFP_ATOMIC ?


I'm not sure but alloc_large_system_hash already has used.
And it's not specific on GFP_ATOMIC.
We have to care of GFP_NOFS and GFP_NOIO to prevent deadlock on reclaim
context.
There are some places to use GFP_NOFS and we don't emit any warning
message in case of that.

> 
> And, do we need to change all pud_,pgd_,pmd_,pte_alloc() for users pgtables ?


Maybe.


-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
