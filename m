Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f200.google.com (mail-wj0-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id D0C646B025E
	for <linux-mm@kvack.org>; Tue, 27 Dec 2016 06:23:20 -0500 (EST)
Received: by mail-wj0-f200.google.com with SMTP id dh1so21960322wjb.0
        for <linux-mm@kvack.org>; Tue, 27 Dec 2016 03:23:20 -0800 (PST)
Received: from celine.tisys.org (celine.tisys.org. [85.25.117.166])
        by mx.google.com with ESMTPS id dh9si49620884wjc.125.2016.12.27.03.23.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 27 Dec 2016 03:23:19 -0800 (PST)
Date: Tue, 27 Dec 2016 12:23:13 +0100
From: Nils Holland <nholland@tisys.org>
Subject: Re: [RFC PATCH] mm, memcg: fix (Re: OOM: Better, but still there on)
Message-ID: <20161227112313.GA23101@boerne.fritz.box>
References: <20161222191719.GA19898@dhcp22.suse.cz>
 <20161222214611.GA3015@boerne.fritz.box>
 <20161223105157.GB23109@dhcp22.suse.cz>
 <20161223121851.GA27413@ppc-nas.fritz.box>
 <20161223125728.GE23109@dhcp22.suse.cz>
 <20161223144738.GB23117@dhcp22.suse.cz>
 <20161223222559.GA5568@teela.multi.box>
 <20161226124839.GB20715@dhcp22.suse.cz>
 <20161226185701.GA17030@boerne.fritz.box>
 <20161227080837.GA1308@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161227080837.GA1308@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Chris Mason <clm@fb.com>, David Sterba <dsterba@suse.cz>, linux-btrfs@vger.kernel.org

On Tue, Dec 27, 2016 at 09:08:38AM +0100, Michal Hocko wrote:
> On Mon 26-12-16 19:57:03, Nils Holland wrote:
> > On Mon, Dec 26, 2016 at 01:48:40PM +0100, Michal Hocko wrote:
> > > On Fri 23-12-16 23:26:00, Nils Holland wrote:
> > > > On Fri, Dec 23, 2016 at 03:47:39PM +0100, Michal Hocko wrote:
> > > > > 
> > > > > Nils, even though this is still highly experimental, could you give it a
> > > > > try please?
> > > > 
> > > > Yes, no problem! So I kept the very first patch you sent but had to
> > > > revert the latest version of the debugging patch (the one in
> > > > which you added the "mm_vmscan_inactive_list_is_low" event) because
> > > > otherwise the patch you just sent wouldn't apply. Then I rebooted with
> > > > memory cgroups enabled again, and the first thing that strikes the eye
> > > > is that I get this during boot:
> > > > 
> > > > [    1.568174] ------------[ cut here ]------------
> > > > [    1.568327] WARNING: CPU: 0 PID: 1 at mm/memcontrol.c:1032 mem_cgroup_update_lru_size+0x118/0x130
> > > > [    1.568543] mem_cgroup_update_lru_size(f4406400, 2, 1): lru_size 0 but not empty
> > > 
> > > Ohh, I can see what is wrong! a) there is a bug in the accounting in
> > > my patch (I double account) and b) the detection for the empty list
> > > cannot work after my change because per node zone will not match per
> > > zone statistics. The updated patch is below. So I hope my brain already
> > > works after it's been mostly off last few days...
> > 
> > I tried the updated patch, and I can confirm that the warning during
> > boot is gone. Also, I've tried my ordinary procedure to reproduce my
> > testcase, and I can say that a kernel with this new patch also works
> > fine and doesn't produce OOMs or similar issues.
> > 
> > I had the previous version of the patch in use on a machine non-stop
> > for the last few days during normal day-to-day workloads and didn't
> > notice any issues. Now I'll keep a machine running during the next few
> > days with this patch, and in case I notice something that doesn't look
> > normal, I'll of course report back!
> 
> Thanks for your testing! Can I add your
> Tested-by: Nils Holland <nholland@tisys.org>

Yes, I think so! The patch has now been running for 16 hours on my two
machines, and that's an uptime that was hard to achieve since 4.8 for
me. ;-) So my tests clearly suggest that the patch is good! :-)

Greetings
Nils

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
