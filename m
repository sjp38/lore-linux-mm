Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 56B7F6B002A
	for <linux-mm@kvack.org>; Tue,  3 Apr 2018 04:40:28 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id i4so9157615wrh.4
        for <linux-mm@kvack.org>; Tue, 03 Apr 2018 01:40:28 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n77si1734188wrb.27.2018.04.03.01.40.26
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 03 Apr 2018 01:40:26 -0700 (PDT)
Date: Tue, 3 Apr 2018 10:40:24 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: avoid the unnecessary waiting when force empty a
 cgroup
Message-ID: <20180403084024.GH5501@dhcp22.suse.cz>
References: <2AD939572F25A448A3AE3CAEA61328C23756E4F1@BC-MAIL-M28.internal.baidu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <2AD939572F25A448A3AE3CAEA61328C23756E4F1@BC-MAIL-M28.internal.baidu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Li,Rongqing" <lirongqing@baidu.com>
Cc: "hannes@cmpxchg.org" <hannes@cmpxchg.org>, "vdavydov.dev@gmail.com" <vdavydov.dev@gmail.com>, "cgroups@vger.kernel.org" <cgroups@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Tue 03-04-18 08:29:39, Li,Rongqing wrote:
> 
> 
> > -----e?(R)a>>?a??a>>?-----
> > a??a>>?aoo: Michal Hocko [mailto:mhocko@kernel.org]
> > a??e??ae??e?': 2018a1'4ae??3ae?JPY 16:05
> > ae??a>>?aoo: Li,Rongqing <lirongqing@baidu.com>
> > ae??e??: hannes@cmpxchg.org; vdavydov.dev@gmail.com;
> > cgroups@vger.kernel.org; linux-mm@kvack.org;
> > linux-kernel@vger.kernel.org
> > a,>>ec?: Re: [PATCH] mm: avoid the unnecessary waiting when force empty a
> > cgroup
> > 
> > On Tue 03-04-18 15:12:09, Li RongQing wrote:
> > > The number of writeback and dirty page can be read out from memcg, the
> > > unnecessary waiting can be avoided by these counts
> > 
> > This changelog doesn't explain the problem and how the patch fixes it.
> 
> If a process in a memory cgroup takes some RSS, when force empty this
> memory cgroup, congestion_wait will be called unconditionally, there
> is 0.5 seconds delay

OK, so the problem is that force_empty hits congestion_wait too much?
Why do we have no progress from try_to_free_mem_cgroup_pages?
 
> If use this patch, nearly no delay.
> 
> 
> > Why do wee another throttling when we do already throttle in the reclaim
> > path?
> 
> Do you mean we should remove congestion_wait(BLK_RW_ASYNC, HZ/10)
> from mem_cgroup_force_empty, since try_to_free_mem_cgroup_pages
> [shrink_inactive_list] has called congestion_wait

If it turns unnecessary, which is quite possible then yes. As I've said
we already throttle when seeing pages under writeback. If that is not
sufficient then we should investigate why.

Please also note that force_empty is considered deprecated. Do you have
any usecase which led you to fixing it?
-- 
Michal Hocko
SUSE Labs
