Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 7FAE46B0033
	for <linux-mm@kvack.org>; Wed,  1 Feb 2017 05:00:29 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id v77so4160290wmv.5
        for <linux-mm@kvack.org>; Wed, 01 Feb 2017 02:00:29 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t10si20639472wmb.160.2017.02.01.02.00.28
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 01 Feb 2017 02:00:28 -0800 (PST)
Date: Wed, 1 Feb 2017 11:00:23 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v5 1/4] mm/migration: make isolate_movable_page() return
 int type
Message-ID: <20170201100022.GI5977@dhcp22.suse.cz>
References: <1485867981-16037-1-git-send-email-ysxie@foxmail.com>
 <1485867981-16037-2-git-send-email-ysxie@foxmail.com>
 <20170201064821.GA10342@bbox>
 <20170201075924.GB5977@dhcp22.suse.cz>
 <20170201094636.GC10342@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170201094636.GC10342@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: ysxie@foxmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, n-horiguchi@ah.jp.nec.com, akpm@linux-foundation.org, vbabka@suse.cz, mgorman@techsingularity.net, hannes@cmpxchg.org, iamjoonsoo.kim@lge.com, izumi.taku@jp.fujitsu.com, arbab@linux.vnet.ibm.com, vkuznets@redhat.com, ak@linux.intel.com, guohanjun@huawei.com, qiuxishi@huawei.com

On Wed 01-02-17 18:46:36, Minchan Kim wrote:
> On Wed, Feb 01, 2017 at 08:59:24AM +0100, Michal Hocko wrote:
> > On Wed 01-02-17 15:48:21, Minchan Kim wrote:
> > > Hi Yisheng,
> > > 
> > > On Tue, Jan 31, 2017 at 09:06:18PM +0800, ysxie@foxmail.com wrote:
> > > > From: Yisheng Xie <xieyisheng1@huawei.com>
> > > > 
> > > > This patch changes the return type of isolate_movable_page()
> > > > from bool to int. It will return 0 when isolate movable page
> > > > successfully, return -EINVAL when the page is not a non-lru movable
> > > > page, and for other cases it will return -EBUSY.
> > > > 
> > > > There is no functional change within this patch but prepare
> > > > for later patch.
> > > > 
> > > > Signed-off-by: Yisheng Xie <xieyisheng1@huawei.com>
> > > > Suggested-by: Michal Hocko <mhocko@kernel.org>
> > > 
> > > Sorry for missing this one you guys were discussing.
> > > I don't understand the patch's goal although I read later patches.
> > 
> > The point is that the failed isolation has to propagate error up the
> > call chain to the userspace which has initiated the migration.
> > 
> > > isolate_movable_pages returns success/fail so that's why I selected
> > > bool rather than int but it seems you guys want to propagate more
> > > detailed error to the user so added -EBUSY and -EINVAL.
> > > 
> > > But the question is why isolate_lru_pages doesn't have -EINVAL?
> > 
> > It doesn't have to same as isolate_movable_pages. We should just return
> > EBUSY when the page is no longer movable.
> 
> Why isolate_lru_page is okay to return -EBUSY in case of race while
> isolate_movable_page should return -EINVAL?
> What's the logic in your mind? I totally cannot understand.

Let me rephrase. Both should return EBUSY.

> > > Secondly, madvise man page should update?
> > 
> > Why?
> 
> man page of madvise doesn't say anything about the error propagation
> for soft_offline.

OK, EBUSY should be documented.

> > > Thirdly, if a driver fail isolation due to -ENOMEM, it should be
> > > propagated, too?
> > 
> > Yes
> > 
> > > if we want to propagte detailed error to user, driver's isolate_page
> > > function should return right error.
> > 
> > Yes
> 
> It seems we are okay to return just -EBUSY until now but now you try to
> return more various error. I don't understand what problem you are
> seeing with just -EBUSY. Anyway, if you want to do it, it should be able
> to propagate error from driver side. That means it should make rule
> what kinds of error driver can return. Please write down it to
> Documentation/vm/page_migration and fix zsmalloc/virtio-balloon, too.

agreed!

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
