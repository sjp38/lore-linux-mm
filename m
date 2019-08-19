Return-Path: <SRS0=U3FQ=WP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 80795C3A5A0
	for <linux-mm@archiver.kernel.org>; Mon, 19 Aug 2019 22:27:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3E08522CE8
	for <linux-mm@archiver.kernel.org>; Mon, 19 Aug 2019 22:27:47 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="o6MCUhy7"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3E08522CE8
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DDB7A6B000A; Mon, 19 Aug 2019 18:27:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D652D6B000C; Mon, 19 Aug 2019 18:27:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C7ADE6B000D; Mon, 19 Aug 2019 18:27:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0124.hostedemail.com [216.40.44.124])
	by kanga.kvack.org (Postfix) with ESMTP id 9F9CF6B000A
	for <linux-mm@kvack.org>; Mon, 19 Aug 2019 18:27:46 -0400 (EDT)
Received: from smtpin01.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id 434DA180AD7C3
	for <linux-mm@kvack.org>; Mon, 19 Aug 2019 22:27:46 +0000 (UTC)
X-FDA: 75840615732.01.baby49_60e59e8b1524e
X-HE-Tag: baby49_60e59e8b1524e
X-Filterd-Recvd-Size: 3012
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by imf26.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon, 19 Aug 2019 22:27:45 +0000 (UTC)
Received: from akpm3.svl.corp.google.com (unknown [104.133.8.65])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 95CBF22CE8;
	Mon, 19 Aug 2019 22:27:44 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1566253664;
	bh=amjQuu+FazRVtx1TJBC7GqpU3maEAdLeUfc01ZumRPo=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References:From;
	b=o6MCUhy7QJ3Bbjhe9x4pf0tlbsmdfKV1eSzvmkAEpz6VLHPhG6Muh4rMiUyp1GPcp
	 9WMO1J75H8UuEqSj/wDoi+57MWtZjxUUBaEJIcTMg996WHcAQ6VNKoqheVSSjoGGJ4
	 VRlwyob/PbcNFAn1RbvBVA+MLdCMeNbTaCBrcApI=
Date: Mon, 19 Aug 2019 15:27:44 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: Roman Gushchin <guro@fb.com>
Cc: <linux-mm@kvack.org>, Michal Hocko <mhocko@kernel.org>, Johannes Weiner
 <hannes@cmpxchg.org>, <linux-kernel@vger.kernel.org>, <kernel-team@fb.com>,
 Vladimir Davydov <vdavydov.dev@gmail.com>
Subject: Re: [PATCH v2 2/3] mm: memcontrol: flush percpu slab vmstats on
 kmem offlining
Message-Id: <20190819152744.4ab8478cfb8697856408425b@linux-foundation.org>
In-Reply-To: <20190819202338.363363-3-guro@fb.com>
References: <20190819202338.363363-1-guro@fb.com>
	<20190819202338.363363-3-guro@fb.com>
X-Mailer: Sylpheed 3.7.0 (GTK+ 2.24.32; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 19 Aug 2019 13:23:37 -0700 Roman Gushchin <guro@fb.com> wrote:

> I've noticed that the "slab" value in memory.stat is sometimes 0,
> even if some children memory cgroups have a non-zero "slab" value.
> The following investigation showed that this is the result
> of the kmem_cache reparenting in combination with the per-cpu
> batching of slab vmstats.
> 
> At the offlining some vmstat value may leave in the percpu cache,
> not being propagated upwards by the cgroup hierarchy. It means
> that stats on ancestor levels are lower than actual. Later when
> slab pages are released, the precise number of pages is substracted
> on the parent level, making the value negative. We don't show negative
> values, 0 is printed instead.
> 
> To fix this issue, let's flush percpu slab memcg and lruvec stats
> on memcg offlining. This guarantees that numbers on all ancestor
> levels are accurate and match the actual number of outstanding
> slab pages.
> 
> Fixes: fb2f2b0adb98 ("mm: memcg/slab: reparent memcg kmem_caches on cgroup removal")
> Signed-off-by: Roman Gushchin <guro@fb.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Michal Hocko <mhocko@kernel.org>
> Cc: Vladimir Davydov <vdavydov.dev@gmail.com>

[1/3] and [3/3] have cc:stable.  [2/3] does not.  However [3/3] does
not correctly apply without [2/3] having being applied.


