Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e33.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id lAUH4TGF006549
	for <linux-mm@kvack.org>; Fri, 30 Nov 2007 12:04:29 -0500
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id lAUH4MLU043944
	for <linux-mm@kvack.org>; Fri, 30 Nov 2007 10:04:27 -0700
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id lAUH4Min011992
	for <linux-mm@kvack.org>; Fri, 30 Nov 2007 10:04:22 -0700
Subject: Re: RFC/POC Make Page Tables Relocatable Part 2 Page Table
	Migration Code
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <d43160c70711300836g52c10a88qc46288cf380192ca@mail.gmail.com>
References: <d43160c70711300836g52c10a88qc46288cf380192ca@mail.gmail.com>
Content-Type: text/plain
Date: Fri, 30 Nov 2007 10:04:17 -0800
Message-Id: <1196445857.18851.140.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ross Biro <rossb@google.com>
Cc: Mel Gorman <mel@skynet.ie>, linux-mm@kvack.org, Mel Gorman <MELGOR@ie.ibm.com>
List-ID: <linux-mm.kvack.org>

On Fri, 2007-11-30 at 11:36 -0500, Ross Biro wrote:
> lmbench shows the overhead of rewalking the page tables is less than
> that of spinlock debugging. 

Spinlock debugging can be pretty heavy, so I wouldn't use it as a
benchmark.  Thanks for posting them early, though.

> Here's the actual page table migration code.  I'm not sure I plugged
> it into the correct spot, but it works well enough to test.

Could you remind us exactly what you're trying to do here?  A bit of the
theory of what you're trying would be good.  Also, this is a wee bit
hard to review because it's a bit messy, still has lots of debugging
printks, and needs some CodingStyle love.  Don't forget to add -p do
your diffs while you're at it.

Where did PageDying() come from?  Where ever it came from, please wrap
it up in its header in a nice #ifdef so you don't have to do this a
number of times:

...
> +{
> +#ifdef CONFIG_SLOW_CACHE
> +       while (unlikely(PageDying(pmd_page(**pmd))))
> +#endif
> +       {
...


> +       union {
>         struct list_head lru;           /* Pageout list, eg. active_list
>                                          * protected by zone->lru_lock !
>                                          */
> +               struct rcu_head rcu;
> +       };

There's a nice shiny comment next to 'lru'.  Hint, hint. ;)

> +int migrate_top_level_page_table(struct mm_struct *mm, struct page *dest)
> +{
> +       return 1;
> +#if 0
> +       unsigned long flags;
> +       void *dest_ptr;
> +
> +       /* We can't do this until we get a heavy duty tlb flush, or
> +          we can force this mm to be switched on all cpus. */

Can you elaborate on this?  You need each cpu to do a task switch _away_
from this mm?

> +int migrate_pmd(pmd_t *pmd, struct mm_struct *mm, unsigned long addr,
> +               struct page *dest)
> +{
...
> +       pte = pte_offset_map(pmd, addr);
> +
> +       dest_ptr = kmap_atomic(dest, KM_IRQ0);

Why KM_IRQ0 here?  

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
