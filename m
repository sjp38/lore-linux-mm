Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1E984280910
	for <linux-mm@kvack.org>; Sat, 11 Mar 2017 04:53:26 -0500 (EST)
Received: by mail-io0-f199.google.com with SMTP id 20so82612885iod.2
        for <linux-mm@kvack.org>; Sat, 11 Mar 2017 01:53:26 -0800 (PST)
Received: from smtpbg325.qq.com (smtpbg325.qq.com. [14.17.32.36])
        by mx.google.com with SMTP id q124si2041813itd.30.2017.03.11.01.53.23
        for <linux-mm@kvack.org>;
        Sat, 11 Mar 2017 01:53:25 -0800 (PST)
From: Yisheng Xie <ysxie@foxmail.com>
Subject: Re: [PATCH RFC] mm/vmscan: donot retry shrink zones when memcg is
 disabled
References: <1489198798-6632-1-git-send-email-ysxie@foxmail.com>
 <CALvZod5X3sLQT-We2VNCiAN9zi9MJvdk4fVGERVpw=GQGrGHEg@mail.gmail.com>
Message-ID: <58C3C648.2020209@foxmail.com>
Date: Sat, 11 Mar 2017 17:41:28 +0800
MIME-Version: 1.0
In-Reply-To: <CALvZod5X3sLQT-We2VNCiAN9zi9MJvdk4fVGERVpw=GQGrGHEg@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shakeel Butt <shakeelb@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@suse.com>, riel@redhat.com, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, xieyisheng1@huawei.com

Hi Shakeel,

Thanks for reviewing.

On 03/11/2017 11:40 AM, Shakeel Butt wrote:
> On Fri, Mar 10, 2017 at 6:19 PM, Yisheng Xie <ysxie@foxmail.com> wrote:
>> From: Yisheng Xie <xieyisheng1@huawei.com>
>>
>> When we enter do_try_to_free_pages, the may_thrash is always clear, and
>> it will retry shrink zones to tap cgroup's reserves memory by setting
>> may_thrash when the former shrink_zones reclaim nothing.
>>
>> However, if CONFIG_MEMCG=n, it should not do this useless retry at all,
>> for we do not have any cgroup's reserves memory to tap, and we have
>> already done hard work and made no progress.
>>
>> Signed-off-by: Yisheng Xie <xieyisheng1@huawei.com>
>> ---
>>  mm/vmscan.c | 2 +-
>>  1 file changed, 1 insertion(+), 1 deletion(-)
>>
>> diff --git a/mm/vmscan.c b/mm/vmscan.c
>> index bc8031e..b03ccc1 100644
>> --- a/mm/vmscan.c
>> +++ b/mm/vmscan.c
>> @@ -2808,7 +2808,7 @@ static unsigned long do_try_to_free_pages(struct zonelist *zonelist,
>>                 return 1;
>>
>>         /* Untapped cgroup reserves?  Don't OOM, retry. */
>> -       if (!sc->may_thrash) {
>> +       if (!sc->may_thrash && IS_ENABLED(CONFIG_MEMCG)) {
> In my opinion it should be even more restrictive (restricting
> cgroup_disabled=memory boot option and cgroup legacy hierarchy). So,
> instead of IS_ENABLED(CONFIG_MEMCG), the check should be something
> like (cgroup_subsys_enabled(memory_cgrp_subsys) &&
> cgroup_subsys_on_dfl(memory_cgrp_subsys)).
Righti 1/4 ?  I will send another version soon.

Thanks
Yisheng Xie.

>>                 sc->priority = initial_priority;
>>                 sc->may_thrash = 1;
>>                 goto retry;
>> --
>> 1.9.1
>>
>>
>>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
