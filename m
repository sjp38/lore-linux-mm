Received: from m5.gw.fujitsu.co.jp ([10.0.50.75]) by fgwmail6.fujitsu.co.jp (8.12.10/Fujitsu Gateway)
	id i9Q1BxqK012378 for <linux-mm@kvack.org>; Tue, 26 Oct 2004 10:11:59 +0900
	(envelope-from kamezawa.hiroyu@jp.fujitsu.com)
Received: from s1.gw.fujitsu.co.jp by m5.gw.fujitsu.co.jp (8.12.10/Fujitsu Domain Master)
	id i9Q1Bxkt006487 for <linux-mm@kvack.org>; Tue, 26 Oct 2004 10:11:59 +0900
	(envelope-from kamezawa.hiroyu@jp.fujitsu.com)
Received: from s1.gw.fujitsu.co.jp (s1 [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 01F89216FBF
	for <linux-mm@kvack.org>; Tue, 26 Oct 2004 10:11:59 +0900 (JST)
Received: from fjmail503.fjmail.jp.fujitsu.com (fjmail503-0.fjmail.jp.fujitsu.com [10.59.80.100])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 1520F216FBE
	for <linux-mm@kvack.org>; Tue, 26 Oct 2004 10:11:58 +0900 (JST)
Received: from [10.124.100.187]
 (fjscan501-0.fjmail.jp.fujitsu.com [10.59.80.120])
 by fjmail503.fjmail.jp.fujitsu.com
 (Sun Internet Mail Server sims.4.0.2001.07.26.11.50.p9)
 with ESMTP id <0I6600E5X3BVRX@fjmail503.fjmail.jp.fujitsu.com> for
 linux-mm@kvack.org; Tue, 26 Oct 2004 10:11:56 +0900 (JST)
Date: Tue, 26 Oct 2004 10:17:44 +0900
From: Hiroyuki KAMEZAWA <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: migration cache, updated
In-reply-to: <20041025213923.GD23133@logos.cnet>
Message-id: <417DA5B8.8000706@jp.fujitsu.com>
MIME-version: 1.0
Content-type: text/plain; charset=us-ascii; format=flowed
Content-transfer-encoding: 7bit
References: <20041025213923.GD23133@logos.cnet>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Cc: linux-mm@kvack.org, Hirokazu Takahashi <taka@valinux.co.jp>, IWAMOTO Toshihiro <iwamoto@valinux.co.jp>, Dave Hansen <haveblue@us.ibm.com>, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

Hi, Marcelo

Marcelo Tosatti wrote:
> Hi,
>  #define SWP_TYPE_SHIFT(e)	(sizeof(e.val) * 8 - MAX_SWAPFILES_SHIFT)
> -#define SWP_OFFSET_MASK(e)	((1UL << SWP_TYPE_SHIFT(e)) - 1)
> +#define SWP_OFFSET_MASK(e)	((1UL << (SWP_TYPE_SHIFT(e))) - 1)
> +
> +#define MIGRATION_TYPE  (MAX_SWAPFILES - 1)
>  
At the first glance, I think MIGRATION_TYPE=0 is better.
#define MIGRATION_TYPE  (0)

In swapfile.c::sys_swapon()
This code determines new swap_type for commanded swapon().
=============
p = swap_info;
for (type = 0 ; type < nr_swapfiles ; type++,p++)
          if (!(p->flags & SWP_USED))
                break;
error = -EPERM;
==============

set nr_swapfiles=1, swap_info[0].flags = SWP_USED
at boot time seems good. or fix swapon().

Thanks.
Kame <kamezawa.hiroyu@jp.fujitsu.com>
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
