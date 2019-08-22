Return-Path: <SRS0=SaVu=WS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 81B87C3A5A1
	for <linux-mm@archiver.kernel.org>; Thu, 22 Aug 2019 07:21:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 50D3F233A0
	for <linux-mm@archiver.kernel.org>; Thu, 22 Aug 2019 07:21:38 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 50D3F233A0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E3A076B02D7; Thu, 22 Aug 2019 03:21:37 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DE9CB6B02D8; Thu, 22 Aug 2019 03:21:37 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CFFA36B02D9; Thu, 22 Aug 2019 03:21:37 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0022.hostedemail.com [216.40.44.22])
	by kanga.kvack.org (Postfix) with ESMTP id A89FC6B02D7
	for <linux-mm@kvack.org>; Thu, 22 Aug 2019 03:21:37 -0400 (EDT)
Received: from smtpin12.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id 11FD48155
	for <linux-mm@kvack.org>; Thu, 22 Aug 2019 07:21:37 +0000 (UTC)
X-FDA: 75849218634.12.line92_4849c6ec5ca21
X-HE-Tag: line92_4849c6ec5ca21
X-Filterd-Recvd-Size: 3661
Received: from mx1.suse.de (mx2.suse.de [195.135.220.15])
	by imf03.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 22 Aug 2019 07:21:36 +0000 (UTC)
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 56018AE1C;
	Thu, 22 Aug 2019 07:21:35 +0000 (UTC)
Date: Thu, 22 Aug 2019 09:21:34 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Edward Chron <echron@arista.com>
Cc: David Rientjes <rientjes@google.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Roman Gushchin <guro@fb.com>, Johannes Weiner <hannes@cmpxchg.org>,
	Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>,
	Shakeel Butt <shakeelb@google.com>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, Ivan Delalande <colona@arista.com>
Subject: Re: [PATCH] mm/oom: Add oom_score_adj value to oom Killed process
 message
Message-ID: <20190822072134.GD12785@dhcp22.suse.cz>
References: <20190821001445.32114-1-echron@arista.com>
 <alpine.DEB.2.21.1908202024300.141379@chino.kir.corp.google.com>
 <20190821064732.GW3111@dhcp22.suse.cz>
 <alpine.DEB.2.21.1908210017320.177871@chino.kir.corp.google.com>
 <20190821074721.GY3111@dhcp22.suse.cz>
 <CAM3twVR5Z1LG4+pqMF94mCw8R0sJ3VJtnggQnu+047c7jxJVug@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAM3twVR5Z1LG4+pqMF94mCw8R0sJ3VJtnggQnu+047c7jxJVug@mail.gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed 21-08-19 16:12:08, Edward Chron wrote:
[...]
> Additionally (which you know, but mentioning for reference) the OOM
> output used to look like this:
> 
> Nov 14 15:23:48 oldserver kernel: [337631.991218] Out of memory: Kill
> process 19961 (python) score 17 or sacrifice child
> Nov 14 15:23:48 oldserver kernel: [337631.991237] Killed process 31357
> (sh) total-vm:5400kB, anon-rss:252kB, file-rss:4kB, shmem-rss:0kB
> 
> It now looks like this with 5.3.0-rc5 (minus the oom_score_adj):
> 
> Jul 22 10:42:40 newserver kernel:
> oom-kill:constraint=CONSTRAINT_NONE,nodemask=(null),cpuset=/,mems_allowed=0,global_oom,task_memcg=/user.slice/user-10383.slice/user@10383.service,task=oomprocs,pid=3035,uid=10383
> Jul 22 10:42:40 newserver kernel: Out of memory: Killed process 3035
> (oomprocs) total-vm:1056800kB, anon-rss:8kB, file-rss:4kB,
> shmem-rss:0kB
> Jul 22 10:42:40 newserver kernel: oom_reaper: reaped process 3035
> (oomprocs), now anon-rss:0kB, file-rss:0kB, shmem-rss:0kB
> 
> The old output did explain that a oom_score of 17 must have either
> tied for highest or was the highest.
> This did document why OOM selected the process it did, even if ends up
> killing the related sh process.
> 
> With the newer format that added constraint message, it does provide
> uid which can be helpful and
> the oom_reaper showing that the memory was reclaimed is certainly reassuring.
> 
> My understanding now is that printing the oom_score is discouraged.
> This seems unfortunate.  The oom_score_adj can be adjusted
> appropriately if oom_score is known.
> So It would be useful to have both.

As already mentioned in our previous discussion I am really not happy
about exporting oom_score withtout a larger context - aka other tasks
scores to have something to compare against. Other than that the value
is an internal implementation detail and it is meaningless without
knowing the exact algorithm which can change at any times so no
userspace should really depend on it. All important metrics should be
displayed by the oom report message already.

-- 
Michal Hocko
SUSE Labs

