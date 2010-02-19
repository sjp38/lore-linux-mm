Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 939AC6B0047
	for <linux-mm@kvack.org>; Fri, 19 Feb 2010 03:24:59 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o1J8OveI027312
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 19 Feb 2010 17:24:57 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 198B345DE55
	for <linux-mm@kvack.org>; Fri, 19 Feb 2010 17:24:57 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id EAD3245DE51
	for <linux-mm@kvack.org>; Fri, 19 Feb 2010 17:24:56 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id CEF541DB8038
	for <linux-mm@kvack.org>; Fri, 19 Feb 2010 17:24:56 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 863341DB803B
	for <linux-mm@kvack.org>; Fri, 19 Feb 2010 17:24:53 +0900 (JST)
Date: Fri, 19 Feb 2010 17:21:22 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: Kernel panic due to page migration accessing memory holes
Message-Id: <20100219172122.fe0891f5.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100219151012.d430b7ea.kamezawa.hiroyu@jp.fujitsu.com>
References: <4B7C8DC2.3060004@codeaurora.org>
	<20100218100324.5e9e8f8c.kamezawa.hiroyu@jp.fujitsu.com>
	<4B7CF8C0.4050105@codeaurora.org>
	<20100218183604.95ee8c77.kamezawa.hiroyu@jp.fujitsu.com>
	<20100218100432.GA32626@csn.ul.ie>
	<4B7DEDB0.8030802@codeaurora.org>
	<20100219110003.dfe58df8.kamezawa.hiroyu@jp.fujitsu.com>
	<4B7E2635.8010700@codeaurora.org>
	<20100219151012.d430b7ea.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Michael Bohan <mbohan@codeaurora.org>, Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-arm-msm@vger.kernel.org, linux-arm-kernel@lists.infradead.org
List-ID: <linux-mm.kvack.org>

On Fri, 19 Feb 2010 15:10:12 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> 1. re-implement pfn_valid() which returns correct value.
>    maybe not difficult. but please take care of defining CONFIG_HOLES_IN_....
>    etc.
> 
> 2. use DISCONTIGMEM and treat each bank and NUMA node.
>    There will be no waste for memmap. But other complication of CONFIG_NUMA.
>    
> 3. use SPARSEMEM.
>    You have even 2 choisce here. 
>    a - Set your MAX_ORDER and SECTION_SIZE to be proper value.
>    b - waste some amount of memory for memmap on the edge of section.
>        (and don't free memmap for the edge.)
>       

I read ARM's code briefly. In 2.6.32, ...I think (1) is implemented. As
==

#ifndef CONFIG_SPARSEMEM
int pfn_valid(unsigned long pfn)
{
        struct meminfo *mi = &meminfo;
        unsigned int left = 0, right = mi->nr_banks;

        do {
                unsigned int mid = (right + left) / 2;
                struct membank *bank = &mi->bank[mid];

                if (pfn < bank_pfn_start(bank))
                        right = mid;
                else if (pfn >= bank_pfn_end(bank))
                        left = mid + 1;
                else
                        return 1;
        } while (left < right);
        return 0;
}
EXPORT_SYMBOL(pfn_valid);
==
So, what you should do is upgrade to 2.6.32 or backport this one.

See this.

http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commit;h=b7cfda9fc3d7aa60cffab5367f2a72a4a70060cd

Thanks,
-Kame




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
