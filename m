Return-Path: <SRS0=csuj=WE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 13DB9C433FF
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 16:08:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A4F2A20880
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 16:08:05 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A4F2A20880
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 11AF36B0006; Thu,  8 Aug 2019 12:08:05 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0CC096B0007; Thu,  8 Aug 2019 12:08:05 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id ED58E6B0008; Thu,  8 Aug 2019 12:08:04 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 990506B0006
	for <linux-mm@kvack.org>; Thu,  8 Aug 2019 12:08:04 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id f19so58525168edv.16
        for <linux-mm@kvack.org>; Thu, 08 Aug 2019 09:08:04 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to
         :references:cc:from:openpgp:autocrypt:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=j5Me+UNwXAeZ9roTI1NGq29xGu0mj0w2bC47GI1uU90=;
        b=Z+rLi3U79mAVu+FPb9naeg9ZBT60o0NK++6CWm5mq+5XyqN5eZ3qoOH0FggrinRZYz
         WqwfKUDA6Qi6ntIL75BGAeVY4nB9hWVL3cMc0PF13ElfA0eUSX3BD5RHknDB3GtPoj3c
         zPUUry8FOc0hu6AdYacIFnM7jN6KG8bkH5Y8jsYc7dYGK/sMomDZnYQBy1tJ4nU05Dn7
         WE5nXyf/3JW2ja+3g9V/DEe4zqIi8yHg3MTIiOr/gLnUWjO/CRPVpKfCei1ThPLpRu6K
         RV3zmddDMqKhfqrzFUeNEsK11srVyiJn5C5K5UzX13csjQ1hZsFQXdaClsXOszz4tioy
         Hp+A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Gm-Message-State: APjAAAUV1IDYbfkShZjZSXEZqWEuADU/ouW/7fGMZUThkkCEwpTdjIhQ
	K0ElQYPwBHmr+sR1XNBtBTQWZd5EAOttB6bFHT7k59HbkIU/YwrHpCn5LcBu85hHJKX+lklF+ox
	f9OJdvzIS8grO34BzsJ/yPXO/yvZ65jcp8cCIJUpw6GOkUD+eHraKMYpF2sP4KQCHWw==
X-Received: by 2002:aa7:d1da:: with SMTP id g26mr16867979edp.198.1565280484163;
        Thu, 08 Aug 2019 09:08:04 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxSjbjCrOSLGmB6M/9eENUe+FsiJ75T51U9TAMm5Lz8pWj2xz37QKPHrQfop9ZssoM7Vc0l
X-Received: by 2002:aa7:d1da:: with SMTP id g26mr16867853edp.198.1565280482964;
        Thu, 08 Aug 2019 09:08:02 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565280482; cv=none;
        d=google.com; s=arc-20160816;
        b=yHfloamgGlPsqLkqIN1uCr+N6HsfDzkxbLP0cDPG3ZZL7v7Tz9hyrj14RCAYrjUU6Z
         DE2nzM/brlgtXV0Ta/C/Y0FAn95xLa4/OgMY4IHjHiewot0q79qKEa1y9A9slnMNFwWw
         jecAiVSDOfWV4x3B+rH78ITCSmz7GYnJ2iVy3Ubj1DYo0WI9niGWdjLP0C1WJdZKBc1m
         MoWCPKI518yamxEkbVHw69IXiIBSo+u4+6RB9wJc8hAMQKoyeuiKsHZdkMfavJctH+nX
         ITEZja51Ml0uPxAoplAy7GNfsilgtZ4XJ592DdTvoIczmdIeFj61euav2fM/swF3jiVf
         YfwA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:autocrypt:openpgp:from:cc:references:to
         :subject;
        bh=j5Me+UNwXAeZ9roTI1NGq29xGu0mj0w2bC47GI1uU90=;
        b=Gy/wMSaN9ZPmaQYr0kHeLN7BrmsvvhUr92DjGKjin+Ymr/LwklwqBGaN32158LNOVD
         W8JPNV/G6rLFNKx4T8fZlEuqfnuzUEIaOIK8K3I5CZeMx3lmuxSO9W/rjAMHF8t6tRzi
         JSB25jb9YNAEN4Qni5zzo3CpsamrNjMQJy6SywwReCuTCaASTJUsEcBEnOSuKNPXHcPZ
         jP/wi4RlWbxOBSICDhUdFBm9b4H/G1+MYDP2LSxTXPlG5/+x1KqD4w9vb3MngRvIkLQd
         677XA4FYmU+MwuDugsKr929tqOeTc4AEaIZIepVJdeoj/DbaXEoRnsD9+KjuthWV4tbi
         kgsA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f13si36427396eda.21.2019.08.08.09.08.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Aug 2019 09:08:02 -0700 (PDT)
Received-SPF: pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 2E2E3AE91;
	Thu,  8 Aug 2019 16:08:02 +0000 (UTC)
Subject: Re: Transparent Huge pages hanging on 5.1.x/5.2.0 kernels?
To: David Zarzycki <dave@znu.io>, linux-mm@kvack.org
References: <E70C35A9-A757-4507-BAB1-D831A5746BBF@znu.io>
Cc: Mel Gorman <mgorman@techsingularity.net>
From: Vlastimil Babka <vbabka@suse.cz>
Openpgp: preference=signencrypt
Autocrypt: addr=vbabka@suse.cz; prefer-encrypt=mutual; keydata=
 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
Message-ID: <b440d2d6-2184-9538-4453-f1722b91e76c@suse.cz>
Date: Thu, 8 Aug 2019 18:08:01 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <E70C35A9-A757-4507-BAB1-D831A5746BBF@znu.io>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 7/15/19 12:32 PM, David Zarzycki wrote:
> Hello,
> 
> In the last few weeks, one of my build boxes started hanging at the end of a build with a zombie ld.lld process stuck in the kernel:
> 
> [97199.634549] CPU: 14 PID: 72214 Comm: ld.lld Kdump: loaded Not tainted 5.2.0-1.fc31.x86_64 #1
> [97199.634550] Hardware name: Supermicro SYS-5038K-i-NF9/K1SPE, BIOS 1.0b 04/13/2017
> [97199.634551] RIP: 0010:compact_zone+0x4d0/0xce0
> [97199.634553] Code: 41 c6 47 78 01 e9 52 fc ff ff 4c 89 f7 48 89 ea 4c 89 e6 e8 22 8e 02 00 49 89 c6 e9 d7 fd ff ff 8b 4c 24 10 4c 89 e2 4c 89 ee <4c> 89 ff e8 e8 e0 ff ff 49 89 c4 48 85 c0 0f 84 bd fe ff ff 45 8b
> [97199.634555] RSP: 0018:ffffac6a53c879c0 EFLAGS: 00000202
> [97199.634557] RAX: 0000000000000001 RBX: 000000000619f200 RCX: 000000000000000c
> [97199.634558] RDX: 000000000619f000 RSI: 000000000619ee20 RDI: ffff95f77ffc8330
> [97199.634559] RBP: ffff95fb7ffd4d00 R08: 0000000000000007 R09: 000000000619f000
> [97199.634561] R10: 0000000000000000 R11: 0000000000000003 R12: 000000000619f000
> [97199.634562] R13: 000000000619ee20 R14: fffffb58467b8000 R15: ffffac6a53c87a90
> [97199.634563] FS:  00007ffff10fd700(0000) GS:ffff95f5fb780000(0000) knlGS:0000000000000000
> [97199.634566] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> [97199.634567] CR2: 00007fff08001378 CR3: 00000054737f6000 CR4: 00000000001406e0
> [97199.634568] Call Trace:
> [97199.634569]  compact_zone_order+0xde/0x140

This was likely the same as
https://bugzilla.kernel.org/show_bug.cgi?id=204165
Fixed by patch https://marc.info/?l=linux-mm&m=156344023621776&w=2
Now commit 670105a25608 ("mm: compaction: avoid 100% CPU usage during
compaction when a task is killed")
It should hit your distro kernel at some point.

> [97199.634570]  try_to_compact_pages+0xcc/0x2a0
> [97199.634570]  __alloc_pages_direct_compact+0x8c/0x170
> [97199.634571]  __alloc_pages_slowpath+0x248/0xdf0
> [97199.634572]  ? get_vtime_delta+0x13/0xe0
> [97199.634573]  ? finish_task_switch+0x12f/0x2a0
> [97199.634574]  __alloc_pages_nodemask+0x2f2/0x340
> [97199.634575]  do_huge_pmd_anonymous_page+0x130/0x910
> [97199.634576]  __handle_mm_fault+0xfd7/0x1ac0
> [97199.634577]  handle_mm_fault+0xc4/0x1f0
> [97199.634577]  do_user_addr_fault+0x1f6/0x450
> [97199.634578]  do_page_fault+0x33/0x120
> [97199.634579]  ? page_fault+0x8/0x30
> [97199.634580]  page_fault+0x1e/0x30
> 
> This bug seems to go away if I comment out the following lines from my boot script:
> 
> # echo always > /sys/kernel/mm/transparent_hugepage/enabled
> # echo always > /sys/kernel/mm/transparent_hugepage/defrag
> 
> What can I do to debug this further?
> 
> Dave
> 

