Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id E29AD6B0253
	for <linux-mm@kvack.org>; Sat, 17 Dec 2016 06:17:25 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id g1so15875981pgn.3
        for <linux-mm@kvack.org>; Sat, 17 Dec 2016 03:17:25 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id c186si12123162pga.181.2016.12.17.03.17.24
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sat, 17 Dec 2016 03:17:24 -0800 (PST)
Subject: Re: [PATCH 2/2] mm, oom: do not enfore OOM killer for __GFP_NOFAIL
 automatically
References: <20161216073941.GA26976@dhcp22.suse.cz>
 <20161216155808.12809-1-mhocko@kernel.org>
 <20161216155808.12809-3-mhocko@kernel.org>
 <20161216173151.GA23182@cmpxchg.org> <20161216221202.GE7645@dhcp22.suse.cz>
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Message-ID: <18652e94-8f5c-dcf1-16e6-0deab6c642ec@I-love.SAKURA.ne.jp>
Date: Sat, 17 Dec 2016 20:17:07 +0900
MIME-Version: 1.0
In-Reply-To: <20161216221202.GE7645@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>
Cc: Nils Holland <nholland@tisys.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Chris Mason <clm@fb.com>, David Sterba <dsterba@suse.cz>, linux-btrfs@vger.kernel.org

Michal Hocko wrote:
> On Fri 16-12-16 12:31:51, Johannes Weiner wrote:
>>> @@ -3737,6 +3752,16 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
>>>  		 */
>>>  		WARN_ON_ONCE(order > PAGE_ALLOC_COSTLY_ORDER);
>>>  
>>> +		/*
>>> +		 * Help non-failing allocations by giving them access to memory
>>> +		 * reserves but do not use ALLOC_NO_WATERMARKS because this
>>> +		 * could deplete whole memory reserves which would just make
>>> +		 * the situation worse
>>> +		 */
>>> +		page = __alloc_pages_cpuset_fallback(gfp_mask, order, ALLOC_HARDER, ac);
>>> +		if (page)
>>> +			goto got_pg;
>>> +
>>
>> But this should be a separate patch, IMO.
>>
>> Do we observe GFP_NOFS lockups when we don't do this? 
> 
> this is hard to tell but considering users like grow_dev_page we can get
> stuck with a very slow progress I believe. Those allocations could see
> some help.
> 
>> Don't we risk
>> premature exhaustion of the memory reserves, and it's better to wait
>> for other reclaimers to make some progress instead?
> 
> waiting for other reclaimers would be preferable but we should at least
> give these some priority, which is what ALLOC_HARDER should help with.
> 
>> Should we give
>> reserve access to all GFP_NOFS allocations, or just the ones from a
>> reclaim/cleaning context?
> 
> I would focus only for those which are important enough. Which are those
> is a harder question. But certainly those with GFP_NOFAIL are important
> enough.
> 
>> All that should go into the changelog of a separate allocation booster
>> patch, I think.
> 
> The reason I did both in the same patch is to address the concern about
> potential lockups when NOFS|NOFAIL cannot make any progress. I've chosen
> ALLOC_HARDER to give the minimum portion of the reserves so that we do
> not risk other high priority users to be blocked out but still help a
> bit at least and prevent from starvation when other reclaimers are
> faster to consume the reclaimed memory.
> 
> I can extend the changelog of course but I believe that having both
> changes together makes some sense. NOFS|NOFAIL allocations are not all
> that rare and sometimes we really depend on them making a further
> progress.
> 

I feel that allowing access to memory reserves based on __GFP_NOFAIL might not
make sense. My understanding is that actual I/O operation triggered by I/O
requests by filesystem code are processed by other threads. Even if we grant
access to memory reserves to GFP_NOFS | __GFP_NOFAIL allocations by fs code,
I think that it is possible that memory allocations by underlying bio code
fails to make a further progress unless memory reserves are granted as well.

Below is a typical trace which I observe under OOM lockuped situation (though
this trace is from an OOM stress test using XFS).

----------------------------------------
[ 1845.187246] MemAlloc: kworker/2:1(14498) flags=0x4208060 switches=323636 seq=48 gfp=0x2400000(GFP_NOIO) order=0 delay=430400 uninterruptible
[ 1845.187248] kworker/2:1     D12712 14498      2 0x00000080
[ 1845.187251] Workqueue: events_freezable_power_ disk_events_workfn
[ 1845.187252] Call Trace:
[ 1845.187253]  ? __schedule+0x23f/0xba0
[ 1845.187254]  schedule+0x38/0x90
[ 1845.187255]  schedule_timeout+0x205/0x4a0
[ 1845.187256]  ? del_timer_sync+0xd0/0xd0
[ 1845.187257]  schedule_timeout_uninterruptible+0x25/0x30
[ 1845.187258]  __alloc_pages_nodemask+0x1035/0x10e0
[ 1845.187259]  ? alloc_request_struct+0x14/0x20
[ 1845.187261]  alloc_pages_current+0x96/0x1b0
[ 1845.187262]  ? bio_alloc_bioset+0x20f/0x2e0
[ 1845.187264]  bio_copy_kern+0xc4/0x180
[ 1845.187265]  blk_rq_map_kern+0x6f/0x120
[ 1845.187268]  __scsi_execute.isra.23+0x12f/0x160
[ 1845.187270]  scsi_execute_req_flags+0x8f/0x100
[ 1845.187271]  sr_check_events+0xba/0x2b0 [sr_mod]
[ 1845.187274]  cdrom_check_events+0x13/0x30 [cdrom]
[ 1845.187275]  sr_block_check_events+0x25/0x30 [sr_mod]
[ 1845.187276]  disk_check_events+0x5b/0x150
[ 1845.187277]  disk_events_workfn+0x17/0x20
[ 1845.187278]  process_one_work+0x1fc/0x750
[ 1845.187279]  ? process_one_work+0x167/0x750
[ 1845.187279]  worker_thread+0x126/0x4a0
[ 1845.187280]  kthread+0x10a/0x140
[ 1845.187281]  ? process_one_work+0x750/0x750
[ 1845.187282]  ? kthread_create_on_node+0x60/0x60
[ 1845.187283]  ret_from_fork+0x2a/0x40
----------------------------------------

I think that this GFP_NOIO allocation request needs to consume more memory reserves
than GFP_NOFS allocation request to make progress. 
Do we want to add __GFP_NOFAIL to this GFP_NOIO allocation request in order to allow
access to memory reserves as well as GFP_NOFS | __GFP_NOFAIL allocation request?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
