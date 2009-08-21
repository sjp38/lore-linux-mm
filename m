Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id DDD1F6B00A4
	for <linux-mm@kvack.org>; Fri, 21 Aug 2009 11:50:06 -0400 (EDT)
Received: from fgwmail7.fujitsu.co.jp (fgwmail7.fujitsu.co.jp [192.51.44.37])
	by fgwmail8.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n7L25hLm012594
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 21 Aug 2009 11:05:43 +0900
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n7L258n9016439
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 21 Aug 2009 11:05:08 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 6F4D845DE52
	for <linux-mm@kvack.org>; Fri, 21 Aug 2009 11:05:08 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 4567745DE51
	for <linux-mm@kvack.org>; Fri, 21 Aug 2009 11:05:08 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 23A8C1DB803F
	for <linux-mm@kvack.org>; Fri, 21 Aug 2009 11:05:08 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id C21851DB803B
	for <linux-mm@kvack.org>; Fri, 21 Aug 2009 11:05:04 +0900 (JST)
Date: Fri, 21 Aug 2009 11:03:09 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [Patch 8/8] kexec: allow to shrink reserved memory
Message-Id: <20090821110309.2d5ffb62.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090821015927.GA4447@cr0.nay.redhat.com>
References: <4A8927DD.6060209@redhat.com>
	<20090818092939.2efbe158.kamezawa.hiroyu@jp.fujitsu.com>
	<4A8A4ABB.70003@redhat.com>
	<20090818172552.779d0768.kamezawa.hiroyu@jp.fujitsu.com>
	<4A8A83F4.6010408@redhat.com>
	<20090819085703.ccf9992a.kamezawa.hiroyu@jp.fujitsu.com>
	<4A8B6649.3080103@redhat.com>
	<20090819171346.aadfeb2c.kamezawa.hiroyu@jp.fujitsu.com>
	<4A8D144C.5050005@redhat.com>
	<20090821093452.ead96b2d.kamezawa.hiroyu@jp.fujitsu.com>
	<20090821015927.GA4447@cr0.nay.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Amerigo Wang <xiyou.wangcong@gmail.com>
Cc: Amerigo Wang <amwang@redhat.com>, "Eric W. Biederman" <ebiederm@xmission.com>, linux-kernel@vger.kernel.org, tony.luck@intel.com, linux-ia64@vger.kernel.org, linux-mm@kvack.org, Neil Horman <nhorman@redhat.com>, Andi Kleen <andi@firstfloor.org>, akpm@linux-foundation.org, bernhard.walle@gmx.de, Fenghua Yu <fenghua.yu@intel.com>, Ingo Molnar <mingo@elte.hu>, Anton Vorontsov <avorontsov@ru.mvista.com>
List-ID: <linux-mm.kvack.org>

On Fri, 21 Aug 2009 09:59:27 +0800
Amerigo Wang <xiyou.wangcong@gmail.com> wrote:

> On Fri, Aug 21, 2009 at 09:34:52AM +0900, KAMEZAWA Hiroyuki wrote:
> >On Thu, 20 Aug 2009 17:15:56 +0800
> >Amerigo Wang <amwang@redhat.com> wrote:
> >    
> >> > The, problem is whether memmap is there or not. That's all.
> >> > plz see init sequence and check there are memmap.
> >> > If memory-for-crash is obtained via bootmem,
> >> > Don't you try to free memory hole ?
> >> >   
> >> 
> >> Hi,
> >> 
> >> It looks like that mem_map has 'struct page' for the reserved memory, I 
> >> checked my "early_node_map[] active PFN ranges" output, the reserved 
> >> memory area for crash kernel is right in one range. Am I missing 
> >> something here?
> >> 
> >> I don't know why that oops comes out, maybe because of no PTE for thoese 
> >> pages?
> >> 
> >Hmm ? Could you show me the code you use ?
> 
> (Sorry that I reply to you with my gmail, my work email can't send out
> this message, probably because one of the destinations is broken...
> I am the same person, don't be confused. :-)
> 
> Sure. Below is it:
> 
> +    for (addr = end + 1; addr < crashk_res.end; addr += PAGE_SIZE) {
> +        printk(KERN_DEBUG "PFN is valid? %d\n", pfn_valid(addr>>PAGE_SHIFT));
> +        ClearPageReserved(virt_to_page(addr));
> +        init_page_count(virt_to_page(addr));
> +        free_page(addr);
> +        totalram_pages++;
> +    }
> 
> 
> pfn_valid() returns 1, and oops happens at ClearPageReserved().
> ('addr' is right between crashk_res.start and crashk_res.end)

Confused, 
  if    pfn_valid(addr >> PAGE_SHIFT) == true 

you should do
	ClearPageReserved(pfn_to_page(addr >> PAGE_SHIFT));

because addr is physical address, not virtual.
I guess crashk_res.end is physical address....

Thanks,
-Kame


> 
> Thank you!
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
