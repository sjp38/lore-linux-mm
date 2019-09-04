Return-Path: <SRS0=zrK/=W7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2B55AC3A5A9
	for <linux-mm@archiver.kernel.org>; Wed,  4 Sep 2019 14:37:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E765C20870
	for <linux-mm@archiver.kernel.org>; Wed,  4 Sep 2019 14:37:50 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E765C20870
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 988D46B0006; Wed,  4 Sep 2019 10:37:50 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 938726B0007; Wed,  4 Sep 2019 10:37:50 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 84DC96B0008; Wed,  4 Sep 2019 10:37:50 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0100.hostedemail.com [216.40.44.100])
	by kanga.kvack.org (Postfix) with ESMTP id 625026B0006
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 10:37:50 -0400 (EDT)
Received: from smtpin03.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 03974181AC9BF
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 14:37:50 +0000 (UTC)
X-FDA: 75897492300.03.sea09_7e8d99050ef0c
X-HE-Tag: sea09_7e8d99050ef0c
X-Filterd-Recvd-Size: 3631
Received: from mx1.suse.de (mx2.suse.de [195.135.220.15])
	by imf21.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 14:37:49 +0000 (UTC)
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 43F1EAFFA;
	Wed,  4 Sep 2019 14:37:48 +0000 (UTC)
Date: Wed, 4 Sep 2019 16:37:47 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	cgroups@vger.kernel.org, Roman Gushchin <guro@fb.com>,
	Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH v1 0/7] mm/memcontrol: recharge mlocked pages
Message-ID: <20190904143747.GA3838@dhcp22.suse.cz>
References: <156760509382.6560.17364256340940314860.stgit@buzz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <156760509382.6560.17364256340940314860.stgit@buzz>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed 04-09-19 16:53:08, Konstantin Khlebnikov wrote:
> Currently mlock keeps pages in cgroups where they were accounted.
> This way one container could affect another if they share file cache.
> Typical case is writing (downloading) file in one container and then
> locking in another. After that first container cannot get rid of cache.
> Also removed cgroup stays pinned by these mlocked pages.
> 
> This patchset implements recharging pages to cgroup of mlock user.
> 
> There are three cases:
> * recharging at first mlock
> * recharging at munlock to any remaining mlock
> * recharging at 'culling' in reclaimer to any existing mlock
> 
> To keep things simple recharging ignores memory limit. After that memory
> usage temporary could be higher than limit but cgroup will reclaim memory
> later or trigger oom, which is valid outcome when somebody mlock too much.

I assume that this is mlock specific because the pagecache which has the
same problem is reclaimable and the problem tends to resolve itself
after some time.

Anyway, how big of a problem this really is? A lingering memcg is
certainly not nice but pages are usually not mlocked for ever. Or is
this a way to protect from an hostile actor?

> Konstantin Khlebnikov (7):
>       mm/memcontrol: move locking page out of mem_cgroup_move_account
>       mm/memcontrol: add mem_cgroup_recharge
>       mm/mlock: add vma argument for mlock_vma_page()
>       mm/mlock: recharge memory accounting to first mlock user
>       mm/mlock: recharge memory accounting to second mlock user at munlock
>       mm/vmscan: allow changing page memory cgroup during reclaim
>       mm/mlock: recharge mlocked pages at culling by vmscan
> 
> 
>  Documentation/admin-guide/cgroup-v1/memory.rst |    5 +
>  include/linux/memcontrol.h                     |    9 ++
>  include/linux/rmap.h                           |    3 -
>  mm/gup.c                                       |    2 
>  mm/huge_memory.c                               |    4 -
>  mm/internal.h                                  |    6 +
>  mm/ksm.c                                       |    2 
>  mm/memcontrol.c                                |  104 ++++++++++++++++--------
>  mm/migrate.c                                   |    2 
>  mm/mlock.c                                     |   14 +++
>  mm/rmap.c                                      |    5 +
>  mm/vmscan.c                                    |   17 ++--
>  12 files changed, 121 insertions(+), 52 deletions(-)
> 
> --
> Signature

-- 
Michal Hocko
SUSE Labs

