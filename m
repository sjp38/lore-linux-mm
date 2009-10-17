Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id DDD496B005A
	for <linux-mm@kvack.org>; Sat, 17 Oct 2009 18:44:18 -0400 (EDT)
Message-ID: <27119164.1255819452382.JavaMail.root@ps28>
Date: Sat, 17 Oct 2009 23:44:12 +0100 (GMT+01:00)
From: "hugh.dickins@tiscali.co.uk" <hugh.dickins@tiscali.co.uk>
Reply-To: "hugh.dickins@tiscali.co.uk" <hugh.dickins@tiscali.co.uk>
Subject: Re: [PATCH] mm: call pte_unmap() against a proper pte (Re: [PATCH
 7/9] swap_info: swap count continuations)
MIME-Version: 1.0
Content-Type: text/plain;charset="UTF-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: nishimura@mxp.nes.nec.co.jp
Cc: Andrew Morton <akpm@linux-foundation.org>, Nitin Gupta <ngupta@vflare.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, hongshin@gmail.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>



>----Original Message----
>From: nishimura@mxp.nes.nec.co.jp
>Date: 16/10/2009 7:30 
>To: "Hugh Dickins"<hugh.dickins@tiscali.co.uk>
>Cc: "Andrew Morton"<akpm@linux-foundation.org>, "Nitin Gupta"<ngupta@vflare.
org>, "KAMEZAWA Hiroyuki"<kamezawa.hiroyu@jp.fujitsu.com>, <hongshin@gmail.
com>, <linux-kernel@vger.kernel.org>, <linux-mm@kvack.org>, "Daisuke Nishimura"
<nishimura@mxp.nes.nec.co.jp>
>Subj: [PATCH] mm: call pte_unmap() against a proper pte (Re: [PATCH 7/9] 
swap_info: swap count continuations)
>
>Hi.
>
>> @@ -645,6 +648,7 @@ static int copy_pte_range(struct mm_stru
>>  	spinlock_t *src_ptl, *dst_ptl;
>>  	int progress = 0;
>>  	int rss[2];
>> +	swp_entry_t entry = (swp_entry_t){0};
>>  
>>  again:
>>  	rss[1] = rss[0] = 0;
>> @@ -671,7 +675,10 @@ again:
>>  			progress++;
>>  			continue;
>>  		}
>> -		copy_one_pte(dst_mm, src_mm, dst_pte, src_pte, vma, addr, rss);
>> +		entry.val = copy_one_pte(dst_mm, src_mm, dst_pte, src_pte,
>> +							vma, addr, rss);
>> +		if (entry.val)
>> +			break;
>>  		progress += 8;
>>  	} while (dst_pte++, src_pte++, addr += PAGE_SIZE, addr != end);
>>  
>It isn't the fault of only this patch, but I think breaking the loop without 
incrementing
>dst_pte(and src_pte) would be bad behavior because we do unmap_pte(dst_pte - 
1) later.
>(current copy_pte_range() already does it though... and this is only 
problematic
>when we break the first loop, IIUC.)

Good catch, thanks a lot for finding that.  I believe this is entirely a fault 
in my 7/9, the existing code
takes care not to break before it has made some progress (in part because of 
this unmap issue).

>
>> @@ -681,6 +688,12 @@ again:
>>  	add_mm_rss(dst_mm, rss[0], rss[1]);
>>  	pte_unmap_unlock(dst_pte - 1, dst_ptl);
>>  	cond_resched();
>> +
>> +	if (entry.val) {
>> +		if (add_swap_count_continuation(entry, GFP_KERNEL) < 0)
>> +			return -ENOMEM;
>> +		progress = 0;
>> +	}
>>  	if (addr != end)
>>  		goto again;
>>  	return 0;
>
>I've searched other places where we break a similar loop and do pte_unmap(pte 
- 1).
>Current copy_pte_range() and apply_to_pte_range() has the same problem.

And thank you for taking the trouble to look further afield: yes, 
apply_to_pte_range()
was already wrong.

>
>How about a patch like this ?
>===
>From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
>
>There are some places where we do like:
>
>	pte = pte_map();
>	do {
>		(do break in some conditions)
>	} while (pte++, ...);
>	pte_unmap(pte - 1);
>
>But if the loop breaks at the first loop, pte_unmap() unmaps invalid pte.
>
>This patch is a fix for this problem.
>
>Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>

Acked-by: Hugh Dickins <hugh.dickins@tiscali.co.uk>





Forget the rest, get the best - http://www.tiscali.co.uk/music

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
