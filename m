Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 9774C8E0001
	for <linux-mm@kvack.org>; Mon,  7 Jan 2019 03:53:20 -0500 (EST)
Received: by mail-pl1-f200.google.com with SMTP id a10so31419043plp.14
        for <linux-mm@kvack.org>; Mon, 07 Jan 2019 00:53:20 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l59si5727694plb.154.2019.01.07.00.53.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Jan 2019 00:53:19 -0800 (PST)
Date: Mon, 7 Jan 2019 09:53:16 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: memory cgroup pagecache and inode problem
Message-ID: <20190107085316.GY31793@dhcp22.suse.cz>
References: <15614FDC-198E-449B-BFAF-B00D6EF61155@bytedance.com>
 <97A4C2CA-97BA-46DB-964A-E44410BB1730@bytedance.com>
 <CAHbLzkouWtCQ3OVEK1FaJoG5ZbSkzsqmcAqmsb-TbuaO2myccQ@mail.gmail.com>
 <ADF3C74C-BE96-495F-911F-77DDF3368912@bytedance.com>
 <CAHbLzkpbVjtx+uxb1sq-wjBAAv_My6kq4c4bwqRKAmOTZ9dR8g@mail.gmail.com>
 <E2306860-760C-4EB2-92E3-057694971D69@bytedance.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <E2306860-760C-4EB2-92E3-057694971D69@bytedance.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Fam Zheng <zhengfeiran@bytedance.com>
Cc: Yang Shi <shy828301@gmail.com>, cgroups@vger.kernel.org, Linux MM <linux-mm@kvack.org>, tj@kernel.org, Johannes Weiner <hannes@cmpxchg.org>, lizefan@huawei.com, Vladimir Davydov <vdavydov.dev@gmail.com>, duanxiongchun@bytedance.com, =?utf-8?B?5byg5rC46IKD?= <zhangyongsu@bytedance.com>, liuxiaozhou@bytedance.com

On Mon 07-01-19 13:10:17, Fam Zheng wrote:
> 
> 
> > On Jan 5, 2019, at 03:36, Yang Shi <shy828301@gmail.com> wrote:
> > 
> > 
> > drop_caches would drop all page caches globally. You may not want to
> > drop the page caches used by other memcgs.
> 
> We’ve tried your async force_empty patch (with a modification to default it to true to make it transparently enabled for the sake of testing), and for the past few days the stale mem cgroups still accumulate, up to 40k.
> 
> We’ve double checked that the force_empty routines are invoked when a mem cgroup is offlined. But this doesn’t look very effective so far. Because, once we do `echo 1 > /proc/sys/vm/drop_caches`, all the groups immediately go away.
> 
> This is a bit unexpected.
> 
> Yang, could you hint what are missing in the force_empty operation, compared to a blanket drop cache?

I would suspect that not all slab pages holding dentries and inodes got
reclaimed during the slab shrinking inoked by the direct reclaimed
triggered by force emptying.
-- 
Michal Hocko
SUSE Labs
