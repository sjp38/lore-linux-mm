Return-Path: <SRS0=aN9C=WJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5D432C32750
	for <linux-mm@archiver.kernel.org>; Tue, 13 Aug 2019 21:31:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1ED292067D
	for <linux-mm@archiver.kernel.org>; Tue, 13 Aug 2019 21:31:21 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="elLSkOtT"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1ED292067D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B3D426B028A; Tue, 13 Aug 2019 17:31:20 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AECFD6B028B; Tue, 13 Aug 2019 17:31:20 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A029C6B028C; Tue, 13 Aug 2019 17:31:20 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0037.hostedemail.com [216.40.44.37])
	by kanga.kvack.org (Postfix) with ESMTP id 797676B028A
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 17:31:20 -0400 (EDT)
Received: from smtpin18.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id 10EBD180AD7C3
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 21:31:20 +0000 (UTC)
X-FDA: 75818700720.18.noise08_800256f3ef42e
X-HE-Tag: noise08_800256f3ef42e
X-Filterd-Recvd-Size: 2320
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by imf24.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 21:31:19 +0000 (UTC)
Received: from akpm3.svl.corp.google.com (unknown [104.133.8.65])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 79C9720665;
	Tue, 13 Aug 2019 21:31:17 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1565731877;
	bh=tjFvWLPSSfcPrnSoEvYPNR+1ax/3i9N/XRtulBqxupU=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References:From;
	b=elLSkOtT891o1HflqX+iByvvwV+ByIjKKmOU9b3NfLMnPa+9erUcWokJI6XD7ymEU
	 7ttmBIX9VYtOUp1ZHrefdIAH/Fihhm2AVf11jHkHeMmAS4U4DpyTMpsY4VCoLMZmW9
	 alzjY58nI17Dwzg+5PuPNEm4GPMQO6UQnyFpzSPs=
Date: Tue, 13 Aug 2019 14:31:17 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: Roman Gushchin <guro@fb.com>
Cc: <linux-mm@kvack.org>, Michal Hocko <mhocko@kernel.org>, Johannes Weiner
 <hannes@cmpxchg.org>, <linux-kernel@vger.kernel.org>, <kernel-team@fb.com>
Subject: Re: [PATCH] mm: memcontrol: flush percpu vmevents before releasing
 memcg
Message-Id: <20190813143117.885bef5929813445ef39fa61@linux-foundation.org>
In-Reply-To: <20190812233754.2570543-1-guro@fb.com>
References: <20190812233754.2570543-1-guro@fb.com>
X-Mailer: Sylpheed 3.7.0 (GTK+ 2.24.32; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 12 Aug 2019 16:37:54 -0700 Roman Gushchin <guro@fb.com> wrote:

> Similar to vmstats, percpu caching of local vmevents leads to an
> accumulation of errors on non-leaf levels. This happens because
> some leftovers may remain in percpu caches, so that they are
> never propagated up by the cgroup tree and just disappear into
> nonexistence with on releasing of the memory cgroup.
> 
> To fix this issue let's accumulate and propagate percpu vmevents
> values before releasing the memory cgroup similar to what we're
> doing with vmstats.
> 
> Since on cpu hotplug we do flush percpu vmstats anyway, we can
> iterate only over online cpus.
> 
> Fixes: 42a300353577 ("mm: memcontrol: fix recursive statistics correctness & scalabilty")

No cc:stable?

