Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 0685C28089F
	for <linux-mm@kvack.org>; Wed,  8 Feb 2017 15:53:21 -0500 (EST)
Received: by mail-io0-f200.google.com with SMTP id q20so1096091ioi.0
        for <linux-mm@kvack.org>; Wed, 08 Feb 2017 12:53:21 -0800 (PST)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id o138si15867243iod.30.2017.02.08.12.53.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 Feb 2017 12:53:20 -0800 (PST)
Subject: Re: [PATCH] block: fix double-free in the failure path of
 cgwb_bdi_init()
References: <CACT4Y+ZsX1gQHdr7+tqhhB6CeKHBU=4VTMDj-meNbZ=uEPLKWA@mail.gmail.com>
 <20170208201907.GC25826@htj.duckdns.org>
From: Jens Axboe <axboe@fb.com>
Message-ID: <66bc2094-3f13-91da-41c2-78fa1e8a81e8@fb.com>
Date: Wed, 8 Feb 2017 13:52:52 -0700
MIME-Version: 1.0
In-Reply-To: <20170208201907.GC25826@htj.duckdns.org>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>, Dmitry Vyukov <dvyukov@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, xiakaixu@huawei.com, Vlastimil Babka <vbabka@suse.cz>, Joe Perches <joe@perches.com>, Mel Gorman <mgorman@techsingularity.net>, Michal Hocko <mhocko@suse.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, syzkaller <syzkaller@googlegroups.com>

On 02/08/2017 01:19 PM, Tejun Heo wrote:
> When !CONFIG_CGROUP_WRITEBACK, bdi has single bdi_writeback_congested
> at bdi->wb_congested.  cgwb_bdi_init() allocates it with kzalloc() and
> doesn't do further initialization.  This usually works fine as the
> reference count gets bumped to 1 by wb_init() and the put from
> wb_exit() releases it.
> 
> However, when wb_init() fails, it puts the wb base ref automatically
> freeing the wb and the explicit kfree() in cgwb_bdi_init() error path
> ends up trying to free the same pointer the second time causing a
> double-free.
> 
> Fix it by explicitly initilizing the refcnt to 1 and putting the base
> ref from cgwb_bdi_destroy().

Queued up for 4.11.

-- 
Jens Axboe

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
