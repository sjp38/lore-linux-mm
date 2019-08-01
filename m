Return-Path: <SRS0=cJsh=V5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.7 required=3.0 tests=FREEMAIL_FORGED_FROMDOMAIN,
	FREEMAIL_FROM,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3D3ACC32751
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 03:16:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D98CF214DA
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 03:16:47 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D98CF214DA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=sina.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7DE918E0005; Wed, 31 Jul 2019 23:16:47 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 790088E0001; Wed, 31 Jul 2019 23:16:47 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 67F878E0005; Wed, 31 Jul 2019 23:16:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 31EDA8E0001
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 23:16:47 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id z1so44667345pfb.7
        for <linux-mm@kvack.org>; Wed, 31 Jul 2019 20:16:47 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-language:sender:precedence:list-id:archived-at:list-archive
         :list-post:content-transfer-encoding;
        bh=xCgJQgMTqjWOvoEVRK/I7Bd3sxY8Qudbi1mCECJGhX8=;
        b=n6cN5lcihZlO+ejtKCmTIz+g+lQLZB5/GsLMLVLAMQumz9dOjIuxzn8vyK4pc0E3lD
         +TASHCY85w5180DlLGwZXmcl1t+YgERQ/wlTOMDGNgmb5Mflv+gDTqb0rjbWZ5AxxIr4
         FDfgSiKaYUA0y/mTzwoK0hTvvOjIu/UQEK5pZwEloPHDGTLuaJFsrVJTOkYOzwf2+Dno
         37KUs+pnxqEfs1w2YTi69Bn97kke3LrECdF0lmUqwJfHntqCrIL2bylJhDRp8MLsZCsO
         o3ZUtchSrXozvSES0SKou0TzmWzgxpTb2LcN9z7GtX3Q7TrhOc6QbnT9Vu5nII5XphE4
         ytdw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of hdanton@sina.com designates 202.108.3.163 as permitted sender) smtp.mailfrom=hdanton@sina.com
X-Gm-Message-State: APjAAAX9WEf9E3yAYMEi6IMq8AcJnm0ayb1gh4nDRDBvx3J5hko4BhAU
	r4NX7cyjBrznH82YPxNuIaJRMMa5YvwK/koJ9bAq0hdYmZpjUN2ZHCTsB/zMpSd1FUcJWdo9KU8
	GWjIyYgSyzhJacRh4L2LQ0ShG2lmJfF4sEyzWs2l/QbvX68Lw8XStbAibHBR5iaZ47Q==
X-Received: by 2002:a63:5945:: with SMTP id j5mr116148297pgm.452.1564629406787;
        Wed, 31 Jul 2019 20:16:46 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxaB+hDPw0YgLrfW2FEhJDD3OGpPP8uC0OuzK41+ODYtCTx+3BFxwDWE8nxplxuqSeQylJ5
X-Received: by 2002:a63:5945:: with SMTP id j5mr116148258pgm.452.1564629405983;
        Wed, 31 Jul 2019 20:16:45 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564629405; cv=none;
        d=google.com; s=arc-20160816;
        b=EMqoN6wmnxh3R3uiKZ+vSu7NgnTjgrczE5QO8cSqFrpNMYNthVkewjZCpsoLVEjUsX
         OoBgOaSMNvfMH8BRJJTi5iGw4zcmQcLovg+0tvVTIdg1el66E9hlVVr8XCXiw6U5R8Xw
         3e5/fZ9KRGs1qvgyRgtdORMsCFK/bOxplMg4tpJMHsxvrBFVnLhSbqw2uIsIlUV/XKCM
         uJ3RiIARdPOIVSLpx9iRVOud32fhbI+c3s8zaE1GbAtuI5wzjvdl0Izf40+pI+z115yR
         cI36+VRQvIpv02rZ5dOMg2lwX9yQq5rgtoRjGCmcg5mTONpA3LjxmYriR09q+cjoMPkb
         W6dg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:list-post:list-archive:archived-at
         :list-id:precedence:sender:content-language:mime-version:references
         :in-reply-to:message-id:date:subject:cc:to:from;
        bh=xCgJQgMTqjWOvoEVRK/I7Bd3sxY8Qudbi1mCECJGhX8=;
        b=BE17mciCVJ8gqUNxtshyrNLCTBVIpy9MuVD1OyHjwgBfacMdseiknhaDWiiJ88Pffy
         RFy2qozgwS+O3JpTZlXVWZiVMWV0ss7xue+FyMTPCTU5ROT4uZYH2EjCGBYjDUnVNQkz
         Vt5cqQ2VdNgE2yOYyOBAmMkdfEgvBpwwYvAATbaAMRBmpu2Z1dntXaHZeHId+khtKRDp
         D2qhcsJTaAINREIqR+nrSgdEaXe9meqvURhvxIcwreNzhMQzpuzjYqoZewHvpGO1EXQM
         d8oBSiAvoUqPNXoIbITpb+g2oK9r9D50eJPT5P4teGv0HxufZMFSQiFJYKvPeyicDW9L
         cq1A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of hdanton@sina.com designates 202.108.3.163 as permitted sender) smtp.mailfrom=hdanton@sina.com
Received: from mail3-163.sinamail.sina.com.cn (mail3-163.sinamail.sina.com.cn. [202.108.3.163])
        by mx.google.com with SMTP id m22si33654294pgh.190.2019.07.31.20.16.45
        for <linux-mm@kvack.org>;
        Wed, 31 Jul 2019 20:16:45 -0700 (PDT)
Received-SPF: pass (google.com: domain of hdanton@sina.com designates 202.108.3.163 as permitted sender) client-ip=202.108.3.163;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of hdanton@sina.com designates 202.108.3.163 as permitted sender) smtp.mailfrom=hdanton@sina.com
Received: from unknown (HELO localhost.localdomain)([222.131.77.31])
	by sina.com with ESMTP
	id 5D42599A00006103; Thu, 1 Aug 2019 11:16:44 +0800 (CST)
X-Sender: hdanton@sina.com
X-Auth-ID: hdanton@sina.com
X-SMAIL-MID: 34768630411146
From: Hillf Danton <hdanton@sina.com>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Mel Gorman <mgorman@suse.de>,
	Mike Kravetz <mike.kravetz@oracle.com>,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	Michal Hocko <mhocko@kernel.org>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RFC PATCH 1/3] mm, reclaim: make should_continue_reclaim perform dryrun detection
Date: Thu,  1 Aug 2019 11:16:33 +0800
Message-Id: <295a37b1-8257-9b4a-b586-9a4990cc9d35@suse.cz>
In-Reply-To: <20190725080551.GB2708@suse.de>
References: <20190724175014.9935-1-mike.kravetz@oracle.com> <20190724175014.9935-2-mike.kravetz@oracle.com> <20190725080551.GB2708@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Language: en-US
List-ID: <linux-kernel.vger.kernel.org>
X-Mailing-List: linux-kernel@vger.kernel.org
Archived-At: <https://lore.kernel.org/lkml/295a37b1-8257-9b4a-b586-9a4990cc9d35@suse.cz/>
List-Archive: <https://lore.kernel.org/lkml/>
List-Post: <mailto:linux-kernel@vger.kernel.org>
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190801031633.Y4GW2YtXQnnb-WbjqL8PxDroUmId5El6AOJE4bK5iso@z>


On Wed, 31 Jul 2019 13:08:44 +0200 Vlastimil Babka wrote:
> 
> I agree this is an improvement overall, but perhaps the patch does too
> many things at once. The reshuffle is one thing and makes sense. The
> change of the last return condition could perhaps be separate. Also
> AFAICS the ultimate result is that when nr_reclaimed == 0, the function
> will now always return false. Which makes the initial test for
> __GFP_RETRY_MAYFAIL and the comments there misleading. There will no
> longer be a full LRU scan guaranteed - as long as the scanned LRU chunk
> yields no reclaimed page, we abort.
> 
Thanks Vlastimil.

We can drop the test for __GFP_RETRY_MAYFAIL imo after observing no
regression produced by the reshuffle combined with dryrun detection
for reasons that
1) such a full lru scan is too expensive a cost for kswapd to pay for
balancing a node. The kthread you see drops the costly order when
appropriate. Which makes the helper in question false.

2) it has been a while otoh that reclaimers play game with neither
the costly order nor __GFP_RETRY_MAYFAIL taken into account, see
commit 2bb0f34fe3c1 ("mm: vmscan: do not iterate all mem cgroups for
global direct reclaim") for instance.

Hillf

