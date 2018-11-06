Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io1-f71.google.com (mail-io1-f71.google.com [209.85.166.71])
	by kanga.kvack.org (Postfix) with ESMTP id 93EE76B02B7
	for <linux-mm@kvack.org>; Tue,  6 Nov 2018 00:38:30 -0500 (EST)
Received: by mail-io1-f71.google.com with SMTP id w22-v6so12928262ioc.5
        for <linux-mm@kvack.org>; Mon, 05 Nov 2018 21:38:30 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y101-v6sor1269349ita.15.2018.11.05.21.38.29
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 05 Nov 2018 21:38:29 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <2c42ba08-f78a-36f6-5a5d-21dd00861872@suse.cz>
References: <20181104125028.3572-1-tiny.windzz@gmail.com> <2c42ba08-f78a-36f6-5a5d-21dd00861872@suse.cz>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Tue, 6 Nov 2018 06:38:08 +0100
Message-ID: <CACT4Y+a+7gqs+gdfePuVGZ-bDGvb8ieE8ugA-pK1AZ8HwfecQg@mail.gmail.com>
Subject: Re: [PATCH] mm, slab: remove unnecessary unlikely()
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Yangtao Li <tiny.windzz@gmail.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Mon, Nov 5, 2018 at 11:18 AM, Vlastimil Babka <vbabka@suse.cz> wrote:
> +CC Dmitry
>
> On 11/4/18 1:50 PM, Yangtao Li wrote:
>> WARN_ON() already contains an unlikely(), so it's not necessary to use
>> unlikely.
>>
>> Signed-off-by: Yangtao Li <tiny.windzz@gmail.com>
>
> Acked-by: Vlastimil Babka <vbabka@suse.cz>
>
> Maybe also change it back to WARN_ON_ONCE? I already considered it while
> reviewing Dmitry's patch and wasn't sure. Now I think that what can
> happen is that either a kernel bug is introduced that _ONCE is enough to
> catch (two separate bugs introduced to both hit this would be rare, and
> in that case the second one will be reported after the first one is
> fixed), or this gets called with a user-supplied value, and then we want
> to avoid spamming dmesg with multiple warnings that the user could
> trigger at will.


If you asking me, I am fine both changes.
I was mainly interested in removing the bogus warnings that actually fire.


>> ---
>>  mm/slab_common.c | 4 +---
>>  1 file changed, 1 insertion(+), 3 deletions(-)
>>
>> diff --git a/mm/slab_common.c b/mm/slab_common.c
>> index 7eb8dc136c1c..4f54684f5435 100644
>> --- a/mm/slab_common.c
>> +++ b/mm/slab_common.c
>> @@ -1029,10 +1029,8 @@ struct kmem_cache *kmalloc_slab(size_t size, gfp_t flags)
>>
>>               index = size_index[size_index_elem(size)];
>>       } else {
>> -             if (unlikely(size > KMALLOC_MAX_CACHE_SIZE)) {
>> -                     WARN_ON(1);
>> +             if (WARN_ON(size > KMALLOC_MAX_CACHE_SIZE))
>>                       return NULL;
>> -             }
>>               index = fls(size - 1);
>>       }
>>
>>
>
