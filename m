Received: from sd0208e0.au.ibm.com (d23rh904.au.ibm.com [202.81.18.202])
	by ausmtp05.au.ibm.com (8.13.8/8.13.6) with ESMTP id kAG4derY7307374
	for <linux-mm@kvack.org>; Thu, 16 Nov 2006 03:39:43 -0100
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.250.237])
	by sd0208e0.au.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id kAFGexAW176024
	for <linux-mm@kvack.org>; Thu, 16 Nov 2006 03:41:04 +1100
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id kAFGbWUF013991
	for <linux-mm@kvack.org>; Thu, 16 Nov 2006 03:37:33 +1100
Message-ID: <455B4245.8000309@in.ibm.com>
Date: Wed, 15 Nov 2006 22:07:25 +0530
From: Balbir Singh <balbir@in.ibm.com>
Reply-To: balbir@in.ibm.com
MIME-Version: 1.0
Subject: Re: [ckrm-tech] [RFC][PATCH 5/8] RSS controller task migration	support
References: <20061115115937.B0A851B6A2@openx4.frec.bull.fr>
In-Reply-To: <20061115115937.B0A851B6A2@openx4.frec.bull.fr>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Patrick.Le-Dot" <Patrick.Le-Dot@bull.net>
Cc: dev@openvz.org, ckrm-tech@lists.sourceforge.net, haveblue@us.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, rohitseth@google.com
List-ID: <linux-mm.kvack.org>

Patrick.Le-Dot wrote:
> Hi Balbir,
> 
> The get_task_mm()/mmput(mm) usage is not correct.
> With CONFIG_DEBUG_SPINLOCK_SLEEP=y :
> 
> BUG: sleeping function called from invalid context at kernel/fork.c:390
> in_atomic():1, irqs_disabled():0
>  [<c0116620>] __might_sleep+0x97/0x9c
>  [<c0116a2e>] mmput+0x15/0x8b
>  [<c01582f6>] install_arg_page+0x72/0xa9
>  [<c01584b1>] setup_arg_pages+0x184/0x1a5
>  ...
> 
> BUG: sleeping function called from invalid context at kernel/fork.c:390
> in_atomic():1, irqs_disabled():0
>  [<c0116620>] __might_sleep+0x97/0x9c
>  [<c0116a2e>] mmput+0x15/0x8b
>  [<c01468ee>] do_no_page+0x255/0x2bd
>  [<c0146b8d>] __handle_mm_fault+0xed/0x1ef
>  [<c0111884>] do_page_fault+0x247/0x506
>  [<c011163d>] do_page_fault+0x0/0x506
>  [<c0348f99>] error_code+0x39/0x40
> 
> 
> current->mm seems to be enough here.

Excellent, thanks for catching this!

> 
> 
> 
> In patch4, memctlr_dec_rss(page, mm) should be memctlr_dec_rss(page)
> to compile correctly.
> 
> and in patch0 :
>> 4. Disable cpuset's (to simply assignment of tasks to resource groups)
>>         cd /container
>>         echo 0 > cpuset_enabled
> 
> should be :
>         echo 0 > cpuacct_enabled
> 
> Note : cpuacct_enabled is 0 by default.
> 

Thanks for pointing this out.

> 
> Now the big question : to implement guarantee, the LRU needs to know
> if a page can be removed from memory or not.
> Any ideas to do that without any change in the struct page ?
> 

For implementing guarantees, we can use limits. Please see
http://wiki.openvz.org/Containers/Guarantees_for_resources.


Thanks for the feedback!

-- 

	Balbir Singh,
	Linux Technology Center,
	IBM Software Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
