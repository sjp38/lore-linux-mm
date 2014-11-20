Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f41.google.com (mail-wg0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id D3C276B0073
	for <linux-mm@kvack.org>; Thu, 20 Nov 2014 04:58:04 -0500 (EST)
Received: by mail-wg0-f41.google.com with SMTP id y19so3204365wgg.14
        for <linux-mm@kvack.org>; Thu, 20 Nov 2014 01:58:04 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g9si3522509wie.98.2014.11.20.01.58.03
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 20 Nov 2014 01:58:03 -0800 (PST)
Date: Thu, 20 Nov 2014 10:58:02 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: low memory killer
Message-ID: <20141120095802.GA24575@dhcp22.suse.cz>
References: <AF7C0ADF1FEABA4DABABB97411952A2EC91E38@CN-MBX02.HTC.COM.TW>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <AF7C0ADF1FEABA4DABABB97411952A2EC91E38@CN-MBX02.HTC.COM.TW>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: zhiyuan_zhu@htc.com
Cc: hannes@cmpxchg.org, Future_Zhou@htc.com, Rachel_Zhang@htc.com, bsingharora@gmail.com, kamezawa.hiroyu@jp.fujitsu.com, cgroups@vger.kernel.org, linux-mm@kvack.org, Greg KH <greg@kroah.com>

[Adding Greg to CC as the current maintainer of the staging and dropping
majordomo]

I am not Johannes but,

On Thu 20-11-14 09:26:05, zhiyuan_zhu@htc.com wrote:
> hi Johannes
> 
> My name is Zhiyuan zhu, an android development engineer in htc.
> We encounter a lowmemorykillera??s problem.
> Coluld you help to kindly support? Thank you.

Please note that lowmemory killer is not part of Memory cgroup resource
controller. It is a staging driver which is supposed to be supported by
support by Android people. I am not sure about the current state but the
implementation and some concepts used to be broken in many ways.
Anyway I think the driver should be dropped from the tree or try to get
promoted to the regular tree _after_ it passes a proper review.
 
> Problem describtion:
> We noticed that gap of dumping cached value from a??lowmemorykillera??
> and a??/proc/meminfo/a?? are different apparently. Like example below,
> lowmemorykiller showed cache only has 72460kB while launcher was
> killed, but /proc/meminfo showed cached still has 142448kB. Please
> check why the gap of cache value between lowmemorykill and
> /proc/meminfo are huge.

lowmem_scan prints:
other_file = global_page_state(NR_FILE_PAGES) - global_page_state(NR_SHMEM) - total_swapcache_pages();

as per meminfo_proc_show(), Cached value corresponds to:
        cached = global_page_state(NR_FILE_PAGES) - total_swapcache_pages() - i.bufferram;

So those two values are quite different. E.g. lowmem killer ignores
shmem pages. This can be considerable amount of memory.

> kernel_e0058_0001_20141107_204711_LC4ABYA00200_htc_a31ul_0.54.999.1.txt at LC4ABYA00200
>         6      161030.084144       2014-11-07 21:44:53.304        lowmemorykiller: Killing 'om.htc.launcher' (4486), adj 294,
> 6      161030.084144       2014-11-07 21:44:53.304           to free 47856kB on behalf of 'kworker/u8:14' (20594) because
> 6      161030.084144       2014-11-07 21:44:53.304           cache 72460kB is below limit 73728kB for oom_score_adj 235
> 6      161030.084144       2014-11-07 21:44:53.304           Free memory is 51304kB above reserved
> 4      161030.084797       2014-11-07 21:44:53.304        MemFree:           55676 kB
> 4      161030.084797       2014-11-07 21:44:53.304        Buffers:            1240 kB
> 4      161030.084797       2014-11-07 21:44:53.304        Cached:           142448 kB

I do not see any code in drivers/staging/android/lowmemorykiller.c that
would print such an information in the current tree.

> Lowmemorykiller calculated cache value is 72460kB, but the
> /proc/meminfoa??s cached is 142448 kB
> 
> After checked the code, I found that:
> Lowmemorykillera??s memory information is comes from /proc/zoneinfo
> filea??s nr_file_pages So I want to know how different the
> /proc/zoneinfo filea??s nr_file_pages and /proc/meminfo filea??s
> Cached ?

See the above.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
