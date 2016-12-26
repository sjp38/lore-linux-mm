Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 772B66B0038
	for <linux-mm@kvack.org>; Mon, 26 Dec 2016 07:48:45 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id m203so50306323wma.2
        for <linux-mm@kvack.org>; Mon, 26 Dec 2016 04:48:45 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id sd16si45897839wjb.290.2016.12.26.04.48.43
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 26 Dec 2016 04:48:43 -0800 (PST)
Date: Mon, 26 Dec 2016 13:48:40 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH] mm, memcg: fix (Re: OOM: Better, but still there on)
Message-ID: <20161226124839.GB20715@dhcp22.suse.cz>
References: <20161220020829.GA5449@boerne.fritz.box>
 <20161221073658.GC16502@dhcp22.suse.cz>
 <20161222101028.GA11105@ppc-nas.fritz.box>
 <20161222191719.GA19898@dhcp22.suse.cz>
 <20161222214611.GA3015@boerne.fritz.box>
 <20161223105157.GB23109@dhcp22.suse.cz>
 <20161223121851.GA27413@ppc-nas.fritz.box>
 <20161223125728.GE23109@dhcp22.suse.cz>
 <20161223144738.GB23117@dhcp22.suse.cz>
 <20161223222559.GA5568@teela.multi.box>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161223222559.GA5568@teela.multi.box>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nils Holland <nholland@tisys.org>
Cc: Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Chris Mason <clm@fb.com>, David Sterba <dsterba@suse.cz>, linux-btrfs@vger.kernel.org

On Fri 23-12-16 23:26:00, Nils Holland wrote:
> On Fri, Dec 23, 2016 at 03:47:39PM +0100, Michal Hocko wrote:
> > 
> > Nils, even though this is still highly experimental, could you give it a
> > try please?
> 
> Yes, no problem! So I kept the very first patch you sent but had to
> revert the latest version of the debugging patch (the one in
> which you added the "mm_vmscan_inactive_list_is_low" event) because
> otherwise the patch you just sent wouldn't apply. Then I rebooted with
> memory cgroups enabled again, and the first thing that strikes the eye
> is that I get this during boot:
> 
> [    1.568174] ------------[ cut here ]------------
> [    1.568327] WARNING: CPU: 0 PID: 1 at mm/memcontrol.c:1032 mem_cgroup_update_lru_size+0x118/0x130
> [    1.568543] mem_cgroup_update_lru_size(f4406400, 2, 1): lru_size 0 but not empty

Ohh, I can see what is wrong! a) there is a bug in the accounting in
my patch (I double account) and b) the detection for the empty list
cannot work after my change because per node zone will not match per
zone statistics. The updated patch is below. So I hope my brain already
works after it's been mostly off last few days...
---
