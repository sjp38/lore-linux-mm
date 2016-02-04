Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f50.google.com (mail-wm0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id CE03044044D
	for <linux-mm@kvack.org>; Thu,  4 Feb 2016 09:24:03 -0500 (EST)
Received: by mail-wm0-f50.google.com with SMTP id g62so6815901wme.0
        for <linux-mm@kvack.org>; Thu, 04 Feb 2016 06:24:03 -0800 (PST)
Received: from mail-wm0-f67.google.com (mail-wm0-f67.google.com. [74.125.82.67])
        by mx.google.com with ESMTPS id e130si20642291wmd.64.2016.02.04.06.24.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 Feb 2016 06:24:02 -0800 (PST)
Received: by mail-wm0-f67.google.com with SMTP id p63so12422065wmp.1
        for <linux-mm@kvack.org>; Thu, 04 Feb 2016 06:24:02 -0800 (PST)
Date: Thu, 4 Feb 2016 15:24:00 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 0/3] OOM detection rework v4
Message-ID: <20160204142400.GC14425@dhcp22.suse.cz>
References: <1450203586-10959-1-git-send-email-mhocko@kernel.org>
 <20160203132718.GI6757@dhcp22.suse.cz>
 <alpine.DEB.2.10.1602031457120.10331@chino.kir.corp.google.com>
 <20160204125700.GA14425@dhcp22.suse.cz>
 <201602042210.BCG18704.HOMFFJOStQFOLV@I-love.SAKURA.ne.jp>
 <20160204133905.GB14425@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160204133905.GB14425@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: rientjes@google.com, akpm@linux-foundation.org, torvalds@linux-foundation.org, hannes@cmpxchg.org, mgorman@suse.de, hillf.zj@alibaba-inc.com, kamezawa.hiroyu@jp.fujitsu.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu 04-02-16 14:39:05, Michal Hocko wrote:
> On Thu 04-02-16 22:10:54, Tetsuo Handa wrote:
> > Michal Hocko wrote:
> > > I am not sure we can fix these pathological loads where we hit the
> > > higher order depletion and there is a chance that one of the thousands
> > > tasks terminates in an unpredictable way which happens to race with the
> > > OOM killer.
> > 
> > When I hit this problem on Dec 24th, I didn't run thousands of tasks.
> > I think there were less than one hundred tasks in the system and only
> > a few tasks were running. Not a pathological load at all.
> 
> But as the OOM report clearly stated there were no > order-1 pages
> available in that particular case. And that happened after the direct
> reclaim and compaction were already invoked.
> 
> As I've mentioned in the referenced email, we can try to do multiple
> retries e.g. do not give up on the higher order requests until we hit
> the maximum number of retries but I consider it quite ugly to be honest.
> I think that a proper communication with compaction is a more
> appropriate way to go long term. E.g. I find it interesting that
> try_to_compact_pages doesn't even care about PAGE_ALLOC_COSTLY_ORDER
> and treat is as any other high order request.
> 
> Something like the following:

With the patch description. Please note I haven't tested this yet so
this is more a RFC than something I am really convinced about. I can
live with it because the number of retries is nicely bounded but it
sounds too hackish because it makes the decision rather blindly. I will
talk to Vlastimil and Mel whether they see some way how to communicate
the compaction state in a reasonable way. But I guess this is something
that can come up later. What do you think?
---
