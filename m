Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id E1D626B01F4
	for <linux-mm@kvack.org>; Wed, 28 Apr 2010 14:10:32 -0400 (EDT)
Message-ID: <4BD879F7.1020102@redhat.com>
Date: Wed, 28 Apr 2010 14:09:59 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH] take all anon_vma locks in anon_vma_lock
References: <1272403852-10479-1-git-send-email-mel@csn.ul.ie> <1272403852-10479-3-git-send-email-mel@csn.ul.ie> <20100427231007.GA510@random.random> <20100428091555.GB15815@csn.ul.ie> <20100428153525.GR510@random.random> <20100428155558.GI15815@csn.ul.ie> <20100428162305.GX510@random.random> <20100428134719.32e8011b@annuminas.surriel.com> <20100428180336.GC510@random.random>
In-Reply-To: <20100428180336.GC510@random.random>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Mel Gorman <mel@csn.ul.ie>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On 04/28/2010 02:03 PM, Andrea Arcangeli wrote:
> On Wed, Apr 28, 2010 at 01:47:19PM -0400, Rik van Riel wrote:
>>   static inline void anon_vma_unlock(struct vm_area_struct *vma)
>
> never mind as this is RFC, lock is clear enough
>
>> @@ -1762,7 +1760,8 @@ static int expand_downwards(struct vm_area_struct *vma,
>>   	if (error)
>>   		return error;
>>
>> -	anon_vma_lock(vma);
>> +	spin_lock(&mm->page_table_lock);
>> +	anon_vma_lock(vma,&mm->page_table_lock);
>
> This will cause a lock inversion (page_table_lock can only be taken
> after the anon_vma lock). I don't immediately see why the
> page_table_lock here though?

We need to safely walk the vma->anon_vma_chain /
anon_vma_chain->same_vma list.

So much for using the mmap_sem for read + the
page_table_lock to lock the anon_vma_chain list.

We'll need a new lock somewhere, probably in the
mm_struct since one per process seems plenty.

I'll add that in the next version of the patch.

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
