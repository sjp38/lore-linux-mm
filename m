Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 6F6636B0388
	for <linux-mm@kvack.org>; Thu, 16 Mar 2017 06:00:01 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id e5so82740993pgk.1
        for <linux-mm@kvack.org>; Thu, 16 Mar 2017 03:00:01 -0700 (PDT)
Received: from dggrg03-dlp.huawei.com ([45.249.212.189])
        by mx.google.com with ESMTPS id u5si4792582pgg.140.2017.03.16.02.59.59
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 16 Mar 2017 03:00:00 -0700 (PDT)
Subject: Re: [PATCH v4] mm/vmscan: more restrictive condition for retry in
 do_try_to_free_pages
References: <1489577808-19228-1-git-send-email-xieyisheng1@huawei.com>
 <20170315124117.GH32620@dhcp22.suse.cz>
From: Yisheng Xie <xieyisheng1@huawei.com>
Message-ID: <80844f35-0864-81fb-e9a1-45def1e67f8b@huawei.com>
Date: Thu, 16 Mar 2017 17:59:35 +0800
MIME-Version: 1.0
In-Reply-To: <20170315124117.GH32620@dhcp22.suse.cz>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: akpm@linux-foundation.org, hannes@cmpxchg.org, mgorman@suse.de, vbabka@suse.cz, riel@redhat.com, shakeelb@google.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, guohanjun@huawei.com, qiuxishi@huawei.com

Hi Michal

Thanks for reviewing.
On 2017/3/15 20:41, Michal Hocko wrote:
> On Wed 15-03-17 19:36:48, Yisheng Xie wrote:
>> By reviewing code, I find that when enter do_try_to_free_pages, the
>> may_thrash is always clear, and it will retry shrink zones to tap
>> cgroup's reserves memory by setting may_thrash when the former
>> shrink_zones reclaim nothing.
>>
>> However, when memcg is disabled or on legacy hierarchy, or there do not
>> have any memcg protected by low limit, it should not do this useless retry
>> at all, for we do not have any cgroup's reserves memory to tap, and we
>> have already done hard work but made no progress.
>>
>> To avoid this unneeded retrying, add a new field in scan_control named
>> memcg_low_protection, set it if there is any memcg protected by low limit
>> and only do the retry when memcg_low_protection is set while may_thrash
>> is clear.
> 
> You still haven't explained why a retry is bad thing. It certainly is
> not about performance because not a single page being reclaimed means
> that all the performance went to hell already. Please always make it
> clear why the change is needed/desirable.
So sorry for about that! This patch is just based on code reviewing, and
sure is nothing to do with performance, therefore, I also cannot get any
data about it. IMO, it may save some cycles for reclaim and this make me
try to prepare this patch. Just as what you said that "the current additional
round of reclaim is just lame for we are trying hard to control the retry
logic from the page allocator".

Thanks
Yisheng Xie.

> 
> But I agree that this makes the code easier to understand so I am OK
> with this change.
> 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
