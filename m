Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 53DF66B02EA
	for <linux-mm@kvack.org>; Tue, 28 Nov 2017 05:33:04 -0500 (EST)
Received: by mail-io0-f197.google.com with SMTP id 186so250784ioo.17
        for <linux-mm@kvack.org>; Tue, 28 Nov 2017 02:33:04 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d23sor14156176ioj.250.2017.11.28.02.33.03
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 28 Nov 2017 02:33:03 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20171128102559.GJ5977@quack2.suse.cz>
References: <1506592464-30962-1-git-send-email-laoar.shao@gmail.com>
 <cdfce9d0-9542-3fd1-098c-492d8d9efc11@I-love.SAKURA.ne.jp>
 <20171127091939.tahb77nznytcxw55@dhcp22.suse.cz> <CALOAHbDNbFs51mW0kUFXcqqyJy+ydpHPaRbvquPVrPTY5HGeRg@mail.gmail.com>
 <20171128102559.GJ5977@quack2.suse.cz>
From: Yafang Shao <laoar.shao@gmail.com>
Date: Tue, 28 Nov 2017 18:33:02 +0800
Message-ID: <CALOAHbBRiv48N_puVW18QX3MHoDU3CvMaa7BwxONAKWSOGWJcg@mail.gmail.com>
Subject: Re: [PATCH] Revert "mm/page-writeback.c: print a warning if the vm
 dirtiness settings are illogical" (was: Re: [PATCH] mm: print a warning once
 the vm dirtiness settings is illogical)
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Michal Hocko <mhocko@suse.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>

2017-11-28 18:25 GMT+08:00 Jan Kara <jack@suse.cz>:
> Hi Yafang,
>
> On Tue 28-11-17 11:11:40, Yafang Shao wrote:
>> What about bellow change ?
>> It makes the function  domain_dirty_limits() more clear.
>> And the result will have a higher precision.
>
> Frankly, I don't find this any better and you've just lost the additional
> precision of ratios computed in the "if (gdtc)" branch the multiplication by
> PAGE_SIZE got us.
>

What about bellow change? It won't be lost any more, becasue
bytes and bg_bytes are both PAGE_SIZE aligned.

-       if (bytes)
-           ratio = min(DIV_ROUND_UP(bytes, global_avail),
-                   PAGE_SIZE);
-       if (bg_bytes)
-           bg_ratio = min(DIV_ROUND_UP(bg_bytes, global_avail),
-                      PAGE_SIZE);
+       if (bytes) {
+           pages = DIV_ROUND_UP(bytes, PAGE_SIZE);
+           ratio = DIV_ROUND_UP(pages * 100, global_avail);
+
+       }
+
+       if (bg_bytes) {
+           pages = DIV_ROUND_UP(bg_bytes, PAGE_SIZE);
+           bg_ratio = DIV_ROUND_UP(pages * 100, global_avail);
+       }


>
>
>> diff --git a/mm/page-writeback.c b/mm/page-writeback.c
>> index 8a15511..2b5e507 100644
>> --- a/mm/page-writeback.c
>> +++ b/mm/page-writeback.c
>> @@ -397,8 +397,8 @@ static void domain_dirty_limits(struct
>> dirty_throttle_control *dtc)
>>     unsigned long bytes = vm_dirty_bytes;
>>     unsigned long bg_bytes = dirty_background_bytes;
>>     /* convert ratios to per-PAGE_SIZE for higher precision */
>> -   unsigned long ratio = (vm_dirty_ratio * PAGE_SIZE) / 100;
>> -   unsigned long bg_ratio = (dirty_background_ratio * PAGE_SIZE) / 100;
>> +   unsigned long ratio = vm_dirty_ratio;
>> +   unsigned long bg_ratio = dirty_background_ratio;
>>     unsigned long thresh;
>>     unsigned long bg_thresh;
>>     struct task_struct *tsk;
>> @@ -416,28 +416,33 @@ static void domain_dirty_limits(struct
>> dirty_throttle_control *dtc)
>>          */
>>         if (bytes)
>>             ratio = min(DIV_ROUND_UP(bytes, global_avail),
>> -                   PAGE_SIZE);
>> +                   100);
>>         if (bg_bytes)
>>             bg_ratio = min(DIV_ROUND_UP(bg_bytes, global_avail),
>> -                      PAGE_SIZE);
>> +                      99);   /* bg_ratio should less than ratio */
>>         bytes = bg_bytes = 0;
>>     }
>>
>> +   /* bytes and bg_bytes must be PAGE_SIZE aligned */
>>     if (bytes)
>> -       thresh = DIV_ROUND_UP(bytes, PAGE_SIZE);
>> +       thresh = DIV_ROUND_UP(bytes, PAGE_SIZE) * 100;
>>     else
>> -       thresh = (ratio * available_memory) / PAGE_SIZE;
>> +       thresh = ratio * available_memory;
>>
>>     if (bg_bytes)
>> -       bg_thresh = DIV_ROUND_UP(bg_bytes, PAGE_SIZE);
>> +       bg_thresh = DIV_ROUND_UP(bg_bytes, PAGE_SIZE) * 100;
>>     else
>> -       bg_thresh = (bg_ratio * available_memory) / PAGE_SIZE;
>> +       bg_thresh = bg_ratio * available_memory;
>>
>>     if (unlikely(bg_thresh >= thresh)) {
>>         pr_warn("vm direct limit must be set greater than background limit.\n");
>>         bg_thresh = thresh / 2;
>>     }
>>
>> +   /* ensure bg_thresh and thresh never be 0 */
>> +   bg_thresh = DIV_ROUND_UP(bg_thresh, 100);
>> +   thresh = DIV_ROUND_UP(thresh, 100);
>> +
>>     tsk = current;
>>     if (tsk->flags & PF_LESS_THROTTLE || rt_task(tsk)) {
>>
>> 2017-11-27 17:19 GMT+08:00 Michal Hocko <mhocko@suse.com>:
>> > Andrew,
>> > could you simply send this to Linus. If we _really_ need something to
>> > prevent misconfiguration, which I doubt to be honest, then it should be
>> > thought through much better.
>> > ---
>> > From 4ef6b1cbf98ea5dae155ab3303c4ae1d93411b79 Mon Sep 17 00:00:00 2001
>> > From: Michal Hocko <mhocko@suse.com>
>> > Date: Mon, 27 Nov 2017 10:12:15 +0100
>> > Subject: [PATCH] Revert "mm/page-writeback.c: print a warning if the vm
>> >  dirtiness settings are illogical"
>> >
>> > This reverts commit 0f6d24f878568fac579a1962d0bf7cb9f01e0ceb because
>> > it causes false positive warnings during OOM situations as noticed by
>> > Tetsuo Handa:
>> > [  621.814512] Node 0 active_anon:3525940kB inactive_anon:8372kB active_file:216kB inactive_file:1872kB unevictable:0kB isolated(anon):0kB isolated(file):0kB mapped:2504kB dirty:52kB writeback:0kB shmem:8660kB s
>> > hmem_thp: 0kB shmem_pmdmapped: 0kB anon_thp: 636928kB writeback_tmp:0kB unstable:0kB all_unreclaimable? yes
>> > [  621.821534] Node 0 DMA free:14848kB min:284kB low:352kB high:420kB active_anon:992kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB writepending:0kB present:15988kB managed:15904kB mlocke
>> > d:0kB kernel_stack:0kB pagetables:24kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB
>> > [  621.829035] lowmem_reserve[]: 0 2687 3645 3645
>> > [  621.831655] Node 0 DMA32 free:53004kB min:49608kB low:62008kB high:74408kB active_anon:2712648kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB writepending:0kB present:3129216kB managed:
>> > 2773132kB mlocked:0kB kernel_stack:96kB pagetables:5096kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB
>> > [  621.839945] lowmem_reserve[]: 0 0 958 958
>> > [  621.842811] Node 0 Normal free:17140kB min:17684kB low:22104kB high:26524kB active_anon:812300kB inactive_anon:8372kB active_file:1228kB inactive_file:1868kB unevictable:0kB writepending:52kB present:1048576k
>> > B managed:981224kB mlocked:0kB kernel_stack:3520kB pagetables:8552kB bounce:0kB free_pcp:120kB local_pcp:120kB free_cma:0kB
>> > [  621.852473] lowmem_reserve[]: 0 0 0 0
>> > [...]
>> > [  621.891477] Out of memory: Kill process 8459 (a.out) score 999 or sacrifice child
>> > [  621.894363] Killed process 8459 (a.out) total-vm:4180kB, anon-rss:88kB, file-rss:0kB, shmem-rss:0kB
>> > [  621.897172] oom_reaper: reaped process 8459 (a.out), now anon-rss:0kB, file-rss:0kB, shmem-rss:0kB
>> > [  622.424664] vm direct limit must be set greater than background limit.
>> >
>> > The problem is that both thresh and bg_thresh will be 0 if available_memory
>> >  is less than 4 pages when evaluating global_dirtyable_memory. While
>> > this might be worked around the whole point of the warning is dubious at
>> > best. We do rely on admins to do sensible things when changing tunable
>> > knobs. Dirty memory writeback knobs are not any special in that regards
>> > so revert the warning rather than adding more hacks to work this around.
>> >
>> > Rerported-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
>> > Debugged-by: Yafang Shao <laoar.shao@gmail.com>
>> > Fixes: 0f6d24f87856 ("mm/page-writeback.c: print a warning if the vm dirtiness settings are illogical")
>> > Signed-off-by: Michal Hocko <mhocko@suse.com>
>> > ---
>> >  Documentation/sysctl/vm.txt | 7 -------
>> >  mm/page-writeback.c         | 5 +----
>> >  2 files changed, 1 insertion(+), 11 deletions(-)
>> >
>> > diff --git a/Documentation/sysctl/vm.txt b/Documentation/sysctl/vm.txt
>> > index b920423f88cb..5025ff9307e6 100644
>> > --- a/Documentation/sysctl/vm.txt
>> > +++ b/Documentation/sysctl/vm.txt
>> > @@ -158,10 +158,6 @@ Note: the minimum value allowed for dirty_bytes is two pages (in bytes); any
>> >  value lower than this limit will be ignored and the old configuration will be
>> >  retained.
>> >
>> > -Note: the value of dirty_bytes also must be set greater than
>> > -dirty_background_bytes or the amount of memory corresponding to
>> > -dirty_background_ratio.
>> > -
>> >  ==============================================================
>> >
>> >  dirty_expire_centisecs
>> > @@ -181,9 +177,6 @@ generating disk writes will itself start writing out dirty data.
>> >
>> >  The total available memory is not equal to total system memory.
>> >
>> > -Note: dirty_ratio must be set greater than dirty_background_ratio or
>> > -ratio corresponding to dirty_background_bytes.
>> > -
>> >  ==============================================================
>> >
>> >  dirty_writeback_centisecs
>> > diff --git a/mm/page-writeback.c b/mm/page-writeback.c
>> > index e7095030aa1f..586f31261c83 100644
>> > --- a/mm/page-writeback.c
>> > +++ b/mm/page-writeback.c
>> > @@ -433,11 +433,8 @@ static void domain_dirty_limits(struct dirty_throttle_control *dtc)
>> >         else
>> >                 bg_thresh = (bg_ratio * available_memory) / PAGE_SIZE;
>> >
>> > -       if (unlikely(bg_thresh >= thresh)) {
>> > -               pr_warn("vm direct limit must be set greater than background limit.\n");
>> > +       if (bg_thresh >= thresh)
>> >                 bg_thresh = thresh / 2;
>> > -       }
>> > -
>> >         tsk = current;
>> >         if (tsk->flags & PF_LESS_THROTTLE || rt_task(tsk)) {
>> >                 bg_thresh += bg_thresh / 4 + global_wb_domain.dirty_limit / 32;
>> > --
>> > 2.15.0
>> >
>> > --
>> > Michal Hocko
>> > SUSE Labs
> --
> Jan Kara <jack@suse.com>
> SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
