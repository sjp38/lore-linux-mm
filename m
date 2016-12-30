Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f198.google.com (mail-wj0-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id BBEAF6B0038
	for <linux-mm@kvack.org>; Fri, 30 Dec 2016 05:19:30 -0500 (EST)
Received: by mail-wj0-f198.google.com with SMTP id hb5so97923890wjc.2
        for <linux-mm@kvack.org>; Fri, 30 Dec 2016 02:19:30 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 4si36719634wjg.34.2016.12.30.02.19.29
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 30 Dec 2016 02:19:29 -0800 (PST)
Date: Fri, 30 Dec 2016 10:19:26 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [RFC PATCH] mm, memcg: fix (Re: OOM: Better, but still there on)
Message-ID: <20161230101926.jjjw76negqcvyaim@suse.de>
References: <20161221073658.GC16502@dhcp22.suse.cz>
 <20161222101028.GA11105@ppc-nas.fritz.box>
 <20161222191719.GA19898@dhcp22.suse.cz>
 <20161222214611.GA3015@boerne.fritz.box>
 <20161223105157.GB23109@dhcp22.suse.cz>
 <20161223121851.GA27413@ppc-nas.fritz.box>
 <20161223125728.GE23109@dhcp22.suse.cz>
 <20161223144738.GB23117@dhcp22.suse.cz>
 <20161223222559.GA5568@teela.multi.box>
 <20161226124839.GB20715@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20161226124839.GB20715@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Nils Holland <nholland@tisys.org>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Chris Mason <clm@fb.com>, David Sterba <dsterba@suse.cz>, linux-btrfs@vger.kernel.org

On Mon, Dec 26, 2016 at 01:48:40PM +0100, Michal Hocko wrote:
> On Fri 23-12-16 23:26:00, Nils Holland wrote:
> > On Fri, Dec 23, 2016 at 03:47:39PM +0100, Michal Hocko wrote:
> > > 
> > > Nils, even though this is still highly experimental, could you give it a
> > > try please?
> > 
> > Yes, no problem! So I kept the very first patch you sent but had to
> > revert the latest version of the debugging patch (the one in
> > which you added the "mm_vmscan_inactive_list_is_low" event) because
> > otherwise the patch you just sent wouldn't apply. Then I rebooted with
> > memory cgroups enabled again, and the first thing that strikes the eye
> > is that I get this during boot:
> > 
> > [    1.568174] ------------[ cut here ]------------
> > [    1.568327] WARNING: CPU: 0 PID: 1 at mm/memcontrol.c:1032 mem_cgroup_update_lru_size+0x118/0x130
> > [    1.568543] mem_cgroup_update_lru_size(f4406400, 2, 1): lru_size 0 but not empty
> 
> Ohh, I can see what is wrong! a) there is a bug in the accounting in
> my patch (I double account) and b) the detection for the empty list
> cannot work after my change because per node zone will not match per
> zone statistics. The updated patch is below. So I hope my brain already
> works after it's been mostly off last few days...
> ---
> From 397adf46917b2d9493180354a7b0182aee280a8b Mon Sep 17 00:00:00 2001
> From: Michal Hocko <mhocko@suse.com>
> Date: Fri, 23 Dec 2016 15:11:54 +0100
> Subject: [PATCH] mm, memcg: fix the active list aging for lowmem requests when
>  memcg is enabled
> 
> Nils Holland has reported unexpected OOM killer invocations with 32b
> kernel starting with 4.8 kernels
> 

I think it's unfortunate that per-zone stats are reintroduced to the
memcg structure. I can't help but think that it would have also worked
to always rotate a small number of pages if !inactive_list_is_low and
reclaiming for memcg even if it distorted page aging. However, given
that such an approach would be less robust and this has been heavily
tested;

Acked-by: Mel Gorman <mgorman@suse.de>

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
