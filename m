Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id E2CE66B0038
	for <linux-mm@kvack.org>; Tue, 19 Dec 2017 12:45:21 -0500 (EST)
Received: by mail-lf0-f69.google.com with SMTP id o63so217637lff.4
        for <linux-mm@kvack.org>; Tue, 19 Dec 2017 09:45:21 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f25sor2908697ljb.69.2017.12.19.09.45.19
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 19 Dec 2017 09:45:20 -0800 (PST)
Subject: Re: [PATCH v2] mm/zsmalloc: simplify shrinker init/destroy
References: <20171219102213.GA435@jagdpanzerIV>
 <1513680552-9798-1-git-send-email-akaraliou.dev@gmail.com>
 <20171219151341.GC15210@dhcp22.suse.cz>
 <20171219152536.GA591@tigerII.localdomain>
 <20171219155815.GC2787@dhcp22.suse.cz>
From: Aliaksei Karaliou <akaraliou.dev@gmail.com>
Message-ID: <15c19718-c08e-e7f6-8af9-9651db1b11cc@gmail.com>
Date: Tue, 19 Dec 2017 20:45:17 +0300
MIME-Version: 1.0
In-Reply-To: <20171219155815.GC2787@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Cc: minchan@kernel.org, ngupta@vflare.org, sergey.senozhatsky.work@gmail.com, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>



On 12/19/2017 06:58 PM, Michal Hocko wrote:
> On Wed 20-12-17 00:25:36, Sergey Senozhatsky wrote:
>> Hi Michal,
>>
>> On (12/19/17 16:13), Michal Hocko wrote:
>>> On Tue 19-12-17 13:49:12, Aliaksei Karaliou wrote:
>>> [...]
>>>> @@ -2428,8 +2422,8 @@ struct zs_pool *zs_create_pool(const char *name)
>>>>   	 * Not critical, we still can use the pool
>>>>   	 * and user can trigger compaction manually.
>>>>   	 */
>>>> -	if (zs_register_shrinker(pool) == 0)
>>>> -		pool->shrinker_enabled = true;
>>>> +	(void) zs_register_shrinker(pool);
>>>> +
>>>>   	return pool;
>>> So what will happen if the pool is alive and used without any shrinker?
>>> How do objects get freed?
>> we use shrinker for "optional" de-fragmentation of zsmalloc pools. we
>> don't free any objects from that path. just move them around within their
>> size classes - to consolidate objects and to, may be, free unused pages
>> [but we first need to make them "unused"]. it's not a mandatory thing for
>> zsmalloc, we are just trying to be nice.
> OK, it smells like an abuse of the API but please add a comment
> clarifying that.
>
> Thanks!
I can update the existing comment to be like that:
         /*
          * Not critical since shrinker is only used to trigger internal
          * de-fragmentation of the pool which is pretty optional thing.
          * If registration fails we still can use the pool normally and
          * user can trigger compaction manually. Thus, ignore return code.
          */

Sergey, does this sound well to you ? Or not clear enough, Michal ?

Best regards,
     Aliaksei

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
