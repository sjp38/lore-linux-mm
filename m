Return-Path: <SRS0=aN9C=WJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D4508C32750
	for <linux-mm@archiver.kernel.org>; Tue, 13 Aug 2019 21:27:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 89EB3216F4
	for <linux-mm@archiver.kernel.org>; Tue, 13 Aug 2019 21:27:55 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="TjxnzxQy"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 89EB3216F4
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DD8476B028A; Tue, 13 Aug 2019 17:27:54 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D60F16B028B; Tue, 13 Aug 2019 17:27:54 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C4FDF6B028C; Tue, 13 Aug 2019 17:27:54 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0208.hostedemail.com [216.40.44.208])
	by kanga.kvack.org (Postfix) with ESMTP id 9BD9D6B028A
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 17:27:54 -0400 (EDT)
Received: from smtpin09.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 36AAE181AC9AE
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 21:27:54 +0000 (UTC)
X-FDA: 75818692068.09.loss77_620d665d93105
X-HE-Tag: loss77_620d665d93105
X-Filterd-Recvd-Size: 3170
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by imf29.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 21:27:53 +0000 (UTC)
Received: from akpm3.svl.corp.google.com (unknown [104.133.8.65])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 9E57F20665;
	Tue, 13 Aug 2019 21:27:52 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1565731672;
	bh=JnDrtx/GuVJXE+K/6+7bGsOzbRZTo0uwMqXFtO03veI=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References:From;
	b=TjxnzxQypKbYUc3VoT24ndSB0NUEq3OdCPnWH/WcRdNlbE8CSDvVztElNn3QMuBIO
	 /YaMslZ4NwSjlMvBQ4kWRGX8P74H28X9zbRKOhfDOG4bQOFwxhd6r5KZp79jL8cv6V
	 pH/HTTZycXXjnnyzj2C68WZ4fcUkvqGxdIFQvKDk=
Date: Tue, 13 Aug 2019 14:27:52 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: Roman Gushchin <guro@fb.com>
Cc: <linux-mm@kvack.org>, Michal Hocko <mhocko@kernel.org>, Johannes Weiner
 <hannes@cmpxchg.org>, <linux-kernel@vger.kernel.org>, <kernel-team@fb.com>
Subject: Re: [PATCH 1/2] mm: memcontrol: flush percpu vmstats before
 releasing memcg
Message-Id: <20190813142752.35807b6070db795674f86feb@linux-foundation.org>
In-Reply-To: <20190812222911.2364802-2-guro@fb.com>
References: <20190812222911.2364802-1-guro@fb.com>
	<20190812222911.2364802-2-guro@fb.com>
X-Mailer: Sylpheed 3.7.0 (GTK+ 2.24.32; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 12 Aug 2019 15:29:10 -0700 Roman Gushchin <guro@fb.com> wrote:

> Percpu caching of local vmstats with the conditional propagation
> by the cgroup tree leads to an accumulation of errors on non-leaf
> levels.
> 
> Let's imagine two nested memory cgroups A and A/B. Say, a process
> belonging to A/B allocates 100 pagecache pages on the CPU 0.
> The percpu cache will spill 3 times, so that 32*3=96 pages will be
> accounted to A/B and A atomic vmstat counters, 4 pages will remain
> in the percpu cache.
> 
> Imagine A/B is nearby memory.max, so that every following allocation
> triggers a direct reclaim on the local CPU. Say, each such attempt
> will free 16 pages on a new cpu. That means every percpu cache will
> have -16 pages, except the first one, which will have 4 - 16 = -12.
> A/B and A atomic counters will not be touched at all.
> 
> Now a user removes A/B. All percpu caches are freed and corresponding
> vmstat numbers are forgotten. A has 96 pages more than expected.
> 
> As memory cgroups are created and destroyed, errors do accumulate.
> Even 1-2 pages differences can accumulate into large numbers.
> 
> To fix this issue let's accumulate and propagate percpu vmstat
> values before releasing the memory cgroup. At this point these
> numbers are stable and cannot be changed.
> 
> Since on cpu hotplug we do flush percpu vmstats anyway, we can
> iterate only over online cpus.
> 
> Fixes: 42a300353577 ("mm: memcontrol: fix recursive statistics correctness & scalabilty")

Is this not serious enough for a cc:stable?

