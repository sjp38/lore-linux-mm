Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 157B26007B8
	for <linux-mm@kvack.org>; Mon,  3 May 2010 12:54:22 -0400 (EDT)
Message-ID: <4BDEFF9E.6080508@redhat.com>
Date: Mon, 03 May 2010 12:53:50 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/2] mm: Take all anon_vma locks in anon_vma_lock
References: <20100503121743.653e5ecc@annuminas.surriel.com> <20100503121847.7997d280@annuminas.surriel.com> <alpine.LFD.2.00.1005030940490.5478@i5.linux-foundation.org>
In-Reply-To: <alpine.LFD.2.00.1005030940490.5478@i5.linux-foundation.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: akpm@linux-foundation.org, Mel Gorman <mel@csn.ul.ie>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>, Christoph Lameter <cl@linux.com>
List-ID: <linux-mm.kvack.org>

On 05/03/2010 12:41 PM, Linus Torvalds wrote:
> On Mon, 3 May 2010, Rik van Riel wrote:
>>
>> Both the page migration code and the transparent hugepage patches expect
>> 100% reliable rmap lookups and use page_lock_anon_vma(page) to prevent
>> races with mmap, munmap, expand_stack, etc.
>
> Pretty much same comments as for the other one. Why are we pandering to
> the case that is/should be unusual?

In this case, because the fix from the migration side is
difficult and fragile, while fixing things from the mmap
side is straightforward.

I believe the overhead of patch 1/2 should be minimal
as well, because the locks we take are the _depth_ of
the process tree (truncated every exec), not the width.


As for patch 2/2, Mel has an alternative approach for that:

http://lkml.org/lkml/2010/4/30/198

Does Mel's patch seem more reasonable to you?

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
