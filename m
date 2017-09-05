Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id BD6C66B04D1
	for <linux-mm@kvack.org>; Tue,  5 Sep 2017 02:29:51 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id r75so2834798wmf.6
        for <linux-mm@kvack.org>; Mon, 04 Sep 2017 23:29:51 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id d30si2376469wra.79.2017.09.04.23.29.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 04 Sep 2017 23:29:50 -0700 (PDT)
Received: from pps.filterd (m0098414.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v856ScNG004535
	for <linux-mm@kvack.org>; Tue, 5 Sep 2017 02:29:48 -0400
Received: from e23smtp07.au.ibm.com (e23smtp07.au.ibm.com [202.81.31.140])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2cshw8bh8t-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 05 Sep 2017 02:29:48 -0400
Received: from localhost
	by e23smtp07.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Tue, 5 Sep 2017 16:29:45 +1000
Received: from d23av05.au.ibm.com (d23av05.au.ibm.com [9.190.234.119])
	by d23relay07.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v856TgPs39452826
	for <linux-mm@kvack.org>; Tue, 5 Sep 2017 16:29:43 +1000
Received: from d23av05.au.ibm.com (localhost [127.0.0.1])
	by d23av05.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v856Tg5L013743
	for <linux-mm@kvack.org>; Tue, 5 Sep 2017 16:29:42 +1000
Subject: Re: [PATCH 1/2] mm, memory_hotplug: do not fail offlining too early
References: <20170904082148.23131-1-mhocko@kernel.org>
 <20170904082148.23131-2-mhocko@kernel.org>
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Date: Tue, 5 Sep 2017 11:59:36 +0530
MIME-Version: 1.0
In-Reply-To: <20170904082148.23131-2-mhocko@kernel.org>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Message-Id: <b8e8ffdf-4f7b-2a02-5869-53b23da645d0@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, qiuxishi@huawei.com, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On 09/04/2017 01:51 PM, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
> 
> Memory offlining can fail just too eagerly under a heavy memory pressure.
> 
> [ 5410.336792] page:ffffea22a646bd00 count:255 mapcount:252 mapping:ffff88ff926c9f38 index:0x3
> [ 5410.336809] flags: 0x9855fe40010048(uptodate|active|mappedtodisk)
> [ 5410.336811] page dumped because: isolation failed
> [ 5410.336813] page->mem_cgroup:ffff8801cd662000
> [ 5420.655030] memory offlining [mem 0x18b580000000-0x18b5ffffffff] failed
> 
> Isolation has failed here because the page is not on LRU. Most probably
> because it was on the pcp LRU cache or it has been removed from the LRU
> already but it hasn't been freed yet. In both cases the page doesn't look
> non-migrable so retrying more makes sense.
> 
> __offline_pages seems rather cluttered when it comes to the retry
> logic. We have 5 retries at maximum and a timeout. We could argue
> whether the timeout makes sense but failing just because of a race when
> somebody isoltes a page from LRU or puts it on a pcp LRU lists is just
> wrong. It only takes it to race with a process which unmaps some pages
> and remove them from the LRU list and we can fail the whole offline
> because of something that is a temporary condition and actually not
> harmful for the offline. Please note that unmovable pages should be
> already excluded during start_isolate_page_range.
> 
> Fix this by removing the max retry count and only rely on the timeout
> resp. interruption by a signal from the userspace. Also retry rather
> than fail when check_pages_isolated sees some !free pages because those
> could be a result of the race as well.
> 
> Signed-off-by: Michal Hocko <mhocko@suse.com>
> ---
>  mm/memory_hotplug.c | 40 ++++++++++------------------------------
>  1 file changed, 10 insertions(+), 30 deletions(-)
> 
> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> index 459bbc182d10..c9dcbe6d2ac6 100644
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -1597,7 +1597,7 @@ static int __ref __offline_pages(unsigned long start_pfn,
>  {
>  	unsigned long pfn, nr_pages, expire;
>  	long offlined_pages;
> -	int ret, drain, retry_max, node;
> +	int ret, node;
>  	unsigned long flags;
>  	unsigned long valid_start, valid_end;
>  	struct zone *zone;
> @@ -1634,43 +1634,25 @@ static int __ref __offline_pages(unsigned long start_pfn,
>  
>  	pfn = start_pfn;
>  	expire = jiffies + timeout;
> -	drain = 0;
> -	retry_max = 5;
>  repeat:
>  	/* start memory hot removal */
> -	ret = -EAGAIN;
> +	ret = -EBUSY;
>  	if (time_after(jiffies, expire))
>  		goto failed_removal;
>  	ret = -EINTR;
>  	if (signal_pending(current))
>  		goto failed_removal;
> -	ret = 0;
> -	if (drain) {
> -		lru_add_drain_all_cpuslocked();
> -		cond_resched();
> -		drain_all_pages(zone);
> -	}

Why we had this condition before that only when we fail in migration
later in do_migrate_range function, drain the lru lists in the next
attempt. Why not from the first attempt itself ? Just being curious.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
