Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f199.google.com (mail-yw0-f199.google.com [209.85.161.199])
	by kanga.kvack.org (Postfix) with ESMTP id CD5D66B0253
	for <linux-mm@kvack.org>; Tue, 26 Apr 2016 07:08:25 -0400 (EDT)
Received: by mail-yw0-f199.google.com with SMTP id v81so22473280ywa.1
        for <linux-mm@kvack.org>; Tue, 26 Apr 2016 04:08:25 -0700 (PDT)
Received: from mail-vk0-x244.google.com (mail-vk0-x244.google.com. [2607:f8b0:400c:c05::244])
        by mx.google.com with ESMTPS id 1si8809540uao.98.2016.04.26.04.08.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Apr 2016 04:08:25 -0700 (PDT)
Received: by mail-vk0-x244.google.com with SMTP id n67so1411702vkf.3
        for <linux-mm@kvack.org>; Tue, 26 Apr 2016 04:08:24 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20160425221816.GA1254@google.com>
References: <CALZtONCDqBjL9TFmUEwuHaNU3n55k0VwbYWqW-9dODuNWyzkLQ@mail.gmail.com>
 <1461619210-10057-1-git-send-email-ddstreet@ieee.org> <20160425221816.GA1254@google.com>
From: Dan Streetman <ddstreet@ieee.org>
Date: Tue, 26 Apr 2016 07:07:45 -0400
Message-ID: <CALZtONCs3pTmdy55u=31P75pr61SUya=f=rS7px4gRXxR6gYZA@mail.gmail.com>
Subject: Re: [PATCH] mm/zpool: use workqueue for zpool_destroy
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yu Zhao <yuzhao@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Seth Jennings <sjenning@redhat.com>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Minchan Kim <minchan@kernel.org>, Nitin Gupta <ngupta@vflare.org>, Linux-MM <linux-mm@kvack.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, linux-kernel <linux-kernel@vger.kernel.org>, Dan Streetman <dan.streetman@canonical.com>

On Mon, Apr 25, 2016 at 6:18 PM, Yu Zhao <yuzhao@google.com> wrote:
> On Mon, Apr 25, 2016 at 05:20:10PM -0400, Dan Streetman wrote:
>> Add a work_struct to struct zpool, and change zpool_destroy_pool to
>> defer calling the pool implementation destroy.
>>
>> The zsmalloc pool destroy function, which is one of the zpool
>> implementations, may sleep during destruction of the pool.  However
>> zswap, which uses zpool, may call zpool_destroy_pool from atomic
>> context.  So we need to defer the call to the zpool implementation
>> to destroy the pool.
>>
>> This is essentially the same as Yu Zhao's proposed patch to zsmalloc,
>> but moved to zpool.
>
> Thanks, Dan. Sergey also mentioned another call path that triggers the
> same problem (BUG: scheduling while atomic):
>   rcu_process_callbacks()
>           __zswap_pool_release()
>                   zswap_pool_destroy()
>                           zswap_cpu_comp_destroy()
>                                   cpu_notifier_register_begin()
>                                           mutex_lock(&cpu_add_remove_lock);
> So I was thinking zswap_pool_destroy() might be done in workqueue in zswap.c.
> This way we fix both call paths.

Yes, you're right, I took so long to get around to this I forgot the details :-)

I'll send a new patch to zswap.

>
> Or you have another patch to fix the second call path?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
