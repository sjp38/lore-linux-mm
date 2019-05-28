Return-Path: <SRS0=UfqE=T4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DD5A1C46460
	for <linux-mm@archiver.kernel.org>; Tue, 28 May 2019 06:23:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7D316208C3
	for <linux-mm@archiver.kernel.org>; Tue, 28 May 2019 06:23:03 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7D316208C3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DC21A6B0275; Tue, 28 May 2019 02:23:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D73BA6B0276; Tue, 28 May 2019 02:23:02 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C88176B0278; Tue, 28 May 2019 02:23:02 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 7BDC86B0275
	for <linux-mm@kvack.org>; Tue, 28 May 2019 02:23:02 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id n23so31536438edv.9
        for <linux-mm@kvack.org>; Mon, 27 May 2019 23:23:02 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=RvJU9OVql/JEHp/f/baa/ZjO5Cnb715k4fRy+xtIa9s=;
        b=i3uN4nKpM6CXpxPubBZME5FZMVT6to+synfUnwsqHzD8AI2zeftexIhnKD8ckaLPXn
         uJXRaN6jwZMYGE9IULHkDDgBv6T+70g2wl/FwopS6gI/QeRQfQzQuNxTpMokQJgZCgSW
         H2aM5kpeD9uGiXkHI/2KOP56srZ9Y5qSklrP+g0MkwqOqkVv7/gbdnn08K5vxL3LsP1E
         QNN+TNil9o5LoLPmBmVZpJusK6niBuZhq5IjYiPs5zzvw4XWjagAinR9Jwivl155Dr4M
         CFPjpboWSjWGhIKD94TYwA3q1zWzj0dcPHbr2jOCkaluaDwrFfHQ80OpkgnueZ6AG6u1
         zVJw==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAXeURS7FQ3O6q+z8LGPLS9RNOMIhv+LI5O5dGv37jIQSa/HCW+e
	/hKS5sq3YJ+u25R1W2v/k+qYQ0l39SKErGVFCo47CLzXn0ac+wWnJdEU5emMtkq6Nq6W/TxTXnw
	KzswvhS5R/4/uKjLH1ADxVzAsMoWytzYG1XOQZvCjQcrclfzKVRZzbaSrxVxnqS8=
X-Received: by 2002:a50:9016:: with SMTP id b22mr123503940eda.99.1559024582035;
        Mon, 27 May 2019 23:23:02 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxqzEMn4Ga/IOZWyQkqcqcj1OCuU03QWKy8ns47aRGk1/GNO55WUZIDmvsxOex5Xcbaq4vZ
X-Received: by 2002:a50:9016:: with SMTP id b22mr123503874eda.99.1559024581121;
        Mon, 27 May 2019 23:23:01 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559024581; cv=none;
        d=google.com; s=arc-20160816;
        b=NRz1GHujzslrXC/O9DD/Rm+h4G6zTw6hTEKvbIiBkuqF2AiBfxUQayVzmnnVDof4WD
         Ih9fUK/FUXtEXrbooAG2ZS39ObR84KdydO5CGuCohCxhYwm5W4mS05hCwhzvV1LeoNXh
         jLH6vsIpd6dCzvedk2xezmfpApOX2irr6TVhHq5r+s0jTtWJc80M6+4zj6SD+hmTnAMz
         AeCPK6kkP7dNxm6NNJEtRT13uYzl+kNomfrBUNmOE4naV25kNyv9NSyuz7WBDMCc58k8
         QFEsmw/OZvfTNx6Fsp6MBjVZ0wkgvkmWOS1cRik6qn7oReLY3nG61DU2e9Kir+neqfvD
         pBtA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=RvJU9OVql/JEHp/f/baa/ZjO5Cnb715k4fRy+xtIa9s=;
        b=RLbv7BKtKtU+UQtF4GCBlCceRBfwWWFvpfbar7cWGj07w3wJP9P28lcjhVCO+FJ3vc
         Am2LHqKgLFTp+czvAXwTcp5Hrf7xKPuzSGIargoBv+dU2q7joUULyIUmuqzcRTdtOD4s
         MwG7ZmstLT/x8AhhZj5C2gROr/rtADtA2Drz4Oa0PO7p/qJgg3Sq1IhlS6HJNnN6ldRQ
         Dmk9FXRaS1Ge5gYlUzacxCZLI++pKnzX41E9tTgAqtcq8el0ZpYpupv22XR1wFSHi/yZ
         ILTNw+j9ovbzCcMCutsyoIi7Qjve4wCWEKZz0QzoFD5hr1H9yUs+/7MkJAsbzgI9gBSa
         51YQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id qt10si814997ejb.35.2019.05.27.23.23.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 May 2019 23:23:01 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id BF63CAF98;
	Tue, 28 May 2019 06:22:59 +0000 (UTC)
Date: Tue, 28 May 2019 08:22:57 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Shakeel Butt <shakeelb@google.com>
Cc: Kirill Tkhai <ktkhai@virtuozzo.com>,
	Vladimir Davydov <vdavydov.dev@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	syzbot+f90a420dfe2b1b03cb2c@syzkaller.appspotmail.com
Subject: Re: [PATCH] list_lru: fix memory leak in __memcg_init_list_lru_node
Message-ID: <20190528062257.GJ1658@dhcp22.suse.cz>
References: <20190528043202.99980-1-shakeelb@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190528043202.99980-1-shakeelb@google.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon 27-05-19 21:32:02, Shakeel Butt wrote:
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

I suspect fault injection has been used here because the object is tiny
to fail the allocation but definitely worth fixing. Thanks!

> Reported-by: syzbot+f90a420dfe2b1b03cb2c@syzkaller.appspotmail.com
> Signed-off-by: Shakeel Butt <shakeelb@google.com>

Acked-by: Michal Hocko <mhocko@suse.com>

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
> -- 
> 2.22.0.rc1.257.g3120a18244-goog
> 

-- 
Michal Hocko
SUSE Labs

