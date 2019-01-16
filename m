Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 585798E0002
	for <linux-mm@kvack.org>; Wed, 16 Jan 2019 02:06:17 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id t7so1995052edr.21
        for <linux-mm@kvack.org>; Tue, 15 Jan 2019 23:06:17 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r19si5241406edl.68.2019.01.15.23.06.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 Jan 2019 23:06:16 -0800 (PST)
Date: Wed, 16 Jan 2019 08:06:14 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: memory cgroup pagecache and inode problem
Message-ID: <20190116070614.GG24149@dhcp22.suse.cz>
References: <15614FDC-198E-449B-BFAF-B00D6EF61155@bytedance.com>
 <97A4C2CA-97BA-46DB-964A-E44410BB1730@bytedance.com>
 <CAHbLzkouWtCQ3OVEK1FaJoG5ZbSkzsqmcAqmsb-TbuaO2myccQ@mail.gmail.com>
 <ADF3C74C-BE96-495F-911F-77DDF3368912@bytedance.com>
 <CAHbLzkpbVjtx+uxb1sq-wjBAAv_My6kq4c4bwqRKAmOTZ9dR8g@mail.gmail.com>
 <E2306860-760C-4EB2-92E3-057694971D69@bytedance.com>
 <CAHbLzkrE887hR_2o_1zJkBcReDt-KzezUE4Jug8zULdV7g17-w@mail.gmail.com>
 <9B56B884-8FDD-4BB5-A6CA-AD7F84397039@bytedance.com>
 <CAHbLzkpHst6bA=eVjoHRFuCuOfo8kKnCPE7Tg4voaJ_kwruVqw@mail.gmail.com>
 <C7C72217-D4AF-474C-A98E-975E389BC85C@bytedance.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <C7C72217-D4AF-474C-A98E-975E389BC85C@bytedance.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Fam Zheng <zhengfeiran@bytedance.com>
Cc: Yang Shi <shy828301@gmail.com>, cgroups@vger.kernel.org, Linux MM <linux-mm@kvack.org>, tj@kernel.org, Johannes Weiner <hannes@cmpxchg.org>, lizefan@huawei.com, Vladimir Davydov <vdavydov.dev@gmail.com>, duanxiongchun@bytedance.com, =?utf-8?B?5byg5rC46IKD?= <zhangyongsu@bytedance.com>, liuxiaozhou@bytedance.com

On Wed 16-01-19 11:52:08, Fam Zheng wrote:
[...]
> > This is what force_empty is supposed to do.  But, as your test shows
> > some page cache may still remain after force_empty, then cause offline
> > memcgs accumulated.  I haven't figured out what happened.  You may try
> > what Michal suggested.
> 
> None of the existing patches helped so far, but we suspect that the
> pages cannot be locked at the force_empty moment. We have being
> working on a “retry” patch which does solve the problem. We’ll
> do more tracing (to have a better understanding of the issue) and post
> the findings and/or the patch later. Thanks.

Just for the record. There was a patch to remove
MEM_CGROUP_RECLAIM_RETRIES restriction in the path. I cannot find the
link right now but that is something we certainly can do. The context is
interruptible by signal and it from my experience any retry count can
lead to unexpected failures. But I guess you really want to check
vmscan tracepoints to see why you cannot reclaim pages on memcg LRUs
first.
-- 
Michal Hocko
SUSE Labs
