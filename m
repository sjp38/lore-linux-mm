Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx118.postini.com [74.125.245.118])
	by kanga.kvack.org (Postfix) with SMTP id 649396B0044
	for <linux-mm@kvack.org>; Wed, 19 Sep 2012 21:12:08 -0400 (EDT)
Message-ID: <505A6EB7.5070305@cn.fujitsu.com>
Date: Thu, 20 Sep 2012 09:17:43 +0800
From: Wen Congyang <wency@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH] memory-hotplug: fix zone stat mismatch
References: <1348039748-32111-1-git-send-email-minchan@kernel.org> <CAHGf_=oSSsJEeh7eN+R6P3n0vq2h5+3DPmogpXqDiu1jJyKmpg@mail.gmail.com> <20120919201738.GA2425@barrios>
In-Reply-To: <20120919201738.GA2425@barrios>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Shaohua Li <shli@fusionio.com>

At 09/20/2012 04:17 AM, Minchan Kim Wrote:
> Hi KOSAKI,
> 
> On Wed, Sep 19, 2012 at 02:05:20PM -0400, KOSAKI Motohiro wrote:
>> On Wed, Sep 19, 2012 at 3:29 AM, Minchan Kim <minchan@kernel.org> wrote:
>>> During memory-hotplug stress test, I found NR_ISOLATED_[ANON|FILE]
>>> are increasing so that kernel are hang out.
>>>
>>> The cause is that when we do memory-hotadd after memory-remove,
>>> __zone_pcp_update clear out zone's ZONE_STAT_ITEMS in setup_pageset
>>> without draining vm_stat_diff of all CPU.
>>>
>>> This patch fixes it.
>>
>> zone_pcp_update() is called from online pages path. but IMHO,
>> the statistics should be drained offline path. isn't it?
> 
> It isn't necessary because statistics is right until we reset it to zero
> in online path.
> Do you have something on your mind that we have to drain it in offline path?

When a node is offlined and onlined again. We create node_data[i] in the
function hotadd_new_pgdat(), and we will lost the statistics stored in
zone->pageset. So we should drain it in offline path.

Thanks
Wen Congyang

> 
>>
>> thanks.
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
