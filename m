Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f182.google.com (mail-wi0-f182.google.com [209.85.212.182])
	by kanga.kvack.org (Postfix) with ESMTP id 5B84B6B0038
	for <linux-mm@kvack.org>; Thu, 25 Jun 2015 05:30:32 -0400 (EDT)
Received: by wiwl6 with SMTP id l6so12141200wiw.0
        for <linux-mm@kvack.org>; Thu, 25 Jun 2015 02:30:31 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id as8si51707668wjc.92.2015.06.25.02.30.30
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 25 Jun 2015 02:30:31 -0700 (PDT)
Message-ID: <558BCA35.80605@suse.cz>
Date: Thu, 25 Jun 2015 11:30:29 +0200
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: Write throughput impaired by touching dirty_ratio
References: <1506191513210.2879@stax.localdomain> <558A69F8.2080304@suse.cz> <1506242140070.1867@stax.localdomain>
In-Reply-To: <1506242140070.1867@stax.localdomain>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mark Hills <mark@xwax.org>
Cc: linux-mm@kvack.org, Michal Hocko <mhocko@suse.cz>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>

On 06/25/2015 12:26 AM, Mark Hills wrote:
> On Wed, 24 Jun 2015, Vlastimil Babka wrote:
>
>> [add some CC's]
>>
>> On 06/19/2015 05:16 PM, Mark Hills wrote:
>>
>> Hmm, so the only thing that dirty_ratio_handler() changes except the
>> vm_dirty_ratio itself, is ratelimit_pages through writeback_set_ratelimit(). So
>> I assume the problem is with ratelimit_pages. There's num_online_cpus() used in
>> the calculation, which I think would differ between the initial system state
>> (where we are called by page_writeback_init()) and later when all CPU's are
>> onlined. But I don't see CPU onlining code updating the limit (unlike memory
>> hotplug which does that), so that's suspicious.
>>
>> Another suspicious thing is that global_dirty_limits() looks at current
>> process's flag. It seems odd to me that the process calling the sysctl would
>> determine a value global to the system.
>
> Yes, I also spotted this. The fragment of code is:
>
>    	tsk = current;
> 	if (tsk->flags & PF_LESS_THROTTLE || rt_task(tsk)) {
> 		background += background / 4;
> 		dirty += dirty / 4;
> 	}
>
> It seems to imply the code was not always used from the /proc interface.
> It's relevant in a moment...
>
>> If you are brave enough (and have kernel configured properly and with
>> debuginfo),
>
> I'm brave... :) I hadn't seen this tool before, thanks for introducing me
> to it, I will use it more now, I'm sure.

Ok I admit I didn't expect so much outcome from my suggestion. Good job :)

>> you can verify how value of ratelimit_pages variable changes on the live
>> system, using the crash tool. Just start it, and if everything works,
>> you can inspect the live system. It's a bit complicated since there are
>> two static variables called "ratelimit_pages" in the kernel so we can't
>> print them easily (or I don't know how). First we have to get the
>> variable address:
>>
>> crash> sym ratelimit_pages
>> ffffffff81e67200 (d) ratelimit_pages
>> ffffffff81ef4638 (d) ratelimit_pages
>>
>> One will be absurdly high (probably less on your 32bit) so it's not the one we want:
>>
>> crash> rd -d ffffffff81ef4638 1
>> ffffffff81ef4638:    4294967328768
>>
>> The second will have a smaller value:
>> (my system after boot with dirty ratio = 20)
>> crash> rd -d ffffffff81e67200 1
>> ffffffff81e67200:             1577
>>
>> (after changing to 21)
>> crash> rd -d ffffffff81e67200 1
>> ffffffff81e67200:             1570
>>
>> (after changing back to 20)
>> crash> rd -d ffffffff81e67200 1
>> ffffffff81e67200:             1496
>
> In my case there's only one such symbol (perhaps because this kernel
> config is quite slimmed down?)
>
>    crash> sym ratelimit_pages
>    c148b618 (d) ratelimit_pages
>
>    (bootup with dirty_ratio 20)
>    crash> rd -d ratelimit_pages
>    c148b618:            78

With just one symbol you can use
crash> p ratelimit_pages

This will take the type properly into account, while rd will print full 
32bit/64bit depending on your kernel, which might be larger than the 
actual variable. But if there are more symbols of same name, "p" will 
somehow randomly pick one of them and don't even warn about it.

[snip]

>>>
>>
>
> Thanks, I hope you find this useful.

Yes, thanks, nice analysis. Since Michal already replied and has more 
experience with the reclaim code and dirty throttling, I won't try 
adding more.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
