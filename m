Return-Path: <SRS0=nlaJ=SI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 53E93C282DA
	for <linux-mm@archiver.kernel.org>; Sat,  6 Apr 2019 17:27:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CD9B8213A2
	for <linux-mm@archiver.kernel.org>; Sat,  6 Apr 2019 17:27:05 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CD9B8213A2
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3D6BA6B000C; Sat,  6 Apr 2019 13:27:03 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3861D6B000D; Sat,  6 Apr 2019 13:27:03 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 29BA46B000E; Sat,  6 Apr 2019 13:27:03 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 066346B000C
	for <linux-mm@kvack.org>; Sat,  6 Apr 2019 13:27:03 -0400 (EDT)
Received: by mail-qk1-f200.google.com with SMTP id w124so7786676qkb.12
        for <linux-mm@kvack.org>; Sat, 06 Apr 2019 10:27:03 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:in-reply-to:message-id:references:user-agent
         :mime-version;
        bh=0bcn3j5pUCo9Sy9DFVSf4l3NHyvwHGVmtDGK5DL4F0U=;
        b=lcx+tW1HJmhrs6WE4sTmwzydUkR/UKWGg6yCfBKZjoPtFZj7ZpE3rIRPkSVNun1VYj
         nF0J5kfhxbJZeQE0vvAMIfL3cb1P12T/8SY0vasCiUrw8ybcLTpy6zpQRRVgD03Vy6CO
         iTVMq750LFjwMOgpYSMb/Q8Vs/EYgXadn5eDAp/N64WCTUZh4UUrEISNNQcuX7TqyRaN
         YvqDscMrtTWVJ8nRSdJIGEZrwctMPeKqbVobmb81UWQKO58K1zsDtb3vvAS/GaidVHqI
         oKPdT5b3k4BW6FMWddtZ4qY/Xjcej6gLcfXG5/XsLueiYnQJbGWJvSfbATmcNpZ8oqQU
         IxUQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mpatocka@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=mpatocka@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAU+qFmQhaAj7fPJY6wOXCYPp+AelGUasedho6mEPrXOXnoWU7eq
	aOWn8Hh9q6hjUd0y1FbwkJwa3EVhwneR8bNDnjw9eB94fD14PY49fC3hvXlitW/OuWZGWzi/9hD
	B90u1L1kPlEieaOvUoQDCR9vcbGVoMOU9NBFFc9cDSzNUpjK/OsVOW5RcyeMuuhX0pA==
X-Received: by 2002:ac8:2ed7:: with SMTP id i23mr17650847qta.326.1554571622710;
        Sat, 06 Apr 2019 10:27:02 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxBjnTVfBw9FHNg3C+Q+oTdGJxkIhic3QIhhxIE0DNVpdsaG2MkZFV319bOvywOgSYTpo4h
X-Received: by 2002:ac8:2ed7:: with SMTP id i23mr17650820qta.326.1554571622026;
        Sat, 06 Apr 2019 10:27:02 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554571622; cv=none;
        d=google.com; s=arc-20160816;
        b=txfJ1b/Vi5oM1ndyG9+pGSpzLKtzw7PA0YuBYpxUH+CQG6s9MvmOwLUzHpKrAgyvJX
         DaML1Z0UvRwGbEFVjyC3crqhV4rfhovxO/MBDQ7UFjkgjrzRWBQRdmr6XlGMtJX3dgln
         RxCfWEjxqbHwsgCRhoqpvn9uWubZb5ZC98oUXtVK8KMlBYif0ckR6MtjQobwd5nveNHT
         y3Izw/MJGt9bn1pF52uXiQwQHYo9nX5zFCyFXIOeY9Pc14oCYCHlChnnuLGnHbxxSs3K
         8scnkkSShx8LWh1jptecEhTBD8ANQFF79LziBA2O+K/crRAHDFlke53St72CHB4mCbnX
         1lQg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:references:message-id:in-reply-to:subject
         :cc:to:from:date;
        bh=0bcn3j5pUCo9Sy9DFVSf4l3NHyvwHGVmtDGK5DL4F0U=;
        b=EAlcA5rEE5BMsqzhHmXC4eWNhkRW3KtTAZ4d1BoZXTZRsfSqGahZfb28VHrmMXiAOU
         KR0gDg1l56BbNXik2wTj/p5/otDSLveUNeoB99eWoUBwI2KmlqlM6xB6SEjVXoAtDOKO
         ePW7/tDfCVvRm4m9F+8MjfqZdNPoHKn3pN8kEDUWXqYJA74mJUbm2MY3205MgTbf3PU2
         8iCMb0S1jgJq5ARgE0iOgYTH43ajzCxuOVBEJ1sfS0W9kXCcLxfvq4HznQ5k9wj9elYz
         qUl0pNuzoUv7NeQUvhFSdnZ4pD4GEP4NsQgnkrFezVa97NUWYpnVehl4S7dRDJFohNUZ
         RUFA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mpatocka@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=mpatocka@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id h5si5452542qkj.3.2019.04.06.10.27.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 06 Apr 2019 10:27:02 -0700 (PDT)
Received-SPF: pass (google.com: domain of mpatocka@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mpatocka@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=mpatocka@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id EE864356DB;
	Sat,  6 Apr 2019 17:27:00 +0000 (UTC)
Received: from file01.intranet.prod.int.rdu2.redhat.com (file01.intranet.prod.int.rdu2.redhat.com [10.11.5.7])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 57D2E17F33;
	Sat,  6 Apr 2019 17:27:00 +0000 (UTC)
Received: from file01.intranet.prod.int.rdu2.redhat.com (localhost [127.0.0.1])
	by file01.intranet.prod.int.rdu2.redhat.com (8.14.4/8.14.4) with ESMTP id x36HQxHu002281;
	Sat, 6 Apr 2019 13:26:59 -0400
Received: from localhost (mpatocka@localhost)
	by file01.intranet.prod.int.rdu2.redhat.com (8.14.4/8.14.4/Submit) with ESMTP id x36HQvku002277;
	Sat, 6 Apr 2019 13:26:58 -0400
X-Authentication-Warning: file01.intranet.prod.int.rdu2.redhat.com: mpatocka owned process doing -bs
Date: Sat, 6 Apr 2019 13:26:57 -0400 (EDT)
From: Mikulas Patocka <mpatocka@redhat.com>
X-X-Sender: mpatocka@file01.intranet.prod.int.rdu2.redhat.com
To: Mel Gorman <mgorman@techsingularity.net>,
        Andrew Morton <akpm@linux-foundation.org>,
        Helge Deller <deller@gmx.de>,
        "James E.J. Bottomley" <James.Bottomley@HansenPartnership.com>,
        John David Anglin <dave.anglin@bell.net>, linux-parisc@vger.kernel.org,
        linux-mm@kvack.org
cc: Vlastimil Babka <vbabka@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>,
        Zi Yan <zi.yan@cs.rutgers.edu>
Subject: Re: Memory management broken by "mm: reclaim small amounts of memory
 when an external fragmentation event occurs"
In-Reply-To: <alpine.LRH.2.02.1904061042490.9597@file01.intranet.prod.int.rdu2.redhat.com>
Message-ID: <alpine.LRH.2.02.1904061325170.1666@file01.intranet.prod.int.rdu2.redhat.com>
References: <alpine.LRH.2.02.1904061042490.9597@file01.intranet.prod.int.rdu2.redhat.com>
User-Agent: Alpine 2.02 (LRH 1266 2009-07-14)
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.13
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.30]); Sat, 06 Apr 2019 17:27:01 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On Sat, 6 Apr 2019, Mikulas Patocka wrote:

> Hi
> 
> The patch 1c30844d2dfe272d58c8fc000960b835d13aa2ac ("mm: reclaim small 
> amounts of memory when an external fragmentation event occurs") breaks 
> memory management on parisc.
> 
> I have a parisc machine with 7GiB RAM, the chipset maps the physical 
> memory to three zones:
> 	0) Start 0x0000000000000000 End 0x000000003fffffff Size   1024 MB
> 	1) Start 0x0000000100000000 End 0x00000001bfdfffff Size   3070 MB
> 	2) Start 0x0000004040000000 End 0x00000040ffffffff Size   3072 MB
> (but it is not NUMA)
> 
> With the patch 1c30844d2, the kernel will incorrectly reclaim the first 
> zone when it fills up, ignoring the fact that there are two completely 
> free zones. Basiscally, it limits cache size to 1GiB.
> 
> For example, if I run:
> # dd if=/dev/sda of=/dev/null bs=1M count=2048
> 
> - with the proper kernel, there should be "Buffers - 2GiB" when this 
> command finishes. With the patch 1c30844d2, buffers will consume just 1GiB 
> or slightly more, because the kernel was incorrectly reclaiming them.
> 
> Mikulas

BTW, 3 years ago, there was exactly the same bug: 
https://marc.info/?l=linux-kernel&m=146472966215941&w=2

Mikulas

