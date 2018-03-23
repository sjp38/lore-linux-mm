Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 1CBAD6B0023
	for <linux-mm@kvack.org>; Fri, 23 Mar 2018 08:29:05 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id p2so5946749wre.19
        for <linux-mm@kvack.org>; Fri, 23 Mar 2018 05:29:05 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 34si6352266wrd.123.2018.03.23.05.29.03
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 23 Mar 2018 05:29:03 -0700 (PDT)
Date: Fri, 23 Mar 2018 13:29:02 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: =?utf-8?B?562U5aSNOiDnrZTlpI06IOetlA==?=
 =?utf-8?B?5aSNOiBbUEFUQ0g=?= =?utf-8?Q?=5D?= mm/memcontrol.c: speed up to
 force empty a memory cgroup
Message-ID: <20180323122902.GR23100@dhcp22.suse.cz>
References: <1521448170-19482-1-git-send-email-lirongqing@baidu.com>
 <20180319085355.GQ23100@dhcp22.suse.cz>
 <2AD939572F25A448A3AE3CAEA61328C23745764B@BC-MAIL-M28.internal.baidu.com>
 <20180319103756.GV23100@dhcp22.suse.cz>
 <2AD939572F25A448A3AE3CAEA61328C2374589DC@BC-MAIL-M28.internal.baidu.com>
 <2AD939572F25A448A3AE3CAEA61328C2374832C1@BC-MAIL-M28.internal.baidu.com>
 <20180323100839.GO23100@dhcp22.suse.cz>
 <2AD939572F25A448A3AE3CAEA61328C2374EC73E@BC-MAIL-M28.internal.baidu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <2AD939572F25A448A3AE3CAEA61328C2374EC73E@BC-MAIL-M28.internal.baidu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Li,Rongqing" <lirongqing@baidu.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "cgroups@vger.kernel.org" <cgroups@vger.kernel.org>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, Andrey Ryabinin <aryabinin@virtuozzo.com>

On Fri 23-03-18 12:04:16, Li,Rongqing wrote:
[...]
> shrink_slab does not reclaim any memory, but take lots of time to
> count lru
>
> maybe we can use the returning of shrink_slab to control if next
> shrink_slab should be called?

How? Different memcgs might have different amount of shrinkable memory.

> Or define a slight list_lru_empty to check if sb->s_dentry_lru is
> empty before calling list_lru_shrink_count, like below

Does it really help to improve numbers?
 
> diff --git a/fs/super.c b/fs/super.c
> index 672538ca9831..954c22338833 100644
> --- a/fs/super.c
> +++ b/fs/super.c
> @@ -130,8 +130,10 @@ static unsigned long super_cache_count(struct shrinker *shrink,
>         if (sb->s_op && sb->s_op->nr_cached_objects)
>                 total_objects = sb->s_op->nr_cached_objects(sb, sc);
>  
> -       total_objects += list_lru_shrink_count(&sb->s_dentry_lru, sc);
> -       total_objects += list_lru_shrink_count(&sb->s_inode_lru, sc);
> +       if (!list_lru_empty(sb->s_dentry_lru))
> +               total_objects += list_lru_shrink_count(&sb->s_dentry_lru, sc);
> +       if (!list_lru_empty(sb->s_inode_lru))
> +               total_objects += list_lru_shrink_count(&sb->s_inode_lru, sc);
>  
>         total_objects = vfs_pressure_ratio(total_objects);
>         return total_objects;

-- 
Michal Hocko
SUSE Labs
