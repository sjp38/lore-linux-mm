Received: from m4.gw.fujitsu.co.jp ([10.0.50.74]) by fgwmail6.fujitsu.co.jp (8.12.10/Fujitsu Gateway)
	id i7VMdKtx025853 for <linux-mm@kvack.org>; Wed, 1 Sep 2004 07:39:20 +0900
	(envelope-from kamezawa.hiroyu@jp.fujitsu.com)
Received: from s0.gw.fujitsu.co.jp by m4.gw.fujitsu.co.jp (8.12.10/Fujitsu Domain Master)
	id i7VMdJTM014451 for <linux-mm@kvack.org>; Wed, 1 Sep 2004 07:39:19 +0900
	(envelope-from kamezawa.hiroyu@jp.fujitsu.com)
Received: from s0.gw.fujitsu.co.jp (s0 [127.0.0.1])
	by s0.gw.fujitsu.co.jp (Postfix) with ESMTP id 6DEA7A7CC9
	for <linux-mm@kvack.org>; Wed,  1 Sep 2004 07:39:19 +0900 (JST)
Received: from fjmail501.fjmail.jp.fujitsu.com (fjmail501-0.fjmail.jp.fujitsu.com [10.59.80.96])
	by s0.gw.fujitsu.co.jp (Postfix) with ESMTP id 0FB6BA7CC6
	for <linux-mm@kvack.org>; Wed,  1 Sep 2004 07:39:19 +0900 (JST)
Received: from jp.fujitsu.com
 (fjscan503-0.fjmail.jp.fujitsu.com [10.59.80.124]) by
 fjmail501.fjmail.jp.fujitsu.com
 (Sun Internet Mail Server sims.4.0.2001.07.26.11.50.p9)
 with ESMTP id <0I3C00DL51LIH2@fjmail501.fjmail.jp.fujitsu.com> for
 linux-mm@kvack.org; Wed,  1 Sep 2004 07:39:18 +0900 (JST)
Date: Wed, 01 Sep 2004 07:44:32 +0900
From: Hiroyuki KAMEZAWA <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [Lhms-devel] Re: [RFC] buddy allocator without bitmap(2) [0/3]
In-reply-to: <1093969590.26660.4806.camel@nighthawk>
Message-id: <4134FF50.8000300@jp.fujitsu.com>
MIME-version: 1.0
Content-type: text/plain; charset=us-ascii
Content-transfer-encoding: 7bit
References: <41345491.1020209@jp.fujitsu.com>
 <1093969590.26660.4806.camel@nighthawk>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: Linux Kernel ML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, lhms <lhms-devel@lists.sourceforge.net>
List-ID: <linux-mm.kvack.org>

Dave Hansen wrote:
> On Tue, 2004-08-31 at 03:36, Hiroyuki KAMEZAWA wrote:
> 
>>Disadvantage:
>>  - using one more PG_xxx flag.
>>  - If mem_map is not aligned, reserve one page as a victim for buddy allocater.
>>
>>How about this approach ?
> 
> 
> Granted, we have some free wiggle room in page->flags right now, but
> using another bit effectively shifts the entire benefit of your patch. 
> Instead of getting rid of the buddy bitmaps, you simply consume a
> page->flag instead.  While you don't have to allocate anything (because
> of the page->flags use), the number of bits consumed in the operation is
> still the same as before.  And the patch is getting more complex by the
> minute.

Hmm...I understand what you say. Consuming PG_xxx bit in buddy allocator is harmful
because no PG_xxx bit is used in current kernel's one.

What this patch implements is
"How to record shape of the mem_map needed by buddy allocator without using some
 structure which must be resized at memory resizing."

Because I had to record some information about shape of mem_map, I used PG_xxx bit.
1 bit is maybe minimum consumption.
If consumption of 1 bit in a page structure is too harmful,
I have to record information in some structure which needs to be resized
at memory resizing. When I do so, this patch itself is meaningless, I think.

I'll consider more, but...



> Something ate your patch:
> 
>    * Global page accounting.  One instance per CPU.  Only unsigned longs are
> @@ -290,6 +297,9 @@ extern unsigned long __read_page_state(u
>   #define SetPageCompound(page) set_bit(PG_compound, &(page)->flags)
>   #define ClearPageCompound(page)       clear_bit(PG_compound, &(page)->flags)
> 
> +#define PageBuddyend(page)      test_bit(PG_buddyend, &(page)->flags)
> +#define SetPageBuddyend(page)   set_bit(PG_buddyend, &(page)->flags)
> +
>   #ifdef CONFIG_SWAP
>   #define PageSwapCache(page)   test_bit(PG_swapcache, &(page)->flags)
>   #define SetPageSwapCache(page)        set_bit(PG_swapcache, &(page)->flags)
> 
> 
> -- Dave


-- 
--the clue is these footmarks leading to the door.--
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
