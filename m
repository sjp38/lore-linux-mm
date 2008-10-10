Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id m9A0fv5M019027
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 10 Oct 2008 09:41:58 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id C5D9D2AC02A
	for <linux-mm@kvack.org>; Fri, 10 Oct 2008 09:41:57 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 6704F12C052
	for <linux-mm@kvack.org>; Fri, 10 Oct 2008 09:41:57 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 4E9451DB803E
	for <linux-mm@kvack.org>; Fri, 10 Oct 2008 09:41:57 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id F35D31DB8038
	for <linux-mm@kvack.org>; Fri, 10 Oct 2008 09:41:56 +0900 (JST)
Date: Fri, 10 Oct 2008 09:41:39 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH -mm] page-writeback: fine-grained dirty_ratio and
 dirty_background_ratio
Message-Id: <20081010094139.e7f8653d.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <48EE236A.90007@gmail.com>
References: <1221232192-13553-1-git-send-email-righi.andrea@gmail.com>
	<20080912131816.e0cfac7a.akpm@linux-foundation.org>
	<532480950809221641y3471267esff82a14be8056586@mail.gmail.com>
	<48EB4236.1060100@linux.vnet.ibm.com>
	<48EB851D.2030300@gmail.com>
	<20081008101642.fcfb9186.kamezawa.hiroyu@jp.fujitsu.com>
	<48ECB215.4040409@linux.vnet.ibm.com>
	<48EE236A.90007@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: righi.andrea@gmail.com
Cc: balbir@linux.vnet.ibm.com, Michael Rubin <mrubin@google.com>, Andrew Morton <akpm@linux-foundation.org>, menage@google.com, dave@linux.vnet.ibm.com, chlunde@ping.uio.no, dpshah@google.com, eric.rannaud@gmail.com, fernando@oss.ntt.co.jp, agk@sourceware.org, m.innocenti@cineca.it, s-uchida@ap.jp.nec.com, ryov@valinux.co.jp, matt@bluehost.com, dradford@bluehost.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Thu, 09 Oct 2008 17:29:46 +0200
Andrea Righi <righi.andrea@gmail.com> wrote:

> The current granularity of 5% of dirtyable memory for dirty pages writeback is
> too coarse for large memory machines and this will get worse as
> memory-size/disk-speed ratio continues to increase.
> 
> These large writebacks can be unpleasant for desktop or latency-sensitive
> environments, where the time to complete a writeback can be perceived as a
> lack of responsiveness by the whole system.
> 
> So, something to define fine grained settings is needed.
> 
> Following there's a similar solution as discussed in [1], but I tried to
> simplify the things a little bit, in order to provide the same functionality
> (in particular try to avoid backward compatibility problems) and reduce the
> amount of code needed to implement an in-kernel parser to handle percentages
> with decimals digits.
> 
> The kernel provides the following parameters:
>  - dirty_ratio, dirty_background_ratio in percentage
>    (1 ... 100)
>  - dirty_ratio_pcm, dirty_background_ratio_pcm in units of percent mille
>    (1 ... 100,000)
> 
> Both dirty_ratio and dirty_ratio_pcm refer to the same vm_dirty_ratio variable,
> only the interface to read/write this value is different. The same is valid for
> dirty_background_ratio and dirty_background_ratio_pcm.
> 
> In this way it's possible to provide a fine grained interface to configure the
> writeback policy and at the same time preserve the compatibility with the old
> coarse grained dirty_ratio / dirty_background_ratio users.
> 
> Examples:
>  # echo 5 > /proc/sys/vm/dirty_ratio
>  # cat /proc/sys/vm/dirty_ratio
>  5
>  # cat /proc/sys/vm/dirty_ratio_pcm
>  5000
> 
>  # echo 500 > /proc/sys/vm/dirty_ratio_pcm
>  # cat /proc/sys/vm/dirty_ratio
>  0
>  # cat /proc/sys/vm/dirty_ratio_pcm
>  500
> 
>  # echo 5500 > /proc/sys/vm/dirty_ratio_pcm
>  # cat /proc/sys/vm/dirty_ratio
>  5
>  # cat /proc/sys/vm/dirty_ratio_pcm
>  5500
> 
I like this. thanks.

<snip>

> -int dirty_background_ratio = 5;
> +int dirty_background_ratio = 5 * PERCENT_PCM;
>  
>  /*
>   * free highmem will not be subtracted from the total free memory
> @@ -77,7 +77,7 @@ int vm_highmem_is_dirtyable;
>  /*
>   * The generator of dirty data starts writeback at this percentage
>   */
> -int vm_dirty_ratio = 10;
> +int vm_dirty_ratio = 10 * PERCENT_PCM;
>  
>  /*
>   * The interval between `kupdate'-style writebacks, in jiffies
> @@ -135,7 +135,8 @@ static int calc_period_shift(void)
>  {
>  	unsigned long dirty_total;
>  
> -	dirty_total = (vm_dirty_ratio * determine_dirtyable_memory()) / 100;
> +	dirty_total = (vm_dirty_ratio * determine_dirtyable_memory())
> +			/ ONE_HUNDRED_PCM;
>  	return 2 + ilog2(dirty_total - 1);
>  }
>  
I wonder...isn't this overflow in 32bit system ?

Thanks,
-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
