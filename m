Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f200.google.com (mail-ot0-f200.google.com [74.125.82.200])
	by kanga.kvack.org (Postfix) with ESMTP id 887A46B0003
	for <linux-mm@kvack.org>; Thu, 15 Mar 2018 16:10:34 -0400 (EDT)
Received: by mail-ot0-f200.google.com with SMTP id e19-v6so2290813otf.9
        for <linux-mm@kvack.org>; Thu, 15 Mar 2018 13:10:34 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id u70sor2345010ota.79.2018.03.15.13.10.33
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 15 Mar 2018 13:10:33 -0700 (PDT)
Subject: Re: Hangs in balance_dirty_pages with arm-32 LPAE + highmem
References: <b77a6596-3b35-84fe-b65b-43d2e43950b3@redhat.com>
 <20180226142839.GB16842@dhcp22.suse.cz>
 <4ba43bef-37f0-c21c-23a7-bbf696c926fd@redhat.com>
 <20180314090851.GG4811@dhcp22.suse.cz>
From: Laura Abbott <labbott@redhat.com>
Message-ID: <ba9181f3-505d-c4ed-5f8b-d57696432f21@redhat.com>
Date: Thu, 15 Mar 2018 13:10:30 -0700
MIME-Version: 1.0
In-Reply-To: <20180314090851.GG4811@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Linux-MM <linux-mm@kvack.org>, linux-block@vger.kernel.org, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>

On 03/14/2018 02:08 AM, Michal Hocko wrote:
> On Mon 05-03-18 13:04:24, Laura Abbott wrote:
>> On 02/26/2018 06:28 AM, Michal Hocko wrote:
>>> On Fri 23-02-18 11:51:41, Laura Abbott wrote:
>>>> Hi,
>>>>
>>>> The Fedora arm-32 build VMs have a somewhat long standing problem
>>>> of hanging when running mkfs.ext4 with a bunch of processes stuck
>>>> in D state. This has been seen as far back as 4.13 but is still
>>>> present on 4.14:
>>>>
>>> [...]
>>>> This looks like everything is blocked on the writeback completing but
>>>> the writeback has been throttled. According to the infra team, this problem
>>>> is _not_ seen without LPAE (i.e. only 4G of RAM). I did see
>>>> https://patchwork.kernel.org/patch/10201593/ but that doesn't seem to
>>>> quite match since this seems to be completely stuck. Any suggestions to
>>>> narrow the problem down?
>>>
>>> How much dirtyable memory does the system have? We do allow only lowmem
>>> to be dirtyable by default on 32b highmem systems. Maybe you have the
>>> lowmem mostly consumed by the kernel memory. Have you tried to enable
>>> highmem_is_dirtyable?
>>>
>>
>> Setting highmem_is_dirtyable did fix the problem. The infrastructure
>> people seemed satisfied enough with this (and are happy to have the
>> machines back). I'll see if they are willing to run a few more tests
>> to get some more state information.
> 
> Please be aware that highmem_is_dirtyable is not for free. There are
> some code paths which can only allocate from lowmem (e.g. block device
> AFAIR) and those could fill up the whole lowmem without any throttling.
> 

Good to note. This particular setup is one basically everyone dislikes
so I think this is only encouragement to move to something else.

Thanks,
Laura
