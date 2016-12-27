Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f200.google.com (mail-wj0-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 14DED6B0038
	for <linux-mm@kvack.org>; Tue, 27 Dec 2016 14:33:17 -0500 (EST)
Received: by mail-wj0-f200.google.com with SMTP id dh1so23684662wjb.0
        for <linux-mm@kvack.org>; Tue, 27 Dec 2016 11:33:17 -0800 (PST)
Received: from celine.tisys.org (celine.tisys.org. [85.25.117.166])
        by mx.google.com with ESMTPS id rk19si51041163wjb.69.2016.12.27.11.33.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 27 Dec 2016 11:33:15 -0800 (PST)
Date: Tue, 27 Dec 2016 20:33:09 +0100
From: Nils Holland <nholland@tisys.org>
Subject: Re: [RFC PATCH] mm, memcg: fix (Re: OOM: Better, but still there on)
Message-ID: <20161227193308.GA17454@boerne.fritz.box>
References: <20161222101028.GA11105@ppc-nas.fritz.box>
 <20161222191719.GA19898@dhcp22.suse.cz>
 <20161222214611.GA3015@boerne.fritz.box>
 <20161223105157.GB23109@dhcp22.suse.cz>
 <20161223121851.GA27413@ppc-nas.fritz.box>
 <20161223125728.GE23109@dhcp22.suse.cz>
 <20161223144738.GB23117@dhcp22.suse.cz>
 <20161223222559.GA5568@teela.multi.box>
 <20161226124839.GB20715@dhcp22.suse.cz>
 <20161227155532.GI1308@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161227155532.GI1308@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Chris Mason <clm@fb.com>, David Sterba <dsterba@suse.cz>, linux-btrfs@vger.kernel.org

On Tue, Dec 27, 2016 at 04:55:33PM +0100, Michal Hocko wrote:
> Hi,
> could you try to run with the following patch on top of the previous
> one? I do not think it will make a large change in your workload but
> I think we need something like that so some testing under which is known
> to make a high lowmem pressure would be really appreciated. If you have
> more time to play with it then running with and without the patch with
> mm_vmscan_direct_reclaim_{start,end} tracepoints enabled could tell us
> whether it make any difference at all.

Of course, no problem!

First, about the events to trace: mm_vmscan_direct_reclaim_start
doesn't seem to exist, but mm_vmscan_direct_reclaim_begin does. I'm
sure that's what you meant and so I took that one instead.

Then I have to admit in both cases (once without the latest patch,
once with) very little trace data was actually produced. In the case
without the patch, the reclaim was started more often and reclaimed a
smaller number of pages each time, in the case with the patch it was
invoked less often, and with the last time it was invoked it reclaimed
a rather big number of pages. I have no clue, however, if that
happened "by chance" or if it was actually causes by the patch and
thus an expected change.

In both cases, my test case was: Reboot, setup logging, do "emerge
firefox" (which unpacks and builds the firefox sources), then, when
the emerge had come so far that the unpacking was done and the
building had started, switch to another console and untar the latest
kernel, libreoffice and (once more) firefox sources there. After that
had completed, I aborted the emerge build process and stopped tracing.

Here's the trace data captured without the latest patch applied:

khugepaged-22    [000] ....   566.123383: mm_vmscan_direct_reclaim_begin: order=9 may_writepage=1 gfp_flags=GFP_TRANSHUGE classzone_idx=3
khugepaged-22    [000] .N..   566.165520: mm_vmscan_direct_reclaim_end: nr_reclaimed=1100
khugepaged-22    [001] ....   587.515424: mm_vmscan_direct_reclaim_begin: order=9 may_writepage=1 gfp_flags=GFP_TRANSHUGE classzone_idx=3
khugepaged-22    [000] ....   587.596035: mm_vmscan_direct_reclaim_end: nr_reclaimed=1029
khugepaged-22    [001] ....   599.879536: mm_vmscan_direct_reclaim_begin: order=9 may_writepage=1 gfp_flags=GFP_TRANSHUGE classzone_idx=3
khugepaged-22    [000] ....   601.000812: mm_vmscan_direct_reclaim_end: nr_reclaimed=1100
khugepaged-22    [001] ....   601.228137: mm_vmscan_direct_reclaim_begin: order=9 may_writepage=1 gfp_flags=GFP_TRANSHUGE classzone_idx=3
khugepaged-22    [001] ....   601.309952: mm_vmscan_direct_reclaim_end: nr_reclaimed=1081
khugepaged-22    [001] ....   694.935267: mm_vmscan_direct_reclaim_begin: order=9 may_writepage=1 gfp_flags=GFP_TRANSHUGE classzone_idx=3
khugepaged-22    [001] .N..   695.081943: mm_vmscan_direct_reclaim_end: nr_reclaimed=1071
khugepaged-22    [001] ....   701.370707: mm_vmscan_direct_reclaim_begin: order=9 may_writepage=1 gfp_flags=GFP_TRANSHUGE classzone_idx=3
khugepaged-22    [001] ....   701.372798: mm_vmscan_direct_reclaim_end: nr_reclaimed=1089
khugepaged-22    [001] ....   764.752036: mm_vmscan_direct_reclaim_begin: order=9 may_writepage=1 gfp_flags=GFP_TRANSHUGE classzone_idx=3
khugepaged-22    [000] ....   771.047905: mm_vmscan_direct_reclaim_end: nr_reclaimed=1039
khugepaged-22    [000] ....   781.760515: mm_vmscan_direct_reclaim_begin: order=9 may_writepage=1 gfp_flags=GFP_TRANSHUGE classzone_idx=3
khugepaged-22    [001] ....   781.826543: mm_vmscan_direct_reclaim_end: nr_reclaimed=1040
khugepaged-22    [001] ....   782.595575: mm_vmscan_direct_reclaim_begin: order=9 may_writepage=1 gfp_flags=GFP_TRANSHUGE classzone_idx=3
khugepaged-22    [000] ....   782.638591: mm_vmscan_direct_reclaim_end: nr_reclaimed=1040
khugepaged-22    [001] ....   782.930455: mm_vmscan_direct_reclaim_begin: order=9 may_writepage=1 gfp_flags=GFP_TRANSHUGE classzone_idx=3
khugepaged-22    [001] ....   782.993608: mm_vmscan_direct_reclaim_end: nr_reclaimed=1040
khugepaged-22    [001] ....   783.330378: mm_vmscan_direct_reclaim_begin: order=9 may_writepage=1 gfp_flags=GFP_TRANSHUGE classzone_idx=3
khugepaged-22    [001] ....   783.369653: mm_vmscan_direct_reclaim_end: nr_reclaimed=1040

And this is the same with the patch applied:

khugepaged-22    [001] ....   523.599997: mm_vmscan_direct_reclaim_begin: order=9 may_writepage=1 gfp_flags=GFP_TRANSHUGE classzone_idx=3
khugepaged-22    [001] ....   523.683110: mm_vmscan_direct_reclaim_end: nr_reclaimed=1092
khugepaged-22    [001] ....   535.345477: mm_vmscan_direct_reclaim_begin: order=9 may_writepage=1 gfp_flags=GFP_TRANSHUGE classzone_idx=3
khugepaged-22    [001] ....   535.401189: mm_vmscan_direct_reclaim_end: nr_reclaimed=1078
khugepaged-22    [000] ....   692.876716: mm_vmscan_direct_reclaim_begin: order=9 may_writepage=1 gfp_flags=GFP_TRANSHUGE classzone_idx=3
khugepaged-22    [001] ....   703.312399: mm_vmscan_direct_reclaim_end: nr_reclaimed=197759

If my test case and thus the results don't sound good, I could of
course try some other test cases ... like capturing for a longer
period of time or trying to produce more memory pressure by running
more processes at the same time, or something like that.

Besides that I can say that the patch hasn't produced any warnings or
other issues so far, so at first glance, it doesn't seem to hurt
anything.

Greetings
Nils

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
