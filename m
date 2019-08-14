Return-Path: <SRS0=g7KO=WK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D1F54C433FF
	for <linux-mm@archiver.kernel.org>; Wed, 14 Aug 2019 08:11:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id ADA1E2084D
	for <linux-mm@archiver.kernel.org>; Wed, 14 Aug 2019 08:11:58 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org ADA1E2084D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 348286B0270; Wed, 14 Aug 2019 04:11:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2F8696B0272; Wed, 14 Aug 2019 04:11:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2359C6B0273; Wed, 14 Aug 2019 04:11:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0058.hostedemail.com [216.40.44.58])
	by kanga.kvack.org (Postfix) with ESMTP id 036AF6B0270
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 04:11:57 -0400 (EDT)
Received: from smtpin22.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 8E1DF181AC9AE
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 08:11:57 +0000 (UTC)
X-FDA: 75820315074.22.rain27_2e2b4a9c52557
X-HE-Tag: rain27_2e2b4a9c52557
X-Filterd-Recvd-Size: 2246
Received: from mx1.suse.de (mx2.suse.de [195.135.220.15])
	by imf43.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 08:11:57 +0000 (UTC)
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id EA6AAAF98;
	Wed, 14 Aug 2019 08:11:55 +0000 (UTC)
Date: Wed, 14 Aug 2019 10:11:55 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org,
	cgroups@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel-team@fb.com
Subject: Re: [PATCH] mm: vmscan: do not share cgroup iteration between
 reclaimers
Message-ID: <20190814081155.GQ17933@dhcp22.suse.cz>
References: <20190812192316.13615-1-hannes@cmpxchg.org>
 <20190813132938.GJ17933@dhcp22.suse.cz>
 <20190813171237.GA21743@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190813171237.GA21743@cmpxchg.org>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue 13-08-19 13:12:37, Johannes Weiner wrote:
> On Tue, Aug 13, 2019 at 03:29:38PM +0200, Michal Hocko wrote:
> > On Mon 12-08-19 15:23:16, Johannes Weiner wrote:
[...]
> > > This change completely eliminates the OOM kills on our service, while
> > > showing no signs of overreclaim - no increased scan rates, %sys time,
> > > or abrupt free memory spikes. I tested across 100 machines that have
> > > 64G of RAM and host about 300 cgroups each.
> > 
> > What is the usual direct reclaim involvement on those machines?
> 
> 80-200 kb/s. In general we try to keep this low to non-existent on our
> hosts due to the latency implications. So it's fair to say that kswapd
> does page reclaim, and direct reclaim is a sign of overload.

Well, there are workloads which are much more direct reclaim heavier.
How much they rely on large memcg trees remains to be seen. Your
changelog should state that the above workload is very light on direct
reclaim, though, because the above paragraph suggests that a risk of
longer stalls is really non-issue while I think this is not really all
that clear.
-- 
Michal Hocko
SUSE Labs

