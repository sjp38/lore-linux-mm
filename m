Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f48.google.com (mail-wg0-f48.google.com [74.125.82.48])
	by kanga.kvack.org (Postfix) with ESMTP id AD30B6B00A3
	for <linux-mm@kvack.org>; Mon, 24 Nov 2014 11:18:01 -0500 (EST)
Received: by mail-wg0-f48.google.com with SMTP id y19so12968653wgg.35
        for <linux-mm@kvack.org>; Mon, 24 Nov 2014 08:18:01 -0800 (PST)
Received: from mail-wg0-x229.google.com (mail-wg0-x229.google.com. [2a00:1450:400c:c00::229])
        by mx.google.com with ESMTPS id y19si12942584wij.47.2014.11.24.08.18.00
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 24 Nov 2014 08:18:00 -0800 (PST)
Received: by mail-wg0-f41.google.com with SMTP id y19so12669090wgg.28
        for <linux-mm@kvack.org>; Mon, 24 Nov 2014 08:18:00 -0800 (PST)
Date: Mon, 24 Nov 2014 17:17:57 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: =?utf-8?B?562U5aSNOiDnrZTlpI0=?= =?utf-8?Q?=3A?= low memory
 killer
Message-ID: <20141124161554.GA11742@curandero.mameluci.net>
References: <AF7C0ADF1FEABA4DABABB97411952A2EC91E38@CN-MBX02.HTC.COM.TW>
 <20141120095802.GA24575@dhcp22.suse.cz>
 <AF7C0ADF1FEABA4DABABB97411952A2EC91EF5@CN-MBX02.HTC.COM.TW>
 <20141120101855.GB24575@dhcp22.suse.cz>
 <AF7C0ADF1FEABA4DABABB97411952A2EC91FE0@CN-MBX02.HTC.COM.TW>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <AF7C0ADF1FEABA4DABABB97411952A2EC91FE0@CN-MBX02.HTC.COM.TW>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: zhiyuan_zhu@htc.com
Cc: hannes@cmpxchg.org, Future_Zhou@htc.com, Rachel_Zhang@htc.com, bsingharora@gmail.com, kamezawa.hiroyu@jp.fujitsu.com, cgroups@vger.kernel.org, linux-mm@kvack.org, greg@kroah.com, Sai_Shen@htc.com

On Thu 20-11-14 12:05:00, zhiyuan_zhu@htc.com wrote:
> Hi Greg/Michal
> Very sorry I have a mistake in previous mail. (It should be nr_file_pages not nr_free_pages)
> I rearrange this problem.
> 
> // *********** log begin **********
> 6      161030.084144       2014-11-07 21:44:53.304        lowmemorykiller: Killing 'om.htc.launcher' (4486), adj 294,
> 6      161030.084144       2014-11-07 21:44:53.304           to free 47856kB on behalf of 'kworker/u8:14' (20594) because
> 6      161030.084144       2014-11-07 21:44:53.304           cache 72460kB is below limit 73728kB for oom_score_adj 235

This is missing the last line which dumps Free memory (at least from the
snippet below, because nothing like that is in the current driver code
anymore)

> //  **** /proc/meminfo 's result
> 4      161030.084797       2014-11-07 21:44:53.304        Cached:           142448 kB
> // *********** log end **********
> 
> After I checked the android's low memory strategy: kernel/drivers/staging/android/lowmemorykiller.c
> 
> // ****** code begin *********
> 		other_file = global_page_state(NR_FILE_PAGES) -
> 						global_page_state(NR_SHMEM) -
> 						total_swapcache_pages();
> 
> 		lowmem_print(1, "Killing '%s' (%d), adj %hd,\n" \
> 				"   to free %ldkB on behalf of '%s' (%d) because\n" \
> 				"   cache %ldkB is below limit %ldkB for oom_score_adj %hd\n" \
> 				"   Free memory is %ldkB above reserved\n",
> 			     selected->comm, selected->pid,
> 			     selected_oom_score_adj,
> 			     selected_tasksize * (long)(PAGE_SIZE / 1024),
> 			     current->comm, current->pid,
> 			     other_file * (long)(PAGE_SIZE / 1024),
> 			     minfree * (long)(PAGE_SIZE / 1024),
> 			     min_score_adj,
> 			     other_free * (long)(PAGE_SIZE / 1024));
> // ******* code end ************
> 
> So android's strategy's free memory is = other_file = (nr file pages - nr shmem - total swapcache pages) * 4K = [cache 72460kB]
> But the system's free memory is: Cached:        142448 kB  // from /proc/meminfo

I have already pointed you at meminfo_proc_show() which calculates the
shown value as:
	cached = global_page_state(NR_FILE_PAGES) -
	                        total_swapcache_pages() - i.bufferram;

That means that the two differ by NR_SHMEM - i.bufferram. 

> And system's free memory is: Cached + MemFree + Buffers is largely
> than the memory which anroid lowmemorykiller calculated memory [cache
> 72460K] At this time point, system will kill some important processes,
> but system have enough memory.  This is android's lowmemorykiller
> defect? or Linux kernel memory's defect?

It looks most likely be lowmemory killer bug but this is hard to tell as
I do not know which kernel version are you looking at and what are the
additional patch on top of Vanilla kernel.
The upstream code doesn't care about Cached value as presented by
/proc/meminfo

> So I have some questions:
> I have a question: what's the nr file pages mean?

It counts page cache pages (aka pages backed by a file). This includes
also SHMEM pages.

> What different between nr_file_pages from Cached (from /proc/meminfo)?

See above about meminfo_proc_show.

> And nr shmem, swapcache pages are small, so I think this is the key
> problem why android's stragegy calculated free memory is largely less
> than /proc/meminfo Cached's value.

I do not see the value of shmem and swapcache from the time when the
situation was evaluated.

Anyway I do not think there would be problem with counters but rather
the way how they are used by lowmemory killer and I would be looking
into that code first before checking the core kernel.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
