Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 758C16B0253
	for <linux-mm@kvack.org>; Fri, 22 Jul 2016 04:13:09 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id m101so217318558ioi.0
        for <linux-mm@kvack.org>; Fri, 22 Jul 2016 01:13:09 -0700 (PDT)
Received: from EUR01-VE1-obe.outbound.protection.outlook.com (mail-ve1eur01on0099.outbound.protection.outlook.com. [104.47.1.99])
        by mx.google.com with ESMTPS id j130si5945359oib.244.2016.07.22.01.13.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 22 Jul 2016 01:13:08 -0700 (PDT)
Date: Fri, 22 Jul 2016 11:12:59 +0300
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: Re: [PATCH] update sc->nr_reclaimed after each shrink_slab
Message-ID: <20160722081259.GE26049@esperanza>
References: <1469159010-5636-1-git-send-email-zhouchengming1@huawei.com>
 <20160722074913.GD794@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20160722074913.GD794@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Zhou Chengming <zhouchengming1@huawei.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, riel@redhat.com, guohanjun@huawei.com

On Fri, Jul 22, 2016 at 09:49:13AM +0200, Michal Hocko wrote:
> On Fri 22-07-16 11:43:30, Zhou Chengming wrote:
> > In !global_reclaim(sc) case, we should update sc->nr_reclaimed after each
> > shrink_slab in the loop. Because we need the correct sc->nr_reclaimed
> > value to see if we can break out.
> 
> Does this actually change anything? Maybe I am missing something but
> try_to_free_mem_cgroup_pages which is the main entry for the memcg
> reclaim doesn't set reclaim_state. I don't remember why... Vladimir?

We don't set reclaim_state on memcg reclaim, because there might be a
lot of unrelated slab objects freed from the interrupt context (e.g.
RCU freed) while we're doing memcg reclaim. Obviously, we don't want
them to contribute to nr_reclaimed.

Link to the thread with the problem discussion:

  http://marc.info/?l=linux-kernel&m=142132698209680&w=2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
