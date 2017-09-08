Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1B1176B0347
	for <linux-mm@kvack.org>; Fri,  8 Sep 2017 13:27:31 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id k20so3022842wre.6
        for <linux-mm@kvack.org>; Fri, 08 Sep 2017 10:27:31 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n9si1811113wre.227.2017.09.08.10.27.29
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 08 Sep 2017 10:27:29 -0700 (PDT)
Subject: Re: [PATCH 2/2] mm, memory_hotplug: remove timeout from
 __offline_memory
References: <20170904082148.23131-1-mhocko@kernel.org>
 <20170904082148.23131-3-mhocko@kernel.org>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <d88f141b-f782-4352-f2b0-00639352097e@suse.cz>
Date: Fri, 8 Sep 2017 19:27:28 +0200
MIME-Version: 1.0
In-Reply-To: <20170904082148.23131-3-mhocko@kernel.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, qiuxishi@huawei.com, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On 09/04/2017 10:21 AM, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
> 
> We have a hardcoded 120s timeout after which the memory offline fails
> basically since the hot remove has been introduced. This is essentially
> a policy implemented in the kernel. Moreover there is no way to adjust
> the timeout and so we are sometimes facing memory offline failures if
> the system is under a heavy memory pressure or very intensive CPU
> workload on large machines.
> 
> It is not very clear what purpose the timeout actually serves. The
> offline operation is interruptible by a signal so if userspace wants
> some timeout based termination this can be done trivially by sending a
> signal.
> 
> If there is a strong usecase to do this from the kernel then we should
> do it properly and have a it tunable from the userspace with the timeout
> disabled by default along with the explanation who uses it and for what
> purporse.
> 
> Signed-off-by: Michal Hocko <mhocko@suse.com>

Makes sense to me.

Acked-by: Vlastimil Babka <vbabka@suse.cz>

> ---
>  mm/memory_hotplug.c | 10 +++-------
>  1 file changed, 3 insertions(+), 7 deletions(-)
> 
> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> index c9dcbe6d2ac6..b8a85c11360e 100644
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -1593,9 +1593,9 @@ static void node_states_clear_node(int node, struct memory_notify *arg)
>  }
>  
>  static int __ref __offline_pages(unsigned long start_pfn,
> -		  unsigned long end_pfn, unsigned long timeout)
> +		  unsigned long end_pfn)
>  {
> -	unsigned long pfn, nr_pages, expire;
> +	unsigned long pfn, nr_pages;
>  	long offlined_pages;
>  	int ret, node;
>  	unsigned long flags;
> @@ -1633,12 +1633,8 @@ static int __ref __offline_pages(unsigned long start_pfn,
>  		goto failed_removal;
>  
>  	pfn = start_pfn;
> -	expire = jiffies + timeout;
>  repeat:
>  	/* start memory hot removal */
> -	ret = -EBUSY;
> -	if (time_after(jiffies, expire))
> -		goto failed_removal;
>  	ret = -EINTR;
>  	if (signal_pending(current))
>  		goto failed_removal;
> @@ -1711,7 +1707,7 @@ static int __ref __offline_pages(unsigned long start_pfn,
>  /* Must be protected by mem_hotplug_begin() or a device_lock */
>  int offline_pages(unsigned long start_pfn, unsigned long nr_pages)
>  {
> -	return __offline_pages(start_pfn, start_pfn + nr_pages, 120 * HZ);
> +	return __offline_pages(start_pfn, start_pfn + nr_pages);
>  }
>  #endif /* CONFIG_MEMORY_HOTREMOVE */
>  
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
