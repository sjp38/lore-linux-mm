Return-Path: <SRS0=g7KO=WK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 15A2CC32753
	for <linux-mm@archiver.kernel.org>; Wed, 14 Aug 2019 12:53:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D767320679
	for <linux-mm@archiver.kernel.org>; Wed, 14 Aug 2019 12:53:38 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D767320679
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6E2516B0007; Wed, 14 Aug 2019 08:53:38 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 66AEC6B0008; Wed, 14 Aug 2019 08:53:38 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5813D6B000A; Wed, 14 Aug 2019 08:53:38 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0190.hostedemail.com [216.40.44.190])
	by kanga.kvack.org (Postfix) with ESMTP id 311726B0007
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 08:53:38 -0400 (EDT)
Received: from smtpin04.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id D66732C04
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 12:53:37 +0000 (UTC)
X-FDA: 75821024874.04.mass08_1f767ade45c04
X-HE-Tag: mass08_1f767ade45c04
X-Filterd-Recvd-Size: 2722
Received: from mx1.suse.de (mx2.suse.de [195.135.220.15])
	by imf39.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 12:53:36 +0000 (UTC)
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id D8FEEAEE9;
	Wed, 14 Aug 2019 12:53:34 +0000 (UTC)
Date: Wed, 14 Aug 2019 14:53:34 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Yang Shi <yang.shi@linux.alibaba.com>, kirill.shutemov@linux.intel.com,
	hannes@cmpxchg.org, rientjes@google.com, akpm@linux-foundation.org,
	linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	Linux API <linux-api@vger.kernel.org>
Subject: Re: [RESEND PATCH 1/2 -mm] mm: account lazy free pages separately
Message-ID: <20190814125334.GX17933@dhcp22.suse.cz>
References: <1565308665-24747-1-git-send-email-yang.shi@linux.alibaba.com>
 <20190809083216.GM18351@dhcp22.suse.cz>
 <1a3c4185-c7ab-8d6f-8191-77dce02025a7@linux.alibaba.com>
 <20190809180238.GS18351@dhcp22.suse.cz>
 <79c90f6b-fcac-02e1-015a-0eaa4eafdf7d@linux.alibaba.com>
 <564a0860-94f1-6301-5527-5c2272931d8b@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <564a0860-94f1-6301-5527-5c2272931d8b@suse.cz>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed 14-08-19 14:49:18, Vlastimil Babka wrote:
> On 8/9/19 8:26 PM, Yang Shi wrote:
> > Here the new counter is introduced for patch 2/2 to account deferred 
> > split THPs into available memory since NR_ANON_THPS may contain 
> > non-deferred split THPs.
> > 
> > I could use an internal counter for deferred split THPs, but if it is 
> > accounted by mod_node_page_state, why not just show it in /proc/meminfo? 
> 
> The answer to "Why not" is that it becomes part of userspace API (btw this
> patchset should have CC'd linux-api@ - please do for further iterations) and
> even if the implementation detail of deferred splitting might change in the
> future, we'll basically have to keep the counter (even with 0 value) in
> /proc/meminfo forever.
> 
> Also, quite recently we have added the following counter:
> 
> KReclaimable: Kernel allocations that the kernel will attempt to reclaim
>               under memory pressure. Includes SReclaimable (below), and other
>               direct allocations with a shrinker.
> 
> Although THP allocations are not exactly "kernel allocations", once they are
> unmapped, they are in fact kernel-only, so IMHO it wouldn't be a big stretch to
> add the lazy THP pages there?

That would indeed fit in much better than a dedicated counter.
-- 
Michal Hocko
SUSE Labs

