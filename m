Return-Path: <SRS0=I31T=WR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 33BD5C3A5A1
	for <linux-mm@archiver.kernel.org>; Wed, 21 Aug 2019 06:47:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 00B422089E
	for <linux-mm@archiver.kernel.org>; Wed, 21 Aug 2019 06:47:35 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 00B422089E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A28876B029B; Wed, 21 Aug 2019 02:47:35 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9D9826B029C; Wed, 21 Aug 2019 02:47:35 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8EEBD6B029D; Wed, 21 Aug 2019 02:47:35 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0071.hostedemail.com [216.40.44.71])
	by kanga.kvack.org (Postfix) with ESMTP id 6717D6B029B
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 02:47:35 -0400 (EDT)
Received: from smtpin28.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 075B98248AC4
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 06:47:35 +0000 (UTC)
X-FDA: 75845504070.28.geese06_7f39d1b24046
X-HE-Tag: geese06_7f39d1b24046
X-Filterd-Recvd-Size: 3229
Received: from mx1.suse.de (mx2.suse.de [195.135.220.15])
	by imf10.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 06:47:34 +0000 (UTC)
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id D59E2ABE3;
	Wed, 21 Aug 2019 06:47:32 +0000 (UTC)
Date: Wed, 21 Aug 2019 08:47:32 +0200
From: Michal Hocko <mhocko@kernel.org>
To: David Rientjes <rientjes@google.com>
Cc: Edward Chron <echron@arista.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Roman Gushchin <guro@fb.com>, Johannes Weiner <hannes@cmpxchg.org>,
	Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>,
	Shakeel Butt <shakeelb@google.com>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, colona@arista.com
Subject: Re: [PATCH] mm/oom: Add oom_score_adj value to oom Killed process
 message
Message-ID: <20190821064732.GW3111@dhcp22.suse.cz>
References: <20190821001445.32114-1-echron@arista.com>
 <alpine.DEB.2.21.1908202024300.141379@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.21.1908202024300.141379@chino.kir.corp.google.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue 20-08-19 20:25:32, David Rientjes wrote:
> On Tue, 20 Aug 2019, Edward Chron wrote:
> 
> > For an OOM event: print oom_score_adj value for the OOM Killed process to
> > document what the oom score adjust value was at the time the process was
> > OOM Killed. The adjustment value can be set by user code and it affects
> > the resulting oom_score so it is used to influence kill process selection.
> > 
> > When eligible tasks are not printed (sysctl oom_dump_tasks = 0) printing
> > this value is the only documentation of the value for the process being
> > killed. Having this value on the Killed process message documents if a
> > miscconfiguration occurred or it can confirm that the oom_score_adj
> > value applies as expected.
> > 
> > An example which illustates both misconfiguration and validation that
> > the oom_score_adj was applied as expected is:
> > 
> > Aug 14 23:00:02 testserver kernel: Out of memory: Killed process 2692
> >  (systemd-udevd) total-vm:1056800kB, anon-rss:1052760kB, file-rss:4kB,
> >  shmem-rss:0kB oom_score_adj:1000
> > 
> > The systemd-udevd is a critical system application that should have an
> > oom_score_adj of -1000. Here it was misconfigured to have a adjustment
> > of 1000 making it a highly favored OOM kill target process. The output
> > documents both the misconfiguration and the fact that the process
> > was correctly targeted by OOM due to the miconfiguration. Having
> > the oom_score_adj on the Killed message ensures that it is documented.
> > 
> > Signed-off-by: Edward Chron <echron@arista.com>
> > Acked-by: Michal Hocko <mhocko@suse.com>
> 
> Acked-by: David Rientjes <rientjes@google.com>
> 
> vm.oom_dump_tasks is pretty useful, however, so it's curious why you 
> haven't left it enabled :/

Because it generates a lot of output potentially. Think of a workload
with too many tasks which is not uncommon.
-- 
Michal Hocko
SUSE Labs

