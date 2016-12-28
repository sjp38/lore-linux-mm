Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 0931A6B0069
	for <linux-mm@kvack.org>; Wed, 28 Dec 2016 03:58:04 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id l2so31783358wml.5
        for <linux-mm@kvack.org>; Wed, 28 Dec 2016 00:58:03 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ed5si53090024wjb.111.2016.12.28.00.58.02
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 28 Dec 2016 00:58:02 -0800 (PST)
Date: Wed, 28 Dec 2016 09:57:59 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH] mm, memcg: fix (Re: OOM: Better, but still there on)
Message-ID: <20161228085759.GD11470@dhcp22.suse.cz>
References: <20161222191719.GA19898@dhcp22.suse.cz>
 <20161222214611.GA3015@boerne.fritz.box>
 <20161223105157.GB23109@dhcp22.suse.cz>
 <20161223121851.GA27413@ppc-nas.fritz.box>
 <20161223125728.GE23109@dhcp22.suse.cz>
 <20161223144738.GB23117@dhcp22.suse.cz>
 <20161223222559.GA5568@teela.multi.box>
 <20161226124839.GB20715@dhcp22.suse.cz>
 <20161227155532.GI1308@dhcp22.suse.cz>
 <20161227193308.GA17454@boerne.fritz.box>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161227193308.GA17454@boerne.fritz.box>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nils Holland <nholland@tisys.org>
Cc: Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Chris Mason <clm@fb.com>, David Sterba <dsterba@suse.cz>, linux-btrfs@vger.kernel.org

On Tue 27-12-16 20:33:09, Nils Holland wrote:
> On Tue, Dec 27, 2016 at 04:55:33PM +0100, Michal Hocko wrote:
> > Hi,
> > could you try to run with the following patch on top of the previous
> > one? I do not think it will make a large change in your workload but
> > I think we need something like that so some testing under which is known
> > to make a high lowmem pressure would be really appreciated. If you have
> > more time to play with it then running with and without the patch with
> > mm_vmscan_direct_reclaim_{start,end} tracepoints enabled could tell us
> > whether it make any difference at all.
> 
> Of course, no problem!
> 
> First, about the events to trace: mm_vmscan_direct_reclaim_start
> doesn't seem to exist, but mm_vmscan_direct_reclaim_begin does. I'm
> sure that's what you meant and so I took that one instead.

yes, sorry about the confusion

> Then I have to admit in both cases (once without the latest patch,
> once with) very little trace data was actually produced. In the case
> without the patch, the reclaim was started more often and reclaimed a
> smaller number of pages each time, in the case with the patch it was
> invoked less often, and with the last time it was invoked it reclaimed
> a rather big number of pages. I have no clue, however, if that
> happened "by chance" or if it was actually causes by the patch and
> thus an expected change.

yes that seems to be a variation of the workload I would say because if
anything the patch should reduce the number of scanned pages.

> In both cases, my test case was: Reboot, setup logging, do "emerge
> firefox" (which unpacks and builds the firefox sources), then, when
> the emerge had come so far that the unpacking was done and the
> building had started, switch to another console and untar the latest
> kernel, libreoffice and (once more) firefox sources there. After that
> had completed, I aborted the emerge build process and stopped tracing.
> 
> Here's the trace data captured without the latest patch applied:
> 
> khugepaged-22    [000] ....   566.123383: mm_vmscan_direct_reclaim_begin: order=9 may_writepage=1 gfp_flags=GFP_TRANSHUGE classzone_idx=3
> khugepaged-22    [000] .N..   566.165520: mm_vmscan_direct_reclaim_end: nr_reclaimed=1100
> khugepaged-22    [001] ....   587.515424: mm_vmscan_direct_reclaim_begin: order=9 may_writepage=1 gfp_flags=GFP_TRANSHUGE classzone_idx=3
> khugepaged-22    [000] ....   587.596035: mm_vmscan_direct_reclaim_end: nr_reclaimed=1029
> khugepaged-22    [001] ....   599.879536: mm_vmscan_direct_reclaim_begin: order=9 may_writepage=1 gfp_flags=GFP_TRANSHUGE classzone_idx=3
> khugepaged-22    [000] ....   601.000812: mm_vmscan_direct_reclaim_end: nr_reclaimed=1100
> khugepaged-22    [001] ....   601.228137: mm_vmscan_direct_reclaim_begin: order=9 may_writepage=1 gfp_flags=GFP_TRANSHUGE classzone_idx=3
> khugepaged-22    [001] ....   601.309952: mm_vmscan_direct_reclaim_end: nr_reclaimed=1081
> khugepaged-22    [001] ....   694.935267: mm_vmscan_direct_reclaim_begin: order=9 may_writepage=1 gfp_flags=GFP_TRANSHUGE classzone_idx=3
> khugepaged-22    [001] .N..   695.081943: mm_vmscan_direct_reclaim_end: nr_reclaimed=1071
> khugepaged-22    [001] ....   701.370707: mm_vmscan_direct_reclaim_begin: order=9 may_writepage=1 gfp_flags=GFP_TRANSHUGE classzone_idx=3
> khugepaged-22    [001] ....   701.372798: mm_vmscan_direct_reclaim_end: nr_reclaimed=1089
> khugepaged-22    [001] ....   764.752036: mm_vmscan_direct_reclaim_begin: order=9 may_writepage=1 gfp_flags=GFP_TRANSHUGE classzone_idx=3
> khugepaged-22    [000] ....   771.047905: mm_vmscan_direct_reclaim_end: nr_reclaimed=1039
> khugepaged-22    [000] ....   781.760515: mm_vmscan_direct_reclaim_begin: order=9 may_writepage=1 gfp_flags=GFP_TRANSHUGE classzone_idx=3
> khugepaged-22    [001] ....   781.826543: mm_vmscan_direct_reclaim_end: nr_reclaimed=1040
> khugepaged-22    [001] ....   782.595575: mm_vmscan_direct_reclaim_begin: order=9 may_writepage=1 gfp_flags=GFP_TRANSHUGE classzone_idx=3
> khugepaged-22    [000] ....   782.638591: mm_vmscan_direct_reclaim_end: nr_reclaimed=1040
> khugepaged-22    [001] ....   782.930455: mm_vmscan_direct_reclaim_begin: order=9 may_writepage=1 gfp_flags=GFP_TRANSHUGE classzone_idx=3
> khugepaged-22    [001] ....   782.993608: mm_vmscan_direct_reclaim_end: nr_reclaimed=1040
> khugepaged-22    [001] ....   783.330378: mm_vmscan_direct_reclaim_begin: order=9 may_writepage=1 gfp_flags=GFP_TRANSHUGE classzone_idx=3
> khugepaged-22    [001] ....   783.369653: mm_vmscan_direct_reclaim_end: nr_reclaimed=1040
> 
> And this is the same with the patch applied:
> 
> khugepaged-22    [001] ....   523.599997: mm_vmscan_direct_reclaim_begin: order=9 may_writepage=1 gfp_flags=GFP_TRANSHUGE classzone_idx=3
> khugepaged-22    [001] ....   523.683110: mm_vmscan_direct_reclaim_end: nr_reclaimed=1092
> khugepaged-22    [001] ....   535.345477: mm_vmscan_direct_reclaim_begin: order=9 may_writepage=1 gfp_flags=GFP_TRANSHUGE classzone_idx=3
> khugepaged-22    [001] ....   535.401189: mm_vmscan_direct_reclaim_end: nr_reclaimed=1078
> khugepaged-22    [000] ....   692.876716: mm_vmscan_direct_reclaim_begin: order=9 may_writepage=1 gfp_flags=GFP_TRANSHUGE classzone_idx=3
> khugepaged-22    [001] ....   703.312399: mm_vmscan_direct_reclaim_end: nr_reclaimed=197759

In these cases there is no real difference because this is not the
lowmem pressure because those requests can go to the highmem zone.

> If my test case and thus the results don't sound good, I could of
> course try some other test cases ... like capturing for a longer
> period of time or trying to produce more memory pressure by running
> more processes at the same time, or something like that.

yes, a stronger memory pressure would be needed. I suspect that your
original issues was more about active list aging than a really strong
memory pressure. So it might be possible that your workload will not
notice. If you can collect those two tracepoints over a longer time it
can still tell us something but I do not want you to burn a lot of time
on this. The main issue seems to be fixed and the follow up fix can wait
for a throughout review after both Mel and Johannes are back from
holiday.

> Besides that I can say that the patch hasn't produced any warnings or
> other issues so far, so at first glance, it doesn't seem to hurt
> anything.

Thanks!
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
