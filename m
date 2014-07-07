Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com [209.85.212.177])
	by kanga.kvack.org (Postfix) with ESMTP id BE36C6B003B
	for <linux-mm@kvack.org>; Mon,  7 Jul 2014 07:34:48 -0400 (EDT)
Received: by mail-wi0-f177.google.com with SMTP id r20so6681411wiv.16
        for <linux-mm@kvack.org>; Mon, 07 Jul 2014 04:34:48 -0700 (PDT)
Received: from mail-wi0-x22e.google.com (mail-wi0-x22e.google.com [2a00:1450:400c:c05::22e])
        by mx.google.com with ESMTPS id cl19si49565779wjb.18.2014.07.07.04.34.47
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 07 Jul 2014 04:34:48 -0700 (PDT)
Received: by mail-wi0-f174.google.com with SMTP id bs8so15816834wib.13
        for <linux-mm@kvack.org>; Mon, 07 Jul 2014 04:34:47 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAOMqctQV0Ce5Z4WF1osuvorZd_JQnoQSOkw1DOPSdPBh+qc=Kw@mail.gmail.com>
References: <CAJd=RBBbJMWox5yJaNzW_jUdDfKfWe-Y7d1riYdN6huQStxzcA@mail.gmail.com>
 <CAOMqctQyS2SFraqJpzE0sRFcihFpMHRhT+3QuZhxft=SUXYVDw@mail.gmail.com>
 <CAOMqctQ+XchmXk_Xno6ViAoZF-tHFPpDWoy7LVW1nooa+ywbmg@mail.gmail.com>
 <CAOMqctT2u7E0kwpm052B9pkNo4D=sYHO+Vk=P_TziUb5KvTMKA@mail.gmail.com>
 <20130917211317.GB6537@quack.suse.cz> <CAOMqctT5Wi_Y9ODAnoG-RQiO1oJ+yKR=LnF21swuupyLShL=+w@mail.gmail.com>
 <20130919101357.GA20140@quack.suse.cz> <CAOMqctQV0Ce5Z4WF1osuvorZd_JQnoQSOkw1DOPSdPBh+qc=Kw@mail.gmail.com>
From: Michal Suchanek <hramrach@gmail.com>
Date: Mon, 7 Jul 2014 13:34:07 +0200
Message-ID: <CAOMqctTAvp4WyaiUtysN-+WXFrHMG1pCRmGN=VZm5HkG2KQ36g@mail.gmail.com>
Subject: Re: doing lots of disk writes causes oom killer to kill processes
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Hillf Danton <dhillf@gmail.com>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>

On 9 October 2013 16:19, Michal Suchanek <hramrach@gmail.com> wrote:
> Hello,
>
> On 19 September 2013 12:13, Jan Kara <jack@suse.cz> wrote:
>> On Wed 18-09-13 16:56:08, Michal Suchanek wrote:
>>> On 17 September 2013 23:13, Jan Kara <jack@suse.cz> wrote:
>>> >   Hello,
>>>
>>> The default for dirty_ratio/dirty_background_ratio is 60/40. Setting
>>   Ah, that's not upstream default. Upstream has 20/10. In SLES we use 40/10
>> to better accomodate some workloads but 60/40 on 8 GB machines with
>> SATA drive really seems too much. That is going to give memory management a
>> headache.
>>
>> The problem is that a good SATA drive can do ~100 MB/s if we are
>> lucky and IO is sequential. Thus if you have 5 GB of dirty data to write,
>> it takes 50s at best to write it, with more random IO to image file it can
>> well take several minutes to write. That may cause some increased latency
>> when memory reclaim waits for writeback to clean some pages.
>>
>>> these to 5/2 gives about the same result as running the script that
>>> syncs every 5s. Setting to 30/10 gives larger data chunks and
>>> intermittent lockup before every chunk is written.
>>>
>>> It is quite possible to set kernel parameters that kill the kernel but
>>>
>>> 1) this is the default
>>   Not upstream one so you should raise this with Debian I guess. 60/40
>> looks way out of reasonable range for todays machines.
>>
>>> 2) the parameter is set in units that do not prevent the issue in
>>> general (% RAM vs #blocks)
>>   You can set the number of bytes instead of percentage -
>> /proc/sys/vm/dirty_bytes / dirty_background_bytes. It's just that proper
>> sizing depends on amount of memory, storage HW, workload. So it's more an
>> administrative task to set this tunable properly.
>>
>>> 3) WTH is the system doing? It's 4core 3GHz cpu so it can handle
>>> traversing a structure holding 800M data in the background. Something
>>> is seriously rotten somewhere.
>>   Likely processes are waiting in direct reclaim for IO to finish. But that
>> is just guessing. Try running attached script (forgot to attach it to
>> previous email). You will need systemtap and kernel debuginfo installed.
>> The script doesn't work with all versions of systemtap (as it is sadly a
>> moving target) so if it fails, tell me your version of systemtap and I'll
>> update the script accordingly.
>
> This was fixed for me by the patch posted earlier by Hillf Danton so I
> guess this answers what the system was (not) doing:
>
> --- a/mm/vmscan.c Wed Sep 18 08:44:08 2013
> +++ b/mm/vmscan.c Wed Sep 18 09:31:34 2013
> @@ -1543,8 +1543,11 @@ shrink_inactive_list(unsigned long nr_to
>   * implies that pages are cycling through the LRU faster than
>   * they are written so also forcibly stall.
>   */
> - if (nr_unqueued_dirty == nr_taken || nr_immediate)
> + if (nr_unqueued_dirty == nr_taken || nr_immediate) {
> + if (current_is_kswapd())
> + wakeup_flusher_threads(0, WB_REASON_TRY_TO_FREE_PAGES);
>   congestion_wait(BLK_RW_ASYNC, HZ/10);
> + }
>   }
>
>   /*
>

Hello,

Is this being addressed somehow?

It seems the 3.15 kernel still has this issue  .. unless it happens to
lock up for some other reason in similar situations.

Thanks

Michal

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
