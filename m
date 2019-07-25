Return-Path: <SRS0=Q21e=VW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 85141C7618B
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 08:13:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 555FE22BED
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 08:13:56 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 555FE22BED
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 05F1A8E004E; Thu, 25 Jul 2019 04:13:56 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 010198E0031; Thu, 25 Jul 2019 04:13:55 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E68038E004E; Thu, 25 Jul 2019 04:13:55 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 9936C8E0031
	for <linux-mm@kvack.org>; Thu, 25 Jul 2019 04:13:55 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id c31so31703068ede.5
        for <linux-mm@kvack.org>; Thu, 25 Jul 2019 01:13:55 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=RwOcOzXLBtZq3njF2VXBM9I9nWlXgCxkEZXNdst/hWM=;
        b=CHD59EvAHdHifmiAiN/rFzzCeH+CzecRvLAYFNFlcvy30/CXPk5I5EoKBvgyr6eRVF
         UNodSQ3rGEawiUgpI82uz+NXOA+5O0XDhSvphTqBN7HK1GdogTVcpyIKZymyU/fvIDga
         e3Q7bIFI3rBRvsfl+2BgqG81Wg2iUAHo+hC1gKODQCrdIqCNmPQY4gODGqQvSo1RyKtZ
         ARZrKQp0cXKyg59pBoE8UMPCBs/i/+UhfbJ0OAqfhRet5MK4YRcqF1e5PolHTmJIfy0s
         +66Kr78WUZxrHQHJmFXjV5CwQp8N1HLRXHmpu5PimpH+3uwKCgAus112Q/JgrGSCPeNC
         ScEg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mgorman@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=mgorman@suse.de
X-Gm-Message-State: APjAAAXU/ldZK5HdwyVYEI5KHAzvu9Aq3YCCTEZV6KiVSMMM/FFyCjuo
	6kOGpsZqtCq0Y7pX9Ct41VXT3b6jPx707VT9DAbbSh419FxSJnHljaAE+xmQeFZbFbgungVypm0
	fy/DYPAjj+ZddAvPgM9AZmKQuh0K/E9ynQQZfcGneBAliXyPpgItQonpEPfYt3Pns/Q==
X-Received: by 2002:a50:eb8f:: with SMTP id y15mr75918911edr.31.1564042435199;
        Thu, 25 Jul 2019 01:13:55 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwCiDZY0yX9f0KTjQE1hVz1gEKAAZFNqZRN5dNamanq+j1bv8uNzCwzK7L0dk9+4ViCPyM3
X-Received: by 2002:a50:eb8f:: with SMTP id y15mr75918877edr.31.1564042434585;
        Thu, 25 Jul 2019 01:13:54 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564042434; cv=none;
        d=google.com; s=arc-20160816;
        b=k+CmKkMGFncZ+43ecRtnjDCpepX0GzMSrE3qBM5PRCsKf/0qzvVsFJtLoqRt+ok+5N
         ErLBeYnZX4dmD+Wxf/eR164zbD/EGboKL9aU3o8NmO0q3J75xW4d5hSBejhB1n7T/gU4
         SzRuHK9AV/AS98ne/mfZhuBIaBqK8PbnT+zp8oHYvmVhZGoZshudmxXsIrz4gsoaZfwN
         vIpZ7vZqNK3FI2tg7KLprBVmTr8i1qTKUBqK4Kln88To+3OBMK99qmEwoQh+/2ubyIlc
         ygjic0tBx/N730j+P7bumqkTDljG/GJm39YRQ566H/yKNI33568ZWb4myqfiDlAjnvcg
         T8dA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=RwOcOzXLBtZq3njF2VXBM9I9nWlXgCxkEZXNdst/hWM=;
        b=bToeMloVUw6/LCxQ12HZgwxw5EWTTkNW4ww27h2nyuXyikFlb6oBjfloo/w0LsgJ8w
         2EsINQ/MMTwndzINdzeaHmaNla6XoYGPrYMqyPCMTdfdgtg3VMPx+O8dUbZ2yoBr5VWC
         HsnKcsLj9TvghuXNWjZ1uoA5IjbkjVJqK6N2M6jKpyhPCOVJaZTTkw+DL/IfAlT0zMcN
         n7KBUTYP1jF3TJ978l5GlMNapQl06ivNrkhgHG/t9EcLfC2fRU14ssbjaSMCgFufLid6
         SMYYj+60CXxnvNA7BGpLehxk2f9/a3cyllOeHWFxO2jfH62DlSfxM/SzX4eTtyDKuqCy
         ds/g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mgorman@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=mgorman@suse.de
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id dx4si9379390ejb.328.2019.07.25.01.13.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Jul 2019 01:13:54 -0700 (PDT)
Received-SPF: pass (google.com: domain of mgorman@suse.de designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mgorman@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=mgorman@suse.de
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 1DB8EAD73;
	Thu, 25 Jul 2019 08:13:54 +0000 (UTC)
Date: Thu, 25 Jul 2019 09:13:50 +0100
From: Mel Gorman <mgorman@suse.de>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	Hillf Danton <hdanton@sina.com>, Michal Hocko <mhocko@kernel.org>,
	Vlastimil Babka <vbabka@suse.cz>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RFC PATCH 3/3] hugetlbfs: don't retry when pool page
 allocations start to fail
Message-ID: <20190725081350.GD2708@suse.de>
References: <20190724175014.9935-1-mike.kravetz@oracle.com>
 <20190724175014.9935-4-mike.kravetz@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20190724175014.9935-4-mike.kravetz@oracle.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jul 24, 2019 at 10:50:14AM -0700, Mike Kravetz wrote:
> When allocating hugetlbfs pool pages via /proc/sys/vm/nr_hugepages,
> the pages will be interleaved between all nodes of the system.  If
> nodes are not equal, it is quite possible for one node to fill up
> before the others.  When this happens, the code still attempts to
> allocate pages from the full node.  This results in calls to direct
> reclaim and compaction which slow things down considerably.
> 
> When allocating pool pages, note the state of the previous allocation
> for each node.  If previous allocation failed, do not use the
> aggressive retry algorithm on successive attempts.  The allocation
> will still succeed if there is memory available, but it will not try
> as hard to free up memory.
> 
> Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>

set_max_huge_pages can fail the NODEMASK_ALLOC() alloc which you handle
*but* in the event of an allocation failure this bug can silently recur.
An informational message might be justified in that case in case the
stall should recur with no hint as to why. Technically passing NULL into
NODEMASK_FREE is also safe as kfree (if used for that kernel config) can
handle freeing of a NULL pointer. However, that is cosmetic more than
anything. Whether you decide to change either or not;

Acked-by: Mel Gorman <mgorman@suse.de>

-- 
Mel Gorman
SUSE Labs

