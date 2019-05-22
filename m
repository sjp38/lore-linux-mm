Return-Path: <SRS0=Hl4p=TW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_NEOMUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 33211C282DD
	for <linux-mm@archiver.kernel.org>; Wed, 22 May 2019 15:22:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E8DF22173C
	for <linux-mm@archiver.kernel.org>; Wed, 22 May 2019 15:22:56 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=shutemov-name.20150623.gappssmtp.com header.i=@shutemov-name.20150623.gappssmtp.com header.b="GcX1w0fw"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E8DF22173C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=shutemov.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6595D6B0006; Wed, 22 May 2019 11:22:56 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 60A086B0008; Wed, 22 May 2019 11:22:56 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4D2A16B000A; Wed, 22 May 2019 11:22:56 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id F0D3D6B0006
	for <linux-mm@kvack.org>; Wed, 22 May 2019 11:22:55 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id r5so4090288edd.21
        for <linux-mm@kvack.org>; Wed, 22 May 2019 08:22:55 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=KgX/KrN1VzCWggUBQFeZMr9AktFTs8VZSbXFmnxyzvo=;
        b=EROAq86iOWbWMEgHfAbxQ7XzYTYl8CxQQgFionqJF2mh9iRjFZPbCYhGnza2Fwpi+7
         KcO0jQu24UzDJ5qsuze2Vw6HSN/rkdR4ntjbPxnavvdvHORQepYjOSg/KvYjAO7dJvof
         mB2Q34XVG3y2e9KiqD8JaVQnCJRujHNUand99Mz5sBu8j2vqa2gSbP+lOFOqup2/MJd2
         1Tsh9CFZeGWGouq32o5yQBNEpZz2MJAbUSze9ukVVXb5l186fYR3qg1J0ZA0myFdmzsV
         siak1xJLZuDalQ9zDx4IJwhXb+9OH0Rw3IpFsQY/5QtGrvH+w5zfOkZL0PuS4BHoZSma
         Hzng==
X-Gm-Message-State: APjAAAU+esNYhnm1ygh+1Pt+wqwJdIJRhxi6bZYBOWdBhCzcoeQYI08h
	x6waVUOScI3o6r9Tj1ql1N8NnoTsPiR9EuqLCCe8njEZ4q9ZRVhYWNtU6Tuc7beZ18qPerrIdOw
	0lYI+4gryVx1ROkcFz5tcP3KgwB4tqhjTameKN1dX2UH30yTAYLWiX1PCb3eWxyG+pg==
X-Received: by 2002:a17:906:61c3:: with SMTP id t3mr52632664ejl.273.1558538575559;
        Wed, 22 May 2019 08:22:55 -0700 (PDT)
X-Received: by 2002:a17:906:61c3:: with SMTP id t3mr52632575ejl.273.1558538574764;
        Wed, 22 May 2019 08:22:54 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558538574; cv=none;
        d=google.com; s=arc-20160816;
        b=DYrtt3EefOw2qO2BTVtFMTcuzKVPWTTv2z+FS/c22hjNvQPgw0lkyTnXt8Dc+wGFYI
         thq/qkDyHF2mW8bHU5ChLAq8S3j7ZQRRNjQd5TXkWYbcliJBsYo91wsM3pUCgtlC1Cq5
         1rZXw1l9uH1+7gRbLJot+tNUlWT1SmnpSujF08dtn2SCIHMGH8u1q4IR4cORiUO6GoIn
         AESb769eSmiMXwlsnlsBd5HuyP0qLFRB3VXr5k7sBQiHeITUHOcB2FDtio+Bb9BqOejk
         14Pq8Dd2ByIb7dRcSR8YgWU8Fuui8uCaS9/KHYNkLvC6nbN/a+qiTPvVAeqEP4C14THO
         vp7g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=KgX/KrN1VzCWggUBQFeZMr9AktFTs8VZSbXFmnxyzvo=;
        b=Xr08JQosLU5lvYaigGaBceOQid1Y4Z1dQFjZdf95m9FV/Q5/O0UZ9Ksf0nuRKD9VRU
         YNLA7+nCtmWJaDHZ3pw3EDCG/HdLVnmitH5TrYELC/WgLmeUA+VSt6EYZvAGtZGkf61U
         LWukr7jT9dDGBhB3AT6H2ch5Uebo4Bb9liZMwWpPBUuCnpiklf06R9OLO6bbkhA50+Ry
         M5KIuUWhAW4YA1cXSy3ZFHJpbRWhIRcvxtDHSL+SD5RUhlimnl+CNfXV1+I59yueTFhI
         uxAlGHCzsQmYts3UJkydz1tw0E1ob+6K5l8rXroEQtc3qqNkGdpGCh0VIjYUswMEWUma
         gpyg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=GcX1w0fw;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e50sor12659529ede.27.2019.05.22.08.22.54
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 22 May 2019 08:22:54 -0700 (PDT)
Received-SPF: neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=GcX1w0fw;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=shutemov-name.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=KgX/KrN1VzCWggUBQFeZMr9AktFTs8VZSbXFmnxyzvo=;
        b=GcX1w0fwJX3vDt7d78Vssz4hVA60VJ9U4c3rX8AHTSYZwQLeaXQVkinzSCIBDoZzTB
         rwjteMFRYCWTKo/ab71WxSj9adzyPMMkHiWBUYrwq1wlH5l9u1kkM9wUy2A5pDlg1ipU
         0NWe6dzLDpANP2IfKV2nDoRXiS/TfgK80rLRXC6Gg0WnwSp1HUw2TSiQmdBonr6HeVLi
         os009EzfGhQ0bhl4JAKB1Xh8I3kM+RJ6Zf4ycKBTBPmV2Vzzswaubzy6/tbn6IJqsM1U
         euI9QfMDbGy1rtN7YsZ+hzN9VvjWux2wM/nms0RxP+3k3fmvTRIuX/Bzv++iBVdECCOG
         7PsA==
X-Google-Smtp-Source: APXvYqzHZikuU8IDFA19PCIsr47Prlil2YLLyeJWuJV/knew+rRRWt8W5HBqMojWnsIXz6OdXkkrWw==
X-Received: by 2002:a05:6402:1256:: with SMTP id l22mr61992618edw.22.1558538574434;
        Wed, 22 May 2019 08:22:54 -0700 (PDT)
Received: from box.localdomain (mm-192-235-121-178.mgts.dynamic.pppoe.byfly.by. [178.121.235.192])
        by smtp.gmail.com with ESMTPSA id n8sm3245262ejk.45.2019.05.22.08.22.53
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 May 2019 08:22:53 -0700 (PDT)
Received: by box.localdomain (Postfix, from userid 1000)
	id 2576A103900; Wed, 22 May 2019 18:22:54 +0300 (+03)
Date: Wed, 22 May 2019 18:22:54 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
To: Kirill Tkhai <ktkhai@virtuozzo.com>
Cc: akpm@linux-foundation.org, dan.j.williams@intel.com, mhocko@suse.com,
	keith.busch@intel.com, kirill.shutemov@linux.intel.com,
	alexander.h.duyck@linux.intel.com, ira.weiny@intel.com,
	andreyknvl@google.com, arunks@codeaurora.org, vbabka@suse.cz,
	cl@linux.com, riel@surriel.com, keescook@chromium.org,
	hannes@cmpxchg.org, npiggin@gmail.com,
	mathieu.desnoyers@efficios.com, shakeelb@google.com, guro@fb.com,
	aarcange@redhat.com, hughd@google.com, jglisse@redhat.com,
	mgorman@techsingularity.net, daniel.m.jordan@oracle.com,
	jannh@google.com, kilobyte@angband.pl, linux-api@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org
Subject: Re: [PATCH v2 0/7] mm: process_vm_mmap() -- syscall for duplication
 a process mapping
Message-ID: <20190522152254.5cyxhjizuwuojlix@box>
References: <155836064844.2441.10911127801797083064.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <155836064844.2441.10911127801797083064.stgit@localhost.localdomain>
User-Agent: NeoMutt/20180716
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, May 20, 2019 at 05:00:01PM +0300, Kirill Tkhai wrote:
> This patchset adds a new syscall, which makes possible
> to clone a VMA from a process to current process.
> The syscall supplements the functionality provided
> by process_vm_writev() and process_vm_readv() syscalls,
> and it may be useful in many situation.

Kirill, could you explain how the change affects rmap and how it is safe.

My concern is that the patchset allows to map the same page multiple times
within one process or even map page allocated by child to the parrent.

It was not allowed before.

In the best case it makes reasoning about rmap substantially more difficult.

But I'm worry it will introduce hard-to-debug bugs, like described in
https://lwn.net/Articles/383162/.

Note, that is some cases we care about rmap walk order (see for instance
mremap() case). I'm not convinced that the feature will not break
something in the area.

-- 
 Kirill A. Shutemov

