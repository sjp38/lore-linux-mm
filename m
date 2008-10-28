Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate7.uk.ibm.com (8.13.8/8.13.8) with ESMTP id m9SD03CM311300
	for <linux-mm@kvack.org>; Tue, 28 Oct 2008 13:00:03 GMT
Received: from d06av04.portsmouth.uk.ibm.com (d06av04.portsmouth.uk.ibm.com [9.149.37.216])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id m9SD03tn4325572
	for <linux-mm@kvack.org>; Tue, 28 Oct 2008 13:00:03 GMT
Received: from d06av04.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av04.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m9SD022W019729
	for <linux-mm@kvack.org>; Tue, 28 Oct 2008 13:00:03 GMT
Subject: Re: [PATCH] memory hotplug: fix page_zone() calculation in
	test_pages_isolated()
From: Gerald Schaefer <gerald.schaefer@de.ibm.com>
In-Reply-To: <20081028093224.a0de9f64.kamezawa.hiroyu@jp.fujitsu.com>
References: <4905F114.3030406@de.ibm.com>
	 <1225128359.12673.101.camel@nimitz>
	 <1225130369.20384.33.camel@localhost.localdomain>
	 <20081028093224.a0de9f64.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain
Date: Tue, 28 Oct 2008 14:00:01 +0100
Message-Id: <1225198802.10037.7.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Dave Hansen <dave@linux.vnet.ibm.com>, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com, y-goto@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

On Tue, 2008-10-28 at 09:32 +0900, KAMEZAWA Hiroyuki wrote:
> But
>  - "pfn" and "end_pfn" (and pfn in the middle of them) can be in different zone on strange machine.
> 
> Now: test_pages_isolated() is called in following sequence.
>   
>   check_page_isolated()
>      walk_memory_resource()			# read resource range and get start/end of pfn
>          -> chcek_page_isolated_cb()
> 		-> test_page_isolated().
> 
> I think all pages within [start, end) passed to test_pages_isolated() should be in the same zone.
> 
> please change this to
>   check_page_isolated()
>      walk_memory_resource()
>          -> check_page_isolated_cb()
>                  -> walk_page_range_in_same_zone()  # get page range in the same zone.
>                         -> test_page_isolated().
> 
> Could you try ?

There is already a "same zone" check at the beginning of offline_pages():

>	if (!test_pages_in_a_zone(start_pfn, end_pfn))
>		return -EINVAL;

So we should be safe here, the only problem that I see is that my
zone->lock patch in test_pages_isolated() is broken. As explained,
the pfn used in my page_zone(pfn_to_page(pfn)) is >= end_pfn.

I'll send a new patch to fix this, using __first_valid_page() again,
as described in my reply to Daves mail. The only other solution that
I see would be to remember the first/last !NULL page that was found
inside the for() loop. Not sure which is better, but I think I like
the first one more. Any other ideas?

Thanks,
Gerald


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
