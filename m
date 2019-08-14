Return-Path: <SRS0=g7KO=WK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 72A61C32753
	for <linux-mm@archiver.kernel.org>; Wed, 14 Aug 2019 12:49:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 430092083B
	for <linux-mm@archiver.kernel.org>; Wed, 14 Aug 2019 12:49:22 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 430092083B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D26C46B0003; Wed, 14 Aug 2019 08:49:21 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CD6D56B0005; Wed, 14 Aug 2019 08:49:21 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BEB3A6B0007; Wed, 14 Aug 2019 08:49:21 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0137.hostedemail.com [216.40.44.137])
	by kanga.kvack.org (Postfix) with ESMTP id 98C606B0003
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 08:49:21 -0400 (EDT)
Received: from smtpin03.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id 2B0EE180AD7C1
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 12:49:21 +0000 (UTC)
X-FDA: 75821014122.03.act85_8bc92e3de7518
X-HE-Tag: act85_8bc92e3de7518
X-Filterd-Recvd-Size: 2663
Received: from mx1.suse.de (mx2.suse.de [195.135.220.15])
	by imf02.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 12:49:20 +0000 (UTC)
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id EAC0FAEE9;
	Wed, 14 Aug 2019 12:49:18 +0000 (UTC)
Subject: Re: [RESEND PATCH 1/2 -mm] mm: account lazy free pages separately
To: Yang Shi <yang.shi@linux.alibaba.com>, Michal Hocko <mhocko@kernel.org>
Cc: kirill.shutemov@linux.intel.com, hannes@cmpxchg.org, rientjes@google.com,
 akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org,
 Linux API <linux-api@vger.kernel.org>
References: <1565308665-24747-1-git-send-email-yang.shi@linux.alibaba.com>
 <20190809083216.GM18351@dhcp22.suse.cz>
 <1a3c4185-c7ab-8d6f-8191-77dce02025a7@linux.alibaba.com>
 <20190809180238.GS18351@dhcp22.suse.cz>
 <79c90f6b-fcac-02e1-015a-0eaa4eafdf7d@linux.alibaba.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <564a0860-94f1-6301-5527-5c2272931d8b@suse.cz>
Date: Wed, 14 Aug 2019 14:49:18 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <79c90f6b-fcac-02e1-015a-0eaa4eafdf7d@linux.alibaba.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 8/9/19 8:26 PM, Yang Shi wrote:
> Here the new counter is introduced for patch 2/2 to account deferred 
> split THPs into available memory since NR_ANON_THPS may contain 
> non-deferred split THPs.
> 
> I could use an internal counter for deferred split THPs, but if it is 
> accounted by mod_node_page_state, why not just show it in /proc/meminfo? 

The answer to "Why not" is that it becomes part of userspace API (btw this
patchset should have CC'd linux-api@ - please do for further iterations) and
even if the implementation detail of deferred splitting might change in the
future, we'll basically have to keep the counter (even with 0 value) in
/proc/meminfo forever.

Also, quite recently we have added the following counter:

KReclaimable: Kernel allocations that the kernel will attempt to reclaim
              under memory pressure. Includes SReclaimable (below), and other
              direct allocations with a shrinker.

Although THP allocations are not exactly "kernel allocations", once they are
unmapped, they are in fact kernel-only, so IMHO it wouldn't be a big stretch to
add the lazy THP pages there?

> Or we fix NR_ANON_THPS and show deferred split THPs in /proc/meminfo?
> 
>>
> 


