Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id CBD8D6B0033
	for <linux-mm@kvack.org>; Fri,  6 Oct 2017 15:33:06 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id 136so15825269wmu.3
        for <linux-mm@kvack.org>; Fri, 06 Oct 2017 12:33:06 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id y14sor735013wmh.20.2017.10.06.12.33.04
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 06 Oct 2017 12:33:04 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20171006075900.icqjx5rr7hctn3zd@dhcp22.suse.cz>
References: <20171005222144.123797-1-shakeelb@google.com> <20171006075900.icqjx5rr7hctn3zd@dhcp22.suse.cz>
From: Shakeel Butt <shakeelb@google.com>
Date: Fri, 6 Oct 2017 12:33:03 -0700
Message-ID: <CALvZod7YN4JCG7Anm2FViyZ0-APYy+nxEd3nyxe5LT_P0FC9wg@mail.gmail.com>
Subject: Re: [PATCH] fs, mm: account filp and names caches to kmemcg
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, Vladimir Davydov <vdavydov.dev@gmail.com>, Greg Thelen <gthelen@google.com>, Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>

>>       names_cachep = kmem_cache_create("names_cache", PATH_MAX, 0,
>> -                     SLAB_HWCACHE_ALIGN|SLAB_PANIC, NULL);
>> +                     SLAB_HWCACHE_ALIGN|SLAB_PANIC|SLAB_ACCOUNT, NULL);
>
> I might be wrong but isn't name cache only holding temporary objects
> used for path resolution which are not stored anywhere?
>

Even though they're temporary, many containers can together use a
significant amount of transient uncharged memory. We've seen machines
with 100s of MiBs in names_cache.

>>       filp_cachep = kmem_cache_create("filp", sizeof(struct file), 0,
>> -                     SLAB_HWCACHE_ALIGN | SLAB_PANIC, NULL);
>> +                     SLAB_HWCACHE_ALIGN | SLAB_PANIC | SLAB_ACCOUNT, NULL);
>>       percpu_counter_init(&nr_files, 0, GFP_KERNEL);
>>  }
>
> Don't we have a limit for the maximum number of open files?
>

Yes, there is a system limit of maximum number of open files. However
this limit is shared between different users on the system and one
user can hog this resource. To cater that, we set the maximum limit
very high and let the memory limit of each user limit the number of
files they can open.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
