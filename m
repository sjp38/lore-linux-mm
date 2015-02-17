Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f47.google.com (mail-wg0-f47.google.com [74.125.82.47])
	by kanga.kvack.org (Postfix) with ESMTP id DB0AC6B0038
	for <linux-mm@kvack.org>; Tue, 17 Feb 2015 03:33:32 -0500 (EST)
Received: by mail-wg0-f47.google.com with SMTP id x12so20109966wgg.6
        for <linux-mm@kvack.org>; Tue, 17 Feb 2015 00:33:32 -0800 (PST)
Received: from mail-we0-x22d.google.com (mail-we0-x22d.google.com. [2a00:1450:400c:c03::22d])
        by mx.google.com with ESMTPS id qm1si27673533wjc.14.2015.02.17.00.33.30
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 Feb 2015 00:33:31 -0800 (PST)
Received: by mail-we0-f173.google.com with SMTP id w55so33499380wes.4
        for <linux-mm@kvack.org>; Tue, 17 Feb 2015 00:33:30 -0800 (PST)
Date: Tue, 17 Feb 2015 09:33:27 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] mm/memcontrol: fix NULL pointer dereference when
 use_hierarchy is 0
Message-ID: <20150217083327.GA32017@dhcp22.suse.cz>
References: <1424150699-5395-1-git-send-email-iamjoonsoo.kim@lge.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1424150699-5395-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <js1304@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On Tue 17-02-15 14:24:59, Joonsoo Kim wrote:
> It can be possible to return NULL in parent_mem_cgroup()
> if use_hierarchy is 0.

This alone is not sufficient because the low limit is present only in
the unified hierarchy API and there is no use_hierarchy there. The
primary issue here is that the memcg has 0 usage so the previous
check for usage will not stop us. And that is bug IMO.

I think that the following patch would be more correct from semantic
POV:
---
