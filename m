Return-Path: <SRS0=NQQQ=W6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 009B4C3A5A2
	for <linux-mm@archiver.kernel.org>; Tue,  3 Sep 2019 12:05:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9621D206B8
	for <linux-mm@archiver.kernel.org>; Tue,  3 Sep 2019 12:05:25 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9621D206B8
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=virtuozzo.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 30DAA6B0003; Tue,  3 Sep 2019 08:05:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 298EE6B0005; Tue,  3 Sep 2019 08:05:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 185356B0006; Tue,  3 Sep 2019 08:05:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0140.hostedemail.com [216.40.44.140])
	by kanga.kvack.org (Postfix) with ESMTP id E62516B0003
	for <linux-mm@kvack.org>; Tue,  3 Sep 2019 08:05:24 -0400 (EDT)
Received: from smtpin29.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 89742908F
	for <linux-mm@kvack.org>; Tue,  3 Sep 2019 12:05:24 +0000 (UTC)
X-FDA: 75893479368.29.ocean68_2f22385c2af4f
X-HE-Tag: ocean68_2f22385c2af4f
X-Filterd-Recvd-Size: 4613
Received: from relay.sw.ru (relay.sw.ru [185.231.240.75])
	by imf38.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue,  3 Sep 2019 12:05:23 +0000 (UTC)
Received: from [172.16.25.5]
	by relay.sw.ru with esmtp (Exim 4.92)
	(envelope-from <aryabinin@virtuozzo.com>)
	id 1i57Ym-0003BW-HN; Tue, 03 Sep 2019 15:05:20 +0300
Subject: Re: [BUG] Early OOM and kernel NULL pointer dereference in 4.19.69
To: Michal Hocko <mhocko@kernel.org>,
 Thomas Lindroth <thomas.lindroth@gmail.com>
Cc: linux-mm@kvack.org, stable@vger.kernel.org
References: <31131c2d-a936-8bbf-e58d-a3baaa457340@gmail.com>
 <20190902071617.GC14028@dhcp22.suse.cz>
 <a07da432-1fc1-67de-ae35-93f157bf9a7d@gmail.com>
 <20190903074132.GM14028@dhcp22.suse.cz>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <84c47d16-ff5a-9af0-efd4-5ef78d302170@virtuozzo.com>
Date: Tue, 3 Sep 2019 15:05:22 +0300
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <20190903074132.GM14028@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 9/3/19 10:41 AM, Michal Hocko wrote:
> On Mon 02-09-19 21:34:29, Thomas Lindroth wrote:
>> On 9/2/19 9:16 AM, Michal Hocko wrote:
>>> On Sun 01-09-19 22:43:05, Thomas Lindroth wrote:
>>>> After upgrading to the 4.19 series I've started getting problems with
>>>> early OOM.
>>>
>>> What is the kenrel you have updated from? Would it be possible to try
>>> the current Linus' tree?
>>
>> I did some more testing and it turns out this is not a regression after all.
>>
>> I followed up on my hunch and monitored memory.kmem.max_usage_in_bytes while
>> running cgexec -g memory:12G bash -c 'find / -xdev -type f -print0 | \
>>         xargs -0 -n 1 -P 8 stat > /dev/null'
>>
>> Just as memory.kmem.max_usage_in_bytes = memory.kmem.limit_in_bytes the OOM
>> killer kicked in and killed my X server.
>>
>> Using the find|stat approach it was easy to test the problem in a testing VM.
>> I was able to reproduce the problem in all these kernels:
>>   4.9.0
>>   4.14.0
>>   4.14.115
>>   4.19.0
>>   5.2.11
>>
>> 5.3-rc6 didn't build in the VM. The build environment is too old probably.
>>
>> I was curious why I initially couldn't reproduce the problem in 4.14 by
>> building chromium. I was again able to successfully build chromium using
>> 4.14.115. Turns out memory.kmem.max_usage_in_bytes was 1015689216 after
>> building and my limit is set to 1073741824. I guess some unrelated change in
>> memory management raised that slightly for 4.19 triggering the problem.
>>
>> If you want to reproduce for yourself here are the steps:
>> 1. build any kernel above 4.9 using something like my .config
>> 2. setup a v1 memory cgroup with memory.kmem.limit_in_bytes lower than
>>    memory.limit_in_bytes. I used 100M in my testing VM.
>> 3. Run "find / -xdev -type f -print0 | xargs -0 -n 1 -P 8 stat > /dev/null"
>>    in the cgroup.
>> 4. Assuming there is enough inodes on the rootfs the global OOM killer
>>    should kick in when memory.kmem.max_usage_in_bytes =
>>    memory.kmem.limit_in_bytes and kill something outside the cgroup.
> 
> This is certainly a bug. Is this still an OOM triggered from
> pagefault_out_of_memory? Since 4.19 (29ef680ae7c21) the memcg charge
> path should invoke the memcg oom killer directly from the charge path.
> If that doesn't happen then the failing charge is either GFP_NOFS or a
> large allocation.
> 
> The former has been fixed just recently by http://lkml.kernel.org/r/cbe54ed1-b6ba-a056-8899-2dc42526371d@i-love.sakura.ne.jp
> and I suspect this is a fix you are looking for. Although it is curious
> that you can see a global oom even before because the charge path would
> mark an oom situation even for NOFS context and it should trigger the
> memcg oom killer on the way out from the page fault path. So essentially
> the same call trace except the oom killer should be constrained to the
> memcg context.
> 
> Could you try the above patch please?
> 

It won't help. We hitting ->kmem limit here, not the ->memory or ->memsw, so try_charge() is successful and
only __memcg_kmem_charge_memcg() fails to charge ->kmem and returns -ENOMEM.

Limiting kmem just never worked and it doesn't work now. AFAIK this feature hasn't been finished because 
there was no clear purpose/use case found. I remember that there was some discussion on lsfmm about this https://lwn.net/Articles/636331/
but I don't remember the discussion itself.

