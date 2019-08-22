Return-Path: <SRS0=SaVu=WS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 170D3C3A5A1
	for <linux-mm@archiver.kernel.org>; Thu, 22 Aug 2019 23:27:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C6FAF23401
	for <linux-mm@archiver.kernel.org>; Thu, 22 Aug 2019 23:27:12 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="WR4Xr/Li"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C6FAF23401
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5C2756B0364; Thu, 22 Aug 2019 19:27:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 572266B0366; Thu, 22 Aug 2019 19:27:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 462116B0367; Thu, 22 Aug 2019 19:27:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0163.hostedemail.com [216.40.44.163])
	by kanga.kvack.org (Postfix) with ESMTP id 26B356B0364
	for <linux-mm@kvack.org>; Thu, 22 Aug 2019 19:27:12 -0400 (EDT)
Received: from smtpin30.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id A657B2C3A
	for <linux-mm@kvack.org>; Thu, 22 Aug 2019 23:27:11 +0000 (UTC)
X-FDA: 75851651862.30.pull51_3ec43d83e6433
X-HE-Tag: pull51_3ec43d83e6433
X-Filterd-Recvd-Size: 2244
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by imf42.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 22 Aug 2019 23:27:11 +0000 (UTC)
Received: from akpm3.svl.corp.google.com (unknown [104.133.8.65])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 16D2E2339F;
	Thu, 22 Aug 2019 23:27:10 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1566516430;
	bh=fxxrOYIlqSS2AAabfmgkps2lg0LsrpP95HyS47QwquQ=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References:From;
	b=WR4Xr/LiXmwcMbud2bhg3CPCNpY/3utY6/8/OtrA5OtzL7AHSPXFqYjD1rYojkqBu
	 5BhalLzEkV6nMuDSsK5mRGw/KloE5O4yijuLnwXBS//FhamXeoeW/z6buCBgFyQ4fD
	 qpYFV/L0+saum1HWybd/MaUqQrjJniXXhnBQjl0Y=
Date: Thu, 22 Aug 2019 16:27:09 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: Roman Gushchin <guro@fb.com>
Cc: <linux-mm@kvack.org>, Michal Hocko <mhocko@kernel.org>, Johannes Weiner
 <hannes@cmpxchg.org>, <linux-kernel@vger.kernel.org>, <kernel-team@fb.com>
Subject: Re: [PATCH v3 0/3] vmstats/vmevents flushing
Message-Id: <20190822162709.fa100ba6c58e15ea35670616@linux-foundation.org>
In-Reply-To: <20190819230054.779745-1-guro@fb.com>
References: <20190819230054.779745-1-guro@fb.com>
X-Mailer: Sylpheed 3.7.0 (GTK+ 2.24.32; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000002, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 19 Aug 2019 16:00:51 -0700 Roman Gushchin <guro@fb.com> wrote:

> v3:
>   1) rearranged patches [2/3] and [3/3] to make [1/2] and [2/2] suitable
>   for stable backporting
> 
> v2:
>   1) fixed !CONFIG_MEMCG_KMEM build by moving memcg_flush_percpu_vmstats()
>   and memcg_flush_percpu_vmevents() out of CONFIG_MEMCG_KMEM
>   2) merged add-comments-to-slab-enums-definition patch in
> 
> Thanks!
> 
> Roman Gushchin (3):
>   mm: memcontrol: flush percpu vmstats before releasing memcg
>   mm: memcontrol: flush percpu vmevents before releasing memcg
>   mm: memcontrol: flush percpu slab vmstats on kmem offlining
> 

Can you please explain why the first two patches were cc:stable but not
the third?


