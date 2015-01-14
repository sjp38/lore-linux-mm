Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f49.google.com (mail-wg0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id 5C8846B006C
	for <linux-mm@kvack.org>; Wed, 14 Jan 2015 11:50:40 -0500 (EST)
Received: by mail-wg0-f49.google.com with SMTP id n12so10061316wgh.8
        for <linux-mm@kvack.org>; Wed, 14 Jan 2015 08:50:39 -0800 (PST)
Received: from mail-wi0-x234.google.com (mail-wi0-x234.google.com. [2a00:1450:400c:c05::234])
        by mx.google.com with ESMTPS id t3si4487901wiw.92.2015.01.14.08.50.39
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 14 Jan 2015 08:50:39 -0800 (PST)
Received: by mail-wi0-f180.google.com with SMTP id n3so12243367wiv.1
        for <linux-mm@kvack.org>; Wed, 14 Jan 2015 08:50:39 -0800 (PST)
Date: Wed, 14 Jan 2015 17:50:36 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH v2] mm: vmscan: fix the page state calculation in
 too_many_isolated
Message-ID: <20150114165036.GI4706@dhcp22.suse.cz>
References: <1421235419-30736-1-git-send-email-vinmenon@codeaurora.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1421235419-30736-1-git-send-email-vinmenon@codeaurora.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vinayak Menon <vinmenon@codeaurora.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, hannes@cmpxchg.org, vdavydov@parallels.com, mgorman@suse.de, minchan@kernel.org

On Wed 14-01-15 17:06:59, Vinayak Menon wrote:
[...]
> In one such instance, zone_page_state(zone, NR_ISOLATED_FILE)
> had returned 14, zone_page_state(zone, NR_INACTIVE_FILE)
> returned 92, and GFP_IOFS was set, and this resulted
> in too_many_isolated returning true. But one of the CPU's
> pageset vm_stat_diff had NR_ISOLATED_FILE as "-14". So the
> actual isolated count was zero. As there weren't any more
> updates to NR_ISOLATED_FILE and vmstat_update deffered work
> had not been scheduled yet, 7 tasks were spinning in the
> congestion wait loop for around 4 seconds, in the direct
> reclaim path.

Not syncing for such a long time doesn't sound right. I am not familiar
with the vmstat syncing but sysctl_stat_interval is HZ so it should
happen much more often that every 4 seconds.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
