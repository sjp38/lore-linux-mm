Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f44.google.com (mail-lf0-f44.google.com [209.85.215.44])
	by kanga.kvack.org (Postfix) with ESMTP id ECF7D6B0253
	for <linux-mm@kvack.org>; Tue, 15 Dec 2015 15:22:56 -0500 (EST)
Received: by mail-lf0-f44.google.com with SMTP id z124so10364422lfa.3
        for <linux-mm@kvack.org>; Tue, 15 Dec 2015 12:22:56 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id mw9si1717596lbb.131.2015.12.15.12.22.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 Dec 2015 12:22:55 -0800 (PST)
Date: Tue, 15 Dec 2015 15:22:35 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 1/7] mm: memcontrol: charge swap to cgroup2
Message-ID: <20151215202235.GB15672@cmpxchg.org>
References: <cover.1449742560.git.vdavydov@virtuozzo.com>
 <265d8fe623ed2773d69a26d302eb31e335377c77.1449742560.git.vdavydov@virtuozzo.com>
 <20151214153037.GB4339@dhcp22.suse.cz>
 <20151214194258.GH28521@esperanza>
 <20151215172127.GC27880@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151215172127.GC27880@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Vladimir Davydov <vdavydov@virtuozzo.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Dec 15, 2015 at 06:21:28PM +0100, Michal Hocko wrote:
> > AFAICS such anon memory protection has a side-effect: real-life
> > workloads need page cache to run smoothly (at least for mapping
> > executables). Disabling swapping would switch pressure to page caches,
> > resulting in performance degradation. So, I don't think per memcg swap
> > limit can be abused to boost your workload on an overcommitted system.
> 
> Well, you can trash on the page cache which could slow down the workload
> but the executable pages get an additional protection so this might be
> not sufficient and still trigger a massive disruption on the global level.

No, this is a real consequence. If you fill your available memory with
mostly unreclaimable memory and your executables start thrashing you
might not make forward progress for hours. We don't have a swap token
for page cache.

> Just to make it clear. I am not against the new way of the swap
> accounting. It is much more clear then the previous one. I am just
> worried it allows for an easy misconfiguration and we do not have any
> measures to help the global system healthiness. I am OK with the patch
> if we document the risk for now. I still think we will end up doing some
> heuristic to throttle for a large unreclaimable high limit excess in the
> future but I agree this shouldn't be the prerequisite.

It's unclear to me how the previous memory+swap counters did anything
tangible for global system health with malicious/buggy workloads. If
anything, the previous model seems to encourage blatant overcommit of
workloads on the flawed assumption that global pressure could always
claw back memory, including anonymous pages of untrusted workloads,
which does not actually work in practice. So I'm not sure what new
risk you are referring to here.

As far as the high limit goes, its job is to contain cache growth and
throttle applications during somewhat higher-than-expected consumption
peaks; not to contain "large unreclaimable high limit excess" from
buggy or malicious applications, that's what the hard limit is for.

All in all, it seems to me we should leave this discussion to actual
problems arising in the real world. There is a lot of unfocussed
speculation in this thread about things that might go wrong, without
much thought put into whether these scenarios are even meaningful or
real or whether they are new problems that come with the swap limit.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
