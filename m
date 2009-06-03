Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id BC3F66B0062
	for <linux-mm@kvack.org>; Wed,  3 Jun 2009 10:53:34 -0400 (EDT)
Message-ID: <4A268DF8.6000701@redhat.com>
Date: Wed, 03 Jun 2009 10:51:36 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [patch][v2] swap: virtual swap readahead
References: <20090602223738.GA15475@cmpxchg.org> <20090602233457.GY1065@one.firstfloor.org> <20090603132751.GA1813@cmpxchg.org>
In-Reply-To: <20090603132751.GA1813@cmpxchg.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Johannes Weiner wrote:
> On Wed, Jun 03, 2009 at 01:34:57AM +0200, Andi Kleen wrote:
>> On Wed, Jun 03, 2009 at 12:37:39AM +0200, Johannes Weiner wrote:

>>> +		pgd = pgd_offset(vma->vm_mm, pos);
>>> +		if (!pgd_present(*pgd))
>>> +			continue;
>>> +		pud = pud_offset(pgd, pos);
>>> +		if (!pud_present(*pud))
>>> +			continue;
>>> +		pmd = pmd_offset(pud, pos);
>>> +		if (!pmd_present(*pmd))
>>> +			continue;
>>> +		pte = pte_offset_map_lock(vma->vm_mm, pmd, pos, &ptl);
>> You could be more efficient here by using the standard mm/* nested loop
>> pattern that avoids relookup of everything in each iteration. I suppose
>> it would mainly make a difference with 32bit highpte where mapping a pte
>> can be somewhat costly. And you would take less locks this way.
> 
> I ran into weird problems here.  The above version is actually faster
> in the benchmarks than writing a nested level walker or using
> walk_page_range().  Still digging but it can take some time.  Busy
> week :(

I'm not too worried about not walking the page tables,
because swap is an extreme slow path anyway.

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
