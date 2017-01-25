Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id 000AA6B0038
	for <linux-mm@kvack.org>; Wed, 25 Jan 2017 11:37:22 -0500 (EST)
Received: by mail-lf0-f71.google.com with SMTP id o12so86659359lfg.7
        for <linux-mm@kvack.org>; Wed, 25 Jan 2017 08:37:22 -0800 (PST)
Received: from mail-lf0-x241.google.com (mail-lf0-x241.google.com. [2a00:1450:4010:c07::241])
        by mx.google.com with ESMTPS id s2si15016365lfg.31.2017.01.25.08.37.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 Jan 2017 08:37:21 -0800 (PST)
Received: by mail-lf0-x241.google.com with SMTP id h65so21559908lfi.3
        for <linux-mm@kvack.org>; Wed, 25 Jan 2017 08:37:21 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20170125002426.GA2234@jagdpanzerIV.localdomain>
References: <20170124200259.16191-1-ddstreet@ieee.org> <20170124200259.16191-3-ddstreet@ieee.org>
 <20170125002426.GA2234@jagdpanzerIV.localdomain>
From: Dan Streetman <ddstreet@ieee.org>
Date: Wed, 25 Jan 2017 11:36:40 -0500
Message-ID: <CALZtONByh4VOUqNewmK77BNgKBzExBhiFwCJ9UTdhQREZ4f+ig@mail.gmail.com>
Subject: Re: [PATCH 2/3] zswap: allow initialization at boot without pool
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Linux-MM <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Seth Jennings <sjenning@redhat.com>, Michal Hocko <mhocko@kernel.org>, Minchan Kim <minchan@kernel.org>, linux-kernel <linux-kernel@vger.kernel.org>, Dan Streetman <dan.streetman@canonical.com>

On Tue, Jan 24, 2017 at 7:24 PM, Sergey Senozhatsky
<sergey.senozhatsky.work@gmail.com> wrote:
>
> just a note,
>
> On (01/24/17 15:02), Dan Streetman wrote:
> [..]
>> @@ -692,6 +702,15 @@ static int __zswap_param_set(const char *val, const struct kernel_param *kp,
>>                */
>>               list_add_tail_rcu(&pool->list, &zswap_pools);
>>               put_pool = pool;
>> +     } else if (!zswap_has_pool) {
>> +             /* if initial pool creation failed, and this pool creation also
>> +              * failed, maybe both compressor and zpool params were bad.
>> +              * Allow changing this param, so pool creation will succeed
>> +              * when the other param is changed. We already verified this
>> +              * param is ok in the zpool_has_pool() or crypto_has_comp()
>> +              * checks above.
>> +              */
>> +             ret = param_set_charp(s, kp);
>>       }
>>
>>       spin_unlock(&zswap_pools_lock);
>
> looks like there still GFP_KERNEL allocation from atomic section:
> param_set_charp()->kmalloc_parameter()->kmalloc(GFP_KERNEL), under
> `zswap_pools_lock'.

thanks, it looks like the other param_set_charp above this new one has
been in the spinlock ever since i added the param callback.  I'll send
a patch.


>
>         -ss
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
