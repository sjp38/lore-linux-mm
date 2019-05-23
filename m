Return-Path: <SRS0=On+J=TX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6E7E3C282E1
	for <linux-mm@archiver.kernel.org>; Thu, 23 May 2019 16:11:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EF58C217F9
	for <linux-mm@archiver.kernel.org>; Thu, 23 May 2019 16:11:52 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EF58C217F9
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=virtuozzo.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5F6336B028E; Thu, 23 May 2019 12:11:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 57F106B0290; Thu, 23 May 2019 12:11:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3FA6F6B0291; Thu, 23 May 2019 12:11:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f198.google.com (mail-lj1-f198.google.com [209.85.208.198])
	by kanga.kvack.org (Postfix) with ESMTP id CE8F96B028E
	for <linux-mm@kvack.org>; Thu, 23 May 2019 12:11:51 -0400 (EDT)
Received: by mail-lj1-f198.google.com with SMTP id y11so1405716ljc.20
        for <linux-mm@kvack.org>; Thu, 23 May 2019 09:11:51 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=qZZ4Nvb9HLCO0PR5z5e1D0aiEJagzg4FRl2eNJ9m6EE=;
        b=FZOiaef6xCegvUQIBFyBzpjyAj+c8QJLPykq3XuFLaolMZYnIsj4DRmP6yqBFdJI30
         ggCPono4R/xd8khzZwWyo8io1kGw79p789jmg7wDAf/Z2+iHTr/FTasDavZkFHcS3FgF
         6ovklOK/4e87kulYFdOu6lNYxzpbGHWm2keM9eqwsOkqprCTIuuZ3UNNmnUpHsflAqAK
         kFkZQRj16CSVBEq0qZ9nhFBQwpeBRLlzFGfJnQefM+WMiu88vC7o3uODZQWkwOOcutv+
         J0aua29ZsLJzNF49Ai4K2CvGtBjU2u8BS/1aPFGnuK7j4DHY4I8Bq/KExQV41XtTKrh0
         bwtg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
X-Gm-Message-State: APjAAAVfpv+Jm+u/d6fx/1wGE5Yno1iqH4sW/c772npMAO4oe7I8h1+p
	tXS9p2AMC9BPNJdQzLRwZERMkikRvEmOauk9uzrX4Ioifz73sampmavZrLGujNTB5ZhEWrLKbGx
	LLI827knd7yL68Cw+kMErIO1DAYSRIJi+1WQdheqj8CKtQNDViTMl8woRiYjLwGDB6g==
X-Received: by 2002:ac2:46f5:: with SMTP id q21mr1814364lfo.112.1558627911262;
        Thu, 23 May 2019 09:11:51 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw0F3CeGifS0098DMxKWXRK8sgUh3vwNffJiZ8da672UEzDsCCh2Ch/31MOE34b/EEdqDsy
X-Received: by 2002:ac2:46f5:: with SMTP id q21mr1814314lfo.112.1558627910031;
        Thu, 23 May 2019 09:11:50 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558627910; cv=none;
        d=google.com; s=arc-20160816;
        b=gDUdV8+1bWPevWKqRwuJPlGU9UmegLoDxBIFda9boIoC6Y9Og9dfs+KukIsi2FvnJs
         zYlZRE4wxVEG6nvh7ft0mN4k2XYonHmPRKOL06TnCobzFsUAM50FmcV2gLy40kckvmkf
         KCzv0+bOkYHioXmHsk6lTAmFNAdUWXlR/oB0c5Avo1+IjuXzAZZv3y0cVSmYLwTfNP3m
         pYCbNdzp+pnftiPbxQbYwPKGGDioVsCuuoGmPfXJ3b3vBH9aeso90hBPXjKaq86X466W
         W10FHwh/4Q0D3+0Ers8MDfHy2tFxLUzhf1iO14x2254kCg/c1qUUrwLzlN4lfWmiefre
         52BA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=qZZ4Nvb9HLCO0PR5z5e1D0aiEJagzg4FRl2eNJ9m6EE=;
        b=M8mFY3oamKK3oOaMyls0muzZHVBRKQ7Zcqdiv1xPCkC+6VHhNMDuzKE7SLTSm6IG9a
         KYxBKFlyWxfKSK8/FygdAT9kBYpSCHGLbnjZH0vgLfcUyKFW2IzHHk0k9sl9I/HIXsmo
         TXEC1nHbYwWQ1bD3DdnjVS/7TCmmHoFp+tRkFEN7HGEsjLEtzIqXK1/c8d2pa76YsKJN
         h5RsiMwszAPuN7NLre9F4dAGsJB6IrFtrfjUpchzGvDEsWzDue1jXY7hu9WLorxg3/T4
         h0iScm8YUUyo9FN9wXXzRappSACDHt5x5/Ii18oH9fbQ+id7iIt29fpAT6NmJTq6NrKp
         S1Tg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from relay.sw.ru (relay.sw.ru. [185.231.240.75])
        by mx.google.com with ESMTPS id s26si8247524ljs.90.2019.05.23.09.11.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 May 2019 09:11:50 -0700 (PDT)
Received-SPF: pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) client-ip=185.231.240.75;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from [172.16.25.169]
	by relay.sw.ru with esmtp (Exim 4.91)
	(envelope-from <ktkhai@virtuozzo.com>)
	id 1hTqJe-00034X-DO; Thu, 23 May 2019 19:11:38 +0300
Subject: Re: [PATCH v2 0/7] mm: process_vm_mmap() -- syscall for duplication a
 process mapping
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: akpm@linux-foundation.org, dan.j.williams@intel.com, mhocko@suse.com,
 keith.busch@intel.com, kirill.shutemov@linux.intel.com,
 alexander.h.duyck@linux.intel.com, ira.weiny@intel.com,
 andreyknvl@google.com, arunks@codeaurora.org, vbabka@suse.cz, cl@linux.com,
 riel@surriel.com, keescook@chromium.org, hannes@cmpxchg.org,
 npiggin@gmail.com, mathieu.desnoyers@efficios.com, shakeelb@google.com,
 guro@fb.com, aarcange@redhat.com, hughd@google.com, jglisse@redhat.com,
 mgorman@techsingularity.net, daniel.m.jordan@oracle.com, jannh@google.com,
 kilobyte@angband.pl, linux-api@vger.kernel.org,
 linux-kernel@vger.kernel.org, linux-mm@kvack.org
References: <155836064844.2441.10911127801797083064.stgit@localhost.localdomain>
 <20190522152254.5cyxhjizuwuojlix@box>
From: Kirill Tkhai <ktkhai@virtuozzo.com>
Message-ID: <4b0a2b23-abc7-fa0d-5e30-74741331e7e5@virtuozzo.com>
Date: Thu, 23 May 2019 19:11:37 +0300
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <20190522152254.5cyxhjizuwuojlix@box>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 22.05.2019 18:22, Kirill A. Shutemov wrote:
> On Mon, May 20, 2019 at 05:00:01PM +0300, Kirill Tkhai wrote:
>> This patchset adds a new syscall, which makes possible
>> to clone a VMA from a process to current process.
>> The syscall supplements the functionality provided
>> by process_vm_writev() and process_vm_readv() syscalls,
>> and it may be useful in many situation.
> 
> Kirill, could you explain how the change affects rmap and how it is safe.
> 
> My concern is that the patchset allows to map the same page multiple times
> within one process or even map page allocated by child to the parrent.
> 
> It was not allowed before.
>
> In the best case it makes reasoning about rmap substantially more difficult.

I don't think here is big impact from process relationships, because of
as it existed before, the main rule of VMA chaining is that VMA is younger
or older each other. For example, reusing of anon_vma in anon_vma_clone()
may be done either children or siblings. Also, it is possible reparenting
after some of processes dies; or splitting two branches of processes having
the same grand parent into two chains after the grand parent dies, so it looks
there should be many combinations already available.

Mapping of the same page multiple times is a different thing, and it was never
allowed for rmap.

Could you please say more specifically what looks suspicious for you and I'll
try to answer then? Otherwise, it's possible to write explanations as big as
a dissertation and to miss all answers to that is interested for you :)

> 
> But I'm worry it will introduce hard-to-debug bugs, like described in
> https://lwn.net/Articles/383162/.

I read the article, but there are a lot of messages in thread, I'm not sure,
that found the actual fix there. But it looks like one of the fixes may be
be usage of anon_vma->root in __page_set_anon_rmap().

> Note, that is some cases we care about rmap walk order (see for instance
> mremap() case). I'm not convinced that the feature will not break
> something in the area.

Yeah, thanks for pointing, I'll check this.

Kirill

