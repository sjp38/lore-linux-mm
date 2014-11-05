Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id B846A6B00BB
	for <linux-mm@kvack.org>; Tue,  4 Nov 2014 21:18:39 -0500 (EST)
Received: by mail-pa0-f50.google.com with SMTP id eu11so15824922pac.9
        for <linux-mm@kvack.org>; Tue, 04 Nov 2014 18:18:38 -0800 (PST)
Received: from heian.cn.fujitsu.com ([59.151.112.132])
        by mx.google.com with ESMTP id lj12si1868064pab.5.2014.11.04.18.18.36
        for <linux-mm@kvack.org>;
        Tue, 04 Nov 2014 18:18:37 -0800 (PST)
Message-ID: <545988BE.3050201@cn.fujitsu.com>
Date: Wed, 5 Nov 2014 10:17:34 +0800
From: Tang Chen <tangchen@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/2] mem-hotplug: Fix wrong check for zone->pageset initialization
 in online_pages().
References: <1414748812-22610-1-git-send-email-tangchen@cn.fujitsu.com> <1414748812-22610-3-git-send-email-tangchen@cn.fujitsu.com> <545976F9.50503@jp.fujitsu.com>
In-Reply-To: <545976F9.50503@jp.fujitsu.com>
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, akpm@linux-foundation.org, santosh.shilimkar@ti.com, grygorii.strashko@ti.com, yinghai@kernel.org, isimatu.yasuaki@jp.fujitsu.co, fabf@skynet.be, nzimmer@sgi.com, wangnan0@huawei.com, vdavydov@parallels.com, toshi.kani@hp.com, phacht@linux.vnet.ibm.com, tj@kernel.org, kirill.shutemov@linux.intel.com, riel@redhat.com, luto@amacapital.net, hpa@linux.intel.com, aarcange@redhat.com, qiuxishi@huawei.com, mgorman@suse.de, rientjes@google.com, hannes@cmpxchg.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Gu Zheng <guz.fnst@cn.fujitsu.com>, jiang.liu@linux.intel.com

On 11/05/2014 09:01 AM, Kamezawa Hiroyuki wrote:
> ......
> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> index 3ab01b2..bc0de0f 100644
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -1013,9 +1013,13 @@ int __ref online_pages(unsigned long pfn, unsigned long nr_pages, int online_typ
>   	 * If this zone is not populated, then it is not in zonelist.
>   	 * This means the page allocator ignores this zone.
>   	 * So, zonelist must be updated after online.
> +	 *
> +	 * If this zone is populated, zone->pageset could be initialized
> +	 * to boot_pageset for the first time a node is added. If so,
> +	 * zone->pageset should be allocated.
>   	 */
>   	mutex_lock(&zonelists_mutex);
> -	if (!populated_zone(zone)) {
> +	if (!populated_zone(zone) || !zone_pcp_initialized(zone)) {
> Please don't add another strange meanings to zone's pcplist.
>
> If you say zone->present_pages doesn't mean zone has pages in buddy list any more,
> please rewrite all parts using zone->present_pages including populated_zone().

Adding Liu Jiang...

I think zone->managed_pages was introduced by Liu Jiang in the following
patch:
