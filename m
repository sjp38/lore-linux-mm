Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 12BB16B0038
	for <linux-mm@kvack.org>; Wed, 13 Sep 2017 07:41:25 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id q76so25121765pfq.5
        for <linux-mm@kvack.org>; Wed, 13 Sep 2017 04:41:25 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v75si9407632pfa.181.2017.09.13.04.41.23
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 13 Sep 2017 04:41:23 -0700 (PDT)
Subject: Re: [PATCH 1/2] mm, memory_hotplug: do not fail offlining too early
References: <20170904082148.23131-1-mhocko@kernel.org>
 <20170904082148.23131-2-mhocko@kernel.org>
 <eb5bf356-f498-b430-1ae8-4ff1ad15ad7f@suse.cz>
 <20170911081714.4zc33r7wlj2nnbho@dhcp22.suse.cz>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <9fad7246-c634-18bb-78f9-b95376c009da@suse.cz>
Date: Wed, 13 Sep 2017 13:41:20 +0200
MIME-Version: 1.0
In-Reply-To: <20170911081714.4zc33r7wlj2nnbho@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, qiuxishi@huawei.com, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On 09/11/2017 10:17 AM, Michal Hocko wrote:
> On Fri 08-09-17 19:26:06, Vlastimil Babka wrote:
>> On 09/04/2017 10:21 AM, Michal Hocko wrote:
>>> From: Michal Hocko <mhocko@suse.com>
>>>
>>> Fix this by removing the max retry count and only rely on the timeout
>>> resp. interruption by a signal from the userspace. Also retry rather
>>> than fail when check_pages_isolated sees some !free pages because those
>>> could be a result of the race as well.
>>>
>>> Signed-off-by: Michal Hocko <mhocko@suse.com>
>>
>> Even within a movable node where has_unmovable_pages() is a non-issue, you could
>> have pinned movable pages where the pinning is not temporary.
> 
> Who would pin those pages? Such a page would be unreclaimable as well
> and thus a memory leak and I would argue it would be a bug.

I don't know who exactly, but generally it's a problem for CMA and a
reason why there was some effort from PeterZ to introduce an API for
long-term pinning.

>> So after this
>> patch, this will really keep retrying forever. I'm not saying it's wrong, just
>> pointing it out, since the changelog seems to assume there would be only
>> temporary failures possible and thus unbound retries are always correct.
>> The obvious problem if we wanted to avoid this, is how to recognize
>> non-temporary failures...
> 
> Yes, we should be able to distinguish the two and hopefully we can teach
> the migration code to distinguish between EBUSY (likely permanent) and
> EGAIN (temporal) failure. This sound like something we should aim for
> longterm I guess. Anyway as I've said in other email. If somebody really
> wants to have a guaratee of a bounded retry then it is trivial to set up
> an alarm and send a signal itself to bail out.

Sure, I would just be careful about not breaking existing userspace
(udev?) when offline triggered via ACPI from some management interface
(or whatever the exact mechanism is).

> Do you think that the changelog should be more clear about this?

It certainly wouldn't hurt :)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
