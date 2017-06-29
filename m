Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 3EBD16B0292
	for <linux-mm@kvack.org>; Thu, 29 Jun 2017 03:16:24 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id t3so706728wme.9
        for <linux-mm@kvack.org>; Thu, 29 Jun 2017 00:16:24 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y71si446976wmc.123.2017.06.29.00.16.22
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 29 Jun 2017 00:16:22 -0700 (PDT)
Date: Thu, 29 Jun 2017 09:16:20 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [Bug 196157] New: 100+ times slower disk writes on
 4.x+/i386/16+RAM, compared to 3.x
Message-ID: <20170629071619.GB31603@dhcp22.suse.cz>
References: <bug-196157-27@https.bugzilla.kernel.org/>
 <20170622123736.1d80f1318eac41cd661b7757@linux-foundation.org>
 <20170623071324.GD5308@dhcp22.suse.cz>
 <3541d6c3-6c41-8210-ee94-fef313ecd83d@gmail.com>
 <20170623113837.GM5308@dhcp22.suse.cz>
 <a373c35d-7d83-973c-126e-a08c411115cb@gmail.com>
 <20170626054623.GC31972@dhcp22.suse.cz>
 <7b78db49-e0d8-9ace-bada-a48c9392a8ca@gmail.com>
 <20170626091254.GG11534@dhcp22.suse.cz>
 <5eff5b8f-51ab-9749-0da5-88c270f0df92@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5eff5b8f-51ab-9749-0da5-88c270f0df92@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alkis Georgopoulos <alkisg@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, bugzilla-daemon@bugzilla.kernel.org, Mel Gorman <mgorman@techsingularity.net>, Johannes Weiner <hannes@cmpxchg.org>

On Thu 29-06-17 09:14:55, Alkis Georgopoulos wrote:
> I've been working on a system with highmem_is_dirtyable=1 for a couple
> of hours.
> 
> While the disk benchmark showed no performance hit on intense disk
> activity, there are other serious problems that make this workaround
> unusable.
> 
> I.e. when there's intense disk activity, the mouse cursor moves with
> extreme lag, like 1-2 fps. Switching with alt+tab from e.g. thunderbird
> to pidgin needs 10 seconds. kswapd hits 100% cpu usage. Etc etc, the
> system becomes unusable until the disk activity settles down.
> I was testing via SSH so I hadn't noticed the extreme lag.
> 
> All those symptoms go away when resetting highmem_is_dirtyable=0.
> 
> So currently 32bit installations with 16 GB RAM have no option but to
> remove the extra RAM...

Or simply install 64b kernel. You can keep 32b userspace if you need
it but running 32b kernel will be always a fight.
 
> About ab8fabd46f81 ("mm: exclude reserved pages from dirtyable memory"),
> would it make sense for me to compile a kernel and test if everything
> works fine without it? I.e. if we see that this caused all those
> regressions, would it be revisited?

The patch makes a lot of sense in general. I do not think we will revert
it based on a configuration which is rare. We might come up with some
tweaks in the dirty memory throttling but that area is quite tricky
already. You can of course try to test without this commit applied (I
believe you would have to go and checkout ab8fabd46f81 and revert the
commit because a later revert sound more complicated to me. I might be
wrong here because I haven't tried that myself though).

> And an unrelated idea, is there any way to tell linux to use a limited
> amount of RAM for page cache, e.g. only 1 GB?

No.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
