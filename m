Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id m9S0WrDu011931
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 28 Oct 2008 09:32:54 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id C60F22AC029
	for <linux-mm@kvack.org>; Tue, 28 Oct 2008 09:32:53 +0900 (JST)
Received: from s8.gw.fujitsu.co.jp (s8.gw.fujitsu.co.jp [10.0.50.98])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 7D81512C054
	for <linux-mm@kvack.org>; Tue, 28 Oct 2008 09:32:53 +0900 (JST)
Received: from s8.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s8.gw.fujitsu.co.jp (Postfix) with ESMTP id 269FB1DB803E
	for <linux-mm@kvack.org>; Tue, 28 Oct 2008 09:32:53 +0900 (JST)
Received: from ml10.s.css.fujitsu.com (ml10.s.css.fujitsu.com [10.249.87.100])
	by s8.gw.fujitsu.co.jp (Postfix) with ESMTP id AAD051DB8043
	for <linux-mm@kvack.org>; Tue, 28 Oct 2008 09:32:52 +0900 (JST)
Date: Tue, 28 Oct 2008 09:32:24 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] memory hotplug: fix page_zone() calculation in
 test_pages_isolated()
Message-Id: <20081028093224.a0de9f64.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1225130369.20384.33.camel@localhost.localdomain>
References: <4905F114.3030406@de.ibm.com>
	<1225128359.12673.101.camel@nimitz>
	<1225130369.20384.33.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Gerald Schaefer <gerald.schaefer@de.ibm.com>
Cc: Dave Hansen <dave@linux.vnet.ibm.com>, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com, y-goto@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

On Mon, 27 Oct 2008 18:59:29 +0100
Gerald Schaefer <gerald.schaefer@de.ibm.com> wrote:
> Instead of using pfn_to_page() you could also have just called
> > __first_valid_page() again.  But, that would have duplicated a bit of
> > work, even though not much in practice because the caches are still hot.
> > 
> > Technically, you wouldn't even need to check the return from
> > __first_valid_page() since you know it has a valid result because you
> > made the exact same call a moment before.
> > 
> > Anyway, can you remove the !page check, fix up the changelog and resend?
> 
> Calling __first_valid_page() again might be a good idea. Thinking about it
> now, I guess there is still a problem left with my patch, but for reasons
> other than what you said :) If the loop is completed with page == NULL,
> we will return -EBUSY with the new patch. But there may have been valid
> pages before, and only some memory hole at the end. In this case, returning
> -EBUSY would probably be wrong.
> 
> Kamezawa, this loop/function was added by you, what do you think?
> 

I think there is a bug, as you wrote.
But
 - "pfn" and "end_pfn" (and pfn in the middle of them) can be in different zone on strange machine.

Now: test_pages_isolated() is called in following sequence.
  
  check_page_isolated()
     walk_memory_resource()			# read resource range and get start/end of pfn
         -> chcek_page_isolated_cb()
		-> test_page_isolated().

I think all pages within [start, end) passed to test_pages_isolated() should be in the same zone.

please change this to
  check_page_isolated()
     walk_memory_resource()
         -> check_page_isolated_cb()
                 -> walk_page_range_in_same_zone()  # get page range in the same zone.
                        -> test_page_isolated().

Could you try ?

Thanks,
-Kame
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
