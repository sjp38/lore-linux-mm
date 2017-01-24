Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id 8B96C6B0266
	for <linux-mm@kvack.org>; Tue, 24 Jan 2017 17:13:10 -0500 (EST)
Received: by mail-lf0-f71.google.com with SMTP id x128so78802639lfa.0
        for <linux-mm@kvack.org>; Tue, 24 Jan 2017 14:13:10 -0800 (PST)
Received: from mail-lf0-x242.google.com (mail-lf0-x242.google.com. [2a00:1450:4010:c07::242])
        by mx.google.com with ESMTPS id q142si13362624lfe.107.2017.01.24.14.13.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Jan 2017 14:13:08 -0800 (PST)
Received: by mail-lf0-x242.google.com with SMTP id h65so18758288lfi.3
        for <linux-mm@kvack.org>; Tue, 24 Jan 2017 14:13:08 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20170124132441.5027560693ed6d8c283c1953@linux-foundation.org>
References: <20170124200259.16191-1-ddstreet@ieee.org> <20170124200259.16191-2-ddstreet@ieee.org>
 <20170124132441.5027560693ed6d8c283c1953@linux-foundation.org>
From: Dan Streetman <ddstreet@ieee.org>
Date: Tue, 24 Jan 2017 17:12:27 -0500
Message-ID: <CALZtONCSvmc=JU3iq=YGJ+gLMG1WEXWLGObHiCMzGxzxMLLkNQ@mail.gmail.com>
Subject: Re: [PATCH 1/3] zswap: disable changing params if init fails
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux-MM <linux-mm@kvack.org>, Seth Jennings <sjenning@redhat.com>, Michal Hocko <mhocko@kernel.org>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Minchan Kim <minchan@kernel.org>, linux-kernel <linux-kernel@vger.kernel.org>, stable@vger.kernel.org, Dan Streetman <dan.streetman@canonical.com>

On Tue, Jan 24, 2017 at 4:24 PM, Andrew Morton
<akpm@linux-foundation.org> wrote:
> On Tue, 24 Jan 2017 15:02:57 -0500 Dan Streetman <ddstreet@ieee.org> wrote:
>
>> Add zswap_init_failed bool that prevents changing any of the module
>> params, if init_zswap() fails, and set zswap_enabled to false.  Change
>> 'enabled' param to a callback, and check zswap_init_failed before
>> allowing any change to 'enabled', 'zpool', or 'compressor' params.
>>
>> Any driver that is built-in to the kernel will not be unloaded if its
>> init function returns error, and its module params remain accessible for
>> users to change via sysfs.  Since zswap uses param callbacks, which
>> assume that zswap has been initialized, changing the zswap params after
>> a failed initialization will result in WARNING due to the param callbacks
>> expecting a pool to already exist.  This prevents that by immediately
>> exiting any of the param callbacks if initialization failed.
>>
>> This was reported here:
>> https://marc.info/?l=linux-mm&m=147004228125528&w=4
>
> I added Marcin's reportde-by to the changelog.

Thanks, I missed that.

>
>> And fixes this WARNING:
>> [  429.723476] WARNING: CPU: 0 PID: 5140 at mm/zswap.c:503
>> __zswap_pool_current+0x56/0x60
>>
>> Fixes: 90b0fc26d5db ("zswap: change zpool/compressor at runtime")
>> Cc: stable@vger.kernel.org
>
> Is this really serious enough to justify a -stable backport?  It's just
> a bit of extra noise associated with an initialization problem which
> the user will be fixing anyway.

The warning is just noise, and not serious.  However, when init fails,
zswap frees all its percpu dstmem pages and its kmem cache.  The kmem
cache might be serious, if kmem_cache_alloc(NULL, gfp) has problems;
but the percpu dstmem pages are definitely a problem, as they're used
as temporary buffer for compressed pages before copying into place in
the zpool.

If the user does get zswap enabled after an init failure, then zswap
will likely Oops on the first page it tries to compress (or worse,
start corrupting memory).

I should have added all that to the changelog to make the issue clear, sorry.

>
>
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
