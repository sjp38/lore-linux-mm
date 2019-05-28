Return-Path: <SRS0=UfqE=T4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4E8DAC072B1
	for <linux-mm@archiver.kernel.org>; Tue, 28 May 2019 08:35:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 130D1208C3
	for <linux-mm@archiver.kernel.org>; Tue, 28 May 2019 08:35:07 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 130D1208C3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=virtuozzo.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B14D66B0272; Tue, 28 May 2019 04:35:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AC4E86B0273; Tue, 28 May 2019 04:35:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9DB886B0275; Tue, 28 May 2019 04:35:06 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lf1-f72.google.com (mail-lf1-f72.google.com [209.85.167.72])
	by kanga.kvack.org (Postfix) with ESMTP id 358CB6B0272
	for <linux-mm@kvack.org>; Tue, 28 May 2019 04:35:06 -0400 (EDT)
Received: by mail-lf1-f72.google.com with SMTP id 22so892819lft.2
        for <linux-mm@kvack.org>; Tue, 28 May 2019 01:35:06 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=Oz2Jtn7TLxujAbF5klBuEKjq+PJwIG6ezw5Z3IWQiEg=;
        b=OuRKGoNDbZu694IMyZZWI5FB8idPNPK4tDnLRnfO17Cf717f1KyYWcYIMoCJNmAJG4
         BSdIuW2jSWf/BGJjxLIjdbhkyRrzziDagYBS1a1ozdIcAlncEdLIO1fgQZ1lSIKqcVsN
         X8SmLhNP0dDPbm4Q3DQZ7Ft7A/BkUhSa8fKqmWDZEFogub+w7MghTHvwsKQS+kRtEtiD
         OsIjmJDYc1zZZGcr9g1jWtZhPj4J5Wv98c7Du4lVGU2HtWFZdDq6B+7qDkqmcTJUViSM
         DvCnn8n7V0SvpsMyUnmQYjUbW8u0Pqwzq4Aim0ZBOutsOVR31t6GW2gFAeSkoHxcqBkK
         5TjQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
X-Gm-Message-State: APjAAAWY1Kkh99cUnoc9O7kTcb/Y/wLpL2UWu1Sn1+/Z+RTn9fwWSQH/
	vsAVMYPlWXC2dbhCvKK1FEQ7/z4D/QWgSyOEltYNLIBeQnkNG8CPOfjXLJSrVSL9WN/2lf44x5H
	s1PcCd1sg6ClWN5Xvw1jbyLYaq0qRaoKUecYx7eNc6L9wDeTn2k+RR5fVgam6VsTaIw==
X-Received: by 2002:a2e:860a:: with SMTP id a10mr7610929lji.158.1559032505417;
        Tue, 28 May 2019 01:35:05 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxEQtNQKq55z4kFIK1Cky/7kvndozCWQBrjpS3XCkEPesHqroRZCwG6BcI4ANmn16tyWiD1
X-Received: by 2002:a2e:860a:: with SMTP id a10mr7610876lji.158.1559032504412;
        Tue, 28 May 2019 01:35:04 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559032504; cv=none;
        d=google.com; s=arc-20160816;
        b=mw0RlGQ1jFhlPTVKcCvrWcTr6yCvVKYKztm7eKvWfGaCasROKNv87KEIy3lS++usOq
         rzNmuQZdZUSj5Aw85LynKNCQyHmC83UiUm0QOhzYX1HDSAXgIZXURoUZ9C/lusXql4xE
         t8E2W1II4lBLD8EaJ3v/HVnfIJEv64h9xiBM1TWYNrm5K3xbw78SCmuUWoU5OPoxyUWG
         e19cIr2p3umT0TdT//y/3bZd53g9F92rKTY2Fd9KuNF5qP5EGv1Qhff9ZbconKnozPEe
         YaoFeym0f2RIOrmhiTT10tu0VrZk4VxbQxvAJWN6t+xdOlpDpBH7KCY9G99NmtE/heaX
         DdYQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=Oz2Jtn7TLxujAbF5klBuEKjq+PJwIG6ezw5Z3IWQiEg=;
        b=mlpZpUdZknNVQhaY6Br3rAoXSGj1Lk27SzOhBKwx1By4+zVF7IRDL2du7NqYi7ux22
         AgrdELVSQAsMBSlAet/G48oTVAIaZoqJc2YFpT/VSck5I6VkjdWPQAUKX+InRNOgz3o9
         VSxuOx6itCFw4V6BH7cfz20V7lJLDKQaAsia81PTYk9ehk637LTL6jaDhq+S4v7J6f/Y
         TKwZj0/iT+cCjvwqI0etIS7FK+JtS86iVkUYcj6za6dF8Wck+9Bi5ME8JPxOLaTQS+Rl
         JQjhdORgQaPdir9sU34xoTjC6Q13OsLGnsF3/znJwmPB1mB6Ws6nxc6THkvPDsUSFTbX
         AikA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from relay.sw.ru (relay.sw.ru. [185.231.240.75])
        by mx.google.com with ESMTPS id z13si12214354lfh.102.2019.05.28.01.35.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 May 2019 01:35:04 -0700 (PDT)
Received-SPF: pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) client-ip=185.231.240.75;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from [172.16.25.169]
	by relay.sw.ru with esmtp (Exim 4.91)
	(envelope-from <ktkhai@virtuozzo.com>)
	id 1hVXZU-000124-DK; Tue, 28 May 2019 11:35:00 +0300
Subject: Re: [PATCH] list_lru: fix memory leak in __memcg_init_list_lru_node
To: Shakeel Butt <shakeelb@google.com>,
 Vladimir Davydov <vdavydov.dev@gmail.com>, Michal Hocko <mhocko@suse.com>,
 Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
 syzbot+f90a420dfe2b1b03cb2c@syzkaller.appspotmail.com
References: <20190528043202.99980-1-shakeelb@google.com>
From: Kirill Tkhai <ktkhai@virtuozzo.com>
Message-ID: <6ed45785-4b5b-83f9-6487-6c4142fe22ac@virtuozzo.com>
Date: Tue, 28 May 2019 11:34:59 +0300
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <20190528043202.99980-1-shakeelb@google.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 28.05.2019 07:32, Shakeel Butt wrote:
> Syzbot reported following memory leak:
> 
> ffffffffda RBX: 0000000000000003 RCX: 0000000000441f79
> BUG: memory leak
> unreferenced object 0xffff888114f26040 (size 32):
>   comm "syz-executor626", pid 7056, jiffies 4294948701 (age 39.410s)
>   hex dump (first 32 bytes):
>     40 60 f2 14 81 88 ff ff 40 60 f2 14 81 88 ff ff  @`......@`......
>     00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
>   backtrace:
>     [<0000000018f36b56>] kmemleak_alloc_recursive include/linux/kmemleak.h:55 [inline]
>     [<0000000018f36b56>] slab_post_alloc_hook mm/slab.h:439 [inline]
>     [<0000000018f36b56>] slab_alloc mm/slab.c:3326 [inline]
>     [<0000000018f36b56>] kmem_cache_alloc_trace+0x13d/0x280 mm/slab.c:3553
>     [<0000000055b9a1a5>] kmalloc include/linux/slab.h:547 [inline]
>     [<0000000055b9a1a5>] __memcg_init_list_lru_node+0x58/0xf0 mm/list_lru.c:352
>     [<000000001356631d>] memcg_init_list_lru_node mm/list_lru.c:375 [inline]
>     [<000000001356631d>] memcg_init_list_lru mm/list_lru.c:459 [inline]
>     [<000000001356631d>] __list_lru_init+0x193/0x2a0 mm/list_lru.c:626
>     [<00000000ce062da3>] alloc_super+0x2e0/0x310 fs/super.c:269
>     [<000000009023adcf>] sget_userns+0x94/0x2a0 fs/super.c:609
>     [<0000000052182cd8>] sget+0x8d/0xb0 fs/super.c:660
>     [<0000000006c24238>] mount_nodev+0x31/0xb0 fs/super.c:1387
>     [<0000000006016a76>] fuse_mount+0x2d/0x40 fs/fuse/inode.c:1236
>     [<000000009a61ec1d>] legacy_get_tree+0x27/0x80 fs/fs_context.c:661
>     [<0000000096cd9ef8>] vfs_get_tree+0x2e/0x120 fs/super.c:1476
>     [<000000005b8f472d>] do_new_mount fs/namespace.c:2790 [inline]
>     [<000000005b8f472d>] do_mount+0x932/0xc50 fs/namespace.c:3110
>     [<00000000afb009b4>] ksys_mount+0xab/0x120 fs/namespace.c:3319
>     [<0000000018f8c8ee>] __do_sys_mount fs/namespace.c:3333 [inline]
>     [<0000000018f8c8ee>] __se_sys_mount fs/namespace.c:3330 [inline]
>     [<0000000018f8c8ee>] __x64_sys_mount+0x26/0x30 fs/namespace.c:3330
>     [<00000000f42066da>] do_syscall_64+0x76/0x1a0 arch/x86/entry/common.c:301
>     [<0000000043d74ca0>] entry_SYSCALL_64_after_hwframe+0x44/0xa9
> 
> This is a simple off by one bug on the error path.
> 
> Reported-by: syzbot+f90a420dfe2b1b03cb2c@syzkaller.appspotmail.com
> Signed-off-by: Shakeel Butt <shakeelb@google.com>

Reviewed-by: Kirill Tkhai <ktkhai@virtuozzo.com>

> ---
>  mm/list_lru.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/mm/list_lru.c b/mm/list_lru.c
> index 0bdf3152735e..92870be4a322 100644
> --- a/mm/list_lru.c
> +++ b/mm/list_lru.c
> @@ -358,7 +358,7 @@ static int __memcg_init_list_lru_node(struct list_lru_memcg *memcg_lrus,
>  	}
>  	return 0;
>  fail:
> -	__memcg_destroy_list_lru_node(memcg_lrus, begin, i - 1);
> +	__memcg_destroy_list_lru_node(memcg_lrus, begin, i);
>  	return -ENOMEM;
>  }
>  
> 

