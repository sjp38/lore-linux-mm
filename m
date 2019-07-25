Return-Path: <SRS0=Q21e=VW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CBF2BC7618B
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 08:06:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8D2742238C
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 08:06:35 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8D2742238C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 34A8B8E004D; Thu, 25 Jul 2019 04:06:35 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2FB208E0031; Thu, 25 Jul 2019 04:06:35 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 211518E004D; Thu, 25 Jul 2019 04:06:35 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id DFBD18E0031
	for <linux-mm@kvack.org>; Thu, 25 Jul 2019 04:06:34 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id b3so31626131edd.22
        for <linux-mm@kvack.org>; Thu, 25 Jul 2019 01:06:34 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=WlOPa1dDyfNWlzX445S8qqqADX6oT/o0Pu+2FZXURZw=;
        b=SL/TqpmVx6XJ7JDukLp/ICLJTXxVNpeDgTOOHbT7GXuHSV80TSSYOGCzc8PXK4iBxu
         FiVrE/VrN+uyFFOLR37K3timFWUD7DlETpf3JKl6kTDH6CrWkzYrnNrSvEtG61hquIRu
         r7Qw+Ph2BCwPkGeRmTIQkUit3DZhCGyx4rPhpvQpqyWaHsJDqjbUuFWYSGcR8BJh3yqM
         f8GzLJO17ciFl1nw0VhhjsOUZp0O//NGaJ2viFxP6JKemXwvUEQdg1BaeyRQ9AiOfOaI
         PJh2isAgNolMsnaUKYZxV7EAIBsLOPgPdNumVLked1Q5jw2SAdIoq9USZ6Gq/hVOxXiQ
         QDcw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mgorman@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=mgorman@suse.de
X-Gm-Message-State: APjAAAV30uvRXp7rZnYUrE7/BJgRnBZvvdaTuht4wuBZbTTKS8k8mnpZ
	9SOo1Fu5qERxPVZzK5zgiX+WqFHtrmdMApBFayfE8TbO7WTtjYXYTTpeqr+qu0VDCsqQIZaNufg
	VP72JfnTViUGMME//BCtPJVhzcGOPcHCkUCTwZAfYy7YUBRBPJ9n3xzh24/yiuJZknQ==
X-Received: by 2002:a50:9846:: with SMTP id h6mr74063309edb.263.1564041994504;
        Thu, 25 Jul 2019 01:06:34 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzMxygspAFvXk2G2zc7mgy+htiIjcyB2Mx0j1/Rx44O4tieMjKuh57b0InKbMlFmfwxzeZO
X-Received: by 2002:a50:9846:: with SMTP id h6mr74063270edb.263.1564041993936;
        Thu, 25 Jul 2019 01:06:33 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564041993; cv=none;
        d=google.com; s=arc-20160816;
        b=d/dl6TI9V4FfGqMax7JH4OpjkYiAupphO0FjJFwscN/s4hFmSjL4E7q4DFvgqE39gX
         576v4Sqbx1jfNkMD0Zb4z1EI+8W7TNcGSLrxk4xaXZwvTcikVjJUtiTpp9SdZkr+ZEfe
         rgLocWKLQeIDh4aBpv1xPkvZM7QK7sVBymlvhG1FzU2Fa6qlHXo4GRdszNEzFC5tGABZ
         thNbE1XeLu/+ktAjt+iU5hnFTLlqbc9G7Ql+H20K0hk/+rHlZrvDuFeTxzF/DVH7HW4+
         tGUEvGsQbHPff0n9iNQ6MvCM4Jelh/zBQRssm/mpm+ifHU1AjKHgXmECVKdMqGkYwunD
         235g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=WlOPa1dDyfNWlzX445S8qqqADX6oT/o0Pu+2FZXURZw=;
        b=0iijW3IAbyIYs5ZIOel4RC0oMB+tmgEOG7360KhGpe8TWY3Xrtp4H0BtmFK+EZjBi3
         uZwwzyvtqA4TMnSj6kzKV4GvGdXLNqVC6EGFrJyOa5LUMt+pXjNmNp0mnPRfiz5GqlOU
         LERdkmWl6X4BMGLgt4iWKBNC7OJkkDLwzzYI+GCPtOHGmZ6u6iNgqaxUGcR4ugM/xMg5
         WCX2zCXkHZ2VmUsvGox1Nn1bohychFweOyH8QfxN8LNNorjV+yGby/nxTuHHXD77efCe
         eimWWSIWdklU+gwsahn552GsxztwJz1Bd3XRfKj12hffB37rvPoawqVXsnuCPM7cxJ15
         ICDg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mgorman@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=mgorman@suse.de
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i44si10645279ede.407.2019.07.25.01.06.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Jul 2019 01:06:33 -0700 (PDT)
Received-SPF: pass (google.com: domain of mgorman@suse.de designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mgorman@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=mgorman@suse.de
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 8D211AFF4;
	Thu, 25 Jul 2019 08:06:33 +0000 (UTC)
Date: Thu, 25 Jul 2019 09:06:31 +0100
From: Mel Gorman <mgorman@suse.de>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	Hillf Danton <hdanton@sina.com>, Michal Hocko <mhocko@kernel.org>,
	Vlastimil Babka <vbabka@suse.cz>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RFC PATCH 2/3] mm, compaction: use MIN_COMPACT_COSTLY_PRIORITY
 everywhere for costly orders
Message-ID: <20190725080631.GC2708@suse.de>
References: <20190724175014.9935-1-mike.kravetz@oracle.com>
 <20190724175014.9935-3-mike.kravetz@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20190724175014.9935-3-mike.kravetz@oracle.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jul 24, 2019 at 10:50:13AM -0700, Mike Kravetz wrote:
> For PAGE_ALLOC_COSTLY_ORDER allocations, MIN_COMPACT_COSTLY_PRIORITY is
> minimum (highest priority).  Other places in the compaction code key off
> of MIN_COMPACT_PRIORITY.  Costly order allocations will never get to
> MIN_COMPACT_PRIORITY.  Therefore, some conditions will never be met for
> costly order allocations.
> 
> This was observed when hugetlb allocations could stall for minutes or
> hours when should_compact_retry() would return true more often then it
> should.  Specifically, this was in the case where compact_result was
> COMPACT_DEFERRED and COMPACT_PARTIAL_SKIPPED and no progress was being
> made.
> 
> Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>

Acked-by: Mel Gorman <mgorman@suse.de>

-- 
Mel Gorman
SUSE Labs

